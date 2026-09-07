-- Run from addon/: lua DoiteDPS/Tests/WarriorWeapons_spec.lua
-- Reuse the catalog fixture; equipment updates are deliberately delayed.
dofile("DoiteDPS/Tests/WarriorCatalog_spec.lua")
local D = DoiteDPS
local W = D.Profiles.Warrior
local now, class, cursor, pending = 0, "WARRIOR", nil, nil
local gear, bags, locked = {}, {}, false
local sword, shield, twohand = "item:11:7:0:0", "item:12:0:0:0", "item:13:8:0:0"
local locations = { [sword] = "INVTYPE_WEAPON", [shield] = "INVTYPE_SHIELD", [twohand] = "INVTYPE_2HWEAPON" }
function UnitClass() return class, class end
function GetTime() return now end
function GetInventoryItemLink(_, slot) return gear[slot] end
function GetContainerNumSlots(bag) return bag == 0 and 4 or 0 end
function GetContainerItemLink(_, slot) return bags[slot] end
function GetContainerItemInfo() return "texture", 1, locked or nil end
function GetItemInfo(key) return key, key, 1, 1, "", "", 1, locations[key] end
function CursorHasItem() return cursor ~= nil end
function CreateFrame()
    return {
        Show = function(self) self.visible = true end,
        Hide = function(self) self.visible = false end,
        SetScript = function(self, key, fn) self[key] = fn end,
    }
end
function D:Print(text) self.lastMessage = text end
function D:GetActiveProfile() return class == "WARRIOR" and W or nil end
function D:SetMode(mode) self.DB.mode = mode end
function D:SetEntryBinding(profile, entry, mode)
    local db = self:GetProfileDB(profile.key)
    db.entryBindings = db.entryBindings or {}
    db.entryBindings[entry] = mode
    return true
end
function PickupInventoryItem(slot)
    assert(not cursor)
    cursor = { key = gear[slot], inventory = slot }
end
function PickupContainerItem(_, slot)
    if cursor then
        assert(cursor.inventory and not bags[slot])
        local old = cursor
        pending = function() bags[slot], gear[old.inventory] = old.key, nil end
        cursor = nil
    else
        assert(bags[slot])
        cursor = { key = bags[slot], bagSlot = slot }
    end
end
function EquipCursorItem(slot)
    assert(cursor and cursor.bagSlot)
    local old = cursor
    pending = function()
        assert(slot ~= 17 or locations[gear[16]] ~= "INVTYPE_2HWEAPON", "main hand must precede shield")
        assert(locations[old.key] ~= "INVTYPE_2HWEAPON" or not gear[17], "shield must be stowed first")
        gear[slot], bags[old.bagSlot] = old.key, gear[slot]
    end
    cursor = nil
end
function ClearCursor() cursor = nil end
local function Tick(ack)
    now = now + 0.11
    if ack and pending then local fn = pending; pending = nil; fn() end
    if W.weaponFrame and W.weaponFrame.visible then W.weaponFrame.OnUpdate() end
end
local function Reset()
    W:FinishWeaponSwap(false)
    D.DB.mode = "arms_berserker_aoe"
    D:GetProfileDB(W.key).entryBindings = {
        single = "arms_berserker_single", aoe = "arms_berserker_aoe",
    }
    gear, bags = { [16] = twohand }, { sword, shield }
    now, cursor, pending, locked, class = 0, nil, nil, false, "WARRIOR"
