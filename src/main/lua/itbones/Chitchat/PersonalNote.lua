-- Returns the ordered array of the personal notes
function Chitchat:GetNote()
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

-- UPDATE
function Chitchat:UpdatePersonalNote(tag,note,rating,role,klass)
  local personal_note = Chitchat:FindOrCreatePersonalNote(tag)
  if personal_note == nil then
    error("UpdatePersonalNote: Unable to find or create a personal note.",2)
  else
    local updated = false
    if rating ~= nil then
      personal_note[RATING_KEY] = rating
      updated = true
    end
    if note ~= nil then
      personal_note[NOTE_KEY] = note
      updated = true
    end
    if role ~= nil then
      personal_note[ROLE_KEY] = self:PersonalNoteAddRole(personal_note[ROLE_KEY], role)
      updated = true
    end
    if klass ~= nil then
      personal_note[CLASS_KEY] = klass
      updated = true
    end
    if updated then self:SendMessage("CHITCHAT_NOTE_UPDATED", tag, personal_note.id) end
  end
end

-- Find or Create a personal note
-- return: personal note table
function Chitchat:FindOrCreatePersonalNote(tag)
  local personal_note = Chitchat:GetNote(tag)
  if personal_note ~= nil then return personal_note end
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
  
  personal_note[TAG_KEY] = tag
  personal_note[NOTE_KEY] = ""
  personal_note[RATING_KEY] = 0
  personal_note[ROLE_KEY] = 0
  personal_note[CLASS_KEY] = ""
  self:SendMessage("CHITCHAT_NOTE_CREATED", personal_note[TAG_KEY])
  self:Debug("Created Note for "..personal_note[TAG_KEY])
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


-- function PersonalNote:GetPlayerClass()
  -- return self.klass or ""
-- end
-- function PersonalNote:SetPlayerClass(newClass)
  -- self.klass = newClass
-- end
