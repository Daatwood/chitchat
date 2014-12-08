-- TODO
--  Right-clicking on conversations and on messages.
local selected_id = nil

function Chitchat:OnLoadFrame(frame)
  initFrame()
	UIDropDownMenu_Initialize(ChitchatDropDown, Chitchat_InitializeLogOptionsMenu, "MENU")
  
  self:RegisterMessage("CHITCHAT_MESSAGE_CREATED","DirtyLogCache")
  self:RegisterMessage("CHITCHAT_LOG_UPDATED","UpdateConversationList")
  self:RegisterMessage("CHITCHAT_NOTE_UPDATED","OnChitchatNoteUpdated")
  self:RegisterMessage("CHITCHAT_LOG_DELETED","UpdateConversationList")
end

function initFrame()
  for line=1,10 do
    getglobal("ChitchatFrameEntry"..line):SetID(line)
  end
end

function Chitchat_InitializeLogOptionsMenu(self, level)
  local info = UIDropDownMenu_CreateInfo()
  if level == 1 then
    info.checked = Chitchat:WhisperLogGet(Chitchat.menuItemID, Chitchat.FAVORITE_KEY)
    info.notCheckable = false
    info.text = "Favorite"
    info.value = "FAVORITE"
    info.func = OnClickDropDownItem
    UIDropDownMenu_AddButton(info)
  
    info.checked = Chitchat:WhisperLogGet(Chitchat.menuItemID, Chitchat.HIDE_CHAT_KEY)
    info.notCheckable = false
    info.text = "Silent?"
    info.value = "QUITE_MODE"
    info.func = OnClickDropDownItem
    UIDropDownMenu_AddButton(info)
    
    info.notCheckable = true
    
    info.text = "Have We Met?"
    info.value = "HAVE_WE_MET"
    info.func = OnClickDropDownItem
    UIDropDownMenu_AddButton(info)
   
    info.text = "Delete Log"
    info.value = "DELETE_LOG"
    info.func = OnClickDropDownItem
    UIDropDownMenu_AddButton(info)
    
    info.text = "Delete Messages"
    info.value = "DELETE_MESSAGES"
    info.func = OnClickDropDownItem
    UIDropDownMenu_AddButton(info)
    
    info.text = "Cancel"
    info.value = "CANCEL"
    info.func = OnClickDropDownItem
    UIDropDownMenu_AddButton(info)
  end
end

function OnClickDropDownItem(self)
  local action = self.value
  if action == "HAVE_WE_MET" then
    Chitchat:EditNoteHandler(Chitchat.menuItemID)
  elseif action == "COPY_NAME" then
    print(Chitchat.menuItemID)
  elseif action == "QUITE_MODE" then
    Chitchat:WhisperLogSet(Chitchat.menuItemID, Chitchat.HIDE_CHAT_KEY, not self.checked)
  elseif action == "FAVORITE" then
    Chitchat:WhisperLogSet(Chitchat.menuItemID, Chitchat.FAVORITE_KEY, not self.checked)
  elseif action == "DELETE_LOG" then
    Chitchat:DeleteWhisperLog(Chitchat.menuItemID, false)
  elseif action == "DELETE_MESSAGES" then
    Chitchat:DeleteWhisperLog(Chitchat.menuItemID, true)
  elseif action == "DELETE_NOTE" then
    print("Deleting: "..self.PlayerTag:GetText())
  end
  --Chitchat:Debug("Click: ("..Chitchat.menuItemID..")"..action)
end

-- Called when any frame under parent frame is shown.
function Chitchat:OnShowFrame(frame)
  PlaySound("igCharacterInfoOpen")
  ChitchatFrameScrollBar:Show()
end

-- Called when any frame under parent frame is hidden.
function Chitchat:OnHideFrame(frame)
  PlaySound("igCharacterInfoClose")
end

-- CAlled when any entry button is clicked
function Chitchat:OnClickEntry(self, button, down)
  local tag = self.name:GetText()
  if button == "LeftButton" then
    Chitchat:HideEntryDropdown()
    PlaySound("igMainMenuOptionCheckBoxOn")
    Chitchat:ShowWhispers(tag)
    self.unreadBG:Hide()
    self.unread:SetText('')
  elseif button == "RightButton" then
    Chitchat:ShowEntryDropDown(tag,getglobal("ChitchatFrameEntry"..self:GetID()), 120, 10);
  end
end

function Chitchat:ShowEntryDropDown(itemID, anchorTo, offsetX, offsetY)	
	Chitchat.menuItemID = itemID;
	ToggleDropDownMenu(1, nil, ChitchatDropDown, anchorTo, offsetX, offsetY);
