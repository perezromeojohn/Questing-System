-- DATA STORE
local dataStoreService = game:GetService("DataStoreService")
local HttpService = game:GetService("HttpService")
local RS = game:GetService("ReplicatedStorage")
local TS = game:GetService("TweenService")
local SSS = game:GetService("ServerScriptService")

-- GUI STUFF
local questHolder = RS.QuestSystem.GUI.QuestHolder

-- Module and Stuff
local PlayerManager = require(game:GetService("ServerScriptService"):WaitForChild("PlayerManager"))
local QuestData = require(script.Parent.QuestData)
local QuestTypes = require(script.Parent.QuestTypes)

-- remotes and stuff
local claimQuest = RS.QuestSystem.Remotes.ClaimQuest
local notifQuest = RS.QuestSystem.Remotes.Notif
local createQuest = RS.QuestSystem.Remotes.CreateQuest
local event = RS.QuestSystem.Remotes.UpdateQuestProg

local beamEnable = RS.QuestSystem.Remotes.Beam

local QUEST_TYPES = QuestTypes

local function GenerateUniqueId()
	local randomId = HttpService:GenerateGUID(false)
	return randomId
end

local questManager = {} -- module
questManager.__index = questManager

-- lists
local playerQuests = {}

function questManager.new(player, playerId, questData)
	local self = setmetatable({}, questManager)

	self.Player = player

	self.questData = {}
	self.questData = questData
	self.playerId = playerId

	self.BindableEvent = event.Event:Connect(function(...)
		self:UpdateQuestProgress(...)
		self:TutorialChecker(...)
	end)

	self.ServerEvent = claimQuest.OnServerEvent:Connect(function(...)
		self:onServerEvent(...)
	end)

	self.ServerEventCreate = createQuest.OnServerEvent:Connect(function(...)
		self:CreateQuestForPlayer(...)
	end)

	return self

end

function questManager:Init()

	if playerQuests[self.playerId] == nil then
		playerQuests[self.playerId] = {} -- Initialize as an empty table only if it's nil
	end

	for _, quest in pairs(self.questData) do
		self:CreateGUI(self.playerId, quest)
		self:UpdateQuestGUI(self.playerId, quest.questId, quest.progress, quest.questObjective, quest.completed, quest.questCriteria, quest.questSource, quest.questName)
		table.insert(playerQuests[self.playerId], quest) -- Insert each quest into the existing table
		self:SetActiveQuest(self.playerId)
	end
end

function questManager:TutorialChecker(player)
	local quests = player.Quests

	for _,v in ipairs(quests:GetChildren()) do
		if v:GetAttribute("questCriteria") == "TutorialQuest" then
			self:onServerEvent(player, v:GetAttribute("questId"))
		end
	end
end

-- tutorial
function questManager:OnCharacterAdded(player, playerId, questTutorial)
	local quest = player:WaitForChild("Quests")
	local questLevel = player:WaitForChild("Quests"):GetAttribute("QuestLevel")

	-- get the first index in the QuestTutorial and pass it to the questData,new

	if questTutorial[questLevel] then
		local questData = QuestData.new()
		questData.questId = tostring(questTutorial[questLevel].questId + 1)
		questData.questSource = questTutorial[questLevel].Name
		questData.questName = questTutorial[questLevel].questName
		questData.questCriteria = questTutorial[questLevel].questCriteria
		questData.questType = questTutorial[questLevel].questType
		questData.questObjective = questTutorial[questLevel].questObjective
		questData.questTarget = questTutorial[questLevel].questTarget
		questData.progress = 0
		questData.completed = questTutorial[questLevel].completed
		questData.claimed = false
		questData.questrepeat = questTutorial[questLevel].questrepeat
		questData.reward1 = questTutorial[questLevel].reward1
		questData.reward2 = questTutorial[questLevel].reward2
		questData.reward3 = questTutorial[questLevel].reward3

		self:CheckDictionary(player, playerId, questTutorial)

		for _, npc in ipairs(game:GetService("Workspace"):FindFirstChild("NPC"):GetChildren()) do
			if npc:IsA("Model") and npc:GetAttribute("Name") == questData.questSource then
				npc:SetAttribute("QuestAccepted", true)
			end

			if questData.questTarget == npc:GetAttribute("Name") then
				game:GetService("CollectionService"):AddTag(npc, questData.questType )
			end
		end

		if playerQuests[playerId] == nil then
			playerQuests[playerId] = {} -- Initialize as an empty table if it's nil
		end

		for _, v in ipairs(quest:GetChildren()) do
			if v then
				if v.Name == questData.questId then
					return
				end
			end
		end

		table.insert(playerQuests[playerId], questData) -- Insert the new quest into the existing table

		local player = game.Players:GetPlayerByUserId(playerId)

		self:CreateGUI(playerId, questData)
		self:SetActiveQuest(playerId)

		-- Save
		PlayerManager.SetQuestData(player, questData)

		-- notifQuest:FireClient(player, "New Quest!")
	end
