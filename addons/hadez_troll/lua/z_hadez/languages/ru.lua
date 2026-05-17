-- [[ CREATED BY ZOMBIE EXTINGUISHER ]]
 
local ru = {
    search = "Поиск",
    toggle = "Вкл/Выкл все",
    selectPlayer = "Сначала выберите игрока!",
    themself = "Себя",
    everyone = "Всех",
    targetAll = "Может целиться в других",
    
    -- Mind control
    controlPlayer = "Управлять игроком",
    stopControl = "Остановить управление",
    invisibleOnControl = "Вкл. невидимость во время контроля",
    forcePhysgunOnControl = "Отнять физган",
    stealChatOnControl = "Украсть чат",
    mindControlLogEnabled = "[p] взял под управление [p]",
    mindControlLogDisabled = "[p] потерял управление над [p]",
    
    -- Rocket launch
    launchPlayer = "Запустить игрока",
    launchPlayers = "Запустить игроков",
    launchExplode = "Ракета делает бум",
    launchSound = "Исп. звуковые эффекты",
    rocketLaunchLogEnabled = "[p] запустил в космос [p]",
    
    -- Aimbot
    aimbotEnable = "Включить Aimbot",
    aimbotDisable = "Выключить Aimbot",
    aimbotNeverMiss = "Пули никогда не промахиваются",
    aimbotMagicBullets = "Пули прошивают стены",
    aimbotVisibleOnly = "Только видимые цели",
    aimbotCrosshairSort = "Нацеливаться на ближ. к прицелу",
    aimbotPauseOnDeath = "Останавливать при смерти цели",
    aimbotAlwaysActive = "Всегда активен",
    aimbotLogEnabled = "[p] включил aimbot",
    aimbotLogDisabled = "[p] выключил aimbot",
    
    -- Wallhack
    wallhackToggle = "Вкл/Выкл Wallhack",
    wallhackChams = "Подсветка",
    wallhackWireframe = "Обводка",
    wallhackHitboxes = "Хитбоксы",
    wallhackBones = "Кости",
    wallhackAimlines = "Линия прицеливания",
    wallhackWeapons = "Оружия",
    wallhackName = "Имя",
    wallhackTeam = "Команда",
    wallhackHealth = "Здоровье",
    wallhackDistance = "Дистанция",
    wallhackLine = "Выровнять по",
    wallhackWeaponInfo = "Инфо об оружии",
    wallhackLogEnabled = "[p] включил wallhack для [p]",
    wallhackLogDisabled = "[p] выключил wallhack для [p]",
    
    -- Chat steal
    stealChat = "Украсть чат",
    returnChat = "Вернуть чат",
    chatStealMute = "Цель может писать в чат",
    chatStealLogEnabled = "[p] украл чат у [p]",
    chatStealLogDisabled = "[p] вернул чат [p]",
    
    -- Smite
    smitePlayer = "Уничтожить игрока",
    smitePlayers = "Уничтожить игроков",
    smiteLogEnabled = "[p] уничтожил [p]",
    
    -- Blackout
    blackoutPlayer = "Вкл/Выкл отключку",
    blackoutLogEnabled = "[p] отрубил [p]",
    blackoutLogDisabled = "[p] пробудил [p]",
    
    -- Ravebreak 
    ravebreak = "Рейв-брейк",
    ravebreakDance = "Заставить цель танцевать",
    ravebreakColorize = "Вкл. цветные эффекты",
    ravebreakLogEnabled = "[p] заставил танцевать [p]",
    
    -- Weapon break
    weaponBreak = "Сломать оружие",
    weaponBreakSuicide = "Цели стреляют по себе",
    weaponBreakMiss = "Все пули промахиваются",
    weaponBreakLogEnabled = "[p] сломал оружие у [p]", 
    weaponBreakLogDisabled = "[p] восстановил оружие для [p]", 
    
    -- Bullet time
    bulletTime = "Время пуль",
    bulletInvincible = "Невидимость",
    bulletTimeReturn = "Возвращать весь урон",
    bulletTimeDodge = "Уворачиваться от пуль",
    bulletTimeSlowmo = "Замедленное движение",
    bulletTimeLogEnabled = "[p] включил время пуль для [p]",
    bulletTimeLogDisabled = "[p] выключил время пуль для [p]",
    
    -- Nuke
    nukeLaunch = "Запуск ядерной бомбы",
    nukeCountdown = "Обратный отсчёт детонации",
    nukeIncoming = "Тактическая ядерная бомба",
    nukeLogEnabled = "[p] запустил ядерную бомбу в [p]",
    
    -- Barrier
    barrierToggle = "Вкл/Выкл барьер",
    barrierInvincible = "Невидимость",
    barrierKillPly = "Убивать игроков",
    barrierKillNpc = "Убивать NPC",
    barrierRegenerateHealth = "Восстанавливать здоровье",
    barrierRegenerateArmor = "Восстанавливать броню",
    barrierNoDamage = "Блокировать весь урон",
    barrierLogEnabled = "[p] включил барьер для [p]",
    barrierLogDisabled = "[p] выключил барьер [p]",
    
    -- Weapon Mod
    weaponMod = "Модификация оружия",
    weaponModInfiniteClip = "Бесконечные патроны в обойме",
    weaponModInfiniteReserve = "Бесконечные патроны в запасе",
    weaponModRapidFire = "Быстрая стрельба",
    weaponModRapidFireToolgun = "Быстрая стрельба из тулгана",
    weaponModNoSpread = "Без разброса",
    weaponModNoRecoil = "Без отдачи",
    weaponModLogEnabled = "[p] модифицировал оружие для [p]",
    weaponModLogDisabled = "[p] демодифицировал оружие для [p]",
    
    -- Speed Hack
    speedHack = "SpeedHack",
    speedHackRun = "Быстрый бег",
    speedHackWalk = "Быстрое хождение",
    speedHackJumpHigh = "Высокий прыжок",
    speedHackJumpInfinite = "Бесконечный прыжок",
    speedHackNoFallDMG = "Без урона от падения",
    speedHackTime = "Speedmo (x5)",
    speedHackLogEnabled = "[p] включил speedhack для [p]",
    speedHackLogDisabled = "[p] выключил speedhack для [p]",
    
    -- Morph
    morphPlayer = "Превратить игрока",
    morphPlayers = "Превратить игроков",
    morphMove = "Цели могут двигаться",
    morphToilet = "Превратить в унитаз",
    morphBoat = "Превратить в лодку",
    morphCar = "Превратить в машину",
    morphBin = "Превратить в урну",
    morphVendingMachine = "Превратить в торговый автомат",
    morphTurret = "Превратить в турель",
    morphGrave = "Превратить в могилу",
    morphBust = "Превратить в бюст",
    morphGhost = "Превратить в призрака",
    morphGordon = "Превратить в Гордона",
    morphDoll = "Превратить в куклу",
    morphModelInput = "custom/model.mdl",
    morphLogEnabled = "[p] изменил форму [p]",
    morphLogDisabled = "[p] вернул форму [p]",
    
    -- Hacky Text
    hackyText = "Показать текст",
    hackyTextInput = "Этот сервер был взломан Z",
    hackyTextLogEnabled = "[p] показах хакерский текст для [p]",
    
    -- Ammo Mod
    ammoMod = "Модификация боеприпасов",
    ammoModLogEnabled = "[p] модифицировал боеприпасы для [p]",
    ammoModLogDisabled = "[p] демодифицировал боеприпасы для [p]",
    
    -- Void
    voidHide = "Пустотные прятки",
    voidDrag = "Пустотные перемещения",
    voidHideOption = "Спрятаться в пустоте",
    voidDragOption = "Перетащить пустоту",
    voidPropCollide = "Столкновение с пропами",
    voidHideLogEnabled = "[p] спрятал в пустоту [p]",
    voidHideLogDisabled = "[p] вернул из пустоты [p]",
    voidDragLogEnabled = "[p] переместил в пустоту [p]",
    
    -- Inverter
    invert = "Инвертировать",
    invertMove = "Инвертировать передвижение",
    invertAim = "Инвертировать углы прицеливания",
    invertJump = "Инвертировать прыжок",
    invertShoot = "Инвертировать стрельбу",
    inverterLogDisabled = "[p] восстановил управление для [p]",
    inverterLogEnabled = "[p] инвертировал управление для [p]",
    
    -- Lava Floor
    lavaFloorRise = "Извержение лавы",
    lavaFloorRecall = "Вернуть лаву",
    lavaFloorForceStop = "Быстрый сброс",
    lavaFloorLevelInfo = "Уровень лавы",
    lavaFloorStartLevel = "Начать с самого низкого игрока",
    lavaFloorSpectate = "Наблюдать за смертью",
    lavaFloorIgniteProps = "Поджигать пропы",
    lavaFloorDoomsday = "Конец света",
    lavaFloorEarthquake = "Землетрясение",
    lavaFloorLogDisabled = "[p] вернул лаву обратно в ядро",
    lavaFloorLogEnabled = "[p] запустил извержение вулкана"
    
}
 
ru.nukeSound = ru.launchSound
ru.barrierSound = ru.launchSound
ru.voidSound = ru.launchSound
ru.lavaFloorSound = ru.launchSound
 
return ru