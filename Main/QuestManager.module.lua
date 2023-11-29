-- DATA STORE
local dataStoreService = game:GetService("DataStoreService")
local HttpService = game:GetService("HttpService")
local RS = game:GetService("ReplicatedStorage")
local TS = game:GetService("TweenService")

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

local QUEST_TYPES = QuestTypes

local questManager = {} -- module
questManager.__index = questManager

-- lists
local playerQuests = {}

function questManager:Init(player, playerId, questData)
	local self = setmetatable({}, questManager)

	self.Player = player

	if playerQuests[playerId] == nil then
		playerQuests[playerId] = {} -- Initialize as an empty table only if it's nil
	end

	for _, quest in pairs(questData) do
		self:CreateGUI(playerId, quest)
		self:UpdateQuestGUI(playerId, quest.questId, quest.progress, quest.questObjective, quest.completed)
		table.insert(playerQuests[playerId], quest) -- Insert each quest into the existing table
		self:SetActiveQuest(playerId)
	end

	event.Event:Connect(function(...)
		self:UpdateQuestProgress(...)
	end)

	return self
end

function questManager:CreateQuestForPlayer(playerId, questattribute)
	local questData = QuestData.new()
	questData.questId = self:GenerateUniqueId()
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

	-- print(playerQuests[playerId])
	-- print(playerQuests)

	notifQuest:FireClient(player, "New Quest!")

	return questData.questId
end

-- Function to create the GUI for a player's quest
function questManager:CreateGUI(playerId, questData)
	local player = game.Players:GetPlayerByUserId(playerId)
	
	if questData.claimed ~= true then
		local questHolderClone = questHolder:Clone()
		local questNameLabel = questHolderClone.QuestName
		local questObjectiveLabel = questHolderClone.ProgressBarFrame.ProgressBG.ProgressValue
		local questObjectiveBar = questHolderClone.ProgressBarFrame.ProgressBG.ProgressFG
		
		if questData.questCriteria == "MainQuest" then
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
	end
	
	

	
end

-- Function to update the GUI for a player's quest
function questManager:UpdateQuestGUI(playerId, questId, progress, questObjective, questStatus)
	local player = game.Players:GetPlayerByUserId(playerId)
	local playerGui = player.PlayerGui:WaitForChild("QuestSystem").MainFrame.Contents
	
	for _, v in ipairs(playerGui:GetDescendants()) do
		if v.Name == questId then
			local questHolderClone = v
			
			local questData = {
				Progress = tostring(progress) .. " / " .. tostring(questObjective),
				ProgressRatio = progress / questObjective,
				QuestStatus = questStatus,
				PlayerID = playerId,
				QuestID = questId,
			}

			-- Batch GUI updates for efficiency
			if questHolderClone then
				self:BatchUpdateQuestGUI(questHolderClone, questData)
			end
		end
	end
	

	
	
end

-- Function to update the ActiveQuest GUI
function questManager:UpdateActiveQuest(playerId, questId, questData)
	local player = game.Players:GetPlayerByUserId(playerId)
	local activeQuestFrame = player.PlayerGui.QuestSystem.ActiveQuest
	local iconCheck = activeQuestFrame.Check
	local progressText = activeQuestFrame.Progress

	if activeQuestFrame.Visible == true then
		progressText.Text = questData.Progress
		if questData.QuestStatus == true then
			iconCheck.Visible = true
		else
			iconCheck.Visible = false
		end
	end
end

-- Function to batch update GUI elements for a quest
function questManager:BatchUpdateQuestGUI(questHolderClone, questData)
	local questObjectiveLabel = questHolderClone:WaitForChild("ProgressBarFrame").ProgressBG.ProgressValue
	local questObjectiveBar = questHolderClone:WaitForChild("ProgressBarFrame").ProgressBG.ProgressFG
	local questClaimFrame = questHolderClone:WaitForChild("Template").ClaimFrame
	-- get the player's starterGUI base on the questData
	local player = game.Players:GetPlayerByUserId(questData.PlayerID)
	local notif = player.PlayerGui:WaitForChild("QuestSystem").MainButton.Notif

	-- Perform batch GUI updates
	questObjectiveLabel.Text = questData.Progress
	questObjectiveBar.Size = UDim2.new(questData.ProgressRatio, 0, 1, 0)
	--questClaimFrame.Visible = questData.QuestStatus
	self:UpdateActiveQuest(questData.PlayerID, questData.QuestID, questData)
	if questData.QuestStatus == true then
		local claim = questClaimFrame:Clone()
		claim.Parent =  questHolderClone:WaitForChild("ProgressBarFrame")
		claim.Visible = true
		notif.Visible = true
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
		self:UpdateQuestGUI(playerId, questId, questData.progress, questData.questObjective, questChecker)
		if questChecker == true then
			-- set attribute questClaimed.Value,
			-- folder:WaitForChild(questId):SetAttribute("claimed", questData.claimed)
			questData.completed = true
			folder:WaitForChild(questId):SetAttribute("completed", questData.completed)
			notifQuest:FireClient(player, "Quest Completed!")
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

	checkIcon.Visible = false

	-- Check for completed but unclaimed quest
	for _, questData in ipairs(playerQuests) do
		if questData.completed and not questData.claimed then
			activeQuestText.Text = questData.questName
			progressText.Text = tostring(questData.progress) .. " / " .. tostring(questData.questObjective)
			activeQuestFrame.Visible = true
			checkIcon.Visible = true
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

	-- Hide the ActiveQuest frame if no appropriate quest found
	warn("No Quest Found")
	activeQuestFrame.Visible = false
