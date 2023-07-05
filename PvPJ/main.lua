local addon = {
	name = "PvPJ",
	displayName = "|cFF3DA5PvP|r Journal",
	displayNameShort = "|cFF3DA5PvPJ|r",
	author = "Scootworks (Updated by g4rr3t)",
	version = "27",
	api = {101038, nil},
	savedVarVersion = "1",
}

local LibSWF = LibScootworksFunctions
addon.LibSWF = LibSWF

--------------
-- SETTINGS --
--------------
function addon:ControlHandler()
	addon:HandlerAlliance()
	addon:HandlerCombat()
	addon:HandlerChatMessages()
	addon:HandlerCampaign()
end

local function SetPlayerEnvironment()
	addon.inAvaWorld = IsPlayerInAvAWorld()
	addon.inWorldBg = IsActiveWorldBattleground()
	-- debug
	LibSWF:ChatOutput(string.format("SetPlayerEnvironment() inAvaWorld: %s, inWorldBg: %s", tostring(addon.inAvaWorld), tostring(addon.inWorldBg)), true, addon.savedVarCopy.debug, addon.name)
end


----------
-- INIT --
----------
function addon:LoadSavedVariables()
	local default = {
		debug = false,
		keywordLeader = "!lead",
		keywordInvite = "!invite",
		allowGroupInvite = true,
		allowPassCrown = true,
		showForwardCamp = false,
		showTimeStamp = true,
		showAPLog = true,
		showAPtotal = true,
		showQueuePosition = true,
		showAPreason = true,
		autoAcceptCampaign = true,
		showNotifications_yourKill = true,
		showNotifications_yourDeath = true,
		showNotifications_Resurrection = true,
		setAPvalue = 500,
		colours = {
			text = { 0, 0.67, 1, 1 },
			timestamp = { 0.56, 0.56, 0.56, 1 },
			player = { 1, 1, 1, 1 },
		},
	}
	self.default = default
	-- savedVar
	self.savedVars = ZO_SavedVars:NewAccountWide(addon.name .. "_Save", addon.savedVarVersion, GetWorldName(), default)
	self:CopySV()
end

local function OnAddOnLoaded(_, addonName)
	if addonName ~= addon.name then return end
	EVENT_MANAGER:UnregisterForEvent(addon.name, EVENT_ADD_ON_LOADED)
	
	if not LibSWF:IsAddonVersionSameGameVersion(addon.api[1], addon.api[2], addon.name) then return end

	addon:LoadSavedVariables()
	addon:LoadSettingsMenu()
	addon:RefreshColorTable()
	addon:CreateButton()
	
	-- debug
	LibSWF:ChatOutput("loaded", true, addon.savedVarCopy.debug, addon.name, 1500)

	-- EVENTS
	EVENT_MANAGER:RegisterForEvent(addon.name, EVENT_PLAYER_ACTIVATED, function()
		SetPlayerEnvironment()
		addon:ControlHandler()
	end)
end

EVENT_MANAGER:RegisterForEvent(addon.name, EVENT_ADD_ON_LOADED, OnAddOnLoaded)

PVPJ = addon
