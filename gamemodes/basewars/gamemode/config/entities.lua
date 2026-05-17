BaseWars:CreateCategory("Favorites", "basewars_materials/f4/favorite.png", 1)
local PRINTERS_CATEGORY = BaseWars:CreateCategory("Printers", "basewars_materials/f4/printer.png", 2)
local WEAPONS_CATEGORY = BaseWars:CreateCategory("Weapons", "basewars_materials/f4/weapon.png", 3)
local DEFENSES_CATEGORY = BaseWars:CreateCategory("Defenses", "basewars_materials/f4/defense.png", 4)
local RAID_CATEGORY = BaseWars:CreateCategory("Raid", "basewars_materials/f4/bomb.png", 5)
local FARMING_CATEGORY = BaseWars:CreateCategory("Farming", "basewars_materials/f4/farming.png", 6)
local MISC_CATEGORY = BaseWars:CreateCategory("Misc", "basewars_materials/f4/misc.png", 7)

local PRINTER_MODEL = "models/props_c17/consolebox01a.mdl"
local BANK_MODEL = "models/props_c17/consolebox01a.mdl"
local TURRET_MODEL = "models/combine_turrets/floor_turret.mdl"
local TESLA_MODEL = "models/props_c17/substation_transformer01d.mdl"
local MINE_MODEL = "models/props_combine/combine_mine01.mdl"
local IS_VIP_FUNCTION = function(ply) return BaseWars:IsVIP(ply), "VIP" end
local IS_PREMIUM_FUNCTION = function(ply) return BaseWars:IsPremium(ply), "Premium" end

--[[-------------------------------------------------------------------------
	PRINTERS & BANK
---------------------------------------------------------------------------]]
local PRINTER_TIER_1 = "1Printers Tier 1"
BaseWars:CreateEntity("bw_base_bank"):SetClass("bw_base_bank"):SetCategory(PRINTERS_CATEGORY):SetSubCategory(PRINTER_TIER_1):SetName("Bank"):SetPrice(50000):SetMax(1):SetLevel(1):SetModel(BANK_MODEL):Finish()

-- PRINTER TIER 1
BaseWars:CreateEntity("bw_base_printer"):SetClass("bw_base_printer"):SetCategory(PRINTERS_CATEGORY):SetSubCategory(PRINTER_TIER_1):SetName("Basic Printer"):SetPrice(2000):SetLevel(1):SetMax(4):SetModel(PRINTER_MODEL):Finish()
BaseWars:CreateEntity("bw_printer_vip1"):SetClass("bw_printer_vip1"):SetCategory(PRINTERS_CATEGORY):SetSubCategory(PRINTER_TIER_1):SetName("Printer VIP 1"):SetPrice(2500):SetLevel(1):SetMax(4):SetModel(PRINTER_MODEL):SetRankCheck(IS_VIP_FUNCTION):Finish()
BaseWars:CreateEntity("bw_printer_premium1"):SetClass("bw_printer_premium1"):SetCategory(PRINTERS_CATEGORY):SetSubCategory(PRINTER_TIER_1):SetName("Premium Printer 1"):SetPrice(2501):SetLevel(5):SetMax(4):SetModel(PRINTER_MODEL):SetRankCheck(IS_PREMIUM_FUNCTION):Finish()
BaseWars:CreateEntity("bw_base_printer_credits"):SetClass("bw_base_printer_credits"):SetCategory(PRINTERS_CATEGORY):SetSubCategory(PRINTER_TIER_1):SetName("Credits Printer"):SetPrice(5000):SetLevel(1):SetMax(1):SetModel(PRINTER_MODEL):Finish()

-- PRINTER TIER 2
local PRINTER_TIER_2 = "2Printers Tier 2"
BaseWars:CreateEntity("bw_printer_copper"):SetClass("bw_printer_copper"):SetCategory(PRINTERS_CATEGORY):SetSubCategory(PRINTER_TIER_2):SetName("Copper Printer"):SetPrice(12500):SetLevel(3):SetMax(4):SetModel(PRINTER_MODEL):Finish()
BaseWars:CreateEntity("bw_printer_silver"):SetClass("bw_printer_silver"):SetCategory(PRINTERS_CATEGORY):SetSubCategory(PRINTER_TIER_2):SetName("Silver Printer"):SetPrice(20000):SetLevel(7):SetMax(4):SetModel(PRINTER_MODEL):Finish()
BaseWars:CreateEntity("bw_printer_gold"):SetClass("bw_printer_gold"):SetCategory(PRINTERS_CATEGORY):SetSubCategory(PRINTER_TIER_2):SetName("Gold Printer"):SetPrice(50000):SetLevel(9):SetMax(4):SetModel(PRINTER_MODEL):Finish()
BaseWars:CreateEntity("bw_printer_platinum"):SetClass("bw_printer_platinum"):SetCategory(PRINTERS_CATEGORY):SetSubCategory(PRINTER_TIER_2):SetName("Platinum Printer"):SetPrice(75000):SetLevel(13):SetMax(4):SetModel(PRINTER_MODEL):Finish()
BaseWars:CreateEntity("bw_printer_iridium"):SetClass("bw_printer_iridium"):SetCategory(PRINTERS_CATEGORY):SetSubCategory(PRINTER_TIER_2):SetName("Iridium Printer"):SetPrice(150000):SetLevel(17):SetMax(4):SetModel(PRINTER_MODEL):Finish()
BaseWars:CreateEntity("bw_printer_uranium"):SetClass("bw_printer_uranium"):SetCategory(PRINTERS_CATEGORY):SetSubCategory(PRINTER_TIER_2):SetName("Uranium Printer"):SetPrice(300000):SetLevel(21):SetMax(4):SetModel(PRINTER_MODEL):Finish()
BaseWars:CreateEntity("bw_printer_vip2"):SetClass("bw_printer_vip2"):SetCategory(PRINTERS_CATEGORY):SetSubCategory(PRINTER_TIER_2):SetName("VIP Printer 2"):SetPrice(300001):SetLevel(1):SetMax(4):SetModel(PRINTER_MODEL):SetRankCheck(IS_VIP_FUNCTION):Finish()
BaseWars:CreateEntity("bw_printer_premium2"):SetClass("bw_printer_premium2"):SetCategory(PRINTERS_CATEGORY):SetSubCategory(PRINTER_TIER_2):SetName("Premium Printer 2"):SetPrice(300002):SetLevel(15):SetMax(4):SetModel(PRINTER_MODEL):SetRankCheck(IS_PREMIUM_FUNCTION):Finish()

-- PRINTER TIER 3
local PRINTER_TIER_3 = "3Printers Tier 3"
BaseWars:CreateEntity("bw_printer_mobius"):SetClass("bw_printer_mobius"):SetCategory(PRINTERS_CATEGORY):SetSubCategory(PRINTER_TIER_3):SetName("Mobius Printer"):SetPrice(15000000):SetLevel(50):SetMax(4):SetModel(PRINTER_MODEL):Finish()
BaseWars:CreateEntity("bw_printer_darkmatter"):SetClass("bw_printer_darkmatter"):SetCategory(PRINTERS_CATEGORY):SetSubCategory(PRINTER_TIER_3):SetName("Dark Matter Printer"):SetPrice(30000000):SetLevel(60):SetMax(4):SetModel(PRINTER_MODEL):Finish()
BaseWars:CreateEntity("bw_printer_redmatter"):SetClass("bw_printer_redmatter"):SetCategory(PRINTERS_CATEGORY):SetSubCategory(PRINTER_TIER_3):SetName("Red Matter Printer"):SetPrice(45000000):SetLevel(70):SetMax(4):SetModel(PRINTER_MODEL):Finish()
BaseWars:CreateEntity("bw_printer_monolith"):SetClass("bw_printer_monolith"):SetCategory(PRINTERS_CATEGORY):SetSubCategory(PRINTER_TIER_3):SetName("Monolith Printer"):SetPrice(60000000):SetLevel(80):SetMax(4):SetModel(PRINTER_MODEL):Finish()
BaseWars:CreateEntity("bw_printer_quantum"):SetClass("bw_printer_quantum"):SetCategory(PRINTERS_CATEGORY):SetSubCategory(PRINTER_TIER_3):SetName("Quantum Printer"):SetPrice(85000000):SetLevel(90):SetMax(4):SetModel(PRINTER_MODEL):Finish()
BaseWars:CreateEntity("bw_printer_quasar"):SetClass("bw_printer_quasar"):SetCategory(PRINTERS_CATEGORY):SetSubCategory(PRINTER_TIER_3):SetName("Quasar Printer"):SetPrice(110000000):SetLevel(100):SetMax(4):SetModel(PRINTER_MODEL):Finish()
BaseWars:CreateEntity("bw_printer_vip3"):SetClass("bw_printer_vip3"):SetCategory(PRINTERS_CATEGORY):SetSubCategory(PRINTER_TIER_3):SetName("VIP Printer 3"):SetPrice(110000001):SetLevel(1):SetMax(4):SetModel(PRINTER_MODEL):SetRankCheck(IS_VIP_FUNCTION):Finish()
BaseWars:CreateEntity("bw_printer_premium3"):SetClass("bw_printer_premium3"):SetCategory(PRINTERS_CATEGORY):SetSubCategory(PRINTER_TIER_3):SetName("Premium Printer 3"):SetPrice(110000002):SetLevel(70):SetMax(4):SetModel(PRINTER_MODEL):SetRankCheck(IS_PREMIUM_FUNCTION):Finish()

