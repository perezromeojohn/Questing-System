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

local QUEST_TYPES = QuestTypes

local questManager = {} -- module

-- lists
local playerQuests = {}

function questManager:Init(playerId, questData)
	if playerQuests[playerId] == nil then
		playerQuests[playerId] = {} -- Initialize as an empty table only if it's nil
	end

	for _, quest in pairs(questData) do
		questManager:CreateGUI(playerId, quest)
		questManager:UpdateQuestGUI(playerId, quest.questId, quest.progress, quest.questObjective, quest.completed)
		table.insert(playerQuests[playerId], quest) -- Insert each quest into the existing table
	end
end

function questManager:CreateQuestForPlayer(playerId, questattribute)
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


	-- Ensure playerQuests[playerId] is a table
	if playerQuests[playerId] == nil then
		playerQuests[playerId] = {} -- Initialize as an empty table if it's nil
	end

	table.insert(playerQuests[playerId], questData) -- Insert the new quest into the existing table

	local player = game.Players:GetPlayerByUserId(playerId)

	questManager:CreateGUI(playerId, questData)

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
	local playerGui = player.PlayerGui:WaitForChild("QuestSystem").MainFrame.Contents.ActiveFrame

	if questData.claimed ~= true  then
		local questHolderClone = questHolder:Clone()
		questHolderClone.Parent = playerGui
		questHolderClone.Name = questData.questId

		local questNameLabel = questHolderClone.QuestName
		local questObjectiveLabel = questHolderClone.ProgressBarFrame.ProgressBG.ProgressValue
		local questObjectiveBar = questHolderClone.ProgressBarFrame.ProgressBG.ProgressFG

		questNameLabel.Text = questData.questName
		questObjectiveLabel.Text = "0 / " .. tostring(questData.questObjective)
		questObjectiveBar.Size = UDim2.new(0, 0, 1, 0)

		-- Check if questData.reward1 and reward2 have values, and clone the GUI accordingly
		if questData.reward1 ~= nil then
			local rewardHolderClone = RS.QuestSystem.GUI.RewardHolder:Clone()
			rewardHolderClone.Parent = questHolderClone.RewardFrame.RewardHolder
			rewardHolderClone.Image = "rbxassetid://14092500930" -- might change
			rewardHolderClone.Amount.Text = "+"..tostring(questData.reward1) -- might change
		end

		if questData.reward2 ~= nil then
			local rewardHolderClone = RS.QuestSystem.GUI.RewardHolder:Clone()
			rewardHolderClone.Parent = questHolderClone.RewardFrame.RewardHolder
			rewardHolderClone.Amount.Text = "+"..tostring(questData.reward2) -- might change
		end

		if questData.reward1 == nil and questData.reward2 == nil then
			warn("This quest has no reward!")
		end
	end
end

-- Function to update the GUI for a player's quest
function questManager:UpdateQuestGUI(playerId, questId, progress, questObjective, questStatus)
	local player = game.Players:GetPlayerByUserId(playerId)
	local playerGui = player.PlayerGui:WaitForChild("QuestSystem").MainFrame.Contents.ActiveFrame
	local questHolderClone = playerGui:FindFirstChild(questId)

	local questData = {
		Progress = tostring(progress) .. " / " .. tostring(questObjective),
		ProgressRatio = progress / questObjective,
		QuestStatus = questStatus
	}

	-- Batch GUI updates for efficiency
	if questHolderClone then
		self:BatchUpdateQuestGUI(questHolderClone, questData)
	end

end

