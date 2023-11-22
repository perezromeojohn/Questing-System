local Quest = {
	["NPC1"] = {
		[1] = {
			questObjective = 5,
			completed = false,
			questName = "Kill 5 Erggies",
			questCriteria = "MainQuest",
			questTarget = "Erggies",
			questrepeat = false,
			questType = "KILL_MOBS",
			questDialog = "sample dialoge",
			questLevel = 1,
			reward1 = 100,
			reward2 = 0,
			reward3 = 0,
		},
	},

	["NPC2"] = {
		[1] = {
			questObjective = 5,
			completed = false,
			questName = "Kill 5 Birgg",
			questCriteria = "MainQuest",
			questTarget = "Birgg",
			questrepeat = false,
			questType = "KILL_MOBS",
			questDialog = "sample fuckerinoes",
			questLevel = 1,
			reward1 = 100,
			reward2 = 800,
			reward3 = 0,
		},
	},

	["NPC3"] = {
		[1] = {
			questObjective = 1,
			completed = false,
			questName = "Talk to NPC1",
			questCriteria = "MainQuest",
			questTarget = "NPC1",
			questrepeat = false,
			questType = "TALK_NPC",
			questDialog = "sample dialoge",
			questLevel = 1,
			reward1 = 100,
			reward2 = 0,
			reward3 = 0,
		},
	},

	["NPC4"] = {
		[1] = {
			questObjective = 10,
			completed = false,
			questName = "Collect 10 item",
			questCriteria = "MainQuest",
			questTarget = "item",
			questrepeat = false,
			questType = "GATHER_ITEM",
			questDialog = "sample dialoge",
			questLevel = 1,
			reward1 = 100,
			reward2 = 0,
			reward3 = 0,
		},
	},
}

return Quest
