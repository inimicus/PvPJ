local addon = PVPJ
local LibSWF = addon.LibSWF
local PLAYER_UNIT = "player"

local SI_OUTPUT_KILL_DEATH = "<<1>><<2>> <<3>> |c<<4>>→ <<!a:5>>|r"


-----------
-- DEATH --
-----------
local function OnPlayerDead()
	for i = 1, GetNumKillingAttacks() do
		local attackerRawName, _, _, _, isPlayer, _, _, _, attackerDisplayName = GetKillingAttackerInfo(i)
		if attackerDisplayName == GetDisplayName() or attackerRawName == GetUnitName(PLAYER_UNIT) then
			LibSWF:ChatOutput("you killed yourself", true, addon.savedVarCopy.debug, addon.name)
			return
		end
		local attackName, _, _, wasKillingBlow = GetKillingAttackInfo(i)
		-- check
		if wasKillingBlow and isPlayer or addon.savedVarCopy.debug then
			-- count death
			addon.sessionTable.sessionDeath = addon.sessionTable.sessionDeath + 1
			-- return when output option is disabled
			if addon.savedVarCopy.showNotifications_yourDeath then
				LibSWF:ChatOutput(zo_strformat(SI_OUTPUT_KILL_DEATH, addon:GetTimeStampFormat(), addon:GetIconFormat("death", "100%"), 
					addon:GetMyColor("player"):Colorize(ZO_LinkHandler_CreatePlayerLink(addon:GetUserFacingName(attackerRawName, attackerDisplayName))), 
					addon:GetMyColor("text"):ToHex(), attackName))
					-- if death is detected, jump out of the function. in general there are max 5 abilities and there is a check GetNumKillingAttacks(). return is not really needed
			end
			return
		end
	end
end
--[[
SLASH_COMMANDS["/testonplayerdead"] = function()
	LibSWF:ChatOutput(zo_strformat(SI_OUTPUT_KILL_DEATH, addon:GetTimeStampFormat(), addon:GetIconFormat("death", "100%"), addon:GetMyColor("player"):Colorize(ZO_LinkHandler_CreatePlayerLink("@my victim")), addon:GetMyColor("text"):ToHex(), GetAbilityName(63075)))
end
]]


-----------
-- KILLS --
-----------
local onKillEventTable = {}
local msgKill = {}
local msgRess = {}

