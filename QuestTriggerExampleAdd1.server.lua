local proxPrompt = script.Parent
local SSS = game:GetService("ServerScriptService")

local QM = require(SSS.QuestSystem.QuestInit.QuestManager)
local QD = require(SSS.QuestSystem.QuestInit.QuestData)

local questData = QD.new()
questData.questObjective = 768 
questData.progress = 0
questData.completed = false

local QUEST_TYPES = {
	KILL_MOBS = "KILL_MOBS",
	GET_COINS = "GET_COINS"
}

proxPrompt.TriggerEnded:Connect(function(player)
	local playerId = player.UserId
    local questFolder = player.Quests.playerId
    

    -- [4641573294] =  ▼  { -- playerid
	--     ["questId"] = "34085E80-E394-41DF-AE46-FD39EB22689D" =  ▼  { 
	--         ["completed"] = false, -- completed = boolean
	--         ["progress"] = 0, -- progress = number
	--         ["questObjective"] = 15, -- questObjective = number
	--         ["questType"] = "KILL_MOBS" -- questType = string -- is there a way to get this questType that has a KILL_MOBS assigned to it to all quests inside the player so that I could add progress to them all?
	--      }
	--   }

    for _, questData in ipairs(questFolder:GetDescendants()) do
        -- get the questType of the questData
        if questData.Name == "questType" then
           QM:UpdateKillMobsQuestProgress(playerId, questData.Parent.Name, questData.Parent.progress.Value + 1)
           print("CHIKI CHIKi")
        end
    end
end)