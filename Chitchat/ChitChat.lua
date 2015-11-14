Chitchat = LibStub("AceAddon-3.0"):NewAddon("Chitchat", "AceConsole-3.0","AceEvent-3.0", "AceHook-3.0")

Chitchat.LDBIcon = LibStub("LibDBIcon-1.0")
local L = LibStub("AceLocale-3.0"):GetLocale("Chitchat")

--Chitchat.editNoteFrame = nil
-- Whisper Log
Chitchat.INDEX_KEY = "index"
Chitchat.SENDER_KEY = "sender"
Chitchat.MESSAGE_KEY = "message"
Chitchat.TIMESTAMP_KEY = "timestamp"
Chitchat.INCOMING_KEY = "incoming"
Chitchat.ID_KEY = "id"
Chitchat.HIDE_CHAT_KEY = "quiet"
Chitchat.FAVORITE_KEY = "favorite"
-- Message Entry
Chitchat.TAG_KEY = "tag"
Chitchat.MESSAGES_KEY = "messages"
Chitchat.UNREAD_KEY = "unread"
-- Personal Note
Chitchat.NOTE_KEY = "note"
Chitchat.RATING_KEY = "rating"
Chitchat.ROLE_KEY = "role"
Chitchat.CLASS_KEY = "playerclass"
Chitchat.SEEN_KEY = "seen"
Chitchat.ENCOUNTERS_KEY = "encounters"
Chitchat.ENCOUNTERS_TIMESTAMP_KEY = "encounter-timestamp"
-- Encounter
Chitchat.COUNT_KEY = "count"
Chitchat.DESCRIPTION_KEY = "descript"
-- Options
Chitchat.Recording = false
Chitchat.InCombat = false


-- Unused
Chitchat.optionHaveWeMetTooltips = false
Chitchat.optionEncounterTooltips = false
Chitchat.optionEncounterTooltipRecord = false
Chitchat.optionEncounterDungeonFormat = nil
Chitchat.optionEncounterDungeonExtraFormat = nil
Chitchat.optionEncounterRaidFormat = nil
Chitchat.optionEncounterRaidExtraFormat = nil
Chitchat.optionEncounterCheckFrequceny = 1800
Chitchat.optionEncounterAutoCreateNote = true
Chitchat.optionMenuHooks = {  ["PLAYER"] = false,
                              ["TARGET"] = false,
                              ["PARTY"] = false,
                              ["FRIEND"] = false,
                              ["FRIEND_OFFLINE"] = false,
                              ["RAID_PLAYER"] = false }

UnitPopupButtons["CC_EDIT_NOTE"] = {text = "Have we met?", dist = 0, func = Chitchat.EditNoteDropdown}
UnitPopupButtons["CC_ENCOUNTER_INSPECT"] = {text = "Get Encounters", dist = 0, func = Chitchat.DropDownEncounterInspect}

