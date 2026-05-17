-- [[ CREATED BY ZOMBIE EXTINGUISHER ]]

local es = {
	search = "Buscar",
	toggle = "Alternar todos",
	selectPlayer = "¡Selecciona a un jugador primero!",
	themself = "él mismo",
	everyone = "Todos",
 
	-- Mind control
	controlPlayer = "Controlar Jugador",
	stopControl = "Parar de controlar",
	invisibleOnControl = "Volverse invisible durante el control",
	forcePhysgunOnControl = "Forzar phsygun",
	stealChatOnControl = "Robar chat",
	mindControlLogEnabled = "[p] tomó el control sobre [p]",
	mindControlLogDisabled = "[p] perdió el control sobre [p]",
 
	-- Rocket launch
	launchPlayer = "Lanzar Jugador",
	launchPlayers = "Lanzar Jugadores",
	launchExplode = "Los cohetes hacen boooom",
	launchSound = "Usar efectos de sonido",
	rocketLaunchLogEnabled = "[p] lanzó a [p]",
 
	-- Aimbot
	aimbotEnable = "Activar Aimbot",
	aimbotDisable = "Desactivar Aimbot",
	aimbotNeverMiss = "Las Balas nunca fallan",
	aimbotMagicBullets = "Disparos a través de la pared",
	aimbotVisibleOnly = "Sólo objetivos visibles",
	aimbotCrosshairSort = "Objetivos cercanos a la mira",
	aimbotPauseOnDeath = "Pausar cuando el objetivo muera",
	aimbotAlwaysActive = "Siempre activo",
	aimbotLogEnabled = "[p] activó el aimbot",
	aimbotLogDisabled = "[p] desactivó el aimbot",
 
	-- Wallhack
	wallhackToggle = "Activar Wallhack",
	wallhackChams = "Camaleón",
	wallhackWireframe = "Bordes",
	wallhackHitboxes = "Hitboxes",
	wallhackBones = "Huesos",
	wallhackAimlines = "Línea de apuntado",
	wallhackWeapons = "Armas",
	wallhackName = "Nombre",
	wallhackTeam = "Equipo",
	wallhackHealth = "Vida",
	wallhackDistance = "Distancia",
	wallhackLine = "Alineado a",
	wallhackWeaponInfo = "Información del arma",
	wallhackLogEnabled = "[p] activó el wallhack para [p]",
	wallhackLogDisabled = "[p] desactivó el wallhack para [p]",
 
	-- Chat steal
	stealChat = "Robar Chat",
	returnChat = "Devolver Chat",
	chatStealMute = "El objetivo puede chatear",
	chatStealLogEnabled = "[p] le robó el chat a [p]",
	chatStealLogDisabled = "[p] le devolvió el chat a [p]",
 
	-- Smite
	smitePlayer = "Castigar Jugador",
	smitePlayers = "Castigar Jugadores",
	smiteLogEnabled = "[p] castigó a [p]",
 
	-- Blackout
	blackoutPlayer = "Alternar Blackout",
	blackoutLogEnabled = "[p] activó el Blackout sobre [p]",
	blackoutLogDisabled = "[p] despertó a [p]",
 
	-- Ravebreak 
	ravebreak = "Ravebreak",
	ravebreakDance = "Obliga a los objetivos a bailar",
	ravebreakColorize = "Activar efectos de colores",
	ravebreakLogEnabled = "[p] ravebrakeó a [p]",
 
	-- Weapon break
	weaponBreak = "Romper Armas",
	weaponBreakSuicide = "El objetivo se dispara a si mismo",
	weaponBreakMiss = "Errar todos los disparos",
	weaponBreakLogEnabled = "[p] rompió las armas de [p]", 
	weaponBreakLogDisabled = "[p] restauró las armas de [p]", 
 
	-- Bullet time
	bulletTime = "Tiempo de la Bala",
	bulletInvincible = "Invencible",
	bulletTimeReturn = "Devolver todo el daño",
	bulletTimeDodge = "Esquivar balas",
	bulletTimeSlowmo = "Cámara lenta",
	bulletTimeLogEnabled = "[p] le activó el tiempo de bala a [p]",
	bulletTimeLogDisabled = "[p] le desactivó el tiempo de bala a [p]",
 
	-- Nuke
	nukeLaunch = "Lanzar Nuclear",
	nukeCountdown = "Cuenta regresiva para detonar",
	nukeIncoming = "Nuclear Táctica",
	nukeLogEnabled = "[p] nukeó a [p]",
 
	-- Barrier
	barrierToggle = "Alternar Barrera",
	barrierInvincible = "Invencible",
	barrierKillPly = "Matar Jugadores",
	barrierKillNpc = "Matar NPCs",
	barrierRegenerateHealth = "Regenerar vida",
	barrierRegenerateArmor = "Regenerar armadura",
	barrierNoDamage = "Bloquear todo el daño",
	barrierLogEnabled = "[p] le activó la barrera a [p]",
	barrierLogDisabled = "[p] le desactivó la barrera a [p]",
 
	-- Weapon Mod
	weaponMod = "Modificaciones de Armas",
	weaponModInfiniteClip = "Cargador Infinito",
	weaponModInfiniteReserve = "Reserva Infinita",
	weaponModRapidFire = "Fuego Rápido",
	weaponModRapidFireToolgun = "Herramienta de Fuego Rápido",
	weaponModNoSpread = "Sin spread",
	weaponModNoRecoil = "Sin recoil",
	weaponModLogEnabled = "[p] modificó las armas de [p]",
	weaponModLogDisabled = "[p] desactivó las modificaciones de armas de [p]",
 
	-- Speed Hack
	speedHack = "Hack de Velocidad",
	speedHackRun = "Correr Rápido",
	speedHackWalk = "Caminar Rápido",
	speedHackJumpHigh = "Salto Alto",
	speedHackJumpInfinite = "Salto Infinito",
	speedHackTime = "Multiplicador (x5)",
	speedHackLogEnabled = "[p] le activó el hack de velocidad a [p]",
	speedHackLogDisabled = "[p] le desactivó el hack de velocidad a [p]",
 
	-- Morph
	morphPlayer = "Transformar Jugador",
	morphPlayers = "Transformar Jugadores",
	morphMove = "El objetivo se puede mover",
	morphToilet = "Transformar en inodoro",
	morphBoat = "Transformar en murciélago",
	morphCar = "Transformar en auto",
	morphBin = "Transformar en tacho de basura",
	morphVendingMachine = "Transformar en máquina expendedora",
	morphTurret = "Transformar en torreta",
	morphGrave = "Transformar en lápida",
	morphBust = "Transformar en busto",
	morphGhost = "Transformar en fantasma",
	morphGordon = "Transformar en Gordon",
	morphDoll = "Transformar en muñeca",
	morphModelInput = "modelo/personalizado.mdl",
	morphLogEnabled = "[p] transformó a [p]",
	morphLogDisabled = "[p] destransformó a [p]",
 
	-- Hacky Text
	hackyText = "Mostrar Texto",
	hackyTextInput = "Este servidor fue hackeado por Z",
	hackyTextLogEnabled = "[p] le mostró un texto sospechoso a [p]",
 
	-- Ammo Mod
	ammoMod = "Modificación de munición",
	ammoModLogEnabled = "[p] le activó la modificación de munición a [p]",
	ammoModLogDisabled = "[p] le desactivó la modificación de munición a [p]",
 
	-- Void
	voidHide = "Ocultar vacío",
	voidDrag = "Arrastrar vacío",
	voidHideOption = "Ocultar en el vacío",
	voidDragOption = "Arrastras al vacío",
	voidPropCollide = "Colisionar con props",
	voidHideLogEnabled = "[p] ocultó en el vacío a [p]",
	voidHideLogDisabled = "[p] devolvió del vacío a [p]",
	voidDragLogEnabled = "[p] arrastró al vacío a [p]",
 
}
 
es.nukeSound = es.launchSound
es.barrierSound = es.launchSound
es.voidSound = es.launchSound
 
return es