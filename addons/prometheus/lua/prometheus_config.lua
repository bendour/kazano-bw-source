--[[ Config ]]--

	Prometheus.WebsiteEnabled = true -- If true, the chat command will be enabled (Opens menu)

	Prometheus.WebsiteCmd = "!donate" -- Command they need to type in chat to open your website

	Prometheus.CanCheckRankCmd = true -- Can people re-check their ranks?
		Prometheus.CheckRankCmd = "!checkrank" -- Command they can type in chat to force a re-check on their rank which will assign them the latest rank that they have bought(Can happen in all kinds of cases, admin mod messes up, rank files are lost etc)

	Prometheus.SeperateForSite = true -- Set to true if you want to use seperate chat commands for opening donation page and opening menu
		Prometheus.OpenDonationCmd = "!donatesite" -- Used only if Prometheus.SeperateForSite is set to true, keep in mind to not have both be same command

	Prometheus.DropPermaWeaponOnDeath = false -- Should a permanent weapon given by Prometheus drop when a person dies
	Prometheus.CanDropPermaWeapon = false -- Can a perma weapon be dropped? If set to false weapon will be destroyed when dropped(Except on DarkRP where it simply cannot be dropped).

	Prometheus.Access.AdminMenu = {"superadmin"} -- Groups that can access the admin menu. Examples: {"admin"}  {"admin", "superadmin", "owner"}     For AssMod use the number of the rank like: {1, 2}

	Prometheus.NotifyEveryone = true -- If true, it will send a notification to everyone that a person on server has gotten a package

	Prometheus.RefreshTime = 40 -- How often should it check for new actions (In seconds)

	Prometheus.PlayerPackageCooldown = 10 -- How many seconds a person needs to wait before they can refresh their active packages(In menu)

	Prometheus.ServerID = 1 -- ID of this server, will be given to you when you create it on your web side of prometheus

	Prometheus.DebugInfo = false -- If enabled, will show debug info of actions, actions and other things in server console

	Prometheus.LoadSettingsFromDB = false -- If false, will always use the FallBackSettings, useful if you want different servers to have different text in the notifications(Different language servers)

	Prometheus.Mysql.Host = "158.178.207.122"
	Prometheus.Mysql.Port = 3306
	Prometheus.Mysql.Username = "prometheusipn_user"
	Prometheus.Mysql.Password = "Arlo62880$"
	Prometheus.Mysql.DBName = "prometheusipn_db"

--[[ End of Config ]]--


--




--[[ Fallback Config ]]-- No need to edit! In here are settings that are set up using the web interface, but in case of a failed connection, these will be used.

	Prometheus.FallbackSettings.message_receiverPerma = "Vous avez reçu un pack donateur. {package}. Ce pack est permanent et n'expire pas." -- Message that will show up to the package reciever. {name} gets replaced by persons name, {package} gets replaced by packages name.
	Prometheus.FallbackSettings.message_receiverNonPerma = "Vous avez reçu un pack donateur. {package}. Ce pack n'est pas permanent et expire le {expire}." -- Message that will show up to everyone else(If enabled). {name} gets replaced by persons name, {package} gets replaced by packages name, {expire} gets replaced by date on which package expires (YYYY-MM-DD).
	Prometheus.FallbackSettings.message_receiverRevoke = "Votre pack {package} a été révoqué. Si vous pensez que c'est injustifié, veuillez contacter un administrateur." -- Message that will show up to the package reciever if their package gets revoked. {name} gets replaced by persons name, {package} gets replaced by packages name.
	Prometheus.FallbackSettings.message_receiverExpire = "Votre pack {package} a expiré." -- Message that will show up to the package reciever when their package expires. {name} gets replaced by persons name, {package} gets replaced by packages name.
	Prometheus.FallbackSettings.message_othersCredits = "{name} a fait un don et a reçu {amount} crédit(s)" -- Message that will show up to everyone when someone buys a credit package. {name} gets replaced by persons name, {amount} gets replaced by the amount of credits they receive.
	Prometheus.FallbackSettings.message_receiverCredits = "Vous avez reçu {amount} crédit(s)" -- Message that will show up to the person when they buy a credit package. {amount} gets replaced by the amount of credits they receive.
	Prometheus.FallbackSettings.message_others = "Grâce à son don, {name} a reçu son pack {package} !" -- Message that will show up to everyone else when receiver gets their package. Works if Prometheus.NotifyEveryone is true. {name} gets replaced by persons name, {package} gets replaced by packages name, {expire} gets replaced by date on which package expires (YYYY-MM-DD).

--[[ End of Fallback Config ]]--