-- PRINTER TIER 4
local PRINTER_TIER_4 = "4Printers Tier 4"
BaseWars:CreateEntity("bw_printer_emerald"):SetClass("bw_printer_emerald"):SetCategory(PRINTERS_CATEGORY):SetSubCategory(PRINTER_TIER_4):SetName("Emerald Printer"):SetPrice(550000000):SetLevel(125):SetMax(4):SetModel(PRINTER_MODEL):Finish()
BaseWars:CreateEntity("bw_printer_obsidian"):SetClass("bw_printer_obsidian"):SetCategory(PRINTERS_CATEGORY):SetSubCategory(PRINTER_TIER_4):SetName("Obsidian Printer"):SetPrice(1000000000):SetLevel(150):SetMax(4):SetModel(PRINTER_MODEL):Finish()
BaseWars:CreateEntity("bw_printer_diamond"):SetClass("bw_printer_diamond"):SetCategory(PRINTERS_CATEGORY):SetSubCategory(PRINTER_TIER_4):SetName("Diamond Printer"):SetPrice(1300000000):SetLevel(175):SetMax(4):SetModel(PRINTER_MODEL):Finish()
BaseWars:CreateEntity("bw_printer_tanzan"):SetClass("bw_printer_tanzan"):SetCategory(PRINTERS_CATEGORY):SetSubCategory(PRINTER_TIER_4):SetName("Tanzanite Printer"):SetPrice(1800000000):SetLevel(200):SetMax(4):SetModel(PRINTER_MODEL):Finish()
BaseWars:CreateEntity("bw_printer_opal"):SetClass("bw_printer_opal"):SetCategory(PRINTERS_CATEGORY):SetSubCategory(PRINTER_TIER_4):SetName("Black Opal Printer"):SetPrice(2200000000):SetLevel(225):SetMax(4):SetModel(PRINTER_MODEL):Finish()
BaseWars:CreateEntity("bw_printer_redberyl"):SetClass("bw_printer_redberyl"):SetCategory(PRINTERS_CATEGORY):SetSubCategory(PRINTER_TIER_4):SetName("Red Beryl Printer"):SetPrice(2600000000):SetLevel(250):SetMax(4):SetModel(PRINTER_MODEL):Finish()
BaseWars:CreateEntity("bw_printer_vip4"):SetClass("bw_printer_vip4"):SetCategory(PRINTERS_CATEGORY):SetSubCategory(PRINTER_TIER_4):SetName("VIP Printer 4"):SetPrice(2600000001):SetLevel(1):SetMax(4):SetModel(PRINTER_MODEL):SetRankCheck(IS_VIP_FUNCTION):Finish()
BaseWars:CreateEntity("bw_printer_premium4"):SetClass("bw_printer_premium4"):SetCategory(PRINTERS_CATEGORY):SetSubCategory(PRINTER_TIER_4):SetName("Premium Printer 4"):SetPrice(2600000002):SetLevel(170):SetMax(4):SetModel(PRINTER_MODEL):SetRankCheck(IS_PREMIUM_FUNCTION):Finish()

-- PRINTER TIER 5
local PRINTER_TIER_5 = "5Printers Tier 5"
BaseWars:CreateEntity("bw_printer_galactic"):SetClass("bw_printer_galactic"):SetCategory(PRINTERS_CATEGORY):SetSubCategory(PRINTER_TIER_5):SetName("Galactic Printer"):SetPrice(20e9):SetLevel(300):SetMax(4):SetModel(PRINTER_MODEL):Finish()
BaseWars:CreateEntity("bw_printer_cosmos"):SetClass("bw_printer_cosmos"):SetCategory(PRINTERS_CATEGORY):SetSubCategory(PRINTER_TIER_5):SetName("Cosmos Printer"):SetPrice(36e9):SetLevel(350):SetMax(4):SetModel(PRINTER_MODEL):Finish()
BaseWars:CreateEntity("bw_printer_infinity"):SetClass("bw_printer_infinity"):SetCategory(PRINTERS_CATEGORY):SetSubCategory(PRINTER_TIER_5):SetName("Infinity Printer"):SetPrice(51e9):SetLevel(400):SetMax(4):SetModel(PRINTER_MODEL):Finish()
BaseWars:CreateEntity("bw_printer_space"):SetClass("bw_printer_space"):SetCategory(PRINTERS_CATEGORY):SetSubCategory(PRINTER_TIER_5):SetName("Space Printer"):SetPrice(58e9):SetLevel(450):SetMax(4):SetModel(PRINTER_MODEL):Finish()
BaseWars:CreateEntity("bw_printer_celest"):SetClass("bw_printer_celest"):SetCategory(PRINTERS_CATEGORY):SetSubCategory(PRINTER_TIER_5):SetName("Celest Printer"):SetPrice(64e9):SetLevel(500):SetMax(4):SetModel(PRINTER_MODEL):Finish()
BaseWars:CreateEntity("bw_printer_orbital"):SetClass("bw_printer_orbital"):SetCategory(PRINTERS_CATEGORY):SetSubCategory(PRINTER_TIER_5):SetName("Orbital Printer"):SetPrice(80e9):SetLevel(550):SetMax(4):SetModel(PRINTER_MODEL):Finish()
BaseWars:CreateEntity("bw_printer_premium5"):SetClass("bw_printer_premium5"):SetCategory(PRINTERS_CATEGORY):SetSubCategory(PRINTER_TIER_5):SetName("Premium Printer 5"):SetPrice(80000000002):SetLevel(350):SetMax(4):SetModel(PRINTER_MODEL):SetRankCheck(IS_PREMIUM_FUNCTION):Finish()
BaseWars:CreateEntity("bw_printer_vip5"):SetClass("bw_printer_vip5"):SetCategory(PRINTERS_CATEGORY):SetSubCategory(PRINTER_TIER_5):SetName("VIP Printer 5"):SetPrice(80000000001):SetLevel(1):SetMax(4):SetModel(PRINTER_MODEL):SetRankCheck(IS_VIP_FUNCTION):Finish()
BaseWars:CreateEntity("bw_printer_premium6"):SetClass("bw_printer_premium6"):SetCategory(PRINTERS_CATEGORY):SetSubCategory(PRINTER_TIER_5):SetName("Premium Printer 6"):SetPrice(16e11):SetLevel(700):SetMax(4):SetModel(PRINTER_MODEL):SetRankCheck(IS_PREMIUM_FUNCTION):Finish()

