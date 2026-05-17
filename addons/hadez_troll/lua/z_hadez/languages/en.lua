-- [[ CREATED BY ZOMBIE EXTINGUISHER ]]

local en = {
	search = "Search",
	toggle = "Toggle all",
	selectPlayer = "Select a player first!",
	themself = "Themself",
	everyone = "Everyone",
	targetAll = "Can target others",
	
	-- Mind control
	controlPlayer = "Control Player",
	stopControl = "Stop Control",
	invisibleOnControl = "Turn invisible during control",
	forcePhysgunOnControl = "Force physgun",
	stealChatOnControl = "Steal chat",
	mindControlLogEnabled = "[p] took control of [p]",
	mindControlLogDisabled = "[p] lost control of [p]",
	
	-- Rocket launch
	launchPlayer = "Launch Player",
	launchPlayers = "Launch Players",
	launchExplode = "Rocket go boooom",
	launchSound = "Use sound effects",
	rocketLaunchLogEnabled = "[p] launched [p]",
	
	-- Aimbot
	aimbotEnable = "Enable Aimbot",
	aimbotDisable = "Disable Aimbot",
	aimbotNeverMiss = "Bullets never miss",
	aimbotMagicBullets = "Wallbanging",
	aimbotVisibleOnly = "Visible targets only",
	aimbotCrosshairSort = "Target closests to crosshairs",
	aimbotPauseOnDeath = "Pause on target death",
	aimbotAlwaysActive = "Always active",
	aimbotLogEnabled = "[p] activated aimbot",
	aimbotLogDisabled = "[p] disabled aimbot",
	
	-- Wallhack
	wallhackToggle = "Toggle Wallhack",
	wallhackChams = "Chams",
	wallhackWireframe = "Wireframe",
	wallhackHitboxes = "Hitboxes",
	wallhackBones = "Bones",
	wallhackAimlines = "Aimline",
	wallhackWeapons = "Weapons",
	wallhackName = "Name",
	wallhackTeam = "Team",
	wallhackHealth = "Health",
	wallhackDistance = "Distance",
	wallhackLine = "Line to",
	wallhackWeaponInfo = "Weapon info",
	wallhackLogEnabled = "[p] activated wallhack for [p]",
	wallhackLogDisabled = "[p] disabled wallhack for [p]",
	
	-- Chat steal
	stealChat = "Steal Chat",
	returnChat = "Return Chat",
	chatStealMute = "Target can chat",
	chatStealLogEnabled = "[p] stole chat from [p]",
	chatStealLogDisabled = "[p] returned chat to [p]",
	
	-- Smite
	smitePlayer = "Smite Player",
	smitePlayers = "Smite Players",
	smiteLogEnabled = "[p] smited [p]",
	
	-- Blackout
	blackoutPlayer = "Toggle Blackout",
	blackoutLogEnabled = "[p] blacked out [p]",
	blackoutLogDisabled = "[p] awakened [p]",
	
	-- Ravebreak 
	ravebreak = "Ravebreak",
	ravebreakDance = "Force targets to dance",
	ravebreakColorize = "Enable color effects",
	ravebreakLogEnabled = "[p] ravebreaks [p]",
	
	-- Weapon break
	weaponBreak = "Break Weapons",
	weaponBreakSuicide = "Targets shoots himself",
	weaponBreakMiss = "Miss all shots",
	weaponBreakNoClipAmmo = "No clip ammo",
	weaponBreakNoReserveAmmo = "No reserve ammo",
	weaponBreakLogEnabled = "[p] broke weapons from [p]", 
	weaponBreakLogDisabled = "[p] restored weapons from [p]", 
	
	-- Bullet time
	bulletTime = "Bullet Time",
	bulletInvincible = "Invincible",
	bulletTimeReturn = "Return all damage",
	bulletTimeDodge = "Bullet dodge",
	bulletTimeSlowmo = "Slow motion",
	bulletTimeLogEnabled = "[p] activated bullet time for [p]",
	bulletTimeLogDisabled = "[p] disabled bullet time for [p]",
	
	-- Nuke
	nukeLaunch = "Launch Nuke",
	nukeCountdown = "Detonation countdown",
	nukeIncoming = "Tactical nuke",
	nukeLogEnabled = "[p] nuked [p]",
	
	-- Barrier
	barrierToggle = "Toggle Barrier",
	barrierInvincible = "Invincible",
	barrierKillPly = "Kill players",
	barrierKillNpc = "Kill NPCs",
	barrierRegenerateHealth = "Regenerate health",
	barrierRegenerateArmor = "Regenerate armor",
	barrierNoDamage = "Block all damage",
	barrierInverse = "Inverse barrier",
	barrierLogEnabled = "[p] activated barrier for [p]",
	barrierLogDisabled = "[p] disabled barrier for [p]",
	
	-- Weapon Mod
	weaponMod = "Mod Weapons",
	weaponModInfiniteClip = "Infinite clip ammo",
	weaponModInfiniteReserve = "Infinite reserve ammo",
	weaponModRapidFire = "Rapidfire",
	weaponModRapidFireToolgun = "Rapidfire toolgun",
	weaponModNoSpread = "No spread",
	weaponModNoRecoil = "No recoil",
	weaponModLogEnabled = "[p] modded weapons from [p]",
	weaponModLogDisabled = "[p] disabled weapon mod for [p]",
	
	-- Speed Hack
	speedHack = "Speed Hack",
	speedHackRun = "Fast run",
	speedHackWalk = "Fast walk",
	speedHackJumpHigh = "High jump",
	speedHackJumpInfinite = "Infinite jump",
	speedHackNoFallDMG = "No fall damage",
	speedHackTime = "Speedmo (x5)",
	speedHackLogEnabled = "[p] activated speed hack for [p]",
	speedHackLogDisabled = "[p] disabled speed hack for [p]",
	
	-- Morph
	morphPlayer = "Morph Player",
	morphPlayers = "Morph Players",
	morphMove = "Target can move",
	morphToilet = "Toilet morph",
	morphBoat = "Boat morph",
	morphCar = "Car morph",
	morphBin = "Trash bin morph",
	morphVendingMachine = "Vending machine morph",
	morphTurret = "Turret morph",
	morphGrave = "Grave morph",
	morphBust = "Bust morph",
	morphGhost = "Ghost morph",
	morphGordon = "Gordon morph",
	morphDoll = "Doll morph",
	morphModelInput = "custom/model.mdl",
	morphLogEnabled = "[p] morphed [p]",
	morphLogDisabled = "[p] demorphed [p]",
	
	-- Hacky Text
	hackyText = "Show Text",
	hackyTextInput = "This server has been hacked by Z",
	hackyTextLogEnabled = "[p] showed hacky text to [p]",
	
	-- Ammo Mod
	ammoMod = "Mod Ammo",
	ammoModLogEnabled = "[p] activated ammo mod for [p]",
	ammoModLogDisabled = "[p] disabled ammo mod for [p]",
	
	-- Void
	voidHide = "Void Hide",
	voidDrag = "Void Drag",
	voidHideOption = "Hide in the void",
	voidDragOption = "Drag into the void",
	voidPropCollide = "Collide with props",
	voidHideLogEnabled = "[p] void hid [p]",
	voidHideLogDisabled = "[p] void returned [p]",
	voidDragLogEnabled = "[p] void dragged [p]",
	
	-- Inverter
	invert = "Invert",
	invertMove = "Inverted moving",
	invertAim = "Inverted aim angles",
	invertJump = "Inverted jump",
	invertShoot = "Inverted shooting",
	invertScreen = "Inverted screen",
	inverterLogDisabled = "[p] restored controls for [p]",
	inverterLogEnabled = "[p] inverted controls for [p]",
	
	-- Lava Floor
	lavaFloorRise = "Erupt Lava",
	lavaFloorRecall = "Recall Lava",
	lavaFloorForceStop = "Force Reset",
	lavaFloorLevelInfo = "Lava Level",
	lavaFloorStartLevel = "Start at lowest player",
	lavaFloorSpeedUp = "Anti-wait player catch-up",
	lavaFloorSpectate = "Spectate on death",
	lavaFloorIgniteProps = "Ignite props",
	lavaFloorDoomsday = "Doomsday",
	lavaFloorEarthquake = "Earthquake",
	lavaFloorLogDisabled = "[p] recalled the lava back to the core",
	lavaFloorLogEnabled = "[p] erupted the volcano",
	
	-- Jumpscare
	jumpscare = "Jumpscare",
	jumpscareMode = "Mode",
	jumpscareInstantSound = "Sound",
	jumpscareLongSound = "Sound",
	jumpscareLongSoundExtra = "Visual Sound",
	jumpscareVisual = "Visual",
	jumpscareLogEnabled = "[p] jumpscared [p]",
	
}

en.nukeSound = en.launchSound
en.barrierSound = en.launchSound
en.voidSound = en.launchSound
en.lavaFloorSound = en.launchSound

return en