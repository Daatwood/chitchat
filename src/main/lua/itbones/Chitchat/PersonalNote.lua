-- Returns the ordered array of the personal notes

Chitchat.sessionTags = {}

function Chitchat:GetNotes()
  return Chitchat.notes
end
function Chitchat:GetNote(tag)
  return Chitchat.notes[tag]
end
function Chitchat:AddNote(tag, personal_note)
  if self.notes == nil then self.notes = {} end
  if personal_note == nil then
    error(("AddLog: 'personal_note' - table expected got '%s'."):format(type(personal_note)),2)
  end
  self.notes[tag] = personal_note
  return self.notes[tag]
end

function Chitchat:MarkAsSeen(tag)
  if self.sessionTags[tag] ~= nil then return false end
  self.sessionTags[tag] = true
  return true
end

-- UPDATE
function Chitchat:UpdatePersonalNote(tag,note,rating,role,klass)
  local personal_note = Chitchat:FindOrCreatePersonalNote(tag)
  -- Nil check
  if personal_note == nil then
    error("UpdatePersonalNote: Unable to find or create a personal note.",2)
  end
  -- Frequency check
  local now = time()
  if personal_note[self.TIMESTAMP_KEY] ~= nil and personal_note[self.TIMESTAMP_KEY] + 3600 < now then
    return
  end
  local updated = false
  if rating ~= nil then
    personal_note[self.RATING_KEY] = rating
    updated = true
  end
  if note ~= nil then
    personal_note[self.NOTE_KEY] = note
    updated = true
  end
  if role ~= nil then
    personal_note[self.ROLE_KEY] = self:PersonalNoteAddRole(personal_note[self.ROLE_KEY], role)
    updated = true
  end
  if klass ~= nil then
    personal_note[self.CLASS_KEY] = klass
    updated = true
  end
  if updated then 
    personal_note[self.TIMESTAMP_KEY] = now
    self:SendMessage("CHITCHAT_NOTE_UPDATED", tag, personal_note.id)
  end
end

-- Find or Create a personal note
-- return: personal note table
function Chitchat:FindOrCreatePersonalNote(tag)
  local personal_note = Chitchat:GetNote(tag)
  if personal_note ~= nil then 
    -- Mark player as Seen.
    if self:MarkAsSeen(tag) then
      if personal_note[self.SEEN_KEY] == nil then personal_note[self.SEEN_KEY] = {} end
      tinsert(personal_note[self.SEEN_KEY],time())
      self:SendMessage("CHITCHAT_PLAYER_SEEN", personal_note[self.TAG_KEY])
      Chitchat:Debug("Found familiar: "..tag)
    end
    return personal_note
  end
  return self:CreatePersonalNote(tag)
end 

-- All PersonalNote are stored as Chitchat.logs. Logs are an ordered array
function Chitchat:CreatePersonalNote(tag)
  local personal_note = {}

  if type(tag)~="string" then
    error(("CreatePersonalNote: 'tag' - string expected got '%s'."):format(type(tag)),2)
  end
  if Chitchat:GetNote(tag) ~= nil then
    error(("CreatePersonalNote: 'tag' - '%s' already exists"):format(tag),2)
  end
  
  personal_note[self.TAG_KEY] = tag
  personal_note[self.NOTE_KEY] = ""
  personal_note[self.RATING_KEY] = 0
  personal_note[self.ROLE_KEY] = 0
  personal_note[self.CLASS_KEY] = ""
  personal_note[self.SEEN_KEY] = {}
  self:SendMessage("CHITCHAT_NOTE_CREATED", personal_note[self.TAG_KEY])
  self:Debug("Created Note for "..personal_note[self.TAG_KEY])
  self:MarkAsSeen(tag)
  tinsert(personal_note[self.SEEN_KEY],time())
  return self:AddNote(tag, personal_note)
end
-- Accepts current Roles as number and new role as string.
-- Returns: new role number
function Chitchat:PersonalNoteAddRole(current_roles, role)
  if not self:IsTankRole(current_roles) and role == "TANK" then
    return current_roles + 4
  elseif not self:IsHealerRole(current_roles) and role == "HEALER" then
    return current_roles + 2
  elseif not self:IsDamagerRole(current_roles) and role == "DAMAGER" then
    return current_roles + 1
  else
    return current_roles
  end
end
--7-THD, 6-TH, 5-TD, 4-T, 3-HD, 2-H, 1-D
function Chitchat:IsTankRole(r)
  return r == 7 or r == 6 or r == 5 or r == 4
end
function Chitchat:IsHealerRole(r)
  return r == 7 or r == 6 or r == 3 or r == 2
end
function Chitchat:IsDamagerRole(r)
  return r == 7 or r == 5 or r == 3 or r == 1
end
function Chitchat:GetRoleInt(tank,healer,dps)
  local r = 0
  if tank ~= nil then r = r + 4 end
  if healer ~= nil then r = r + 2 end
  if dps ~= nil then r = r + 1 end
  return r
end