-- PRESTIGE PRINTERS
local PRESTIGE_PRINTERS = "6Prestige Printers"
BaseWars:CreateEntity("bw_printer_prestige1"):SetClass("bw_printer_prestige1"):SetCategory(PRINTERS_CATEGORY):SetSubCategory(PRESTIGE_PRINTERS):SetName("Prestige Printer 1"):SetPrice(4000):SetLevel(5):SetMax(8):SetPrestige(1):SetModel(PRINTER_MODEL):Finish()
BaseWars:CreateEntity("bw_printer_prestige2"):SetClass("bw_printer_prestige2"):SetCategory(PRINTERS_CATEGORY):SetSubCategory(PRESTIGE_PRINTERS):SetName("Prestige Printer 2"):SetPrice(500000):SetLevel(15):SetMax(8):SetPrestige(3):SetModel(PRINTER_MODEL):Finish()
BaseWars:CreateEntity("bw_printer_prestige3"):SetClass("bw_printer_prestige3"):SetCategory(PRINTERS_CATEGORY):SetSubCategory(PRESTIGE_PRINTERS):SetName("Prestige Printer 3"):SetPrice(140000000):SetLevel(70):SetMax(8):SetPrestige(5):SetModel(PRINTER_MODEL):Finish()
BaseWars:CreateEntity("bw_printer_prestige4"):SetClass("bw_printer_prestige4"):SetCategory(PRINTERS_CATEGORY):SetSubCategory(PRESTIGE_PRINTERS):SetName("Prestige Printer 4"):SetPrice(32e8):SetLevel(170):SetMax(8):SetPrestige(7):SetModel(PRINTER_MODEL):Finish()
BaseWars:CreateEntity("bw_printer_prestige5"):SetClass("bw_printer_prestige5"):SetCategory(PRINTERS_CATEGORY):SetSubCategory(PRESTIGE_PRINTERS):SetName("Prestige Printer 5"):SetPrice(95e9):SetLevel(350):SetMax(8):SetPrestige(9):SetModel(PRINTER_MODEL):Finish()
BaseWars:CreateEntity("bw_printer_prestige6"):SetClass("bw_printer_prestige6"):SetCategory(PRINTERS_CATEGORY):SetSubCategory(PRESTIGE_PRINTERS):SetName("Prestige Printer 6"):SetPrice(16e10):SetLevel(700):SetMax(8):SetPrestige(11):SetModel(PRINTER_MODEL):Finish()
BaseWars:CreateEntity("bw_printer_prestige7"):SetClass("bw_printer_prestige7"):SetCategory(PRINTERS_CATEGORY):SetSubCategory(PRESTIGE_PRINTERS):SetName("Prestige Printer 7"):SetPrice(32e10):SetLevel(1400):SetMax(8):SetPrestige(13):SetModel(PRINTER_MODEL):Finish()
BaseWars:CreateEntity("bw_printer_prestige8"):SetClass("bw_printer_prestige8"):SetCategory(PRINTERS_CATEGORY):SetSubCategory(PRESTIGE_PRINTERS):SetName("Prestige Printer 8"):SetPrice(64e10):SetLevel(2100):SetMax(8):SetPrestige(15):SetModel(PRINTER_MODEL):Finish()
BaseWars:CreateEntity("bw_printer_prestige9"):SetClass("bw_printer_prestige9"):SetCategory(PRINTERS_CATEGORY):SetSubCategory(PRESTIGE_PRINTERS):SetName("Prestige Printer 9"):SetPrice(12e11):SetLevel(2800):SetMax(8):SetPrestige(17):SetModel(PRINTER_MODEL):Finish()
BaseWars:CreateEntity("bw_printer_prestige10"):SetClass("bw_printer_prestige10"):SetCategory(PRINTERS_CATEGORY):SetSubCategory(PRESTIGE_PRINTERS):SetName("Prestige Printer 10"):SetPrice(24e11):SetLevel(3500):SetMax(8):SetPrestige(19):SetModel(PRINTER_MODEL):Finish()
BaseWars:CreateEntity("bw_printer_prestige11"):SetClass("bw_printer_prestige11"):SetCategory(PRINTERS_CATEGORY):SetSubCategory(PRESTIGE_PRINTERS):SetName("Prestige Printer 11"):SetPrice(48e11):SetLevel(4200):SetMax(8):SetPrestige(21):SetModel(PRINTER_MODEL):Finish()
BaseWars:CreateEntity("bw_printer_prestige12"):SetClass("bw_printer_prestige12"):SetCategory(PRINTERS_CATEGORY):SetSubCategory(PRESTIGE_PRINTERS):SetName("Prestige Printer 12"):SetPrice(96e11):SetLevel(4900):SetMax(8):SetPrestige(23):SetModel(PRINTER_MODEL):Finish()
--BaseWars:CreateEntity("bw_printer_prestige13"):SetClass("bw_printer_prestige13"):SetCategory(PRINTERS_CATEGORY):SetSubCategory(PRESTIGE_PRINTERS):SetName("Prestige Printer 13"):SetPrice(70e27):SetLevel(1e7):SetMax(8):SetPrestige(50):SetModel(PRINTER_MODEL):Finish()

--[[-------------------------------------------------------------------------
	DEFENSES
---------------------------------------------------------------------------]]
local DEFENSE_TIER_1 = "1Defenses Tier 1"
BaseWars:CreateEntity("bw_mine"):SetClass("bw_mine"):SetCategory(DEFENSES_CATEGORY):SetSubCategory(DEFENSE_TIER_1):SetName("Mine"):SetPrice(40000):SetLevel(9):SetMax(3):SetModel(MINE_MODEL):Finish()
BaseWars:CreateEntity("bw_turret_ballistic"):SetClass("bw_base_turret2"):SetCategory(DEFENSES_CATEGORY):SetSubCategory(DEFENSE_TIER_1):SetName("Ballistic Turret"):SetPrice(85000):SetLevel(15):SetMax(2):SetModel(TURRET_MODEL):Finish()
BaseWars:CreateEntity("bw_turret_laser"):SetClass("bw_turret_laser"):SetCategory(DEFENSES_CATEGORY):SetSubCategory(DEFENSE_TIER_1):SetName("Laser Turret"):SetPrice(120000):SetLevel(15):SetMax(2):SetModel(TURRET_MODEL):Finish()
BaseWars:CreateEntity("bw_base_tesla"):SetClass("bw_base_tesla"):SetCategory(DEFENSES_CATEGORY):SetSubCategory(DEFENSE_TIER_1):SetName("Tesla"):SetPrice(65000000):SetLevel(20):SetMax(1):SetModel(TESLA_MODEL):Finish()

local DEFENSE_TIER_2 = "2Defenses Tier 2"
BaseWars:CreateEntity("bw_mine_speed"):SetClass("bw_mine_speed"):SetCategory(DEFENSES_CATEGORY):SetSubCategory(DEFENSE_TIER_2):SetName("Fast Mine"):SetPrice(80000):SetLevel(20):SetMax(2):SetModel(MINE_MODEL):Finish()
BaseWars:CreateEntity("bw_mine_power"):SetClass("bw_mine_power"):SetCategory(DEFENSES_CATEGORY):SetSubCategory(DEFENSE_TIER_2):SetName("Powerful Mine"):SetPrice(150000):SetLevel(25):SetMax(2):SetModel(MINE_MODEL):Finish()
BaseWars:CreateEntity("bw_mine_shock"):SetClass("bw_mine_shock"):SetCategory(DEFENSES_CATEGORY):SetSubCategory(DEFENSE_TIER_2):SetName("Shock Mine"):SetPrice(250000):SetLevel(30):SetMax(2):SetModel(MINE_MODEL):Finish()
BaseWars:CreateEntity("bw_turret_laser_vip"):SetClass("bw_turret_laser_vip"):SetCategory(DEFENSES_CATEGORY):SetSubCategory(DEFENSE_TIER_2):SetName("VIP Laser Turret"):SetPrice(1100000):SetLevel(45):SetMax(1):SetModel(TURRET_MODEL):SetRankCheck(IS_VIP_FUNCTION):Finish()
BaseWars:CreateEntity("bw_turret_ballistic_vip"):SetClass("bw_turret_ballistic_vip"):SetCategory(DEFENSES_CATEGORY):SetSubCategory(DEFENSE_TIER_2):SetName("VIP Balistic Turret"):SetPrice(1100000):SetLevel(45):SetMax(1):SetModel(TURRET_MODEL):SetRankCheck(IS_VIP_FUNCTION):Finish()
BaseWars:CreateEntity("bw_turret_ballistic_premium"):SetClass("bw_turret_ballistic_premium"):SetCategory(DEFENSES_CATEGORY):SetSubCategory(DEFENSE_TIER_2):SetName("Premium Balistic Turret"):SetPrice(1200000):SetLevel(45):SetMax(1):SetModel(TURRET_MODEL):SetRankCheck(IS_PREMIUM_FUNCTION):Finish()
BaseWars:CreateEntity("bw_turret_laser_premium"):SetClass("bw_turret_laser_premium"):SetCategory(DEFENSES_CATEGORY):SetSubCategory(DEFENSE_TIER_2):SetName("Premium laser Turret"):SetPrice(1200000):SetLevel(45):SetMax(1):SetModel(TURRET_MODEL):SetRankCheck(IS_PREMIUM_FUNCTION):Finish()
BaseWars:CreateEntity("bw_tesla_vip"):SetClass("bw_tesla_vip"):SetCategory(DEFENSES_CATEGORY):SetSubCategory(DEFENSE_TIER_2):SetName("VIP Tesla"):SetPrice(230000000):SetLevel(65):SetMax(1):SetModel(TESLA_MODEL):SetRankCheck(IS_VIP_FUNCTION):Finish()
BaseWars:CreateEntity("bw_tesla_premium"):SetClass("bw_tesla_premium"):SetCategory(DEFENSES_CATEGORY):SetSubCategory(DEFENSE_TIER_2):SetName("Premium Tesla"):SetPrice(240000000):SetLevel(66):SetMax(1):SetModel(TESLA_MODEL):SetRankCheck(IS_PREMIUM_FUNCTION):Finish()

