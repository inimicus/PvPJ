local strings = {

	SI_PVPJOURNAL_ENABLE_CHATOUTPUT = "Show AP log",
	SI_PVPJOURNAL_ENABLE_CHATOUTPUT_TT = "Show AP log in Chat",

	SI_PVPJOURNAL_TIMESTAMP = "Timestamp",
	SI_PVPJOURNAL_TIMESTAMP_COLOR = "Different color for timestamp & text",
	SI_PVPJOURNAL_TIMESTAMP_COLOR_TT = "Use a different color for timestamp and text.",

	SI_PVPJOURNAL_TIMESTAMP_COLORPICKER = "Timestamp color",
	SI_PVPJOURNAL_TIMESTAMP_COLORPICKER_TT = "If you have enabled a different color for timestamp, choose the color here.",

	SI_PVPJOURNAL_SETAPVALUE_TT = "Shows AP log in chat when AP tick is ≥ than this value.",

	SI_PVPJOURNAL_TEXTCOLOR = "Text color",
	SI_PVPJOURNAL_TEXTCOLOR_TT = "Choose the text color",
	
	SI_PVPJOURNAL_SHORT_AP = "Shorten values",
	SI_PVPJOURNAL_SHORT_AP_TT = "Shows short values for AP gains.\nExample: 1.4k instead 1.400.",
	
	SI_PVPJOURNAL_REASON = "Show AP reason",
	SI_PVPJOURNAL_REASON_TT = "Shows you the reason why you got AP.",
	
	SI_PVPJOURNAL_AMOUNT_AP = "Show current amount of AP",
	SI_PVPJOURNAL_AMOUNT_AP_TT = "Activating this option will read:\n1.233.655 (+25).\nDisabling this option will read: +25.",
	
	SI_PVPJOURNAL_NOTIFICATIONS_ICONS = "Notification Icons",
	SI_PVPJOURNAL_NOTIFICATIONS_ICONS_TT = "Shows a small icon before the message.",

	SI_PVPJOURNAL_NOTIFICATIONS_YOURKILL = "<<1>> You killed...",
	SI_PVPJOURNAL_NOTIFICATIONS_YOURDEATH = "<<1>> Someone killed you...",
	SI_PVPJOURNAL_NOTIFICATIONS_RESURRECTION = "<<1>> Someone resurrected...",
	
	SI_PVPJOURNAL_NOTIFICATIONS_TARGET_COLOR = "Enemy color",
	
	SI_PVPJOURNAL_NOTIFICATIONS_SHORT = "Short notifications",
	SI_PVPJOURNAL_NOTIFICATIONS_SHORT_TT = "When you activate this option, it does shows you a shorter form of the notifications.",
	
	SI_PVPJOURNAL_SLASH_COMMANDS = "Slash-Commands",

	-- notifications reasons
	SI_PVPJOURNAL_NOTIFICATIONS_REASON_13 = "Player Kill",
	SI_PVPJOURNAL_NOTIFICATIONS_REASON_41 = "Resurrection",
	
	-- campaign / battleground
	SI_PVPJOURNAL_FORWARD_CAMP_TT = "Add an additional keybind to respawn faster in forward camp.",
	SI_PVPJOURNAL_QUEUE_POSITION = "Shows <<1>>",
	SI_PVPJOURNAL_QUEUE_POSITION_TT = "Shows a center screen message when your queue position changed",
	SI_PVPJOURNAL_QUEUE_ACCEPT = "Auto accept campaign invite",
	SI_PVPJOURNAL_QUEUE_ACCEPT_TT = "Accept instantly the campaign invite instead showing up the dialog frame",
	SI_PVPJOURNAL_BATTLEGROUND_INFOS = GetString(SI_INSTANCEDISPLAYTYPE9).." Informations",
	SI_PVPJOURNAL_BATTLEGROUND_INFOS_TT = "Enable to get a notifcation when entering a battleground.",
	
	-- ap statistic
	SI_PVPJOURNAL_CHAT_MENU_AP_SESSION = "<<1>> Shows Session",
	SI_PVPJOURNAL_CHAT_MENU_AP_SESSION_RESET = "<<1>> Reset <<2>> session",
	SI_PVPJOURNAL_CHAT_SHOWS_AP_SESSION_RESET = "<<1>> session resetted",
	
    -- group stuff
    SI_PVPJOURNAL_GROUP_INVITE_ENABLE = "Auto group invite",
    SI_PVPJOURNAL_GROUP_INVITE_ENABLE_TT = "Enable to automatically invite to your group when the invite string is seen in chat.",
    SI_PVPJOURNAL_GROUP_INVITE_STRING = "Invite String",
    SI_PVPJOURNAL_GROUP_INVITE_STRING_TT = "Text to check messages to auto-invite for.",
    SI_PVPJOURNAL_GROUP_LEAD = "Pass group lead",
    SI_PVPJOURNAL_GROUP_LEAD_TT = "If someone types this message into the group chat, it will allow to pass the group lead. This might be useful if the current group leader is afk.",
    SI_PVPJOURNAL_GROUP_LEAD_STRING = "Pass lead string",
    SI_PVPJOURNAL_GROUP_LEAD_STRING_TT = "Text to check messages to pass lead for.",
	
}

for stringId, stringValue in pairs(strings) do
   ZO_CreateStringId(stringId, stringValue)
   SafeAddVersion(stringId, 1)
end