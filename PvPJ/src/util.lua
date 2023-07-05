local addon = PVPJ


-----------
-- ICONS --
-----------
local iconTable = {
	--[[
	This table defines all icons that are used in the addon.
	]]
	["kill"]			= "esoui/art/icons/mapkey/mapkey_battle.dds",
	["death"]			= "esoui/art/treeicons/gamepad/gp_tutorial_idexicon_death.dds",
	["ressurected"]		= "esoui/art/icons/mapkey/mapkey_enchanter.dds",
	["alliancePoints"]	= "esoui/art/currency/alliancepoints_64.dds",
	["time"]			= "esoui/art/miscellaneous/timer_64.dds",
	["bg"]				= "esoui/art/lfg/lfg_indexicon_battlegrounds_up.dds",
	["ava"]				= "esoui/art/lfg/lfg_indexicon_alliancewar_up.dds",
	["group"]			= "esoui/art/lfg/lfg_indexicon_group_up.dds",
	["notification"]	= "esoui/art/journal/journal_tabicon_cadwell_up.dds",
}
function addon:GetIconFormat(icon, size)
	--[[
	Simplify zo_iconFormat and grab the icon path from iconTable.
	]]
	return zo_iconFormat(iconTable[icon], size, size)
end


------------
-- COLORS --
------------
function addon:RefreshColorTable()
	--[[
	This function is used in the AddonLoadings and when you choose a color in colorpicker.
	]]
	self.colorTable = {
		["text"] = ZO_ColorDef:New(unpack(type(self.savedVars.colours["text"]) == "table" and self.savedVars.colours["text"] or self.default.colours["text"])),
		["timestamp"] = ZO_ColorDef:New(unpack(type(self.savedVars.colours["timestamp"]) == "table" and self.savedVars.colours["timestamp"] or self.default.colours["timestamp"])),
		["player"] = ZO_ColorDef:New(unpack(type(self.savedVars.colours["player"]) == "table" and self.savedVars.colours["player"] or self.default.colours["player"])),
	}
end

function addon:GetMyColor(formatType)
	--[[
	A little color grabber from the RefreshColorTable() function.
	]]
	return self.colorTable[formatType]
end


---------------
-- TIMESTAMP --
---------------
function addon:GetTimeStampFormat()
	--[[
	This functions returns a formatted time string, as long this timestamp is activate in settings menu.
	]]
	return (self.savedVarCopy.showTimeStamp and self:GetMyColor("timestamp"):Colorize(string.format("[%s] ", GetTimeString()))) or ""
end


---------------------
-- USERNAME FORMAT --
---------------------
function addon:GetUserFacingName(attackerRawName, attackerDisplayName)
	if not IsDecoratedDisplayName(attackerRawName) and attackerDisplayName ~= "" then
		-- We have a character name and a display name, so follow the setting
		return (ZO_ShouldPreferUserId() and attackerDisplayName) or attackerRawName
	end
	-- We either have two display names, or we weren't given a guaranteed display name, so just use the default fromName
	return attackerRawName
end


----------------
-- COPY TABLE --
----------------
function addon:CopySV()
	--[[
	During playing, it takes only the local savedVarCopy settings instead picking the savedVars.
	-> function ZO_DeepTableCopy(source, dest)
	]]
	-- savedVars = addon.savedVars
	-- savedVarCopy = addon.savedVarCopy
	self.savedVarCopy = {}
	self.savedVarCopy = self.savedVars
end