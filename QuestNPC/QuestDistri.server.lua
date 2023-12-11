local Player = game:GetService("Players")
local collectionService = game:GetService("CollectionService")
local SSS = game:GetService("ServerScriptService")
local RS = game:GetService("ReplicatedStorage")

local questIndicatorMesh = RS.QuestSystem.QuestGUI
local QuestDialogRemote = RS.QuestSystem.Remotes.QuestDialog

local event = RS:WaitForChild("Signals"):WaitForChild("TALK_NPCBindableEvent")

local QuestNpc = {}
QuestNpc.__index = QuestNpc
QuestNpc.TagName = "QuestNpc"

function QuestNpc.new(instance, attributes)
	local self = setmetatable({}, QuestNpc)

	self.QuestNPC = instance
	self.attributes = {}
	self.attributes = attributes
	
	self.NPCName = self.attributes.Name

	self:Init()

	return self
end

function QuestNpc:Init()
	self.Prompt = self:CreatePrompt()
	self.Indicator = self:CloneIndicator()
	
	self.playerAdded = Player.PlayerAdded:Connect(function(plr)
		local QuestFolder = plr:WaitForChild("Quests")
		
		self:CheckAttribute(plr)
		self:CheckIndicator(plr)
		
		QuestFolder:GetAttributeChangedSignal("QuestLevel"):Connect(function()
			self:CheckAttribute(plr)
			self:CheckIndicator(plr)
		end)
	end)
	
	self.ConnTrigger = self.Prompt.TriggerEnded:Connect(function(plr)
		self:OnTriggered(plr)
	end)
	
	self:SetIndicator()
end

function QuestNpc:CheckAttribute(plr)
	local playerQuest = plr:WaitForChild("Quests"):GetAttribute("QuestLevel")
	local QuestDictionary = require(script.QuestDictionary)
	
	local data = QuestDictionary[self.attributes.Area]
	
	for index, value in pairs(data) do
		if self.attributes.Name == index then
			self:SetAttribute(plr, QuestDictionary, playerQuest)
		end
	end
end

function QuestNpc:SetAttribute(plr, QuestDictionary, playerQuest)
	
	if self.attributes.QuestType == "MainQuest" then
		local questData = QuestDictionary[self.attributes.Area][self.NPCName]
		
		if next(QuestDictionary[self.attributes.Area][self.NPCName]) == nil then
			self:CleanUp()
			return
		end
		
		for i, v in pairs(questData) do
			if i == playerQuest then
				local questAttributes = QuestDictionary[self.attributes.Area][self.NPCName][i]
				
				if questAttributes then
					for aName, aValue in pairs(questAttributes) do
						self.QuestNPC:SetAttribute(aName, aValue)
					end
				end
				QuestDictionary[self.attributes.Area][self.NPCName][i] = nil
			end
		end
	else
		local questData = QuestDictionary[self.attributes.Area][self.NPCName]
		for aName, aValue in pairs(questData) do
			self.QuestNPC:SetAttribute(aName, aValue)
		end
		
	end
end

function QuestNpc:CheckIndicator(plr)
	local questsFolder = plr:FindFirstChild("Quests")

	for _, questData in ipairs(questsFolder:GetChildren()) do
		if questData:GetAttribute("questSource") == self.NPCName and questData:GetAttribute("claimed") == false then
			self.QuestNPC:SetAttribute("QuestAccepted", true)
		end
	end
end

function QuestNpc:SetIndicator()
	
	local questIndicator = self.Indicator.QuestGUI.Shine
	
	if self.attributes.QuestType == "MainQuest" then
		questIndicator.ImageColor3 = Color3.fromRGB(245, 135, 0)
	elseif self.attributes.QuestType == "TutorialQuest" then
		questIndicator.ImageColor3 = Color3.fromRGB(255, 0, 98)
	else
		questIndicator.ImageColor3 = Color3.fromRGB(13, 255, 0)
	end

	self.changed = self.QuestNPC:GetAttributeChangedSignal("QuestAccepted"):Connect(function()
		if self.QuestNPC:GetAttribute("QuestAccepted") == true then
			self.Indicator.QuestGUI.Sign.Text = "?"
			
			questIndicator.ImageColor3 = Color3.fromRGB(137, 239, 255)
		else
			self.Indicator.QuestGUI.Sign.Text = "!"
			
			if self.QuestType == "MainQuest" then
				questIndicator.ImageColor3 = Color3.fromRGB(245, 135, 0)
			elseif self.QuestType == "TutorialQuest" then
				questIndicator.ImageColor3 = Color3.fromRGB(255, 0, 98)
			else
				questIndicator.ImageColor3 = Color3.fromRGB(13, 255, 0)
			end
			
		end
	end)
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

function QuestNpc:CreatePrompt()
	local prompt = Instance.new("ProximityPrompt")
	prompt.Parent = self.QuestNPC
	prompt.HoldDuration = 0.2
	prompt.ActionText = "Talk to ".. self.attributes.Name
	prompt.UIOffset = Vector2.new(0, 0)

	return prompt
end

function QuestNpc:CloneIndicator()
	local clone = questIndicatorMesh:Clone()
	clone.Parent = self.QuestNPC
	clone.Position = self.QuestNPC.HumanoidRootPart.Position
	clone.Position = Vector3.new(clone.Position.X, self.QuestNPC.LeftFoot.Position.Y, clone.Position.Z)
	clone.NameGui.NPCName.Text = self.NPCName
	
	return clone
end

function QuestNpc:CleanUp()
	
	local questGui = self.QuestNPC:FindFirstChild("QuestGUI").QuestGUI
	
	if questGui then
		questGui:Destroy()
	end
	
	self.QuestNPC:FindFirstChild("ProximityPrompt"):Destroy()
	collectionService:RemoveTag(self.QuestNPC, "QuestNpc")
end


local instances = {}

local AddInstance = collectionService:GetInstanceAddedSignal(QuestNpc.TagName)
--local RemoveInstance = collectionService:GetInstanceRemovedSignal(QuestNpc.TagName)

local function onInstanceAdded(instance)
	instances[instance] = QuestNpc.new(instance, instance:GetAttributes())
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