end

function questManager:CheckDictionary(player, playerId, questTutorial)
	local playerQuest = player:WaitForChild("Quests"):GetAttribute("QuestLevel")
	if next(questTutorial) == nil then
		return
	end

	questTutorial[playerQuest] = nil
end

function questManager:CreateQuestForPlayer(player, playerId, questattribute)
	if questattribute then
		local questData = QuestData.new()
		questData.questId = GenerateUniqueId()
		questData.questSource = questattribute["Name"] -- Attribute name of the NPC
		questData.questName = questattribute["questName"]
		questData.questCriteria = questattribute["questCriteria"]
		questData.questType = questattribute["questType"]
		questData.questObjective = questattribute["questObjective"] 
		questData.questTarget = questattribute["questTarget"]
		questData.progress = 0
		questData.completed = questattribute["completed"]
		questData.claimed = false
		questData.questrepeat = questattribute["questrepeat"]
		questData.reward1 = questattribute["reward1"]
		questData.reward2 = questattribute["reward2"]
		questData.reward3 = questattribute["reward3"]

		for _, npc in ipairs(game:GetService("Workspace"):FindFirstChild("NPC"):GetChildren()) do
			if npc:IsA("Model") and npc:GetAttribute("Name") == questattribute["Name"] then
				npc:SetAttribute("QuestAccepted", true)
			end

			if questData["questTarget"] == npc:GetAttribute("Name") then
				game:GetService("CollectionService"):AddTag(npc, questattribute["questType"] )
			end
		end

		-- Ensure playerQuests[playerId] is a table
		if playerQuests[playerId] == nil then
			playerQuests[playerId] = {} -- Initialize as an empty table if it's nil
		end

		table.insert(playerQuests[playerId], questData) -- Insert the new quest into the existing table

		local player = game.Players:GetPlayerByUserId(playerId)

		self:CreateGUI(playerId, questData)
		self:SetActiveQuest(playerId)

		-- Save
		PlayerManager.SetQuestData(player, questData)

		notifQuest:FireClient(player, "New Quest!")

		return questData.questId
	end
end

