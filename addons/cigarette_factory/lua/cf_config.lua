cf = {}

-- CONFIG --

-- REMEMBER TO DOWNLOAD THE WORKSHOP CONTENT!!! https://steamcommunity.com/sharedfiles/filedetails/?id=1514815567

-- Sell Mode | Setting it to false allows selling cigarettes without bringing them to the export van.
-- Note that if you're using default sell mode you need to save spawned vans using cf_save command! Otherwise vans will disappear after server restart.
cf.InstantSellMode = false

-- Maximum amount of tobacco machine can contain.
cf.maxTobaccoStorage = 3000

-- Maximum default paper storage.
cf.maxPaperStorage = 300

-- Time (in seconds) it takes to produce one pack.
cf.timeToProduce = 5

-- Amount of paper it takes to produce one pack.
cf.paperProductionCost = 2

-- Amount of tobacco it takes to produce one pack.
cf.tobaccoProductionCost = 20

-- Time (in seconds) it takes for a cigarette pack to despawn (reduces lag).
cf.cigAutoDespawnTime = 14

-- Engine performance multiplier after engine upgrade (1.5 makes it 50% more efficient).
cf.engineUpgradeBoost = 1.5

-- Amount of additional storage after storage upgrade.
cf.storageUpgradeBoostTobacco = 1000
cf.storageUpgradeBoostPaper = 700

-- Base amount of $ you'll get for one pack sold.
cf.sellPrice = 390625e8

-- How often should the price change (in seconds).
cf.priceChangeTime = 99999999999999999999

-- Maximum difference in pack price.
cf.maxPriceDifference = 6

-- Max amount of packs that can fit into an export box.
cf.maxCigsBox = 64

-- Max amount of packs player can carry.
cf.maxCigsOnPlayer = 256

-- Machine maximum health
cf.maxMachineHealth = 300

-- Machine hp regen rate
cf.machineRegen = 0

-- Cigarette SWEP compatibility ( REQUIRES https://steamcommunity.com/sharedfiles/filedetails/?id=793269226&searchtext=cigarette !!!)
cf.allowSwep = false

-- Should vans respawn after map cleanup
cf.AutoRespawn = false

-- Translation
cf.StorageText = "STORAGE UPGRADE"
cf.StorageDescText = "Storage upgrade for AUTO-CIG"
cf.ProductionOffText = "PRODUCTION OFF"
cf.ProducingText = "PRODUCING"
cf.RefillNeededText = "REFILL NEEDED"
cf.EngineText = "ENGINE UPGRADE"
cf.EngineDescText = "Engine upgrade for AUTO-CIG"
cf.BoxText = "SHIPPING BOX"
cf.BoxDescText1 = "Box made solely for"
cf.BoxDescText2 = "exporting cigarettes."
cf.BoxDescText3 = "Packs inside: "
cf.BoxDescText4 = "Worth: "
cf.CurrencyText = "$"
cf.Notification1 = "You can't carry more than "
cf.Notification2 = " cigarettes!"
cf.Notification3 = "You picked up a box containg "
cf.Notification4 = " pack(s)!"
cf.MachineHealth = "HP"
cf.VanText = "EXPORT VAN"
cf.VanDescText1 = "Paying "
cf.VanDescText2 = " per one cigarette pack"
cf.SellText1 = "You sold "
cf.SellText2 = " cigarette pack(s) for "
cf.CommandText1 = "Export vans have been saved"
cf.CommandText2 = "Export vans have been loaded"

-- Fonts
if CLIENT then
	surface.CreateFont( "cf_machine_main", {
		font = "Impact",
		size = 24
	})
	surface.CreateFont( "cf_machine_small", {
		font = "Impact",
		size = 16,
		outline = true
	})
end