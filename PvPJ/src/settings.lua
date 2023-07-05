local addon = PVPJ

function addon:LoadSettingsMenu()

	local menu = LibStub("LibAddonMenu-2.0")
	local default = addon.default

	-- menu
	local panel = {
		type = "panel",
		name = addon.displayName,
		displayName = addon.displayName,
		author = addon.author,
        version = addon.version,
		website = "http://www.esoui.com/downloads/info1527-ScootworksAP.html",
		slashCommand = "/pvpj",
		registerForRefresh = true,
		registerForDefaults = true,
	}

	local options = {
		{
			type = "header",
			name = SI_AUDIO_OPTIONS_GENERAL,
		},
		{
			type = "checkbox",
			name = SI_SETTINGSYSTEMPANEL6,
			getFunc = function() return self.savedVars.debug end,
			setFunc = function(value)
				self.savedVars.debug = value
				self:ControlHandler()
				self:CopySV()
			end,
			default = default.debug,
		},
		{
			type = "colorpicker",
			name = SI_PVPJOURNAL_TEXTCOLOR,
			tooltip = SI_PVPJOURNAL_TEXTCOLOR_TT,
			default = ZO_ColorDef:New(unpack(default.colours.text)),
			getFunc = function() return unpack(self.savedVars.colours.text) end,
			setFunc = function(r, g, b)
				self.savedVars.colours.text = {r, g, b}
				self:RefreshColorTable()
			end,
			disabled = function() return not self.savedVars.showAPLog end,
		},
		{
			type = "checkbox",
			name = zo_strformat("[<<2>>] <<1>>", GetString(SI_CHAT_CONFIG_SHOW_TIMESTAMP), GetTimeString()),
			tooltip = zo_strformat("<<1>> / <<2>>", GetString(SI_CHAT_CONFIG_SHOW_TIMESTAMP), GetString(SI_CHAT_CONFIG_HIDE_TIMESTAMP)),
			getFunc = function() return self.savedVars.showTimeStamp end,
			setFunc = function(value)
				self.savedVars.showTimeStamp = value
				self:CopySV()
			end,
			default = default.showTimeStamp,
		},
		{
			type = "colorpicker",
			name = SI_PVPJOURNAL_TIMESTAMP_COLORPICKER,
			tooltip = SI_PVPJOURNAL_TIMESTAMP_COLORPICKER_TT,
			default = ZO_ColorDef:New(unpack(default.colours.timestamp)),
			getFunc = function() return unpack(self.savedVars.colours.timestamp) end,
			setFunc = function(r, g, b)
				self.savedVars.colours.timestamp = {r, g, b}
				self:RefreshColorTable()
			end,
			disabled = function() return not self.savedVars.showTimeStamp end,
		},
		{
			type = "header",
			name = self:GetIconFormat("ava", "100%")..GetString(SI_MAIN_MENU_ALLIANCE_WAR),
		},
		{
			type = "checkbox",
			name = zo_strformat(SI_PVPJOURNAL_QUEUE_POSITION, GetString(SI_GAMEPAD_CAMPAIGN_BROWSER_QUEUE_POSITION_HEADER)),
			tooltip = SI_PVPJOURNAL_QUEUE_POSITION_TT,
			getFunc = function() return self.savedVars.showQueuePosition end,
			setFunc = function(value)
				self.savedVars.showQueuePosition = value
				self:CopySV()
				self:HandlerAlliance()
			end,
			default = default.showQueuePosition,
		},
		{
			type = "checkbox",
			name = SI_PVPJOURNAL_QUEUE_ACCEPT,
			tooltip = SI_PVPJOURNAL_QUEUE_ACCEPT_TT,
			getFunc = function() return self.savedVars.autoAcceptCampaign end,
			setFunc = function(value)
				self.savedVars.autoAcceptCampaign = value
				self:CopySV()
				self:HandlerAlliance()
			end,
			default = default.autoAcceptCampaign,
		},
		--[[
		{
			type = "checkbox",
			name = SI_WORLD_MAP_ACTION_RESPAWN_AT_FORWARD_CAMP,
			tooltip = SI_PVPJOURNAL_FORWARD_CAMP_TT,
			getFunc = function() return self.savedVars.showForwardCamp end,
			setFunc = function(value)
				self.savedVars.showForwardCamp = value
				self:CopySV()
				HandlerForwardCamp()
			end,
			default = default.showForwardCamp,
		},
		]]
		{
			type = "header",
			name = self:GetIconFormat("alliancePoints", "75%")..GetString(SI_GAMEPAD_INVENTORY_ALLIANCE_POINTS),
		},
		{
			type = "checkbox",
			name = SI_PVPJOURNAL_ENABLE_CHATOUTPUT,
			tooltip = SI_PVPJOURNAL_ENABLE_CHATOUTPUT_TT,
			getFunc = function() return self.savedVars.showAPLog end,
			setFunc = function(value)
				self.savedVars.showAPLog = value
				self:CopySV()
			end,
			default = default.showAPLog,
		},
		{
			type = "checkbox",
			name = SI_PVPJOURNAL_REASON,
			tooltip = SI_PVPJOURNAL_REASON_TT,
			getFunc = function() return self.savedVars.showAPreason end,
			setFunc = function(value)
				self.savedVars.showAPreason = value
				self:CopySV()
			end,
			default = default.showAPreason,
			disabled = function() return not self.savedVars.showAPLog end,
		},
		{
			type = "checkbox",
			name = SI_PVPJOURNAL_AMOUNT_AP,
			tooltip = SI_PVPJOURNAL_AMOUNT_AP_TT,
			getFunc = function() return self.savedVars.showAPtotal end,
			setFunc = function(value)
				self.savedVars.showAPtotal = value
				self:CopySV()
			end,
			default = default.showAPtotal,
			disabled = function() return not self.savedVars.showAPLog end,
		},
		{
			type = "slider",
			name = GetString(SI_GAMEPAD_INVENTORY_ALLIANCE_POINTS).." ≥ tick",
			tooltip = SI_PVPJOURNAL_SETAPVALUE_TT,
			min = 0,
			max = 1000,
			step = 10,
			clampInput = false,
			inputLocation = "right",
			getFunc = function() return self.savedVars.setAPvalue end,
			setFunc = function(value)
				self.savedVars.setAPvalue = value
				self:CopySV()
			end,
			default = default.setAPvalue,
			disabled = function() return not self.savedVars.showAPLog end,
		},
		{
			type = "header",
			name = self:GetIconFormat("notification", "100%")..GetString(SI_KEYBINDINGS_LAYER_NOTIFICATIONS),
		},
		{
			type = "checkbox",
			name = zo_strformat(SI_PVPJOURNAL_NOTIFICATIONS_YOURKILL, self:GetIconFormat("kill", "100%")),
			getFunc = function() return self.savedVars.showNotifications_yourKill end,
			setFunc = function(value)
				self.savedVars.showNotifications_yourKill = value
				self:CopySV()
			end,
			default = default.showNotifications_yourKill,
		},
		{
			type = "checkbox",
			name = zo_strformat(SI_PVPJOURNAL_NOTIFICATIONS_YOURDEATH, self:GetIconFormat("death", "100%")),
			getFunc = function() return self.savedVars.showNotifications_yourDeath end,
			setFunc = function(value)
				self.savedVars.showNotifications_yourDeath = value
				self:CopySV()
			end,
			default = default.showNotifications_yourDeath,
		},
		{
			type = "checkbox",
			name = zo_strformat(SI_PVPJOURNAL_NOTIFICATIONS_RESURRECTION, self:GetIconFormat("ressurected", "100%")),
			getFunc = function() return self.savedVars.showNotifications_Resurrection end,
			setFunc = function(value)
				self.savedVars.showNotifications_Resurrection = value
				self:CopySV()
			end,
			default = default.showNotifications_Resurrection,
		},
		{
			type = "colorpicker",
			name = SI_PVPJOURNAL_NOTIFICATIONS_TARGET_COLOR,
			default = ZO_ColorDef:New(unpack(default.colours.player)),
			getFunc = function() return unpack(self.savedVars.colours.player) end,
			setFunc = function(r, g, b)
				self.savedVars.colours.player = {r, g, b}
				self:RefreshColorTable()
			end,
			disabled = function() return not (self.savedVars.showNotifications_yourKill or self.savedVars.showNotifications_yourDeath or self.savedVars.showNotifications_Resurrection) end,
		},
		{
			type = "header",
			name = self:GetIconFormat("group", "100%")..GetString(SI_INTERFACE_OPTIONS_NAMEPLATES_GROUP_INDICATORS),
		},
		{
			type = "checkbox",
			name = SI_PVPJOURNAL_GROUP_INVITE_ENABLE,
			tooltip = SI_PVPJOURNAL_GROUP_INVITE_ENABLE_TT,
			getFunc = function() return self.savedVars.allowGroupInvite end,
			setFunc = function(value)
				self.savedVars.allowGroupInvite = value
				self:CopySV()
				self:HandlerChatMessages()
			end,
			width = "half",
			default = default.allowGroupInvite,
		},
		{
			type = "editbox",
			name = SI_PVPJOURNAL_GROUP_INVITE_STRING,
			tooltip = SI_PVPJOURNAL_GROUP_INVITE_STRING_TT,
			getFunc = function() return self.savedVars.keywordInvite end,
			setFunc = function(text)
				self.savedVars.keywordInvite = text
				self:CopySV()
			end,
			isMultiline = false,
			isExtraWide = false,
			width = "half",
			disabled = function() return not self.savedVars.allowGroupInvite end,
			default = default.keywordInvite,
		},
		{
			type = "checkbox",
			name = SI_PVPJOURNAL_GROUP_LEAD,
			tooltip = SI_PVPJOURNAL_GROUP_LEAD_TT,
			getFunc = function() return self.savedVars.allowPassCrown end,
			setFunc = function(value)
				self.savedVars.allowPassCrown = value
				self:CopySV()
				self:HandlerChatMessages()
			end,
			width = "half",
			default = default.allowPassCrown,
		},
		{
			type = "editbox",
			name = SI_PVPJOURNAL_GROUP_LEAD_STRING,
			tooltip = SI_PVPJOURNAL_GROUP_LEAD_STRING_TT,
			getFunc = function() return self.savedVars.keywordLeader end,
			setFunc = function(text)
				self.savedVars.keywordLeader = text
				self:CopySV()
			end,
			isMultiline = false,
			isExtraWide = false,
			width = "half",
			disabled = function() return not self.savedVars.allowPassCrown end,
			default = default.keywordLeader,
		}
	}

	menu:RegisterAddonPanel(addon.name.."OptionsMenu", panel)
	menu:RegisterOptionControls(addon.name.."OptionsMenu", options)

end