zwf = zwf or {}
zwf.f = zwf.f or {}
zwf.config = zwf.config or {}

/////////////////////////////////////////////////////////////////////////////

// Bought by 00000000000000000
// Version 1.7.7

/////////////////////////// Zeros GrowOP /////////////////////////////

// Developed by ZeroChain:
// http://steamcommunity.com/id/zerochain/
// https://www.artstation.com/zerochain
// https://www.gmodstore.com/users/view/00000000000000000


/////////////////////////////////////////////////////////////////////////////


/*
    Console Commands:

    // Adds a seed with the provided data to the seedbank or player you are looking at
    zwf_addseed Weed_ID Weed_Name GrowTime GrowAmount THC
        Weed_ID = The id of the plant zwf.config.Plants
        Weed_Name = The name of the plant (This should not have spaces!)
        GrowTime = Grow Time in seconds
        GrowAmount = How much weed it produces if grown perfectly
        THC = How much thc the weed has
*/



// This enables the Debug Mode
zwf.config.Debug = false

// Switches between FastDl and Workshop
zwf.config.EnableResourceAddfile = false

// The language , en , de , es , fr , ru , pl , cn , ptbr , tr
zwf.config.SelectedLanguage = "en"

// Currency
zwf.config.Currency = "$"

// Unit of weight
zwf.config.UoW = "g"

// Unit of Liquid
zwf.config.UoL = "l"

// These Ranks are allowed to use the debug commands and save the WeedBuyer NPC with !savezwf
// If xAdmin or SAM is installed then this table will be ignored
zwf.config.AdminRanks = {
    ["superadmin"] = true,
}

// What entities should have the player be the CPPI Owner (This allows them to move the entities via physgun)
zwf.config.CPPI = {
    ["zwf_lamp"] = true,
    ["zwf_pot"] = true,
    ["zwf_pot_hydro"] = true,
    ["zwf_ventilator"] = true,
    ["zwf_drystation"] = true,
    ["zwf_watertank"] = true,
    ["zwf_outlet"] = true,
    ["zwf_mixer"] = true,
    ["zwf_oven"] = true,
    ["zwf_mixer_bowl"] = true,
    ["zwf_packingstation"] = true,
    ["zwf_seed_bank"] = true,
    ["zwf_splice_lab"] = true,
    ["zwf_soil"] = true,
    ["zwf_generator"] = true,
    ["zwf_bong_ent"] = true,
    ["zwf_joint_ent"] = true,
    ["zwf_bong01_ent"] = true,
    ["zwf_bong02_ent"] = true,
    ["zwf_bong03_ent"] = true,
    ["zwf_fuel"] = true,
    ["zwf_autopacker"] = true,
    ["zwf_weedstick"] = true,
    ["zwf_palette"] = true,
    ["zwf_backmix"] = true
}

zwf.config.Player = {
    // If zwf.config.NPC.SellMode = 2 then we Drop the weedblocks when the player dies.
    DropWeedOnDeath = false,
}

// Vrondakis LevelSystem
// This code can be found at lua/zweedfarm/sv/zwf_hooks_sv.lua zwf_OnWeedSold_Vrondakis
zwf.config.VrondakisLevelSystem = {
    Enabled = false,
    XP = {
        ["Selling"] = 15, // XP Per WeedBlock
    }
}

// The Damage the entitys have do take before they get destroyed.
// Setting it to -1 disables it
zwf.config.Damageable = {
    ["zwf_plant"] = 100,
    ["zwf_watertank"] = -1,
    ["zwf_drystation"] = -1,
    ["zwf_fuel"] = -1,
    ["zwf_generator"] = -1,
    ["zwf_lamp"] = -1,
    ["zwf_nutrition"] = -1,
    ["zwf_outlet"] = -1,
    ["zwf_packingstation"] = -1,
    ["zwf_palette"] = 100,
    ["zwf_pot"] = -1,
    ["zwf_pot_hydro"] = -1,
    ["zwf_seed"] = -1,
    ["zwf_seed_bank"] = -1,
    ["zwf_soil"] = -1,
    ["zwf_splice_lab"] = -1,
    ["zwf_ventilator"] = -1,
    ["zwf_autopacker"] = -1,
    ["zwf_weedblock"] = 50,
    ["zwf_weedstick"] = 50,
    ["zwf_jar"] = 50,
}

// This only applies to player who are defined as weed sellers in zwf.config.NPC.WeedSellers
zwf.config.Sharing = {
    // Do we allow seeds to be shared and used by other players?
    // *Note: Enabling this will allow players to take anyones seed and store / use it
    Seeds = false,

    // Do we allow other players to share Fertilizer bottles?
    Fertilizer = false,

    // Do we allow other players to interact with the plants?
    Plants = false,

    // Do we allow other players to remove weed junks from the drying station?
    DryStation = false,

    // Do we allow other players to interact with the packing table?
    Packing = false,

    // Do we allow weedblocks from other players to be added to our palette entity?
    Palette = false,

    // Do we allow other players to add/remove weed and interact with our seedlab entity?
    SeedLab = false,

    // Do we allow other players to interact with the generator?
    Generator = false,

    // Do we allow other players to interact with the lamps?
    Lamps = false,

    // Do we allow other players to interact with the fans?
    Fans = false,

    // Do we allow other players to interact with your Watertank?
    WaterTank = false,
}

zwf.config.ShopTablet = {
    // How much money does the player gets refuned if he sells his bought equipment with the Reload key on the TabletSWEP
    // 1 = full, 0.5 = half , 0 = disabled
    refund = 0.8
}

zwf.config.Wind = {
    // Known Bugs:
    // Can cause a render flicker issue when shining a flashlight on them.

    // Do we want to spawn a wind entity on map load
    // *Note: This will make the plants move more realistically.
    Enabled = true,

    // Some options for the wind entity
    //https://developer.valvesoftware.com/wiki/Env_wind

    gustdirchange = 30,
    gustduration = 4,
    maxgust = 30,
    mingust = 15,
    maxgustdelay = 30,
    mingustdelay = 15,
    maxwind = 64,
    minwind = 16,
}

zwf.config.THC = {

    // The maximal THC Level weed can have.
    Max = 50,

    // How much can the THC level of the plant increase if grown perfectly, aka Good Balance of water and low Temperatur
    MaxIncrease = 3,

    // How much does the THC level of the weed influence the price
    // 0.25 = +25% More Money, 2 = 200% more money
    // Examble: A infuence value of 0.5 would give 50% more money if the THC level of the weed would be full Maxed out, ( Full maxed out means a THC level of zwf.config.THC.Max)
    sellprice_influence = 0.5,
}
