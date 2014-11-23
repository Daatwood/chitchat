Chitchat = LibStub("AceAddon-3.0"):NewAddon("Chitchat", "AceConsole-3.0","AceEvent-3.0")
local CC = Chitchat
local ldb = LibStub:GetLibrary("LibDataBroker-1.1")
local dataObj = ldb:NewDataObject("Rarity", {
 type = "data source",
 text = "Loading",
 label = "Chitchat",
 tocname = "Chitchat",
 icon = "Interface\\Icons\\INV_Misc_EngGizmos_13.blp"
})

local defaultDB = {
  global = {
    silent = false, -- Run quietly in background
    minimap = { hide = false }, -- Minimap Icon display
    logs = {}, -- WhisperLog
    notes = {}, -- PersonalNote
    messages = {} -- MessageEntry
  }
}

function Chitchat:OnInitialize()
  -- Called when the addon is first initalized
  self:Print("OnInitialize: \124TInterface\\Icons\\INV_Misc_EngGizmos_13:12\124t")
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
  
  self:RegisterEvent("HAVEWEMET_RECORD_ADDED","HaveWeMetTest")
    -- HaveWeMet Events
  --self:RegisterEvent("GROUP_ROSTER_UPDATE", "OnEventGroupUpdate")
  --self:RegisterEvent("PLAYER_ENTERING_WORLD","OnEventPlayerEnteringWorld")

  -- Register Hooks
    -- HaveWeMet Hooks
  --self:HookScript(GameTooltip, "OnTooltipSetUnit")
  --self:AddToUnitPopupMenu()

  -- Create Frames

  -- Finalize Addon
end

function Chitchat:HaveWeMetTest()
  Chitchat:Print("HaveWeMetTest!")
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
  Chitchat.messages = Chitchat.db.global.messages
  Chitchat.notes = Chitchat.db.global.notes
  Chitchat.tags = {} -- Chitchat.db.global.tags -- This should be created from logs["guid"] to save storage space
  Chitchat:setupMetatable(Chitchat.logs,WhisperLog,"WHISPER_LOG")
  Chitchat:setupMetatable(Chitchat.notes,PersonalNote,"PERSONAL_NOTE")
  Chitchat:setupMetatable(Chitchat.messages,MessageEntry,nil)
end
function Chitchat:setupMetatable(array, meta, tag_type)
  for index, value in ipairs(array) do
    setmetatable(value, meta)
    if tag_type ~= nil then
      Chitchat:AddTag(value["tag"],tag_type,value["id"])
    end
  end
end

-- Returns the ordered array of the tags
function Chitchat:GetTags()
  return Chitchat.tags
end
function Chitchat:AddTag(tag,tag_type,object_id)
  local tags = Chitchat.tags[tag]
  if Chitchat.tags[tag] == nil then Chitchat.tags[tag] = {} end
  Chitchat.tags[tag][tag_type] = object_id
  --Chitchat:Print("Tag:"..tag.." set "..tag_type.." to "..Chitchat.tags[tag][tag_type])
end
-- Find a tag_type from a tag
function Chitchat:FindTag(tag,tag_type)
  local tags = Chitchat.tags[tag]
  if tags == nil then return nil end
  --Chitchat:Print("Tag:"..tag.." found "..tag_type.." as "..tags[tag_type])
  return tags[tag_type]
end
-- Returns the ordered array of the whisper logs
function Chitchat:GetLogs()
  return Chitchat.logs
end

function initMinimap()
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
    LDBIcon:Register("Chitchat", Chitchat.iconObject,Chitchat.db.global.minimap)
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
  Chitchat:HandleWhisper(sender, message, time(), 1)
end
-- Handle Outgoing WoW Whispers
function Chitchat:OnEventWhisperOutgoing(self, message, sender, lang, channelString, target, flags, arg7, channelNumber, channelName, arg10, counter, guid)
  Chitchat:HandleWhisper(sender, message, time(), 0)
end

-- Locates the Entry by looking up the assigned tag.
-- Create a whisper and add the id to the entries's whisper table.
function Chitchat:HandleWhisper(tag, message, timestamp, incoming)
  local message_id = Chitchat:CreateMessageEntry(tag, message, timestamp, incoming)
  local whisper_log = Chitchat:FindOrCreateWhisperLog(tag)
  if whisper_log == nil then
    error("HandleWhisper: Unable to find or create a whisper log.",2)
  end
  -- Add whisper_id to the whisper log
  --whisper_log:AddMessage(message_id)
  tinsert(whisper_log.messages, message_id)
  whisper_log.unread = 1
  self:SendMessage("CHITCHAT_LOG_UPDATED", whisper_log.id, message_id)
