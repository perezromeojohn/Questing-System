local collectionService = game:GetService("CollectionService")
local SSS = game:GetService("ServerScriptService")
local RS = game:GetService("ReplicatedStorage")

local QuestDictionary = require(script.QuestDictionary)
local QM = require(SSS.QuestSystem.QuestInit.QuestManager)
local PM = require(game:GetService("ServerScriptService"):WaitForChild("PlayerManager"))

local questIndicatorMesh = RS.QuestSystem.QuestGUI

local QuestDialogRemote = RS.QuestSystem.Remotes.QuestDialog

local event = game:GetService("ReplicatedStorage"):WaitForChild("Signals"):WaitForChild("TALK_NPCBindableEvent")

local QuestNpc = {}
QuestNpc.__index = QuestNpc
QuestNpc.TagName = "QuestNpc"

function QuestNpc.new(instance, name)
	local self = setmetatable({}, QuestNpc)

	self.QuestNPC = instance
	self.NPCName = name

	-- clone the questIndicatorMesh mesh and parent it to the questNPC model, set its position to the self.instance and make sure the gui mesh always appears in the ground or feet of the instance
	local questIndicatorMeshClone = questIndicatorMesh:Clone()
	questIndicatorMeshClone.Parent = self.QuestNPC
	questIndicatorMeshClone.Position = self.QuestNPC.HumanoidRootPart.Position
	questIndicatorMeshClone.Position = Vector3.new(questIndicatorMeshClone.Position.X, self.QuestNPC.LeftFoot.Position.Y, questIndicatorMeshClone.Position.Z)

	self.Prompt = self:CreatePrompt()
	self.ConnTrigger = self.Prompt.TriggerEnded:Connect(function(plr)
		local playerId = plr.UserId
		local getTagged = collectionService:GetTagged("TALK_NPC")
		local playerQuest = plr:WaitForChild("Quests"):GetAttribute("QuestLevel")
		self:SetQuestAttribute(playerQuest)
		print(playerQuest)

		if table.find(getTagged, self.QuestNPC) then
			event:Fire(plr, playerId)
			task.wait(0.5)
			QuestDialogRemote:FireClient(plr, playerId, self.NPCName, self.QuestNPC:GetAttributes())
		else
			QuestDialogRemote:FireClient(plr, playerId, self.NPCName, self.QuestNPC:GetAttributes())
		end
	end)

	return self
end

function QuestNpc:SetQuestAttribute(playerQuestLevel)
	local questData = QuestDictionary[self.NPCName][playerQuestLevel] or QuestDictionary[self.NPCName][#QuestDictionary[self.NPCName]]
	for key, value in pairs(questData) do
		self.QuestNPC:SetAttribute(key, value)
	end
end

function QuestNpc:CreatePrompt()
	local prompt = Instance.new("ProximityPrompt")
	prompt.Parent = self.QuestNPC
	prompt.HoldDuration = 0.2
	prompt.ActionText = "Talk to ".. self.NPCName
	prompt.UIOffset = Vector2.new(0, 0)

	return prompt
end

local instances = {}

local AddInstance = collectionService:GetInstanceAddedSignal(QuestNpc.TagName)
local RemoveInstance = collectionService:GetInstanceRemovedSignal(QuestNpc.TagName)

local function onInstanceAdded(instance)
	instances[instance] = QuestNpc.new(instance, instance:GetAttribute("Name"))
end

local function onInstanceRemove(instance)
	if instances[instance] then
		instances[instance]:Cleanup()
		instances[instance] = nil
	end
end

for _, instance in pairs(collectionService:GetTagged(QuestNpc.TagName)) do
	onInstanceAdded(instance)
end

AddInstance:Connect(onInstanceAdded)
RemoveInstance:Connect(onInstanceRemove)