end

function Chitchat:HideEntryDropdown()
	if (UIDropDownMenu_GetCurrentDropDown() == ChitchatDropDown) then
    Chitchat.menuItemID = nil;
		HideDropDownMenu(1);
	end
end

function Chitchat:ShowWhispers(log_tag)
  ChitchatNote:SetFont("Fonts\\FRIZQT__.TTF", 12)
  local text = "<html><body>"
  local message = ""
  local whisper = nil
  local color = ""
  local alignment = ""
  local currentDate
  local currentTime
  local displayDate = ""
  local conversation = self:GetLog(log_tag)
  if conversation ~= nil and conversation[self.MESSAGES_KEY] ~= nil then
    Chitchat.highlightedTag = log_tag
    conversation[self.UNREAD_KEY] = 0
    for index, value in ipairs(conversation[self.MESSAGES_KEY]) do
      whisper = Chitchat:GetMessage(tostring(value))
      if whisper ~= nil then
        if whisper[self.INCOMING_KEY] == 1 then
          color = "ffDA81F5"
          alignment = "left"
        else
          color = "ffffffff"
          alignment = "right"
        end
        currentDate = FormatDate(whisper[self.TIMESTAMP_KEY])
        currentTime = FormatTime(whisper[self.TIMESTAMP_KEY])
        if displayDate ~= currentDate then
          displayDate = currentDate
          message = "<br/><p align='center'>"..displayDate.."</p>"
        end
        message = message.."<p>|cFFA9A9A9["..currentTime.."]|r|c"..color.."["..whisper[self.SENDER_KEY].."]: "..whisper[self.MESSAGE_KEY].."|r</p> "
        text = text..""..message
        message = ""
      else
        self:Debug("Unable to locate whisper "..value.." for "..log_tag)
      end
    end
  end
  ChitchatNote:SetText(text.."<br/><br/></body></html>")
end

function FormatTimestamp(timestamp)
  return date("%m/%d/%y %H:%M:%S", timestamp)
end
function FormatTime(timestamp)
  return date("%H:%M:%S", timestamp)
end
function FormatDate(timestamp)
  return date("%m/%d/%y", timestamp)
end

function Chitchat_OnNoteEditBoxEnterPressed(self)
  local message = self:GetText()
  local tag = Chitchat.highlightedTag
  SendChatMessage(message,"WHISPER",nil,tag)
  Chitchat_OnNoteEditBoxEscapePressed(self)
end

function Chitchat_OnNoteEditBoxEscapePressed(self)
  self:SetText("")
  self:ClearFocus()
end

function Chitchat_OnScrollUpdate()
  Chitchat:OnScrollUpdate()
end

function Chitchat:OnScrollUpdate()
  local line; -- 1 through 5 of our window to scroll
  local lineplusoffset; -- an index into our data calculated from the scroll offset
  -- 100 is max entries, 10 is # of lines, 46 is pixel height
  local order_list = self:GetOrderedLogList()
  local entries = #order_list
  FauxScrollFrame_Update(ChitchatFrameScrollBar,entries,10,46);
  for line=1,10 do
    lineplusoffset = line + FauxScrollFrame_GetOffset(ChitchatFrameScrollBar);
    button = getglobal("ChitchatFrameEntry"..line)
    if lineplusoffset <= entries then
      local conversation =  self:GetLog(order_list[lineplusoffset])
      local display = "Missing Label"
      local tagged_note = ""
      local roles_note = ""
      local class_texture = nil
      if conversation ~= nil then
        display = conversation["tag"]
        local pnote = self:GetNote(conversation[self.TAG_KEY])
        if pnote ~= nil then
          class_texture = CLASS_ICON_TCOORDS[pnote[self.CLASS_KEY]]
          tagged_note = pnote[self.NOTE_KEY]
          local roles = pnote[self.ROLE_KEY]
          if self:IsTankRole(roles) then
            roles_note = roles_note..""..INLINE_TANK_ICON
          end
          if self:IsHealerRole(roles) then
            roles_note = roles_note..""..INLINE_HEALER_ICON
          end
          if self:IsDamagerRole(roles) then
            roles_note = roles_note..""..INLINE_DAMAGER_ICON
          end
        end
      end
      
      if conversation[self.FAVORITE_KEY] then
        button.favorite:Show()
      else
        button.favorite:Hide()
      end
      
      if conversation[self.UNREAD_KEY] ~= nil and conversation[self.UNREAD_KEY] > 0 then
        button.unreadBG:Show()
        button.unread:SetText(conversation[self.UNREAD_KEY])
      else
        button.unreadBG:Hide()
        button.unread:SetText('')
      end
      
      if class_texture then
        button.classIcon:Show()
        button.classIcon:SetTexture("Interface\\TargetingFrame\\UI-Classes-Circles")
        button.classIcon:SetTexCoord(unpack(class_texture))
      else
        button.classIcon:Hide()
      end
      button.role:SetText(roles_note)
      button.name:SetText(display)
      button.note:SetText(tagged_note)
      button:Show()
    else
      button:Hide()
    end
  end