-- Function to create the GUI for a player's quest
function questManager:CreateGUI(playerId, questData)
	local player = game.Players:GetPlayerByUserId(playerId)

	if questData.claimed ~= true then
		local questHolderClone = questHolder:Clone()
		local questNameLabel = questHolderClone.QuestName
		local questObjectiveLabel = questHolderClone.ProgressBarFrame.ProgressBG.ProgressValue
		local questObjectiveBar = questHolderClone.ProgressBarFrame.ProgressBG.ProgressFG

		if questData.questCriteria == "MainQuest" or questData.questCriteria == "TutorialQuest" then
			local MainFrame = player.PlayerGui:WaitForChild("QuestSystem").MainFrame.Contents.MainQuest
			questHolderClone.Parent = MainFrame
			questHolderClone.Name = questData.questId
		else
			local SideFrame = player.PlayerGui:WaitForChild("QuestSystem").MainFrame.Contents.SideQuest
			questHolderClone.Parent = SideFrame
			questHolderClone.Name = questData.questId
		end

		questNameLabel.Text = questData.questName
		questObjectiveLabel.Text = "0 / " .. tostring(questData.questObjective)
		questObjectiveBar.Size = UDim2.new(0, 0, 1, 0)

		-- Check if questData.reward1 and reward2 have values, and clone the GUI accordingly
		if questData.reward1 > 0 then
			local rewardHolderClone = RS.QuestSystem.GUI.RewardHolder:Clone()
			rewardHolderClone.Parent = questHolderClone.RewardFrame.RewardHolder
			rewardHolderClone.Image = "rbxassetid://14092500930" -- might change
			rewardHolderClone.Amount.Text = "+"..tostring(questData.reward1) -- might change
		end

		if questData.reward2 > 0 then
			local rewardHolderClone = RS.QuestSystem.GUI.RewardHolder:Clone()
			rewardHolderClone.Parent = questHolderClone.RewardFrame.RewardHolder
			rewardHolderClone.Amount.Text = "+"..tostring(questData.reward2) -- might change
		end

		if questData.reward3 == true then
			local rewardHolderClone = RS.QuestSystem.GUI.RewardHolder:Clone()
			rewardHolderClone.Image = "rbxassetid://15486414192" -- might change
			rewardHolderClone.Parent = questHolderClone.RewardFrame.RewardHolder
			rewardHolderClone.Amount.Text = "Guardian" -- might change
		end

		if questData.reward1 == nil and questData.reward2 == nil and questData.reward3 == nil then
			warn("This quest has no reward!")
		end

		-- beams
		if questData.questCriteria == "TutorialQuest" then
			beamEnable:FireClient(player, questData.questSource, true, questData.questCriteria)
		end
	end
end

-- Function to update the GUI for a player's quest
function questManager:UpdateQuestGUI(playerId, questId, progress, questObjective, questStatus, questCriteria, questSource, questName)

	local player = game.Players:GetPlayerByUserId(playerId)
	local playerGui = player.PlayerGui:WaitForChild("QuestSystem").MainFrame.Contents

	for _, v in ipairs(playerGui:GetDescendants()) do
		if questId == v.Name  then
			local questHolderClone = v

			local questData = {
				Progress = tostring(progress) .. " / " .. tostring(questObjective),
				ProgressRatio = progress / questObjective,
				QuestStatus = questStatus,
				PlayerID = playerId,
				QuestID = questId,
				QuestCriteria = questCriteria,
				QuestSource = questSource,
				QuestName = questName,
			}

			-- Batch GUI updates for efficiency
			if questHolderClone then
				self:BatchUpdateQuestGUI(questHolderClone, questData)
			end
		end
	end
end
-- Function to batch update GUI elements for a quest
function questManager:BatchUpdateQuestGUI(questHolderClone, questData)
	local questObjectiveLabel = questHolderClone:WaitForChild("ProgressBarFrame").ProgressBG.ProgressValue
	local questObjectiveBar = questHolderClone:WaitForChild("ProgressBarFrame").ProgressBG.ProgressFG
	local questClaimFrame = questHolderClone:WaitForChild("Template").ClaimFrame
	local questMainClaim = questHolderClone:WaitForChild("Template").MainQuestClaim
	-- Perform batch GUI updates
	questObjectiveLabel.Text = questData.Progress
	questObjectiveBar.Size = UDim2.new(questData.ProgressRatio, 0, 1, 0)
	--questClaimFrame.Visible = questData.QuestStatus
	self:UpdateActiveQuest(questData.PlayerID, questData.QuestID, questData)
	if questData.QuestStatus == true then
		if questData.QuestCriteria == "MainQuest" then
			local claim = questMainClaim:Clone()
			claim.Parent =  questHolderClone:WaitForChild("ProgressBarFrame")
			claim.NPCname.Text = "Talk to " .. questData.QuestSource 
			claim.Visible = true
		else
			local claim = questClaimFrame:Clone()
			claim.Parent =  questHolderClone:WaitForChild("ProgressBarFrame")
			claim.Visible = true
		end
	end