end

---------------------------------------------------------------
-- Usage:
-- FindOrCreateWhisperLog -- Returns whisper_log object
-- FindWhisperLog -- Returns whisper_log id
-- CreateWhisperLog -- Returns whisper_log id

WhisperLog = {}
WhisperLog.__index = WhisperLog

-- Locates Log for guid or creates it if does not already exist
function Chitchat:FindOrCreateWhisperLog(tag)
  -- Retrieve log id
  local log_id = Chitchat:FindTag(tag,"WHISPER_LOG")
  if log_id == nil then
    log_id = Chitchat:CreateWhisperLog(tag)
    Chitchat:AddTag(tag, "WHISPER_LOG", log_id) -- Update the Tags to include a id to note.
  end
  return Chitchat:GetLogs()[log_id]
end

-- All WhisperLogs are stored as Chitchat.logs. Logs are an array
function Chitchat:CreateWhisperLog(tag)
  local whisper_log = {}

  if type(tag)~="string" then
    error(("CreateWhisperLog: 'tag' - string expected got '%s'."):format(type(tag)),2)
  end
  if tag == "" then
    error(("CreateWhisperLog: 'tag' - empty tag not allowed."),2)
  end
  if Chitchat:FindTag(tag,"WHISPER_LOG") ~= nil then
    error(("CreateWhisperLog: 'tag' - '%s' already exists"):format(tag),2)
  end
  
  setmetatable(whisper_log,self)
  tinsert(Chitchat:GetLogs(), whisper_log)
  whisper_log.tag = tag -- Ties the log to a predictable unique string, whispers are guid pased while channels are global name based.
  whisper_log.messages = {} -- Internal id of all whispers.
  whisper_log.unread = 1 -- Flags log as containing new whispers
  whisper_log.id = table.getn(Chitchat:GetLogs())
  
  Chitchat:Print("Created Log ("..whisper_log.id..") for "..whisper_log.tag)
  Chitchat:SendMessage("CHITCHAT_LOG_CREATED", whisper_log.id, tag)
  
  return whisper_log.id
end
function WhisperLog:GetID()
  return self.id
end
function WhisperLog:GetTag()
  return self.tag
end
function WhisperLog:SetTag(newTag)
  self.tag = newTag
end
function WhisperLog:GetMessages()
  return self.messages
end
function WhisperLog:AddMessage(message_id)
  tinsert(self.messages, message_id)
  self:SetUnread()
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
---------------------------------------------------------------
-- Usage:
-- UpdatePersonalNote -- Returns nothing.
-- FindOrCreatePersonalNote -- Returns personal_note object
-- CreatePersonalNote -- Returns personal note id

-- Returns the ordered array of the personal notes
function Chitchat:GetNote()
  return Chitchat.notes
end

PersonalNote = {}
PersonalNote.__index = PersonalNote

-- UPDATE
function Chitchat:UpdatePersonalNote(tag,note,rating,role,klass)
  local personal_note = Chitchat:FindOrCreatePersonalNote(tag)
  if personal_note == nil then
    error("UpdatePersonalNote: Unable to find or create a personal note.",2)
  else
    local updated = false
    if rating ~= nil then
      personal_note:SetRating(rating)
      updated = true
    end
    if note ~= nil then
      personal_note:SetNote(note)
      updated = true
    end
    if roles ~= nil then
      personal_note:SetRole(role)
      updated = true
    end
    if klass ~= nil then
      personal_note:SetPlayerClass(klass)
      updated = true
    end
    self:SendMessage("CHITCHAT_NOTE_UPDATED", tag, personal_note.id)
  end
end

-- Find or Create a personal note
-- return: personal note table
function Chitchat:FindOrCreatePersonalNote(tag)
  -- Retrieve note id
  local note_id = Chitchat:FindTag(tag,"PERSONAL_NOTE")
  if note_id == nil then
    note_id = Chitchat:CreatePersonalNote(tag)
    Chitchat:AddTag(tag, "PERSONAL_NOTE", note_id) -- Update the Tags to include a id to note.
  end
  return Chitchat:GetNotes()[note_id]
