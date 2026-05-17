--[[
    Configuration des récompenses du Calendrier de l'Avent
    Serveur BaseWars Kazano
    
    Récompenses actives :
    - Charbon (rien)
    - Crédits BaseWars
    - Points Pointshop BaseWars
    - Skins Pointshop BaseWars
    - Armes Permanentes BaseWars
    - Caisse Mystère VoidCases
--]]

--[[
    COAL - Charbon (récompense par défaut)
    NE PAS SUPPRIMER OU MODIFIER L'ID
--]]
CH_Advent.Rewards[ 1 ] = {
    Name = "Coal",
    Enabled = true,
    Entries = 40,
    UniqueID = 1,
    RewardFunction = function( ply )
        CH_Advent.Notify( ply, "Tu as gagné du charbon... Meilleure chance demain !" )
    end,
}

--[[
    CRÉDITS BASEWARS
--]]
local MinCredits = 10
local MaxCredits = 750

CH_Advent.Rewards[ 2 ] = {
    Name = "Crédits BaseWars",
    Enabled = true,
    Entries = 35,
    UniqueID = 2,
    RewardFunction = function( ply )
        local amount = math.random( MinCredits, MaxCredits )
        
        if ply.AddCredit then
            ply:AddCredit( amount )
            CH_Advent.Notify( ply, "Tu as gagné " .. string.Comma( amount ) .. " crédits !" )
        else
            CH_Advent.Notify( ply, "Erreur: Système de crédits non disponible." )
        end
    end,
}

--[[
    POINTS POINTSHOP BASEWARS
--]]
local MinPointshop = 100
local MaxPointshop = 1500

CH_Advent.Rewards[ 3 ] = {
    Name = "Points Pointshop",
    Enabled = true,
    Entries = 30,
    UniqueID = 3,
    RewardFunction = function( ply )
        local amount = math.random( MinPointshop, MaxPointshop )
        
        if ply.AddPointshop then
            ply:AddPointshop( amount )
            CH_Advent.Notify( ply, "Tu as gagné " .. string.Comma( amount ) .. " points Pointshop !" )
        else
            CH_Advent.Notify( ply, "Erreur: Système Pointshop non disponible." )
        end
    end,
}

--[[
    SKINS POINTSHOP BASEWARS
--]]
local basewars_pointshop_skins = {
    37, 38, 39, 40, 41, 42, 43, 44, 45, 46,
    47, 48, 49, 50, 51, 52, 58, 59, 60, 61,
    62, 63, 64, 66, 67, 68, 69, 70, 71, 72,
    73, 74, 76, 78, 79, 80, 81, 82, 88, 89,
    90, 91, 93, 94, 96, 97, 98, 99, 100, 101,
    102, 103, 104, 105, 106, 110, 111, 112, 113, 114, 118,
}

