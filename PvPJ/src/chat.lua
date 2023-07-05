local addon = PVPJ
local LibSWF = addon.LibSWF
local PLAYER_UNIT = "player"
local PLAYER_DISPLAY_NAME = GetUnitDisplayName(PLAYER_UNIT)

----------------
-- GROUP LEAD --
----------------
local function PassGroupLead(fromDisplayName)
	--[[
	This function gives the grouplead to another person.
	That only works, if you are the group leader
	]]
	-- debug
	if fromDisplayName == zo_strformat(PLAYER_DISPLAY_NAME) then
		LibSWF:ChatOutput("send person = received person", true, addon.savedVarCopy.debug, addon.name)
		return
	end
	-- promote	
	local playerTag = nil
	for i = 1, GetGroupSize() do
		if string.match(zo_strformat(GetUnitDisplayName("group"..i)), fromDisplayName) and IsUnitOnline("group"..i) then
			GroupPromote("group"..i)
		end
	end
end

local function InviteMember(fromDisplayName)
	--[[
	This function invites players to your group.
	That only works, if you are the group leader
	]]
	-- debug
	if fromDisplayName == zo_strformat(PLAYER_DISPLAY_NAME) then
		LibSWF:ChatOutput("send person = received person", true, addon.savedVarCopy.debug, addon.name)
		return
	end
	-- invite
	if GetGroupSize() > 1 and IsUnitGroupLeader(PLAYER_UNIT) or not IsPlayerInGroup(zo_strformat(PLAYER_DISPLAY_NAME)) then
		GroupInviteByName(fromDisplayName)
		LibSWF:ChatOutput("send person = received person", true, addon.savedVarCopy.debug, addon.name)
	else
		-- GetString(SI_GROUPINVITERESPONSE8) -- "Only group leaders can invite others to group."
		LibSWF:ChatOutput(string.format("%s: %s", fromDisplayName, GetString(SI_GROUPINVITERESPONSE8)), true, addon.savedVarCopy.debug, addon.name)
	end
end

local function OnChatMessage(_, channelType, _, text, _, messageFromDisplayName)
	-- pass lead
	if addon.savedVarCopy.allowPassCrown and IsUnitGroupLeader(PLAYER_UNIT) then
		if channelType == CHAT_CHANNEL_PARTY or channelType == CHAT_CHANNEL_WHISPER then
			--if string.lower(zo_strformat(text)) == string.lower(addon.savedVarCopy.keywordLeader) then
			if text:lower() == addon.savedVarCopy.keywordLeader:lower() then
				PassGroupLead(zo_strformat(messageFromDisplayName))
			end
		end
	end
	-- invite member	
	if addon.savedVarCopy.allowGroupInvite then
		if channelType >= CHAT_CHANNEL_GUILD_1 and channelType <= CHAT_CHANNEL_OFFICER_5 or channelType == CHAT_CHANNEL_WHISPER then
			-- if string.lower(zo_strformat(text)) == string.lower(addon.savedVarCopy.keywordInvite) then
			if text:lower() == addon.savedVarCopy.keywordLeader:lower() then
				InviteMember(zo_strformat(messageFromDisplayName))
			end
		end
	end
end

function addon:HandlerChatMessages()
	--[[
	This function is a chat message handler. When one of those options is activate,
	then start to register. If all three options are disabled, unregister the events.
	]]
	if self.savedVarCopy.allowGroupInvite or self.savedVarCopy.allowPassCrown or self.savedVarCopy.debug then
		EVENT_MANAGER:RegisterForEvent(addon.name, EVENT_CHAT_MESSAGE_CHANNEL, OnChatMessage)
	else
		EVENT_MANAGER:UnregisterForEvent(addon.name, EVENT_CHAT_MESSAGE_CHANNEL)
	end
end