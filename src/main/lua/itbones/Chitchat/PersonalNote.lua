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