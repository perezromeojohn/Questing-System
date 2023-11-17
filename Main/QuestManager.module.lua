-- DATA STORE
local dataStoreService = game:GetService("DataStoreService")
local questDataStore = dataStoreService:GetDataStore("TESTTHINGY1") -- rename this for new database

local HttpService = game:GetService("HttpService")
local RS = game:GetService("ReplicatedStorage")
local TS = game:GetService("TweenService")

-- Module and Stuff
local QuestData = require(script.Parent.QuestData)
local QuestTypes = require(script.Parent.QuestTypes)

local QUEST_TYPES = QuestTypes

-- Lists
local questManager = {}
local playerQuests = {}

-- Function to create a new quest for a player
function questManager:CreateQuestForPlayer(playerId, questName, questCriteria, questType, questObjective)
	local questData = QuestData.new()
	questData.questId = GenerateUniqueId()
	questData.questName = questName
	questData.questCriteria = questCriteria
	questData.questType = questType
	questData.questObjective = questObjective
	questData.progress = 0
	questData.completed = false
	questData.claimed = false

	-- Ensure playerQuests[playerId] is a table
	if playerQuests[playerId] == nil then
		playerQuests[playerId] = {}
	end

	-- Add the quest to the player's quest list
	table.insert(playerQuests[playerId], questData)

	-- Serialize the player's quest data into JSON
	-- local playerQuestJSON = HttpService:JSONEncode(playerQuests[playerId])

	-- Store the JSON string in the DataStore
	-- questDataStore:SetAsync(playerId, playerQuestJSON)

	-- so inside a player, there's a quest folder and inside that folder it has a playerid string value. now I want to make a string value inside it too that represents this data for example:
	--
	-- [4641573294] =  ▼  { -- playerid
	--     ["questId"] = "34085E80-E394-41DF-AE46-FD39EB22689D" =  ▼  { 
	--         ["completed"] = false, -- completed = boolean
	--         ["progress"] = 0, -- progress = number
	--         ["questObjective"] = 15, -- questObjective = number
	--         ["questType"] = "KILL_MOBS" -- questType = string
	--         ["claimed"] = false -- claimed = boolean
	--      }
	--   }

	-- i want to store these inside the player's quests folder's playerid string value
	local player = game.Players:GetPlayerByUserId(playerId)
	local folder = player.Quests:WaitForChild("playerId")
	local questId = Instance.new("StringValue", folder)
	questId.Name, questId.Value = questData.questId, questData.questId
	for k, v in pairs({completed = questData.completed, progress = questData.progress, questObjective = questData.questObjective, questType = questData.questType, claimed = questData.claimed, questName = questData.questName, questCriteria = questData.questCriteria}) do
		local val = Instance.new(typeof(v) == "boolean" and "BoolValue" or typeof(v) == "number" and "IntValue" or "StringValue", questId)
		val.Name, val.Value = k, v
	end

	return questData.questId
end

-- Function to update the progress of a player's quest
function questManager:UpdateQuestProgressForPlayer(playerId, questId, progress)
	for _, questData in ipairs(playerQuests[playerId]) do
		if questData.questId == questId then
			questData.progress = progress
			break
		end
	end
end

function questManager:GetQuestForPlayer(playerId)
	return playerQuests[playerId]
end

-- Function to check if a player's quest is completed
function questManager:IsQuestCompletedForPlayer(playerId, questId)
	for _, questData in ipairs(playerQuests[playerId]) do
		if questData.questId == questId and questData.progress >= questData.questObjective then
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
		local folder = player.Quests:WaitForChild("playerId")

		local questObjective = folder:WaitForChild(questId).questObjective
		local questProgress = folder:WaitForChild(questId).progress
		local questStatus = folder:WaitForChild(questId).completed
		local questClaimed = folder:WaitForChild(questId).claimed

		questObjective.Value = questData.questObjective
		questProgress.Value = questData.progress
		questStatus.Value = questData.completed

		local questChecker = questManager:IsQuestCompletedForPlayer(playerId, questId)
		if questChecker == true then
			-- delete the folder:waitForChild questId of it
			local questIdFolder = folder:WaitForChild(questId)
			-- set questClaimed to true
			questClaimed.Value, questData.claimed = true, true

			warn("Quest completed!")
		end
	end
end

-- Function to generate a unique identifier for a quest
function GenerateUniqueId()
	local randomId = HttpService:GenerateGUID(false)
	return randomId
end

-- Function to update progress for KILL_MOBS quests
function questManager:UpdateKillMobsQuestProgress(playerId, questId, mobKills, questType)
	for _, questData in ipairs(playerQuests[playerId]) do
		if questData.questId == questId and questData.questType == questType then
			print(questData.claimed)
			if questData.claimed == false then
				questData.progress = questData.progress + mobKills
				questManager:UpdatePlayerLeaderStats(playerId, questId)
			end
			break
		end
	end
end

-- Function to update progress for GET_COINS quests
function questManager:UpdateGetCoinsQuestProgress(playerId, questId, coinsCollected)
	for _, questData in ipairs(playerQuests[playerId]) do
		if questData.questId == questId and questData.questType == QUEST_TYPES.GET_COINS then
			questData.progress = questData.progress + coinsCollected
			break
		end
	end
end

return questManager
