lean_config = lean_config || {}
lean_igconfig = lean_igconfig || {}

--[[-------------------------------------------------------------------------
General Config
---------------------------------------------------------------------------]]
lean_config.igconfigcmd = "!leancfg" -- Command to use for opening the in-game config
lean_config.maxpermitted = {"superadmin", "founder"} -- Ranks that can use the in-game config

--[[-------------------------------------------------------------------------
Don't edit anything below, It's all done in-game.
---------------------------------------------------------------------------]]
lean_config.categories = {
	"General",
	"Barrel",
	"Crate",
	"Small Crate",
	"Cup",
	"Capacities",
	"Prices",
	"NPC"
}
-- Barrel
lean_igconfig.barreldmg = {val = true,name = "Barrel Take Damage",category = "Barrel",desc = "Should the barrel take damage?"}
lean_igconfig.barrelhp = {val = 150,name = "Barrel HP",category = "Barrel",desc = "What HP should the barrel have?"}
lean_igconfig.shakeamount = {val = 50,name = "Shake Amount",category = "Barrel",desc = "How much should we have to shake the barrel?"}
lean_igconfig.extractamount = {val = 4,name = "Extract Amount",category = "Barrel",desc = "How many cups can you fill from 1 round of lean production?"}
lean_igconfig.manualshake = {val = true,name = "Manually shake barrel",category = "Barrel",desc = "Should we manually shake the barrel or should we press e and wait a timer? ( tick for shake )"}
lean_igconfig.mixingtime = {val = 30,name = "Mixing time",category = "Barrel",desc = "How long we have to wait in seconds for the barrel to mix ( if manualshake is turned off )"}
lean_igconfig.pingOnVel = {val = true,name = "Ping on shake",category = "Barrel",desc = "When shaking the barrel, should the barrel make a noise? (if shaking is enabled)"}
-- Cup
lean_igconfig.cupdmg = {val = true,name = "Cup Take Damage",category = "Cup",desc = "Should the polystyrene cup take damage?"}
lean_igconfig.cuphp = {val = 50,name = "Cup HP",category = "Cup",desc = "What HP should the cup have?"}
lean_igconfig.speedtime = {val = 20,name = "Speed Effects Time",category = "Cup",desc = "How long should the speed increase effects last?"}
lean_igconfig.allowleanuse = {val = true,name = "Allow Drinking Lean",category = "Cup",desc = "Should people be allowed to drink lean?"}
lean_igconfig.speedamount = {val = 500,name = "Speed Amount",category = "Cup",desc = "How much should we increase their speed after drinking lean?"}
-- Crate
lean_igconfig.cratehold = {val = 10,name = "Crate Capacity",category = "Crate",desc = "How many cups can the crate hold?"}
lean_igconfig.usetosell = {val = true,name = "Press E to pickup crate",category = "Crate",desc = "Use E to pickup the crate? ( true = press e, false = carry to npc"}
lean_igconfig.cratedmg = {val = true,name = "Crate Take Damage",category = "Crate",desc = "Should the crate take damage?"}
lean_igconfig.cratehp = {val = 200,name = "Crate HP",category = "Crate",desc = "What HP should the crate have?"}
lean_igconfig.cratedropcups = {val = true,name = "Drop cups on destroy",category = "Crate",desc = "Should we drop the cups on the floor if the crate is destroyed? ( If there are too many cups this may cause lag )"}
-- General
lean_igconfig.currency = {val = "$",name = "Currency",category = "General",desc = "What currency should we use?"}
lean_igconfig.prefix = {val = "[Lean Production]",name = "Chat Prefix",category = "General",desc = "What should we display before all chat messages?"}
lean_igconfig.prefixcol = {val = Color(255,0,0),name = "Chat Prefix Color",category = "General",desc = "What colour should the chat prefix be?"}
lean_igconfig.sellprice = {val = 10000,name = "Lean Sell Price",category = "General",desc = "How much 1 cup of lean will sell for"}
lean_igconfig.usevrondakis = {val = false,name = "Use Vrondakis Levelling System",category = "General",desc = "Should we use Vrondakis levelling system to give XP when selling lean?"}
lean_igconfig.vrondakisamt = {val = 100,name = "Vrondakis XP Amount",category = "General",desc = "How much XP 1 cup of lean will give on selling"}
lean_igconfig.ingredientscooldown = {val = 0.5,name = "Ingredients Cooldown",category = "General",desc = "The cooldown before a player can add another ingredient (If this is too low your server can lag as exploiters like net messages with no cooldown)"}
-- Capacities
lean_igconfig.requiredsprite = {val = 4,name = "Required Sprite",category = "Capacities",desc = "Required amount of sprite to begin mixing process"}
lean_igconfig.requiredcodeine = {val = 3,name = "Required Codeine",category = "Capacities",desc = "Required amount of codeine to begin mixing process"}
lean_igconfig.requiredranchers = {val = 5,name = "Required Jolly-Ranchers",category = "Capacities",desc = "Required jolly-ranchers to begin mixing process"}
lean_igconfig.requiredice = {val = 6,name = "Required Ice Cubes",category = "Capacities",desc = "Required ice cubes to begin mixing process"}
-- Prices
lean_igconfig.sprite_price = {val = 0,name = "Sprite Price",category = "Prices",desc = "How much it costs for 1 sprite"}
lean_igconfig.codeine_price = {val = 0,name = "Codeine Price",category = "Prices",desc = "How much it costs for 1 codeine"}
lean_igconfig.ranchers_price = {val = 0,name = "Jolly-Ranchers Price",category = "Prices",desc = "How much it costs for 1 jolly-rancher"}
lean_igconfig.ice_price = {val = 0,name = "Ice Cube Price",category = "Prices",desc = "How much it costs for 1 ice cube"}
-- NPC
lean_igconfig.npcmodel = {val = "models/Humans/Group03/Male_04.mdl",name = "NPC Model",category = "NPC",desc = "Model for the Lean Buyer NPC"}
lean_igconfig.overheadtxt = {val = "Lean Buyer",name = "Overhead Text",category = "NPC",desc = "Text to display above the NPC's head ( dont make this too long )"}
lean_igconfig.subheading = {val = "Press E to sell",name = "Sub-Header",category = "NPC",desc = "Text to display under the header"}
lean_igconfig.nolean = {val = "Bring me some lean...",name = "No Lean Text",category = "NPC",desc = "What to tell the player if they have no lean"}
-- Small Crate
lean_igconfig.smalldmg = {val = true,name = "Take damage",category = "Small Crate",desc = "Should the small crate take damage?"}
lean_igconfig.smallhp = {val = 50,name = "HP",category = "Small Crate",desc = "How much HP should the small crate have?"}
lean_igconfig.smallhold = {val = 2,name = "Capacity",category = "Small Crate",desc = "How many cups can the small crate hold?"}
lean_igconfig.smalldrop = {val = true,name = "Drop cups",category = "Small Crate",desc = "Should we drop the cups inside the box when it's destroyed?"}