--[[-------------------------------------------------------------------------
	RAIDS
---------------------------------------------------------------------------]]
local RAIDS_TOOLS = "Tools"
--BaseWars:CreateEntity("bw_heal_gun"):SetClass("bw_heal_gun"):SetCategory(RAID_CATEGORY):SetSubCategory(RAIDS_TOOLS):SetName("Heal Gun"):SetPrice(3500000):SetLevel(45):SetMax(5):SetModel("models/weapons/w_Physics.mdl"):SetIsWeapon(true):Finish()
BaseWars:CreateEntity("bw_blowtorch"):SetClass("bw_blowtorch"):SetCategory(RAID_CATEGORY):SetSubCategory(RAIDS_TOOLS):SetName("Blow Torch"):SetPrice(40000):SetLevel(9):SetMax(5):SetModel("models/weapons/w_irifle.mdl"):SetIsWeapon(true):Finish()
BaseWars:CreateEntity("bw_blowtorch_vip"):SetClass("bw_blowtorch_vip"):SetCategory(RAID_CATEGORY):SetSubCategory(RAIDS_TOOLS):SetName("Blow Torch VIP"):SetPrice(60000):SetLevel(9):SetMax(5):SetModel("models/weapons/w_irifle.mdl"):SetIsWeapon(true):SetRankCheck(IS_VIP_FUNCTION):Finish()
BaseWars:CreateEntity("bw_blowtorch_premium"):SetClass("bw_blowtorch_premium"):SetCategory(RAID_CATEGORY):SetSubCategory(RAIDS_TOOLS):SetName("Blow Torch Premium"):SetPrice(80000):SetLevel(9):SetMax(5):SetModel("models/weapons/w_irifle.mdl"):SetIsWeapon(true):SetRankCheck(IS_PREMIUM_FUNCTION):Finish()

local RAIDS_EXPLOSIVES = "Explosives"
BaseWars:CreateEntity("bw_weapon_c4"):SetClass("bw_weapon_c4"):SetCategory(RAID_CATEGORY):SetSubCategory(RAIDS_EXPLOSIVES):SetName("C4"):SetPrice(5500000):SetLevel(30):SetMax(1):SetModel("models/weapons/w_c4.mdl"):SetCooldown(5):SetIsWeapon(true):Finish()
BaseWars:CreateEntity("bw_explosive_bigbomb"):SetClass("bw_explosive_bigbomb"):SetCategory(RAID_CATEGORY):SetSubCategory(RAIDS_EXPLOSIVES):SetName("Big Bomb"):SetPrice(500000000):SetLevel(45):SetMax(1):SetModel("models/props_c17/oildrum001.mdl"):Finish()
BaseWars:CreateEntity("bw_explosive_nuke"):SetClass("bw_explosive_nuke"):SetCategory(RAID_CATEGORY):SetSubCategory(RAIDS_EXPLOSIVES):SetName("Nuke"):SetPrice(25e12):SetLevel(125):SetMax(1):SetModel("models/props_phx/mk-82.mdl"):Finish()

--[[-------------------------------------------------------------------------
	MISC
---------------------------------------------------------------------------]]
local DISPENSER_TIER_1 = "1Dispensers Tier 1"
BaseWars:CreateEntity("bw_base_armordispenser"):SetClass("bw_base_armordispenser"):SetCategory(MISC_CATEGORY):SetSubCategory(DISPENSER_TIER_1):SetName("Armor Dispenser"):SetPrice(35000):SetLevel(20):SetMax(2):SetModel("models/props_combine/suit_charger001.mdl"):Finish()
BaseWars:CreateEntity("bw_base_healthdispenser"):SetClass("bw_base_healthdispenser"):SetCategory(MISC_CATEGORY):SetSubCategory(DISPENSER_TIER_1):SetName("Health Dispenser"):SetPrice(50000):SetLevel(15):SetMax(2):SetModel("models/props_combine/health_charger001.mdl"):Finish()
BaseWars:CreateEntity("bw_base_ammodispenser"):SetClass("bw_base_ammodispenser"):SetCategory(MISC_CATEGORY):SetSubCategory(DISPENSER_TIER_1):SetName("Ammo Dispenser"):SetPrice(65000):SetLevel(25):SetMax(2):SetModel("models/items/ammocrate_ar2.mdl"):Finish()

local DISPENSER_TIER_2 = "2Dispensers Tier 2"
BaseWars:CreateEntity("bw_armordispenser_v2"):SetClass("bw_armordispenser_v2"):SetCategory(MISC_CATEGORY):SetSubCategory(DISPENSER_TIER_2):SetName("Armor Dispenser V2"):SetPrice(20000000):SetLevel(110):SetMax(2):SetModel("models/props_combine/suit_charger001.mdl"):Finish()
BaseWars:CreateEntity("bw_healthdispenser_v2"):SetClass("bw_healthdispenser_v2"):SetCategory(MISC_CATEGORY):SetSubCategory(DISPENSER_TIER_2):SetName("Health Dispenser V2"):SetPrice(25000000):SetLevel(80):SetMax(2):SetModel("models/props_combine/health_charger001.mdl"):Finish()
BaseWars:CreateEntity("bw_ammodispenser_v2"):SetClass("bw_ammodispenser_v2"):SetCategory(MISC_CATEGORY):SetSubCategory(DISPENSER_TIER_2):SetName("Ammo Dispenser V2"):SetPrice(30000000):SetLevel(125):SetMax(2):SetModel("models/items/ammocrate_ar2.mdl"):Finish()

local KITS = "3Kits"
BaseWars:CreateEntity("bw_base_armorkit"):SetClass("bw_base_armorkit"):SetCategory(MISC_CATEGORY):SetSubCategory(KITS):SetName("Armor Kit"):SetPrice(50000):SetLevel(25):SetMax(5):SetModel("models/props_junk/cardboard_box004a.mdl"):Finish()
BaseWars:CreateEntity("bw_advance_armorkit"):SetClass("bw_advance_armorkit"):SetCategory(MISC_CATEGORY):SetSubCategory(KITS):SetName("Advanced Armor Kit"):SetPrice(500000):SetLevel(80):SetMax(5):SetModel("models/props_junk/cardboard_box004a.mdl"):Finish()
BaseWars:CreateEntity("bw_repairkit"):SetClass("bw_repairkit"):SetCategory(MISC_CATEGORY):SetSubCategory(KITS):SetName("Repair Kit"):SetPrice(25000):SetLevel(20):SetMax(5):SetModel("models/Items/car_battery01.mdl"):Finish()

local STRUCTURES = "4Structures"
BaseWars:CreateEntity("bw_spawnpoint"):SetClass("bw_spawnpoint"):SetCategory(MISC_CATEGORY):SetSubCategory(STRUCTURES):SetName("Spawn Point"):SetPrice(25000):SetLevel(1):SetMax(3):SetModel("models/props_trainstation/trainstation_clock001.mdl"):SetCustomSpawn(true):Finish()
BaseWars:CreateEntity("bw_radar"):SetClass("bw_radar"):SetCategory(MISC_CATEGORY):SetSubCategory(STRUCTURES):SetName("Radar"):SetPrice(25000000):SetLevel(35):SetMax(1):SetModel("models/props_rooftop/roof_dish001.mdl"):Finish()
BaseWars:CreateEntity("mediaplayer_tv"):SetClass("mediaplayer_tv"):SetCategory(MISC_CATEGORY):SetSubCategory(STRUCTURES):SetName("Media Player TV"):SetPrice(50000):SetLevel(10):SetMax(1):SetModel("models/gmod_tower/flatscreen.mdl"):Finish()
BaseWars:CreateEntity("rammel_boombox"):SetClass("rammel_boombox"):SetCategory(MISC_CATEGORY):SetSubCategory(STRUCTURES):SetName("BoomBox"):SetPrice(1000):SetLevel(10):SetMax(1):SetModel("models/rammel/boombox.mdl"):Finish()
--local VEHICLES = "Vehicles"
--BaseWars:CreateEntity("hoverboard"):SetClass("hoverboards"):SetCategory(MISC_CATEGORY):SetSubCategory(VEHICLES):SetName("HoverBoard"):SetPrice(2000000000):SetLevel(1000):SetMax(1):SetModel(""):SetVehicleName("HoverBoard"):Finish()

--[[-------------------------------------------------------------------------
	WEAPONS
---------------------------------------------------------------------------]]
local LEANPROD = "1Lean Production"
BaseWars:CreateEntity("lean_barrel"):SetClass("lean_barrel"):SetCategory(FARMING_CATEGORY):SetSubCategory(LEANPROD):SetName("Barrel"):SetPrice(4e9):SetLevel(250):SetMax(1):SetModel("models/freeman/codeine_barrel.mdl"):Finish()
BaseWars:CreateEntity("lean_smallcrate"):SetClass("lean_smallcrate"):SetCategory(FARMING_CATEGORY):SetSubCategory(LEANPROD):SetName("Lean Crate"):SetPrice(4e9):SetLevel(250):SetMax(1):SetModel("models/freeman/codeine_crate.mdl"):Finish()
BaseWars:CreateEntity("lean_cup"):SetClass("lean_cup"):SetCategory(FARMING_CATEGORY):SetSubCategory(LEANPROD):SetName("Lean Cup"):SetPrice(2e8):SetLevel(250):SetMax(4):SetModel("models/freeman/codeine_cup.mdl"):Finish()