local Options =
{
  name = L["CHITCHAT"],
  handler = Chitchat,
  type = "group",
  args = {
    addon_desc = {
      name = L["OPT_ADDON_DESC"],
      order = 1,
      type = "description",
      width = "full",
    },
    header_general = {
      name = L["OPT_HEADER_GENERAL"],
      order = 2,
      type = "header",
    },
    minimap = {
      name = L["OPT_MINIMAP"],
      desc = L["OPT_MINIMAP_DESC"],
      order = 3,
      type = "toggle",
      width = "full",
      get = "GetMinimap",
      set = "SetMinimap"
    },
    toggle_ui = {
      name = L["OPT_TOGGLE"],
      desc = L["OPT_TOGGLE_DESC"],
      order = 4,
      type = "execute",
      width = "normal",
      func = "ToggleFrame"
    },
    header_record_mode = {
      name = L["OPT_HEADER_RECORD_MODE"],
      order = 5,
      type = "header",
    },
    always_on = {
      name = L["OPT_RECORD_ALWAYS"],
      order = 6,
      type = "toggle",
      width = "normal",
      get = "IsRecordAlways",
      set = "ToggleRecordAlways",
    },
    record_resting = {
      name = L["OPT_RECORD_RESTING"],
      order = 7,
      type = "toggle",
      width = "normal",
      get = "IsRecordResting",
      set = "ToggleRecordResting",
    },
    record_combat = {
      name = L["OPT_RECORD_COMBAT"],
      order = 8,
      type = "toggle",
      width = "normal",
      get = "IsRecordCombat",
      set = "ToggleRecordCombat",
    },
    record_afk = {
      name = L["OPT_RECORD_AFK"],
      order = 9,
      type = "toggle",
      width = "normal",
      get = "IsRecordAfk",
      set = "ToggleRecordAfk",
    },
    record_dnd = {
      name = L["OPT_RECORD_DND"],
      order = 10,
      type = "toggle",
      width = "normal",
      get = "IsRecordDnd",
      set = "ToggleRecordDnd",
    },
    header_recording = {
      name = L["OPT_HEADER_RECORDING"],
      order = 11,
      type = "header",
    },
    notify = {
      name = L["OPT_NOTIFY"],
      order = 12,
      type = "toggle",
      width = "normal",
      get = "CanNotify",
      set = "ToggleNotify",
    },
    silent = {
      name = L["OPT_SILENT"],
      order = 12,
      type = "toggle",
      width = "double",
      get = "IsSilent",
      set = "ToggleSilent",
    },
    hideIncoming = {
      name = L["OPT_HIDE_INCOMING"],
      order = 13,
      type = "toggle",
      width = "double",
      get = "HideIncoming",
      set = "ToggleHideIncoming",
    },
    hideOutgoing = {
      name = L["OPT_HIDE_OUTGOING"],
      order = 13,
      type = "toggle",
      width = "double",
      get = "HideOutgoing",
      set = "ToggleHideOutgoing",
    },
    recordOutgoing = {
      name = L["OPT_RECORD_OUTGOING"],
      order = 14,
      type = "toggle",
      width = "double",
      get = "RecordOutgoing",
      set = "ToggleRecordOutgoing",
    },
    autoRespond = {
      name = L["OPT_AUTO_RESPOND"],
      order = 16,
      type = "toggle",
      width = "double",
      get = "AutoRespond",
      set = "ToggleAutoRespond",
    },
    autoRespondMessage = {
      name = L["OPT_AUTO_RESPOND_MESSAGE"],
      order = 17,
      type = "input",
      disabled = "NotAutoRespond",
      width = "full",
      get = "AutoRespondMessage",
      set = "SetAutoRespondMessage",
    },
    header_channels = {
      name = L["OPT_HEADER_CHANNEL"],
      order = 18,
      type = "header",
    },
    channelTrade = {
      name = L["OPT_CHANNEL_TRADE"],
      order = 19,
      type = "toggle",
      width = "normal",
      get = "ChannelTrade",
      set = "ToggleChannelTrade",
    },
    channelGeneral = {
      name = L["OPT_CHANNEL_GENERAL"],
      order = 20,
      type = "toggle",
      width = "normal",
      get = "ChannelGeneral",
      set = "ToggleChannelGeneral",
    },
    channelGuild = {
      name = L["OPT_CHANNEL_GUILD"],
      order = 21,
      type = "toggle",
      width = "normal",
      get = "ChannelGuild",
      set = "ToggleChannelGuild",
    },
    channelOfficer = {
      name = L["OPT_CHANNEL_OFFICER"],
      order = 22,
      type = "toggle",
      width = "normal",
      get = "ChannelOfficer",
      set = "ToggleChannelOfficer",
    },
    header_other = {
      name = L["OPT_HEADER_OTHER"],
      order = 23,
      type = "header",
    },
    fixCapslock = {
      name = L["OPT_FIX_CAPSLOCK"],
      order = 24,
      type = "toggle",
      width = "normal",
      get = "FixCapslock",
      set = "ToggleFixCapslock",
    }
  }
}

local defaultDB = {
  global = {
    silent = false, -- Run quietly in background
    logs = {}, -- WhisperLog
    notes = {}, -- PersonalNote
    encounters = {}, -- Casual Encounters
    messages = {index = 0}, -- MessageEntry
  },
  profile = {
    minimap = {
      hide = false
    },
    missed = 0,
    unreadColor = {
      r = 1,
      b = 0.5,
      g = 1
    },
    record = {
      always = false,
      resting = false,
      combat = true,
      afk = true,
      dnd = true
    },
    recording = {
      hideIncoming = false,
      hideOutgoing = false,
      recordOutgoing = true,
      notify = true,
      silent = false,
      autoRespond = false,
      autoRespondMessage = L["SETTING_AUTO_RESPOND"]
    },
    channels = {
      trade = false,
      general = false,
      guild = false,
      officer = false
    },
    other = {
      fixCapslock = true
    }
  }
}