end
Reset()
assert(W:SaveWeapons("dps"))
assert(W:SetWeapon("tank", "main", sword))
assert(W:SetWeapon("tank", "off", shield))
assert(not W:SetWeapon("tank", "main", twohand), "reject two-hander in visual tank slot")
assert(not W:SetWeapon("tank", "off", sword), "reject weapon in shield slot")
assert(not W:SetWeapon("dps", "main", sword), "reject one-hander in damage slot")
assert(W:SetWeapon("tank", "off", nil), "visual slot can be cleared")
assert(not D:GetProfileDB(W.key).weaponSets.tank.off)
assert(W:SetWeapon("tank", "off", shield))
assert(not W:SaveWeapons("tank"))
gear = { [16] = sword, [17] = shield }
assert(W:SaveWeapons("tank"))
assert(not W:SaveWeapons("dps"))
Reset()
assert(DoiteDPS_WarriorRole())
assert(W.weaponSwap and D.DB.mode == "arms_berserker_aoe", "wait for equipment acknowledgement")
assert(not W:Execute("arms_berserker_aoe"), "pause output during swap")
assert(not W:SaveWeapons("dps"))
assert(DoiteDPS_WarriorRole() and W.weaponSwap.role == "tank", "double click cannot reverse swap")
Tick(false)
assert(not gear[17] and D.DB.mode == "arms_berserker_aoe")
Tick(true)
assert(gear[16] == sword and not gear[17])
Tick(true)
assert(gear[17] == shield and not W.weaponSwap)
assert(D.DB.mode == "protection_aoe", "preserve AoE entry")
local bindings = D:GetProfileDB(W.key).entryBindings
assert(bindings.single == "protection_single" and bindings.aoe == "protection_aoe")
assert(W:Execute(bindings.single) and D.Profiles.WarriorProtection.executed == "single")
assert(DoiteDPS_WarriorRole())
Tick(true); Tick(true)
assert(gear[16] == twohand and not gear[17] and not W.weaponSwap)
assert(bindings.single == "arms_berserker_single" and bindings.aoe == "arms_berserker_aoe")
assert(W:Execute(bindings.aoe) and D.Profiles.WarriorArms.executed == "aoe")
Reset()
bags[2] = nil
assert(not DoiteDPS_WarriorRole() and gear[16] == twohand and not pending, "missing shield aborts before swap")
Reset()
bags[1] = "item:11:99:0:0"
assert(not DoiteDPS_WarriorRole(), "different enchant is not the saved weapon")
Reset()
cursor = { key = shield }
assert(not DoiteDPS_WarriorRole() and cursor, "preserve preexisting cursor item")
Reset()
locked = true
assert(DoiteDPS_WarriorRole())
Tick(true)
assert(not pending and gear[16] == twohand)
locked = false
Tick(false); Tick(true); Tick(true)
assert(D.DB.mode == "protection_aoe", "finish after transient item lock")
Reset()
assert(DoiteDPS_WarriorRole())
now = 6
Tick(false)
assert(not W.weaponSwap and D.DB.mode == "arms_berserker_aoe", "timeout retains rotation")
Reset()
gear, bags = { [16] = sword, [17] = shield }, { twohand, sword, sword, sword }
D.DB.mode = "protection_single"
assert(not DoiteDPS_WarriorRole() and gear[17] == shield and not pending, "full backpack aborts before shield removal")
Reset()
assert(DoiteDPS_WarriorRole("tank"))
Tick(true) -- main hand equipped, shield request still pending
now = 6
Tick(false)
assert(not W.weaponSwap and gear[16] == sword and D.DB.mode == "arms_berserker_aoe")
Tick(true) -- late acknowledgement must not commit a timed-out role change
assert(D.DB.mode == "arms_berserker_aoe")
now = 0
assert(DoiteDPS_WarriorRole("tank") and D.DB.mode == "protection_aoe", "retry reconciles partial/late equipment changes")
assert(DoiteDPS_WarriorRole("tank") and not W.weaponSwap, "explicit tank request is idempotent")
Reset()
assert(DoiteDPS_WarriorRole("tank"))
W:OnEvent("PLAYER_ENTERING_WORLD")
assert(not W.weaponSwap and D.DB.mode == "arms_berserker_aoe", "world transition cancels pending swap")
Reset()
D:GetProfileDB(W.key).weaponSets = nil
assert(not DoiteDPS_WarriorRole(), "unconfigured character cannot swap")
class = "SHAMAN"
assert(not DoiteDPS_WarriorRole(), "reject non-warriors")
print("WarriorWeapons_spec: async toggle, bindings, capture and failure checks passed")
