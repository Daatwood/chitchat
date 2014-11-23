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
  
  Chitchat:Print("Created Log for "..whisper_log.tag)
  Chitchat:SendMessage("CHITCHAT_LOG_CREATED", whisper_log.id, tag)
  
  return whisper_log.id
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