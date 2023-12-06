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
		local Quests = player:FindFirstChild("Quests")
		local playerQuests = player:WaitForChild("Quests"):GetChildren()
		task.wait(.1)
		if QM then
			local new = QM.new(player, playerId, PM.GetQuestData(player))
			
			--if Quests then
			--	if Quests:GetAttribute("QuestLevel") == 0 then
			--		new:OnCharacterAdded(player, playerId)
			--	end
			--end
			
			new:Init()
		end
		
		
		
	end)
end)


