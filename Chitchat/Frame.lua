local selected_id = nil
local L = LibStub("AceLocale-3.0"):GetLocale("Chitchat")

function Chitchat:OnLoadFrame(frame)
  initFrame()
	UIDropDownMenu_Initialize(ChitchatDropDown, Chitchat_InitializeLogOptionsMenu, "MENU")

  self:RegisterMessage("CHITCHAT_MESSAGE_CREATED","DirtyLogCache")
  self:RegisterMessage("CHITCHAT_LOG_UPDATED","UpdateConversationList")
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
    info.text = L["MENU_FAVORITE"]
    info.value = "FAVORITE"
    info.func = OnClickDropDownItem
    UIDropDownMenu_AddButton(info)

    -- info.checked = Chitchat:WhisperLogGet(Chitchat.menuItemID, Chitchat.HIDE_CHAT_KEY)
    -- info.notCheckable = false
    -- info.text = "Silent?"
    -- info.value = "QUITE_MODE"
    -- info.func = OnClickDropDownItem
    -- UIDropDownMenu_AddButton(info)

    info.notCheckable = true

    -- info.text = "Have We Met?"
    -- info.value = "HAVE_WE_MET"
    -- info.func = OnClickDropDownItem
    -- UIDropDownMenu_AddButton(info)

    info.text = L["MENU_DELETE_LOG"]
    info.value = "DELETE_LOG"
    info.func = OnClickDropDownItem
    UIDropDownMenu_AddButton(info)

    info.text = L["MENU_DELETE_MESSAGES"]
    info.value = "DELETE_MESSAGES"
    info.func = OnClickDropDownItem
    UIDropDownMenu_AddButton(info)

    info.text = L["MENU_CANCEL"]
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
end

-- Called when any frame under parent frame is shown.
function Chitchat:OnShowFrame(frame)
  PlaySound("igCharacterInfoOpen")
  ChitchatFrameScrollBar:Show()
  ChitchatMessageScrollBar:Show()
  Chitchat.db.profile.missed = 0
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

function Chitchat_OnMessageScrollUpdate()
  Chitchat:OnMessageScrollUpdate()
end

function Chitchat:OnMessageScrollUpdate()
  local offset = FauxScrollFrame_GetOffset(ChitchatMessageScrollBar)
  ChitchatMessageFrame:SetScrollOffset(offset)
end

function Chitchat:ShowWhispers(log_tag)
  ChitchatMessageFrame:Clear();
  local whisper = nil
  local currentDate
  local currentTime
  local message
  local color
  local conversation = self:GetLog(log_tag)
  local count = 0
  if conversation ~= nil and conversation[self.MESSAGES_KEY] ~= nil then
    conversation[self.UNREAD_KEY] = 0
    for index, value in ipairs(conversation[self.MESSAGES_KEY]) do
      whisper = Chitchat:GetMessage(tostring(value))
      if whisper ~= nil then
        if whisper[self.INCOMING_KEY] == 1 then
          color = "ffDA81F5"
        else
          color = "ffffffff"
        end
        currentDate = FormatDate(whisper[self.TIMESTAMP_KEY])
        currentTime = FormatTime(whisper[self.TIMESTAMP_KEY])
        message = "|cFFA9A9A9["..currentDate.."]["..currentTime.."]|r|c"..color.."["..whisper[self.SENDER_KEY].."]: "..whisper[self.MESSAGE_KEY].."|r"
        ChitchatMessageFrame:AddMessage(message)
        if count < 1025 then
          count = index
        end
      end

    end
  end
  FauxScrollFrame_Update(ChitchatMessageScrollBar,count,21,46)
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
	local sortVal = sortTest1 - sortTest2;
	if (sortVal < 0) then
		return true;
	elseif (sortVal == 0) then
		return (index1 < index2);	-- from C side elements are alphabetically sorted
	else
		return false;
	end
end
