-- TODO
--  Right-clicking on conversations and on messages.
local selected_id = nil

function Chitchat:OnLoadFrame(frame)
  initFrame()
	UIDropDownMenu_Initialize(ChitchatDropDown, Chitchat_InitializeLogOptionsMenu, "MENU");
  
  self:RegisterMessage("CHITCHAT_LOG_UPDATED","OnScrollUpdate")
  self:RegisterMessage("CHITCHAT_NOTE_UPDATED","OnScrollUpdate")
end

function initFrame()
  for line=1,10 do
    getglobal("ChitchatFrameEntry"..line):SetID(line)
  end
end

 function Chitchat_InitializeLogOptionsMenu(self, level)
  local info = UIDropDownMenu_CreateInfo()
  if level == 1 then
    info.notCheckable = true
    
    info.text = "Have We Met?"
    info.value = "HAVE_WE_MET"
    info.func = OnClickDropDownItem
    UIDropDownMenu_AddButton(info)
   
    info.text = "Delete Log"
    info.value = "DELETE"
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
  elseif action == "DELETE" then
    Chitchat:DeleteWhisperLog(Chitchat.menuItemID)
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
  local log_id = self:GetID() + FauxScrollFrame_GetOffset(ChitchatFrameScrollBar);
  local order_list = Chitchat:GetOrderedLogList(false)
  local log_tag = order_list[log_id]
  --Chitchat:Debug("Showing entry for "..log_tag)
  if button == "LeftButton" then
    Chitchat:HideEntryDropdown()
    PlaySound("igMainMenuOptionCheckBoxOn")
    Chitchat:ShowWhispers(log_tag)
  elseif button == "RightButton" then
    Chitchat:ShowEntryDropDown(log_tag,getglobal("ChitchatFrameEntry"..self:GetID()), 120, 10);
    --ToggleDropDownMenu(1, nil, ChitchatDropDown, , 120, 10);
    --menuFrame = CreateFrame("Frame", "ExampleMenuFrame", getglobal("ChitchatFrameEntry1"..self:GetID()), "UIDropDownMenuTemplate")
    --EasyMenu(menu, menuFrame, menuFrame, 0 , 0, "MENU");
    -- TODO Show right-click menu
    --Chitchat_ShowLogOptionsMenu(lineplusoffset, self, 0, 0);
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

-- function Chitchat_ShowLogOptionsMenu(index, anchorTo, offsetX, offsetY)
  -- if (index) then
    -- Chitchat.menuLogID = Chitchat:GetLogs()[index]
    -- return;
  -- end
  -- ToggleDropDownMenu(1, nil, ChitchatLogOptionsMenu, anchorTo, offsetX, offsetY);
-- end

-- Single Whisper Format
-- (similar to facebook chat)
-----------------------------
-- <h1>Player Name</h1>
-- <p align='right'>1/14 10:36pm</p>
-- <p>a message from the player</p>
-- 
-- Should actually be similar to WoW Chat. 
-- [Time][Player]: Message...
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
  if conversation ~= nil then
    for index, value in ipairs(conversation[MESSAGES_KEY]) do
      whisper = Chitchat:GetMessage(tostring(value))
      if whisper ~= nil then
        if whisper[INCOMING_KEY] == 1 then
          color = "ffDA81F5"
          alignment = "left"
        else
          color = "ffffffff"
          alignment = "right"
        end
        currentDate = FormatDate(whisper[TIMESTAMP_KEY])
        currentTime = FormatTime(whisper[TIMESTAMP_KEY])
        if displayDate ~= currentDate then
          displayDate = currentDate
          message = "<br/><p align='center'>"..displayDate.."</p>"
        end
        
        message = message.."<p>|cFFA9A9A9["..currentTime.."]|r|c"..color.."["..whisper[SENDER_KEY].."]: "..whisper[MESSAGE_KEY].."|r</p>"
        
        --message = "<p align='"..alignment.."'>"..sender.."</p>"
        -- message = message.."<img src='Interface\Icons\Ability_Ambush' width='32' height='32' align='left'/>"
        --message = message.."<p align='"..alignment.."'>|cFFA9A9A9["..FormatTimestamp(whisper:GetTimestamp()).."]|r</p>"
        --message = message.."<p align='"..alignment.."'>|c"..color..""..whisper:GetMessage().."|r</p>"
        text = text..""..message
        message = ""
      else
        self:Print("Unable to locate whisper "..value.." for "..log_tag)
      end
    end
  else
    self:Print("Unable to locate whisper log for "..tag)
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

function Chitchat_OnScrollUpdate()
  Chitchat:OnScrollUpdate()
end

function Chitchat:OnScrollUpdate()
  local line; -- 1 through 5 of our window to scroll
  local lineplusoffset; -- an index into our data calculated from the scroll offset
  -- 100 is max entries, 10 is # of lines, 46 is pixel height
  local order_list = self:GetOrderedLogList(false)
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
        local pnote = self:GetNote(conversation[TAG_KEY])
        if pnote ~= nil then
          class_texture = CLASS_ICON_TCOORDS[pnote[CLASS_KEY]]
          tagged_note = pnote[NOTE_KEY]
          local roles = pnote[ROLE_KEY]
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
      --getglobal("ChitchatFrameEntry"..line):SetText(display);
      button:Show()
      --getglobal("ChitchatFrameEntry"..line):Show();
    else
      button:Hide()
      --getglobal("ChitchatFrameEntry"..line):Hide();
    end
  end
end

Chitchat.ordered_logs = {}
function Chitchat:GetOrderedLogList(cache)
  if cache and self.ordered_logs ~= nil then return self.ordered_logs end
  self.ordered_logs = {}
  for key, value in pairs(self.logs) do
    tinsert(self.ordered_logs,value[TAG_KEY])
  end
  return self.ordered_logs
end