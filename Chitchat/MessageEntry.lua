---------------------------------------------------------------
-- MESSAGE_ENTRY # is a single whisper.
-- Usage:
-- CreateMessageEntry -- Returns message_entry id

-- Returns the ordered array of the messages entries
function Chitchat:GetMessages()
  return self.messages
end
function Chitchat:GetMessage(index)
  return self.messages[index]
end
function Chitchat:AddMessage(message)
  local i = self:GetMessageIndex()
  while self.messages[i] ~= nil do
    i = i + 1
  end
  message[self.ID_KEY] = i
  self.messages[tostring(i)] = message
  self.messages[self.INDEX_KEY] = i + 1
  return message
end
function Chitchat:GetMessageIndex()
  return self.messages[self.INDEX_KEY]
end

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

  message_entry[self.SENDER_KEY] = player
  message_entry[self.MESSAGE_KEY] = message
  message_entry[self.TIMESTAMP_KEY] = timestamp
  message_entry[self.INCOMING_KEY] = incoming
  self:AddMessage(message_entry)
  self:SendMessage("CHITCHAT_MESSAGE_CREATED", message_entry[self.ID_KEY])
  return message_entry
end