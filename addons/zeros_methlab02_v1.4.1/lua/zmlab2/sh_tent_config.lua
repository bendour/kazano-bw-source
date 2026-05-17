/*
    Addon id: a36a6eee-6041-4541-9849-360baff995a2
    Version: v1.4.1 (stable)
*/

zmlab2 = zmlab2 or {}
zmlab2.config = zmlab2.config or {}
                                                                                                                                                                                                                                                                                                                                                                                                                                                       -- 071bfceb8fb4fbc39d3b52c5c3fe7b52159006ab4669d1b75f42deff9fdb1cb2
                                                                                                                                                                                                                                                                                                                                                                                                                                                       -- 00000000000000000
                                                                                                                                                                                                                                                                                                                                                                                                                                                       -- 00000000000000000
                                                                                                                                                                                                                                                                                                                                                                                                                                                       -- 20505de7028925e794a03b5d1a113ab09db033ae5f8a5a69bfd7d0ab6982aaae

zmlab2.config.Tent = {
	[1] = {
		name = zmlab2.language["tent01_title"],
		desc = zmlab2.language["tent01_desc"],
		price = 125e13,
		model = "models/zerochain/props_methlab/zmlab2_tent02.mdl",
		tex_diff = "zerochain/props_methlab/tent02/tent02_diff",
		tex_nrm = "zerochain/props_methlab/tent02/tent02_nrm",
		tex_em = "zerochain/props_methlab/tent02/tent02_em",
		mat_id = 5,
		min = Vector(-90,-80,0),
		max = Vector(90,80,95),
		construction_time = 4,
		light = {
			pos = Vector(0, 0, 100),
			size = 256,
			brightness = 4,
		},
		color = Color(255,191,0)

                                                                                                                                                                                                                                                                                                                                                                                                                                                       -- 071bfceb8fb4fbc39d3b52c5c3fe7b52159006ab4669d1b75f42deff9fdb1cb2

		/*
		// Can be used to restrict a tent to a certain rank,job,level etc
		customcheck = function(ply)
			return ply:IsSuperAdmin()
		end,
		*/
	},
	[2] = {
		name = zmlab2.language["tent02_title"],
		desc = zmlab2.language["tent02_desc"],
		price = 125e13,
		model = "models/zerochain/props_methlab/zmlab2_tent01.mdl",
		tex_diff = "zerochain/props_methlab/tent01/tent01_diff",
		tex_nrm = "zerochain/props_methlab/tent01/tent01_nrm",
		tex_em = "zerochain/props_methlab/tent01/tent01_em",
		mat_id = 5,
		min = Vector(-90,-147,0),
		max = Vector(90,147,95),
		construction_time = 4,
		light = {
			pos = Vector(0, 0, 100),
			size = 256,
			brightness = 4,
		},
		color = Color(255,191,0)
	},
	[3] = {
		name = zmlab2.language["tent03_title"],
		desc = zmlab2.language["tent03_desc"],
		price = 125e13,
		model = "models/zerochain/props_methlab/zmlab2_tent04.mdl",
		tex_diff = "zerochain/props_methlab/tent04/tent04_diff",
		tex_nrm = "zerochain/props_methlab/tent04/tent04_nrm",
		tex_em = "zerochain/props_methlab/tent04/tent04_em",
		mat_id = 5,
		min = Vector(-90,-280,0),
		max = Vector(90,280,95),
		construction_time = 4,
		light = {
			pos = Vector(0, 0, 150),
			size = 512,
			brightness = 4,
		},
		color = Color(255,191,0)
	},
	[4] = {
		name = zmlab2.language["tent04_title"],
		desc = zmlab2.language["tent04_desc"],
		price = 125e13,
		model = "models/zerochain/props_methlab/zmlab2_tent03.mdl",
		tex_diff = "zerochain/props_methlab/tent03/tent03_diff",
		tex_nrm = "zerochain/props_methlab/tent03/tent03_nrm",
		tex_em = "zerochain/props_methlab/tent03/tent03_em",
		mat_id = 6,
		min = Vector(-150,-270,0),
		max = Vector(150,270,200),
		construction_time = 4,
		light = {
			pos = Vector(0, 0, 170),
			size = 512,
			brightness = 5,
		},
	},
	[5] = {
		name = zmlab2.language["tent05_title"],
		desc = zmlab2.language["tent05_desc"],
		price = 125e13,
		model = "models/zerochain/props_methlab/zmlab2_tent05.mdl",
		tex_diff = "zerochain/props_methlab/tent05/tent05_diff",
		tex_nrm = "zerochain/props_methlab/tent05/tent05_nrm",
		tex_em = "zerochain/props_methlab/tent05/tent05_em",
		mat_id = 3,
		min = Vector(-120,-120,0),
		max = Vector(120,120,95),
		construction_time = 4,
		light = {
			pos = Vector(0, 0, 80),
			size = 512,
			brightness = 3,
		},
		color = Color(255,191,0)
	},
}
