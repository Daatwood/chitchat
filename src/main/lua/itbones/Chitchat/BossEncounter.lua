
-- Statistic Category IDS
WOD_DUNGEON_CATEGORY = 15233

Chitchat.WOD_DUNGEON_ZONE_ENCOUNTERS = {
  ["Auchindoun"] = {["NORMAL"] = 9262, ["HEROIC"] = 9263},
  ["Bloodmaul Slag Mines"] = {["NORMAL"] = 9258, ["HEROIC"] = 9259},
  ["Grimrail Depot"] = {["NORMAL"] = 9268, ["HEROIC"] = 9269},
  ["Iron Docks"] = {["NORMAL"] = 9260, ["HEROIC"] = 9261},
  ["Shadowmoon Burial Grounds"] = {["NORMAL"] = 9273, ["HEROIC"] = 9274},
  ["Skyreach"] = {["NORMAL"] = 9266, ["HEROIC"] = 9267},
  ["The Everbloom"] = {["NORMAL"] = 9271, ["HEROIC"] = 9272},
  ["Upper Blackrock Spire"] = {["NORMAL"] = 9275, ["HEROIC"] = 9276},
}

Chitchat.encounterUnitId = nil
Chitchat.encounterUnitTag = nil
Chitchat.encounterBlizzId = nil
Chitchat.encounterFrequcenyCheck = 1800
Chitchat.optionEncounterAutoCreateNote = true

function Chitchat:EcounterTimestampExpired(unitTag, timestamp)
  local personal_note = self:GetNote(unitTag)
  if personal_note == nil then return false end
  if personal_note[ENCOUNTERS_TIMESTAMP_KEY] == nil then return false end
  if timestamp == nil then timestamp = time() end
  return personal_note[ENCOUNTERS_TIMESTAMP_KEY] + self.encounterFrequcenyCheck < timestamp
end

function Chitchat:DoEncounterInspect(unitId, unitTag, blizzId, forceUpdate)
  local personal_note
  local now = time()
  if Chitchat.optionEncounterAutoCreateNote then
    personal_note = self:FindOrCreatePersonalNote(unitTag)
  else
    personal_note = self:GetNote(unitTag)
  end
  -- Nil check
  if personal_note == nil then
    if unitId == nil then unitId = "nil" end
    if unitTag == nil then unitTag = "nil" end
    self:Debug("Encounter note nil escape. unitid:"..unitId..", unitTag:"..unitTag)
    return
  end
  -- Frequency check 
  if self:EcounterTimestampExpired(unitTag,now) then
    if not forceUpdate then return end
  end
  if self:Inspectable(unitId) then
    self:Debug("Inspect unit:"..unitId..",tag:"..unitTag)
    self.encounterUnitId = unitId
    self.encounterUnitTag = unitTag
    self.encounterBlizzId = blizzId
    self:RegisterEvent("INSPECT_ACHIEVEMENT_READY", "OnEventInspectAchievementReady")
    SetAchievementComparisonUnit(unitId)
  else
    self:Debug("Cannot inspect unit:"..unitId..",tag:"..unitTag)
    self.encounterUnitId = nil
    self.encounterUnitTag = nil
  end
  personal_note[ENCOUNTERS_TIMESTAMP_KEY] = now
end

function Chitchat:Inspectable(unitId)
  return (CanInspect(unitId) and UnitIsVisible(unitId) and CheckInteractDistance(unitId, 1) and not InCombatLockdown())
end

function Chitchat:OnEventInspectAchievementReady()
  self:UnregisterEvent("INSPECT_ACHIEVEMENT_READY");
  if self.encounterUnitId == nil or self.encounterUnitTag == nil then
    self:Debug("Encounter inspection cannot perform.")
    return 
  end
  if self.encounterBlizzId == nil then
    self:Debug("Polling all statistics")
    local i, statisticCount
    statisticCount = GetCategoryNumAchievements(WOD_DUNGEON_CATEGORY)
    for i = 1, statisticCount do
      local bId, _ = GetAchievementInfo(WOD_DUNGEON_CATEGORY,i)
      self:AddPlayerEncounterStatistic(self.encounterUnitTag, bId)
    end
  else
    self:AddPlayerEncounterStatistic(self.encounterUnitTag, self.encounterBlizzId)
  end
  
  self.encounterUnitId = nil
  self.encounterUnitTag = nil
  self.encounterBlizzId = nil
  ClearAchievementComparisonUnit();
end

