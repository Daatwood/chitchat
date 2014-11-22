-- TODO
--  Right-clicking on conversations and on messages.

function Chitchat:OnLoadFrame(frame)
  Chitchat:Print("OnLoadFrame")
  initFrame()
  local showmenu;
	UIDropDownMenu_Initialize(ChitchatDropDown, Chitchat_InitializeLogOptionsMenu, "MENU");
	-- showmenu = function()
		-- ToggleDropDownMenu(1, nil, ChitchatDropDown, ChitchatFrameEntry1, 120, 10);
	-- end
end

function initFrame()
  for line=1,10 do
    getglobal("ChitchatFrameEntry"..line):SetID(line)
  end
end

 function Chitchat_InitializeLogOptionsMenu()
  local info = UIDropDownMenu_CreateInfo()
  info.text = "Rename Log"
  info.notCheckable = true
  UIDropDownMenu_AddButton(info)
  
  info.text = "Merge with..."
  UIDropDownMenu_AddButton(info)
  
  info.text = "Delete Log"
  UIDropDownMenu_AddButton(info)
  
  info.text = "Cancel"
  UIDropDownMenu_AddButton(info)
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
  Chitchat:Print("click: "..button)
  if button == "LeftButton" then
    PlaySound("igMainMenuOptionCheckBoxOn")
    local lineplusoffset = self:GetID() + FauxScrollFrame_GetOffset(ChitchatFrameScrollBar);
    local conversation = Chitchat:GetLogs()[lineplusoffset]
    Chitchat:ShowWhispers(conversation)
  elseif button == "RightButton" then
    --Chitchat:Print("Test")
    Chitchat.menuLogID = lineplusoffset
    ToggleDropDownMenu(1, nil, ChitchatDropDown, getglobal("ChitchatFrameEntry"..self:GetID()), 120, 10);
    --menuFrame = CreateFrame("Frame", "ExampleMenuFrame", getglobal("ChitchatFrameEntry1"..self:GetID()), "UIDropDownMenuTemplate")
    --EasyMenu(menu, menuFrame, menuFrame, 0 , 0, "MENU");
    -- TODO Show right-click menu
    --Chitchat_ShowLogOptionsMenu(lineplusoffset, self, 0, 0);
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
function Chitchat:ShowWhispers(conversation)
  ChitchatNote:SetFont("Fonts\\FRIZQT__.TTF", 12)
  local text = "<html><body>"
  local message = ""
  local whisper = nil
  local color = ""
  local alignment = ""
  local currentDate
  local displayDate = ""
  if conversation ~= nil then
    for index, value in ipairs(conversation:GetWhispers()) do
      whisper = Chitchat:GetWhispers()[value]
      if whisper ~= nil then
        if whisper:IsIncoming() then
          color = "ffDA81F5"
          alignment = "left"
        else
          color = "ffffffff"
          alignment = "right"
        end
        currentDate = FormatDate(whisper:GetTimestamp())
        if displayDate ~= currentDate then
          displayDate = currentDate
          message = "<br/><p align='center'>"..displayDate.."</p>"
        end
        
        message = message.."<p>|cFFA9A9A9["..FormatTime(whisper:GetTimestamp()).."]|r|c"..color.."["..whisper:GetSender().."]: "..whisper:GetMessage().."|r</p>"
        
        --message = "<p align='"..alignment.."'>"..sender.."</p>"
        -- message = message.."<img src='Interface\Icons\Ability_Ambush' width='32' height='32' align='left'/>"
        --message = message.."<p align='"..alignment.."'>|cFFA9A9A9["..FormatTimestamp(whisper:GetTimestamp()).."]|r</p>"
        --message = message.."<p align='"..alignment.."'>|c"..color..""..whisper:GetMessage().."|r</p>"
        text = text..""..message
        message = ""
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


function Chitchat_OnScrollUpdate()
  local line; -- 1 through 5 of our window to scroll
  local lineplusoffset; -- an index into our data calculated from the scroll offset
  -- 100 is max entries, 10 is # of lines, 46 is pixel height
  local entries = table.maxn(Chitchat:GetLogs())
  FauxScrollFrame_Update(ChitchatFrameScrollBar,entries,10,46);
  for line=1,10 do
    lineplusoffset = line + FauxScrollFrame_GetOffset(ChitchatFrameScrollBar);
    button = getglobal("ChitchatFrameEntry"..line)
    if lineplusoffset <= entries then
      local conversation = Chitchat:GetLogs()[lineplusoffset]
      local display = "Missing Label"
      if conversation ~= nil then
        display = conversation:GetLabel()
      end
      button.name:SetText(display)
      --getglobal("ChitchatFrameEntry"..line):SetText(display);
      button:Show()
      --getglobal("ChitchatFrameEntry"..line):Show();
    else
      button:Hide()
      --getglobal("ChitchatFrameEntry"..line):Hide();
    end
  end
end