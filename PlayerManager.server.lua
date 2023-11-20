local Players = game:GetService("Players")
local DataStoreService = game:GetService("DataStoreService")
local httpService = game:GetService("HttpService")
--local PlayerData = DataStoreService:GetDataStore("ProjectIsekai-StagingTest-B-007")
local PlayerData = DataStoreService:GetDataStore("Romeo-015")

local SSS = game:GetService("ServerScriptService")

local autoSavesTimerinSec = 600

local function ResourcesSetup(player, moneyVal, soulVal, robxVal)
	local resources = Instance.new("Folder", player)
	resources.Name = "Resources"

	local money = Instance.new("NumberValue", resources)
	money.Name = "Money"
	money.Value = moneyVal

	local Soul = Instance.new("NumberValue", resources)
	Soul.Name = "Souls"
	Soul.Value = soulVal

	local robx = Instance.new("NumberValue", resources)
	robx.Name = "RobX"
	robx.Value = robxVal

	return resources
end

local function PlayerProgressSetUp(player, progress)
	local playerProgress = Instance.new("Folder", player)
	playerProgress.Name = "PlayerProgress"

	for i,v in pairs(progress) do
		local instance = Instance.new("BoolValue", playerProgress)
		instance.Name = v.name
		instance.Value = v.bool
	end

	return playerProgress
end

local function LoadData(player)
	local success, result = pcall(function()
		local stringTable = PlayerData:GetAsync(player.UserId)

		if stringTable then
			local loadedStats = httpService:JSONDecode(stringTable)
			warn("Player Data Loaded ....")
			return loadedStats
		end
	end)

	if not success then
		warn(result)
	end
	return success, result
end

local function SaveData(player, data)
	local savedTableString = httpService:JSONEncode(data)

	local success, result = pcall(function()
		return PlayerData:SetAsync(player.UserId, savedTableString)
	end)

	if not success then
		warn(result)
	elseif success then
		warn("Game Saved...")
	end

	return success
end

local sessionData = {}
--------------------------------------------------------------------- Guardian
local function GuardianInventory(player, unlockedSlot, slot1, slot2, slot3, slot4, slot5)
	local Guardian = Instance.new("Folder", player)
	Guardian.Name = "Guardian"
	Guardian:SetAttribute("GuardianUnlockedSlot", unlockedSlot)

	local GuardianInventory = Instance.new("Folder",Guardian)
	GuardianInventory.Name = "GuardianInventory"

	local GuardianSlot1 = Instance.new("StringValue",Guardian)
	GuardianSlot1.Name = "GuardianSlot1"
	GuardianSlot1.Value = slot1

	local GuardianSlot2 = Instance.new("StringValue",Guardian)
	GuardianSlot2.Name = "GuardianSlot2"
	GuardianSlot2.Value = slot2

	local GuardianSlot3 = Instance.new("StringValue",Guardian)
	GuardianSlot3.Name = "GuardianSlot3"
	GuardianSlot3.Value = slot3

	local GuardianSlot4 = Instance.new("StringValue", Guardian)
	GuardianSlot4.Name = "GuardianSlot4"
	GuardianSlot4.Value = slot4

	local GuardianSlot5 = Instance.new("StringValue", Guardian)
	GuardianSlot5.Name = "GuardianSlot5"
	GuardianSlot5.Value = slot5

	return Guardian
end
--------------------------------------------------------------------- Equipments

local function EquipmentsInventory(player, weaponSlot, armorSlot)
	local Equipment = Instance.new("Folder", player)
	Equipment.Name = "Equipments"

	local EquipmentInventory = Instance.new("Folder", Equipment)
	EquipmentInventory.Name = "WeaponInventory"

	local EquipmentInventory = Instance.new("Folder", Equipment)
	EquipmentInventory.Name = "ArmorInventory"

	local WeaponSlot = Instance.new("StringValue", Equipment)
	WeaponSlot.Name = "WeaponEquipped"
	WeaponSlot.Value = weaponSlot

	local ArmorSlot = Instance.new("StringValue", Equipment)
	ArmorSlot.Name = "ArmorEquipped"
	ArmorSlot.Value = armorSlot

	return Equipment
end

