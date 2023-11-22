local Player = game:GetService("Players")
local RS = game:GetService("ReplicatedStorage")
local DSV = game:GetService("DataStoreService")
local HTTP = game:GetService("HttpService")

local QM = require(script.QuestManager)
local QD = require(script.QuestData)
local QT = require(script.QuestTypes)
local PM = require(game:GetService("ServerScriptService"):WaitForChild("PlayerManager"))

Player.PlayerAdded:Connect(function(player)
	player.CharacterAdded:Connect(function(char)
		local playerId = player.UserId
		local playerQuests = player:WaitForChild("Quests"):GetChildren()
		--print(PM.GetQuestData(player))
		task.wait(0.2)
		QM:Init(playerId, PM.GetQuestData(player))
	end)
end)


