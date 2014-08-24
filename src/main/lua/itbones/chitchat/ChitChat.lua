
Chitchat = LibStub("AceAddon-3.0"):NewAddon("Chitchat", "AceConsole-3.0","AceEvent-3.0")
ModTestData = {}

-- Minimap Icon
-- local icon = LibStub("LibDBIcon-1.0");

function Chitchat:OnInitialize()
  -- Called when the addon is first initalized
  self:Print("OnInitialize")
  
  -- Load Saved DB
  self.logs = {}
  
  -- Setup slash commands
  self:RegisterChatCommand("chitchat","CommandHandler")
  
  --self:InitializeFrame()
  for i=1,25 do
    ModTestData[i] = "Player "..i
  end
end

function Chitchat:OnEnable()
  -- Called when the addon is enabled, just before running
  self:Print("OnEnable")
  
  -- Register Events
  self:RegisterEvent("CHAT_MSG_WHISPER", "OnEventWhisperIncoming")
  self:RegisterEvent("CHAT_MSG_WHISPER_INFORM","OnEventWhisperOutgoing")
  -- Register Hooks
  
  -- Create Frames
  
  -- Finalize Addon
  
  -- self:ToggleFrame()
end

function Chitchat:OnDisable()
  self:Print("OnDisable")
  -- Called when the addon is disabled
  
  -- Halt mod completely, and enter standby mode.
end


function Chitchat:CommandHandler(input)
  self:ToggleFrame()
end


function Chitchat:ToggleFrame()
  self:Print("ToggleFrame")
  if ChitchatFrame:IsShown() then
    HideUIPanel(ChitchatFrame)
  else
    ShowUIPanel(ChitchatFrame)
  end
end

function Chitchat:GetDataTest()
  return ModTestData
end

-- Returns the ordered array of the whisper log
function Chitchat:GetLogs()
  return self.logs
end

-- Handle Incoming WoW Whispers
-- 0x038000000648C5B7 as Ryknzu
function Chitchat:OnEventWhisperIncoming(self, message, sender, lang, channelString, target, flags, arg7, channelNumber, channelName, arg10, counter, guid)
  -- Testing purpose
  --rnd = math.random(10000,99999)
  --guid = "9x099000000"..rnd
  
  Chitchat:Print("Incoming Message "..message.." from "..sender.." with guid "..guid)
  -- Verify/Create WhisperEntry for Player
  local wLog = Chitchat.logs[guid]
  if wLog == nil then
    wLog = Chitchat:NewWhisperLog(guid, sender, "WOW")
  end
  local wEntry = Chitchat:NewWhisperEntry(guid, 1, message)
  tinsert(wLog.messages, 1, wEntry)
  --Chitchat:Print("TODO Create & Add WhisperEntry to Log.")
  --Chitchat:Print("LOG:"..Chitchat.logs[guid])
end

function Chitchat:OnEventWhisperOutgoing(self, message, sender, lang, channelString, target, flags, arg7, channelNumber, channelName, arg10, counter, guid)
  Chitchat:Print("Outgoing Message "..message.." to "..sender.." with guid "..guid)
    -- Verify/Create WhisperEntry for Player
  local wLog = Chitchat.logs[guid]
  if wLog == nil then
    wLog = Chitchat:NewWhisperLog(guid, sender, "WOW")
  end
  -- Create Entry as Outgoing
  local wEntry = Chitchat:NewWhisperEntry(guid, 0, message)
  tinsert(wLog.messages, 1, wEntry)
end

-- WHISPER_LOG # is a single log confined by a button, each contains a date which is followed by an array of whispers
-- WhisperLog:GetPlayerType -> Returns either "WOW" or "BNET". Logs are treated differently by type.
-- WhisperLog:GetDisplayName -> Returns name used for display, generally playername.
-- WhisperLog:GetUnreadMessage -> Returns messages recieved while AFK or DND
-- WhisperLog:GetAllMessages -> Returns all messages.
-- WhisperLog:GetFilterMessages -> Filters messages by incoming/outgoing, date, unread(while AFK/DND) or by word
-- WhisperLog:GetUID -> Returns the unique id for the log. For WOW this is GUID, For BNET there will be internal tracking used, presenceID may change.
WhisperLog = {}
WhisperLog.__index = WhisperLog

-- All WhisperLogs are stored as Chitchat.logs. Logs are an array 
function Chitchat:NewWhisperLog(uid, displayName, entryType)
  local wlog = {}
  
  if type(entryType)~="string" then
    error(("NewWhisperLog: 'entryType' - string expected got '%s'."):format(type(entryType)),2)
  end
  if self.logs[uid] then
    error(("NewWhisperLog: 'uid' - WhisperLog for '%s' already exists."):format(uid),2)
  end
  setmetatable(wlog,WhisperLog)
  self.logs[uid] = wlog
  wlog.uid = uid
  wlog.displayName = displayName
  wlog.entryType = entryType
  wlog.messages = {}
  Chitchat:Print("Created Log for "..wlog.uid.." displayed as "..wlog.displayName.." with type "..wlog.entryType)
  return wlog