end 

-- All PersonalNote are stored as Chitchat.logs. Logs are an ordered array
function Chitchat:CreatePersonalNote(tag)
  local personal_note = {}

  if type(tag)~="string" then
    error(("CreatePersonalNote: 'tag' - string expected got '%s'."):format(type(tag)),2)
  end
  if Chitchat:FindTag(tag,"PERSONAL_NOTE") ~= nil then
    error(("CreatePersonalNote: 'tag' - '%s' already exists"):format(tag),2)
  end
  
  setmetatable(personal_note,PersonalNote)
  tinsert(Chitchat:GetNotes(), personal_note)
  personal_note.tag = tag -- Ties to a predictable unique string
  personal_note.note = ""
  personal_note.rating = 0
  personal_note.role = 0
  personal_note.klass = nil
  personal_note.id = table.getn(Chitchat:GetNotes())
  
  print("Created Note: "..personal_note.id.." for "..personal_note.tag)
  self:SendMessage("CHITCHAT_NOTE_CREATED", personal_note.id, tag)
  
  return personal_note.id
end
function PersonalNote:GetID()
  return self.id
end
function PersonalNote:GetTag()
  return self.tag
end
function PersonalNote:SetTag(newTag)
  self.tag = newTag
end

function PersonalNote:GetNote()
  return self.note
end
function PersonalNote:SetNote(newNote)
  self.note = newNote
end

function PersonalNote:GetRating()
  return self.rating
end
function PersonalNote:SetRating(newRating)
  self.rating = newRating
end

function PersonalNote:GetRole()
  return self.role
end
function PersonalNote:SetRole(newRole)
  self.role = newRole
end
-- 7-THD, 6-TH, 5-TD, 4-T, 3-HD, 2-H, 1-D
function PersonalNote:IsTank()
  local r = self.role
  return r == 7 or r == 6 or r == 5 or r == 4
end
function PersonalNote:IsHealer()
  local r = self.role
  return r == 7 or r == 6 or r == 3 or r == 2
end
function PersonalNote:IsDps()
  local r = self.role
  return r == 7 or r == 5 or r == 3 or r == 1
end
function PersonalNote:SetRoles(tank,healer,dps)
  local r = 0
  if tank ~= nil then r = r + 4 end
  if healer ~= nil then r = r + 2 end
  if dps ~= nil then r = r + 1 end
  self.role = r
end

function PersonalNote:GetPlayerClass()
  return self.klass or ""
end
function PersonalNote:SetPlayerClass(newClass)
  self.klass = newClass
end
---------------------------------------------------------------
-- MESSAGE_ENTRY # is a single whisper.
-- Usage:
-- CreateMessageEntry -- Returns message_entry id

-- Returns the ordered array of the messages entries
function Chitchat:GetMessages()
  return Chitchat.messages
end

MessageEntry = {}
MessageEntry.__index = MessageEntry
-- All entries are stored in an array and referenced by Chitchat.logs
function Chitchat:CreateMessageEntry(player, message, timestamp, incoming)
  local message_entry = {}

  if type(player)~="string" then
    error(("CreateMessageEntry: 'player' - string expected got '%s'."):format(type(player)),2)
  end
  if type(message)~="string" then
    error(("CreateMessageEntry: 'message' - string expected got '%s'."):format(type(message)),2)
  end
  if type(incoming)~= "number" then
    error(("CreateMessageEntry: 'incoming' - number expected got '%s'."):format(type(incoming)),2)
  end
  
  -- Message was sent by the player
  if incoming == 0 then
    local name = UnitName("player")
    local realm = GetRealmName()
    player = name.."-"..realm
  end

  setmetatable(message_entry, MessageEntry)
  tinsert(self:GetMessages(),message_entry)
  message_entry.player = player
  message_entry.message = message
  message_entry.timestamp = timestamp
  message_entry.incoming = incoming
  message_entry.id = table.getn(Chitchat:GetMessages())
  
  self:SendMessage("CHITCHAT_MESSAGE_CREATED", message_entry.id, player)
  return message_entry.id
end
function MessageEntry:GetMessage()
  return self.message
end
function MessageEntry:GetTimestamp()
  return self.timestamp
end
function MessageEntry:IsIncoming()
  return self.incoming == 1
end
function MessageEntry:GetSender()
  local sender = self.player
  if sender == nil then
    sender = "Unknown"
  end
  return sender
end