local ZEROS_FIRECRACKER = "2Zero's FireCracker"
BaseWars:CreateEntity("zcm_crackermachine"):SetClass("zcm_crackermachine"):SetCategory(FARMING_CATEGORY):SetSubCategory(ZEROS_FIRECRACKER):SetName("Fire Cracker Machine"):SetPrice(45e9):SetLevel(750):SetMax(1):SetModel("models/zerochain/props_crackermaker/zcm_base.mdl"):SetPrestige(3):Finish()
BaseWars:CreateEntity("zcm_box"):SetClass("zcm_box"):SetCategory(FARMING_CATEGORY):SetSubCategory(ZEROS_FIRECRACKER):SetName("Fire Cracker Box"):SetPrice(5e9):SetLevel(750):SetMax(1):SetModel("models/zerochain/props_crackermaker/zcm_box.mdl"):SetPrestige(3):Finish()
BaseWars:CreateEntity("zcm_blackpowder"):SetClass("zcm_blackpowder"):SetCategory(FARMING_CATEGORY):SetSubCategory(ZEROS_FIRECRACKER):SetName("Black Powder"):SetPrice(1e9):SetLevel(750):SetMax(1):SetModel("models/zerochain/props_crackermaker/zcm_blackpowder.mdl"):SetPrestige(3):Finish()
BaseWars:CreateEntity("zcm_paperroll"):SetClass("zcm_paperroll"):SetCategory(FARMING_CATEGORY):SetSubCategory(ZEROS_FIRECRACKER):SetName("Paper Roll"):SetPrice(1e9):SetLevel(750):SetMax(1):SetModel("models/zerochain/props_crackermaker/zcm_paper.mdl"):SetPrestige(3):Finish()

local BITMIER = "3Bitminer 2"
BaseWars:CreateEntity("bm2_bitminer_rack"):SetClass("bm2_bitminer_rack"):SetCategory(FARMING_CATEGORY):SetSubCategory(BITMIER):SetName("Bitminer Rack"):SetPrice(625e9):SetLevel(2500):SetMax(1):SetModel("models/bitminers2/bitminer_rack.mdl"):SetPrestige(7):Finish()
BaseWars:CreateEntity("bm2_generator"):SetClass("bm2_generator"):SetCategory(FARMING_CATEGORY):SetSubCategory(BITMIER):SetName("Generator"):SetPrice(625e9):SetLevel(2500):SetMax(1):SetModel("models/bitminers2/generator.mdl"):SetPrestige(7):Finish()
BaseWars:CreateEntity("bm2_fuel"):SetClass("bm2_fuel"):SetCategory(FARMING_CATEGORY):SetSubCategory(BITMIER):SetName("Fuel"):SetPrice(50e9):SetLevel(2500):SetMax(5):SetModel("models/props_junk/gascan001a.mdl"):SetPrestige(7):Finish()
BaseWars:CreateEntity("bm2_extra_fuel_tank"):SetClass("bm2_extra_fuel_tank"):SetCategory(FARMING_CATEGORY):SetSubCategory(BITMIER):SetName("Fuel Tank"):SetPrice(2e12):SetLevel(2500):SetMax(1):SetModel("models/bitminers2/bm2_extra_fueltank.mdl"):SetPrestige(7):SetRankCheck(IS_VIP_FUNCTION):Finish()
BaseWars:CreateEntity("bm2_extra_fuel_line"):SetClass("bm2_extra_fuel_line"):SetCategory(FARMING_CATEGORY):SetSubCategory(BITMIER):SetName("Fuel Line"):SetPrice(1e12):SetLevel(2500):SetMax(1):SetModel("models/bitminers2/bm2_extra_fuel_plug.mdl"):SetPrestige(7):SetRankCheck(IS_VIP_FUNCTION):Finish()
BaseWars:CreateEntity("bm2_large_fuel"):SetClass("bm2_large_fuel"):SetCategory(FARMING_CATEGORY):SetSubCategory(BITMIER):SetName("Large Fuel"):SetPrice(100e9):SetLevel(2500):SetMax(5):SetModel("models/props/de_train/barrel.mdl"):SetPrestige(7):SetRankCheck(IS_VIP_FUNCTION):Finish()
BaseWars:CreateEntity("bm2_bitminer_server"):SetClass("bm2_bitminer_server"):SetCategory(FARMING_CATEGORY):SetSubCategory(BITMIER):SetName("Bitminer Server"):SetPrice(70e9):SetLevel(2500):SetMax(8):SetModel("models/bitminers2/bitminer_2.mdl"):SetPrestige(7):Finish()
BaseWars:CreateEntity("bm2_power_lead"):SetClass("bm2_power_lead"):SetCategory(FARMING_CATEGORY):SetSubCategory(BITMIER):SetName("Power Lead"):SetPrice(625e9):SetLevel(2500):SetMax(1):SetModel("models/bitminers2/bitminer_plug_2.mdl"):SetPrestige(7):Finish()

local ZEROS_OILRUSH = "4Zero's Oilrush"
BaseWars:CreateEntity("zrush_machinecrate"):SetClass("zrush_machinecrate"):SetCategory(FARMING_CATEGORY):SetSubCategory(ZEROS_OILRUSH):SetName("Oil Mahine Crate"):SetPrice(10e9):SetLevel(5000):SetMax(4):SetModel("models/zerochain/props_oilrush/zor_machinecrate.mdl"):SetPrestige(12):Finish()
BaseWars:CreateEntity("zrush_barrel"):SetClass("zrush_barrel"):SetCategory(FARMING_CATEGORY):SetSubCategory(ZEROS_OILRUSH):SetName("Oil Barrel"):SetPrice(25e9):SetLevel(5000):SetMax(5):SetModel("models/zerochain/props_oilrush/zor_barrel.mdl"):SetPrestige(12):Finish()
BaseWars:CreateEntity("zrush_drillpipe_holder"):SetClass("zrush_drillpipe_holder"):SetCategory(FARMING_CATEGORY):SetSubCategory(ZEROS_OILRUSH):SetName("Oil Drill Pipe"):SetPrice(100e9):SetLevel(5000):SetMax(5):SetModel("models/zerochain/props_oilrush/zor_drillpipe_holder.mdl"):SetPrestige(12):Finish()


local METH_LAB = "5Zero's Methlab"
BaseWars:CreateEntity("zmlab_frezzer"):SetClass("zmlab_frezzer"):SetCategory(FARMING_CATEGORY):SetSubCategory(METH_LAB):SetName("Freezer"):SetPrice(14e12):SetLevel(15000):SetMax(1):SetModel("models/zerochain/zmlab/zmlab_frezzer.mdl"):SetPrestige(18):Finish()
BaseWars:CreateEntity("zmlab_combiner"):SetClass("zmlab_combiner"):SetCategory(FARMING_CATEGORY):SetSubCategory(METH_LAB):SetName("Combiner"):SetPrice(14e12):SetLevel(15000):SetMax(1):SetModel("models/zerochain/zmlab/zmlab_combiner.mdl"):SetPrestige(18):Finish()
BaseWars:CreateEntity("zmlab_filter"):SetClass("zmlab_filter"):SetCategory(FARMING_CATEGORY):SetSubCategory(METH_LAB):SetName("Filter"):SetPrice(14e12):SetLevel(15000):SetMax(2):SetModel("models/zerochain/zmlab/zmlab_filter.mdl"):SetPrestige(18):Finish()
BaseWars:CreateEntity("zmlab_collectcrate"):SetClass("zmlab_collectcrate"):SetCategory(FARMING_CATEGORY):SetSubCategory(METH_LAB):SetName("Transport Crate"):SetPrice(1e11):SetLevel(15000):SetMax(2):SetModel("models/zerochain/zmlab/zmlab_transportcrate.mdl"):SetPrestige(18):Finish()
BaseWars:CreateEntity("zmlab_aluminium"):SetClass("zmlab_aluminium"):SetCategory(FARMING_CATEGORY):SetSubCategory(METH_LAB):SetName("Aluminium"):SetPrice(5e11):SetLevel(15000):SetMax(10):SetModel("models/zerochain/zmlab/zmlab_aluminiumbox.mdl"):SetPrestige(18):Finish()
BaseWars:CreateEntity("zmlab_methylamin"):SetClass("zmlab_methylamin"):SetCategory(FARMING_CATEGORY):SetSubCategory(METH_LAB):SetName("Methylamin"):SetPrice(5e11):SetLevel(15000):SetMax(10):SetModel("models/zerochain/zmlab/zmlab_methylamin.mdl"):SetPrestige(18):Finish()