end

function Chitchat:GetWhisperLog(uid)
  return self.logs[uid]
end

function WhisperLog:GetDisplayName()
  return self.displayName
end

function WhisperLog:GetUid()
  return self.uid
end

function WhisperLog:GetEntryType()
  return self.entryType
end


-- WHISPER_ENTRY # is a single whisper.
-- WhisperEntry:IsUnread -> Returns if the messages was recieved while AFK/DND
-- WhisperEntry:IsIncoming -> Returns true if whisper was recieved, false if was sent.
-- WhisperEntry:GetDate -> Returns the date of the whisper
-- WhisperEntry:GetTime -> Returns the time of the whisper
-- WhisperEntry:GetMessage -> Returns the content of the whisper
WhisperEntry = {}
WhisperEntry.__index = WhisperEntry

-- All entries are stored as array in a WhisperLog
function Chitchat:NewWhisperEntry(uid, incoming, message)
  local wentry = {}
  
  if uid == nil then
    error("NewWhisperEntry: 'uid' - int expected got nil.",2)
  end
  
  if type(message)~="string" then
    error(("NewWhisperEntry: 'message' - string expected got '%s'."):format(type(message)),2)
  end
  
  if self.logs[uid] == nil then
    error(("NewWhisperEntry: 'uid' - WhisperLog does not exist for '%s'."):format(uid),2)
  end
  
  setmetatable(wentry,WhisperEntry)
  wentry.unread = 1
  wentry.incoming = incoming
  wentry.timestamp = time() -- TODO Fix this.
  wentry.message = message
  Chitchat:Print("Created Entry for "..uid.." AS unread:"..wentry.unread..", incoming:"..wentry.incoming..", timestamp:"..wentry.timestamp..", message:'"..wentry.message.."'.")
  return wentry
end



-- local BUTTON_HEIGHT = 46;

-- StaticPopupDialogs["Chitchat_PLAYER_NOTE"] = {
  -- text = PLAYER_NOTE_LABEL,
  -- button1 = ACCEPT,
  -- button2 = PLAYER_NOTE_DEFAULT_LABEL,
  -- button3 = CANCEL,
  -- hasEditBox = 1,
  -- maxLetters = 16,
  -- OnAccept = function(self)
    -- local text = self.editBox:GetText();
    -- ChitChat_SetCustomName(self.data, text);
    -- ChitChat_UpdateAll();
  -- end,
  -- OnAlt = function(self)
    -- ChitChat_SetCustomName(self.data, "");
    -- ChitChat_UpdateAll();
  -- end,
  -- EditBoxOnEnterPressed = function(self)
    -- local parent = self:GetParent();
    -- local text = parent.editBox:GetText();
    -- ChitChat_SetCustomName(parent.data, text);
    -- ChitChat_UpdateAll();
    -- parent:Hide();
  -- end,
  -- OnShow = function(self)
    -- self.editBox:SetFocus();
  -- end,
  -- OnHide = function(self)
    -- ChatEdit_FocusActiveWindow();
    -- self.editBox:SetText("");
  -- end,
  -- timeout = 0,
  -- exclusive = 1,
  -- hideOnEscape = 1
-- };

-- StaticPopupDialogs["CHITCHAT_SEND_MESSAGE"] = {
  -- text = PET_PUT_IN_CAGE_LABEL,
  -- button1 = OKAY,
  -- button2 = CANCEL,
  -- maxLetters = 30,
  -- OnAccept = function(self)
    -- ChitChat_SendMessageById(self.data);
  -- end,
  -- timeout = 0,
  -- exclusive = 1,
  -- hideOnEscape = 1
-- };

-- StaticPopupDialogs["CHITCHAT_DELETE_LOG"] = {
  -- -- Adding extra line breaks as a hack because IMPORTANT!
  -- text = "\n\nDELETE_LOG_LABEL\n\n",
  -- button1 = OKAY,
  -- button2 = CANCEL,
  -- maxLetters = 30,
  -- OnAccept = function(self)
    -- ChitChat_DeleteById(self.data);
  -- end,
  -- timeout = 0,
  -- exclusive = 1,
  -- hideOnEscape = 1,
  -- showAlert = 1,
-- };

-- SLASH_CHITCHAT = '/chitchat';
-- function ChitChatHandler(msg, editBox)
  -- ChitChatParent:Open();
-- end
-- SlashCmdList["CHITCHAT"] = ChitChatHandler

-- function ChitChatUtil_GetDisplayName(petID)
  -- local internalId, playerName, level, classId, isOffline, isFavorite, customName, customIcon, customIconBorder = C_PetJournal.GetPetInfoByPetID(petID);
  -- return playerName;
-- end

-- function ChitChatParent_OnShow(self)
  -- PlaySound("igCharacterInfoOpen");
  -- ChitChat:Show();
-- end

