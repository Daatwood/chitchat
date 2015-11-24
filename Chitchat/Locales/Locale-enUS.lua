--[[

	(C) Copyright 2010 Dustin Atwood aka "Ryknzu"(Ryknzu@gmail.com)

	See License.htm for license terms.
]]
--[[

Chitchat

Chitchat is an addon that works as a in-game answering machine. You can
choose when Chitchat will begin recording incoming whispers. While recording
choose how Chitchat will notify you of a whisper. All incoming whispers are
saved locally and can be viewed at anytime through an easy to use interface.
Have a fully customized experience with many easy to understand options.

I appreciate any feedback, please email me at ryknzu@gmail.com with your questions, concerns or suggestions.

]]

local L = LibStub("AceLocale-3.0"):NewLocale("Chitchat", "enUS", true)

if(L) then
-- General Information
L["CHITCHAT"] = "Chitchat"
L["TOGGLE"] = "Toggle"
L["DELETE"] = "Clear"
L["DELETE_NAME"] = "Clear Name"
L["DELETE_DATE"] = "Clear Date"
L["VIEW"] = "View"
L["VIEW_MSG"] = "Click to View."
-- Options
L["OPT_ADDON_TITLE"] = "Chitchat"
L["OPT_ADDON_DESC"] = format("Chitchat is an add-on that works as an in-game answering machine by |cff0080FFRenzu of US-Crushridge|r.\nVersion: %s",GetAddOnMetadata("Chitchat", "Version"))
L["OPT_HEADER_GENERAL"] = "General"
L["OPT_MINIMAP"] = "Toggle Minimap Icon"
L["OPT_MINIMAP_DESC"] = "Toggles the minimap icon."
L["OPT_TOGGLE"] = "Toggle Interface"
L["OPT_TOGGLE_DESC"] = "Toggles Chitchat interface window."
L["OPT_HEADER_RECORD_MODE"] = "Recording Mode"
L["OPT_RECORD_ALWAYS"] = "Always-On"
L["OPT_RECORD_RESTING"] = "Resting in Town/Inn"
L["OPT_RECORD_COMBAT"] = "During Combat"
L["OPT_RECORD_AFK"] = "While AFK"
L["OPT_RECORD_DND"] = "While DND"
L["OPT_HEADER_RECORDING"] = "While Recording"
L["OPT_HIDE_INCOMING"] = "Hide Incoming Whispers"
L["OPT_HIDE_OUTGOING"] = "Hide Outgoing Whispers"
L["OPT_RECORD_OUTGOING"] = "Record Outgoing Whispers"
L["OPT_NOTIFY"] = "Notify upon return"
L["OPT_SILENT"] = "Silent Recording Messages"
L["OPT_AUTO_RESPOND"] = "Auto Respond"
L["OPT_AUTO_RESPOND_MESSAGE"] = "Auto Respond Message"
L["OPT_HEADER_CHANNEL"] = "Channel Recordings"
L["OPT_CHANNEL_TRADE"] = "Record Trade Chat"
L["OPT_CHANNEL_GENERAL"] = "Record General Chat"
L["OPT_CHANNEL_GUILD"] = "Record Guild Chat"
L["OPT_CHANNEL_OFFICER"] = "Record Officer Chat"
L["OPT_HEADER_OTHER"] = "Other"
L["OPT_FIX_CAPSLOCK"] = "Fix Capslock"
L["OPT_ALERT"] = "New whispers as Raid Warnings"
-- Settings
L["SETTING_AUTO_RESPOND"] = "Currently unavailable, will respond when able."
-- Unread Whisper Messages
L["MISSED_MSG_FIRST"] = "You have "
L["MISSED_MSG_LAST_SINGULAR"] = " unread whisper. "
L["MISSED_MSG_LAST_PLURAL"] = " unread whispers. "
-- Notification Message
L["RECORDING_START"] = "Recording has started."
L["RECORDING_STOP"] = "Recording has ended."
-- Chitchat Frame Menu
L["MENU_FAVORITE"] = "Favorite"
L["MENU_DELETE_LOG"] = "Delete Log"
L["MENU_DELETE_MESSAGES"] = "Delete Messages"
L["MENU_CANCEL"] = "Cancel"
-- Others
L["TRADE_STRING"] = "Trade"
L["GENERAL_STRING"] = "General"
-- Tooltip
L["RECORDING_ON"] = "Recording: |cFF00FF00On|r"
L["RECORDING_OFF"] = "Recording: |cFFFF0000Off|r"
L["INSTRUCT_LEFTCLICK"] = "Click to toggle the window."
L["INSTRUCT_MIDCLICK"] = "Middle-click to force start/stop recording."
L["INSTRUCT_RIGHTCLICK"] = "Right-click for options."


end
