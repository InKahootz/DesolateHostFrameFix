local addonName, mod = ...
_G[addonName] = mod

-- GLOBALS: GetSpellInfo, IsSpellInRange, UnitInRange

local SPIRIT_REALM = GetSpellInfo(235621)

local UnitDebuff, UnitIsPlayer = UnitDebuff, UnitIsPlayer

--
-- Blizzard Hook
--
local _IsSpellInRange = IsSpellInRange
local _UnitInRange = UnitInRange

-- AddOn Hook
local _LibIsSpellInRange
local _VUHDO_isInRange

-- Replace IsSpellInRange(index, "bookType", "unit")
local function IsSpellInRealmRange(index, bookType, unit)
    local playerRealm = UnitDebuff("player", SPIRIT_REALM)
    local unitRealm = UnitDebuff(bookType or "", SPIRIT_REALM) or UnitDebuff(unit, SPIRIT_REALM)

    -- If the realms aren't equal then the range is always false
    if UnitIsPlayer(unit) or playerRealm ~= unitRealm then
        return false
    else
        -- Otherwise, just return a regular range check
        return _IsSpellInRange(index, bookType, unit)
    end
end

-- Replace SpellRange-1.0 IsSpellInRange. Little hacky but it works.
local function LibIsSpellInRealmRange(spellInput, unit)
    local playerRealm = UnitDebuff("player", SPIRIT_REALM)
    local unitRealm = UnitDebuff(bookType or "", SPIRIT_REALM) or UnitDebuff(unit, SPIRIT_REALM)

    -- If the realms aren't equal then the range is always false
    if UnitIsPlayer(unit) and playerRealm ~= unitRealm then
        return false
    else
        -- Otherwise, just return a regular range check
        return _LibIsSpellInRange(spellInput, unit)
    end
end

-- Replace UnitInRange(unit)
local function UnitInRealmRange(unit)
    local playerRealm = UnitDebuff("player", SPIRIT_REALM)
    local unitRealm = UnitDebuff(unit, SPIRIT_REALM)

    -- If the realms aren't equal then the range is always false
    if UnitIsPlayer(unit) and playerRealm ~= unitRealm then
        -- Undocumented 2nd return. Always true from what I can tell.
        return false, true
    else
        -- Otherwise, just return a regular range check
        return _UnitInRange(unit)
    end
end

-- VUHDO override just to use our custom global functions
local function VUHDO_isInRealmRange(unit)
    if UnitIsPlayer(unit) then
        return UnitInRealmRange(unit)
    else
        return _VUHDO_isInRange
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
	ReplaceGlobals()
end

local function Disable()
    RestoreGlobals()
end

frame:SetScript("OnEvent", function(_, event, encounterID)
    -- The Desolate Host Start
	if event == "ENCOUNTER_START" and encounterID == 2054 then
		Enable()
	elseif event == "ENCOUNTER_END" then
		Disable()
    end
end)
