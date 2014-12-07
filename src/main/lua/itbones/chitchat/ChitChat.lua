Chitchat = LibStub("AceAddon-3.0"):NewAddon("Chitchat", "AceConsole-3.0","AceEvent-3.0", "AceHook-3.0")

Chitchat.editNoteFrame = nil

local defaultDB = {
  global = {
    silent = false, -- Run quietly in background
    minimap = { hide = false }, -- Minimap Icon display
    tooltipNotes = false,
    logs = {}, -- WhisperLog
    notes = {}, -- PersonalNote
    encounters = {}, -- Casual Encounters
    messages = {index = 0}, -- MessageEntry
    channelRecording = false,
    channelsToRecord = {
    ["Trade"] = false,
    ["General"] = false,
    },
    recordBNConversation = true,
    menusToModify = {
      ["PLAYER"] = true, 
      ["TARGET"] = true,
      ["PARTY"] = true, 
      ["FRIEND"] = true, 
      ["FRIEND_OFFLINE"] = true, 
      ["RAID_PLAYER"] = true,
    },
    tooltips = {
      showInCombat = false,
      worldFormat = {
        default = nil,
        expanded = "all",
      },
      dungeonFormat = {
        default = "current",
        expanded = "all",
      },
      raidFormat = {
        default = "current",
        expanded = "all",
      },
    },
  }
}

INDEX_KEY = "index"
SENDER_KEY = "sender"
MESSAGE_KEY = "message"
TIMESTAMP_KEY = "timestamp"
INCOMING_KEY = "incoming"
ID_KEY = "id"
HIDE_CHAT_KEY = "quiet"
FAVORITE_KEY = "favorite"

TAG_KEY = "tag"
MESSAGES_KEY = "messages"
UNREAD_KEY = "unread"

NOTE_KEY = "note"
RATING_KEY = "rating"
ROLE_KEY = "role"
CLASS_KEY = "playerclass"
SEEN_KEY = "seen"
ENCOUNTERS_KEY = "encounters"
ENCOUNTERS_TIMESTAMP_KEY = "encounter-timestamp"

COUNT_KEY = "count"
DESCRIPTION_KEY = "descript"

local GREEN =  "|cff00ff00"
local YELLOW = "|cffffff00"
local RED =    "|cffff0000"
local BLUE =   "|cff0198e1"
local ORANGE = "|cffff9933"
local WHITE =  "|cffffffff"
local tooltipNoteFormat = YELLOW.."%s "..WHITE.."%s".."|r"
local tooltipNoteDungeonEncounterFormat = YELLOW.."   %s "..WHITE.."%s | "..ORANGE.."%s".."|r"

Chitchat.WOD_DUNGEON_ZONES = {
  "Auchindoun",
  "Bloodmaul Slag Mines",
  "Grimrail Depot",
  "Iron Docks",
  "Shadowmoon Burial Grounds",
  "Skyreach",
  "The Everbloom",
  "Upper Blackrock Spire"
}
Chitchat.WOD_RAID_ZONES = {
  "Highmaul"
}

local defaultIcon = "Interface\\Icons\\INV_Misc_Book_03.blp"
local newMessageIcon = "Interface\\Icons\\INV_Misc_Book_04.blp"

Chitchat.inspectGuid = nil

UnitPopupButtons["CC_EDIT_NOTE"] = {text = "Have we met?", dist = 0, func = Chitchat.EditNoteDropdown}
UnitPopupButtons["CC_ENCOUNTER_INSPECT"] = {text = "Get Encounters", dist = 0, func = Chitchat.EditNoteDropdown}

function Chitchat:OnInitialize()
  -- Called when the addon is first initalized
  --self:Debug("OnInitialize: \124TInterface\\Icons\\INV_Misc_EngGizmos_13:12\124t")
  -- Setup slash commands
  self:RegisterChatCommand("chitchat","CommandHandler")
  self:RegisterChatCommand("cc","CommandHandler")
  -- Load saved database
  initDatabase()

  -- Setup minimap icon
  initMinimap()

  --self:InitializeFrame()
