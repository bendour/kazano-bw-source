CH_Advent = CH_Advent or {}
CH_Advent.Config = CH_Advent.Config or {}
CH_Advent.Rewards = CH_Advent.Rewards or {}

--[[
	General
--]]
CH_Advent.Config.Language = "fr" -- Set the language of the script.

CH_Advent.Config.NotificationTime = 10 -- How long will notifications last?

CH_Advent.Config.BottomMenuText = "Kazano Basewars"

CH_Advent.Config.CanOpenMissedSquares = true -- Should players be able to open missed squares?

CH_Advent.Config.LockToSpecificMonth = true -- Should the advent calendar be locked to a specific month?
CH_Advent.Config.LockedToMonth = "December" -- Which month should the calendar be locked to? It will unlock the 1st in this month.

CH_Advent.Config.RanksToBypassChecks = { -- These ranks will bypass all checks and can continously open advent calendar squares. Set to true to enable bypass!
	["owner"] = false,
	["superadmin"] = false,
	["admin"] = false,
}

--[[
	Menu
--]]
CH_Advent.Config.OpenMenuOnConnect = false -- Should the advent calendar open when they spawn after connecting?

CH_Advent.Config.UseChatCommand = true -- Should we enable the chat command?
CH_Advent.Config.MenuChatCommand = "!calendrier" -- Chat command to open the menu

CH_Advent.Config.ShowRewardTooltip = true -- When hovering over an opened square should we show a tooltip with the reward they got?

CH_Advent.Config.MenuLinks = { -- You can put your links here and they will show in the advent calendar menu. Leave blank "" to disable one or more.
	["YouTube"] = "",
	["Discord"] = "",
	["Steam"] = "",
	["Website"] = "",
}

--[[
	NPC
--]]
CH_Advent.Config.DistanceTo3D2D = 50000 -- Distance to 3d2d above NPC

CH_Advent.Config.UseNPC = true -- Should we enable an NPC that lets you open the menu?
CH_Advent.Config.NPCModel = "models/kleiner.mdl" -- Model of the NPC

CH_Advent.Config.DrawDetailed3D2D = true -- Draw the detailed 3d2d above the npc?
CH_Advent.Config.DrawSimplistc3D2D = false -- Draw the simplistic 3d2d above the npc?

--[[
	History
--]]
CH_Advent.Config.HistoryCacheTime = 600 -- We keep the cache of the history for 600 seconds. After that it will be fetched from the DB upon next request.
CH_Advent.Config.LeaderboardCacheTime = 600 -- We keep the cache of the leaderboard for 600 seconds. After that it will be fetched from the DB upon next request.

--[[
	Reward
--]]
CH_Advent.Config.ConfettiOnReward = true -- Emit a confetti effect from the player when opening a reward (not coal)
CH_Advent.Config.SoundEmitOnReward = true -- Emit a sound from the player when opening a reward (not coal)

CH_Advent.Config.RewardXPOnOpenSquare = true -- Aside from the other reward in a square, should we give an amount of XP when opening a square (regardless of the reward)?
CH_Advent.Config.RewardXPAmount = 25 -- If enabled above we give this XP every time they open a square.

--[[
	Square colors
--]]
CH_Advent.Config.SquareColors = {
	[1] = Color( 47, 47, 47, 255 ), -- Gray
	[2] = Color( 156, 45, 43, 255 ), -- Red
	[3] = Color( 244, 237, 214, 255 ), -- Beige
	[4] = Color( 182, 198, 175, 255 ), -- Green
	[5] = Color( 156, 45, 43, 255 ), -- Red
	[6] = Color( 245, 238, 215, 255 ), -- Beige
	[7] = Color( 182, 198, 175, 255 ), -- Green
	[8] = Color( 182, 198, 175, 255 ), -- Green
	[9] = Color( 156, 45, 43, 255 ), -- Red
	[10] = Color( 228, 195, 156, 255 ), -- Dark beige
	[11] = Color( 47, 47, 47, 255 ), -- Gray
	[12] = Color( 156, 45, 43, 255 ), -- Red
	[13] = Color( 228, 195, 156, 255 ), -- Dark beige
	[14] = Color( 182, 198, 175, 255 ), -- Green
	[15] = Color( 156, 45, 43, 255 ), -- Red
	[16] = Color( 47, 47, 47, 255 ), -- Gray
	[17] = Color( 156, 45, 43, 255 ), -- Red
	[18] = Color( 182, 198, 175, 255 ), -- Green
	[19] = Color( 182, 198, 175, 255 ), -- Green
	[20] = Color( 182, 198, 175, 255 ), -- Green
	[21] = Color( 47, 47, 47, 255 ), -- Gray
	[22] = Color( 156, 45, 43, 255 ), -- Red
	[23] = Color( 182, 198, 175, 255 ), -- Green
	[24] = Color( 228, 195, 156, 255 ), -- Dark beige
}