-- Gets the count value and adds to encounter table and personal_note link
function Chitchat:AddPlayerEncounterStatistic(tag, bId)
  local encounter, count, personal_note
  -- Nil Checks
  if tag == nil or bId == nil then return end
  
  -- Get personal note first
  personal_note = self:GetNote(tag)
  if personal_note == nil then
    if self.optionEncounterAutoCreateNote then
      personal_note = self:CreatePersonalNote(tag)
    else
      return
    end
  end
  if personal_note[ENCOUNTERS_KEY] == nil then personal_note[ENCOUNTERS_KEY] = {} end
  
  -- Get encounter table 
  encounter = self:GetEncounter(tostring(bId))
  if encounter == nil then -- First time run, create tables
    -- TODO move this to a first-time run area
    self:RefreshEncounterTable(WOD_DUNGEON_CATEGORY)
    encounter = self.encounters[blizzId]
    if encounter == nil then return end
  end
  if encounter[tag] == nil then encounter[tag] = {} end
  
  count = tostring(GetComparisonStatistic(bId)) -- Get Comparison Statistic from supplied Blizzard Id
  if count == "--" then return end -- Haven't ran the dungeon. Quick escape don't save, waste of space.
  encounter[tag][COUNT_KEY] = count -- Record Tag count in encounter table
  personal_note[ENCOUNTERS_KEY][tostring(bId)] = true -- Add link from personal_note to encounter for quick reference
end

function Chitchat:GetEncounters()
  return self.encounters
end
function Chitchat:GetEncounter(blizzId)
  if type(blizzId)~="string" then
    error(("GetEncounter: 'blizzId' - string expected got '%s'."):format(type(blizzId)),2)
  end
  local encounter = self.encounters[blizzId]
  if encounter == nil then
    self:Debug("Unable to find blizzid:"..blizzId)
    self:RefreshEncounterTable(WOD_DUNGEON_CATEGORY)
  end
  return encounter
end

function Chitchat:GetEncounterDungeonKills(tag,zone)
  local nk, hk = 0, 0
  local blizzids = self.WOD_DUNGEON_ZONE_ENCOUNTERS[zone]
  if blizzids == nil then
    self:Debug("GetEncounterDungeonKills: Zone not found:"..zone)
    return 0, 0 
  end
  local personal_note = Chitchat:GetNote(tag)
  if personal_note == nil then 
    self:Debug("GetEncounterDungeonKills: Personal Note nil.")
    return 0, 0 
  end
  local player_encounters = personal_note[ENCOUNTERS_KEY]
  local encounter = tostring(blizzids["NORMAL"])
  if player_encounters[encounter] then
    nk = self:GetEncounter(encounter)[tag][COUNT_KEY]
  end
  encounter = tostring(blizzids["HEROIC"])
  if player_encounters[encounter] then
    hk = self:GetEncounter(encounter)[tag][COUNT_KEY]
  end
  return nk, hk
end

-- Updates the BossEncounters to include a category
function Chitchat:RefreshEncounterTable(category)
  self:Debug("Refreshing Encounter Table")
  local statisticCount = GetCategoryNumAchievements(category)
  for i = 1, statisticCount do
    local blizzId, name
    blizzId, name = GetAchievementInfo(category, i)
    blizzId = tostring(blizzId)
    if self:GetEncounter(blizzId) == nil then
      self:CreateBossEncounter(blizzId,name)
    end
  end
end

function Chitchat:GetZoneTextFromEncounter(encounter)
  local startIndex, endIndex, name
  startIndex, endIndex = string.find(encounter,"%b()")
  name = string.sub(encounter,startIndex+1,endIndex-1)
  return name or encounter
end

function Chitchat:AddEncounter(blizzId, boss_encounter)
  if boss_encounter == nil then
    error(("AddEncounter: 'boss_encounter' - table expected got '%s'."):format(type(boss_encounter)),2)
  end
  self.encounters[blizzId] = boss_encounter
  --self:Debug("Created Boss encounter "..blizzId.." - "..self.encounters[blizzId][DESCRIPTION_KEY])
  return blizzId
end

function Chitchat:CreateBossEncounter(blizzId, description)
  local boss_encounter = {}
  
  if type(blizzId)~="string" then
    error(("CreateBossEncounter: 'blizzId' - string expected got '%s'."):format(type(blizzId)),2)
  end
  if type(description)~="string" then
    error(("CreateBossEncounter: 'description' - string expected got '%s'."):format(type(description)),2)
  end
  if self:GetEncounter(blizzId) ~= nil then
    error(("CreateBossEncounter: 'blizzId' - '%s' already exists"):format(blizzId),2)
  end
  
  boss_encounter[DESCRIPTION_KEY] = description
  return self:AddEncounter(blizzId, boss_encounter)
end