-- Function to batch update GUI elements for a quest
function questManager:BatchUpdateQuestGUI(questHolderClone, questData)
	local questObjectiveLabel = questHolderClone:WaitForChild("ProgressBarFrame").ProgressBG.ProgressValue
	local questObjectiveBar = questHolderClone:WaitForChild("ProgressBarFrame").ProgressBG.ProgressFG
	local questClaimFrame = questHolderClone:WaitForChild("ProgressBarFrame").ClaimFrame

	-- Perform batch GUI updates
	questObjectiveLabel.Text = questData.Progress
	questObjectiveBar.Size = UDim2.new(questData.ProgressRatio, 0, 1, 0)
	questClaimFrame.Visible = questData.QuestStatus
	if questData.QuestStatus == true then
		questClaimFrame.Visible = true
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
	local questData = questManager:GetQuestDataForPlayer(playerId, questId)
	if questData ~= nil then
		local player = game.Players:GetPlayerByUserId(playerId)
		local folder = player.Quests

		-- replace this with attribute stuff
		folder:WaitForChild(questId):SetAttribute("questObjective", questData.questObjective)
		folder:WaitForChild(questId):SetAttribute("progress", questData.progress)


		local questChecker = questManager:IsQuestCompletedForPlayer(playerId, questId)
		questManager:UpdateQuestGUI(playerId, questId, questData.progress, questData.questObjective, questChecker)
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

function questManager:DeletePlayerLeaderstats(playerId, questId)
	local player = game.Players:GetPlayerByUserId(playerId)
	local questData = questManager:GetQuestDataForPlayer(playerId, questId)
	local folder = player.Quests:WaitForChild(questId)

	if folder then
		--print(questData)
		-- folder:Destroy()
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
		end

		if questIndex then
			table.remove(playerQuests[playerId], questIndex)
		end

		-- Remove quest from playerQuests table
		if playerQuests[playerId] then
			playerQuests[playerId][questId] = nil
		end


		PlayerManager.SetQuestData(player, questData)
		questManager:DeleteQuestGUI(player, questId)
		-- print the new table
		-- print(playerQuests[playerId])
	else
		warn("Quest not found!")
	end
end


function questManager:DeleteQuestGUI(player, questId)
	local playerGui = player.PlayerGui:WaitForChild("QuestSystem").MainFrame.Contents.ActiveFrame
	local questHolderClone = playerGui:FindFirstChild(questId)
	if questHolderClone then
		questHolderClone:Destroy()
	end
end

-- Function to generate a unique identifier for a quest
function GenerateUniqueId()
	local randomId = HttpService:GenerateGUID(false)
	return randomId
end

-- Function to update progress for KILL_MOBS quests
function questManager:UpdateQuestProgress(playerId, questId, progress, questType, targetName) -- arguments has value
	for _, questData in ipairs(playerQuests[playerId]) do
		if questData.questId == questId then
			if questData.questType == questType and questData.completed == false then
				if questData.questTarget == targetName then
					questData.progress = questData.progress + progress
					questManager:UpdatePlayerLeaderStats(playerId, questId)
				end
			end
		end
	end
end

-- Function to update progress for GET_COINS quests
function questManager:UpdateGetCoinsQuestProgress(playerId, questId, coinsCollected)
	for _, questData in ipairs(playerQuests[playerId]) do
		if questData.questId == questId then
			if questData.questType == QUEST_TYPES.GET_COINS then
				questData.progress = questData.progress + coinsCollected
				questManager:UpdatePlayerLeaderStats(playerId, questId)
			end
		end
	end
end

-- remove GUI
function questManager:RemoveGUI(playerId)
	local player = game.Players:GetPlayerByUserId(playerId)
	local playerGui = player.PlayerGui:WaitForChild("QuestSystem").MainFrame.Contents.ActiveFrame
	for _, v in ipairs(playerGui:GetChildren()) do
		if v.Name ~= "UIGridLayout" then
			v:Destroy()
		end
	end
end

-- server events
claimQuest.OnServerEvent:Connect(function(player, questId, reward)
	questManager:DeletePlayerLeaderstats(player.UserId, questId)

	local QuestFolder = player:FindFirstChild("Quests")

	for _, questData in ipairs(QuestFolder:GetChildren()) do
		if questData:GetAttribute("questId") == questId then
			PlayerManager.SetMoney(player, PlayerManager.GetMoney(player) + questData:GetAttribute("reward1"))

			if questData:GetAttribute("reward2") then
				PlayerManager.SetSoul(player, PlayerManager.GetSoul(player) + questData:GetAttribute("reward2"))
			end
		end
	end

	print("HELL YES")
end)

createQuest.OnServerEvent:Connect(function(player, questId, bundle)
	questManager:CreateQuestForPlayer(questId, bundle)
end)



return questManager