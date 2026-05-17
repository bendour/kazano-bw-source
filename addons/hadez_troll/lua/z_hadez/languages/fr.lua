-- [[ CREATED BY ZOMBIE EXTINGUISHER ]]

local fr = {
	search = "Rechercher",
	toggle = "Tout activer",
	selectPlayer = "Veuillez d'abord choisir un joueur!",
	themself = "Soi-même",
	everyone = "Tout le monde",
	targetAll = "Peut viser les autres",
	
	-- Mind control
	controlPlayer = "Contrôler Joueur",
	stopControl = "Arrêter de Contrôler",
	invisibleOnControl = "Invisible durant le contrôle",
	forcePhysgunOnControl = "Forcer le physgun",
	stealChatOnControl = "Voler le tchat",
	mindControlLogEnabled = "[p] a pris le contrôle de [p]",
	mindControlLogDisabled = "[p] a perdu le contrôle de [p]",
	
	-- Rocket launch
	launchPlayer = "Lancer Joueur",
	launchPlayers = "Lancer Joueurs",
	launchExplode = "La roquette fait BOOM!",
	launchSound = "Utiliser les sons",
	rocketLaunchLogEnabled = "[p] a envoyé dans l'espace [p]",
	
	-- Aimbot
	aimbotEnable = "Activer Aimbot",
	aimbotDisable = "Désactiver Aimbot",
	aimbotNeverMiss = "Les tirs ne ratent jamais",
	aimbotMagicBullets = "Les tirs passent à travers les murs",
	aimbotVisibleOnly = "Joueurs visibles seulement",
	aimbotCrosshairSort = "Joueurs près du réticule",
	aimbotPauseOnDeath = "Faire une pause lors de la mort d'une cible",
	aimbotAlwaysActive = "Toujours actif",
	aimbotLogEnabled = "[p] a activé aimbot",
	aimbotLogDisabled = "[p] a désactivé aimbot",
	
	-- Wallhack
	wallhackToggle = "Activer Wallhack",
	wallhackChams = "Chams",
	wallhackWireframe = "Wireframe",
	wallhackHitboxes = "Hitboxes",
	wallhackBones = "Os",
	wallhackAimlines = "Ligne de mire",
	wallhackWeapons = "Armes",
	wallhackName = "Nom",
	wallhackTeam = "Équipe",
	wallhackHealth = "Vie",
	wallhackDistance = "Distance",
	wallhackLine = "Aligner à",
	wallhackWeaponInfo = "Information sur l'arme",
	wallhackLogEnabled = "[p] a activé le wallhack pour [p]",
	wallhackLogDisabled = "[p] a désactivé le wallhack pour [p]",
	
	-- Chat steal
	stealChat = "Voler le Tchat",
	returnChat = "Rendre le Tchat",
	chatStealMute = "La cible peut utiliser le tchat",
	chatStealLogEnabled = "[p] a volé le tchat de [p]",
	chatStealLogDisabled = "[p] a rendu le tchat de [p]",
	
	-- Smite
	smitePlayer = "Foudroyer Joueur",
	smitePlayers = "Foudroyer Joueurs",
	smiteLogEnabled = "[p] a foudroyé [p]",
	
	-- Blackout
	blackoutPlayer = "Activer Évanouissement",
	blackoutLogEnabled = "[p] a fait s'évanouir [p]",
	blackoutLogDisabled = "[p] a réveillé [p]",
	
	-- Ravebreak 
	ravebreak = "Ravebreak",
	ravebreakDance = "Forcer les cibles à danser",
	ravebreakColorize = "Activer les effets de couleur",
	ravebreakLogEnabled = "[p] fait faire la fête à [p]",
	
	-- Weapon break
	weaponBreak = "Casser les armes",
	weaponBreakSuicide = "La cible se tire dessus",
	weaponBreakMiss = "Râter tous les tirs",
	weaponBreakLogEnabled = "[p] a cassé les armes de [p]", 
	weaponBreakLogDisabled = "[p] a réparé les armes de [p]", 
	
	-- Bullet time
	bulletTime = "Bullet Time",
	bulletInvincible = "Invincible",
	bulletTimeReturn = "Retourner tous les dommages",
	bulletTimeDodge = "Esquive des balles",
	bulletTimeSlowmo = "Ralenti",
	bulletTimeLogEnabled = "[p] a activé le bullet time pour [p]",
	bulletTimeLogDisabled = "[p] a désactivé le bullet time pour [p]",
	
	-- Nuke
	nukeLaunch = "Lancer une bombe nucléaire",
	nukeCountdown = "Temps avant détonation",
	nukeIncoming = "Bombe nucléaire",
	nukeLogEnabled = "[p] a atomisé [p]",
	
	-- Barrier
	barrierToggle = "Activer Barrière",
	barrierInvincible = "Invincible",
	barrierKillPly = "Tuer joueurs",
	barrierKillNpc = "Tuer PNJs",
	barrierRegenerateHealth = "Regénérer des PV",
	barrierRegenerateArmor = "Regénérer des PA",
	barrierNoDamage = "Bloquer tous les dommages",
	barrierLogEnabled = "[p] a activé la barrière pour [p]",
	barrierLogDisabled = "[p] a désactivé la barrière pour [p]",
	
	-- Weapon Mod
	weaponMod = "Modifications d'armes",
	weaponModInfiniteClip = "Balles dans le chargeur infinies",
	weaponModInfiniteReserve = "Balles en réserve infinies",
	weaponModRapidFire = "Tir rapide",
	weaponModRapidFireToolgun = "Tir rapide avec le Toolgun",
	weaponModNoSpread = "Pas de propagation des balles",
	weaponModNoRecoil = "Pas de recul",
	weaponModLogEnabled = "[p] a modifié les armes de [p]",
	weaponModLogDisabled = "[p] a rendu les armes de base de [p]",
	
	-- Speed Hack
	speedHack = "Speed Hack",
	speedHackRun = "Course rapide",
	speedHackWalk = "Marche rapide",
	speedHackJumpHigh = "Saut haut",
	speedHackJumpInfinite = "Saut infini",
    speedHackNoFallDMG = "Aucun dégâts de chute",
	speedHackTime = "Speedmo (x5)",
	speedHackLogEnabled = "[p] a activé le speedhack pour [p]",
	speedHackLogDisabled = "[p] a désactivé le speedhack de [p]",
	
	-- Morph
	morphPlayer = "Metamorphoser Joueur",
	morphPlayers = "Métamorphoser Joueurs",
	morphMove = "La cible peut bouger",
	morphToilet = "Métamorphose WC",
	morphBoat = "Métamorphose Bâteau",
	morphCar = "Métamorphose Voiture",
	morphBin = "Métamorphobe Poubelle",
	morphVendingMachine = "Métamorphose Machine à vendre",
	morphTurret = "Métamorphose Tourelle",
	morphGrave = "Métamorphose Tombe",
	morphBust = "Métamorphose Buste",
	morphGhost = "Métamorphose Fantôme",
	morphGordon = "Métamorphose Gordon",
	morphDoll = "Métamorphose Poupée",
	morphModelInput = "custom/model.mdl",
	morphLogEnabled = "[p] a métamorphosé [p]",
	morphLogDisabled = "[p] a rendu normale l'apparance de [p]",
	
	-- Hacky Text
	hackyText = "Montrer le texte",
	hackyTextInput = "Ce serveur a été hack par Z",
	hackyTextLogEnabled = "[p] a montré un texte de hack à [p]",
	
	-- Ammo Mod
	ammoMod = "Modifications de munitions",
	ammoModLogEnabled = "[p] a activé les modifications de balles pour [p]",
	ammoModLogDisabled = "[p] a désactivé les modifications de balles pour [p]",
	
	-- Void
	voidHide = "Cacher Néant",
	voidDrag = "Tirer Néant",
	voidHideOption = "Cacher dans le néant",
	voidDragOption = "Tirer dans le néant",
	voidPropCollide = "Collide with props",
	voidHideLogEnabled = "[p] a caché dans le néant [p]",
	voidHideLogDisabled = "[p] a ressorti du néant [p]",
	voidDragLogEnabled = "[p] a tiré dans le néant [p]",
	
	-- Inverter
	invert = "Inverser",
	invertMove = "Mouvements inversés",
	invertAim = "Angles de tir inversés",
	invertJump = "Saut inversé",
	invertShoot = "Inverser le tir",
	inverterLogDisabled = "[p] a remis les mouvements normaux de [p]",
	inverterLogEnabled = "[p] a inversé les mouvements de [p]",

	-- Lava Floor
	lavaFloorRise = "Erupter la lave",
	lavaFloorRecall = "Rappeler la lave",
	lavaFloorForceStop = "Remise à zéro forcée",
	lavaFloorLevelInfo = "Niveau de la lave",
	lavaFloorStartLevel = "Commencer au joueur le plus bas",
	lavaFloorSpectate = "Spectateur à la mort",
	lavaFloorIgniteProps = "Mettre en feu les Props",
	lavaFloorDoomsday = "Jour du Jugement dernier",
	lavaFloorEarthquake = "Tremblements de Terre",
	lavaFloorLogDisabled = "[p] a rappelé la lave!",
	lavaFloorLogEnabled = "[p] a fait sortir de la lave des tréfonds de la Terre!"
	
}

fr.nukeSound = fr.launchSound
fr.barrierSound = fr.launchSound
fr.voidSound = fr.launchSound
fr.lavaFloorSound = fr.launchSound

return fr