end

-- Function to update the ActiveQuest GUI
function questManager:UpdateActiveQuest(playerId, questId, questData)
	local player = game.Players:GetPlayerByUserId(playerId)
	local activeQuestFrame = player.PlayerGui.QuestSystem.ActiveQuest
	local activeQuestText = activeQuestFrame.Holder.ActiveQuest
	local iconCheck = activeQuestFrame.Check
	local progressText = activeQuestFrame.Progress

	if activeQuestFrame.Visible == true then
		activeQuestText.Text = questData.QuestName
		progressText.Text = questData.Progress
		if questData.QuestStatus == true then
			iconCheck.Visible = true
		else
			iconCheck.Visible = false
		end
	end
end

-- Function to update the progress of a player's quest
function questManager:UpdateQuestProgressForPlayer(playerId, questId, progress)
	for _, questData in ipairs(playerQuests[playerId]) do
		if questData.questId == questId then
			questData.progress = progress
		end
	end
end

-- Function to get a player's quest
function questManager:GetQuestForPlayer(playerId)
	return playerQuests[playerId]
end

-- Function to check if a player's quest is completed
function questManager:IsQuestCompletedForPlayer(playerId, questId)
	for _, questData in ipairs(playerQuests[playerId]) do
		if questData.questId == questId and questData.progress == questData.questObjective then
			questData.completed = true
			return true
		end
	end
	return false
end

-- Function to get the quest data for a player's quest
function questManager:GetQuestDataForPlayer(playerId, questId)
	for _, questData in ipairs(playerQuests[playerId]) do
		if questData.questId == questId then
			return questData
		end
	end
	return nil
end

function questManager:UpdatePlayerLeaderStats(playerId, questId)
	local questData = self:GetQuestDataForPlayer(playerId, questId)
	if questData ~= nil then
		local player = game.Players:GetPlayerByUserId(playerId)
		local folder = player.Quests

		-- replace this with attribute stuff
		folder:WaitForChild(questId):SetAttribute("questObjective", questData.questObjective)
		folder:WaitForChild(questId):SetAttribute("progress", questData.progress)


		local questChecker = self:IsQuestCompletedForPlayer(playerId, questId)
		self:UpdateQuestGUI(playerId, questId, questData.progress, questData.questObjective, questChecker, questData.questCriteria, questData.questSource, questData.questName)
		if questChecker == true then
			-- set attribute questClaimed.Value,
			-- folder:WaitForChild(questId):SetAttribute("claimed", questData.claimed)
			questData.completed = true
			folder:WaitForChild(questId):SetAttribute("completed", questData.completed)
			notifQuest:FireClient(player, "Quest Completed!")
			if questData.questCriteria == "MainQuest" then
				beamEnable:FireClient(player, questData.questSource, true, questData.questCriteria)
			end
		end
		PlayerManager.SetQuestData(player, questData)
	end
end

-- function to see Active Quest in the GUI
function questManager:SetActiveQuest(playerId)
	local player = game.Players:GetPlayerByUserId(playerId)
	local playerQuests = self:GetQuestForPlayer(playerId)
	local activeQuestFrame = player.PlayerGui.QuestSystem.ActiveQuest
	local checkIcon = activeQuestFrame.Check
	local activeQuestText = activeQuestFrame.Holder.ActiveQuest
	local progressText = activeQuestFrame.Progress

	if playerQuests == {} then return end

	checkIcon.Visible = false

	-- Check for completed but unclaimed quest
	for _, questData in ipairs(playerQuests) do
		if questData.completed and not questData.claimed then
			activeQuestText.Text = questData.questName
			progressText.Text = tostring(questData.progress) .. " / " .. tostring(questData.questObjective)
			activeQuestFrame.Visible = true
			checkIcon.Visible = true
			beamEnable:FireClient(player, questData.questSource, true, questData.questCriteria)
			return
		end
	end

	-- Check for incomplete quest with progress
	for _, questData in ipairs(playerQuests) do
		if questData.progress > 0 and questData.progress < questData.questObjective and not questData.completed then
			activeQuestText.Text = questData.questName
			progressText.Text = tostring(questData.progress) .. " / " .. tostring(questData.questObjective)
			activeQuestFrame.Visible = true
			return
		end
	end

	-- check for quests that are not completed
	for _, questData in ipairs(playerQuests) do
		if questData.progress == 0 and questData.completed == false then
			activeQuestText.Text = questData.questName
			progressText.Text = tostring(questData.progress) .. " / " .. tostring(questData.questObjective)
			activeQuestFrame.Visible = true
			return
		end
	end

	activeQuestFrame.Visible = false
