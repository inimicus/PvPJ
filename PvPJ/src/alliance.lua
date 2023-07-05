local addon = PVPJ
local LibSWF = addon.LibSWF

local SI_OUTPUT_TWO_ALTERNATIVE = "%s%s"
local SI_OUTPUT_TWO_DOUBLEPOINT = "%s: %s"


-----------------
-- CHAT OUTPUT --
-----------------
addon.sessionTable = {
	--[[
	This table defines all about AP sessions.
	]]
	-- session
	sessionAP		= 0,
	sessionDeath	= 0,
	sessionKills	= 0,
	sessionStart	= GetTimeStamp(),
	-- killings
	lastNotifyKill	= "",
	lastNotifyTime	= GetGameTimeMilliseconds(),
}

local function GetSessionAP()
	return ZO_Currency_FormatPlatform(CURT_ALLIANCE_POINTS, addon.sessionTable.sessionAP, ZO_CURRENCY_FORMAT_AMOUNT_ICON)
end

local function GetSessionKills()
	return string.format(SI_OUTPUT_TWO_ALTERNATIVE, addon:GetIconFormat("kill", "100%"), addon.sessionTable.sessionKills)
end

local function GetSessionDeaths()
	return string.format(SI_OUTPUT_TWO_ALTERNATIVE, addon:GetIconFormat("death", "100%"), addon.sessionTable.sessionDeath)
end

local function GetSessionTime(seconds)
	return string.format(SI_OUTPUT_TWO_ALTERNATIVE, addon:GetIconFormat("time", "100%"), os.date("!%T", seconds))
end

local function GetAPRatio(seconds)
	return string.format("%s/h", ZO_Currency_FormatPlatform(CURT_ALLIANCE_POINTS, zo_roundToZero(addon.sessionTable.sessionAP / seconds * 3600), ZO_CURRENCY_FORMAT_AMOUNT_ICON))
end

local function APstats()
	-- check ap session
	if addon.sessionTable.sessionAP <= 0 then
		addon.sessionTable.sessionAP = 0
	end
	-- session time
	local seconds = GetTimeStamp() - addon.sessionTable.sessionStart
	-- output
	LibSWF:ChatOutput(string.format("%s / %s / %s / %s → %s", GetSessionAP(), GetSessionKills(), GetSessionDeaths(), GetSessionTime(seconds), GetAPRatio(seconds)))
end


---------------
-- CHAT MENU --
---------------
local function ResetAPsession()
	addon.sessionTable.sessionAP = 0
	addon.sessionTable.sessionKills = 0
	addon.sessionTable.sessionDeath = 0
	addon.sessionTable.sessionStart = GetTimeStamp()
end

local function APsessionResetted()
	ResetAPsession()
	LibSWF:ChatOutput(zo_strformat(SI_PVPJOURNAL_CHAT_SHOWS_AP_SESSION_RESET, addon:GetIconFormat("alliancePoints", "80%")))
end

local function ChatSystemShowOptions(originalFunc, ...)
	originalFunc(...)
	if addon.inAvaWorld or addon.inWorldBg or addon.savedVarCopy.debug then
		-- Hide this Menu options in PvE
		AddCustomMenuItem(zo_strformat(SI_PVPJOURNAL_CHAT_MENU_AP_SESSION_RESET, addon.displayNameShort, addon:GetIconFormat("alliancePoints", "80%")), APsessionResetted)
	end
	ShowMenu(ZO_Menu.owner)
end
LibSWF:WrapFunction("ZO_ChatSystem_ShowOptions", ChatSystemShowOptions)


----------------------
-- AP NOTIFICATIONS --
----------------------
local function GetAPTotalFormat(alliancePoints)
	return string.format("|c%s(|r%s|c%s)|r", addon:GetMyColor("text"):ToHex(), ZO_Currency_FormatPlatform(CURT_ALLIANCE_POINTS, alliancePoints, ZO_CURRENCY_FORMAT_AMOUNT_ICON), addon:GetMyColor("text"):ToHex())
end

local ALLIANCE_POINTS_COLOR = ZO_ColorDef:New(GetInterfaceColor(INTERFACE_COLOR_TYPE_CURRENCY, CURRENCY_COLOR_ALLIANCE_POINTS))
local function GetAPDifferenceFormat(difference)
	return string.format("%s%s", ALLIANCE_POINTS_COLOR:Colorize("+"), ZO_Currency_FormatPlatform(CURT_ALLIANCE_POINTS, difference, ZO_CURRENCY_FORMAT_AMOUNT_ICON))
end

