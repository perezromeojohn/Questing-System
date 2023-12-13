local RS = game:GetService("ReplicatedStorage")

local player = game.Players.LocalPlayer
local char = player.Character or player.CharacterAdded:Wait()
local playerHRP = char:WaitForChild("HumanoidRootPart")
local playerGui = player.PlayerGui

-- remotes
local beamEnable = RS.QuestSystem.Remotes.Beam

-- beams
local guideBeam = RS.QuestSystem.GuidingBeam
local tutorialBeam = RS.QuestSystem.TutorialBeam

-- get the player's quest list by player > Quests > get children,.now find a children that has an attribute questCriteria with a value of MainQuest and
-- and an attribute completed with a value of false

-- func here grubber
beamEnable.OnClientEvent:Connect(function(npcSource, enable, questCriteria)
	if npcSource == nil then
		warn("No NPC Source")
		return
	end

	if questCriteria == "MainQuest" then
		if enable == true then
			local npc = workspace.NPC:FindFirstChild(npcSource)
			local beam = guideBeam:Clone()

			local npcHRP = npc:FindFirstChild("HumanoidRootPart")
			if not npcHRP then
				return
			end

			local att1 = Instance.new("Attachment")
			att1.Name = "Att1"
			att1.Parent = playerHRP

			local att2 = Instance.new("Attachment")
			att2.Name = "Att2"
			att2.Parent = npcHRP

			beam.Parent = playerHRP
			beam.Attachment0 = att1
			beam.Attachment1 = att2

			beam.Enabled = true
		else
			local att1 = playerHRP:FindFirstChild("Att1")
			local att2 = workspace.NPC:FindFirstChild(npcSource).HumanoidRootPart:FindFirstChild("Att2")

			local beam = playerHRP:FindFirstChild("GuidingBeam")

			if att1 == nil or att2 == nil or beam == nil then
				warn("No attachments or beam found")
				return
			end

			att1:Destroy()
			att2:Destroy()
			beam:Destroy()
		end
	end

	if questCriteria == "TutorialQuest" then
		if enable == true then
			local npc = workspace.NPC:FindFirstChild(npcSource)
			local beam = tutorialBeam:Clone()

			local npcHRP = npc:FindFirstChild("HumanoidRootPart")
			if not npcHRP then
				return
			end

			local att1 = Instance.new("Attachment")
			att1.Name = "Att1"
			att1.Parent = playerHRP

			local att2 = Instance.new("Attachment")
			att2.Name = "Att2"
			att2.Parent = npcHRP

			beam.Parent = playerHRP
			beam.Attachment0 = att1
			beam.Attachment1 = att2

			beam.Enabled = true
		else
			local att1 = playerHRP:FindFirstChild("Att1")
			local att2 = workspace.NPC:FindFirstChild(npcSource).HumanoidRootPart:FindFirstChild("Att2")

			local beam = playerHRP:FindFirstChild("TutorialBeam")

			if att1 == nil or att2 == nil or beam == nil then
				warn("No attachments or beam found")
				return
			end

			att1:Destroy()
			att2:Destroy()
			beam:Destroy()
		end
	end
end)