end


function questManager:DeletePlayerLeaderstats(playerId, questId)
	local player = game.Players:GetPlayerByUserId(playerId)
	local questData = self:GetQuestDataForPlayer(playerId, questId)
	local folder = player.Quests:FindFirstChild(questId)

	if folder:GetAttribute("claimed") == false then
		folder:SetAttribute("claimed", true)
		if  questData and questData.claimed == false then
			questData.claimed = true
			questData.questSource = folder:GetAttribute("questSource")
		else
			return
		end

		for i, v in ipairs(playerQuests[playerId]) do
			if v.questId == questId then
				if i then
					table.remove(playerQuests[playerId], i)
				end

				for _, npc in ipairs(game:GetService("Workspace"):FindFirstChild("NPC"):GetChildren()) do
					if npc:IsA("Model") and npc:GetAttribute("Name") == v.questSource then
						npc:SetAttribute("QuestAccepted", false)
					end
				end
			end
		end

		-- Remove quest from playerQuests table
		if playerQuests[playerId] then
			playerQuests[playerId][questId] = nil
		end

		PlayerManager.SetQuestData(player, questData)
		self:DeleteQuestGUI(player, questId)
	else
		warn("Quest not found!")
	end
end


function questManager:DeleteQuestGUI(player, questId)
	local playerGui = player.PlayerGui:WaitForChild("QuestSystem").MainFrame.Contents

	for _, v in ipairs(playerGui:GetDescendants()) do
		if v.Name == questId then
			local questHolderClone = v

			if questHolderClone then
				questHolderClone:Destroy()
			end
		end
	end
end


function questManager:UpdateQuestProgress(player, playerId, questId, progress, questType, targetName) -- arguments has value
	for _, questData in ipairs(playerQuests[playerId]) do
		if questData.questId == questId and player == self.Player and questData.completed ~= true then
			if questData.questTarget == targetName then
				questData.progress = questData.progress + progress
				self:UpdatePlayerLeaderStats(playerId, questId)
			end
		end
	end
end

function questManager:onServerEvent(player, questId, guardianName) 

	self:DeletePlayerLeaderstats(player.UserId, questId)
	local guardianBindableEvent = game:GetService("ReplicatedStorage"):WaitForChild("Signals"):WaitForChild("GuardianBindableEvent")
	local QuestFolder = player:FindFirstChild("Quests")

	self:SetActiveQuest(player.UserId)

	for _, questData in ipairs(QuestFolder:GetChildren()) do
		if questData:GetAttribute("questId") == questId then
			PlayerManager.SetMoney(player, PlayerManager.GetMoney(player) + questData:GetAttribute("reward1"))

			if questData:GetAttribute("reward2") then
				PlayerManager.SetSoul(player, PlayerManager.GetSoul(player) + questData:GetAttribute("reward2"))
			end

			if questData:GetAttribute("reward3") == true then
				guardianBindableEvent:Fire(player, guardianName)
			end

			--New
			if questData:GetAttribute("questCriteria") == "SideQuest" then return end

			PlayerManager.SetQuestLevel(player, 1)			

			beamEnable:FireClient(player, questData:GetAttribute("questSource"), false, questData:GetAttribute("questCriteria"))
		end
	end
end

return questManager