local function CosmeticsInventory(player, head, back, body, hand, feet, cosmeticInv)
	local cosmetics = Instance.new("Folder", player)
	cosmetics.Name = "Cosmetics"

	local CosmeticInventory = Instance.new("Folder", cosmetics)
	CosmeticInventory.Name = "CosmeticInventory"

	local HeadSlot = Instance.new("StringValue", cosmetics)
	HeadSlot.Name = "HeadSlot"
	HeadSlot.Value = head

	local BackSlot = Instance.new("StringValue", cosmetics)
	BackSlot.Name = "BackSlot"
	BackSlot.Value = back

	local BodySlot = Instance.new("StringValue", cosmetics)
	BodySlot.Name = "BodySlot"
	BodySlot.Value = body

	local HandSlot = Instance.new("StringValue", cosmetics)
	HandSlot.Name = "HandSlot"
	HandSlot.Value = hand

	local FeetSlot = Instance.new("StringValue", cosmetics)
	FeetSlot.Name = "FeetSlot"
	FeetSlot.Value = feet

	for i,v in pairs(cosmeticInv) do
		local item = Instance.new("StringValue", CosmeticInventory)
		item.Name = v.name
		for placeholder, val in pairs(v) do
			item:SetAttribute(placeholder,val)
		end
	end

	return cosmetics
end

local function QuestData(player, val)
	local QM = require(SSS.QuestSystem.QuestInit.QuestManager)
	local Quests = Instance.new("Folder", player)
	Quests.Name = "Quests"

	-- if player has no quest data, return
	if not val then
		return
	end

	for i, v in pairs(val) do
		local stringval = Instance.new("StringValue", Quests)
		stringval.Name = v.questId
		QM:CreateGUI(player.UserId, v)
		-- playerId, questId, progress, questObjective, questStatus
		QM:UpdateQuestGUI(player.UserId, v.questId, v.progress, v.questObjective, v.completed)

		for aName, aVal in pairs(v) do
			stringval:SetAttribute(aName, aVal)
		end
	end

	QM:Init(player.UserId, val)
end

local playerAdded = Instance.new("BindableEvent")
local playerRemoving = Instance.new("BindableEvent")

local PlayerManager = {}

PlayerManager.PlayerAdded = playerAdded.Event
PlayerManager.PlayerRemoving = playerRemoving.Event

function PlayerManager.Start()
	for _, player in ipairs(Players:GetPlayers()) do
		coroutine.wrap(PlayerManager.OnPlayerAdded)(player)
	end
	Players.PlayerAdded:Connect(PlayerManager.OnPlayerAdded)
	Players.PlayerRemoving:Connect(PlayerManager.OnPlayerRemoving)

	game:BindToClose(PlayerManager.OnClose)
end

function PlayerManager.OnPlayerAdded(player)
	player.CharacterAdded:Connect(function(character)
		character.Humanoid.WalkSpeed = 30
		PlayerManager.OnCharacterAdded(player, character)
	end)

	local success,data = LoadData(player)
	sessionData[player.UserId] = success and data or {

		Money = 0,
		Souls = 0,
		RobX = 0,

		UnlockIds = {},

		GuardianSlot1 = "",
		GuardianSlot2 = "",
		GuardianSlot3 = "",
		GuardianSlot4 = "",
		GuardianSlot5 = "",

		GuardianInv = {},

		GuardianUnlockedSlot = 2,

		WeaponSlot = "",

		WeaponInv = {},
		ArmorInv = {},


		HeadSlot = "",
		BackSlot = "",
		BodySlot = "",
		HandSlot = "",
		FeetSlot = "",
		CosmeticsInv = {},

		PlayerProgress = {},

		PlayerStats = {},

		PlayerQuestData = {},

		TycoonChest = {},
	}

	ResourcesSetup(
		player,
		PlayerManager.GetMoney(player),
		PlayerManager.GetSoul(player),
		PlayerManager.GetRobX(player)
	)

	GuardianInventory(
		player,
		PlayerManager.GetGuardianUnlockedSlot(player),
		PlayerManager.GetGuardianSlot(player,1),
		PlayerManager.GetGuardianSlot(player,2),
		PlayerManager.GetGuardianSlot(player,3),
		PlayerManager.GetGuardianSlot(player,4),
		PlayerManager.GetGuardianSlot(player,5)
	)

	EquipmentsInventory(
		player,
		PlayerManager.GetWeaponSlot(player),
		PlayerManager.GetCosticSlot(player,"Body")
	)

	CosmeticsInventory(
		player,		
		PlayerManager.GetCosticSlot(player,"Head"),
		PlayerManager.GetCosticSlot(player,"Back"),
		PlayerManager.GetCosticSlot(player,"Body"),
		PlayerManager.GetCosticSlot(player,"Hand"),
		PlayerManager.GetCosticSlot(player,"Feet"),
		PlayerManager.GetCosmeticInv(player)
	)

	PlayerProgressSetUp(
		player,
		PlayerManager.GetPlayerProgress(player)
	)

	QuestData(
		player,
		PlayerManager.GetQuestData(player)
	)

	playerAdded:Fire(player)


	coroutine.wrap(function()
		while true do
			task.wait(autoSavesTimerinSec)
			SaveData(player, sessionData[player.UserId])
		end
	end)()
