zmlab = zmlab || {}
zmlab.config = zmlab.config || {}

/////////////////////////////////////////////////////////////////////////////

// Version 1.6.4

///////////////////////////// Zeros MethLab ////////////////////////////////////

// Developed by ZeroChain:
// http://steamcommunity.com/id/zerochain/
// https://www.gmodstore.com/users/view/00000000000000000
// https://www.artstation.com/zerochain

////////////////////////////////////////////////////////////////////////////////
//////////////BEFORE YOU START BE SURE TO READ THE README.TXT///////////////////
////////////////////////////////////////////////////////////////////////////////






// Misc
///////////////////////
// This enables fast download
zmlab.config.EnableResourceAddfile = false

// Some debug information
zmlab.config.Debug = false


// This lets you set what Language we want do use
// en,de,dk,es,fr,pl,ru,tr, cn , pt
zmlab.config.SelectedLanguage = "en"

// These Ranks are allowed do use the Chat Command  !savezmlab  which saves all the NPCs and DropOff Points
zmlab.config.AdminRanks = {
	["superadmin"] = true,
}

// Here you can add all the Jobs that can sell Meth, Leave empty the table to allow everyone to sell meth
-- zmlab.config.Jobs = {
-- 	[TEAM_ZMLAB_COOK] = true,
-- }

// Currency
zmlab.config.Currency = "$"

// Unit of weight
zmlab.config.UoW = "g"

// The Damage the entitys have do take before they get destroyed.
// Setting it to -1 disables it
zmlab.config.Damageable = {
	["zmlab_combiner"] = 3000,
	["zmlab_frezzer"] = 2500,
	["zmlab_methylamin"] = 200,
	["zmlab_aluminium"] = 200,
	["zmlab_filter"] = 500,
	["zmlab_collectcrate"] = 300,
	["zmlab_meth_baggy"] = 1,
	["zmlab_meth"] = 1,
	["zmlab_palette"] = 150,
}

// Disables the Owner Checks so everyone can use everyones methlab entitys
zmlab.config.SharedOwnership = false

// Do we have VrondakisLevelSystem installed?
zmlab.config.Vrondakis = {
	Enabled = false,

	Data = {
		["Selling"] = {XP = 1},
		["BreakingIce"] = {XP = 1},
	}
}



zmlab.config.Combiner = {

	// This Values Defines the Meth Sludge the combiner can produce per Cook
	MethperBatch = 1200,

	// This Values Defines the Producing Time in seconds
	MixProcessingTime = 25, // seconds

	// This Values Defines the Filtering Time in seconds.
	FilterProcessingTime = 50, // seconds

	// This Values Defines the Finishing MethSludge Time in seconds
	FinishProcessingTime = 100, // seconds

	// The length in seconds it takes to pump
	Pump_Interval = 0.3, // seconds

	// This Values Defines how fast the Meth Sludge gets Pumped out of the Combiner
	Pump_Amount = 10,

	// How much dirty gets the combiner per Batch (Setting it to 0 means it never gets dirty)
	DirtAmount = 200,

	// How much dirt can the player clean per Use/Click
	CleanAmount = 10
}

zmlab.config.Filter = {

	// The Health of the Filter (Setting it to 0 disables the Filter losing Health)
	Health = 250,
	// *Note* When the Combiner is in the Filtering Process then the Filter is gonna lose Health every Second if he is installed.

	// How much MethSludge do we get if we dont use a filter 1 = 100%, 0.5 = 50%, 0.25 = 25%
	NoFilterPenalty = 0.25,

	// The damage a player in distance gets per Second if there is no filter installed (Setting it to 0 disables the Damage)
	PoisenDamage = 15,
}

zmlab.config.Freezer = {
	// If the Frezzer has Trays with Methsludge then its going to frezze them in this Interval
	Freeze_Inerval = 1, // seconds

	// How much Meth does remain after its frozen/dry (0.05 = 5%)
	MethFreezeLoss = 0.1,

	// The Time in seconds it takes for the Meth do frezze
	Freeze_Time = 25,
}

