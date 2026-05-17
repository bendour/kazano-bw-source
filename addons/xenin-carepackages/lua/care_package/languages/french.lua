local LANG = {
	["Tool.NotAdmin"] = "Vous devez être admin pour accéder à ceci !",
	["Tool.DeletedAll"] = "Vous avez supprimé :amount: points de spawn !",
	["Tool.TooClose"] = "Cet emplacement est trop proche de la skybox",
	["Tool.Blocked"] = "Cet emplacement ne peut pas être atteint directement par la skybox !",

	["Spawn.Commencing"] = "Largage aérien dans :time: secondes",
	["Spawn.Spawned"] = "L'avion est apparu, préparez-vous pour le colis entrant",

	["Drops.Money.Take"] = "Prendre les crédits",
	["Drops.Money.Loot"] = "Récupérer",
	["Drops.Weapons.Equipped"] = "Vous possédez déjà cette arme",
	["Drops.Weapons.DontOwnXeninInventory"] = "Vous ne possédez pas Xenin Inventory",
	["Drops.Weapons.InventoryFull"] = "Votre inventaire est plein",

	["ConCommand.PlanePos.First"] =  "Allez maintenant à l'autre coin de la map\n",
	["ConCommand.PlanePos.Second"] = "Vous avez maintenant enregistré les limites de l'avion ! Vous pourrez voir la zone de l'avion dans le ciel jusqu'à ce que vous vous reconnectiez\n",

	["Loot.Error.Dead"] = "Vous êtes mort",
	["Loot.Error.InventoryNotThere"] = "Vous avez essayé d'utiliser une commande d'inventaire, mais Xenin Inventory n'est pas installé",
	["Loot.Error.Invalid"] = "Le colis est invalide !",
	["Loot.Error.NotReady"] = "La caisse n'est pas prête",
	["Loot.Error.TooFarAway"] = "Vous êtes trop loin de la caisse",
	["Loot.Error.DoesntContainAnything"] = "La caisse ne contient rien",
	["Loot.Error.ItemLooted"] = "L'objet a déjà été récupéré",
	["Loot.Error.DoesntExistInConfig"] = "L'objet n'existe pas dans la configuration",

	["Crate.Unopened"] = "NON OUVERT",
	["Crate.OpeningIn"] = "OUVERTURE DANS :time: SECONDES",
	["Crate.Opened"] = "OUVERT",
	["Crate.Name"] = "Colis",

	["Flare.Invalid"] = "Votre fusée éclairante est trop proche de quelque chose/pas à découvert. Veuillez réessayer",
	["Flare.Valid"] = "Votre fusée éclairante est placée à découvert ! Colis en approche",
	["Flare.Plane"] = "Quelqu'un a appelé un colis ! Avion en approche",
}

CarePackage:CreateLanguage("French", LANG)
