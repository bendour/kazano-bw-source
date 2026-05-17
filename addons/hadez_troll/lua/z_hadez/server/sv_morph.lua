-- [[ CREATED BY ZOMBIE EXTINGUISHER ]]

util.AddNetworkString("z_hadez_MorphPlayers")
local function MorphPlayers(len, ply)

	if !SH_HADEZ:HasAccess(ply, "morph") then return end
	
	local targets = SH_HADEZ:NetReadPlayers()
	local morphOptions = {
		move = net.ReadBool(),
		model = net.ReadString()
	}
	
	for i=1, #targets do
	
		local target = targets[i]
		
		if !IsValid(target) then continue end
		
		local enabled = !SH_HADEZ:IsMorphed(target)
	
		if enabled then
			target.z_hadez_MorphOptions = morphOptions
			SV_HADEZ:MorphStart(target, morphOptions)
		else
			SV_HADEZ:MorphStop(target)
		end
		
		SV_HADEZ:OnPowerToggled(target, "morph", enabled)
		
	end
	
	SV_HADEZ:LogFeature("morphLog", "morph", ply, targets, function(ply)
		return SH_HADEZ:IsMorphed(ply)
	end)
	
end
net.Receive("z_hadez_MorphPlayers", MorphPlayers)

local function CreateMorphEntity(ply, model)

	local morphEnt = ents.Create( "z_hadez_morphent" )
	morphEnt:SetModel( model )
	morphEnt:SetPos(ply:GetPos() - Vector(0, 0, morphEnt:OBBMins().z))
	morphEnt:SetAngles(ply:GetAngles())
	-- morphEnt:SetParent(ply) --> Doesn't network angles properly
	morphEnt:SetOwner(ply)
	morphEnt:Spawn()

	morphEnt:CallOnRemove("z_hadez_MorphRespawn",function(ent)
		
		timer.Simple(0.5, function()
			
			if !IsValid(ply) then return end
		
			if SH_HADEZ:IsMorphed(ply) then
				CreateMorphEntity(ply, model)
			end
			
		end)
		
	end)
	
	ply.z_hadez_MorphEntity = morphEnt

	return morphEnt

end

function SV_HADEZ:MorphStart(ply, options)

	if !util.IsValidModel(options.model) then return end
	
	SV_HADEZ:SetMorphed(ply, true)
	SV_HADEZ:CloakPlayer(ply, true, false, COLLISION_GROUP_NONE)

	CreateMorphEntity(ply, options.model)
	
end

function SV_HADEZ:MorphStop(ply)

	SV_HADEZ:SetMorphed(ply, false)
	
	if IsValid(ply.z_hadez_MorphEntity) then
		ply.z_hadez_MorphEntity:RemoveCallOnRemove("z_hadez_MorphRespawn")
		ply.z_hadez_MorphEntity:Remove()
	end
	
	SV_HADEZ:CloakPlayer(ply, false, false)
	
end

local function StartCommand(ply, cmd)

	-- Start using recorded movement
	if SH_HADEZ:IsMorphed(ply) and ply.z_hadez_MorphOptions then
		
		if !ply.z_hadez_MorphOptions.move then
		
			cmd:ClearMovement()
			cmd:ClearButtons()
		
		end
		
	end
	
end
hook.Add("StartCommand", "z_hadez_Morph", StartCommand)
