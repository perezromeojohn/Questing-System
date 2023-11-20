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
	GET_COINS = "GET_COINS",
	KILL_BIRGG = "KILL_BIRGG"
}

proxPrompt.TriggerEnded:Connect(function(player)
	local playerId = player.UserId
	local questFolder = player.Quests


	for _, questData in ipairs(questFolder:GetDescendants()) do
        QM:UpdateKillMobsQuestProgress(playerId, questData:GetAttribute("questId"), 1, QUEST_TYPES.KILL_BIRGG)
    end
end)