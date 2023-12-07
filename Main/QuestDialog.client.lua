local RS = game:GetService("ReplicatedStorage")
local player = game.Players.LocalPlayer
local questDialog = player.PlayerGui:WaitForChild("QuestDialog")


-- remotes
local QuestDialogRemote = RS.QuestSystem.Remotes.QuestDialog
local QuestCreateRemote = RS.QuestSystem.Remotes.CreateQuest
local claimQuest = RS.QuestSystem.Remotes.ClaimQuest
local rewardEvent = RS.QuestSystem.Remotes.RewardEvent

-- GUI
local mainFrame = questDialog.MainFrame.Frame
local npcName = questDialog.MainFrame.NPCName
local npcNameShadow = questDialog.MainFrame.NPCNameShadow
local npcDialogue = questDialog.MainFrame.NPCText
local npcQuestType = questDialog.MainFrame.QuestType

-- buttons
local declineButton = mainFrame.DeclineFrame.Button
local acceptButton = mainFrame.Template.AcceptFrame
local claimButton = mainFrame.Template.ClaimFrame
local rewardTemplate = questDialog.MainFrame.RewardFrame.RewardFrame.Template.RewardHolder

local quests = player.Quests

local function cloneAcceptbtn(parent)
	local newbtn = acceptButton:Clone()
	newbtn.Visible = true
	newbtn.Parent = parent

	return newbtn
end

local function cloneClaimbtn(parent)
	local newbtn = claimButton:Clone()
	newbtn.Visible = true
	newbtn.Parent = parent

	return newbtn
end

local function cloneReward(parent)
	local newtemp = rewardTemplate:Clone()
	newtemp.Visible = true
	newtemp.Parent = parent
	
	return newtemp
end

local Questdialog = {}
Questdialog.__index = Questdialog

local attributes = {}

function Questdialog.new(playerId, NPCname, attrib)
	
	local self = setmetatable({}, Questdialog)
	
	self.playerID = playerId
	self.NPCname = NPCname
	
	attributes = {}
	attributes = attrib
	
	return self
end

function Questdialog:Init()
	
	if questDialog.Enabled == true then return end

	local newbtn = self:GetAcceptBtn()
	questDialog.Enabled = true

	npcName.Text = self.NPCname
	npcNameShadow.Text = self.NPCname
	npcDialogue.Text = attributes.questDialog
	
	npcQuestType.Text = attributes.questCriteria
	
	self:GetRewards()

	for i,v in pairs(attributes) do
		newbtn:SetAttribute(i, v)
	end
	
	for _, quest in ipairs(quests:GetChildren()) do
		local questSource = quest:GetAttribute("questSource")
		local claimed = quest:GetAttribute("claimed")
		if questSource == self.NPCname and not claimed then
			if quest:GetAttribute("completed") == true and quest:GetAttribute("questCriteria") == "MainQuest" then
				npcDialogue.Text = "Claim your reward!"
				newbtn:Destroy()
				self:GetClaimBtn(quest:GetAttribute("questId"))
			else
				npcDialogue.Text = "Come back when you have completed the quest"
				questDialog.MainFrame.RewardFrame.Visible = false
				newbtn:Destroy()
			end
		end
	end
	
	declineButton.MouseButton1Click:Connect(function()
		questDialog.Enabled = false
		for i,v in pairs(newbtn:GetAttributes()) do
			newbtn:SetAttribute(i, nil)
		end
		attributes = {}
	end)
end

function Questdialog:GetRewards()
	for _, v in ipairs(questDialog.MainFrame.RewardFrame.RewardFrame:GetChildren()) do
		if v:IsA("ImageLabel") then
			v:Destroy()
		end
	end
	
	questDialog.MainFrame.RewardFrame.Visible = true
	
	if attributes.reward1 > 0 then
		local rewardHolderClone = cloneReward(questDialog.MainFrame.RewardFrame.RewardFrame)
		rewardHolderClone.Image = "rbxassetid://14092500930" -- might change
		rewardHolderClone.Amount.Text = "+"..tostring(attributes.reward1) -- might change
		rewardHolderClone:SetAttribute("type", "Coin")
	end

	if attributes.reward2 > 0 then
		local rewardHolderClone = cloneReward(questDialog.MainFrame.RewardFrame.RewardFrame)
		rewardHolderClone.Amount.Text = "+"..tostring(attributes.reward2) -- might change
		rewardHolderClone:SetAttribute("type", "Soul")
	end

	if attributes.reward3 == true then
		local rewardHolderClone = cloneReward(questDialog.MainFrame.RewardFrame.RewardFrame)
		rewardHolderClone.Image = "rbxassetid://15486414192" -- might change
		rewardHolderClone.Amount.Text = "Guardian" -- might change
		rewardHolderClone:SetAttribute("type", "Guardian")
	end

	if attributes.reward1 == nil and attributes.reward2 == nil and attributes.reward3 == nil then
		warn("This quest has no reward!")
	end
end

function Questdialog:GetAcceptBtn()
	for _, v in ipairs(mainFrame:GetChildren()) do
		if v:IsA("ImageLabel") and v.Name ~= "DeclineFrame" then
			v:Destroy()
		end
	end
	
	local acceptBtn = cloneAcceptbtn(mainFrame)

	acceptBtn.Button.MouseButton1Click:Connect(function()
		questDialog.Enabled = false
		QuestCreateRemote:FireServer(player.UserId, attributes)
		for i,v in pairs(acceptButton:GetAttributes()) do
			acceptButton:SetAttribute(i, nil)
		end
		attributes = {}
	end)
	
	return acceptBtn
end

function Questdialog:GetClaimBtn(questId)
	for _, v in ipairs(mainFrame:GetChildren()) do
		if v:IsA("ImageLabel") and v.Name ~= "DeclineFrame" then
			v:Destroy()
		end
	end

	local claimbtn = cloneClaimbtn(mainFrame)

	claimbtn.Button.MouseButton1Click:Connect(function()
		questDialog.Enabled = false
		
		local guardianfolder = game:GetService("ReplicatedStorage").GuardianFolder
		local checkTable = {}

		for i, v in ipairs(guardianfolder:GetChildren()) do
			if v:IsA("Model") then
				table.insert(checkTable, v.Name)
			end
		end

		local getRandomItem = checkTable[math.random(1, #checkTable)]
		
		claimQuest:FireServer(questId, getRandomItem)
		
		local module = require(RS.QuestSystem.Component.RewardNotification)
		
		if module then
			local component = module.new(attributes, getRandomItem)
			component:Init()
		end
		
		attributes = {}
	end)
end

QuestDialogRemote.OnClientEvent:Connect(function(playerId, NPCname, attrib)
	local newDialog = Questdialog.new(playerId, NPCname, attrib)
	newDialog:Init()
end)