local WEED = "6Weed"
BaseWars:CreateEntity("zwf_cable"):SetClass("zwf_cable"):SetCategory(FARMING_CATEGORY):SetSubCategory(WEED):SetName("Cable"):SetPrice(10e12):SetLevel(35000):SetMax(1):SetModel("models/zerochain/props_weedfarm/zwf_cable_vm.mdl"):SetPrestige(25):Finish()
BaseWars:CreateEntity("zwf_wateringcan"):SetClass("zwf_wateringcan"):SetCategory(FARMING_CATEGORY):SetSubCategory(WEED):SetName("Watering Can"):SetPrice(10e12):SetLevel(35000):SetMax(1):SetModel("models/zerochain/props_weedfarm/zwf_wateringcan_vm.mdl"):SetPrestige(25):Finish()
BaseWars:CreateEntity("zwf_shoptablet"):SetClass("zwf_shoptablet"):SetCategory(FARMING_CATEGORY):SetSubCategory(WEED):SetName("Tablet"):SetPrice(10e12):SetLevel(35000):SetMax(1):SetModel("models/zerochain/props_weedfarm/zwf_tablet.mdl"):SetPrestige(25):Finish()

local CIGARETTE = "7Cigarettes"
BaseWars:CreateEntity("cf_cigarette_machine"):SetClass("cf_cigarette_machine"):SetCategory(FARMING_CATEGORY):SetSubCategory(CIGARETTE):SetName("Cigarette Machine"):SetPrice(25e14):SetLevel(80000):SetMax(1):SetModel("models/cigarette_factory/cf_machine.mdl"):SetPrestige(30):Finish()
BaseWars:CreateEntity("cf_engine_upgrade"):SetClass("cf_engine_upgrade"):SetCategory(FARMING_CATEGORY):SetSubCategory(CIGARETTE):SetName("Machine Upgrade"):SetPrice(100e12):SetLevel(80000):SetMax(1):SetModel("models/maxofs2d/thruster_propeller.mdl"):SetPrestige(30):Finish()
BaseWars:CreateEntity("cf_storage_upgrade"):SetClass("cf_storage_upgrade"):SetCategory(FARMING_CATEGORY):SetSubCategory(CIGARETTE):SetName("Storage Upgrade"):SetPrice(100e12):SetLevel(80000):SetMax(1):SetModel("models/thrusters/jetpack.mdl"):SetPrestige(30):Finish()
BaseWars:CreateEntity("cf_delievery_box"):SetClass("cf_delievery_box"):SetCategory(FARMING_CATEGORY):SetSubCategory(CIGARETTE):SetName("Cigarette Box"):SetPrice(75e12):SetLevel(80000):SetMax(1):SetModel("models/props_junk/cardboard_box003a.mdl"):SetPrestige(30):Finish()
BaseWars:CreateEntity("cf_roll_paper"):SetClass("cf_roll_paper"):SetCategory(FARMING_CATEGORY):SetSubCategory(CIGARETTE):SetName("Paper"):SetPrice(25e12):SetLevel(80000):SetMax(3):SetModel("models/cigarette_factory/cf_rollpaper.mdl"):SetPrestige(30):Finish()
BaseWars:CreateEntity("cf_tobacco_pack"):SetClass("cf_tobacco_pack"):SetCategory(FARMING_CATEGORY):SetSubCategory(CIGARETTE):SetName("Tobacco"):SetPrice(25e12):SetLevel(80000):SetMax(3):SetModel("models/cigarette_factory/cf_tobacco_pack.mdl"):SetPrestige(30):Finish()

local METH2 = "8Zero's Methlab 2"
BaseWars:CreateEntity("zmlab2_tent"):SetClass("zmlab2_tent"):SetCategory(FARMING_CATEGORY):SetSubCategory(METH2):SetName("Tent"):SetPrice(1e14):SetLevel(100000):SetMax(1):SetModel("models/zerochain/props_methlab/zmlab2_tentkit.mdl"):SetPrestige(35):Finish()
BaseWars:CreateEntity("zmlab2_equipment"):SetClass("zmlab2_equipment"):SetCategory(FARMING_CATEGORY):SetSubCategory(METH2):SetName("Equipment"):SetPrice(1e14):SetLevel(100000):SetMax(1):SetModel("models/zerochain/props_methlab/zmlab2_chest.mdl"):SetPrestige(35):Finish()

--[[-------------------------------------------------------------------------
	WEAPONS
---------------------------------------------------------------------------]]
-- local GRENADES = "8Grenades"
-- BaseWars:CreateEntity("bw_grenade_gas"):SetClass("bw_grenade_gas"):SetCategory(WEAPONS_CATEGORY):SetSubCategory(GRENADES):SetName("Gas Grenade"):SetPrice(150000000):SetLevel(500):SetMax(5):SetModel("models/props_rooftop/roof_dish001.mdl"):SetPrestige(5):SetIsWeapon(true):Finish()

local PISTOLS = "1Pistols"
BaseWars:CreateEntity("arccw_bo1_asp"):SetClass("arccw_bo1_asp"):SetCategory(WEAPONS_CATEGORY):SetSubCategory(PISTOLS):SetName("ASP"):SetModel("models/weapons/arccw/c_bo1_asp.mdl"):SetPrice(20000):SetMax(5):SetLevel(20):SetIsWeapon(true):Finish()
BaseWars:CreateEntity("arccw_bo2_browninghp"):SetClass("arccw_bo2_browninghp"):SetCategory(WEAPONS_CATEGORY):SetSubCategory(PISTOLS):SetName("Browning High-Power"):SetModel("models/weapons/arccw/c_bo2_bhp.mdl"):SetPrice(15000):SetMax(5):SetLevel(20):SetIsWeapon(true):Finish()
BaseWars:CreateEntity("arccw_bo1_cz75"):SetClass("arccw_bo1_cz75"):SetCategory(WEAPONS_CATEGORY):SetSubCategory(PISTOLS):SetName("CZ 75"):SetModel("models/weapons/arccw/c_bo1_cz75.mdl"):SetPrice(30000):SetMax(5):SetLevel(20):SetIsWeapon(true):Finish()
BaseWars:CreateEntity("arccw_bo1_m1911"):SetClass("arccw_bo1_m1911"):SetCategory(WEAPONS_CATEGORY):SetSubCategory(PISTOLS):SetName("M1911"):SetModel("models/weapons/arccw/c_bo1_m1911.mdl"):SetPrice(25000):SetMax(5):SetLevel(20):SetIsWeapon(true):Finish()
BaseWars:CreateEntity("arccw_waw_p38"):SetClass("arccw_waw_p38"):SetCategory(WEAPONS_CATEGORY):SetSubCategory(PISTOLS):SetName("Walther P38"):SetModel("models/weapons/arccw/c_waw_p38.mdl"):SetPrice(10000):SetMax(5):SetLevel(20):SetIsWeapon(true):Finish()
BaseWars:CreateEntity("arccw_bo3_rk5"):SetClass("arccw_bo3_rk5"):SetCategory(WEAPONS_CATEGORY):SetSubCategory(PISTOLS):SetName("RK5 Triton"):SetModel("models/weapons/arccw/c_bo3_rk5.mdl"):SetPrice(40000):SetMax(5):SetLevel(20):SetIsWeapon(true):Finish()
BaseWars:CreateEntity("arccw_bo3_bloodhound"):SetClass("arccw_bo3_bloodhound"):SetCategory(WEAPONS_CATEGORY):SetSubCategory(PISTOLS):SetName("Bloodhound"):SetModel("models/weapons/arccw/c_bo2_rpd.mdl"):SetPrice(35000):SetMax(5):SetLevel(20):SetIsWeapon(true):Finish()
BaseWars:CreateEntity("arccw_bo1_python"):SetClass("arccw_bo1_python"):SetCategory(WEAPONS_CATEGORY):SetSubCategory(PISTOLS):SetName("Colt Python"):SetModel("models/weapons/arccw/c_bo1_python.mdl"):SetPrice(45000):SetMax(5):SetLevel(20):SetIsWeapon(true):Finish()
BaseWars:CreateEntity("arccw_bo2_judge"):SetClass("arccw_bo2_judge"):SetCategory(WEAPONS_CATEGORY):SetSubCategory(PISTOLS):SetName("Taurus Raging Judge"):SetModel("models/weapons/arccw/c_bo2_judge.mdl"):SetPrice(50000):SetMax(5):SetLevel(20):SetIsWeapon(true):Finish()