end

function Chitchat:UpdateConversationList(self, tag)
  Chitchat:DirtyLogCache()
  Chitchat:OnScrollUpdate()
  if tag ~= nil and Chitchat.highlightedTag == tag then
    Chitchat:ShowWhispers(tag)
  end
end

function Chitchat:DirtyLogCache()
  Chitchat.cacheDirty = true
end

function Chitchat:OnSearchTextChanged(self)
	SearchBoxTemplate_OnTextChanged(self);

	local text = self:GetText();
	local oldText = Chitchat.searchString;
	if ( text == "" ) then
		Chitchat.searchString = nil;
	else
		Chitchat.searchString = string.lower(text);
	end

	if ( oldText ~= Chitchat.searchString ) then
    Chitchat:DirtyLogCache()
		Chitchat:OnScrollUpdate()
	end
end

Chitchat.sortVal = {}
Chitchat.cachedLogs = {}
Chitchat.cacheDirty = true
function Chitchat:GetOrderedLogList()
  if not self.cacheDirty and self.cachedLogs ~= nil then return self.cachedLogs end
  local logs = self.logs or {}
  self.cachedLogs = {}
  self.sortVal = {}
  for key, value in pairs(logs) do
    local i = #self.cachedLogs + 1
    local isUnread = value[self.UNREAD_KEY] > 0
    local tag = value[self.TAG_KEY]
    if self:TagMatchesFilter(tag) then
      self.cachedLogs[i] = tag
      self.sortVal[tag] = Chitchat_GetWhisperLogSortVal(value[self.FAVORITE_KEY], isUnread)
    end
  end
  local comparison = function(index1, index2)
		return Chtichat_SortComparison(index1, index2)
	end
  table.sort(self.cachedLogs, comparison)
	self.sortVal = {}
  self.cacheDirty = false
  return self.cachedLogs
end

function Chitchat:TagMatchesFilter(tag)
	if ( self.searchString ) then
		if ( string.find(string.lower(tag), self.searchString, 1, true) ) then
			return true;
		else
			return false;
		end
	end
  return true
end

function Chitchat_GetWhisperLogSortVal(isFavorite, isUnread)
	local sortOrder = 3;
	if (isFavorite) then
		sortOrder = 1
	elseif (isUnread) then
		sortOrder = 2
	end

	return sortOrder;
end

function Chtichat_SortComparison(index1, index2)
	local sortTest1 = Chitchat.sortVal[index1];
	local sortTest2 = Chitchat.sortVal[index2];
  --Chitchat:Print("Sort:"..tostring(sortTest1).."@"..index1.." <=> "..tostring(sortTest2).."@"..index2)
	local sortVal = sortTest1 - sortTest2;
	if (sortVal < 0) then
		return true;
	elseif (sortVal == 0) then
		return (index1 < index2);	-- from C side elements are alphabetically sorted
	else
		return false;
	end
end

-------------------------------------------------------------------------------
---- HAVE WE MET FRAME
-------------------------------------------------------------------------------

function Chitchat:OnChitchatNoteUpdated(self, tag)
  
  Chitchat.cachedNotesDirty = true
  if HaveWeMetFrame:IsShown() then
    Chitchat:HaveWeMetFrameListUpdate()
  end
  Chitchat:UpdateConversationList(self,tag)
end

function Chitchat:OnLoadHaveWeMetFrame(frame)
  HybridScrollFrame_CreateButtons(frame.List.listScroll, "HaveWeMetPersonalNoteTemplate", 0, 0)
  UIDropDownMenu_Initialize(HaveWeMetDropDown, Chitchat_InitializeHaveWeMetMenu, "MENU")
  self:RegisterMessage("CHITCHAT_NOTE_UPDATED","GetOrderedNoteList", "true")
end

function Chitchat:OnShowHaveWeMetFrame(frame)
  Chitchat:HaveWeMetFrameListUpdate()
end

function Chitchat:OnHideHaveWeMetFrame(frame)

end

