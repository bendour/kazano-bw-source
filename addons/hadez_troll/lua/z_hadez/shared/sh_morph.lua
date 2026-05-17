-- [[ CREATED BY ZOMBIE EXTINGUISHER ]]

local morphModels = {
	["morphToilet"] = "models/props_c17/furnituretoilet001a.mdl",
	["morphBoat"] = "models/props_canal/boat002b.mdl",
	["morphCar"] = "models/props_vehicles/car002a_physics.mdl",
	["morphBin"] = "models/props_junk/TrashBin01a.mdl",
	["morphVendingMachine"] = "models/props_interiors/VendingMachineSoda01a.mdl",
	["morphTurret"] = "models/combine_turrets/floor_turret.mdl",
	["morphGrave"] = "models/props_c17/gravestone002a.mdl",
	["morphBust"] = "models/props_combine/breenbust.mdl",
	["morphGhost"] = "models/shadertest/vertexlittextureplusenvmappedbumpmap.mdl",
	["morphGordon"] = "models/editor/playerstart.mdl",
	["morphDoll"] = "models/maxofs2d/companion_doll.mdl",
}

local function Initialize()

	local morphModelKeyTranslations = {}
	local morphModelTranslations = {}

	for langKey, path in pairs(morphModels) do
		
		local translation = SH_HADEZ:Translate(langKey)
		morphModelKeyTranslations[translation] = langKey
		table.insert(morphModelTranslations, translation)

	end

	table.sort(morphModelTranslations, function(a, b) return a:lower() < b:lower() end)

	function SH_HADEZ:GetMorphModelFromTranslation(translation)
		
		local key = morphModelKeyTranslations[translation]

		return morphModels[key]
		
	end

	function SH_HADEZ:GetMorphModels()
		return table.Copy(morphModels)
	end

	function SH_HADEZ:GetMorphModelNames()
		return table.Copy(morphModelTranslations)
	end

end
hook.Add("Initialize", "z_hadez_Morph", Initialize)

function SH_HADEZ:IsMorphed(ply)
	return ply:GetNWBool("z_hadez_Morph")
end

if SERVER then

	function SV_HADEZ:SetMorphed(ply, bool)
		ply:SetNWBool("z_hadez_Morph", bool)
	end
	
	-- Precaches model so client can validate model
	util.AddNetworkString("z_hadez_MorphValidateModel")
	local function ValidateModel(len, ply)
		
		if !SH_HADEZ:HasAccess(ply, "morph") then return end
	
		util.IsValidModel(net.ReadString())
		
	end
	net.Receive("z_hadez_MorphValidateModel", ValidateModel)
	
end