local SMG = "2SMG"
BaseWars:CreateEntity("arccw_bo1_spectre"):SetClass("arccw_bo1_spectre"):SetCategory(WEAPONS_CATEGORY):SetSubCategory(SMG):SetName("Spectre M4"):SetModel("models/weapons/arccw/c_bo1_spectre.mdl"):SetPrice(60000):SetMax(5):SetLevel(40):SetIsWeapon(true):Finish()
BaseWars:CreateEntity("arccw_bo1_skorpion"):SetClass("arccw_bo1_skorpion"):SetCategory(WEAPONS_CATEGORY):SetSubCategory(SMG):SetName("Skorpion"):SetModel("models/weapons/arccw/c_bo1_skorpion.mdl"):SetPrice(65000):SetMax(5):SetLevel(40):SetIsWeapon(true):Finish()
BaseWars:CreateEntity("arccw_bo1_uzi"):SetClass("arccw_bo1_uzi"):SetCategory(WEAPONS_CATEGORY):SetSubCategory(SMG):SetName("Uzi"):SetModel("models/weapons/arccw/c_bo1_uzi.mdl"):SetPrice(70000):SetMax(5):SetLevel(40):SetIsWeapon(true):Finish()
BaseWars:CreateEntity("arccw_bo2_mp7"):SetClass("arccw_bo2_mp7"):SetCategory(WEAPONS_CATEGORY):SetSubCategory(SMG):SetName("MP7"):SetModel("models/weapons/arccw/c_bo2_mp7.mdl"):SetPrice(75000):SetMax(5):SetLevel(40):SetIsWeapon(true):Finish()
BaseWars:CreateEntity("arccw_bo3_mp40"):SetClass("arccw_bo3_mp40"):SetCategory(WEAPONS_CATEGORY):SetSubCategory(SMG):SetName("MP40"):SetModel("models/weapons/arccw/c_bo3_mp40.mdl"):SetPrice(80000):SetMax(5):SetLevel(40):SetIsWeapon(true):Finish()
BaseWars:CreateEntity("arccw_bo2_mp5"):SetClass("arccw_bo2_mp5"):SetCategory(WEAPONS_CATEGORY):SetSubCategory(SMG):SetName("MP5"):SetModel("models/weapons/arccw/c_bo2_mp5.mdl"):SetPrice(90000):SetMax(5):SetLevel(40):SetIsWeapon(true):Finish()
BaseWars:CreateEntity("arccw_bo3_sten3"):SetClass("arccw_bo3_sten3"):SetCategory(WEAPONS_CATEGORY):SetSubCategory(SMG):SetName("Sten MK3"):SetModel("models/weapons/arccw/c_bo3_sten3.mdl"):SetPrice(85000):SetMax(5):SetLevel(40):SetIsWeapon(true):Finish()
BaseWars:CreateEntity("arccw_bo3_ppsh41"):SetClass("arccw_bo3_ppsh41"):SetCategory(WEAPONS_CATEGORY):SetSubCategory(SMG):SetName("PPSh-41"):SetModel("models/weapons/arccw/c_waw_ppsh41.mdl"):SetPrice(95000):SetMax(5):SetLevel(40):SetIsWeapon(true):Finish()
BaseWars:CreateEntity("arccw_bo2_vector"):SetClass("arccw_bo2_vector"):SetCategory(WEAPONS_CATEGORY):SetSubCategory(SMG):SetName("Kriss Vector"):SetModel("models/weapons/arccw/w_bo2_vector.mdl"):SetPrice(95000):SetMax(5):SetLevel(40):SetIsWeapon(true):Finish()
BaseWars:CreateEntity("arccw_bo2_scorpion"):SetClass("arccw_bo2_scorpion"):SetCategory(WEAPONS_CATEGORY):SetSubCategory(SMG):SetName("Scorpion Evo 3"):SetModel("models/weapons/arccw/w_bo2_scorpion.mdl"):SetPrice(95000):SetMax(5):SetLevel(40):SetIsWeapon(true):Finish()
BaseWars:CreateEntity("arccw_bo2_msmc"):SetClass("arccw_bo2_msmc"):SetCategory(WEAPONS_CATEGORY):SetSubCategory(SMG):SetName("MSMC"):SetModel("models/weapons/arccw/w_bo2_msmc.mdl"):SetPrice(95000):SetMax(5):SetLevel(40):SetIsWeapon(true):Finish()
BaseWars:CreateEntity("arccw_bo3_kuda"):SetClass("arccw_bo3_kuda"):SetCategory(WEAPONS_CATEGORY):SetSubCategory(SMG):SetName("Kuda AP9"):SetModel("models/weapons/arccw/c_bo3_kuda.mdl"):SetPrice(95000):SetMax(5):SetLevel(40):SetIsWeapon(true):Finish()
-- BaseWars:CreateEntity("m9k_honeybadger"):SetClass("m9k_honeybadger"):SetCategory(WEAPONS_CATEGORY):SetSubCategory(SMG):SetName("Honey Badger"):SetModel("models/weapons/w_aac_honeybadger.mdl"):SetPrice(100000):SetMax(5):SetLevel(40):SetIsWeapon(true):Finish()

local ASSAULT_RIFLES = "3Assault Rifles"
BaseWars:CreateEntity("arccw_cde_ak5"):SetClass("arccw_cde_ak5"):SetCategory(WEAPONS_CATEGORY):SetSubCategory(ASSAULT_RIFLES):SetName("AK5"):SetModel("models/weapons/arccw/c_cde_ak5.mdl"):SetPrice(200000):SetMax(5):SetLevel(60):SetIsWeapon(true):Finish()
BaseWars:CreateEntity("arccw_bo2_mtar"):SetClass("arccw_bo2_mtar"):SetCategory(WEAPONS_CATEGORY):SetSubCategory(ASSAULT_RIFLES):SetName("MTAR"):SetModel("models/weapons/arccw/w_bo2_mtar.mdl"):SetPrice(250000):SetMax(5):SetLevel(60):SetIsWeapon(true):Finish()
BaseWars:CreateEntity("arccw_bo1_ak47"):SetClass("arccw_bo1_ak47"):SetCategory(WEAPONS_CATEGORY):SetSubCategory(ASSAULT_RIFLES):SetName("AK-47"):SetModel("models/weapons/arccw/c_bo1_ak47.mdl"):SetPrice(300000):SetMax(5):SetLevel(60):SetIsWeapon(true):Finish()
BaseWars:CreateEntity("arccw_bo2_an94"):SetClass("arccw_bo2_an94"):SetCategory(WEAPONS_CATEGORY):SetSubCategory(ASSAULT_RIFLES):SetName("AN-94"):SetModel("models/weapons/arccw/w_bo2_an94.mdl"):SetPrice(350000):SetMax(5):SetLevel(60):SetIsWeapon(true):Finish()
BaseWars:CreateEntity("arccw_bo2_thompson"):SetClass("arccw_bo2_thompson"):SetCategory(WEAPONS_CATEGORY):SetSubCategory(ASSAULT_RIFLES):SetName("Thompson"):SetModel("models/weapons/arccw/c_bo2_thompson.mdl"):SetPrice(400000):SetMax(5):SetLevel(60):SetIsWeapon(true):Finish()
BaseWars:CreateEntity("arccw_bo2_osw"):SetClass("arccw_bo2_osw"):SetCategory(WEAPONS_CATEGORY):SetSubCategory(ASSAULT_RIFLES):SetName("FN FAL"):SetModel("models/weapons/arccw/w_bo2_osw.mdl"):SetPrice(450000):SetMax(5):SetLevel(60):SetIsWeapon(true):Finish()
BaseWars:CreateEntity("arccw_bo1_m16"):SetClass("arccw_bo1_m16"):SetCategory(WEAPONS_CATEGORY):SetSubCategory(ASSAULT_RIFLES):SetName("Colt M16A1"):SetModel("models/weapons/arccw/c_bo1_m16a1.mdl"):SetPrice(500000):SetMax(5):SetLevel(60):SetIsWeapon(true):Finish()
BaseWars:CreateEntity("arccw_bo2_sig556"):SetClass("arccw_bo2_sig556"):SetCategory(WEAPONS_CATEGORY):SetSubCategory(ASSAULT_RIFLES):SetName("SIG 556"):SetModel("models/weapons/arccw/w_bo2_sig556.mdl"):SetPrice(550000):SetMax(5):SetLevel(60):SetIsWeapon(true):Finish()
BaseWars:CreateEntity("arccw_bo3_icr1"):SetClass("arccw_bo3_icr1"):SetCategory(WEAPONS_CATEGORY):SetSubCategory(ASSAULT_RIFLES):SetName("ICR 1"):SetModel("models/weapons/arccw/w_bo3_icr1.mdl"):SetPrice(600000):SetMax(5):SetLevel(60):SetIsWeapon(true):Finish()
BaseWars:CreateEntity("arccw_bo2_m27"):SetClass("arccw_bo2_m27"):SetCategory(WEAPONS_CATEGORY):SetSubCategory(ASSAULT_RIFLES):SetName("HK416"):SetModel("models/weapons/arccw/c_bo2_m27.mdl"):SetPrice(650000):SetMax(5):SetLevel(60):SetIsWeapon(true):Finish()
BaseWars:CreateEntity("arccw_bo1_galil"):SetClass("arccw_bo1_galil"):SetCategory(WEAPONS_CATEGORY):SetSubCategory(ASSAULT_RIFLES):SetName("Galil"):SetModel("models/weapons/arccw/c_bo1_galil.mdl"):SetPrice(700000):SetMax(5):SetLevel(60):SetIsWeapon(true):Finish()
BaseWars:CreateEntity("arccw_bo1_famas"):SetClass("arccw_bo1_famas"):SetCategory(WEAPONS_CATEGORY):SetSubCategory(ASSAULT_RIFLES):SetName("Famas"):SetModel("models/weapons/arccw/c_bo1_famas.mdl"):SetPrice(700000):SetMax(5):SetLevel(60):SetIsWeapon(true):Finish()

