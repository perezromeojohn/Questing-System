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

local claimButtons = {}

-- button actions
questBtn.MouseButton1Click:Connect(function()
    MainScreen.Visible = not MainScreen.Visible
    blur.Enabled = not blur.Enabled
end)

closeBtn.MouseButton1Click:Connect(function()
    MainScreen.Visible = not MainScreen.Visible
    blur.Enabled = not blur.Enabled
end)

for _, button in ipairs(MainScreen:GetDescendants()) do
    if button:IsA("ImageButton") and button.Name == "ClaimButton" then
        table.insert(claimButtons, button)
        print(button.Name)
    end
end

-- get all the claimButtons and get the questId from the parent. ClaimButton.Parent.Parent.Parent
for _, button in ipairs(claimButtons) do
    button.MouseButton1Click:Connect(function()
        local questId = button.Parent.Parent.Parent.Name
        button.Parent.Parent.Parent:Destroy()
    end)
end

-- client side functions to serverside

-- returning lists from serverside to clientside