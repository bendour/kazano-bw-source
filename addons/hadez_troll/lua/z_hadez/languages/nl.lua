-- [[ CREATED BY ZOMBIE EXTINGUISHER ]]

local nl = {
	search = "Zoek",
	toggle = "Toggle alles",
	selectPlayer = "Selecteer eerst een speler!",
	themself = "Zichzelf",
	everyone = "Iedereen",
	targetAll = "Kan anderen targetten",
	
	-- Mind control
	controlPlayer = "Controleer Speler",
	stopControl = "Stop Controle",
	invisibleOnControl = "Onzichtbaar tijdens controle",
	forcePhysgunOnControl = "Forceer physgun",
	stealChatOnControl = "Steel chat",
	mindControlLogEnabled = "[p] nam controle over [p]",
	mindControlLogDisabled = "[p] verloor controle over [p]",
	
	-- Rocket launch
	launchPlayer = "Lanceer Speler",
	launchPlayers = "Lanceer Spelers",
	launchExplode = "Raket gaat boooom",
	launchSound = "Gebruik geluids effecten",
	rocketLaunchLogEnabled = "[p] lanceerde [p]",
	
	-- Aimbot
	aimbotEnable = "Activeer Aimbot",
	aimbotDisable = "Disactiveer Aimbot",
	aimbotNeverMiss = "Kogels missen nooit",
	aimbotMagicBullets = "Wallbanging",
	aimbotVisibleOnly = "Alleen zichtbare doelwitten",
	aimbotCrosshairSort = "Doelwit dichtste bij crosshairs",
	aimbotPauseOnDeath = "Pauzeer op dood doelwit",
	aimbotAlwaysActive = "Altijd actief",
	aimbotLogEnabled = "[p] activeerde aimbot",
	aimbotLogDisabled = "[p] deactiveerde aimbot",
	
	-- Wallhack
	wallhackToggle = "Toggle Wallhack",
	wallhackChams = "Chams",
	wallhackWireframe = "Wireframe",
	wallhackHitboxes = "Hitboxes",
	wallhackBones = "Beenderen",
	wallhackAimlines = "Kijklijn",
	wallhackWeapons = "Wapens",
	wallhackName = "Naam",
	wallhackTeam = "Team",
	wallhackHealth = "Leven",
	wallhackDistance = "Afstand",
	wallhackLine = "Lijn naar",
	wallhackWeaponInfo = "Wapen info",
	wallhackLogEnabled = "[p] activeerde wallhack voor [p]",
	wallhackLogDisabled = "[p] deactiveerde wallhack voor [p]",
	
	-- Chat steal
	stealChat = "Steel Chat",
	returnChat = "Geef Chat Terug",
	chatStealMute = "Doelwit kan chatten",
	chatStealLogEnabled = "[p] steelde chat van [p]",
	chatStealLogDisabled = "[p] gaf chat terug aan [p]",
	
	-- Smite
	smitePlayer = "Smite Speler",
	smitePlayers = "Smite Spelers",
	smiteLogEnabled = "[p] smited [p]",
	
	-- Blackout
	blackoutPlayer = "Toggle Blackout",
	blackoutLogEnabled = "[p] verduisterd [p]",
	blackoutLogDisabled = "[p] maakt wakker [p]",
	
	-- Ravebreak 
	ravebreak = "Ravebreak",
	ravebreakDance = "Forceer dans",
	ravebreakColorize = "Gebruik kleur effecten",
	ravebreakLogEnabled = "[p] ravebreaks [p]",
	
	-- Weapon break
	weaponBreak = "Breek Wapens",
	weaponBreakSuicide = "Targets shiet zichzelf",
	weaponBreakMiss = "Mis alle schoten",
	weaponBreakNoClipAmmo = "Geen clip ammo",
	weaponBreakNoReserveAmmo = "Geen reserve ammo",
	weaponBreakLogEnabled = "[p] brak wapens van [p]", 
	weaponBreakLogDisabled = "[p] restoreerde wapens van [p]",
	
	-- Bullet time
	bulletTime = "Bullet Time",
	bulletInvincible = "Onverslaanbaar",
	bulletTimeReturn = "Keer alle schade terug",
	bulletTimeDodge = "Kogels ontwijken",
	bulletTimeSlowmo = "Slow motion",
	bulletTimeLogEnabled = "[p] activeerde bullet time voor [p]",
	bulletTimeLogDisabled = "[p] deactiveerde bullet time voor [p]",
	
	-- Nuke
	nukeLaunch = "Lanceer Nuke",
	nukeCountdown = "Detonatie aftelling",
	nukeIncoming = "Nucleaire Bom",
	nukeLogEnabled = "[p] nuked [p]",
	
	-- Barrier
	barrierToggle = "Toggle Barrier",
	barrierInvincible = "Onverslaanbaar",
	barrierKillPly = "Kill spelers",
	barrierKillNpc = "Kill NPCs",
	barrierRegenerateHealth = "Herstel leven",
	barrierRegenerateArmor = "Herstel harnas",
	barrierNoDamage = "Blokkeer all schade",
	barrierInverse = "Keer barriere om",
	barrierLogEnabled = "[p] activeerde barrier voor [p]",
	barrierLogDisabled = "[p] deactiveerde barrier voor [p]",
	
	-- Weapon Mod
	weaponMod = "Mod Wapens",
	weaponModInfiniteClip = "Oneindig clip ammo",
	weaponModInfiniteReserve = "Oneindig reserve ammo",
	weaponModRapidFire = "Rapidfire",
	weaponModRapidFireToolgun = "Rapidfire toolgun",
	weaponModNoSpread = "Geen spread",
	weaponModNoRecoil = "Geen recoil",
	weaponModLogEnabled = "[p] modded wapens van [p]",
	weaponModLogDisabled = "[p] deactiveerde wapen mod voor [p]",
	
	-- Speed Hack
	speedHack = "Speed Hack",
	speedHackRun = "Snel lopen",
	speedHackWalk = "Snel wandelen",
	speedHackJumpHigh = "Hoog springen",
	speedHackJumpInfinite = "Oneindig springen",
	speedHackNoFallDMG = "Geen val schade",
	speedHackTime = "Speedmo (x5)",
	speedHackLogEnabled = "[p] activeerde speed hack voor [p]",
	speedHackLogDisabled = "[p] deactiveerde speed hack voor [p]",
	
	-- Morph
	morphPlayer = "Morph Speler",
	morphPlayers = "Morph Spelers",
	morphMove = "Target kag bewegen",
	morphToilet = "Toilet morph",
	morphBoat = "Boot morph",
	morphCar = "Auto morph",
	morphBin = "Vuilbak morph",
	morphVendingMachine = "Automaat morph",
	morphTurret = "Turret morph",
	morphGrave = "Graf morph",
	morphBust = "Borstbeeld morph",
	morphGhost = "Geest morph",
	morphGordon = "Gordon morph",
	morphDoll = "Pop morph",
	morphModelInput = "custom/model.mdl",
	morphLogEnabled = "[p] morphed [p]",
	morphLogDisabled = "[p] demorphed [p]",
	
	-- Hacky Text
	hackyText = "Toon Text",
	hackyTextInput = "This server has been hacked by Z",
	hackyTextLogEnabled = "[p] toonde hacky text aan [p]",
	
	-- Ammo Mod
	ammoMod = "Mod Ammo",
	ammoModLogEnabled = "[p] activeerde ammo mod voor [p]",
	ammoModLogDisabled = "[p] deactiveerde ammo mod voor [p]",
	
	-- Void
	voidHide = "Void Hide",
	voidDrag = "Void Drag",
	voidHideOption = "Verstop in de void",
	voidDragOption = "Sleep in de void",
	voidPropCollide = "Bots met objecten",
	voidHideLogEnabled = "[p] verstopte in de void [p]",
	voidHideLogDisabled = "[p] haalde uit de void [p]",
	voidDragLogEnabled = "[p] sleepte in de void [p]",
	
	-- Inverter
	invert = "Keer Om",
	invertWalk = "Beweging omkeren",
	invertAiming = "Rondkijken omkeren",
	invertJump = "Springen omkeren",
	invertShoot = "Schieten omkeren",
	invertScreen = "Scherm omkeren",
	inverterLogDisabled = "[p] herstelde toetsen voor [p]",
	inverterLogEnabled = "[p] draaide toetsen om voor [p]",
	
	-- Lava Floor
	lavaFloorRise = "Barst Vulkaan",
	lavaFloorRecall = "Lava Herroepen",
	lavaFloorForceStop = "Geforceerd Stopped",
	lavaFloorLevelInfo = "Lava Niveau",
	lavaFloorStartLevel = "Start bij de laagste speler",
	lavaFloorSpeedUp = "Anti-wacht spelers inhalen",
	lavaFloorSpectate = "Specteer wanneer dood",
	lavaFloorIgniteProps = "Ontvlam props",
	lavaFloorDoomsday = "Doomsday",
	lavaFloorEarthquake = "Aardbeving",
	lavaFloorLogDisabled = "[p] roepte de lava terug naar de core",
	lavaFloorLogEnabled = "[p] barste de vulkaan",
	
	-- Jumpscare
	jumpscare = "Jumpscare",
	jumpscareMode = "Modus",
	jumpscareInstantSound = "Geluid",
	jumpscareLongSound = "Geluid",
	jumpscareLongSoundExtra = "Afbeelding Geluid",
	jumpscareVisual = "Afbeelding",
	jumpscareLogEnabled = "[p] schrikte [p]",
	
}

nl.nukeSound = nl.launchSound
nl.barrierSound = nl.launchSound
nl.voidSound = nl.launchSound

return nl