-- QuestGUI buttons Client Side

local RS = game:GetService("ReplicatedStorage")
local TS = game:GetService("TweenService")

local player = game.Players.LocalPlayer
local char = player.Character or player.CharacterAdded:Wait()
local playerGui = player.PlayerGui

-- retrieve GUI
local QuestSystemScreen = playerGui:WaitForChild("QuestSystem")
local MainScreen = QuestSystemScreen.MainFrame

local blur = game:GetService("Lighting").InventoryBlur

local questBtn = QuestSystemScreen.MainButton
local closeBtn = QuestSystemScreen.MainFrame.CloseButton

-- button actions
questBtn.MouseButton1Click:Connect(function()
    MainScreen.Visible = not MainScreen.Visible
    blur.Enabled = not blur.Enabled
end)

closeBtn.MouseButton1Click:Connect(function()
    MainScreen.Visible = not MainScreen.Visible
    blur.Enabled = not blur.Enabled
end)

-- client side functions to serverside


-- returning lists from serverside to clientside