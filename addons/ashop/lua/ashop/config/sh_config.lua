local l = ashop.Config or {} // don't touch that

l.Language = "french"
l.create_money = 0
l.create_premiummoney = 0
l.modelPanelDisplayWeapon = "fas2_sg551"
l.PetSnapAngle = true // Instantly teleport the pet to the good pos, this avoid the shaking
l.UnequipOnMissingRanks = false // Unequip + Block equip if the player does not have the rank anymore
l.OpenKey = KEY_F6
l.OpenTauntMenuKey = KEY_F7 // Open Taunt Menu
l.PS2Compatibility = true // Add PS2 functions AND SH, for easy compatibility
l.PetDistanceBeforeMoving = 256 // The distance before the pet start moving
l.TitleVerticalPosAdd = 0 // Do we add value to the verical position of the title ?

// NPC
l.NPCName = ""
l.NPCModel = "models/breen.mdl"

// Size of the displayed title
// If you are using AHud, a recommended value is 20 or 25
l.FontSizeTitle = 120

// Can people sell items they obtained/bought ?
// If this is less or equal to 0 OR more than 1, it will hide the option
l.SellPrice = 0

// Restrict some jobs/team to have accessories/wearables
// Examples are commented, to make them works, remove the "//" at the front of the line
// Follow the format of the examples, [TEAM_SOMETHING] = true. Replace TEAM_SOMETHING by the variable for your team/job.

l.jobsBlockEquipAccessories = {
    // [TEAM_UNDEAD or -100] = true, // Zombie survival zombie team
    // [TEAM_POLICE or -101] = true, // Darkrp, police team for example
}

// Unboxing notification parameters
l.notif_holdDiv = 5 // How much parts we have in the notification
l.notif_holdPart = 3 // How much parts are used to keep the notification at the middle
l.notif_time = 5 // How much time the notification will stay
l.UnboxChatPrint = false // Print the unbox in the chat, rather than a popup

// UI
l.colors = {
    Separator = Color(47, 73, 109),

    // 25, 30, 62
    Grad1_0 = Color(31, 35, 64),

    // 33, 38, 70
    Grad1_1 = Color(38, 43, 72),
    Grad1_12 = Color(33, 38, 70),

    // 31, 47, 81
    Grad2_0 = Color(36, 51, 82),

    // 34, 53, 89
    Grad2_1 = Color(39, 56, 89),

    // 29, 44, 75
    ItemBg = Color(35,48,76,255),

    // 71, 108, 184
    StateOn = Color(50, 121, 215, 255),
    StateOff = Color(47, 67, 109, 255),

    // 30 35 67
    Good = Color(50, 203, 113),
    entryColor = Color(35, 40, 66, 255),

    badInput = Color(230, 77, 62),
    badInputBg = Color(64, 31, 36),
    badInputBg2 = Color(64, 31, 36),

    White = Color(231, 240, 241),
    White50 = Color(231, 240, 241, 255*0.5),
    White25 = Color(231, 240, 241, 255*0.15),
    White5 = Color(231, 240, 241, 255*0.05),
    BlurpleWrite = Color(193, 186, 237),

    blurple = Color(115, 97, 230),
    blurpleBg = Color(46, 68, 111),

    normalMoneyBg = Color(40, 186, 189, 255*0.4),
    normalMoney = Color(40, 186, 189),

    pink = Color(50, 121, 215, 255*0.4),
    premiumMoneyLogo = Color(50, 121, 215),
}

l.round = 8

// Ranks that can access to the parameters of the addon completely.
l.fullEdit = {
	["superadmin"] = true,
}

// Modify it only if your TFA skins doesn't apply on your weapon
// for some reasons.
// This will apply the skin on every "elements" that is a model with bone merging
// Use the weapon class
l.aggressiveTFASkinDetection = {
    ["at_sw_dc15s_all"] = true,
    ["at_sw_dc15s_base1"] = true,
    ["at_sw_dc15s_base2"] = true,
    ["at_sw_dc15s_base3"] = true,
    ["at_sw_dc15s_heavy1"] = true,
    ["at_sw_dc15s_heavy2"] = true,
    ["at_sw_dc15s_heavy3"] = true,
    ["at_sw_dc15s_recon1"] = true,
    ["at_sw_dc15s_recon2"] = true,
    ["at_sw_dc15s_recon3"] = true,
    ["at_sw_dc15s_security1"] = true,
    ["at_sw_dc15s_security2"] = true,
    ["at_sw_dc15s_security3"] = true,
    ["at_sw_dc15a_all"] = true,
    ["at_sw_dc15a_base1"] = true,
    ["at_sw_dc15a_base2"] = true,
    ["at_sw_dc15a_base3"] = true,
    ["at_sw_dc15a_heavy1"] = true,
    ["at_sw_dc15a_heavy2"] = true,
    ["at_sw_dc15a_heavy3"] = true,
    ["at_sw_dc15a_recon1"] = true,
    ["at_sw_dc15a_recon2"] = true,
    ["at_sw_dc15a_recon3"] = true,
    ["at_sw_dc15a_security1"] = true,
    ["at_sw_dc15a_security2"] = true,
    ["at_sw_dc15a_security3"] = true,
}








// DON'T TOUCH BELOW !
// DON'T TOUCH BELOW !
// DON'T TOUCH BELOW !
// DON'T TOUCH BELOW !
// DON'T TOUCH BELOW !
// DON'T TOUCH BELOW !
// DON'T TOUCH BELOW !
// DON'T TOUCH BELOW !
// DON'T TOUCH BELOW !
// DON'T TOUCH BELOW !
// DON'T TOUCH BELOW !

l.SendItemsChunkSeconds = 0.2
l.BitsRender = 8
l.BitsObjectType = 8
l.BitsPac3 = 10
l.BitsRarity = 8
l.BitsItemID = 20
l.BitsPlyItemID = 20
l.BitsRankPromotion = 7
l.BitsGroupRank = 10
l.BitsSubObjectType = 8

ashop.Config = l // and also don't touch that