zmlab.config.FreezingTray = {

	// The amount a frezzing Tray can hold
	Capacity = 250,

	// How much Meth do we lose when breaking it (0.05 = 5%)
	MethBreakLoss = 0.05,
}

zmlab.config.TransportCrate = {
	// The amount a Transport crate can hold
	Capacity = 1000,

	// This will let you collect the TransportCrate no matter if its complete full or not (Only works on zmlab.config.MethBuyer.SellMode 1 and 3)
	NoWait = true,

	// Should the TransportCrate collide with everything?
	FullCollide = false
}

zmlab.config.Palette = {
	// How many meth crates can fit on the palette
	Limit = 24
}

zmlab.config.MethExtractorSWEP = {

	// How much Meth do we extract per click
	// *Note This extracts a small bag of meth from a transport crate or Big Bag
	Amount = 25,
}




zmlab.config.Police = {

	// Should the player get wanted once he sells meth?
	WantedOnMethSell = true,

	// These jobs can get extra money if they destroy TransportCrates filled with meth and also get a Wanted notification once a player sells meth
	Jobs = {
		["Civil Protection"] = true,
		["SWAT"] = true,
	},

	// The money the police player receives (for destroying the TransportCrate) is the same amount the meth producer receives times this value
	// 1 = 100% , 0.5 = 50%
	PoliceCut = 1,

	// This chat command can be used by the police to strip all the meth from the player they are looking at
	cmd_strip = "!stripmeth"
}

zmlab.config.Meth = {
	// Should the player drop all of his meth on Death?
	DropMeth_OnDeath = false,

	// Should the meth be consumable?
	Consumable = false,

	// The Damage a player gets when consuming meth
	Damage = 10,

	// The duration a bag of meth can get you high
	EffectDuration = 20,

	// How much faster should the player get when on meth?
	SpeedMul = 2, // 2 = Double  // 0.5 = Half

	// This enables the music that plays while the player is high
	//*Note The music can only be heard from the player that uses the drug
	EffectMusic = true
}


zmlab.config.Methylamin = {
	// This Values Defines needed Methylamin amount
	Max = 5,

	// Do we want do randomize the needed Methylamin amount for each Cook? (If yes then it will use zmlab.config.Meth.Max as max value)
	Random = true,
}

zmlab.config.Aluminium = {
	// This Values Defines needed Aluminium amount
	Max = 5,

	// Do we want do randomize the needed Aluminium amount for each Cook? (If yes then it will use zmlab.config.Aluminium.Max as max value)
	Random = true,
}

zmlab.config.MethBuyer = {
	// The Model of the Meth Buyer
	Model = "models/Humans/Group03/male_07.mdl",

	// Do we want do Show a Sell/Cash Effect if the user sells something?
	ShowEffect = true,

	// What Sell mode do we want?
	SellMode = 3,
	// 1 = Methcrates can be absorbed by Players and sold by the MethBuyer on use
	// 2 = Methcrates cant be absorbed and the MethBuyer tells you a dropoff point instead (Palette Entity gets used here for easier transport)
	// 3 = Methcrates can be absorbed and the MethBuyer tells you a dropoff point
	// 4 = Methcrates need to be moved to the MethBuyer and sold directly by him

	// Sell Price per unit
	// Examble: 1kg Meth = 7$ for a user Rank
	SellRanks = {
		["default"] = 1, // This value gets used if the players rank is not definied in the table
		["user"] = 200e9,
		["VIP"] = 230e9,
		["Premium"] = 230e9,
		["TrialModerator"] = 230e9,
		["Moderator"] = 230e9,
		["SuperModerator"] = 230e9,
		["Administrator"] = 230e9,
		["superadmin"] = 230e9,
	},
}

zmlab.config.DropOffPoint = {

	// The Time in seconds before Dropoff Point closes.
	DeliverTime = 60,

	// The Time in seconds till you can request another dropoff point.
	DeliverRequest_CoolDown = 60,

	// Do we want the DropOff Point do close as soon as it gets a Meth Drop
	OnTimeUse = true,
}
