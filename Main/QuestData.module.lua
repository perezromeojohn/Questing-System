local QuestData = {}

-- Creates a new quest data object
function QuestData:new()
    local questData = {
        questId = nil, -- Unique identifier for the quest
        questName = nil, -- Name of the quest
        questCriteria = nil, -- Criteria for the quest (e.g., MainQuest, DailyQuest, WeeklyQuest)
        questType = nil, -- Type of quest (e.g., KILL_MOBS, GET_COINS)
        questObjective = nil, -- The objective of the quest (e.g., kill 10 mobs)
        questTarget = nil, -- The target of the quest (e.g., kill 10 zombies)
        progress = 0, -- Current progress on the quest
        completed = false, -- Flag indicating whether the quest is completed
        claimed = false, -- Flag indicating whether the quest is claimed
    }
    return questData
end

return QuestData