end

function PlayerManager.OnCharacterAdded(player, character)
	local humanoid = character:FindFirstChild("Humanoid")

	if humanoid then
		humanoid.Died:Connect(function()
			wait(2)
			player:LoadCharacter()
		end)
	end
end

---------------------------------------------------------------------------- Resources

function PlayerManager.GetMoney(player)
	return sessionData[player.UserId].Money
end

function PlayerManager.SetMoney(player, value)
	if value then
		sessionData[player.UserId].Money = value
		local leaderstats = player:FindFirstChild("Resources")
		if leaderstats then
			local money = leaderstats:FindFirstChild("Money")
			if money then
				money.Value = value
			end
		end
	end
end

function PlayerManager.GetSoul(player)
	return sessionData[player.UserId].Souls
end

function PlayerManager.SetSoul(player, value)
	if value then
		sessionData[player.UserId].Souls = value
		local resources = player:FindFirstChild("Resources")
		if resources then
			local souls = resources:FindFirstChild("Souls")
			if souls then
				souls.Value = value
			end
		end
	end
end

function PlayerManager.GetRobX(player)
	return sessionData[player.UserId].RobX
end

function PlayerManager.SetRobX(player, value)
	if value then
		sessionData[player.UserId].RobX = value
		local resources = player:FindFirstChild("Resources")
		if resources then
			local robx = resources:FindFirstChild("RobX")
			if robx then
				robx.Value = value
			end
		end
	end
end

---------------------------------------------------------------------------- Tycoon

function PlayerManager.AddUnlockId(player, id)
	local data = sessionData[player.UserId]

	if not table.find(data.UnlockIds, id) then
		table.insert(data.UnlockIds, id)
	end
end

function PlayerManager.GetUnlockIds(player)
	return sessionData[player.UserId].UnlockIds
end

---------------------------------------------------------------------------- TycoonChest

function PlayerManager.AddTycoonChest(player, id)
	local data = sessionData[player.UserId].TycoonChest

	if not data[id] then
		data[id] = {
			value = 0
		}
	end
end

function PlayerManager.GetTycoonChest(player)
	return sessionData[player.UserId].TycoonChest
end

function PlayerManager.SetTycoonChest(player, id, val)
	local data = sessionData[player.UserId].TycoonChest

	if data[id] and val then
		data[id] = {
			value = val
		}
	end
end

---------------------------------------------------------------------------- PlayerSave

function PlayerManager.SavePlayerData(player)
	SaveData(player, sessionData[player.UserId])
end

---------------------------------------------------------------------------- Guardian

function PlayerManager.GetGuardianSlot(player, slot)
	if slot == 1 then
		return sessionData[player.userId].GuardianSlot1
	elseif slot == 2 then
		return sessionData[player.userId].GuardianSlot2
	elseif slot == 3 then
		return sessionData[player.userId].GuardianSlot3
	elseif slot == 4 then
		return sessionData[player.userId].GuardianSlot4
	elseif slot == 5 then
		return sessionData[player.userId].GuardianSlot5
	end
end

