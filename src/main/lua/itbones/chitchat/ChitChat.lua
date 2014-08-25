Chitchat = LibStub("AceAddon-3.0"):NewAddon("Chitchat", "AceConsole-3.0","AceEvent-3.0")
ModTestData = {}

-- Minimap Icon
local minimap = LibStub("LibDBIcon-1.0");

local iconDb = {
  profile = {
    minimap = {
      hide = false
    }
  }
}

function Chitchat:OnInitialize()
  -- Called when the addon is first initalized
  self:Print("OnInitialize")

  -- Load saved database
  initDatabase()

  -- Setup slash commands
  self:RegisterChatCommand("chitchat","CommandHandler")

  -- Setup minimap icon
  initMinimap()

  --self:InitializeFrame()
end

function Chitchat:OnEnable()
  -- Called when the addon is enabled, just before running
  self:Print("OnEnable")

  -- Register Events
  self:RegisterEvent("CHAT_MSG_WHISPER", "OnEventWhisperIncoming")
  self:RegisterEvent("CHAT_MSG_WHISPER_INFORM","OnEventWhisperOutgoing")

  -- Register Hooks

  -- Create Frames

  -- Finalize Addon
end

function Chitchat:OnDisable()
  self:Print("OnDisable")
  -- Called when the addon is disabled

  -- Halt mod completely, and enter standby mode.
  self:UnregisterEvent("CHAT_MSG_WHISPER", "OnEventWhisperIncoming")
  self:UnregisterEvent("CHAT_MSG_WHISPER_INFORM","OnEventWhisperOutgoing")
end

function initDatabase()
  Chitchat.logs = {} --LibStub("AceDB-3.0"):New("ChitchatDB",{}, "Default", "factionrealm")
  Chitchat.whispers = {}
  Chitchat.tags = {}
end

function initMinimap()
  Chitchat.iconDb = LibStub("AceDB-3.0"):New("Chitchat",iconDb, "Default", "factionrealm")
  Chitchat.iconObject = LibStub("LibDataBroker-1.1"):NewDataObject("Chitchat", {
    type = "data source",
    text = "CHITCHAT",
    icon = "Interface\\Icons\\INV_Misc_EngGizmos_13.blp",
    OnClick = function (frame, button)
      Chitchat:ToggleFrame()
    end,
    OnTooltipShow = function (tooltip)
      Chitchat:OnTooltipShow(tooltip)
    end
  })

  minimap:Register("Chitchat", Chitchat.iconObject,Chitchat.iconDb.minimap)
end
function Chitchat:OnTooltipShow (tooltip)
  tooltip:AddLine("Chitchat")
end

function enableDatabase()
  -- Init DB
  self.logs = {}
end

function Chitchat:CommandHandler(input)
  -- self:ToggleFrame()
  Chitchat:FakeWhisper(math.random(0,1))
end

function Chitchat:ToggleFrame()
  self:Print("ToggleFrame")
  if ChitchatFrame:IsShown() then
    HideUIPanel(ChitchatFrame)
  else
    ShowUIPanel(ChitchatFrame)
  end
end

-- Returns the ordered array of the whisper logs
function Chitchat:GetLogs()
  return self.logs
end
-- Returns the ordered array of the whisper entries
function Chitchat:GetWhispers()
  return self.whispers
end
-- Returns the ordered array of the tags
function Chitchat:GetTags()
  return self.tags
end

-- Generate a Fake Whisper for Testing.
-- incoming: 0 or 1. determines if message is sent or recieved.
function Chitchat:FakeWhisper(incoming)
  local rnd = math.random(10000,99999)
  local guid = "9x099000000"..rnd
  local sender = "P"..rnd.."-Server"..rnd
  local message = "Lorem ipsum dolor sit amet, consectetur adipiscing elit. Vestibulum ultricies nisi ligula, ac finibus nulla aliquet et. Suspendisse porttitor consectetur massa, ac ultrices eros ultricies quis. Nullam in magna luctus, rutrum ligula sit amet."
  Chitchat:HandleWhisper(guid, sender, message, time(), incoming)
end
-- Handle Incoming WoW Whispers
function Chitchat:OnEventWhisperIncoming(self, message, sender, lang, channelString, target, flags, arg7, channelNumber, channelName, arg10, counter, guid)
  Chitchat:HandleWhisper(guid, sender, message, time(), 1)
  -- Chitchat:Print("Incoming Message "..message.." from "..sender.." with guid "..guid)
  -- -- Verify/Create WhisperEntry for Player
  -- local wLog = Chitchat.logs[guid]
  -- if wLog == nil then
    -- wLog = Chitchat:NewWhisperLog(guid, sender, "WOW")
  -- end
  -- local wEntry = Chitchat:NewWhisperEntry(guid, 1, message)
  -- tinsert(wLog.messages, 1, wEntry)
