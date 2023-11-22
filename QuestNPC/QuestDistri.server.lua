

local collectionService = game:GetService("CollectionService")
local SSS = game:GetService("ServerScriptService")
local RS = game:GetService("ReplicatedStorage")

local QuestDictionary = require(script.QuestDictionary)
local QM = require(SSS.QuestSystem.QuestInit.QuestManager)

local QuestDialog = RS.QuestSystem.Remotes.QuestDialog

local QuestNpc = {}
QuestNpc.__index = QuestNpc
QuestNpc.TagName = "QuestNpc"

function QuestNpc.new(instance, name)
	local self = setmetatable({}, QuestNpc)

	self.QuestNPC = instance
	self.NPCName = name

	self:SetQuestAttribute()

	self.Prompt = self:CreatePrompt()
	self.ConnTrigger = self.Prompt.Triggered:Connect(function(plr)
		local playerId = plr.UserId

		-- QM:CreateQuestForPlayer(
		-- 	playerId,
		-- 	self.QuestNPC:GetAttributes()
		-- )
        print("HELLO PO")
	end)
	
	return self
end

function QuestNpc:SetQuestAttribute()
	self.QuestNPC:SetAttribute("questName", QuestDictionary[self.NPCName][1]["questName"])
	self.QuestNPC:SetAttribute("questObjective", QuestDictionary[self.NPCName][1]["questObjective"])
	self.QuestNPC:SetAttribute("completed", QuestDictionary[self.NPCName][1]["completed"])
	self.QuestNPC:SetAttribute("questCriteria", QuestDictionary[self.NPCName][1]["questCriteria"])
	self.QuestNPC:SetAttribute("questTarget", QuestDictionary[self.NPCName][1]["questTarget"])
	self.QuestNPC:SetAttribute("questType", QuestDictionary[self.NPCName][1]["questType"])
	self.QuestNPC:SetAttribute("questrepeat", QuestDictionary[self.NPCName][1]["questrepeat"])
	self.QuestNPC:SetAttribute("reward1", QuestDictionary[self.NPCName][1]["reward"]["reward1"])
	self.QuestNPC:SetAttribute("reward2", QuestDictionary[self.NPCName][1]["reward"]["reward2"])
end

function QuestNpc:CreatePrompt()
	local prompt = Instance.new("ProximityPrompt")
	prompt.Parent = self.QuestNPC
	prompt.HoldDuration = 0.5
	prompt.ActionText = "Talk"
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