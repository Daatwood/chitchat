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
  if type(timestamp)~="string" then
    error(("CreateMessageEntry: 'timestamp' - string expected got '%s'."):format(type(timestamp)),2)
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