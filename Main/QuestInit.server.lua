local Player = game:GetService("Players")
local RS = game:GetService("ReplicatedStorage")
local DSV = game:GetService("DataStoreService")
local HTTP = game:GetService("HttpService")

local QM = require(script.QuestManager)
local QD = require(script.QuestData)
local QT = require(script.QuestTypes)

local questData = QD.new()
questData.questObjective = 15 
questData.progress = 16
questData.completed = false

local QUEST_TYPES = QT

-- server
--local dataStore = DSV:GetDataStore("DSVQuests") -- datastore named

-- onplayer added, create a folder inside the player named Quests 
Player.PlayerAdded:Connect(function(player)
	local folder = Instance.new("Folder")
	folder.Name = "Quests"
	folder.Parent = player

	-- instance string value inside the player named playerId
	local playerId = Instance.new("StringValue", folder)
	playerId.Name = "playerId"
	playerId.Value = player.UserId
	
	-- QM:CreateQuestForPlayer(player.UserId, QUEST_TYPES.KILL_MOBS, questData.questObjective)
end)


