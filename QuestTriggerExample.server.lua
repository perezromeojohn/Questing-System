local proxPrompt = script.Parent
local SSS = game:GetService("ServerScriptService")

local QM = require(SSS.QuestSystem.QuestManager)
local QD = require(SSS.QuestSystem.QuestData)

proxPrompt.TriggerEnded:Connect(function(player)
    local playerId = player.UserId
    local questData = QM:GetQuestForPlayer(playerId)
end)