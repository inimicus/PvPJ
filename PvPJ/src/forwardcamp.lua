local addon = PVPJ

local function IsForwardCampUsable()
    --[[
    This function checks, if the forward camp is usable or not.
    ]]
    for i = 1, GetNumForwardCamps(1) do
        local usable = select(5, GetForwardCampPinInfo(1, i))
        if usable then
			-- debug
			LibSWF:ChatOutput(string.format("IsForwardCampUsable() index: %s, usable: %s", tostring(i), tostring(usable)), true, addon.savedVarCopy.debug, addon.name)
            return true
        end
    end
    return false
end

local function GetForwardCampId()
    --[[
    Check if you can respawn in keep/camp and return the keepId.
    ]]
    for i = 1, GetNumKeeps() do
        local keepId = GetKeepKeysByIndex(i)
        -- debug
        LibSWF:ChatOutput(string.format("GetForwardCampId() keepId: %s (%s)", keepId, GetKeepName(keepId)), true, addon.savedVarCopy.debug, addon.name)
        -- check
        if CanRespawnAtKeep(keepId) then
            return keepId
        end
    end
    return false
end

local function RespawnForwardCamp()
    --[[
    This function let you respawn in the camp. We integrated a second check again, because may you have
    a delay from IsForwardCampUsable() to this function (lag).
    ]]
    local campIndex = GetForwardCampId()
	-- debug
	LibSWF:ChatOutput(string.format("RespawnForwardCamp() campIndex: %s (%s)", tostring(campIndex), GetKeepName(campIndex)), true, addon.savedVarCopy.debug, addon.name)
	-- check
    if campIndex then
        RespawnAtForwardCamp(campIndex)
    end
end

local function CheckForwardCampVisible()
    --[[
    This function updates hisself to turn on/off the keybind in death window.
    ]]
	local isAVADeath = select(6, GetDeathInfo())
    if isAVADeath and IsInCyrodiil() and IsForwardCampUsable() and GetForwardCampId() then 
		-- debug
		LibSWF:ChatOutput("CheckForwardCampVisible() camp found", true, addon.savedVarCopy.debug, addon.name)
        return true
    else
        return false
    end
end

CampKeyStrip = ZO_Object:Subclass()

function CampKeyStrip:New(name, keybind, callback, visible, alignment)
	local obj = ZO_Object.New(self)
	obj:Init(name, keybind, callback, visible, alignment)
	return obj
end

function CampKeyStrip:Init(name, keybind, callback, visible, alignment)
	local function createStripDescriptor(name, keybind, callback, visible, alignment)
		return {{
			alignment = alignment or KEYBIND_STRIP_ALIGN_LEFT,
			name = name,
			keybind = keybind,
			callback = callback,
			visible = visible,
		}}
	end
	self.stripDescriptor = createStripDescriptor(name, keybind, callback, visible, alignment)
end

function CampKeyStrip:Add()
	if self.wasAdded then return end	
	KEYBIND_STRIP:AddKeybindButtonGroup(self.stripDescriptor)
	self.wasAdded = true
end

function CampKeyStrip:Remove()
	if self.wasAdded then
		KEYBIND_STRIP:RemoveKeybindButtonGroup(self.stripDescriptor)
		self.wasAdded = false
	end
end

local stripDescriptor = CampKeyStrip:New(GetString(SI_WORLD_MAP_ACTION_RESPAWN_AT_FORWARD_CAMP), "UI_SHORTCUT_QUICK_SLOTS", RespawnForwardCamp, CheckForwardCampVisible)

local function CallbackForwardCamp(oldState, newState)
    if newState == SCENE_SHOWN then
        stripDescriptor:Add()
    elseif newState == SCENE_HIDING then
        stripDescriptor:Remove()
    end
end

local function HandlerForwardCamp()
    --[[
    Enable or disable the tracking.
    ]]
    if addon.savedVarCopy.showForwardCamp then
        DEATH_FRAGMENT:RegisterCallback("StateChange", CallbackForwardCamp)
    else
        DEATH_FRAGMENT:UnregisterCallback("StateChange", CallbackForwardCamp)
    end
end