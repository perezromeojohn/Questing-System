local Quest = {
	["Area1"] = {	
		["Orcbolg"] = {
			[0] = {
				questObjective = 1,
				completed = false,
				questName = "Talk to Orcbolg",
				questCriteria = "MainQuest",
				questTarget = "Orcbolg",
				questrepeat = false,
				questType = "TALK_NPC",
				questDialog = "Talk to Orcbolg",
				reward1 = 100,
				reward2 = 0,
				reward3 = 0,
			},
			
			[1] = {
				questObjective = 1,
				completed = false,
				questName = "Kill Goblin Gobbers",
				questCriteria = "MainQuest",
				questTarget = "GoblinGobbers",
				questrepeat = false,
				questType = "KILL_MOBS",
				questDialog = "Can you Kill 5 Goblin Gobbers?",
				reward1 = 50,
				reward2 = 0,
				reward3 = true,
			},
			[2] = {
				questObjective = 1,
				completed = false,
				questName = "Kill Goblin Warrior",
				questCriteria = "MainQuest",
				questTarget = "GoblinWarrior",
				questrepeat = false,
				questType = "KILL_MOBS",
				questDialog = "Thanks, now can you kill 10 Goblin Warrior?",
				reward1 = 50,
				reward2 = 0,
				reward3 = true,
			},
			[3] = {
				questObjective = 1,
				completed = false,
				questName = "Kill Goblin Assasin",
				questCriteria = "MainQuest",
				questTarget = "GoblinAssassin",
				questrepeat = false,
				questType = "KILL_MOBS",
				questDialog = "Thanks, now can you kill 20 Goblin Assassin?",
				reward1 = 50,
				reward2 = 0,
				reward3 = true,
			},
			[4] = {
				questObjective = 1,
				completed = false,
				questName = "Kill Ermbirgg",
				questCriteria = "MainQuest",
				questTarget = "Ermbirgg",
				questrepeat = false,
				questType = "KILL_MOBS",
				questDialog = "Thanks, now can you kill Ermbirgg?",
				reward1 = 500,
				reward2 = 0,
				reward3 = true,
			},
			[5] = {
				questObjective = 1,
				completed = false,
				questName = "Kill Goblin Gobbers",
				questCriteria = "MainQuest",
				questTarget = "GoblinGobbers",
				questrepeat = false,
				questType = "KILL_MOBS",
				questDialog = "Can you Kill 5 Goblin Gobbers?",
				reward1 = 50,
				reward2 = 0,
				reward3 = true,
			},
		},
		
		--["Dummy"] = {
		--	[0] = {
		--		questObjective = 1,
		--		completed = false,
		--		questName = "Talk to Orcbolg",
		--		questCriteria = "MainQuest",
		--		questTarget = "Orcbolg",
		--		questrepeat = false,
		--		questType = "TALK_NPC",
		--		questDialog = "Talk to Orcbolg",
		--		reward1 = 100,
		--		reward2 = 0,
		--		reward3 = 0,
		--	}
		--},
		
		--["TurtleHermit"] = {
		--	[0] = {
		--		questObjective = 1,
		--		completed = false,
		--		questName = "Kill Goblin Gobbers",
		--		questCriteria = "MainQuest",
		--		questTarget = "GoblinGobbers",
		--		questrepeat = false,
		--		questType = "KILL_MOBS",
		--		questDialog = "Can you Kill 5 Goblin Gobbers?",
		--		reward1 = 50,
		--		reward2 = 0,
		--		reward3 = true,
		--	},
			
		--},

		["TurtleHermit"] = {
			questObjective = 1,
			completed = false,
			questName = "Kill Goblin Warrior",
			questCriteria = "SideQuest",
			questTarget = "GoblinWarrior",
			questrepeat = false,
			questType = "KILL_MOBS",
			questDialog = "Can you Kill 15 Goblin Warrior",
			reward1 = 100,
			reward2 = 0,
			reward3 = true,
			},
		
		["Birgg"] = {
			questObjective = 1,
			completed = false,
			questName = "Kill Goblin Gobbers",
			questCriteria = "SideQuest",
			questTarget = "GoblinGobbers",
			questrepeat = false,
			questType = "KILL_MOBS",
			questDialog = "Can you Kill 20 Goblin Gobbers",
			reward1 = 150,
			reward2 = 10,
			reward3 = false,
		},
		
		["Erggie"] = {
			questObjective = 1,
			completed = false,
			questName = "Gather Herbs",
			questCriteria = "SideQuest",
			questTarget = "Herbs",
			questrepeat = false,
			questType = "GATHER_iTEM",
			questDialog = "Can you Gather 15 Herbs",
			reward1 = 100,
			reward2 = 10,
			reward3 = false,
		},
		
		["SpearBee"] = {
			questObjective = 1,
			completed = false,
			questName = "Kill Goblin Assasin",
			questCriteria = "SideQuest",
			questTarget = "GoblinAssassin",
			questrepeat = false,
			questType = "KILL_MOBS",
			questDialog = "Thanks, now can you kill 20 Goblin Assassin?",
			reward1 = 500,
			reward2 = 0,
			reward3 = false,
		},

		["Charlson"] = {
			questObjective = 1,
			completed = false,
			questName = "Talk to Orcborg",
			questCriteria = "TutorialQuest",
			questTarget = "GoblinAssassin",
			questrepeat = false,
			questType = "KILL_MOBS",
			questDialog = "Hello my guy, welcome to Hero City. U need a weapon.",
			reward1 = 200,
			reward2 = 0,
			reward3 = false,
		},
		
	},
}

return Quest