function PlayerManager.SetGuardianSlot(player, slot, value)
	if slot == 1 then
		sessionData[player.userId].GuardianSlot1 = value
		local Guardian = player:FindFirstChild("Guardian")
		if Guardian then
			local slot = Guardian:FindFirstChild("GuardianSlot1")
			if slot then
				slot.Value = value
			end
		end
	elseif slot == 2 then
		sessionData[player.userId].GuardianSlot2 = value
		local Guardian = player:FindFirstChild("Guardian")
		if Guardian then
			local slot = Guardian:FindFirstChild("GuardianSlot2")
			if slot then
				slot.Value = value
			end
		end
	elseif slot == 3 then
		sessionData[player.userId].GuardianSlot3 = value
		local Guardian = player:FindFirstChild("Guardian")
		if Guardian then
			local slot = Guardian:FindFirstChild("GuardianSlot3")
			if slot then
				slot.Value = value
			end
		end
	elseif slot == 4 then
		sessionData[player.userId].GuardianSlot4 = value
		local Guardian = player:FindFirstChild("Guardian")
		if Guardian then
			local slot = Guardian:FindFirstChild("GuardianSlot4")
			if slot then
				slot.Value = value
			end
		end
	elseif slot == 5 then
		sessionData[player.userId].GuardianSlot5 = value
		local Guardian = player:FindFirstChild("Guardian")
		if Guardian then
			local slot = Guardian:FindFirstChild("GuardianSlot5")
			if slot then
				slot.Value = value
			end
		end
	end
end

function PlayerManager.GetGuardianSlot1(player)
	return sessionData[player.userId].GuardianSlot1
end

function PlayerManager.SetGuardianSlot1(player, value)
	if value then
		sessionData[player.userId].GuardianSlot1 = value
		local Guardian = player:WaitForChild("Guardian")
		if Guardian then
			local slot1 = Guardian:FindFirstChild("GuardianSlot1")
			if slot1 then
				slot1.Value = value
			end
		end
	end
end

function PlayerManager.GetGuardianSlot2(player)
	return sessionData[player.userId].GuardianSlot2
end

function PlayerManager.SetGuardianSlot2(player, value)
	if value then
		sessionData[player.userId].GuardianSlot2 = value
		local Guardian = player:WaitForChild("Guardian")
		if Guardian then
			local slot2 = Guardian:FindFirstChild("GuardianSlot2")
			if slot2 then
				slot2.Value = value
			end
		end
	end
end

function PlayerManager.GetGuardianSlot3(player)
	return sessionData[player.userId].GuardianSlot3
end

function PlayerManager.SetGuardianSlot3(player, value)
	if value then
		sessionData[player.userId].GuardianSlot3 = value
		local Guardian = player:WaitForChild("Guardian")
		if Guardian then
			local slot3 = Guardian:FindFirstChild("GuardianSlot3")
			if slot3 then
				slot3.Value = value
			end
		end
	end
end

function PlayerManager.GetGuardianSlot4(player)
	return sessionData[player.userId].GuardianSlot4
end

function PlayerManager.SetGuardianSlot4(player, value)
	if value then
		sessionData[player.userId].GuardianSlot4 = value
		local Guardian = player:WaitForChild("Guardian")
		if Guardian then
			local slot4 = Guardian:FindFirstChild("GuardianSlot4")
			if slot4 then
				slot4.Value = value
			end
		end
	end
end

function PlayerManager.GetGuardianSlot5(player)
	return sessionData[player.userId].GuardianSlot5
end

function PlayerManager.SetGuardianSlot5(player, value)
	if value then
		sessionData[player.userId].GuardianSlot5 = value
		local Guardian = player:WaitForChild("Guardian")
		if Guardian then
			local slot5 = Guardian:FindFirstChild("GuardianSlot5")
			if slot5 then
				slot5.Value = value
			end
		end
	end
end

function PlayerManager.AddGuardianInv(player, randomId, guardianName, rarity)
	local guardian = game:GetService("ReplicatedStorage"):WaitForChild("GuardianFolder"):FindFirstChild(guardianName)

	if guardian then
		local dataInv = sessionData[player.userId].GuardianInv
		dataInv[randomId] = {
			id = randomId,
			name = guardian:GetAttribute("Name"),
			damage = guardian:GetAttribute("Damage"),
			rarity = rarity,
			multi = guardian:GetAttribute("Multi"),
			attack = guardian:GetAttribute("Attack"),
			health = guardian:GetAttribute("Health")

		}
	end
end

function PlayerManager.GetGuardianInv(player)
	return sessionData[player.UserId].GuardianInv
end

function PlayerManager.SetGuardianUnlockedSlot(player, value)
	if value then
		sessionData[player.userId].GuardianUnlockedSlot = value
		local Guardian = player:FindFirstChild("Guardian")
		if Guardian then
			Guardian:SetAttribute("GuardianUnlockedSlot", value)
		end
	end
