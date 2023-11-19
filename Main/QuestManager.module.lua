-- DATA STORE
local dataStoreService = game:GetService("DataStoreService")
local questDataStore = dataStoreService:GetDataStore("TESTTHINGY1") -- rename this for new database

local HttpService = game:GetService("HttpService")
local RS = game:GetService("ReplicatedStorage")
local TS = game:GetService("TweenService")

-- GUI STUFF
local questHolder = RS.QuestSystem.GUI.QuestHolder

-- Module and Stuff
local QuestData = require(script.Parent.QuestData)
local QuestTypes = require(script.Parent.QuestTypes)

-- remotes and stuff
local claimQuest = RS.QuestSystem.Remotes.ClaimQuest

local QUEST_TYPES = QuestTypes

local questManager = {} -- module

-- lists
local playerQuests = {}
local playerQuestIndex = {}

-- Save function
function questManager:SavePlayerQuests(playerId)
    local playerData = playerQuests[playerId]
    if playerData then
        local success, errorMessage = pcall(function()
            questDataStore:SetAsync(playerId, playerData)
        end)
        if not success then
            warn("Error saving player data: " .. errorMessage)
        end
    else
        warn("No data found for playerId: " .. tostring(playerId))
    end
end

-- Load function
function questManager:LoadPlayerQuests(playerId)
    local success, playerData = pcall(function()
        return questDataStore:GetAsync(playerId)
    end)
    if success and playerData then
        playerQuests[playerId] = playerData
        for _, questData in pairs(playerData) do
			questManager:CreateGUI(playerId, questData.questId, questData.questName, questData.questObjective)
			if not playerQuestIndex[playerId] then
				playerQuestIndex[playerId] = {}
			end
			playerQuestIndex[playerId][questData.questId] = questData
			local player = game.Players:GetPlayerByUserId(playerId)
			local folder = player.Quests:WaitForChild("playerId")
			local questId = Instance.new("StringValue", folder)
			questId.Name, questId.Value = questData.questId, questData.questId
			for k, v in pairs({completed = questData.completed, progress = questData.progress, questObjective = questData.questObjective, questType = questData.questType, claimed = questData.claimed, questName = questData.questName, questCriteria = questData.questCriteria}) do
				local val = Instance.new(typeof(v) == "boolean" and "BoolValue" or typeof(v) == "number" and "IntValue" or "StringValue", questId)
				val.Name, val.Value = k, v
			end
			questManager:UpdatePlayerLeaderStats(playerId, questData.questId)
        end
    else
        warn("Error loading player data for playerId: " .. tostring(playerId))
    end
end

-- function to remove a completed quest in the da

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

	questManager:CreateGUI(playerId, questData.questId, questName, questObjective)

	if not playerQuestIndex[playerId] then
        playerQuestIndex[playerId] = {}
    end
    playerQuestIndex[playerId][questData.questId] = questData

	-- save
	questManager:SavePlayerQuests(playerId)

	return questData.questId
end

-- Function to create the GUI for a player's quest
function questManager:CreateGUI(playerId, questId, questName, questObjective)
	local player = game.Players:GetPlayerByUserId(playerId)
	local playerGui = player.PlayerGui:WaitForChild("QuestSystem").MainFrame.Contents.ActiveFrame
	local questHolderClone = questHolder:Clone()
	questHolderClone.Parent = playerGui
	questHolderClone.Name = questId

	local questNameLabel = questHolderClone.QuestName
	local questObjectiveLabel = questHolderClone.ProgressBarFrame.ProgressBG.ProgressValue
	local questObjectiveBar = questHolderClone.ProgressBarFrame.ProgressBG.ProgressFG

	questNameLabel.Text = questName
	questObjectiveLabel.Text = "0 / " .. tostring(questObjective)
	questObjectiveBar.Size = UDim2.new(0, 0, 1, 0)
end

-- Function to update the GUI for a player's quest
function questManager:UpdateQuestGUI(playerId, questId, progress, questObjective, questStatus)
    local player = game.Players:GetPlayerByUserId(playerId)
    local playerGui = player.PlayerGui:WaitForChild("QuestSystem").MainFrame.Contents.ActiveFrame
    local questHolderClone = playerGui:WaitForChild(questId)

    local questData = {
        Progress = tostring(progress) .. " / " .. tostring(questObjective),
        ProgressRatio = progress / questObjective,
        QuestStatus = questStatus
    }

    -- Batch GUI updates for efficiency
    self:BatchUpdateQuestGUI(questHolderClone, questData)
end

-- Function to batch update GUI elements for a quest
function questManager:BatchUpdateQuestGUI(questHolderClone, questData)
    local questObjectiveLabel = questHolderClone.ProgressBarFrame.ProgressBG.ProgressValue
    local questObjectiveBar = questHolderClone.ProgressBarFrame.ProgressBG.ProgressFG
    local questClaimFrame = questHolderClone.ProgressBarFrame.ClaimFrame

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
    local questData = playerQuestIndex[playerId][questId]
    if questData then
        questData.progress = progress
    end
end

-- Function to get a player's quest
function questManager:GetQuestForPlayer(playerId)
	return playerQuests[playerId]
end

-- Function to check if a player's quest is completed
function questManager:IsQuestCompletedForPlayer(playerId, questId)
    local questData = playerQuestIndex[playerId][questId]
    if questData and questData.progress >= questData.questObjective then
        questData.completed = true
        return true
    end
    return false
end

-- Function to get the quest data for a player's quest
function questManager:GetQuestDataForPlayer(playerId, questId)
	local questData = playerQuestIndex[playerId][questId]
	if questData.questId == questId then
		return questData
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
		questManager:UpdateQuestGUI(playerId, questId, questData.progress, questData.questObjective, questChecker)
		if questChecker == true then
			questClaimed.Value, questData.claimed = true, true

			warn("Quest completed!")
		end
		questManager:SavePlayerQuests(playerId)
	end
end

function questManager:DeletePlayerLeaderstats(playerId, questId)
    local player = game.Players:GetPlayerByUserId(playerId)
    local folder = player.Quests:WaitForChild("playerId")
    local questIdFolder = folder:FindFirstChild(questId)
    
    if questIdFolder then
        questIdFolder:Destroy()
        questManager:DeleteQuestGUI(player, questId)
        
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
        
        -- Remove quest from playerQuestIndex
        if playerQuestIndex[playerId] and playerQuestIndex[playerId][questId] then
            playerQuestIndex[playerId][questId] = nil
        end
        
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
function questManager:UpdateKillMobsQuestProgress(playerId, questId, mobKills, questType)
    local questData = playerQuestIndex[playerId][questId]
    if questData and questData.questType == questType and not questData.claimed then
        questData.progress = questData.progress + mobKills
        questManager:UpdatePlayerLeaderStats(playerId, questId)
    end
end

-- Function to update progress for GET_COINS quests
function questManager:UpdateGetCoinsQuestProgress(playerId, questId, coinsCollected)
    local questData = playerQuestIndex[playerId][questId]
    if questData and questData.questType == QUEST_TYPES.GET_COINS then
        questData.progress = questData.progress + coinsCollected
    end
end

-- server events
claimQuest.OnServerEvent:Connect(function(player, questId)
	questManager:DeletePlayerLeaderstats(player.UserId, questId)
end)

return questManager