end

function Chitchat:OnEnable()
  -- Called when the addon is enabled, just before running
  self:Debug("OnEnable")

  -- Register Events
  self:RegisterEvent("CHAT_MSG_WHISPER", "OnEventWhisperIncoming")
  self:RegisterEvent("CHAT_MSG_WHISPER_INFORM","OnEventWhisperOutgoing")
  if self.db.global.channelRecording == true then
    self:RegisterEvent("CHAT_MSG_CHANNEL","OnEventChannelChatMessage")
  end
  if self.db.global.recordBNConversation == true then
    self:RegisterEvent("CHAT_MSG_BN_WHISPER","OnEventBnetWhisperIncoming")
    self:RegisterEvent("CHAT_MSG_BN_WHISPER_INFORM","OnEventBnetWhisperOutgoing")
  end
  -- if: allow chat bypass filter
  ChatFrame_AddMessageEventFilter("CHAT_MSG_WHISPER", Chitchat_FilterWhisperMessages)
  ChatFrame_AddMessageEventFilter("CHAT_MSG_WHISPER_INFORM", Chitchat_FilterWhisperMessages)
  
  self:RegisterEvent("GROUP_ROSTER_UPDATE", "OnEventGroupRosterUpdate")
  self:RegisterMessage("CHITCHAT_PLAYER_SEEN","OnPlayerSessionAlert")

  -- Register Hooks
  -- HaveWeMet Hooks
 
  for menu, enabled in pairs(self.db.global.menusToModify) do
    if menu and enabled then
      tinsert(UnitPopupMenus[menu], #UnitPopupMenus[menu], "CC_EDIT_NOTE")
      tinsert(UnitPopupMenus[menu], #UnitPopupMenus[menu], "CC_ENCOUNTER_INSPECT")
    end
  end
  self:SecureHook("UnitPopup_ShowMenu")
  
  self:HookScript(GameTooltip, "OnTooltipSetUnit")

  -- Create Frames
  self.editNoteFrame = self:CreateEditNoteFrame()

  -- Finalize Addon
end

function Chitchat:Debug(s, ...)
	if self.db.global.silent then self:Print(format("[Debug] "..s, ...)) end
end

function Chitchat:OnDisable()
  self:Debug("OnDisable")
  -- Called when the addon is disabled

  -- Halt mod completely, and enter standby mode.
  self:UnregisterEvent("CHAT_MSG_WHISPER", "OnEventWhisperIncoming")
  self:UnregisterEvent("CHAT_MSG_WHISPER_INFORM","OnEventWhisperOutgoing")
end

function initDatabase()
  Chitchat.db = LibStub("AceDB-3.0"):New("ChitchatDB",defaultDB,true)
  Chitchat.logs = Chitchat.db.global.logs or {}
  Chitchat.messages = Chitchat.db.global.messages or {}
  Chitchat.notes = Chitchat.db.global.notes or {}
  Chitchat.encounters = Chitchat.db.global.encounters or {}
end
function Chitchat:setupMetatable(array, meta, tag_type)
  for index, value in ipairs(array) do
    setmetatable(value, meta)
    if tag_type ~= nil then
      Chitchat:AddTag(value["tag"],tag_type,value["id"])
    end
  end
end

function initMinimap()
  Chitchat.iconObject = LibStub("LibDataBroker-1.1"):NewDataObject("Chitchat", {
    type = "data source",
    text = "CHITCHAT",
    icon = defaultIcon,
    OnClick = function (frame, button)
      -- TODO Verify not in combat
      Chitchat:ToggleFrame()
    end,
    OnTooltipShow = function (tooltip)
      Chitchat:OnTooltipShow(tooltip)
    end
  })
  local LDBIcon = LibStub("LibDBIcon-1.0", true)
  if LDBIcon then
    LDBIcon:Register("Chitchat", Chitchat.iconObject,Chitchat.db.global.minimap)
  end
end
function Chitchat:OnTooltipShow (tooltip)
  tooltip:AddLine("Chitchat")
end

function Chitchat:CommandHandler(input)
  local cmd = strlower(input)
	if cmd == "debug" then
		if self.db.global.silent then
			self.db.global.silent = false
			self:Print("Debug mode OFF")
		else
			self.db.global.silent = true
			self:Print("Debug mode ON")
		end
  elseif cmd == "test" then
    self:Print("Faking a whisper.")
    Chitchat:FakeWhisper(math.random(0,1))
  elseif cmd == "statupdate" then
    self:AddSelfStatistics()
	else
		self:ToggleFrame()
	end
end

function Chitchat:ToggleFrame()
  if ChitchatParent:IsShown() then
    HideUIPanel(ChitchatParent)
  else
    ShowUIPanel(ChitchatParent)
    Chitchat.iconObject.icon = defaultIcon
  end
end

function Chitchat:OnPlayerSessionAlert(self, tag)
  Chitchat:Print("Familiar Player: "..tag)
end

-- Generate a Fake Whisper for Testing.
-- incoming: 0 or 1. determines if message is sent or recieved.
local TEST_STRING = "Lorem ipsum dolor sit amet, consectetur adipiscing elit. Vestibulum ultricies nisi ligula, ac finibus nulla aliquet et. Suspendisse porttitor consectetur massa, ac ultrices eros ultricies quis. Nullam in magna luctus, rutrum ligula sit amet."
function Chitchat:FakeWhisper(incoming)
  local rnd = math.random(1,99999)
  local tag = "Prototype"..rnd.."-"..GetRealmName()
  local message = strsub(TEST_STRING,0,math.random(11, strlen(TEST_STRING)))
  Chitchat:HandleWhisper(tag, message, time(), incoming)
  Chitchat:UpdatePersonalNote(tag,"Test Message, Please Ignore.",math.random(0,10),"TANK","DEATHKNIGHT")
end
function Chitchat:OnEventChannelChatMessage(self, message, sender, lang, channelString, target, flags, arg7, channelNumber, channelName, arg10, counter, guid)
  Chitchat:HandleChatMessage(channelName,sender,message,time())
 end
function Chitchat:OnEventBnetWhisperIncoming(self, message, sender, arg3, arg4, arg5, arg6, arg7, arg8, arg9, arg10, counter, arg12, presenceID, arg14)
  Chitchat:HandleBNWhisper(presenceID,message,time(),1)
end
function Chitchat:OnEventBnetWhisperOutgoing(self, message, sender, arg3, arg4, arg5, arg6, arg7, arg8, arg9, arg10, counter, arg12, presenceID, arg14)
  Chitchat:HandleBNWhisper(presenceID,message,time(),0)
end
-- Handle Incoming WoW Whispers
function Chitchat:OnEventWhisperIncoming(self, message, sender, lang, channelString, target, flags, arg7, channelNumber, channelName, arg10, counter, guid)
  Chitchat:HandleWhisper(sender, message, time(), 1)
end
-- Handle Outgoing WoW Whispers
function Chitchat:OnEventWhisperOutgoing(self, message, sender, lang, channelString, target, flags, arg7, channelNumber, channelName, arg10, counter, guid)
  Chitchat:HandleWhisper(sender, message, time(), 0)
end

-- a filter to hide all yelled messaged containing certain text
function Chitchat_FilterWhisperMessages(self,event,message, sender, ...)
  local whisper_log = Chitchat:GetLog(sender)
  if whisper_log ~= nil and whisper_log[HIDE_CHAT_KEY] == true then
    Chitchat:Debug("Ready")
    return true, "", "", ...
  end
  return false, message, sender, ...
end

function Chitchat:HandleBNWhisper(presenceID,message,timestamp,incoming)
  local index = BNGetFriendIndex(presenceID)
  local _, _, _, _, toonName = BNGetFriendInfo(index)
  self:HandleWhisper(toonName,message,timestamp,incoming)
end

-- Locates the Entry by looking up the assigned tag.
-- Create a whisper and add the id to the entries's whisper table.
function Chitchat:HandleWhisper(tag, message, timestamp, incoming)
  local message_id = Chitchat:CreateMessageEntry(tag, message, timestamp, incoming)[ID_KEY]
  local whisper_log = Chitchat:FindOrCreateWhisperLog(tag)
  if whisper_log == nil then
    error("HandleWhisper: Unable to find or create a whisper log.",2)
  end
  
  tinsert(whisper_log.messages, message_id)
  if incoming == 1 then
    whisper_log[UNREAD_KEY] = whisper_log[UNREAD_KEY] + 1
    Chitchat.iconObject.icon = newMessageIcon
  end
  self:SendMessage("CHITCHAT_LOG_UPDATED", whisper_log[TAG_KEY], message_id)
end

function Chitchat:HandleChatMessage(channel,tag,message,timestamp)
  local message_id = Chitchat:CreateMessageEntry(tag, message, timestamp, 2)[ID_KEY]
  local chat_log = Chitchat:FindOrCreateWhisperLog(channel)
  if chat_log == nil then
    error("HandleChatMessage: Unable to find or create a chat log.",2)
  end
  tinsert(chat_log.messages, message_id)
end

----------------------------------------------------------------------------
-- HAVE WE MET 
----------------------------------------------------------------------------
function Chitchat:OnTooltipSetUnit(tooltip, ...)
  --if self.db.global.tooltipNotes == false then return end
  local name, unitid = tooltip:GetUnit()
  local tag, note, rating,seen,personal_note,encounter
  local showExpandedTooltip = IsShiftKeyDown()
  local inInstance, instanceType = IsInInstance()

-- If the unit exists and is a player then check if there is a note for it.
  if UnitExists(unitid) and UnitIsPlayer(unitid) then
    name, realm = UnitName(unitid)
    if realm == nil then
      realm = GetRealmName()
    end
    tag = name.."-"..realm
    personal_note = Chitchat:GetNote(tag)
    if personal_note ~= nil then
      rating = personal_note[RATING_KEY]
      note = personal_note[NOTE_KEY]
      encounter = personal_note[ENCOUNTERS_KEY]
      seen = personal_note[SEEN_KEY]
      if type(rating) == "number" and rating > 0  then tooltip:AddLine(tooltipNoteFormat:format("Rated ", rating),1, 1, 1, false) end
      if note ~= nil and note ~= "" then tooltip:AddLine(tooltipNoteFormat:format("Note:",note),1, 1, 1, true) end
      TooltipHaveWeMetLastSeen(tooltip,seen)
      -- TODO: CONFIG CHECK AUTO ENCOUNTER INSPECT (OUTDATED,ALWAYS,NEVER)
      --Chitchat:DoEncounterInspect(unitid, tag, nil, false)
      
      if encounter ~= nil then
        tooltip:AddLine(tooltipNoteFormat:format("Encounters",date("%m/%d/%y %H:%M:%S", personal_note[ENCOUNTERS_TIMESTAMP_KEY])),1,1,1,false)
        if inInstance then
          -- get instance info
          local name, _, _, _, _, _, _, _ =GetInstanceInfo()
          -- When in Dungeon shift shows all Dungeons/Heroic
          if instanceType == "party" then
            local instances = { name }
            if showExpandedTooltip then instances = self.WOD_DUNGEON_ZONES end
            TooltipDungeonExpanded(tooltip,tag, instances)
          elseif instanceType == "raid" then
            local instances = { name }
            if showExpandedTooltip then instances = self.WOD_RAID_ZONES end
            local i, zone, nk, hk
            for i, zone in ipairs(instances) do
              nk, hk = Chitchat:GetEncounterDungeonKills(tag,zone)
              tooltip:AddLine(tooltipNoteDungeonEncounterFormat:format(zone,nk,hk),1, 1, 1, false)
            end
          end
        else
          -- Show Expanded World Tooltip
          if showExpandedTooltip then
            TooltipDungeonExpanded(tooltip,tag, Chitchat.WOD_DUNGEON_ZONES)
            --TooltipRaidCondensed(tooltip,tag,Chitchat.WOD_RAID_ZONES)
          end
        end
      elseif showExpandedTooltip then
        tooltip:AddLine(tooltipNoteFormat:format("Encounters: ","None found."),1, 1, 1, false)
      end
    end
  end
end

function TooltipHaveWeMetLastSeen(tooltip, seen_notes)
  if seen_notes == nil then return end
  tooltip:AddLine(tooltipNoteFormat:format("Last Seen:",''),1,1,1,false)
  tooltip:AddLine(tooltipNoteFormat:format(" ",date("%m/%d/%y %H:%M:%S", seen_notes[#seen_notes])),1,1,1,false)
end

function TooltipDungeonExpanded(tooltip, tag, instances)
  local i, zone, nk, hk
  for i, zone in ipairs(instances) do
    nk, hk = Chitchat:GetEncounterDungeonKills(tag,zone)
    tooltip:AddLine(tooltipNoteDungeonEncounterFormat:format(zone,nk,hk),1, 1, 1, false)
  end
end
-- Raid Name (Difficulty) [9|8|7|6|5|4|3|2|1]
function TooltipRaidExpanded(tooltip, tag, instances)
  
end

-- Raid Name [9M|8H|7N|6N|5N|4N|3R|2N|1R]
function TooltipRaidShort(tooltip, tag, instances)
  local i, zone, rk, nk, hk, mk
  for i, zone in ipairs(instances) do
    bosses = Chitchat:GetEncounterRaidBossKills(tag,zone,difficulty)
    tooltip:AddLine(tooltipNoteDungeonEncounterFormat:format(zone,nk,hk),1, 1, 1, false)
  end
end

-- Raid Name (Difficulty): 11/14 or Cleared
function TooltipRaidSimple(tooltip, tag, instances)
  
end

function Chitchat:GetEncountersFromTarget()
  local unitid = "target"
  if UnitExists(unitid) and UnitIsPlayer(unitid) then
    local name, realm = UnitName(unitid)
    if realm == nil then
      realm = GetRealmName()
    end
    tag = name.."-"..realm
    Chitchat:DoEncounterInspect(unitid, tag, nil,true)
  end
end

function Chitchat:UnitPopup_ShowMenu(dropdownMenu, which, unit, name, userData, ...)
  for i = 1, UIDROPDOWNMENU_MAXBUTTONS do
    local button = _G["DropDownList"..UIDROPDOWNMENU_MENU_LEVEL.."Button"..i]
    if button.value == "CC_EDIT_NOTE" then
      button.func =  Chitchat.EditNoteDropdown
    elseif button.value == "CC_ENCOUNTER_INSPECT" then
      button.func = Chitchat.DropDownEncounterInspect
    end
  end
end

function Chitchat:EditNoteDropdown()
	local menu = UIDROPDOWNMENU_INIT_MENU
  local name = menu.name
  local realm = menu.server
  if realm == nil then
    realm = GetRealmName()
  end
	local tag = name.."-"..realm
	Chitchat:EditNoteHandler(tag)
end

function Chitchat:DropDownEncounterInspect()
  local menu = UIDROPDOWNMENU_INIT_MENU
  local name = menu.name
  local realm = menu.server
  local unitid = menu.unit
  if realm == nil then
    realm = GetRealmName()
  end
	local tag = name.."-"..realm
  Chitchat:DoEncounterInspect(unitid, tag, nil, true)
end

function Chitchat:EditNoteHandler(input)
  local tag
  if input and #input > 0 then
    tag = input
  end
  if tag ~= nil then
    local personal_note = Chitchat:GetNote(tag)
    local note = ""
    local rating = 0
    if personal_note ~= nil then
      note = personal_note[NOTE_KEY]
      rating = personal_note[RATING_KEY]
      if type(rating) ~= "number" then rating = 0 end
    end
    local frame = Chitchat.editNoteFrame
    frame.charname:SetText(tag)
    ChitchatEditFrameNote:SetText(note)
    ChitchatEditFrameSlider:SetValue(rating)
    frame:Show()
    frame:Raise()
  end
  HaveWeMetNoteFrame:Show()
  HaveWeMetNoteFrame:Raise()
end

-- Handle Group changes
function Chitchat:OnEventGroupRosterUpdate(self, args)
  Chitchat:HandleGroupChange()
end

function Chitchat:HandleGroupChange()
  self:Debug("Group Changed")
  local group_size = GetNumGroupMembers()
  local valid_players = 0
  if group_size == 0 then
    return
  end
  local group_type = "Raid"
  local group_size_max = 40
  if UnitInParty("player") and UnitInRaid("player") == nil then
    group_type = "Party"
    group_size_max = 5
    valid_players = 1
  end
  for i=1, group_size_max do
    local unitId = group_type..""..i
    local p_name, p_realm = UnitName(unitId)
    local _, p_class = UnitClass(unitId)
    local guid = self:GetPlayerTag(p_name, p_realm)
    local role = UnitGroupRolesAssigned(unitId)
    if guid ~= nil and guid ~= '' then
      self:UpdatePersonalNote(guid,nil,nil,role,p_class)
      valid_players = valid_players + 1
    end
    if valid_players >= group_size then break end
  end
end

function Chitchat:GetPlayerTag(p_name, p_realm)
  if p_name == nil then
    return ''
  end
  if p_realm == nil or p_realm == '' then
    p_realm = GetRealmName()
  end
  return p_name.."-"..p_realm
end

-------------------------------------------------------------------------------
-- HAVE WE MET FRAME 
-------------------------------------------------------------------------------

function Chitchat:CreateEditNoteFrame()
	local editwindow = CreateFrame("Frame", "ChitchatEditWindow", UIParent)
	editwindow:SetFrameStrata("DIALOG")
	editwindow:SetToplevel(true)
	editwindow:SetWidth(400)
	editwindow:SetHeight(280)
	editwindow:SetPoint("CENTER", UIParent)
	editwindow:SetBackdrop(
		{bgFile="Interface\\Tooltips\\UI-Tooltip-Background", 
	    edgeFile="Interface\\Tooltips\\UI-Tooltip-Border", tile=true,
		tileSize=16, edgeSize=16, insets={left=4, right=4, top=4, bottom=4}})
	editwindow:SetBackdropColor(0,0,0,1)

	local savebutton = CreateFrame("Button", nil, editwindow, "UIPanelButtonTemplate")
	savebutton:SetText("Save")
	savebutton:SetWidth(100)
	savebutton:SetHeight(20)
	savebutton:SetPoint("BOTTOM", editwindow, "BOTTOM", -60, 20)
	savebutton:SetScript("OnClick",
  function(this)
    local frame = this:GetParent()
    local tag = frame.charname:GetText()
    local rating = math.floor(frame.slider:GetValue()+0.5)
    Chitchat:UpdatePersonalNote(tag,frame.editbox:GetText(),rating, nil, nil)
    frame:Hide()
  end)

	local cancelbutton = CreateFrame("Button", nil, editwindow, "UIPanelButtonTemplate")
	cancelbutton:SetText("Cancel")
	cancelbutton:SetWidth(100)
	cancelbutton:SetHeight(20)
	cancelbutton:SetPoint("BOTTOM", editwindow, "BOTTOM", 60, 20)
	cancelbutton:SetScript("OnClick", function(this) this:GetParent():Hide(); end)

	local headertext = editwindow:CreateFontString("ChitchatEditFrameTitle", editwindow, "GameFontNormalLarge")
	headertext:SetPoint("TOP", editwindow, "TOP", 0, -20)
	headertext:SetText("Have we met?")

	local charname = editwindow:CreateFontString("ChitchatEditFrameTag", editwindow, "GameFontNormal")
	charname:SetPoint("BOTTOM", headertext, "BOTTOM", 0, -40)
	charname:SetFont(charname:GetFont(), 14)
	charname:SetTextColor(1.0,1.0,1.0,1)
  
  local editBoxContainer = CreateFrame("Frame", nil, editwindow)
  editBoxContainer:SetPoint("TOPLEFT", editwindow, "TOPLEFT", 20, -150)
  editBoxContainer:SetPoint("BOTTOMRIGHT", editwindow, "BOTTOMRIGHT", -40, 100)
	editBoxContainer:SetBackdrop(
		{bgFile="Interface\\Tooltips\\UI-Tooltip-Background", 
	  edgeFile="Interface\\Tooltips\\UI-Tooltip-Border", tile=true,
		tileSize=16, edgeSize=16, insets={left=3, right=3, top=3, bottom=3}})
	editBoxContainer:SetBackdropColor(0,0,0,0.9)

	local editbox = CreateFrame("EditBox", "ChitchatEditFrameNote", editwindow)
  editbox:SetFontObject("GameFontHighlight")
	editbox:SetWidth(300)
	editbox:SetHeight(20)
  editbox:SetPoint("TOPLEFT", editBoxContainer, "TOPLEFT", 6, -6)
  editbox:SetMaxLetters(255)
  editbox:SetMultiLine(false)
  editbox:SetTextInsets(0, 0, 0, 0)
  editbox:SetCursorPosition(0)
  -- editbox:SetBackdrop(
		-- {bgFile="Interface\\Tooltips\\UI-Tooltip-Background", 
	    -- edgeFile="Interface\\Tooltips\\UI-Tooltip-Border", tile=true,
		-- tileSize=16, edgeSize=16, insets={left=-5, right=1, top=1, bottom=1}})
	editbox:SetBackdropColor(0,0,0,1)
	editbox:SetAutoFocus(true)
	editbox:SetScript("OnShow", function(this) editbox:SetFocus() end)
	editbox:SetScript("OnEnterPressed",
    function(this)
      local frame = this:GetParent()
      local tag = frame.charname:GetText()
      local rating = math.floor(frame.slider:GetValue()+0.5)
      Chitchat:UpdatePersonalNote(tag,tag,frame.editbox:GetText(),rating)
      frame:Hide()
    end)
	editbox:SetScript("OnEscapePressed",
    function(this)
      this:SetText("")
      this:GetParent():Hide()
    end)
  
  local slider = CreateFrame("Slider", 'ChitchatEditFrameSlider', editwindow,'OptionsSliderTemplate')
  slider:ClearAllPoints()
  slider:SetPoint("BOTTOM", charname, "BOTTOM", 0, -40)
  --slider:SetWidth(100)
  --slider:SetHeight(20)
  --slider:SetOrientation('HORIZONTAL')
  slider:SetMinMaxValues(0, 10)
  slider:SetValueStep(1)
  getglobal(slider:GetName() .. 'Low'):SetText('Unrated')
  getglobal(slider:GetName() .. 'High'):SetText('10');
  getglobal(slider:GetName() .. 'Text'):SetText('Rating: ')
  slider:SetScript("OnValueChanged", function(self, value)
    local val = math.floor(value+0.5)
    if val == 0 then
      val = "Unrated"
    end
    getglobal(slider:GetName() .. 'Text'):SetText("Rating: "..val)
  end)
  slider:SetValue(0)
  slider:Show()

	editwindow.charname = charname
	editwindow.editbox = editbox
  --editwindow.rating = rating
  editwindow.slider = slider

  editwindow:SetMovable(true)
  editwindow:RegisterForDrag("LeftButton")
  editwindow:SetScript("OnDragStart",
    function(this,button)
      this:StartMoving()
    end)
  editwindow:SetScript("OnDragStop",
    function(this)
        this:StopMovingOrSizing()
    end)
  editwindow:EnableMouse(true)
	editwindow:Hide()
	return editwindow
end

