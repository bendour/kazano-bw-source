dtj.weaponHud.config = {
    -- maximum number of slots
    -- hl2 by default uses 6, so this should never be changed, unless using custom menus
    -- be sure to match your maxSlots with how many slots your custom menu has
    maxSlots = 5,
   
    -- adjust the total scale of everything (smaller number = smaller size)
    -- PLEASE NOTE:
    --          What looks good on YOUR resolution, might not look good on others!
    --  Recommend leaving this at one. If something isn't fitting, please submit a screenshot support ticket
    scale = 0.8,
   
    -- if a slot has too many weapons to fit on the screen
    -- should we position the weapon into the next slot?
    autoSlot = true,
   
    -- when a weapon doesn't have a layout order, or SlotPos
    -- it will automatically use this slot (by default (0) means the last / largest slot)
    slotOverflow = 2,
   
    -- this forces all HL2 (default weapons) to stay in their original slots
    -- even with a custom layout, hl2 weapons will still position themselves in the default order (if enabled)
    hl2Slots = false,
   
    -- enable themes
    -- if running on a server with many addons, may recommend disabling themes for a performance boost
    useThemes = false,
   
    -- force a theme on players
    -- leave empty to allow players to select their own theme(s)
    forceTheme = "default",
   
    -- should we be using the custom menu table?
    -- if you configured your menu in-game, make sure "dtj_weaponhud_serverslots" is set to 1
    -- that will ignore useCustom
    useCustom = true,
   
    -- display context menu settings icon?
    -- as well as display the admin slot editor within the sandbox menu
    -- this does nothing on gamemodes that don't have the spawnmenu
    sandboxMods = false,
   
    -- the mouse wheel sensitivity
    -- by default it's easy to quickly scroll past the weapon you wish to select
    -- "high"   = real time, no delay
    -- "medium" = slightly slower response
    -- "low"    = even slower
    mouseSensitivity = "high",
   
    -- can we show the menu while being in a vehicle?
    inVehicle = false,
   
    -- how long (in seconds) to keep the drawer displayed
    -- set to zero (0.0) to keep it open until closed
    showTime = 2,
   
    -- should the weapon names be bold (capitalized)
    bold = false,
   
    -- titles for the default (hl2) weapon drawer
    -- layout is slot order (1, 2, 3, 4, 5, 6)
    -- this MUST match the amount set from "maxSlots"
    -- if using a custom menu, this table will be ignored. You can set your titles within the customMenu table
    titles = { "TOOLS", "WEAPONS", "WEAPONS", "WEAPONS", "WEAPONS" },
   
    -- EXAMPLE (if you wish to hide the titles, use showTitles=false)
    --titles = { "", "", "", "", "", "" },
   
    -- EXAMPLE
    --titles = { "-", "-", "-", "-", "-", "-" },
   
    -- show titles?
    -- this shows your custom menu title, or the default titles above
    showTitles = true,
   
    -- show information (author, purpose, etc..) about SWEPs
    showTooltip = false,
   
    -- show weapon icons
    -- this will also draw the default HL2 weapon sprites
    showIcons = false,
   
    -- indicates if we should show the ammo count
    showAmmo = false,
   
    -- show error and other useful messages in the console?
    -- this includes both on the server and client. Recommend to leave enabled for any issues
    showMessages = true,
   
    -- how far from the top of the screen, to position the drawer
    offset = 5,
   
    -- padding between slot elements (0-25 is recommended)
    padding = 2,
   
    -- collapsed height
    -- affected by screen resolution, recommend to leave alone
    collapsedHeight = 50,
   
    -- expanded height
    -- affected by screen resolution, recommend to leave alone
    expandedHeight = 160,
   
    -- the slot "headers" color
    slotColor = Color( 50, 50, 50, 220 ),
   
    -- main color of the drawer
    mainColor = Color( 50, 50, 50, 220 ),
   
    -- color of the current selection
    selectColor = Color( 80, 80, 80, 140 ),
   
    -- ammo text color
    ammoColor = Color( 255, 255, 51, 200 ),
   
    -- error text color
    -- such as "NO AMMO"
    errorColor = Color( 255, 51, 51, 255 ),
   
    -- title text color
    titleColor = Color( 255, 255, 255, 255 ),
   
    -- color of the hl2 weapon sprites/icons
    hl2WeaponColor = Color( 255, 255, 255, 255 ),
   
    -- how long it takes for the drawer to close/fade out
    fadeOutTime = 0.25,
   
    -- how long it takes for the drawer to close/fade out
    fadeInTime = 0.25,
   
    -- sound played when navigation weapons
    -- use "" for no sound
    navSound = "common/wpn_moveselect.wav",
   
    -- sound played when a weapon is selected
    -- use "" for no sound
    selectedSound = "common/wpn_hudoff.wav",
   
    -- the privilege a user needs to use the admin features
    -- if not using an Admin Mod that supports CAMI, this defaults to IsSuperAdmin()
    priv = "dtj_weaponhud",
}
 
