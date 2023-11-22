local RS = game:GetService("ReplicatedStorage")
local player = game.Players.LocalPlayer
local questDialog = player.PlayerGui:WaitForChild("QuestDialog")

-- buttons
local declineButton = questDialog.MainFrame.Frame.DeclineFrame.Button
local acceptButton = questDialog.MainFrame.Frame.AcceptFrame.Button

-- remotes
local QuestDialogRemote = RS.QuestSystem.Remotes.QuestDialog
local QuestCreateRemote = RS.QuestSystem.Remotes.CreateQuest

-- GUI
local npcName = questDialog.MainFrame.NPCName
local npcNameShadow = questDialog.MainFrame.NPCNameShadow
local npcDialogue = questDialog.MainFrame.NPCText
local npcQuestType = questDialog.MainFrame.QuestType

-- quests folder
local quests = player.Quests

local questBundle = {}

QuestDialogRemote.OnClientEvent:Connect(function(playerId, NPCname, attrib)
	if questDialog.Enabled == true then
		warn("Already Enabled")
		return
	end

	acceptButton.Parent.Visible = true
	-- set to nil questBundle
	questBundle = {}
	questBundle = attrib
	questDialog.Enabled = true
	npcName.Text = NPCname
	npcNameShadow.Text = NPCname

	-- Check if the quest source matches the NPC name
	local completedQuest = false
	for _, quest in ipairs(quests:GetChildren()) do
		local questSource = quest:GetAttribute("questSource")
		local claimed = quest:GetAttribute("claimed")
		if questSource == NPCname and not claimed then
			completedQuest = true
			break
		end
	end

	-- check 
	if completedQuest then
		npcDialogue.Text = "Come back when you have completed the quest, Partner!"
		acceptButton.Parent.Visible = false
	else
		npcDialogue.Text = attrib.questDialog
	end

	npcQuestType.Text = attrib.questCriteria

	for i,v in pairs(questBundle) do
		acceptButton:SetAttribute(i, v)
	end
end)

declineButton.MouseButton1Click:Connect(function()
	questDialog.Enabled = false
	for i,v in pairs(acceptButton:GetAttributes()) do
		acceptButton:SetAttribute(i, nil)
	end
	questBundle = {}
end)

acceptButton.MouseButton1Click:Connect(function()
	questDialog.Enabled = false
	QuestCreateRemote:FireServer(player.UserId, questBundle)
	for i,v in pairs(acceptButton:GetAttributes()) do
		acceptButton:SetAttribute(i, nil)
	end
	questBundle = {}
end)