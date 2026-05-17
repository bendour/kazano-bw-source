ashop.Config = ashop.Config or {}

ashop.Config.MySQL = {
	enable = false,
	host = "127.0.0.1",
	user = "root",
	password = "",
	database = "akulla",
	port = 3306
}

/*
	When giving coins based on their rank group,
	Should we give the maximum amount of all the group
	or make a sum ?
*/
ashop.maxOrAccumulation = false
ashop.BlockPac3Edit = true

// For TTT, these are premades hook you can enable to give credits at the end of a round
// Will also be used for deathrun
ashop.TTT_Credits_WinningTeam = { // Given credits at the end of rounds
	normal = 20,
	premium = 0
}

ashop.TTT_Credits_LosingTeam = { // Given credits at the end of rounds
	normal = 10,
	premium = 0
}

ashop.ZC_Credits_AlivePlayers = {
	normal = 20,
	premium = 0
}

// Prevent players from using weapon items outside the preparation phase
ashop.TTT_BlockWeaponOutsidePrep = false

// HARD RESET SETTING
// DON'T ENABLE IT EXCEPT IF YOU WANT TO RESET THE WHOLE ASHOP CONFIG
// YOU NEED TO PUT IT AS TRUE, THEN TYPE ashop_hardreset IN YOUR SERVER CONSOLE
// DON'T. ENABLE. IT. IF. NOT. NEEDED.
// THIS WILL KICK ALL PLAYERS
// ERASE DATABASE/ERASE ALL CONFIG
// FREEZE THE SERVER TILL SOMEONE FORCE REBOOT IT.
ashop.HardReset = false