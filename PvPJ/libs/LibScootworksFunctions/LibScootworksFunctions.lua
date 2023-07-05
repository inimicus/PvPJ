local MAJOR, MINOR = "LibScootworksFunctions", 3
local LibSWF, oldminor = LibStub:NewLibrary(MAJOR, MINOR)
if not LibSWF then return end


------------------
-- LOCALIZATION --
------------------
local SI_LSF_ENLIGHTENED_POOL = "You have |cFFFFFF<<1>>|r enlightened points"
local SI_LSF_UPDATE_ADDON = "Please update this addon!\nIt does not work with this game version."
if GetCVar("language.2") == "de" then
	SI_LSF_ENLIGHTENED_POOL = "Ihr habt |cFFFFFF<<1>>|r Erfrischungspunkte"
	SI_LSF_UPDATE_ADDON = "Bitte aktualisiere diese Erweiterung!\nEs unterstützt diese Spielversion nicht."
end


-----------------
-- CHAT OUTPUT --
-----------------
local function ReturnSystemMessage(msg)
	--[[
	Send outputs always as system message
	]]
	if CHAT_SYSTEM.primaryContainer then
		CHAT_SYSTEM.primaryContainer:OnChatEvent(nil, msg, CHAT_CATEGORY_SYSTEM)
	else
		CHAT_SYSTEM:AddMessage(msg)
	end
end

function LibSWF:ChatOutput(msg, isDebugMessage, isInDebugMode, addonName, delayMs)
	local msg = tostring(msg)
	--[[
	Check if this message is a debug message or not
	]]
	if isDebugMessage then
		if not isInDebugMode then return end
		if addonName == "nil" or addonName == nil then
			msg = zo_strformat("|cFF0000[Debug]|r <<1>>", msg)
		else
			msg = zo_strformat("|cFF0000[<<1>> Debug]|r <<2>>", addonName, msg)
		end
	end
	--[[
	Send a message with a delay, as long there is a delay value.
	]]
	if delayMs then
		zo_callLater(function()
			ReturnSystemMessage(msg)
		end, delayMs)
		return
	end
	ReturnSystemMessage(msg)
end


-------------------------
-- COMPARE API VERSION --
-------------------------
function LibSWF:IsAddonVersionSameGameVersion(addonApiVersion1, addonApiVersion2, addonName)
	local addonApiVersion1 = addonApiVersion1 or 0
	local addonApiVersion2 = addonApiVersion2 or 0
	if GetAPIVersion() > math.max(addonApiVersion1, addonApiVersion2) then
		LibSWF:ChatOutput(SI_LSF_UPDATE_ADDON, true, true, addonName, 1000)
		return false
	end
	return true
end


-----------------
-- CHECK ADDON --
-----------------
function LibSWF:IsAddonStateEnabled(addonName)
	--[[
	Checks if there is a specific addon enabled
	]]
	local AM = GetAddOnManager()
    for i = 1, AM:GetNumAddOns() do
        local name, _, _, _, _, state = AM:GetAddOnInfo(i)
        if name == addonName and state == ADDON_STATE_ENABLED then
            return true
        end
    end
    return false
end

--------------------
-- SLASH COMMANDS --
--------------------
-- misc
SLASH_COMMANDS['/rl'] = function() ReloadUI("ingame") end
SLASH_COMMANDS['/ready'] = function() ZO_SendReadyCheck() end

-- language
SLASH_COMMANDS["/langfr"] = function() SetCVar("language.2", "fr") end
SLASH_COMMANDS["/langen"] = function() SetCVar("language.2", "en") end
SLASH_COMMANDS["/langde"] = function() SetCVar("language.2", "de") end

-- group commands
SLASH_COMMANDS['/lg'] = function() GroupLeave() end
SLASH_COMMANDS['/gl'] = function() GroupLeave() end
SLASH_COMMANDS['/gd'] = function() GroupDisband() end
SLASH_COMMANDS['/dg'] = function() GroupDisband() end

-- enlightenend
local function GetEnlightenedPoints()
	local getEnlightenedPool = GetEnlightenedPool()
	if getEnlightenedPool > 0 then
		LibSWF:ChatOutput(zo_strformat(SI_LSF_ENLIGHTENED_POOL, zo_round(getEnlightenedPool/250)))
		return
	end
	LibSWF:ChatOutput(zo_strformat(SI_ENLIGHTENED_STATE_LOST_HEADER))
end
SLASH_COMMANDS['/ep'] = GetEnlightenedPoints
SLASH_COMMANDS['/erfrischung'] = GetEnlightenedPoints

---------------
-- CHAT MENU --
---------------
function LibSWF:WrapFunction(object, functionName, wrapper)
    if type(object) == "string" then
        wrapper = functionName
        functionName = object
        object = _G
    end
    local originalFunction = object[functionName]
    object[functionName] = function(...) return wrapper(originalFunction, ...) end
end

local function ChatSystemShowOptions(originalFunc, ...)
	originalFunc(...)
	-- Add new options for the chat options
	AddCustomMenuItem(GetString(SI_ADDON_MANAGER_RELOAD), function() ReloadUI("ingame") end)
	-- Show menu
	ShowMenu(ZO_Menu.owner)
end
LibSWF:WrapFunction("ZO_ChatSystem_ShowOptions", ChatSystemShowOptions)