function Chitchat_InitializeHaveWeMetMenu(self, level)
  local info = UIDropDownMenu_CreateInfo()
  if level == 1 then
    info.notCheckable = true
    
    info.text = "Delete Note"
    info.value = "DELETE_NOTE"
    info.func = OnClickDropDownItem
    UIDropDownMenu_AddButton(info)
    
    info.text = "Cancel"
    info.value = "CANCEL"
    info.func = OnClickDropDownItem
    UIDropDownMenu_AddButton(info)
  end
end

function Chitchat:HideHaveWeMetEntryDropdown()
	if (UIDropDownMenu_GetCurrentDropDown() == HaveWeMetDropDown) then
		HideDropDownMenu(1);
	end
end

function Chitchat:OnClickHaveWeMetEntry(self, button, down)
  Chitchat:HideHaveWeMetEntryDropdown()
  if button == "LeftButton" then
    Chitchat:EditNoteHandler(self.PlayerTag:GetText())
  else
    ToggleDropDownMenu(1, nil, HaveWeMetDropDown, self, 120, 10);
    --Chitchat:ShowEntryDropDown(log_tag,getglobal("ChitchatFrameEntry"..self:GetID()), 120, 10);
  end
end

function Chitchat:HaveWeMetFrameListUpdate()
  local items = Chitchat:GetOrderedNoteList(false)--HaveWeMetFrame.List.items or {}
  local numItems = #items
  local scrollFrame = HaveWeMetFrame.List.listScroll
  local offset = HybridScrollFrame_GetOffset(scrollFrame)
  local buttons = scrollFrame.buttons
  local numButtons = #buttons
  
  HaveWeMetFrame.noteCount:SetText(numItems.." Notes")
  
  if numItems == 0 then
    HaveWeMetFrame.List.EmptyNotesText:SetText("No Notes Found")
  else
    HaveWeMetFrame.List.EmptyNotesText:SetText(nil)
  end
  
  for i = 1, numButtons do
    local button = buttons[i]
		local index = offset + i -- adjust index
		local item = items[index]
    local personal_note = nil
    if ( item ) then
      personal_note = self:GetNote(item)
    end
    if personal_note ~= nil then
      -- Setup Personal Note stuff HERE!!!!
      local class_texture = CLASS_ICON_TCOORDS[personal_note[self.CLASS_KEY]]
      local rating = personal_note[self.RATING_KEY]
      if class_texture then
        button.ClassIcon:Show()
        button.ClassIcon:SetTexture("Interface\\TargetingFrame\\UI-Classes-Circles")
        button.ClassIcon:SetTexCoord(unpack(class_texture))
      else
        button.ClassIcon:Hide()
      end
      
      if self:IsTankRole(personal_note[self.ROLE_KEY]) then
        button.TankIcon:SetAlpha(1.0)
      else
        button.TankIcon:SetAlpha(0.25)
      end
      if self:IsHealerRole(personal_note[self.ROLE_KEY]) then
        button.HealerIcon:SetAlpha(1.0)
      else
        button.HealerIcon:SetAlpha(0.25)
      end
      if self:IsDamagerRole(personal_note[self.ROLE_KEY]) then
        button.DamagerIcon:SetAlpha(1.0)
      else
        button.DamagerIcon:SetAlpha(0.25)
      end
      
      if type(rating) == "number" and rating > 0 then
        if rating > 7 then
          button.Rating:SetTextColor(0.0,1.0,0.0)
        elseif rating > 3 then
          button.Rating:SetTextColor(1.0,0.82,0.0)
        elseif rating > 0 then
          button.Rating:SetTextColor(0.9,0.0,0.0)
        end
        button.Rating:SetText(personal_note[self.RATING_KEY])
        button.Rating:Show()
      else
        button.Rating:Hide()
      end
      button.PlayerTag:SetText(personal_note[self.TAG_KEY])
      button.Note:SetText(personal_note[self.NOTE_KEY])
      
      button:Show()
    else
      button:Hide()
    end
  end
  local totalHeight = numItems * scrollFrame.buttonHeight;
	local displayedHeight = numButtons * scrollFrame.buttonHeight;
	HybridScrollFrame_Update(scrollFrame, totalHeight, displayedHeight);
	
end

