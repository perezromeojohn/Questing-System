local QuestData = {}

-- Creates a new quest data object
function QuestData:new()
    local questData = {
        questId = nil, -- Unique identifier for the quest
        questType = nil, -- Type of quest (e.g., KILL_MOBS, GET_COINS)
        questObjective = nil, -- The objective of the quest (e.g., kill 10 zombies)
        progress = 0, -- Current progress on the quest
        completed = false, -- Flag indicating whether the quest is completed
    }
    return questData
end

return QuestData
