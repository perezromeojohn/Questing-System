local Player = game:GetService("Players")
local RS = game:GetService("ReplicatedStorage")
local DSV = game:GetService("DataStoreService")
local HTTP = game:GetService("HttpService")
local SSS = game:GetService("ServerScriptService")

local QM = require(script.QuestManager)
local QD = require(script.QuestData)
local PM = require(SSS:WaitForChild("PlayerManager"))
--local QT = require(SSS.QuestSystem:WaitForChild("QuestDistri"):WaitForChild("QuestTutorial"))

Player.PlayerAdded:Connect(function(player)
	player.CharacterAdded:Connect(function(char)
		local playerId = player.UserId
		local Quests = player:FindFirstChild("Quests")

		task.wait(.1)
		if QM then
			local new = QM.new(player, playerId, PM.GetQuestData(player))

			new:Init()

			task.wait(0.2)
			if Quests then
				if Quests:GetAttribute("QuestLevel") == 0 then
					local questTutorial = require(script.QuestTutorial)
					if questTutorial then
						new:OnCharacterAdded(player, playerId, questTutorial)
					end
				end
			end
		end
	end)
end)