Chitchat.cachedNotes = {}
Chitchat.cachedNotesDirty = true
function Chitchat:GetOrderedNoteList()
  if not self.cachedNotesDirty and self.cachedNotes ~= nil then return self.cachedNotes end
  local notes = self.notes or {}
  self.cachedNotes = {}
  self.sortVal = {}
  for key, value in pairs(notes) do
    local i = #self.cachedNotes + 1
    local tag = value[self.TAG_KEY]
    local seen = value[self.SEEN_KEY]
    if self:TagMatchesFilter(tag) then
      self.cachedNotes[i] = tag
      if seen ~= nil then
        self.sortVal[tag] = seen[#seen]
      else
        self.sortVal[tag] = 0
      end
    end
  end
  local comparison = function(index1,index2)
    return Chitchat:PersonalNoteComparison(index1,index2)
  end
  table.sort(self.cachedNotes,comparison)
  self.sortVal = {}
  self.cachedNotesDirty = false
  return self.cachedNotes
end

function Chitchat:PersonalNoteComparison(index1,index2)
	local sortTest1 = Chitchat.sortVal[index1];
	local sortTest2 = Chitchat.sortVal[index2];
  if sortTest1 == nil or sortTest2 == nil then
   return false
  end
  local sortVal = sortTest2 - sortTest1;
	if (sortVal < 0) then
		return true;
	elseif (sortVal == 0) then
		return (index1 < index2);	-- from C side elements are alphabetically sorted
	else
		return false;
	end
end

-------------------------------------------------------------------------------
---- HAVE WE MET NOTE FRAME
-------------------------------------------------------------------------------
function Chitchat:PersonalNoteFrameOnLoad(frame)
  local ratingFrameName = frame.Rating:GetName()
  getglobal(ratingFrameName..'Low'):SetText('Unrated')
  getglobal(ratingFrameName..'High'):SetText('10')
  getglobal(ratingFrameName..'Text'):SetText('Rating:')
  
  local class_texture = CLASS_ICON_TCOORDS["PRIEST"]
  frame.ClassIcon:Show()
  frame.ClassIcon:SetAlpha(0.75)
  frame.ClassIcon:SetTexture("Interface\\TargetingFrame\\UI-Classes-Circles")
  frame.ClassIcon:SetTexCoord(unpack(class_texture))
end

function Chitchat:PersonalNoteFrameOnValueChangedRating(self,value)
  local text = math.floor(value+0.5)
  if text == 0 then
    text = "Unrated"
  end
  getglobal(self:GetName() .. 'Text'):SetText("Rating: "..text)
end

function Chitchat:PersonalNoteFrameOnEnterPressed(self)
  local frame = self:GetParent()
  local tag = frame.PlayerTag:GetText()
  local rating = math.floor(frame.Rating:GetValue()+0.5)
  local note = frame.NoteBox:GetText()
  Chitchat:UpdatePersonalNote(tag,note,rating,nil,nil)
  frame:Hide()
end

function Chitchat:PersonalNoteFrameOnSave(self,button,down)
  Chitchat:PersonalNoteFrameOnEnterPressed(self)
end

function Chitchat:ShowPersonalNoteFrame(tag)
  local personal_note = Chitchat:GetNote(tag)
  local note = ""
  local rating = 0
  local className = ''
  local roleNumber = 0
  if personal_note ~= nil then
    note = personal_note[self.NOTE_KEY]
    rating = personal_note[self.RATING_KEY]
    if type(rating) ~= "number" then rating = 0 end
    className = personal_note[self.CLASS_KEY]
    roleNumber = personal_note[self.ROLE_KEY]
  end
  local frame = HaveWeMetNoteFrame
  frame.PlayerTag:SetText(tag)
  frame.NoteBox:SetText(note)
  frame.Rating:SetValue(rating)
  self:PersonalNoteFrameSetClassIcon(frame,className)
  self:PersonalNoteFrameSetRoles(frame,roleNumber)
  frame:Show()
  frame:Raise()
end

function Chitchat:PersonalNoteFrameSetClassIcon(frame, className)
  local class_texture = CLASS_ICON_TCOORDS[className]
  if class_texture then
    frame.ClassIcon:Show()
    frame.ClassIcon:SetAlpha(0.75)
    frame.ClassIcon:SetTexture("Interface\\TargetingFrame\\UI-Classes-Circles")
    frame.ClassIcon:SetTexCoord(unpack(class_texture))
  else
    frame.ClassIcon:Hide()
  end
end

function Chitchat:PersonalNoteFrameSetRoles(frame, roleNumber)
  
  if self:IsTankRole(roleNumber) then
    frame.TankIcon:SetAlpha(1.0)
  else
    frame.TankIcon:SetAlpha(0.25)
  end
  if self:IsHealerRole(roleNumber) then
    frame.HealerIcon:SetAlpha(1.0)
  else
    frame.HealerIcon:SetAlpha(0.25)
  end
  if self:IsDamagerRole(roleNumber) then
    frame.DamagerIcon:SetAlpha(1.0)
  else
    frame.DamagerIcon:SetAlpha(0.25)
  end
end