end


function questManager:DeletePlayerLeaderstats(playerId, questId)
	print(questId)
	local player = game.Players:GetPlayerByUserId(playerId)
	local questData = self:GetQuestDataForPlayer(playerId, questId)
	local folder = player.Quests:WaitForChild(questId)
	
	print(questData)

	if folder then
		folder:SetAttribute("claimed", true)
		if  questData and questData.claimed == false then
			questData.claimed = true
			questData.questSource = "DONEZO" -- change this when completed my guy
		else
			return
		end

		local questIndex
		for i, v in ipairs(playerQuests[playerId]) do
			if v.questId == questId then
				questIndex = i
				break
			end
			print(v)
			print(v.questSource)
			--for _, npc in ipairs(game:GetService("Workspace"):FindFirstChild("NPC"):GetChildren()) do
			--	print(npc)
			--	if npc:IsA("Model") and npc:GetAttribute("Name") == v.questSource then
			--		npc:SetAttribute("QuestAccepted", false)
			--	end
			--end
		end

		if questIndex then
			table.remove(playerQuests[playerId], questIndex)
		end

		-- Remove quest from playerQuests table
		if playerQuests[playerId] then
			playerQuests[playerId][questId] = nil
		end


		PlayerManager.SetQuestData(player, questData)
		self:DeleteQuestGUI(player, questId)
		-- print the new table
		-- print(playerQuests[playerId])
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

-- Function to generate a unique identifier for a quest
function questManager:GenerateUniqueId()
	local randomId = HttpService:GenerateGUID(false)
	return randomId
end

-- Function to update progress for KILL_MOBS quests
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

-- remove GUI
--function questManager:RemoveGUI(playerId)
--	local player = game.Players:GetPlayerByUserId(playerId)
--	local playerGui = player.PlayerGui:WaitForChild("QuestSystem").MainFrame.Contents.MainQuest
--	for _, v in ipairs(playerGui:GetChildren()) do
--		if v.Name ~= "UIGridLayout" then
--			v:Destroy()
--		end
--	end
--end

-- server events
claimQuest.OnServerEvent:Connect(function(player, questId, reward)
	questManager:DeletePlayerLeaderstats(player.UserId, questId)
	local guardianBindableEvent = game:GetService("ReplicatedStorage"):WaitForChild("Signals"):WaitForChild("GuardianBindableEvent")
	local QuestFolder = player:FindFirstChild("Quests")

	for _, questData in ipairs(QuestFolder:GetChildren()) do
		if questData:GetAttribute("questId") == questId then
			PlayerManager.SetMoney(player, PlayerManager.GetMoney(player) + questData:GetAttribute("reward1"))

			if questData:GetAttribute("reward2") then
				PlayerManager.SetSoul(player, PlayerManager.GetSoul(player) + questData:GetAttribute("reward2"))
			end

			if questData:GetAttribute("reward3") == true then
				local guardianfolder = game:GetService("ReplicatedStorage").GuardianFolder
				local checkTable = {}

				for i, v in ipairs(guardianfolder:GetChildren()) do
					if v:IsA("Model") then
						table.insert(checkTable, v.Name)
					end
				end

				local getRandomItem = checkTable[math.random(1, #checkTable)]
				guardianBindableEvent:Fire(player, getRandomItem)
			end

			-- if questdata is MainQuest then print "Next Quest"
			if questData:GetAttribute("questCriteria") == "MainQuest" then
				PlayerManager.SetQuestLevel(player, 1)
				-- print("Next Quest")
			end
		end
	end

	questManager:SetActiveQuest(player.UserId)
end)

createQuest.OnServerEvent:Connect(function(player, questId, bundle)
	questManager:CreateQuestForPlayer(questId, bundle)
end)



return questManager