CH_Advent.Rewards[ 4 ] = {
    Name = "Skin Pointshop",
    Enabled = true,
    Entries = 15,
    UniqueID = 4,
    RewardFunction = function( ply )
        if not BaseWars or not BaseWars.PS then
            CH_Advent.Notify( ply, "Erreur: Système Pointshop non disponible." )
            return
        end
        
        local rand_skin = basewars_pointshop_skins[ math.random( #basewars_pointshop_skins ) ]
        
        -- Donner le skin au joueur
        local success = BaseWars.PS:GiveSkinToPlayer( ply:SteamID64(), rand_skin, "0" )
        
        if success then
            CH_Advent.Notify( ply, "Tu as gagné un skin Pointshop ! (ID: " .. rand_skin .. ")" )
        else
            -- Fallback: donner des crédits si le joueur a déjà le skin
            if ply.AddCredit then
                ply:AddCredit( 1000 )
                CH_Advent.Notify( ply, "Tu as déjà ce skin ! Voici 1000 crédits à la place." )
            end
        end
    end,
}

--[[
    ARMES PERMANENTES BASEWARS
    Armes VoidCases (Commun → Légendaire, sans Mythique)
--]]
local basewars_permanent_weapons = {
    -- === SHOTGUNS ===
    -- Commun
    "tfa_cso_usas12",
    "tfa_cso_winchester_m1887",
    -- Peu Commun
    "tfa_cso_spas12ex",
    "tfa_cso_qbs09",
    -- Rare
    "tfa_cso_usas12_camo",
    "tfa_cso_double_barrel",
    -- Légendaire
    "tfa_cso_laserfist",
    "tfa_cso_volcano",

    -- === MELEE ===
    -- Commun
    "tfa_cso_mastercombatknife",
    "tfa_cso_balisong",
    "tfa_cso_dualknife",
    "tfa_cso_hammer",
    "tfa_cso_crowbar_red",
    "tfa_cso_combatknife",
    "tfa_cso_machete",
    "tfa_cso_fireaxe",
    -- Peu Commun
    "tfa_cso_tomahawk",
    "tfa_cso_wakizashi",
    "tfa_cso_dragonsword",
    "tfa_cso_katana",
    "tfa_cso_nata",
    "tfa_cso_shovel",
    -- Rare
    "tfa_cso_dualsword",
    "tfa_cso_janus9",
    "tfa_cso_pauldron",
    "tfa_cso_balrog9",
    -- Légendaire
    "tfa_cso_runeblade",
    "tfa_cso_stormgiant",
    "tfa_cso_magicknife",

    -- === SNIPERS ===
    -- Commun
    "tfa_cso_m24",
    "tfa_cso_scout",
    "tfa_cso_wa2000",
    "tfa_cso_awp",
    "tfa_cso_sg550",
    "tfa_cso_sl8",
    -- Peu Commun
    "tfa_cso_m95",
    "tfa_cso_psg1",
    "tfa_cso_xm2010",
    "tfa_cso_trg42",
    -- Rare
    "tfa_cso_m95_tiger",
    "tfa_cso_awp_camo",
    "tfa_cso_cheytacm200",
    "tfa_cso_m400",
    -- Légendaire
    "tfa_cso_railcannon",
    "tfa_cso_m82",
    "tfa_cso_savery",

    -- === SMG ===
    -- Commun
    "tfa_cso_mp5",
    "tfa_cso_tmp",
    "tfa_cso_ump",
    "tfa_cso_p90",
    "tfa_cso_mac10",
    "tfa_cso_mp7a1",
    "tfa_cso_k1a",
    -- Peu Commun
    "tfa_cso_mp7a1_60r",
    "tfa_cso_thompson",
    "tfa_cso_p90_lapin",
    "tfa_cso_tmpdragon",
    -- Rare
    "tfa_cso_dualkriss",
    "tfa_cso_mp7a1_dragon",
    "tfa_cso_skull8",
    "tfa_cso_balrog3",
    -- Légendaire
    "tfa_cso_janus1",
    "tfa_cso_bouncer",

    -- === ASSAULT RIFLES ===
    -- Commun
    "tfa_cso_ak47",
    "tfa_cso_m4a1",
    "tfa_cso_sg552",
    "tfa_cso_aug",
    "tfa_cso_famas",
    "tfa_cso_galil",
    "tfa_cso_m16a4",
    "tfa_cso_l85a2",
    "tfa_cso_scarl",
    "tfa_cso_xm8",
    "tfa_cso_an94",
    "tfa_cso_tar21",
    "tfa_cso_f2000",
    "tfa_cso_sako",
    -- Peu Commun
    "tfa_cso_m16a4_cso2",
    "tfa_cso_oicw",
    "tfa_cso_ak47_60r",
    "tfa_cso_scarh",
    "tfa_cso_m14ebr",
    "tfa_cso_ak47dragon",
    "tfa_cso_sg552dragon",
    "tfa_cso_akmsu",
    -- Rare
    "tfa_cso_m4a1dragon",
    "tfa_cso_stg44",
    "tfa_cso_ak74u",
    "tfa_cso_augex",
    "tfa_cso_m4a1_dark",
    "tfa_cso_gungnir",
    -- Légendaire
    "tfa_cso_janus7",
    "tfa_cso_balrog7",
    "tfa_cso_m4a1_gold",
    "tfa_cso_plasmagun",
    "tfa_cso_ethereal",

    -- === PISTOLS (GUNS) ===
    -- Commun
    "tfa_cso_glock",
    "tfa_cso_usp",
    "tfa_cso_p228",
    "tfa_cso_fiveseven",
    "tfa_cso_deagle",
    "tfa_cso_elites",
    "tfa_cso_anaconda",
    "tfa_cso_m1911a1",
    "tfa_cso_mp7a1pistol",
    -- Peu Commun
    "tfa_cso_deagle_gold",
    "tfa_cso_infinityex2",
    "tfa_cso_colt",
    "tfa_cso_m950",
    "tfa_cso_luger",
    "tfa_cso_dualinfinity",
    -- Rare
    "tfa_cso_desperado",
    "tfa_cso_m950se",
    "tfa_cso_skull1",
    "tfa_cso_dualinfinityex1",
    -- Légendaire
    "tfa_cso_kingcobra",
    "tfa_cso_dualinfinityfinal",
    "tfa_cso_thunderpistol",

    -- === FUN / LMG ===
    -- Commun
    "tfa_cso_m249",
    "tfa_cso_negev",
    "tfa_cso_mg3",
    "tfa_cso_pkm",
    "tfa_cso_qbb95",
    "tfa_cso_mg36",
    -- Peu Commun
    "tfa_cso_m60e4",
    "tfa_cso_hk121",
    "tfa_cso_m134",
    "tfa_cso_m249_camo",
    -- Rare
    "tfa_cso_mk48",
    "tfa_cso_skull7",
    -- Légendaire
    "tfa_cso_balrog7",
    "tfa_cso_janus7",

    -- === GRENADES ===
    -- Commun
    "tfa_cso_flashbang",
    "tfa_cso_smokegrenade",
    "tfa_cso_he",
    -- Peu Commun
    "tfa_cso_fgrenade",
    -- Rare
    "tfa_cso_sfgrenade",
    -- Légendaire
    "tfa_cso_holybomb",
}

CH_Advent.Rewards[ 5 ] = {
    Name = "Arme Permanente",
    Enabled = true,
    Entries = 10,
    UniqueID = 5,
    RewardFunction = function( ply )
        if not BaseWars or not BaseWars.PW then
            CH_Advent.Notify( ply, "Erreur: Système d'armes permanentes non disponible." )
            return
        end
        
        local rand_weapon = basewars_permanent_weapons[ math.random( #basewars_permanent_weapons ) ]
        local weaponName = BaseWars.PW:GetWeaponName( rand_weapon ) or rand_weapon
        
        -- Ajouter l'arme permanente au joueur
        BaseWars.PW:AddWeapon( ply:SteamID64(), "0", rand_weapon )
        
        CH_Advent.Notify( ply, "Tu as gagné l'arme permanente : " .. weaponName .. " !" )
    end,
}

--[[
    CAISSE MYSTÈRE VOIDCASES
--]]
local voidcases_mystery_box_id = 181 -- ID de la caisse mystère dans VoidCases

CH_Advent.Rewards[ 6 ] = {
    Name = "Caisse Mystère",
    Enabled = true,
    Entries = 20,
    UniqueID = 6,
    RewardFunction = function( ply )
        -- Utiliser la commande console VoidCases pour donner une caisse
        RunConsoleCommand( "voidcases_giveitem", tostring( ply:SteamID64() ), tostring( voidcases_mystery_box_id ), "1" )
        
        CH_Advent.Notify( ply, "Tu as gagné une Caisse Mystère ! Ouvre-la dans ton inventaire VoidCases." )
    end,
}

--[[
    GROS LOT - CRÉDITS
--]]
local BigCreditsMin = 750
local BigCreditsMax = 5000

CH_Advent.Rewards[ 7 ] = {
    Name = "Gros Lot Crédits",
    Enabled = true,
    Entries = 5,
    UniqueID = 7,
    RewardFunction = function( ply )
        local amount = math.random( BigCreditsMin, BigCreditsMax )
        
        if ply.AddCredit then
            ply:AddCredit( amount )
            CH_Advent.Notify( ply, "JACKPOT ! Tu as gagné " .. string.Comma( amount ) .. " crédits !" )
        else
            CH_Advent.Notify( ply, "Erreur: Système de crédits non disponible." )
        end
    end,
}

--[[
    GROS LOT - POINTS POINTSHOP
--]]
local BigPointshopMin = 2500
local BigPointshopMax = 15000

CH_Advent.Rewards[ 8 ] = {
    Name = "Gros Lot Pointshop",
    Enabled = true,
    Entries = 5,
    UniqueID = 8,
    RewardFunction = function( ply )
        local amount = math.random( BigPointshopMin, BigPointshopMax )
        
        if ply.AddPointshop then
            ply:AddPointshop( amount )
            CH_Advent.Notify( ply, "JACKPOT ! Tu as gagné " .. string.Comma( amount ) .. " points Pointshop !" )
        else
            CH_Advent.Notify( ply, "Erreur: Système Pointshop non disponible." )
        end
    end,
}
