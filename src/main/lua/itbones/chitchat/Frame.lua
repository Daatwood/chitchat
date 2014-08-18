

function Chitchat:OnLoadFrame(frame)
  Chitchat:Print("OnLoadFrame")
  Chitchat.contacts = {}
end

-- Called when any frame under parent frame is shown.
function Chitchat:OnShowFrame(frame)
  Chitchat:Print("OnShowFrame")
  ChitchatFrameScrollBar:Show()
  
  Chitchat.contacts = Chitchat_CreateContacts()
end

-- Called when any frame under parent frame is hidden.
function Chitchat:OnHideFrame(frame)
  Chitchat:Print("OnHideFrame")
  Chitchat.contacts = {}
end

-- CAlled when any entry button is clicked
function Chitchat:OnClickEntry(self, button, down)
  if button == "LeftButton" then
    PlaySound("igMainMenuOptionCheckBoxOn");
    -- TODO Select Player Entry pass 
  end
  Chitchat:Print("OnClickEntry: "..button.." as "..self:GetText());
end

function Chitchat_OnScrollUpdate()
  local line; -- 1 through 5 of our window to scroll
  local lineplusoffset; -- an index into our data calculated from the scroll offset
  -- 100 is max entries, 10 is # of lines, 16 is pixel height
  FauxScrollFrame_Update(ChitchatFrameScrollBar,100,10,16);
  for line=1,10 do
    lineplusoffset = line + FauxScrollFrame_GetOffset(ChitchatFrameScrollBar);
    if lineplusoffset <= table.maxn(Chitchat.contacts) then
      local contact = Chitchat.contacts[lineplusoffset] 
      local display = "Empty"
      if contact ~= nil then
        display = contact:GetLabel()
      end
      getglobal("ChitchatFrameEntry"..line):SetText(display);
      getglobal("ChitchatFrameEntry"..line):Show();
    else
      getglobal("ChitchatFrameEntry"..line):Hide();
    end
  end
end

function Chitchat_CreateContacts()
  local list = {}
  local i = 1
  for k,v in pairs(Chitchat.logs) do
    Chitchat:Print(i.."] k="..k..", v="..type(v))
    if type(k) == "string" then
      list[i] = Chitchat:NewContact(k)
      local label = Chitchat:GetLogs()[k]:GetDisplayName()
      Chitchat:Print("Created Contact at "..i.." attached to tag "..k.." displayed as "..label)
      getglobal("ChitchatFrameEntry"..i):SetText(label);
      i = i + 1
    end
  end
  Chitchat:Print("Created "..i.." contacts")
  return list
end

-- function Chitchat_CreateContact(tag)
  -- tinsert(Chitchat.contacts, Chitchat:NewContact(tag)
-- end

Contact = {}
Contact.__index = Contact
function Chitchat:NewContact(tag)
  local contact = {}
  
  -- if type(tag)~="string" then
    -- error(("NewContact: 'tag' - string expected got '%s'."):format(type(tag)),2)
  -- end
  
  if Chitchat.logs[tag] == nil then
    error(("NewContact: 'tag' - WhisperLog does not exist for '%s'."):format(tag),2)
  end
  
  setmetatable(contact,Contact)
  contact.tags = {}
  contact.label = Chitchat:GetLogs()[tag]:GetDisplayName()
  tinsert(contact.tags, tag)
  
  return contact
end

function Contact:GetLabel()
  local tag = self.tags[1]
  
  if tag == nil or tag == "" then
    error(("GetDisplayName: 'tag' - is empty or does not exist '%s'."):format(tag),2)
  end
  
  if self.label then
    return self.label
  end
  
  if Chitchat.logs[tag] == nil then
    error(("GetDisplayName: 'uid' - WhisperLog does not exist for '%s'."):format(uid),2)
  end

  return Chitchat.logs[tag]:GetDisplayName()
end