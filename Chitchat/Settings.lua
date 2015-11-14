
function Chitchat:GetMinimap(info)
  return self.db.profile.minimap.hide
end
function Chitchat:SetMinimap(info, value)
  self.db.profile.minimap.hide = value
  if self.db.profile.minimap.hide then
    Chitchat.LDBIcon:Hide("Chitchat")
  else
    Chitchat.LDBIcon:Show("Chitchat")
  end
end

function Chitchat:IsRecordAlways(info)
  return self.db.profile.record.always
end
function Chitchat:ToggleRecordAlways(info, value)
  self.db.profile.record.always = value
  if(self.db.profile.record.always) then
    Chitchat.Recording = true
  else
    Chitchat.Recording = false
  end
end

function Chitchat:IsRecordResting(info)
  return self.db.profile.record.resting
end
function Chitchat:ToggleRecordResting(info, value)
  self.db.profile.record.resting = value
  if (self.db.profile.record.resting) then
    self:RegisterEvent("PLAYER_UPDATE_RESTING", "OnEventUpdateResting")
  else
    self:UnregisterEvent("PLAYER_UPDATE_RESTING", "OnEventUpdateResting")
  end
  Chitchat:OnEventUpdateResting()
end

function Chitchat:IsRecordCombat(info)
  return self.db.profile.record.combat
end
function Chitchat:ToggleRecordCombat(info, value)
  self.db.profile.record.combat = value
  if self.db.profile.record.combat then
    self:RegisterEvent("PLAYER_REGEN_DISABLED", "OnEventCombatStart")
    self:RegisterEvent("PLAYER_REGEN_ENABLED", "OnEventCombatEnd")
  else
    self:UnregisterEvent("PLAYER_REGEN_DISABLED", "OnEventCombatStart")
    self:UnregisterEvent("PLAYER_REGEN_ENABLED", "OnEventCombatEnd")
    Chitchat.InCombat = false
    Chitchat:OnEventCombatEnd()
  end
end

function Chitchat:IsRecordAfk(info)
  return self.db.profile.record.afk
end
function Chitchat:ToggleRecordAfk(info, value)
  self.db.profile.record.afk = value
  if self.db.profile.record.afk then
    self:RegisterEvent("PLAYER_FLAGS_CHANGED", "OnEventFlagsChange")
  else
    self:UnregisterEvent("PLAYER_FLAGS_CHANGED", "OnEventFlagsChange")
  end
  Chitchat:OnEventFlagsChange();
end

function Chitchat:IsRecordDnd(info)
  return self.db.profile.record.dnd
end
function Chitchat:ToggleRecordDnd(info, value)
  self.db.profile.record.dnd = value
  if self.db.profile.record.dnd then
    self:RegisterEvent("PLAYER_FLAGS_CHANGED", "OnEventFlagsChange")
  else
    self:UnregisterEvent("PLAYER_FLAGS_CHANGED", "OnEventFlagsChange")
  end
  Chitchat:OnEventFlagsChange();
end

function Chitchat:HideIncoming(info)
  return self.db.profile.recording.hideIncoming
end
function Chitchat:ToggleHideIncoming(info, value)
  self.db.profile.recording.hideIncoming = value
end

function Chitchat:HideOutgoing(info)
  return self.db.profile.recording.hideOutgoing
end
function Chitchat:ToggleHideOutgoing(info, value)
  self.db.profile.recording.hideOutgoing = value
end

function Chitchat:RecordOutgoing(info)
  return self.db.profile.recording.recordOutgoing
end
function Chitchat:ToggleRecordOutgoing(info, value)
  self.db.profile.recording.recordOutgoing = value
end

function Chitchat:CanNotify(info)
  return self.db.profile.recording.notify
end
function Chitchat:ToggleNotify(info, value)
  self.db.profile.recording.notify = value
end

function Chitchat:IsSilent(info)
  return self.db.profile.recording.silent
end
function Chitchat:ToggleSilent(info, value)
  self.db.profile.recording.silent = value
end

function Chitchat:NotAutoRespond(info)
  return not Chitchat:AutoRespond(info)
end
function Chitchat:AutoRespond(info)
  return self.db.profile.recording.autoRespond
end
function Chitchat:ToggleAutoRespond(info, value)
  self.db.profile.recording.autoRespond = value
end

function Chitchat:AutoRespondMessage(info)
  return self.db.profile.recording.autoRespondMessage
end
function Chitchat:SetAutoRespondMessage(info, value)
  self.db.profile.recording.autoRespondMessage = value
end

function Chitchat:ChannelTrade(info)
  return self.db.profile.channels.trade
end
function Chitchat:ToggleChannelTrade(info, value)
  self.db.profile.channels.trade = value
end

function Chitchat:ChannelGeneral(info)
  return self.db.profile.channels.general
end
function Chitchat:ToggleChannelGeneral(info, value)
  self.db.profile.channels.general = value
end

function Chitchat:ChannelGuild(info)
  return self.db.profile.channels.guild
end
function Chitchat:ToggleChannelGuild(info, value)
  self.db.profile.channels.guild = value
  if self.db.profile.channels.guild then
    self:RegisterEvent("CHAT_MSG_GUILD","OnEventChannelGuild")
  else
    self:UnregisterEvent("CHAT_MSG_GUILD","OnEventChannelGuild")
  end
end

function Chitchat:ChannelOfficer(info)
  return self.db.profile.channels.officer
end
function Chitchat:ToggleChannelOfficer(info, value)
  self.db.profile.channels.officer = value
  if self.db.profile.channels.officer then
    self:RegisterEvent("CHAT_MSG_OFFICER","OnEventChannelOfficer")
  else
    self:UnregisterEvent("CHAT_MSG_OFFICER","OnEventChannelOfficer")
  end
end

function Chitchat:FixCapslock(info)
  return self.db.profile.other.fixCapslock
end
function Chitchat:ToggleFixCapslock(info, value)
  self.db.profile.other.fixCapslock = value
end