--[[
    Translations
--]]
dtj.weaponHud.lang = {
    ["asking_server"]   = "Requesting information from server, please wait...",
    ["access_denied"]   = "You do not have sufficient access",
    ["too_soon"]        = "Please wait before requesting slot configuration again..",
    ["sending"]         = "Submitting configuration to server..",
    ["saved"]           = "Weapon Drawer settings saved!"
}
 
--[[
    Custom Icons for Wepaons
    ---------------------
    This allows you to setup custom icons (ignoring the default SWEP settings) for each weapon
    ["weapon_class_name_entity"] = "path/to/material"
--]]
dtj.weaponHud.icons = {
    --["weapon_crowbar"] = "gmod/scope",                    -- VTF/VMT MATERIAL
    --["weapon_crowbar"] = "entities/weapon_crowbar.png",   -- PNG
}
 
-- Your custom menu, if required
-- Leave empty to use the standard HL2 layout
dtj.weaponHud.customMenu = {
{
        title = "TOOLS",
        "weapon_physcannon",
        "weapon_physgun",
        "gmod_tool"
    },
    {
        title = "WEAPONS",
        "keys"
    },
    {
        title = "WEAPONS",
        "awpdragon"
    },
    {
        title = "WEAPONS",
        "csgo_bayonet"
    },
    {
        title = "WEAPONS",
        "csgo_bayonet_fade"
    }
}
--[[
    Custom Menu Layout
    -----------------
    You can configure your slot names, and what weapons will be located in that slot.
    The order in which you add the weapons, is the order that it will appear in the weapon drawer
   
    Useful for other gamemodes besides Sandbox (like DarkRP).
   
    Any weapons that are not listed in a slot, will automatically populate the last/largest slot.
    Make sure you have enough slots to match "maxSlots" count!
--]]
 
--[[
-- EXAMPLE 1
 
dtj.weaponHud.customMenu = {
    {
        title = "SLOT 1",
        "weapon_crowbar",
        "weapon_physgun",
        "weapon_physcannon"
    },
   
    {
        title = "SLOT2",
        "weapon_pistol",
        "weapon_smg1",
        "weapon_ar2"
    },
   
    {
        title = "SLOT3"
    },
   
    {
        title = "SLOT4"
    },
   
    {
        title = "SLOT5"
    },
    {
        title = "SLOT6"
    }
}
 
 
 
dtj.weaponHud.customMenu = {
    {
        title = "ROLE-PLAY",
        "weapon_physcannon",
        "weapon_physgun",
        "arrest_stick",
        "door_ram",
        "keys",
        "lockpick"
    },
    {
        title = "WEAPONS",
        "weapon_ak472",
        "weapon_deagle2",
        "weapon_fiveseven2",
        "weapon_glock2",
        "weapon_m42",
        "weapon_mac102",
        "weapon_mp52",
        "weapon_p2282",
        "weapon_pumpshotgun2",
    },
    {
        title = "TOOLS",
        "gmod_tool",
        "gmod_camera",
        "weaponchecker"
    },
    {
        title = "MISC",
        "med_kit"
    }
}
]]--