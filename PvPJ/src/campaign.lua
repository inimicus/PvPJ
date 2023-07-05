local addon = PVPJ
local LibSWF = addon.LibSWF
local PLAYER_UNIT = "player"


----------------------------
-- CAMPAIGN QUEUE POSITION--
----------------------------
local function GetSoloOrGroupMessage(isGroup, position)
	return isGroup and (zo_strformat(SI_CAMPAIGN_BROWSER_GROUP_QUEUED, position)) or zo_strformat(SI_CAMPAIGN_BROWSER_SOLO_QUEUED, position)
end

local function UnregisterCampaignPositionState()
	EVENT_MANAGER:UnregisterForEvent(addon.name, EVENT_CAMPAIGN_QUEUE_POSITION_CHANGED)
end

local function OnCampaignQueuePositionChanged(_, campaignId, isGroup, position)
	if position < 1 or not addon.savedVarCopy.showQueuePosition then
		UnregisterCampaignPositionState()
		return
	end
	-- output
	local messageParams = CENTER_SCREEN_ANNOUNCE:CreateMessageParams(CSA_CATEGORY_SMALL_TEXT, SOUNDS.NONE)
	messageParams:SetText(string.format("%s - %s", GetAllianceColor(GetUnitAlliance(PLAYER_UNIT)):Colorize(GetCampaignName(campaignId)), GetSoloOrGroupMessage(isGroup, position)))
	CENTER_SCREEN_ANNOUNCE:AddMessageWithParams(messageParams)
	-- debug
	LibSWF:ChatOutput(string.format("isGroup: %s, campaignId: %s, position: %s", tostring(isGroup), campaignId, position), true, addon.savedVarCopy.debug, addon.name)
end
--[[
SLASH_COMMANDS['/testqueueposition'] = function()
	OnCampaignQueuePositionChanged(_, 80, false, 5)
	OnCampaignQueuePositionChanged(_, 81, true, 10)
end
]]

local function HandlerQueuePosition()
	if addon.savedVarCopy.showQueuePosition or addon.savedVarCopy.debug then
		EVENT_MANAGER:RegisterForEvent(addon.name, EVENT_CAMPAIGN_QUEUE_POSITION_CHANGED, OnCampaignQueuePositionChanged)
	else
		UnregisterCampaignPositionState()
	end
end


--------------------------
-- CAMPAIGN AUTO ACCEPT --
--------------------------
local function UnregisterCampaignQueueState()
	EVENT_MANAGER:UnregisterForEvent(addon.name, EVENT_CAMPAIGN_QUEUE_STATE_CHANGED)
end

local function OnCampaignQueueStateChanged(_, campaignId, isGroup, state)
	if not addon.savedVarCopy.autoAcceptCampaign then
		UnregisterCampaignQueueState()
		return
	end
	-- debug
	LibSWF:ChatOutput(string.format("campaignId: %s, isGroup: %s, state: %s", campaignId, tostring(isGroup), tostring(state)), true, addon.savedVarCopy.debug, addon.name)
	-- check state
	if state ~= CAMPAIGN_QUEUE_REQUEST_STATE_CONFIRMING then return end
	-- accept with "_, _, true"
	ConfirmCampaignEntry(campaignId, isGroup, true)
	-- output
	ZO_Alert(UI_ALERT_CATEGORY_ERROR, SOUNDS.GENERAL_ALERT_ERROR, zo_strformat("<<1>> <<2>>", GetString(SI_CAMPAIGN_ENTER_MESSAGE), GetCampaignName(campaignId)))
	-- if you don't unregister the event, you get kicked out of the game for spam!
	UnregisterCampaignQueueState()
end

local function HandlerQueueState()
	if addon.savedVarCopy.autoAcceptCampaign or addon.savedVarCopy.debug then
		EVENT_MANAGER:RegisterForEvent(addon.name, EVENT_CAMPAIGN_QUEUE_STATE_CHANGED, OnCampaignQueueStateChanged)
	else
		UnregisterCampaignQueueState()
	end
end


--------------
-- CAMPAIGN --
--------------
function addon:HandlerCampaign()
	HandlerQueuePosition()
	HandlerQueueState()
end