end

function PlayerManager.GetGuardianUnlockedSlot(player)
	return sessionData[player.UserId].GuardianUnlockedSlot
end

---------------------------------------------------------------------------- Equipment

function PlayerManager.GetWeaponSlot(player)
	return sessionData[player.UserId].WeaponSlot
end

function PlayerManager.SetWeaponSlot(player, value)
	if value then
		sessionData[player.userId].WeaponSlot = value
		local Equipment = player:FindFirstChild("Equipments")
		if Equipment then
			local weapSlot = Equipment:FindFirstChild("WeaponEquipped")
			if weapSlot then
				weapSlot.Value = value
			end
		end
	end
end

--function PlayerManager.GetArmorSlot(player)
--	return sessionData[player.UserId].ArmorSlot
--end

function PlayerManager.SetArmorSlot(player, value)
	if value then
		sessionData[player.userId].ArmorSlot = value
		local Equipment = player:FindFirstChild("Equipments")
		if Equipment then
			local armSlot = Equipment:FindFirstChild("ArmorEquipped")
			if armSlot then
				armSlot.Value = value
			end
		end
	end
end

function PlayerManager.GetWeaponInv(player)
	return sessionData[player.UserId].WeaponInv
end

function PlayerManager.AddWeaponInv(player, randomId, weaponName, rarity)
	local equipment = game:GetService("ReplicatedStorage"):WaitForChild("EquipmentStorage"):WaitForChild("Weapon"):FindFirstChild(weaponName)

	if equipment then
		local dataInv = sessionData[player.userId].WeaponInv
		dataInv[randomId] = {
			name = equipment.Name,
			id = randomId,
			rarity = rarity,
			cooldown = equipment:GetAttribute("Cooldown"),
			damage = equipment:GetAttribute("Damage"),
			description = equipment:GetAttribute("Description"),
			iconid = equipment:GetAttribute("IconId"),
			multi = equipment:GetAttribute("Multi"),
			class = equipment:GetAttribute("Class"),
			skill1 = equipment:GetAttribute("Skill1"),
			skill2 = equipment:GetAttribute("Skill2"),
			skill3 = equipment:GetAttribute("Skill3"),
			skill4 = equipment:GetAttribute("Skill4"),
		}
	end
end

function PlayerManager.GetArmorInv(player)
	return sessionData[player.UserId].ArmorInv
end

function PlayerManager.AddArmorInv(player, randomId, weaponName, rarity)
	local equipment = game:GetService("ReplicatedStorage"):WaitForChild("EquipmentStorage"):WaitForChild("Armor"):FindFirstChild(weaponName)

	if equipment then
		local dataInv = sessionData[player.userId].ArmorInv
		dataInv[randomId] = { 
			name = equipment.Name,
			id = randomId,
			rarity = rarity,
			cooldown = equipment:GetAttribute("Cooldown"),
			baseHealth = equipment:GetAttribute("BaseHealth"),
			description = equipment:GetAttribute("Description"),
			iconid = equipment:GetAttribute("IconId"),
			multi = equipment:GetAttribute("Multi"),
			skill1 = equipment:GetAttribute("Skill1"),
			skill2 = equipment:GetAttribute("Skill2"),
			skill3 = equipment:GetAttribute("Skill3"),
			skill4 = equipment:GetAttribute("Skill4"),
		}
	end
end

---------------------------------------------------------------------------- Cosmetics

function PlayerManager.GetCosticSlot(player, slot)
	if slot == "Head" then
		return sessionData[player.UserId].HeadSlot
	elseif slot == "Back" then
		return sessionData[player.UserId].BackSlot
	elseif slot == "Body" then
		return sessionData[player.UserId].BodySlot
	elseif slot == "Hand" then
		return sessionData[player.UserId].HandSlot
	elseif slot == "Feet" then
		return sessionData[player.UserId].FeetSlot

	end
end

