local RS = game:GetService("ReplicatedStorage")

local player = game.Players.LocalPlayer
local char = player.Character or player.CharacterAdded:Wait()
local playerHRP = char:WaitForChild("HumanoidRootPart")
local playerGui = player.PlayerGui

-- beams
local guideBeam = RS.QuestSystem.GuidingBeam

-- get the player's quest list by player > Quests > get children,.now find a children that has an attribute questCriteria with a value of MainQuest and
-- and an attribute completed with a value of false


local function checkMainQuest()
    local questList = player.Quests:GetChildren()

    for _, quest in pairs(questList) do
        if quest:GetAttribute("questCriteria") == "MainQuest" then
            if quest:GetAttribute("completed") == false then
                return false
            elseif quest:GetAttribute("completed") == true then
                local npcSource = quest:GetAttribute("questSource")
                return true, npcSource
            end
        else
            return false
        end
    end
end

-- func here grubber
local function enableBeam()
    -- store the return value of checkMainQuest() in a variable
    local isMainQuest, npcSource = checkMainQuest() -- store values
    if isMainQuest == true then
        local npc = workspace.NPC:FindFirstChild(npcSource)
        local beam = guideBeam:Clone()

        local npcHRP = npc:WaitForChild("HumanoidRootPart")

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
        warn("No Main Quest Completed")
    end
end

enableBeam()
