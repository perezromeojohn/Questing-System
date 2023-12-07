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
	self.QuestType = instance:GetAttribute("QuestType")
	self.Area = instance:GetAttribute("Area")

	self:Init()

	return self
end

function QuestNpc:Init()
	self.Prompt = self:CreatePrompt()

	self.PlayerAdded = game:GetService("Players").PlayerAdded:Connect(function(plr)
		local playerQuest = plr:WaitForChild("Quests")

		self:SetQuestAttribute(plr)
		self:CheckIndicator(plr)

		playerQuest:GetAttributeChangedSignal("QuestLevel"):Connect(function()
			self:SetQuestAttribute(plr)
		end)
	end)

	self.ConnTrigger = self.Prompt.TriggerEnded:Connect(function(plr)
		self:SetQuestAttribute(plr)
		task.wait(0.1)
		self:OnTriggered(plr)
	end)

	self:QuestIndicator()
end

function QuestNpc:QuestIndicator()
	-- clone the questIndicatorMesh mesh and parent it to the questNPC model, set its position to the self.instance and make sure the gui mesh always appears in the ground or feet of the instance
	local questIndicatorMeshClone = questIndicatorMesh:Clone()
	local questIndicator = questIndicatorMeshClone.QuestGUI.Shine

	if self.QuestType == "MainQuest" then
		questIndicator.ImageColor3 = Color3.fromRGB(245, 135, 0)
	elseif self.QuestType == "TutorialQuest" then
		questIndicator.ImageColor3 = Color3.fromRGB(255, 0, 98)
	else
		questIndicator.ImageColor3 = Color3.fromRGB(13, 255, 0)
	end

	self.QuestNPC:GetAttributeChangedSignal("QuestAccepted"):Connect(function()
		if self.QuestNPC:GetAttribute("QuestAccepted") == true then
			questIndicatorMeshClone.QuestGUI.Sign.Text = "?"
			questIndicator.ImageColor3 = Color3.fromRGB(137, 239, 255)
		else
			if self.QuestType == "MainQuest" then
				questIndicator.ImageColor3 = Color3.fromRGB(245, 135, 0)
			elseif self.QuestType == "TutorialQuest" then
				questIndicator.ImageColor3 = Color3.fromRGB(255, 0, 98)
			else
				questIndicator.ImageColor3 = Color3.fromRGB(13, 255, 0)
			end

			questIndicatorMeshClone.QuestGUI.Sign.Text = "!"
		end
	end)

	questIndicatorMeshClone.Parent = self.QuestNPC
	questIndicatorMeshClone.Position = self.QuestNPC.HumanoidRootPart.Position
	questIndicatorMeshClone.Position = Vector3.new(questIndicatorMeshClone.Position.X, self.QuestNPC.LeftFoot.Position.Y, questIndicatorMeshClone.Position.Z)
	questIndicatorMeshClone.NameGui.NPCName.Text = self.NPCName
end

function QuestNpc:CheckIndicator(plr)
	local questsFolder = plr:FindFirstChild("Quests")

	for _, questData in ipairs(questsFolder:GetChildren()) do
		if questData:GetAttribute("questSource") == self.NPCName and questData:GetAttribute("claimed") == false then
			self.QuestNPC:SetAttribute("QuestAccepted", true)
		end
	end
end

function QuestNpc:OnTriggered(plr)
	local playerId = plr.UserId
	local getTagged = collectionService:GetTagged("TALK_NPC")

	if table.find(getTagged, self.QuestNPC) then
		event:Fire(plr, playerId)
		task.wait(0.1)
		--QuestDialogRemote:FireClient(plr, playerId, self.NPCName, self.QuestNPC:GetAttributes())
	else
		QuestDialogRemote:FireClient(plr, playerId, self.NPCName, self.QuestNPC:GetAttributes())
	end
end

function QuestNpc:SetQuestAttribute(plr)
	local playerQuest = plr:WaitForChild("Quests"):GetAttribute("QuestLevel")
	local count = {}

	if self.QuestType == "MainQuest" then
		local data = QuestDictionary[self.Area][self.NPCName]

		if not data then return end

		for i,v in pairs(data) do
			table.insert(count, v)
		end

		if playerQuest > #count then
			self:CleanUp()
			return
		end

		local questData = QuestDictionary[self.Area][self.NPCName][playerQuest] --or QuestDictionary[self.Area][self.NPCName][#QuestDictionary[self.NPCName]]

		if questData then
			for key, value in pairs(questData) do
				self.QuestNPC:SetAttribute(key, value)
			end
		end
	elseif self.QuestType == "TutorialQuest" then
		local QuestTutorialDictionary = require(script.Parent.QuestInit.QuestTutorial)
		if QuestDictionary then
			local data = QuestTutorialDictionary

			if not data then return end
		
			for i,v in pairs(data) do
				print(v)
				table.insert(count, v)
			end
			
			if playerQuest > #count then
				self:CleanUp()
				return
			end
			
			local questData = QuestTutorialDictionary[playerQuest]
			
			for key, value in pairs(questData) do
				if data.Name == self.NPCName then
					self.QuestNPC:SetAttribute(key, value)
				end
			end
		end
	else
		local questData = QuestDictionary[self.Area][self.NPCName]
		for key, value in pairs(questData) do
			self.QuestNPC:SetAttribute(key, value)
		end
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

function QuestNpc:CleanUp()
	self.QuestNPC:FindFirstChild("QuestGUI").QuestGUI:Destroy()
	self.QuestNPC:FindFirstChild("ProximityPrompt"):Destroy()
	collectionService:RemoveTag(self.QuestNPC, "QuestNpc")
end

local instances = {}

local AddInstance = collectionService:GetInstanceAddedSignal(QuestNpc.TagName)
--local RemoveInstance = collectionService:GetInstanceRemovedSignal(QuestNpc.TagName)

local function onInstanceAdded(instance)
	instances[instance] = QuestNpc.new(instance, instance:GetAttribute("Name"))
end

--local function onInstanceRemove(instance)
--	if instances[instance] then
--		instances[instance]:Cleanup()
--		instances[instance] = nil
--	end
--end

for _, instance in pairs(collectionService:GetTagged(QuestNpc.TagName)) do
	onInstanceAdded(instance)
end

AddInstance:Connect(onInstanceAdded)
--RemoveInstance:Connect(onInstanceRemove)