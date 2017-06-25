local addonName, mod = ...
_G[addonName] = mod

-- GLOBALS: GetSpellInfo, IsSpellInRange, UnitInRange

local SPIRIT_REALM = GetSpellInfo(235621)

--
-- Blizzard Hook
--
local _LibIsSpellInRange
local _IsSpellInRange = IsSpellInRange
local _UnitInRange = UnitInRange

-- Replace IsSpellInRange(index, "bookType", "unit")
local function IsSpellInRealm(index, bookType, unit)
    local playerRealm = UnitDebuff("player", SPIRIT_REALM)
    local unitRealm = UnitDebuff(bookType or "", SPIRIT_REALM) or UnitDebuff(unit, SPIRIT_REALM)

    -- If the realms aren't equal then the range is always false
    if playerRealm ~= unitRealm then
        return false, true
    else
        -- Otherwise, just return a regular range check
        return _IsSpellInRange(index, bookType, unit)
    end
end

-- Replace SpellRange-1.0 IsSpellInRange. Little hacky but it works.
local function LibIsSpellInRealm(spellInput, unit)
    local playerRealm = UnitDebuff("player", SPIRIT_REALM)
    local unitRealm = UnitDebuff(bookType or "", SPIRIT_REALM) or UnitDebuff(unit, SPIRIT_REALM)

    -- If the realms aren't equal then the range is always false
    if playerRealm ~= unitRealm then
        return false
    else
        -- Otherwise, just return a regular range check
        return _LibIsSpellInRange(spellInput, unit)
    end
end

-- Replace UnitInRange(unit)
local function UnitInRealm(unit)
    local playerRealm = UnitDebuff("player", SPIRIT_REALM)
    local unitRealm = UnitDebuff(unit, SPIRIT_REALM)

    -- If the realms aren't equal then the range is always false
    if playerRealm ~= unitRealm then
        -- Undocumented 2nd return. Always true from what I can tell.
        return false, true
    else
        -- Otherwise, just return a regular range check
        return _UnitInRange(unit)
    end
end

function mod:ReplaceGlobals()
    -- ElvUI
    _LibIsSpellInRange = LibStub.libs["SpellRange-1.0"].IsSpellInRange
    LibStub.libs["SpellRange-1.0"].IsSpellInRange = LibIsSpellInRealm

    -- Blizzard Raid Frames
    UnitInRange = UnitInRealm

    -- Any globals that use it
	IsSpellInRange = IsSpellInRealm
end

function mod:RestoreGlobals()
    LibStub.libs["SpellRange-1.0"].IsSpellInRange = _LibIsSpellInRange
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
local function LibIsSpellInRealm(spellInput, unit)
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
    _LibIsSpellInRange = LibStub.libs["SpellRange-1.0"].IsSpellInRange
    LibStub.libs["SpellRange-1.0"].IsSpellInRange = LibIsSpellInRealm

    -- Blizzard Raid Frames
    UnitInRange = UnitInRenew

    -- Any globals that use it
	IsSpellInRange = IsSpellInRenew
end

local function RestoreTest()
    LibStub.libs["SpellRange-1.0"].IsSpellInRange = _LibIsSpellInRange
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
frame:RegisterEvent("ADDON_LOADED")

local function Enable()
	ReplaceGlobals()
end

local function Disable()
    RestoreGlobals()
end

local i = 1;
mod.addons = {}
frame:SetScript("OnEvent", function(_, event, encounterID)
    -- The Desolate Host Start
	if event == "ENCOUNTER_START" and encounterID == 2054 then
		Enable()
	elseif event == "ENCOUNTER_END" then
		Disable()
	elseif event == "ADDON_LOADED" then
        i = i + 1
        if encounterID == "DesolateFrameFix" or encounterID == "ElvUI" then
            mod.addons[encounterID] = i
        end
    end
end)