local GREEN =  "|cff00ff00"
local YELLOW = "|cffffd517"
local RED =    "|cffff0000"
local BLUE =   "|cff0198e1"
local ORANGE = "|cffff9933"
local WHITE =  "|cffffffff"
local tooltipNoteFormat = YELLOW.."%s "..WHITE.."%s".."|r"
local tooltipNoteDungeonEncounterFormat = YELLOW.."   %s "..WHITE.."%s | "..ORANGE.."%s".."|r"
local tooltipNoteRaidEncounterFormat = WHITE.."   %s "..RED.."(%s) "..WHITE.."%s".."|r"
local defaultIcon = "Interface\\Icons\\INV_Misc_Book_03.blp"
local newMessageIcon = "Interface\\Icons\\INV_Misc_Book_04.blp"
local noteIcon = "Interface\\Icons\\INV_inscription_papyrus"
local iconToChat = "|T%s:12|t"
local noteHyperLink = BLUE.."|Hccnote:%s|h"..iconToChat:format(noteIcon).."|h|r"
local editNoteHyperLink = BLUE.."|Hccedit:%s|h"..iconToChat:format(noteIcon).."|h|r"

local HYPERLINK_REF = format("%s:%s", L["CHITCHAT"], L["VIEW"])
local HYPERLINK = format("|c00FFFF00|H%s|h%s|h|r",HYPERLINK_REF, L["VIEW_MSG"])
local HYPERLINK_CHITCHAT = format("|c00FFFF00|H%s|h%s: |h|r",HYPERLINK_REF, L["CHITCHAT"])

function Chitchat:OnInitialize()
  -- Setup slash commands
  self:RegisterChatCommand("chitchat","CommandHandler")
  self:RegisterChatCommand("cc","CommandHandler")
  -- Load saved database
  Chitchat.db = LibStub("AceDB-3.0"):New("ChitchatDB",defaultDB,true)
  Chitchat.logs = Chitchat.db.global.logs or {}
  Chitchat.messages = Chitchat.db.global.messages or {}
  Chitchat.notes = Chitchat.db.global.notes or {}
  Chitchat.encounters = Chitchat.db.global.encounters or {}

  LibStub("AceConfig-3.0"):RegisterOptionsTable("Chitchat", Options)
  self.optionsFrame = LibStub("AceConfigDialog-3.0"):AddToBlizOptions("Chitchat","Chitchat")

  -- Setup minimap icon
  Chitchat.minimapIcon = LibStub("LibDataBroker-1.1"):NewDataObject("Chitchat", {
    type = "data source",
    text = "CHITCHAT",
    icon = defaultIcon,
    OnClick = function (frame, button)
      Chitchat:ToggleFrame()
    end,
    OnTooltipShow = function (tooltip)
      Chitchat:OnMinimapTooltipShow(tooltip)
    end
  })
  if Chitchat.LDBIcon then
    Chitchat.LDBIcon:Register("Chitchat", Chitchat.minimapIcon,Chitchat.db.profile.minimap)
  end

end