local SNIPER_RIFLES = "4Sniper Rifles"
BaseWars:CreateEntity("arccw_waw_arisaka"):SetClass("arccw_waw_arisaka"):SetCategory(WEAPONS_CATEGORY):SetSubCategory(SNIPER_RIFLES):SetName("Arisaka"):SetModel("models/weapons/arccw/w_waw_arisaka.mdl"):SetPrice(800000):SetLevel(90):SetIsWeapon(true):Finish()
BaseWars:CreateEntity("arccw_waw_mosin"):SetClass("arccw_waw_mosin"):SetCategory(WEAPONS_CATEGORY):SetSubCategory(SNIPER_RIFLES):SetName("Mosin"):SetModel("models/weapons/arccw/w_waw_mosin.mdl"):SetPrice(850000):SetLevel(90):SetIsWeapon(true):Finish()
BaseWars:CreateEntity("arccw_waw_k98k"):SetClass("arccw_waw_k98k"):SetCategory(WEAPONS_CATEGORY):SetSubCategory(SNIPER_RIFLES):SetName("Kar-98K"):SetModel("models/weapons/arccw/w_waw_k98k.mdl"):SetPrice(900000):SetLevel(90):SetIsWeapon(true):Finish()
BaseWars:CreateEntity("arccw_bo2_ballista"):SetClass("arccw_bo2_ballista"):SetCategory(WEAPONS_CATEGORY):SetSubCategory(SNIPER_RIFLES):SetName("Ballista"):SetModel("models/weapons/arccw/w_bo2_ballista.mdl"):SetPrice(950000):SetLevel(90):SetIsWeapon(true):Finish()
BaseWars:CreateEntity("arccw_bo2_dsr50"):SetClass("arccw_bo2_dsr50"):SetCategory(WEAPONS_CATEGORY):SetSubCategory(SNIPER_RIFLES):SetName("DSR-50"):SetModel("models/weapons/arccw/w_bo2_dsr50.mdl"):SetPrice(1000000):SetLevel(100):SetIsWeapon(true):Finish()
BaseWars:CreateEntity("arccw_bo1_l96"):SetClass("arccw_bo1_l96"):SetCategory(WEAPONS_CATEGORY):SetSubCategory(SNIPER_RIFLES):SetName("L96A1"):SetModel("models/weapons/w_cstm_l96.mdl"):SetPrice(1500000):SetLevel(100):SetIsWeapon(true):Finish()

local SHOTGUNS = "5Shotguns"
BaseWars:CreateEntity("arccw_bo1_ks23"):SetClass("arccw_bo1_ks23"):SetCategory(WEAPONS_CATEGORY):SetSubCategory(SHOTGUNS):SetName("KS 23"):SetModel("models/weapons/arccw/c_bo1_ks23.mdl"):SetPrice(2000000):SetMax(5):SetLevel(120):SetIsWeapon(true):Finish()
BaseWars:CreateEntity("arccw_bo1_ithaca"):SetClass("arccw_bo1_ithaca"):SetCategory(WEAPONS_CATEGORY):SetSubCategory(SHOTGUNS):SetName("Ithaca 37"):SetModel("models/weapons/arccw/c_bo1_ithaca.mdl"):SetPrice(2500000):SetMax(5):SetLevel(120):SetIsWeapon(true):Finish()
BaseWars:CreateEntity("arccw_bo1_olympia"):SetClass("arccw_bo1_olympia"):SetCategory(WEAPONS_CATEGORY):SetSubCategory(SHOTGUNS):SetName("Olympia"):SetModel("models/weapons/arccw/c_bo1_olympia.mdl"):SetPrice(3000000):SetMax(5):SetLevel(120):SetIsWeapon(true):Finish()
BaseWars:CreateEntity("arccw_bo2_ksg"):SetClass("arccw_bo2_ksg"):SetCategory(WEAPONS_CATEGORY):SetSubCategory(SHOTGUNS):SetName("Kel-Tec KSG"):SetModel("models/weapons/arccw/c_bo2_ksg.mdl"):SetPrice(3500000):SetMax(5):SetLevel(120):SetIsWeapon(true):Finish()
BaseWars:CreateEntity("arccw_bo2_r870"):SetClass("arccw_bo2_r870"):SetCategory(WEAPONS_CATEGORY):SetSubCategory(SHOTGUNS):SetName("Remington 870 MCS"):SetModel("models/weapons/arccw/c_bo2_r870.mdl"):SetPrice(4000000):SetMax(5):SetLevel(120):SetIsWeapon(true):Finish()

local SPECIALS = "6Specials"
BaseWars:CreateEntity("arccw_bo1_shiv"):SetClass("arccw_bo1_shiv"):SetCategory(WEAPONS_CATEGORY):SetSubCategory(SPECIALS):SetName("Shiv"):SetModel("models/weapons/arccw/c_bo1_shiv.mdl"):SetPrice(10000000):SetMax(5):SetLevel(250):SetIsWeapon(true):Finish()
BaseWars:CreateEntity("arccw_bo1_sog_knife"):SetClass("arccw_bo1_sog_knife"):SetCategory(WEAPONS_CATEGORY):SetSubCategory(SPECIALS):SetName("S.O.G Knife"):SetModel("models/weapons/arccw/c_bo1_sog_knife.mdl"):SetPrice(10000000):SetMax(5):SetLevel(250):SetIsWeapon(true):Finish()


--local CWWEAPONS = "6CW Weapons"
--BaseWars:CreateEntity("cw_famasg2_official"):SetClass("cw_famasg2_official"):SetCategory(WEAPONS_CATEGORY):SetSubCategory(CWWEAPONS):SetName("Famas G2"):SetModel("models/weapons/cstrike/c_rif_famas.mdl"):SetPrice(200000000):SetMax(5):SetLevel(300):SetPrestige(1):SetIsWeapon(true):Finish()
--BaseWars:CreateEntity("cw_scarh"):SetClass("cw_scarh"):SetCategory(WEAPONS_CATEGORY):SetSubCategory(CWWEAPONS):SetName("SCAR-H"):SetModel("models/cw2/rifles/w_scarh.mdl"):SetPrice(200000000):SetMax(5):SetLevel(300):SetPrestige(1):SetIsWeapon(true):Finish()
--BaseWars:CreateEntity("cw_xm1014_official"):SetClass("cw_xm1014_official"):SetCategory(WEAPONS_CATEGORY):SetSubCategory(CWWEAPONS):SetName("M4 Super 90"):SetModel("models/weapons/w_cstm_m3super90.mdl"):SetPrice(400000000):SetMax(5):SetLevel(300):SetPrestige(1):SetIsWeapon(true):Finish()
--BaseWars:CreateEntity("cw_shorty"):SetClass("cw_shorty"):SetCategory(WEAPONS_CATEGORY):SetSubCategory(CWWEAPONS):SetName("Saiga-12K"):SetModel("models/weapons/cw2_super_shorty.mdl"):SetPrice(400000000):SetMax(5):SetLevel(300):SetPrestige(1):SetIsWeapon(true):Finish()
--BaseWars:CreateEntity("cw_ump45"):SetClass("cw_ump45"):SetCategory(WEAPONS_CATEGORY):SetSubCategory(CWWEAPONS):SetName("UMP45"):SetModel("models/weapons/w_hk_ump45.mdl"):SetPrice(600000000):SetMax(5):SetLevel(300):SetPrestige(1):SetIsWeapon(true):Finish()
--BaseWars:CreateEntity("cw_mp7_official"):SetClass("cw_mp7_official"):SetCategory(WEAPONS_CATEGORY):SetSubCategory(CWWEAPONS):SetName("MP7"):SetModel("models/cw2/smgs/mp7_world.mdl"):SetPrice(600000000):SetMax(5):SetLevel(300):SetPrestige(1):SetIsWeapon(true):Finish()
--BaseWars:CreateEntity("cw_svd_official"):SetClass("cw_svd_official"):SetCategory(WEAPONS_CATEGORY):SetSubCategory(CWWEAPONS):SetName("SVD"):SetModel("models/cw2/rifles/svd_world.mdl"):SetPrice(800000000):SetMax(5):SetLevel(300):SetPrestige(1):SetIsWeapon(true):Finish()
--BaseWars:CreateEntity("cw_l115"):SetClass("cw_l115"):SetCategory(WEAPONS_CATEGORY):SetSubCategory(CWWEAPONS):SetName("L115"):SetModel("models/weapons/w_cstm_l96.mdl"):SetPrice(1000000000):SetMax(5):SetLevel(300):SetPrestige(1):SetIsWeapon(true):Finish()