end
-- Handle Outgoing WoW Whispers
function Chitchat:OnEventWhisperOutgoing(self, message, sender, lang, channelString, target, flags, arg7, channelNumber, channelName, arg10, counter, guid)
  Chitchat:HandleWhisper(guid, sender, message, time(), 0)
end

-- Locates the Entry by looking up the assigned tag.
-- Create a whisper and add the id to the entries's whisper table.
function Chitchat:HandleWhisper(guid, sender, message, timestamp, incoming)
  Chitchat:Print("HandleWhisper: guid:"..guid..", sender:"..sender..", message:"..message..", timestamp:"..timestamp..", incoming:"..incoming)
  
  -- Create a Whisper Entry and return id. id = table.getn(Chitchat.whispers)
  local whisper_id = Chitchat:WhisperEntryCreate(message, timestamp, incoming)
  -- Get reference to whisper log
  local whisper_log = Chitchat:WhisperLogFindOrCreate(guid, sender)
  if whisper_log == nil then
    error("HandleWhisper: Unable to find or create a whisper log.",2)
  end
  
  -- Add whisper_id to the whisper log
  tinsert(whisper_log.whispers, whisper_id)
  -- Send an AceEvent stating a new whisper was recorded
  self:SendMessage("CHITCHAT_WHISPER_LOG_UPDATED", guid, sender, message, timestamp, incoming)
end

-- Locates Log for guid or creates it if does not already exist
function Chitchat:WhisperLogFindOrCreate(guid, sender)
  -- Retrieve log id
  local log_id = Chitchat.tags[guid]
  if log_id == nil then
    -- There is no tag link for a log, create one.
    -- TODO Iterate through Chitchat.logs to ensure the guid does not already exist
    --      Chitchat.tags is a only cached table.
    log_id = Chitchat:WhisperLogCreate(guid, sender)
    self.tags[guid] = log_id
  end
  
  return Chitchat.logs[log_id]
end


WhisperLog = {}
WhisperLog.__index = WhisperLog
-- All WhisperLogs are stored as Chitchat.logs. Logs are an array
function Chitchat:WhisperLogCreate(guid, sender)
  local whisper_log = {}

  if type(guid)~="string" then
    error(("WhisperLogCreate: 'guid' - string expected got '%s'."):format(type(guid)),2)
  end
  if type(sender)~="string" then
    error(("WhisperLogCreate: 'sender' - string expected got '%s'."):format(type(sender)),2)
  end
  if self.tags[guid] then
    error(("WhisperLogCreate: 'guid' - '%s' already exists."):format(guid),2)
  end
  
  setmetatable(whisper_log,WhisperLog)
  tinsert(self.logs, whisper_log)
  whisper_log.label = sender
  whisper_log.tags = { guid }
  whisper_log.whispers = {}
  
  self:Print("Created Log for "..whisper_log.tags[1].." displayed as "..whisper_log.label)
  self:SendMessage("CHITCHAT_WHISPER_LOG_CREATED", guid, sender)
  
  return table.getn(self.logs)
end
function WhisperLog:GetLabel()
  return self.label
end
function WhisperLog:GetTags()
  return self.tags
end
function WhisperLog:GetWhispers()
  return self.whispers
end

-- WHISPER_ENTRY # is a single whisper.
WhisperEntry = {}
WhisperEntry.__index = WhisperEntry
-- All entries are stored in an array and referenced by Chitchat.logs
function Chitchat:WhisperEntryCreate(message, timestamp, incoming)
  local unread = 1
  local whisper_entry = {}

  if type(message)~="string" then
    error(("NewWhisperEntry: 'message' - string expected got '%s'."):format(type(message)),2)
  end

  setmetatable(whisper_entry, WhisperEntry)
  tinsert(self.whispers,whisper_entry)
  whisper_entry.message = message
  whisper_entry.timestamp = timestamp
  whisper_entry.incoming = incoming
  whisper_entry.unread = unread
  
  --Chitchat:Print("Created Entry for "..uid.." AS unread:"..wentry.unread..", incoming:"..wentry.incoming..", timestamp:"..wentry.timestamp..", message:'"..wentry.message.."'.")
  self:SendMessage("CHITCHAT_WHISPER_ENTRY_CREATED", message, timestamp, incoming)
  
  return table.getn(Chitchat.whispers)
end
function WhisperEntry:GetMessage()
  return self.message
end
function WhisperEntry:GetTimestamp()
  return self.timestamp
end
function WhisperEntry:IsIncoming()
  return self.incoming == 1
end
function WhisperEntry:IsUnread()
  return self.unread == 1
end