function Chitchat:OnEnable()
  if Chitchat.db.profile.record.always then
    Chitchat:StartRecording()
  end
  if Chitchat.db.profile.record.resting and IsResting() then
    Chitchat:StartRecording()
  end
  if Chitchat.db.profile.record.dnd and UnitIsDND("player") then
    Chitchat:StartRecording()
  end
  if Chitchat.db.profile.record.afk and UnitIsAFK("player") then
    Chitchat:StartRecording()
  end


  -- Register Events
  self:RegisterEvent("CHAT_MSG_WHISPER", "OnEventWhisperIncoming")
  self:RegisterEvent("CHAT_MSG_WHISPER_INFORM","OnEventWhisperOutgoing")
  self:RegisterEvent("CHAT_MSG_BN_WHISPER","OnEventBnetWhisperIncoming")
  self:RegisterEvent("CHAT_MSG_BN_WHISPER_INFORM","OnEventBnetWhisperOutgoing")
  self:RegisterEvent("CHAT_MSG_CHANNEL","OnEventChannelChatMessage")
  ChatFrame_AddMessageEventFilter("CHAT_MSG_WHISPER", Chitchat_FilterWhisperMessages)
  ChatFrame_AddMessageEventFilter("CHAT_MSG_WHISPER_INFORM", Chitchat_FilterWhisperMessagesOutgoing)
  ChatFrame_AddMessageEventFilter("CHAT_MSG_CHANNEL", Chitchat_FilterChannelMessages)
  ChatFrame_AddMessageEventFilter("CHAT_MSG_GUILD", Chitchat_FilterChannelMessages)

  if Chitchat.db.profile.record.resting then
    self:RegisterEvent("PLAYER_UPDATE_RESTING", "OnEventUpdateResting")
  end
  if Chitchat.db.profile.record.combat then
    self:RegisterEvent("PLAYER_REGEN_DISABLED", "OnEventCombatStart")
    self:RegisterEvent("PLAYER_REGEN_ENABLED", "OnEventCombatEnd")
  end
  if Chitchat.db.profile.record.afk or Chitchat.db.profile.record.dnd then
    self:RegisterEvent("PLAYER_FLAGS_CHANGED", "OnEventFlagsChange")
  end
  if Chitchat.db.profile.channels.guild then
    self:RegisterEvent("CHAT_MSG_GUILD","OnEventChannelGuild")
  end
  if Chitchat.db.profile.channels.officer then
    self:RegisterEvent("CHAT_MSG_OFFICER","OnEventChannelOfficer")
  end

  -- for menu, enabled in pairs(self.optionMenuHooks) do
  --   if menu and enabled then
  --     tinsert(UnitPopupMenus[menu], #UnitPopupMenus[menu], "CC_EDIT_NOTE")
  --     tinsert(UnitPopupMenus[menu], #UnitPopupMenus[menu], "CC_ENCOUNTER_INSPECT")
  --   end
  -- end
  -- self:SecureHook("UnitPopup_ShowMenu")
  -- self:HookScript(GameTooltip, "OnTooltipSetUnit")
  self:RawHook(nil, "SetItemRef", true)
end

function Chitchat:OnDisable()
  Chitchat:StopRecording()
  -- Halt mod completely, and enter standby mode.
  self:UnregisterEvent("CHAT_MSG_WHISPER", "OnEventWhisperIncoming")
  self:UnregisterEvent("CHAT_MSG_WHISPER_INFORM","OnEventWhisperOutgoing")
  self:UnregisterEvent("CHAT_MSG_BN_WHISPER","OnEventBnetWhisperIncoming")
  self:UnregisterEvent("CHAT_MSG_BN_WHISPER_INFORM","OnEventBnetWhisperOutgoing")
  self:UnregisterEvent("CHAT_MSG_CHANNEL","OnEventChannelChatMessage")
  ChatFrame_RemoveMessageEventFilter("CHAT_MSG_WHISPER", Chitchat_FilterWhisperMessages)
  ChatFrame_RemoveMessageEventFilter("CHAT_MSG_WHISPER_INFORM", Chitchat_FilterWhisperMessagesOutgoing)
  ChatFrame_RemoveMessageEventFilter("CHAT_MSG_CHANNEL", Chitchat_FilterChannelMessages)
  ChatFrame_RemoveMessageEventFilter("CHAT_MSG_GUILD", Chitchat_FilterChannelMessages)

  if Chitchat.db.profile.record.resting then
    self:UnregisterEvent("PLAYER_UPDATE_RESTING", "OnEventUpdateResting")
  end
  if Chitchat.db.profile.record.combat then
    self:UnregisterEvent("PLAYER_REGEN_DISABLED", "OnEventCombatStart")
    self:UnregisterEvent("PLAYER_REGEN_ENABLED", "OnEventCombatEnd")
  end
  if Chitchat.db.profile.record.afk or Chitchat.db.profile.record.dnd then
    self:UnregisterEvent("PLAYER_FLAGS_CHANGED", "OnEventFlagsChange")
  end

  if Chitchat.db.profile.channels.guild then
    self:UnregisterEvent("CHAT_MSG_GUILD","OnEventChannelGuild")
  end
  if Chitchat.db.profile.channels.officer then
    self:UnregisterEvent("CHAT_MSG_OFFICER","OnEventChannelOfficer")
  end
end

function Chitchat:Debug(s, ...)
	if Chitchat.db.global.silent then self:Print(format("[Debug] "..s, ...)) end
end

function Chitchat:CommandHandler(input)
  local cmd = strlower(input)
	if cmd == "debug" then
		if Chitchat.db.global.silent then
			Chitchat.db.global.silent = false
			self:Print("Debug mode OFF")
		else
			Chitchat.db.global.silent = true
			self:Print("Debug mode ON")
		end
  elseif cmd == "test" then
    self:Print("Faking a whisper.")
    Chitchat:FakeWhisper(math.random(0,1))
	else
		self:ToggleFrame()
	end
end

function Chitchat:ToggleFrame()
  if ChitchatParent:IsShown() then
    HideUIPanel(ChitchatParent)
  else
    ShowUIPanel(ChitchatParent)
    Chitchat.minimapIcon.icon = defaultIcon
  end
end

function Chitchat:OnMinimapTooltipShow(tooltip)
  tooltip:AddLine(L["CHITCHAT"])
  if Chitchat.Recording then
    tooltip:AddLine(L["RECORDING_ON"])
  else
    tooltip:AddLine(L["RECORDING_OFF"])
  end
  if (Chitchat.db.profile.missed > 0) then
    local m = L["MISSED_MSG_LAST_PLURAL"]
    if Chitchat.db.profile.missed == 1 then
      m = L["MISSED_MSG_LAST_SINGULAR"]
    end
		tooltip:AddLine(L["MISSED_MSG_FIRST"] .. Chitchat_UnreadColorHex() ..  Chitchat.db.profile.missed .. "|r" .. m)
	end
end

-- UnreadColorHex
-- Returns the unread color hex formatted
function Chitchat_UnreadColorHex()
	local unreadColor = format("|cff%02x%02x%02x",Chitchat.db.profile.unreadColor.r*255,Chitchat.db.profile.unreadColor.g*255,Chitchat.db.profile.unreadColor.b*255)
	return unreadColor
end

function Chitchat:StartRecording()
  if(not Chitchat.Recording) then
    Chitchat.Recording = true
    if not Chitchat:IsSilent() then
      DEFAULT_CHAT_FRAME:AddMessage(HYPERLINK_CHITCHAT .. L["RECORDING_START"], Chitchat.db.profile.unreadColor.r, Chitchat.db.profile.unreadColor.g, Chitchat.db.profile.unreadColor.b);
    end
  end
end

-- TODO Add stop recording checks here and rename to StopSoftRecording
function Chitchat:StopRecording()
  if (Chitchat.Recording) then
    Chitchat.Recording = false
    if (not Chitchat.db.profile.record.always) then
      if not Chitchat:IsSilent() then
        DEFAULT_CHAT_FRAME:AddMessage(HYPERLINK_CHITCHAT .. L["RECORDING_STOP"], Chitchat.db.profile.unreadColor.r, Chitchat.db.profile.unreadColor.g, Chitchat.db.profile.unreadColor.b);
      end
      Chitchat:RelayMissed()
    end
  end
end

function Chitchat:RelayMissed()
  if (Chitchat.db.profile.recording.notify and Chitchat.db.profile.missed > 0) then
    local m = L["MISSED_MSG_LAST_SINGULAR"]
    if (Chitchat.db.profile.missed > 1) then
      m = L["MISSED_MSG_LAST_PLURAL"]
    end
    DEFAULT_CHAT_FRAME:AddMessage(HYPERLINK_CHITCHAT .. L["MISSED_MSG_FIRST"] .. Chitchat.db.profile.missed .. m .. HYPERLINK, Chitchat.db.profile.unreadColor.r, Chitchat.db.profile.unreadColor.g, Chitchat.db.profile.unreadColor.b);
  end
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
  local record = false
  if Chitchat.db.profile.channels.trade and string.find(channelName,L["TRADE_STRING"]) ~= nil then
    record = true
  elseif Chitchat.db.profile.channels.general and string.find(channelName,L["GENERAL_STRING"]) ~= nil then
    record = true
  end
  if record then
    Chitchat:HandleChatMessage(channelName,sender,message,time())
  end
 end
function Chitchat:OnEventChannelGuild(self, message, sender, lang, channelString, target, flags, arg7, channelNumber, channelName, arg10, counter, guid)
  local ginfo = GetGuildInfo("player")
  Chitchat:HandleChatMessage(ginfo,sender,message,time())
end
function Chitchat:OnEventChannelOfficer(self, message, sender, lang, channelString, target, flags, arg7, channelNumber, channelName, arg10, counter, guid)
  local ginfo = GetGuildInfo("player")
  Chitchat:HandleChatMessage(ginfo.." Officer",sender,message,time())
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

-- Handle Resting Changes
function Chitchat:OnEventUpdateResting(self)
  if Chitchat.db.profile.record.resting and IsResting() then
    Chitchat:StartRecording()
  else
    local preventChange = Chitchat.db.profile.record.always
    if Chitchat.db.profile.record.dnd and UnitIsDND("player") then
      preventChange = true
    end
    if Chitchat.db.profile.record.afk and UnitIsAFK("player") then
      preventChange = true
    end
    if not preventChange then
      Chitchat:StopRecording()
    end
  end
end
-- Handle Combat Start
function Chitchat:OnEventCombatStart(self)
  Chitchat:StartRecording()
  Chitchat.InCombat = true
end
-- Handle Combat End
function Chitchat:OnEventCombatEnd(self)
  local preventChange = Chitchat.db.profile.record.always
  if Chitchat.db.profile.record.dnd and UnitIsDND("player") then
    preventChange = true
  end
  if Chitchat.db.profile.record.afk and UnitIsAFK("player") then
    preventChange = true
  end
  if not preventChange then
    Chitchat:StopRecording()
  end
  Chitchat.InCombat = false
end
function Chitchat:OnEventFlagsChange(self, unitid)
  local preventChange = Chitchat.db.profile.record.always
  if Chitchat.db.profile.record.resting and IsResting("player") then
    preventChange = true
  end
  if Chitchat.db.profile.record.combat and Chitchat.InCombat then
    preventChange = true
  end

  if Chitchat.db.profile.record.dnd and UnitIsDND("player") then
    Chitchat:StartRecording()
  elseif Chitchat.db.profile.record.afk and UnitIsAFK("player") then
    Chitchat:StartRecording()
  elseif not preventChange then
    Chitchat:StopRecording()
  end
end

-- Filter to halt whisper messages from on-screen
function Chitchat_FilterWhisperMessages(self,event,message, sender, ...)
  local whisper_log = Chitchat:GetLog(sender)
  if whisper_log ~= nil and whisper_log[self.HIDE_CHAT_KEY] == true then
    return true, "", "", ...
  end
  if Chitchat.Recording and Chitchat.db.profile.recording.hideIncoming then
    return true, "", "", ...
  end
  return false, message, sender, ...
end
-- Filter to halt whisper messages from on-screen
function Chitchat_FilterWhisperMessagesOutgoing(self,event,message, sender, ...)
  local whisper_log = Chitchat:GetLog(sender)
  if whisper_log ~= nil and whisper_log[self.HIDE_CHAT_KEY] == true then
    return true, "", "", ...
  end
  if Chitchat.Recording and Chitchat.db.profile.recording.hideOutgoing then
    return true, "", "", ...
  end
  return false, message, sender, ...
end

-- CAPS LOCK KILLER
function Chitchat_FilterChannelMessages(self,event,message,sender, ...)
  if Chitchat.db.profile.other.fixCapslock then
    local message_upper = message:upper()
    if message_upper == message then
      message = message:lower():gsub("^%l", string.upper) -- Lowers message then capitalize first letter
    end
  end
  if Chitchat:GetNote(sender) ~= nil then
    message = Chitchat:RolesToString(sender)..""..noteHyperLink:format(sender).." "..message
  end
  return false, message, sender, ...
end

function Chitchat:RolesToString(sender)
  local roles_note = ""
  local pnote = self:GetNote(sender)
  if pnote ~= nil then
    local roles = pnote[self.ROLE_KEY]

    if self:IsTankRole(roles) then
      roles_note = roles_note..""..INLINE_TANK_ICON
    end
    if self:IsHealerRole(roles) then
      roles_note = roles_note..""..INLINE_HEALER_ICON
    end
    if self:IsDamagerRole(roles) then
      roles_note = roles_note..""..INLINE_DAMAGER_ICON
    end
  end
  return roles_note
end

local SetHyperlink = ItemRefTooltip.SetHyperlink
function ItemRefTooltip:SetHyperlink(link)
  local linkType, player_tag = strsplit(":", link)
  if linkType == "ccnote" then
    Chitchat:ShowNoteTooltip(player_tag)
  elseif linkType == "ccedit" then
    Chitchat:ShowPersonalNoteFrame(player_tag)
  else
    SetHyperlink(self, link)
  end
end

function Chitchat:HandleBNWhisper(presenceID,message,timestamp,incoming)
  local index = BNGetFriendIndex(presenceID)
  local _, _, _, _, toonName = BNGetFriendInfo(index)
  self:HandleWhisper(toonName,message,timestamp,incoming)
end
local respondDelay = 0
-- Locates the Entry by looking up the assigned tag.
-- Create a whisper and add the id to the entries's whisper table.
function Chitchat:HandleWhisper(tag, message, timestamp, incoming)
  -- Escape if not recording
  if not Chitchat.Recording then
    return
  end

  -- Escape if not recording outgoing messages
  if not Chitchat.db.profile.recording.recordOutgoing and incoming == 0 then
    return
  end

  if Chitchat.db.profile.recording.autoRespond and incoming == 1 and respondDelay ~= time() then
    if not Chitchat.db.profile.record.always then
      SendChatMessage(L["CHITCHAT"] .. ": " ..Chitchat.db.profile.recording.autoRespondMessage , "WHISPER", nil, tag);
      respondDelay = time()
    end
  end

  local message_entry = Chitchat:CreateMessageEntry(tag, message, timestamp, incoming)[self.ID_KEY]
  local whisper_log = Chitchat:FindOrCreateWhisperLog(tag)
  if whisper_log == nil then
    error("HandleWhisper: Unable to find or create a whisper log.",2)
  end
  if whisper_log.messages == nil then
    whisper_log.messages = {}
  end
  tinsert(whisper_log.messages, message_entry)
  if incoming == 1 then
    if not Chitchat.db.profile.record.always then
      Chitchat.db.profile.missed = Chitchat.db.profile.missed + 1
      whisper_log[self.UNREAD_KEY] = whisper_log[self.UNREAD_KEY] + 1
      Chitchat.minimapIcon.icon = newMessageIcon
    end
  end
  self:SendMessage("CHITCHAT_LOG_UPDATED", whisper_log[self.TAG_KEY])
end

function Chitchat:HandleChatMessage(channel,tag,message,timestamp)
  if channel == nil or channel == '' then return end
  local message_entry = Chitchat:CreateMessageEntry(tag, message, timestamp, 2)[self.ID_KEY]
  local chat_log = Chitchat:FindOrCreateWhisperLog(channel)
  if chat_log == nil then
    error("HandleChatMessage: Unable to find or create a chat log.",2)
  end
  if chat_log.messages == nil then
    chat_log.messages = {}
  end
  tinsert(chat_log.messages, message_entry)
  self:SendMessage("CHITCHAT_LOG_UPDATED", chat_log[self.TAG_KEY])
end

function Chitchat:SetItemRef(link, text, button)
	if (link == HYPERLINK_REF) then
		if(button == "LeftButton") then
			Chitchat:ToggleFrame()
		elseif(button == "RightButton") then
			InterfaceOptionsFrame_OpenToCategory("Chitchat")
		end
		return nil
	end
	return self.hooks.SetItemRef(link, text, button)
end

----------------------------------------------------------------------------
-- HAVE WE MET
----------------------------------------------------------------------------
function Chitchat:OnTooltipSetUnit(tooltip, ...)
  --if Chitchat.db.global.tooltipNotes == false then return end
  local name, unitid = tooltip:GetUnit()
  local showExpandedTooltip = IsShiftKeyDown()

-- If the unit exists and is a player then check if there is a note for it.
  if UnitExists(unitid) and UnitIsPlayer(unitid) then
    local name, realm = UnitName(unitid)
    if realm == nil then
      realm = GetRealmName()
    end
    local tag = name.."-"..realm
    local personal_note = Chitchat:GetNote(tag)
    if personal_note ~= nil then
      if self.optionHaveWeMetTooltips then
        self:TooltipHaveWeMet(tooltip,personal_note,showExpandedTooltip)
      end
      if self.optionEncounterTooltips then
        self:TooltipEncounters(tooltip,personal_note,showExpandedTooltip)
      end
      if self.optionEncounterTooltipRecord then
        Chitchat:DoEncounterInspect(unitid, tag, nil, false)
      end
    end
  end
end

function Chitchat:ShowNoteTooltip(tag)
  local personal_note = self:GetNote(tag)
  if personal_note == nil then return end
  local encounter_timestamp = personal_note[self.ENCOUNTERS_TIMESTAMP_KEY]

  ShowUIPanel(ItemRefTooltip)
  if (not ItemRefTooltip:IsVisible()) then
    ItemRefTooltip:SetOwner(UIParent, "ANCHOR_PRESERVE")
  end
  ItemRefTooltip:ClearLines()
  local name, server = strsplit('-',tag)
  local classType = personal_note[self.CLASS_KEY]
  -- Begin Have we Met Not area
  ItemRefTooltip:AddDoubleLine(YELLOW..name,classType)
  ItemRefTooltip:AddLine(WHITE..server)
  self:TooltipHaveWeMet(ItemRefTooltip,personal_note,true)
  self:TooltipEncounterDungeon(ItemRefTooltip,tag,self.WOD_DUNGEON_ZONES)
  self:TooltipEncounterRaid(ItemRefTooltip,tag, self.WOD_RAID_ZONES, {"Raid Finder","Normal","Heroic","Mythic"})
  ItemRefTooltip:AddDoubleLine(YELLOW.."Encounters Updated at|r", date("%m/%d/%y %H:%M:%S", encounter_timestamp),1,1,1,1,1,1)
  ItemRefTooltip:Show()
  ItemRefTooltip:Show()
end

function Chitchat:TooltipHaveWeMet(tooltip, personal_note, showExpandedTooltip)
  if personal_note == nil then return end
  local note = personal_note[self.NOTE_KEY]
  local rating = personal_note[self.RATING_KEY]
  local roleNumber = personal_note[self.ROLE_KEY]
  local seen_info = personal_note[self.SEEN_KEY]
  local roleString = ""
  if self:IsTankRole(roleNumber) then
    roleString = roleString..""..INLINE_TANK_ICON
  end
  if self:IsHealerRole(roleNumber) then
    roleString = roleString..""..INLINE_HEALER_ICON
  end
  if self:IsDamagerRole(roleNumber) then
    roleString = roleString..""..INLINE_DAMAGER_ICON
  end
  if type(rating) == "number" or rating > 0 then
    tooltip:AddDoubleLine(YELLOW.."Rated "..WHITE..rating,roleString,1,1,1,1,1,1)
  end

  if note ~= nil and note ~= "" then
    if not showExpandedTooltip then
      note = note
    end
    tooltip:AddLine(YELLOW.."Note "..WHITE..note,1,1,1,1,true)
  end
  if seen_info ~= nil then
    local index = #seen_info-1
    if index > 1 then
      tooltip:AddDoubleLine(YELLOW.."Last Seen|r",date("%m/%d/%y %H:%M:%S", seen_info[#seen_info]))
    end
  end
end

function Chitchat:TooltipEncounters(tooltip, personal_note, showExpandedTooltip)
  local inInstance = false --, instanceType = IsInInstance()
  local encounters = personal_note[self.ENCOUNTERS_KEY]
  local encounter_timestamp = personal_note[self.ENCOUNTERS_TIMESTAMP_KEY]
  local tag = personal_note[self.TAG_KEY]

  if encounters == nil then
    if showExpandedTooltip then
      tooltip:AddLine(tooltipNoteFormat:format("Encounters: ","None found."),1, 1, 1, false)
      tooltip:AddDoubleLine(YELLOW.."Encounters Updated at|r", date("%m/%d/%y %H:%M:%S", encounter_timestamp),1,1,1,1,1,1)
      return
    end
  end
  if inInstance then
    local name, _, _, difficulty, _, _, _, _ =GetInstanceInfo() -- Normal Heroic Mythic Raid Finder
    if instanceType == "party" then
      local instances = { name }
      if showExpandedTooltip then instances = self.WOD_DUNGEON_ZONES end
      self:TooltipEncounterDungeon(tooltip, tag, instances)
    elseif instanceType == "raid" then
      local instances = { name } -- nil?
      local difficulties = { difficulty }
      if showExpandedTooltip then
        instances = self.WOD_RAID_ZONES
        difficulties = { "Raid Finder","Normal","Heroic","Mythic" }
      end
      self:TooltipEncounterRaid(tooltip, tag, instances, difficulties)
    end
  else
    if showExpandedTooltip then
      self:TooltipEncounterDungeon(tooltip, tag, self.WOD_DUNGEON_ZONES)
      self:TooltipEncounterRaid(tooltip, tag, self.WOD_RAID_ZONES,{"Raid Finder","Normal","Heroic","Mythic"})
      tooltip:AddDoubleLine(YELLOW.."Encounters Updated at|r", date("%m/%d/%y %H:%M:%S", encounter_timestamp),1,1,1,1,1,1)
    end
  end
end
-- Dungeon Name [N|H]
function Chitchat:TooltipEncounterDungeon(tooltip, tag, instances)
  local i, zone
  --tooltip:AddLine(tooltipNoteFormat:format('Dungeons',''),1, 1, 1, false)
  tooltip:AddDoubleLine(YELLOW.."Dungeons|r", GREEN.."N"..WHITE..' | '..ORANGE.."H|r",1,1,1,1,1,1)
  for i, zone in ipairs(instances) do
    local nk, hk = self:GetEncounterDungeonKills(tag,zone)
    local colorNk = GREEN
    local colorHk = ORANGE
    if tostring(nk) == "0" then colorNk = RED end
    if tostring(hk) == "0" then colorHk = RED end
    tooltip:AddDoubleLine(WHITE..'  '..zone.."|r", colorNk..nk..WHITE..' | '..colorHk..hk.."|r",1,1,1,1,1,1)
  end
end
-- Raid Name (Difficulty) [9|8|7|6|5|4|3|2|1]
function Chitchat:TooltipEncounterRaid(tooltip, tag, instances, difficulties)
  local i, zone, doesRaiding
  tooltip:AddLine(tooltipNoteFormat:format('Raids',''),1, 1, 1, false)
  for i, zone in ipairs(instances) do
    for i, difficulty in ipairs(difficulties) do
      local kills, valid = self:GetEncounterRaidKills(tag, zone, difficulty)
      if valid then
        doesRaiding = true
        local kill_string = ""
        for i, kill in ipairs(kills) do
          local color = RED
          if tostring(kill) ~= "0" then color = GREEN end
          kill_string = kill_string..color..tostring(kill)
          if i ~= #kills then
            kill_string = kill_string..WHITE.." | "
          end
        end
        tooltip:AddDoubleLine(WHITE..'  '..zone.." "..ORANGE..difficulty.." |r", kill_string.."|r",1,1,1,1,1,1)
      end
    end
  end
  if not doesRaiding then
    tooltip:AddLine(tooltipNoteFormat:format('','None found.'),1, 1, 1, false)
  end
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
    if not string.match(tag, "-") then
      tag = tag.."-"..GetRealmName()
    else
      local name, server = strsplit("-", tag)
      if server == nil then
        tag = name.."-"..GetRealmName()
      end
    end

    self:ShowPersonalNoteFrame(tag)
  end
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
      self:UpdatePersonalNote(guid,nil,nil,role,p_class,true)
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
