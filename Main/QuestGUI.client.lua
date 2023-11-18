-- QuestGUI buttons Client Side

local RS = game:GetService("ReplicatedStorage")
local TS = game:GetService("TweenService")

local player = game.Players.LocalPlayer
local char = player.Character or player.CharacterAdded:Wait()
local playerGui = player.PlayerGui

-- remote event
local claimQuest = RS.QuestSystem.Remotes.ClaimQuest

-- retrieve GUI
local QuestSystemScreen = playerGui:WaitForChild("QuestSystem")
local MainScreen = QuestSystemScreen.MainFrame

local blur = game:GetService("Lighting").InventoryBlur

local questBtn = QuestSystemScreen.MainButton
local closeBtn = QuestSystemScreen.MainFrame.CloseButton

local claimButtons = {}

-- local functions
local function addButtonFunction()
	for _, button in ipairs(claimButtons) do
		button.MouseButton1Click:Connect(function()
			local questId = button.Parent.Parent.Parent.Name
			--button.Parent.Parent.Parent:Destroy()
			claimQuest:FireServer(questId)
            -- remove the button in the table
            for i, btn in ipairs(claimButtons) do
                if btn == button then
                    table.remove(claimButtons, i)
                    break
                end
            end
		end)
	end
end

local function getButton()
	for _, button in ipairs(MainScreen:GetDescendants()) do
		if button:IsA("ImageButton") and button.Name == "ClaimButton" then
			local isButtonAlreadyAdded = false
			for _, btn in ipairs(claimButtons) do
				if btn == button then
					isButtonAlreadyAdded = true
					break
				end
			end
			if not isButtonAlreadyAdded then
				table.insert(claimButtons, button)
			end
		end
	end

	addButtonFunction()
end

-- button actions
questBtn.MouseButton1Click:Connect(function()
	MainScreen.Visible = true
	blur.Enabled = true
	questBtn.Visible = false

	getButton()
	print("Claim buttons: " .. #claimButtons)
end)

closeBtn.MouseButton1Click:Connect(function()
	MainScreen.Visible = false
	blur.Enabled = false
	questBtn.Visible = true
end)

addButtonFunction()

print(claimButtons)
-- client side functions to serverside

-- returning lists from serverside to clientside