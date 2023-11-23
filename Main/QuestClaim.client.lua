-- QuestGUI buttons Client Side

local RS = game:GetService("ReplicatedStorage")
local TS = game:GetService("TweenService")

local player = game.Players.LocalPlayer
local char = player.Character or player.CharacterAdded:Wait()
local playerGui = player.PlayerGui

-- remote event
local claimQuest = RS.QuestSystem.Remotes.ClaimQuest

local button = script.Parent

button.MouseButton1Click:Connect(function()
	print("ilan")
	local questId = button.Parent.Parent.Parent.Name
	claimQuest:FireServer(questId)
	-- remove the button in the table
end)