function PlayerManager.SetCosmeticSlot(player, targetSlot, val)
	local function setStringValue(str)
		local cosmetics = player:FindFirstChild("Cosmetics")
		if cosmetics then
			local slot = cosmetics:FindFirstChild(str)
			if slot then
				slot.Value = val
			end
		end
	end

	local cosmeticFunctionTable = {
		["Head"] = function()
			sessionData[player.UserId].HeadSlot = val
			setStringValue("HeadSlot")
		end,

		["Back"] = function()
			sessionData[player.UserId].BackSlot = val
			setStringValue("BackSlot")
		end,

		["Body"] = function()
			sessionData[player.UserId].BodySlot = val
			setStringValue("BodySlot")
		end,

		["Hand"] = function()
			sessionData[player.UserId].HandSlot = val
			setStringValue("HandSlot")
		end,

		["Feet"] = function()
			sessionData[player.UserId].FeetSlot = val
			setStringValue("FeetSlot")
		end,
	}

	if cosmeticFunctionTable[targetSlot] then
		cosmeticFunctionTable[targetSlot]()
	else
		warn("Parameter Unacceptable")
	end

end

function PlayerManager.GetCosmeticInv(player)
	return sessionData[player.UserId].CosmeticsInv
end

function PlayerManager.AddCosmeticInv(player, genId, cosmeticName)
	local inStorage = false
	local cosmeticInstance

	for i,v in ipairs(game:GetService("ReplicatedStorage"):WaitForChild("CosmeticStorage"):GetDescendants()) do
		if v.Name == cosmeticName then
			inStorage = true
			cosmeticInstance = v
		end
	end

	if inStorage then
		local dataInv = sessionData[player.UserId].CosmeticsInv
		dataInv[genId] = {
			id = genId,
			name = cosmeticName,
			description = cosmeticInstance:GetAttribute("description"),
			cosmeticType = cosmeticInstance:GetAttribute("type"),
			displayName = cosmeticInstance:GetAttribute("displayName"),
		}

		local cosmetics = player:FindFirstChild("Cosmetics")
		if cosmetics then
			local inv = cosmetics:FindFirstChild("CosmeticInventory")
			if inv then				
				local item = Instance.new("StringValue", inv)
				item.Name = cosmeticName

				item:SetAttribute("id", genId)
				item:SetAttribute("name", cosmeticName)
				item:SetAttribute("description", cosmeticInstance:GetAttribute("description"))
				item:SetAttribute("cosmeticType", cosmeticInstance:GetAttribute("type"))
				item:SetAttribute("displayName", cosmeticInstance:GetAttribute("displayName"))

			end
		end
	end

end

---------------------------------------------------------------------------- Player Progress

function PlayerManager.GetPlayerProgress(player)
	return sessionData[player.UserId].PlayerProgress
end

function PlayerManager.AddPlayerProgress(player, progress, val)
	local playerProgress = sessionData[player.UserId].PlayerProgress
	playerProgress[progress] = {
		name = progress,
		bool = val,
	}

	local playerProgress = player:FindFirstChild("PlayerProgress")
	if playerProgress then
		local progression = playerProgress:FindFirstChild(progress)

		if not progression then
			local inst = Instance.new("BoolValue",playerProgress)
			inst.Name = progress
			inst.Value = val
		else
			progression.Value = val
		end
	end
end

---------------------------------------------------------------------------- Quest Data Progress

function PlayerManager.GetQuestData(player)
	return sessionData[player.UserId].PlayerQuestData
end

function PlayerManager.SetQuestData(player, val)
	local playerQuestData  = sessionData[player.UserId].PlayerQuestData
	playerQuestData[val.questId] = {
		questId = val.questId,
		questName = val.questName,
		questCriteria = val.questCriteria,
		questType = val.questType,
		questObjective = val.questObjective,
		questTarget = val.questTarget,
		progress = val.progress,
		completed = val.completed,
		claimed = val.claimed,
	}

	local questData = player:FindFirstChild("Quests")
	if questData then
		local questsInstance = questData:FindFirstChild(val.questId)
		if questsInstance then
			warn("Already In Quest")
		else
			local stringVal = Instance.new("StringValue", questData)
			stringVal.Name = val.questId

			for aName, aVal in pairs(val) do
				stringVal:SetAttribute(aName,aVal)
			end
		end
	end
end

function PlayerManager.OnPlayerRemoving(player)
	SaveData(player, sessionData[player.UserId])
	playerRemoving:Fire(player)
end

function PlayerManager.OnClose()
	for _, player in ipairs(Players:GetChildren()) do
		PlayerManager.OnPlayerRemoving(player)
	end
end

return PlayerManager