local function GenerateOnCombatEventMessages()
	--[[
	Grab the table inputs and generate a message and returns it.
	]]
	for targetName, layoutData in pairs(onKillEventTable) do
		local abilityName, abilityId = unpack(layoutData)
		if abilityId > 0 then
			addon.sessionTable.sessionKills = addon.sessionTable.sessionKills + 1
			if addon.savedVarCopy.showNotifications_yourKill then
				msgKill[#msgKill + 1] = zo_strformat(SI_OUTPUT_KILL_DEATH, addon:GetTimeStampFormat(), addon:GetIconFormat("kill", "100%"), addon:GetMyColor("player"):Colorize(ZO_LinkHandler_CreatePlayerLink(targetName)), addon:GetMyColor("text"):ToHex(), abilityName)
			end
		else
			if addon.savedVarCopy.showNotifications_Resurrection then
				msgRess[#msgRess + 1] = zo_strformat(SI_OUTPUT_THREE, addon:GetTimeStampFormat(), addon:GetIconFormat("ressurected", "100%"), addon:GetMyColor("player"):Colorize(ZO_LinkHandler_CreatePlayerLink(targetName)))
			end
		end
	end
	onKillEventTable = {}	
	return msgKill, msgRess
end

local function UnregisterEventUpdate()
	EVENT_MANAGER:UnregisterForUpdate(addon.name.."CombatEventUpdate")
end

local function GetOnCombatEventMessages()
	--[[
	This functions gets the output for kills and resurrections
	]]
	if next(onKillEventTable) == nil then return end
	-- generate outputs
	local outputKill, outputRess = GenerateOnCombatEventMessages()
	if outputKill ~= nil then
		for _, msgOutputKill in ipairs(outputKill) do
			LibSWF:ChatOutput(msgOutputKill)
		end
		msgKill = {}
	end
	if outputRess ~= nil then
		for _, msgOutputRess in ipairs(outputRess) do
			LibSWF:ChatOutput(msgOutputRess)
		end
		msgRess = {}
	end
	-- stop update
	UnregisterEventUpdate()
end

local function RegisterEventUpdate()
	EVENT_MANAGER:RegisterForUpdate(addon.name.."CombatEventUpdate", 500, GetOnCombatEventMessages)
end

local function OnCombatEvent(_, _, _, abilityName, _, _, sourceName, sourceType, targetName, _, _, _, _, _, _, _, abilityId)
	UnregisterEventUpdate()
	if sourceType == COMBAT_UNIT_TYPE_PLAYER or sourceType == COMBAT_UNIT_TYPE_PLAYER_PET and sourceName ~= targetName then
		-- debug
		LibSWF:ChatOutput(zo_strformat("OnCombatEvent() sourceName: <<1>>, targetName: <<2>>, abilityName: <<3>>", sourceName, targetName, abilityName), true, addon.savedVarCopy.debug, addon.name)
		-- new handler for killings/ressurections
		if abilityId > 0 then
			onKillEventTable[targetName] = {abilityName, abilityId}
		else
			onKillEventTable[targetName] = {abilityName, 0}
		end
	end
	RegisterEventUpdate()
end

local function OnBattlegroundKill(_, killedPlayerCharacterName, killedPlayerDisplayName, _, killingPlayerCharacterName, _, _, battlegroundKillType, killingAbilityId)
	UnregisterEventUpdate()
	if battlegroundKillType == BATTLEGROUND_KILL_TYPE_KILLING_BLOW then
		-- debug
		LibSWF:ChatOutput(zo_strformat("OnBattlegroundKill() sourceName: <<1>>, targetName: <<2>>, killingAbilityId: <<3>>", killingPlayerCharacterName, killedPlayerDisplayName, killingAbilityId), true, addon.savedVarCopy.debug, addon.name)
		-- adding to kill table
		onKillEventTable[addon:GetUserFacingName(killedPlayerCharacterName, killedPlayerDisplayName)] = {GetAbilityName(killingAbilityId), killingAbilityId}	
	end
	RegisterEventUpdate()
end

local function UnregisterCombatEvents()
	-- session deaths / kills
	EVENT_MANAGER:UnregisterForEvent(addon.name, EVENT_PLAYER_DEAD)
	-- combat events
	EVENT_MANAGER:UnregisterForEvent(addon.name, EVENT_COMBAT_EVENT)
	EVENT_MANAGER:UnregisterForEvent(addon.name, EVENT_BATTLEGROUND_KILL)
end

local function RegisterCombatEvents()
	-- session deaths / kills
	EVENT_MANAGER:RegisterForEvent(addon.name, EVENT_PLAYER_DEAD , OnPlayerDead)
	-- combat events
	if addon.inAvaWorld then
		EVENT_MANAGER:RegisterForEvent(addon.name, EVENT_COMBAT_EVENT, OnCombatEvent)
		EVENT_MANAGER:AddFilterForEvent(addon.name, EVENT_COMBAT_EVENT, REGISTER_FILTER_IS_ERROR, false, REGISTER_FILTER_COMBAT_RESULT, ACTION_RESULT_KILLING_BLOW, REGISTER_FILTER_UNIT_TAG, PLAYER_UNIT)
	elseif addon.inWorldBg then
		EVENT_MANAGER:RegisterForEvent(addon.name, EVENT_BATTLEGROUND_KILL, OnBattlegroundKill)
		EVENT_MANAGER:AddFilterForEvent(addon.name, EVENT_BATTLEGROUND_KILL, REGISTER_FILTER_UNIT_TAG, PLAYER_UNIT)
	end
end


------------
-- COMBAT --
------------
function addon:HandlerCombat()
	if self.inAvaWorld or self.inWorldBg or self.savedVarCopy.debug then
		RegisterCombatEvents()
	else
		UnregisterCombatEvents()
	end
end
