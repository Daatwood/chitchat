
-- function Chitchat:ResetInspection()
  -- if requestedAchievementData then
    -- ClearAchievementComparisonUnit();
    -- requestedAchievementData = nil
  -- end
  -- Chitchat.inspectUnit = nil
  -- Chitchat.inspectUnitType = nil
  -- Chitchat.canInspect = nil
-- end

-- Statistic Category IDS
WOD_DUNGEON_CATEGORY = 15233

Chitchat.WOD_DUNGEON_ZONE_ENCOUNTERS = {
  ["Auchidoun"] = {["NORMAL"] = 9262, ["HEROIC"] = 9263},
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
Chitchat.encounterUnitQueue = {}
Chitchat.encounterUnitQueueSize = 0
Chitchat.encounterQueueUpdating = nil

function Chitchat:DoEncounterInspect(unitId, unitTag, blizzId,force)
  local personal_note
  local now = time()
  personal_note = self:GetNote(unitTag)
  -- Nil check
  if personal_note == nil then
    if unitId == nil then unitId = "nil" end
    if unitTag == nil then unitTag = "nil" end
    self:Debug("Encounter note nil escape. unitid:"..unitId..", unitTag:"..unitTag)
    return
  end
  -- Frequency check
  if not force and personal_note[ENCOUNTERS_TIMESTAMP_KEY] ~= nil and personal_note[ENCOUNTERS_TIMESTAMP_KEY] + 1800 > now then
    return
  end
  
  if CanInspect(unitId) and UnitIsVisible(unitId) then
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

function Chitchat:ClearEncounterQueue()
  self.encounterUnitId = nil
  self.encounterUnitTag = nil
  self.encounterUnitQueue = {}
  self.encounterUnitQueueSize = 0
  self.encounterQueueUpdating = false
end

function Chitchat:AddToEncounterQueue(unitId,tag)
  self.encounterUnitQueue[unitId] = tag
  self.encounterUnitQueueSize = self.encounterUnitQueueSize + 1
end

function Chitchat:DoEncounterQueue()
  self:Debug("Do encounter queue.")
  local unitId, unitTag
  local personal_note
  local now = time()
  unitId, unitTag = next(self.encounterUnitQueue)
  personal_note = self:GetNote(unitTag)
  if self.encounterUnitQueue == nil or unitId == nil or unitTag == nil then 
    self:Debug("Encounter Queue size:"..self.encounterUnitQueueSize)
    return
  end
  -- Nil check
  if personal_note == nil then
    if unitId == nil then unitId = "nil" end
    if unitTag == nil then unitTag = "nil" end
    self:Debug("Encounter note nil escape. unitid:"..unitId..", unitTag:"..unitTag)
    return
  end
  -- Frequency check
  if personal_note[ENCOUNTERS_TIMESTAMP_KEY] ~= nil and personal_note[ENCOUNTERS_TIMESTAMP_KEY] + 3600 < now then
    self:Debug("Encounter timestamp escape")
    return
  end
  
  if CanInspect(unitId) and UnitIsVisible(unitId)then
    self:Debug("Inspect unit:"..unitId..",tag:"..unitTag)
    self.encounterUnitId = unitId
    self.encounterUnitTag = unitTag
    self:RegisterEvent("INSPECT_ACHIEVEMENT_READY", "OnEventInspectAchievementReady")
    SetAchievementComparisonUnit(unitId)
  else
    self:Debug("Cannot inspect unit:"..unitId..",tag:"..unitTag)
    self.encounterUnitId = nil
    self.encounterUnitTag = nil
  end
  
  if self.encounterUnitQueueSize > 0 then
    if not self.encounterQueueUpdating then self.encounterQueueUpdating = true end
    ChitchatParent:SetScript("OnUpdate",Chitchat_OnUpdate);
    self:Debug("Encounter Queue starting.")
  else
    if self.encounterQueueUpdating then self.encounterQueueUpdating = nil end
    ChitchatParent:SetScript("OnUpdate",nil);
    self:Debug("Encounter Queue stopping. Size:"..self.encounterUnitQueueSize)
  end
  self.encounterUnitQueue[unitId] = nil
  self.encounterUnitQueueSize = self.encounterUnitQueueSize - 1
end

function Chitchat_OnUpdate(self, elapsed)
  if Chitchat.encounterUnitId == nil and Chitchat.encounterUnitTag == nil then
    Chitchat:DoEncounterQueue()
  end
end

function Chitchat:OnEventInspectAchievementReady()
  self:UnregisterEvent("INSPECT_ACHIEVEMENT_READY");
  if self.encounterUnitId == nil or self.encounterUnitTag == nil then
    self:Debug("Encounter inspection cannot perform.")
    return 
  end
  self:Debug("Getting Stats for player:"..self.encounterUnitId)
  self:AddPlayerStatistics(self.encounterUnitTag, self.encounterBlizzId)
  self.encounterUnitId = nil
  self.encounterUnitTag = nil
  self.encounterBlizzId = nil
  ClearAchievementComparisonUnit();
end

function Chitchat:AddSelfStatistics()
  local i
  local statisticCount = GetCategoryNumAchievements(WOD_DUNGEON_CATEGORY)
  local timestamp = time()
  for i = 1, statisticCount do
    local blizzId, Name, kills
    blizzId, Name = GetAchievementInfo(WOD_DUNGEON_CATEGORY, i)
    kills = tostring(GetStatistic(blizzId))
    self:AddPlayerEncounter(tostring(blizzId),"Renzu-Crushridge",timestamp,kills)
    --print(GetStatistic(IDNumber))
  end
end

function Chitchat:AddPlayerStatistics(tag, blizzId)
  local i
  local timestamp = time()
  if blizzId == nil then
    self:Debug("Polling all statistics")
    local statisticCount = GetCategoryNumAchievements(WOD_DUNGEON_CATEGORY)
    for i = 1, statisticCount do
      local Name, kills
      blizzId, Name = GetAchievementInfo(WOD_DUNGEON_CATEGORY, i)
      kills = tostring(GetComparisonStatistic(blizzId))
      self:AddPlayerEncounter(tostring(blizzId),tag,timestamp,kills)
      --print(GetStatistic(IDNumber))
    end
  else
    kills = tostring(GetComparisonStatistic(blizzId))
    self:AddPlayerEncounter(tostring(blizzId),tag,timestamp,kills)
  end
end

function Chitchat:AddPlayerEncounter(blizzId,tag,timestamp,count)
  if count == nil or count == "--" then return end
  local boss_encounter = self:GetEncounter(blizzId)
  
  if boss_encounter == nil then
    self:RefreshEncounterTable(WOD_DUNGEON_CATEGORY)
    boss_encounter = self.encounters[blizzId]
  end
    
  if boss_encounter[tag] == nil then boss_encounter[tag] = {} end
  --boss_encounter[tag][TIMESTAMP_KEY] = timestamp
  boss_encounter[tag][COUNT_KEY] = count
  
  local personal_note = self:GetNote(tag)
  if personal_note[ENCOUNTERS_KEY] == nil then personal_note[ENCOUNTERS_KEY] = {} end
  personal_note[ENCOUNTERS_KEY][blizzId] = true
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
-- Return blizzId
function Chitchat:GetEncounterLookup(encounter)
  if self.encounterLookup == nil then self:RefreshEncounterLookupTable() end
  return self.encounterLookup[encounter]
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
    --self:Debug("encounter: "..encounter..",tag:,"..tag.."count:"..nk)
  else
    nk = 0
  end
  encounter = tostring(blizzids["HEROIC"])
  if player_encounters[encounter] then
    hk = self:GetEncounter(encounter)[tag][COUNT_KEY]
    --self:Debug("encounter: "..encounter..",tag:,"..tag.."count:"..hk)
  else
    hk = 0
  end
  return nk, hk
end

function Chitchat:GetEncounterLookupKillCount(zone,encounters,tag)
  local kills = 0
  local blizzId = Chitchat:GetEncounterLookup(zone)
  if blizzId ~= nil then blizzId = blizzId[1] end
  if encounters[blizzId] then
    kills = self:GetEncounter(blizzId)[tag][COUNT_KEY]
  end
  return kills
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
  self:RefreshEncounterLookupTable()
end

-- [ZoneName][Difficulty] = {blizzId}
-- Hard code this?
function Chitchat:RefreshEncounterLookupTable()
  self:Debug("Refreshing EncounterLookup Table")
  self.encounterLookup = {}
  for blizzId, encounter in pairs(self:GetEncounters()) do
    local description, startIndex, endIndex, name
    description = encounter[DESCRIPTION_KEY]
    -- Locates the Area in '()'
    startIndex, endIndex = string.find(description,"%b()")
    name = string.sub(description,startIndex+1,endIndex-1)
    -- Locate difficulty Regular, Raid Finder, Normal, Heroic, Mythic
    if self.encounterLookup[name] == nil then self.encounterLookup[name] = {} end
    tinsert(self.encounterLookup[name],blizzId)
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