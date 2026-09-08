-- All the slots on the character sheet.
CompareStats_itemLocations = {
	INVTYPE_2HWEAPON = "MainHandSlot", -- Two-Hand
	INVTYPE_BODY = "ShirtSlot", -- Shirt
	INVTYPE_CHEST = "ChestSlot", -- Chest
	INVTYPE_CLOAK = "BackSlot", -- Back
	INVTYPE_FEET = "FeetSlot", -- Feet
	INVTYPE_FINGER = "Finger0Slot", -- Finger
	INVTYPE_FINGER_OTHER = "Finger1Slot", -- Finger_other
	INVTYPE_HAND = "HandsSlot", -- Hands
	INVTYPE_HEAD = "HeadSlot", -- Head
	INVTYPE_HOLDABLE = "SecondaryHandSlot", -- Held In Off-hand
	INVTYPE_LEGS = "LegsSlot", -- Legs
	INVTYPE_NECK = "NeckSlot", -- Neck
	INVTYPE_RANGED = "RangedSlot", -- Ranged
	INVTYPE_RELIC = "RangedSlot", -- Relic
	INVTYPE_ROBE = "ChestSlot", -- Chest
	INVTYPE_SHIELD = "SecondaryHandSlot", -- Off Hand
	INVTYPE_SHOULDER = "ShoulderSlot", -- Shoulder
	INVTYPE_TABARD = "TabardSlot", -- Tabard
	INVTYPE_TRINKET = "Trinket0Slot", -- Trinket
	INVTYPE_TRINKET_OTHER = "Trinket1Slot", -- Trinket_other
	INVTYPE_WAIST = "WaistSlot", -- Waist
	INVTYPE_WEAPON = "MainHandSlot", -- One-Hand
	INVTYPE_WEAPON_OTHER = "SecondaryHandSlot", -- One-Hand_other
	INVTYPE_WEAPONMAINHAND = "MainHandSlot", -- Main Hand
	INVTYPE_WEAPONOFFHAND = "SecondaryHandSlot", -- Off Hand
	INVTYPE_WRIST = "WristSlot", -- Wrist
	INVTYPE_WAND = "RangedSlot", -- Wand
	INVTYPE_RANGEDRIGHT = "RangedSlot", -- Guns
	INVTYPE_GUN = "RangedSlot", -- Gun - Though almost all seem to use the above.
	INVTYPE_AMMO = "AmmoSlot", -- Gun and Bow ammo
	INVTYPE_GUNPROJECTILE = "AmmoSlot", -- Projectile
	INVTYPE_BOWPROJECTILE = "AmmoSlot", -- Projectile
	INVTYPE_CROSSBOW = "RangedSlot", -- Crossbow
	INVTYPE_THROWN = "RangedSlot", -- Thrown
};


-- Version : Default English
COMPARESTATS_LOAD_MESSAGE = "CompareStats Loaded: ";
CS_ARMOR = "Armor";
CS_WEAPON = "Weapon";
CS_RACE_TAUREN = "Tauren";
CS_RACE_GNOME = "Gnome";
COMPARESTATS_EQUIP_CHANGE = "Equipping this will change: ";
COMPARESTATS_HITPOINTS = "Hit Points: ";
COMPARESTATS_MANA = "Mana: ";
COMPARESTATS_AP = "AP: ";
COMPARESTATS_DPS = " dps: ";
COMPARESTATS_BEAR_AP = "Bear AP: ";
COMPARESTATS_BEAR_DPS = " Bear dps: ";
COMPARESTATS_CAT_AP = "Cat AP: ";
COMPARESTATS_CAT_DPS = " Cat dps: ";
COMPARESTATS_RAP = "RAP: ";
GFWTOOLTIP_LOAD_MESSAGE = "GFWTooltip v";
GFWTOOLTIP_LOAD_MESSAGE_TWO = " loaded.";


-- Version : Russian ( by Maus )
if ( GetLocale() == "zhCN" ) then

COMPARESTATS_LOAD_MESSAGE = "装备属性对比加载. ";
CS_ARMOR = "护甲";
CS_WEAPON = "武器";
CS_RACE_TAUREN = "牛头人";
CS_RACE_GNOME = "侏儒";
COMPARESTATS_EQUIP_CHANGE = "装备将更改下列属性: ";
COMPARESTATS_HITPOINTS = "生命值: ";
COMPARESTATS_MANA = "法力值: ";
COMPARESTATS_AP = "攻强: ";
COMPARESTATS_DPS = "每秒伤害: ";
COMPARESTATS_BEAR_AP = "熊形态AP: ";
COMPARESTATS_BEAR_DPS = " 熊形态dps: ";
COMPARESTATS_CAT_AP = "猎豹形态 AP: ";
COMPARESTATS_CAT_DPS = " 猎豹形态 dps: ";
COMPARESTATS_RAP = "远程攻强: ";
GFWTOOLTIP_LOAD_MESSAGE = "GFWTooltip v ";
GFWTOOLTIP_LOAD_MESSAGE_TWO = " 加载.";

end