-- function ChitChatParent_OnHide(self)
  -- PlaySound("igCharacterInfoClose");
-- end

-- function ChitChat_OnLoad(self)
  -- -- self:RegisterEvent("UNIT_PORTRAIT_UPDATE");
  -- -- self:RegisterEvent("PET_JOURNAL_LIST_UPDATE");
  -- -- self:RegisterEvent("PET_JOURNAL_PET_DELETED");
  -- -- self:RegisterEvent("PET_JOURNAL_PETS_HEALED");
  -- -- self:RegisterEvent("BATTLE_PET_CURSOR_CLEAR");
  -- -- self:RegisterEvent("COMPANION_UPDATE");
  -- -- self:RegisterEvent("PET_BATTLE_LEVEL_CHANGED");
  -- -- self:RegisterEvent("PET_BATTLE_QUEUE_STATUS");

  -- self.listScroll.update = ChitChat_UpdateMessageList;
  -- self.listScroll.scrollBar.doNotHide = true;
  -- HybridScrollFrame_CreateButtons(self.listScroll, "PlayerListButtonTemplate", 44, 0);
  
  -- UIDropDownMenu_Initialize(self.playerOptionsMenu, PlayerOptionsMenu_Init, "MENU");

  -- -- Shows the 2nd half with all player information and messages.
  -- -- ChitChat_ShowPlayerById(1);
-- end

-- function ChitChat_OnShow(self)
  -- PlaySound("igCharacterInfoOpen");
  -- ChitChat_UpdatePlayerList();
  -- ChitChat_UpdatePlayerLoadOut();
  -- ChitChat_UpdatePlayerCard(ChitChatPlayerCard);
  
  -- -- MESSAGE EVENT STUFF
  -- --self:RegisterEvent("ACHIEVEMENT_EARNED");

  -- --SetPortraitToTexture(ChitChatParentPortrait,"Interface\\Icons\\PetJournalPortrait");
-- end

-- function ChitChat_OnHide(self)
  -- -- MESSAGE EVENT STUFF
  -- -- self:UnregisterEvent("ACHIEVEMENT_EARNED");
  -- PlaySound("igCharacterInfoClose");
  -- ChitChat.PlayerSelect:Hide();
-- end

-- function ChitChat_OnEvent(self, event, ...)
  -- -- TODO See Ref: PetJournal_OnEvent(self, event, ...)
-- end

-- function ChitChat_SelectClass(self, targetClassId)
  -- -- TODO: PetJournal_SelectSpecies(self, targetClassId)
-- end

-- -- REMOVED 
-- -- PetJournal_SelectPet(self, targetPetID)

-- function ChitChatPlayerList_UpdateScrollPos(self, visibleIndex)
  -- local buttons = self.buttons;
  -- local height = math.max(0, math.floor(self.buttonHeight * (visibleIndex - (#buttons)/2)));
  -- HybridScrollFrame_SetOffset(self, height);
  -- self.scrollBar:SetValue(height);
-- end

-- function ChitChat_ShowPlayerSelect(self)
  -- -- TODO PetJournal_ShowPetSelect(self)
-- end

-- function ChitChat_OnSearchTextChanged(self)
	-- local text = self:GetText();
	-- if text == SEARCH then
		-- --C_PetJournal.SetSearchFilter("");
		-- return;
	-- end
	
	-- --C_PetJournal.SetSearchFilter(text);
-- end

-- function ChitChatListItem_OnClick(self, button)
  -- -- TODO PetJournalListItem_OnClick(self, button)
-- end

-- function ChitChat_UpdateAll()
  -- ChitChat_UpdatePlayerList();
  -- ChitChat_UpdatePlayerLoadOut();
  -- ChitChat_UpdatePlayerCard(ChitChatPlayerCard);
  -- ChitChat_HidePlayerDropdown();
-- end

-- function ChitChat_UpdatePlayerList()
  -- -- TODO See Ref: PetJournal_UpdatePetList
-- end

-- function ChitChat_UpdatePlayerLoadOut()
  -- -- TODO See Ref: PetJournal_UpdatePetLoadOut
-- end

-- function ChitChat_UpdatePlayerCard(self)
  -- -- TODO See Ref: PetJournal_UpdatePetCard(PetJournalPetCard)
-- end

-- function ChitChatUnreadCount_OnEnter(self)
	-- GameTooltip:SetOwner(self, "ANCHOR_RIGHT");
	-- GameTooltip:SetMinimumWidth(150);
	-- GameTooltip:SetText("CHITCHAT_TOTAL_UNREAD_COUNT", 1, 1, 1);
	-- GameTooltip:AddLine("CHITCHAT_TOTAL_UNREAD_COUNT_TOOLTIP", nil, nil, nil, true);
	-- GameTooltip:Show();
-- end

-- function ChitChatFilterDropDown_OnLoad(self)
	-- UIDropDownMenu_Initialize(self, ChitChatFilterDropDown_Initialize, "MENU");
-- end