local rewards = GetString(SI_CUSTOMERSERVICESUBMITFEEDBACKSUBCATEGORIES705)
local reasonTable = {
	--[[
	This table defines the AP output reasons.
	]]
	-- BG
	[12] = string.format(SI_OUTPUT_TWO_DOUBLEPOINT, GetString(SI_QUESTTYPE13), rewards), 	-- CURRENCY_CHANGE_REASON_BATTLEGROUND
	[21] = GetString(SI_SCORETRACKERENTRYTYPE7), 											-- CURRENCY_CHANGE_REASON_MEDAL
	-- PvP
	[4]  = string.format(SI_OUTPUT_TWO_DOUBLEPOINT, GetString(SI_ITEMFILTERTYPE7), rewards),-- CURRENCY_CHANGE_REASON_QUESTREWARD
	[13] = GetString(SI_PVPJOURNAL_NOTIFICATIONS_REASON_13),								-- CURRENCY_CHANGE_REASON_KILL
	[14] = GetString(SI_MAPFILTER2),														-- CURRENCY_CHANGE_REASON_KEEP_REWARD
	[40] = GetString(SI_SPECIALIZEDITEMTYPE2100),											-- CURRENCY_CHANGE_REASON_KEEP_REPAIR
	[41] = GetString(SI_PVPJOURNAL_NOTIFICATIONS_REASON_41),								-- CURRENCY_CHANGE_REASON_PVP_RESURRECT
}
local function GetAPReasonFormat(reason)
	return addon.savedVarCopy.showAPreason and addon:GetMyColor("text"):Colorize(string.format("(%s)", reasonTable[reason] or reason)) or ""
end

local blacklist = {
	[42] = CURRENCY_CHANGE_REASON_BANK_DEPOSIT,
	[43] = CURRENCY_CHANGE_REASON_BANK_WITHDRAWAL,
}
local function OnAlliancePointUpdate(_, alliancePoints, _, difference, reason)
	--[[
	This function counts AP gained.
	]]
	if difference < 1 or blacklist[reason] then return end
	addon.sessionTable.sessionAP = addon.sessionTable.sessionAP + difference
	if addon.savedVarCopy.showAPLog and difference >= addon.savedVarCopy.setAPvalue then
		LibSWF:ChatOutput(string.format("%s%s %s", addon:GetTimeStampFormat(), (addon.savedVarCopy.showAPtotal and string.format("%s %s", GetAPDifferenceFormat(difference), GetAPTotalFormat(alliancePoints))) or GetAPDifferenceFormat(difference), GetAPReasonFormat(reason)))
	end
	-- debug
	LibSWF:ChatOutput(string.format("OnAlliancePointUpdate() ap: %s, difference: %s, reason: %s", alliancePoints, difference, reason), true, addon.savedVarCopy.debug, addon.name)
end
-- SLASH_COMMANDS['/testalliancepointupdate'] = function() OnAlliancePointUpdate(_, 1234567, _, 1350, 12) end


-------------------
-- CREATE BUTTON --
-------------------
local PVPJbutton
function addon:CreateButton()
	local button = WINDOW_MANAGER:CreateControl(addon.name, ZO_ChatWindow, CT_BUTTON)
	PVPJbutton = button
	button:SetDimensions(32, 32)
	if LibSWF:IsAddonStateEnabled("ChatLogger") then
		LibSWF:ChatOutput("ChatLogger enabled", true, self.savedVarCopy.debug, addon.name, 1000)
		button:SetAnchor(TOPLEFT, ZO_ChatSystemOptions, TOPRIGHT, -110, 8)
	else
		button:SetAnchor(TOPLEFT, ZO_ChatSystemOptions, TOPRIGHT, -75, 8)
	end
	-- define button
    button:SetNormalTexture("esoui/art/journal/journal_tabicon_cadwell_up.dds")
    button:SetPressedTexture("esoui/art/journal/journal_tabicon_cadwell_down.dds")
    button:SetMouseOverTexture("esoui/art/journal/journal_tabicon_cadwell_over.dds")
	button:SetClickSound("Click")
	button:SetHandler("OnMouseEnter", function()
		InitializeTooltip(InformationTooltip, button, BOTTOMRIGHT, 10, 10, TOPLEFT)
		SetTooltipText(InformationTooltip, zo_strformat(SI_PVPJOURNAL_CHAT_MENU_AP_SESSION, addon.displayNameShort))
	end)
	button:SetHandler("OnMouseExit", function() ClearTooltip(InformationTooltip, tooltipOwner) end)
	button:SetHidden(true)
	-- set the callback function of the button
	button:SetHandler("OnClicked", APstats)
end


--------------
-- ALLIANCE --
--------------
function addon:HandlerAlliance()
	if addon.inAvaWorld or addon.inWorldBg or self.savedVarCopy.debug then
		EVENT_MANAGER:RegisterForEvent(addon.name, EVENT_ALLIANCE_POINT_UPDATE, OnAlliancePointUpdate)
		PVPJbutton:SetHidden(false)
	else
		EVENT_MANAGER:UnregisterForEvent(addon.name, EVENT_ALLIANCE_POINT_UPDATE)
		PVPJbutton:SetHidden(true)
	end
end