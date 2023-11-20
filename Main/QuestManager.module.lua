-- DATA STORE
local dataStoreService = game:GetService("DataStoreService")
local questDataStore = dataStoreService:GetDataStore("TESTTHINGY1") -- rename this for new database


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

local QUEST_TYPES = QuestTypes

local questManager = {} -- module

-- lists
local playerQuests = {}

function questManager:Init(playerId, questData)
	if playerQuests[playerId] == nil then
		playerQuests[playerId] = {} -- Initialize as an empty table only if it's nil
	end

	for _, quest in pairs(questData) do
		table.insert(playerQuests[playerId], quest) -- Insert each quest into the existing table
	end

end

function questManager:CreateQuestForPlayer(playerId, questName, questCriteria, questType, questObjective, questTarget)
	local questData = QuestData.new()
	questData.questId = GenerateUniqueId()
	questData.questName = questName
	questData.questCriteria = questCriteria
	questData.questType = questType
	questData.questObjective = questObjective
	questData.questTarget = questTarget
	questData.progress = 0
	questData.completed = false
	questData.claimed = false

	-- Ensure playerQuests[playerId] is a table
	if playerQuests[playerId] == nil then
		playerQuests[playerId] = {} -- Initialize as an empty table if it's nil
	end

	table.insert(playerQuests[playerId], questData) -- Insert the new quest into the existing table

	local player = game.Players:GetPlayerByUserId(playerId)

	questManager:CreateGUI(playerId, questData)

	-- Save
	PlayerManager.SetQuestData(player, questData)

	print(playerQuests[playerId])
	print(playerQuests)

	return questData.questId
end

-- Function to create the GUI for a player's quest
function questManager:CreateGUI(playerId, questData)
	--.questId, v.questName, v.questObjective
	--questId, questName, questObjective
	local player = game.Players:GetPlayerByUserId(playerId)
	local playerGui = player.PlayerGui:WaitForChild("QuestSystem").MainFrame.Contents.ActiveFrame
	
	if questData.claimed ~= true  then
		print("okay")
		local questHolderClone = questHolder:Clone()
		questHolderClone.Parent = playerGui
		questHolderClone.Name = questData.questId
		
		local questNameLabel = questHolderClone.QuestName
		local questObjectiveLabel = questHolderClone.ProgressBarFrame.ProgressBG.ProgressValue
		local questObjectiveBar = questHolderClone.ProgressBarFrame.ProgressBG.ProgressFG

		questNameLabel.Text = questData.questName
		questObjectiveLabel.Text = "0 / " .. tostring(questData.questObjective)
		questObjectiveBar.Size = UDim2.new(0, 0, 1, 0)
	end
	
	
end

-- Function to update the GUI for a player's quest
function questManager:UpdateQuestGUI(playerId, questId, progress, questObjective, questStatus)
	print("warn")
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
			print(questData.progress, questData.questObjective)
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
			warn("Quest completed!")
		end
		PlayerManager.SetQuestData(player, questData)
	end
end

function questManager:DeletePlayerLeaderstats(playerId, questId)
	local player = game.Players:GetPlayerByUserId(playerId)
	local questData = questManager:GetQuestDataForPlayer(playerId, questId)
	print(questData)
	local folder = player.Quests:WaitForChild(questId)

	if folder then
		-- folder:Destroy()
		questManager:DeleteQuestGUI(player, questId)

		local questIndex
		for i, v in ipairs(playerQuests[playerId]) do
			if v.questId == questId then
				questIndex = i
				break
			end
		end

		folder:SetAttribute("claimed", true)
		questData.claimed = true

		if questIndex then
			table.remove(playerQuests[playerId], questIndex)
		end

		-- Remove quest from playerQuests table
		if playerQuests[playerId] then
			playerQuests[playerId][questId] = nil
		end


		PlayerManager.SetQuestData(player, questData)
		print(questData)
		-- print the new table
		-- print(playerQuests[playerId])
	else
		warn("Quest not found!")
	end
end


function questManager:DeleteQuestGUI(player, questId)
	local playerGui = player.PlayerGui:WaitForChild("QuestSystem").MainFrame.Contents.ActiveFrame
	local questHolderClone = playerGui:WaitForChild(questId)
	questHolderClone:Destroy()
end

-- Function to generate a unique identifier for a quest
function GenerateUniqueId()
	local randomId = HttpService:GenerateGUID(false)
	return randomId
end

-- Function to update progress for KILL_MOBS quests
function questManager:UpdateKillMobsQuestProgress(playerId, questId, mobKills, questType, mobName) -- arguments has value
	for _, questData in ipairs(playerQuests[playerId]) do
		if questData.questId == questId then
			if questData.questType == questType and questData.completed == false then
				if questData.questTarget == mobName then
					questData.progress = questData.progress + mobKills
					questManager:UpdatePlayerLeaderStats(playerId, questId)
				end
			end
		else
			warn("Invalid")
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

-- server events
claimQuest.OnServerEvent:Connect(function(player, questId)
	questManager:DeletePlayerLeaderstats(player.UserId, questId)
	print("REWARD CLAIM")
end)

return questManager