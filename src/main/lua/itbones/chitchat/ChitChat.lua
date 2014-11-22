Chitchat = LibStub("AceAddon-3.0"):NewAddon("Chitchat", "AceConsole-3.0","AceEvent-3.0")

local defaultDB = {
  global = {
    logs = {},
    whispers = {},
    tags = {}
  },
  profile = {
    silent = false,
    minimap = {
      hide = false
    }
  }
}

function Chitchat:OnInitialize()
  -- Called when the addon is first initalized
  self:Print("OnInitialize")

  -- Setup slash commands
  self:RegisterChatCommand("chitchat","CommandHandler")
  
  -- Load saved database
  initDatabase()

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
  Chitchat.db = LibStub("AceDB-3.0"):New("ChitchatDB",defaultDB)
  Chitchat.logs = Chitchat.db.global.logs
  Chitchat.whispers = Chitchat.db.global.whispers
  Chitchat.tags = Chitchat.db.global.tags -- This should be created from logs["guid"] to save storage space
  setupMetatable(Chitchat.logs,WhisperLog)
  setupMetatable(Chitchat.whispers,WhisperEntry)
end

function setupMetatable(array, meta)
  for index, value in ipairs(array) do
    setmetatable(value, meta)
  end
end

function initMinimap()
  -- Chitchat.iconDb = LibStub("AceDB-3.0"):New("Chitchat",iconDb, "Default", "factionrealm")
  Chitchat.iconObject = LibStub("LibDataBroker-1.1"):NewDataObject("Chitchat", {
    type = "data source",
    text = "CHITCHAT",
    icon = "Interface\\Icons\\INV_Misc_EngGizmos_13.blp",
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
    LDBIcon:Register("Chitchat", Chitchat.iconObject,Chitchat.db.profile.minimap)
  end
end
function Chitchat:OnTooltipShow (tooltip)
  tooltip:AddLine("Chitchat")
end

function Chitchat:CommandHandler(input)
  -- self:ToggleFrame()
  Chitchat:FakeWhisper(math.random(0,1))
end

function Chitchat:ToggleFrame()
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
local TEST_STRING = "Lorem ipsum dolor sit amet, consectetur adipiscing elit. Vestibulum ultricies nisi ligula, ac finibus nulla aliquet et. Suspendisse porttitor consectetur massa, ac ultrices eros ultricies quis. Nullam in magna luctus, rutrum ligula sit amet."
function Chitchat:FakeWhisper(incoming)
  local rnd = 00001 --math.random(10000,99999)
  local guid = "9x099000000"..rnd
  local sender = "P"..rnd.."-Server"..rnd
  local message = strsub(TEST_STRING,0,math.random(11, strlen(TEST_STRING)))
  Chitchat:HandleWhisper(guid, sender, message, time(), incoming)
end
-- Handle Incoming WoW Whispers
function Chitchat:OnEventWhisperIncoming(self, message, sender, lang, channelString, target, flags, arg7, channelNumber, channelName, arg10, counter, guid)
  Chitchat:HandleWhisper(guid, sender, message, time(), 1)
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
  local whisper_id = Chitchat:WhisperEntryCreate(sender, message, timestamp, incoming)
  -- Get reference to whisper log
  local whisper_log = Chitchat:WhisperLogFindOrCreate(guid, sender)
  if whisper_log == nil then
    error("HandleWhisper: Unable to find or create a whisper log.",2)
  end
  
  -- Add whisper_id to the whisper log
  tinsert(whisper_log.whispers, whisper_id)
  whisper_log:SetUnread()
  -- Send an AceEvent stating a new whisper was recorded
  self:SendMessage("CHITCHAT_WHISPER_LOG_UPDATED", guid, sender, message, timestamp, incoming)
end

-- Locates Log for guid or creates it if does not already exist
function Chitchat:WhisperLogFindOrCreate(guid, label)
  -- Retrieve log id
  local log_id = Chitchat:GetTags()[guid]
  if log_id == nil then
    -- There is no tag link for a log, create one.
    -- TODO Iterate through Chitchat.logs to ensure the guid does not already exist
    --      Chitchat.tags is a only cached table.
    log_id = Chitchat:WhisperLogCreate(guid, label)
    self:GetTags()[guid] = log_id
  end
  
  return Chitchat:GetLogs()[log_id]
end


WhisperLog = {}
WhisperLog.__index = WhisperLog
-- All WhisperLogs are stored as Chitchat.logs. Logs are an array
function Chitchat:WhisperLogCreate(guid, label)
  local whisper_log = {}

  if type(guid)~="string" then
    error(("WhisperLogCreate: 'guid' - string expected got '%s'."):format(type(guid)),2)
  end
  if type(label)~="string" then
    error(("WhisperLogCreate: 'label' - string expected got '%s'."):format(type(label)),2)
  end
  if self:GetTags()[guid] then
    error(("WhisperLogCreate: 'guid' - '%s' already exists"):format(guid),2)
  end
  
  setmetatable(whisper_log,WhisperLog)
  tinsert(self:GetLogs(), whisper_log)
  whisper_log.label = label -- Title of the conversation displayed to user. Can be changed by user.
  whisper_log.tag = guid -- Ties the log to a predictable unique string, whispers are guid pased while channels are global name based.
  whisper_log.whispers = {} -- Internal id of all whispers.
  whisper_log.unread = 1 -- Flags log as containing new whispers
  whisper_log.id = table.getn(Chitchat:GetLogs())
  
  self:Print("Created Log for "..whisper_log.tag.." displayed as "..whisper_log.label)
  self:SendMessage("CHITCHAT_WHISPER_LOG_CREATED", guid, sender)
  
  return whisper_log.id
end
function WhisperLog:GetLabel()
  return self.label
end
function WhisperLog:SetLabel(newLabel)
  self.label = newLabel
end
function WhisperLog:GetTag()
  return self.tags
end
function WhisperLog:GetWhispers()
  return self.whispers
end
function WhisperLog:SetUnread()
  self.unread = 1
end
function WhisperLog:SetRead()
  self.unread = 0
end
function WhisperLog:IsUnread()
  return self.unread == 1
end

-- WHISPER_ENTRY # is a single whisper.
WhisperEntry = {}
WhisperEntry.__index = WhisperEntry
-- All entries are stored in an array and referenced by Chitchat.logs
function Chitchat:WhisperEntryCreate(player, message, timestamp, incoming)
  local whisper_entry = {}

  if type(message)~="string" then
    error(("NewWhisperEntry: 'message' - string expected got '%s'."):format(type(message)),2)
  end
  
  -- Message was sent by the player
  if incoming == 0 then
    player = UnitName("player")
  end

  setmetatable(whisper_entry, WhisperEntry)
  tinsert(self:GetWhispers(),whisper_entry)
  whisper_entry.player = player
  whisper_entry.message = message
  whisper_entry.timestamp = timestamp
  whisper_entry.incoming = incoming
  whisper_entry.id = table.getn(Chitchat:GetWhispers())
  
  --Chitchat:Print("Created Entry for "..uid.." AS player:"..wentry.player..", incoming:"..wentry.incoming..", timestamp:"..wentry.timestamp..", message:'"..wentry.message.."'.")
  self:SendMessage("CHITCHAT_WHISPER_ENTRY_CREATED", player, message, timestamp, incoming)
  
  return whisper_entry.id
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
function WhisperEntry:GetSender()
  local sender = self.player
  if sender == nil then
    sender = "Unknown"
  end
  return sender
end
