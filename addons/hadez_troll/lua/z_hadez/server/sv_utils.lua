-- [[ CREATED BY ZOMBIE EXTINGUISHER ]]

function SV_HADEZ:CloakPlayer(ply, enabled, hideWeapons, colOverride)
	
	ply.z_hadez_isCloaked = enabled
	ply.z_hadez_cloakedOptions = {
		hideWeapons = hideWeapons,
		colOverride = colOverride
	}

	/* Blocks eyeAngles update on target + cant render models in paint hook
		ply:SetNoDraw(enabled)
		ply:DrawWorldModel(!enabled)
	*/
	
	/* Draws flashlight shadows
		ply:SetRenderMode(enabled and RENDERMODE_TRANSALPHA or RENDERMODE_NORMAL)
		ply:Fire("alpha", enabled and 0 or 255, 0)
	*/
	
	ply:SetRenderMode(enabled and RENDERMODE_NONE or RENDERMODE_NORMAL)
	ply:SetCollisionGroup(enabled and (colOverride or COLLISION_GROUP_IN_VEHICLE) or COLLISION_GROUP_NONE)
	ply:SetNoTarget(enabled)
	ply:DrawShadow(!enabled)
	-- ply:DrawWorldModel(!enabled)
	
	if hideWeapons == nil or hideWeapons then
	
		-- Weapons
		local weps = ply:GetWeapons()
		
		for i=1, #weps do
			-- weps[i]:SetNoDraw(enabled)
			weps[i]:SetRenderMode(enabled and RENDERMODE_TRANSALPHA or RENDERMODE_NORMAL)
			weps[i]:Fire("alpha", enabled and 0 or 255, 0)
			weps[i]:DrawShadow(!enabled) 
			 
			-- if enabled then
				-- weps[i]:AddEffects(EF_NOSHADOW) 
				-- weps[i]:AddEffects(EF_NORECEIVESHADOW)
			-- else
				-- weps[i]:RemoveEffects(EF_NOSHADOW)
				-- weps[i]:RemoveEffects(EF_NORECEIVESHADOW)
			-- end
			
		end
		
		-- Physgun beams
		local physgunBeams = ents.FindByClassAndParent("physgun_beam", ply)
		
		if physgunBeams then
			for i=1, #physgunBeams do
				physgunBeams[i]:SetNoDraw(enabled)
			end
		end
		
	end
	
end

local function PlayerSwitchWeapon( ply, oldWeapon, newWeapon )

	if ply.z_hadez_isCloaked then
		
		-- Skip some frames (ArcCW being ArcCW)
		timer.Simple(0.1, function()
		
			if IsValid(ply) then
				SV_HADEZ:CloakPlayer(ply, true, ply.z_hadez_cloakedOptions.hideWeapons, ply.z_hadez_cloakedOptions.colOverride)
			end
			
		end)
		
	end

end
hook.Add("PlayerSwitchWeapon", "z_hadez_WeaponCloak" ,PlayerSwitchWeapon)

function SV_HADEZ:ForceWeapon(ply, class) 
	
	local hasWeapon = ply:HasWeapon(class)
	
	if !hasWeapon then
		ply:Give(class)
	end
	
	local timerID = "z_hadez_forceWeaponTimer"..class..ply:UniqueID()
	timer.Create(timerID, 0.5, 0, function()
	
		if !ply:IsValid() or (IsValid(ply:GetActiveWeapon()) and ply:GetActiveWeapon():GetClass() == class) then
			timer.Destroy(timerID)
			return
		end
		
		ply:SelectWeapon(class)
		
	end)
	
	return hasWeapon
	
end

function SV_HADEZ:HoldWeapons(ply, shouldHold)

	if shouldHold then

		local weps = ply:GetWeapons()
		ply.holdingWeps = {}
		
		for i=1, #weps do
			table.insert(ply.holdingWeps, weps[i]:GetClass())
		end
		
		ply:StripWeapons()
		
	else
	
		ply.holdingWeps = ply.holdingWeps or {}
	
		for i=1, #ply.holdingWeps do
			ply:Give(ply.holdingWeps[i])
		end
	
	end

end

function SV_HADEZ:CreateParticleEffect(name, posOrParent, duration)

	local particleSystem = ents.Create("info_particle_system")
	particleSystem:SetKeyValue("effect_name", name)
	particleSystem:SetKeyValue("start_active", "1")
	
	
	if isentity(posOrParent) then
		particleSystem:SetParent(posOrParent)
		particleSystem:SetPos(posOrParent:GetPos() + Vector(0,0,1))
	else
		particleSystem:SetPos(posOrParent)
	end

	particleSystem:Spawn() 
	particleSystem:Activate()
	particleSystem:Fire("Kill", nil, duration)
	
	return particleSystem

end

function SV_HADEZ:BroadcastSound(soundPath, soundLevel, origin, distance)
	
	local plys = player.GetAll()
	
	for i=1, #plys do
		
		local ply = plys[i]
		ply.nextPlaySound = ply.nextPlaySound or 0
		
		if ply:GetPos():Distance(origin) <= distance then
		
			if ply.nextPlaySound < CurTime() then 
				ply:EmitSound(soundPath, soundLevel)
				ply.nextPlaySound = CurTime() + 0.5
			end
			
		end
		
	end
	

end

local function CanSuicide(ply)

	if SH_HADEZ:IsVoidDragged(ply) and SH_HADEZ:IsInRocketLaunch(ply) then
		return false
	end
	
end
hook.Add( "CanPlayerSuicide", "z_hadez_CanSuicide", CanSuicide)