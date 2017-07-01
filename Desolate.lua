local addonName, mod = ...
_G[addonName] = mod

-- GLOBALS: GetSpellInfo, IsSpellInRange, UnitInRange, SLASH_DesolateHostFrameFix1

local DESOLATE_HOST_ENCOUNTER_ID = 2054
local SPIRIT_REALM = GetSpellInfo(235621)

local UnitDebuff, UnitIsPlayer = UnitDebuff, UnitIsPlayer

--
-- Blizzard Hook
--
local _IsSpellInRange = IsSpellInRange
local _UnitInRange = UnitInRange

-- AddOn Hook
local _GridFrame
local _GridUnitInRange
local _LibIsSpellInRange
local _VUHDO_isInRange

-- Grid
local function GridUnitInRealmRange(unit)
    DelegateRangeCheck(_GridUnitInRange, unit)
end

-- Replace IsSpellInRange(index, "bookType", "unit")
local function IsSpellInRealmRange(index, bookType, unit)
    DelegateRangeCheck(_IsSpellInRange, index, bookType, unit)
end

-- Replace SpellRange-1.0 IsSpellInRange. Little hacky but it works.
local function LibIsSpellInRealmRange(spellInput, unit)
    DelegateRangeCheck(_LibIsSpellInRange, spellInput, unit)
end

-- Replace UnitInRange(unit)
local function UnitInRealmRange(unit)
    DelegateRangeCheck(_UnitInRange, unit)
end

-- VUHDO override just to use our custom global functions
local function VUHDO_isInRealmRange(unit)
    DelegateRangeCheck(_VUHDO_isInRange, unit)
end

local function DelegateRangeCheck(originalFunc, ...)
    -- Make sure we are actually getting a unit to check against
    local unit
    local n = select('#', ...)
    for i = 1,n do
        local arg = select(i, ...)
        if UnitIsPlayer(arg) then
            unit = arg
            break;
        end
    end
    if not unit then
        -- Not our problem
        return originalFunc(...)
    end

    local playerRealm = UnitDebuff("player", SPIRIT_REALM)
    local unitRealm = UnitDebuff(unit, SPIRIT_REALM)

    -- If the realms aren't equal then the range is always false
    if playerRealm ~= unitRealm then
        -- Returning extra for UnitInRange, could be breaking but it doesn't interfere with any of the supported addons
        return false, true
    else
        return originalFunc(...)
    end
end

function mod:ReplaceGlobals()
    -- ElvUI
    if LibStub and LibStub.libs["SpellRange-1.0"] then
        _LibIsSpellInRange = LibStub.libs["SpellRange-1.0"].IsSpellInRange
        LibStub.libs["SpellRange-1.0"].IsSpellInRange = LibIsSpellInRealmRange
    end

    -- Vuhdo
    if VUHDO_isInRange then
        VUHDO_isInRange = VUHDO_isInRealmRange
    end

    if Grid then
        _GridFrame = Grid:GetModule("GridFrame")
        _GridUnitInRange = _GridFrame.UnitInRange
        _GridFrame.UnitInRange = GridUnitInRealmRange
    end

    -- Blizzard Raid Frames
    UnitInRange = UnitInRealmRange

    -- Any globals that use it
	IsSpellInRange = IsSpellInRealmRange
end

function mod:RestoreGlobals()

    if LibStub and LibStub.libs["SpellRange-1.0"] then
        LibStub.libs["SpellRange-1.0"].IsSpellInRange = _LibIsSpellInRange
    end

    if VUHDO_isInRange then
        VUHDO_isInRange = _VUHDO_isInRange
    end

    if Grid then
        _GridFrame.UnitInRange = _GridUnitInRange
    end
    
    UnitInRange = _UnitInRange
	IsSpellInRange = _IsSpellInRange
end

--@debug@

-- Replace IsSpellInRange(index, "bookType", "unit")
local function IsSpellInRenew(index, bookType, unit)
    local playerRealm = UnitBuff("player", "Renew")
    local unitRealm = UnitBuff(bookType or "", "Renew") or UnitBuff(unit or "", "Renew")

    -- If the realms aren't equal then the range is always false
    if playerRealm ~= unitRealm then
        return false
    else
        -- Otherwise, just return a regular range check
        return IsSpellInRange(index, bookType, unit)
    end
end

-- Replace SpellRange-1.0 IsSpellInRange. Little hacky but it works.
local function LibIsSpellInRenew(spellInput, unit)
    local playerRealm = UnitBuff("player", "Renew")
    local unitRealm = UnitBuff(bookType or "", "Renew")

    -- If the realms aren't equal then the range is always false
    if playerRealm ~= unitRealm then
        return false
    else
        -- Otherwise, just return a regular range check
        return _LibIsSpellInRange(spellInput, unit)
    end
end

-- Replace UnitInRange(unit)
local function UnitInRenew(unit)
    local playerRealm = UnitBuff("player", "Renew")
    local unitRealm = UnitBuff(unit, "Renew")

    -- If the realms aren't equal then the range is always false
    if playerRealm ~= unitRealm then
        -- Undocumented 2nd return. Always true from what I can tell.
        return false, true
    else
        -- Otherwise, just return a regular range check
        return _UnitInRange(unit)
    end
end

local function ReplaceTest()
    -- ElvUI
    if LibStub and LibStub.libs["SpellRange-1.0"] then
        _LibIsSpellInRange = LibStub.libs["SpellRange-1.0"].IsSpellInRange
        LibStub.libs["SpellRange-1.0"].IsSpellInRange = LibIsSpellInRealmRange
    end

    -- Blizzard Raid Frames
    UnitInRange = UnitInRenew

    -- Any globals that use it
	IsSpellInRange = IsSpellInRenew
end

local function RestoreTest()
    if LibStub and LibStub.libs["SpellRange-1.0"] then
        LibStub.libs["SpellRange-1.0"].IsSpellInRange = _LibIsSpellInRange
    end

    UnitInRange = _UnitInRange
	IsSpellInRange = _IsSpellInRange
end

function mod:EnableTest()
    self:ReplaceTest()
end

function mod:DisableTest()
    self:RestoreTest()
end

--@end-debug@

local frame = CreateFrame("Frame")

frame:RegisterEvent("ENCOUNTER_START")
frame:RegisterEvent("ENCOUNTER_END")

local function Enable()
	mod:ReplaceGlobals()
end

local function Disable()
    mod:RestoreGlobals()
end

frame:SetScript("OnEvent", function(_, event, encounterID)
    -- The Desolate Host Start
	if event == "ENCOUNTER_START" and encounterID == DESOLATE_HOST_ENCOUNTER_ID then
		Enable()
	elseif event == "ENCOUNTER_END" and encounterID == DESOLATE_HOST_ENCOUNTER_ID then
		Disable()
    end
end)

SLASH_DesolateHostFrameFix1 = "/dhff"
SlashCmdList["DesolateHostFrameFix"] = function(txt)
    if txt == "on" or txt == "enable" then
        Enable()
        print('Desolate Host Frame Fix: |cFF00FF00Enabled|r')
    elseif txt == "off" or txt == "disable" then
        Disable()
        print('Desolate Host Frame Fix: |cFFFF0000Disabled|r')        
    end
end