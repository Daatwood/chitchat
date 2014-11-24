function Chitchat:GetLogs()
  return self.logs
end
function Chitchat:GetLog(tag)
  return self.logs[tag]
end
function Chitchat:AddLog(tag, whisper_log)
  if self.logs == nil then self.logs = {} end
  if whisper_log == nil then
    error(("AddLog: 'whisper_log' - table expected got '%s'."):format(type(whisper_log)),2)
  end
  self.logs[tag] = whisper_log
  return self.logs[tag]
end

-- Locates Log for guid or creates it if does not already exist
function Chitchat:FindOrCreateWhisperLog(tag)
  local whisper_log = Chitchat:GetLog(tag)
  if whisper_log ~= nil then return whisper_log end
  return self:CreateWhisperLog(tag)
end

function Chitchat:DeleteWhisperLog(tag)
  -- Retrieve log id
  local whisper_log = Chitchat:GetLog(tag)
  if whisper_log ~= nil then
    if whisper_log["tag"] == tag then
      if whisper_log[MESSAGES_KEY] ~= nil then
        -- Delete messages so they are not orphans
        for index, value in ipairs(whisper_log[MESSAGES_KEY]) do
          self.messages[tostring(value)] = nil
        end
        self:Debug("Deleted all recorded messages.")
      end
    
      self.logs[tag] = nil
      self:Debug("Deleted WhisperLog for "..tag)
      self:SendMessage("CHITCHAT_LOG_DELETED", tag)
      self:OnScrollUpdate()
      ChitchatNote:SetText("")
    else
      self:Print(("DeleteWhisperLog: Unable able to delete log.'%s' != '%s'"):format(tag,whisper_log["tag"]))
    end
  else
    self:Debug("Unable to locate WhisperLog ("..tag..") for deletion.")
  end
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
  if Chitchat:GetLog(tag) ~= nil then
    error(("CreateWhisperLog: 'tag' - '%s' already exists"):format(tag),2)
  end
  
  whisper_log[TAG_KEY] = tag
  whisper_log[MESSAGES_KEY] = {}
  whisper_log[UNREAD_KEY] = 0
  self:SendMessage("CHITCHAT_MESSAGE_CREATED", whisper_log[TAG_KEY])
  self:Debug("Created Log for "..whisper_log[TAG_KEY])
  return self:AddLog(tag, whisper_log)
end