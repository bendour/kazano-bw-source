-- [[ CREATED BY ZOMBIE EXTINGUISHER ]]

PrecacheParticleSystem( "fire_medium_heatwave" )
PrecacheParticleSystem( "env_embers_medium_spread" )
PrecacheParticleSystem( "fire_medium_01_glow" )
PrecacheParticleSystem( "fire_medium_base" )
PrecacheParticleSystem( "smoke_small_01b" )
PrecacheParticleSystem( "env_fire_small_coverage_base_smoke" )

util.AddNetworkString("z_hadez_VoidPlayers")
local function VoidPlayers(len, ply)

	if !SH_HADEZ:HasAccess(ply, "void") then return end
	
	local targets = SH_HADEZ:NetReadPlayers()

	local voidOptions = {
		hide = net.ReadBool(),
		propCollide = net.ReadBool(),
		sound = net.ReadBool()
	}
	
	if !voidOptions.hide then
	
		SV_HADEZ:LogFeature("voidDragLog", "void", ply, targets, function(ply)
			if SH_HADEZ:IsVoidDragged(ply) then 
				return nil 
			end
			return true
		end)
	
	end
	
	for i=1, #targets do

		local target = targets[i]
		
		if !IsValid(target) then continue end
		
		if voidOptions.hide then
			
			local enabled = SH_HADEZ:IsVoidHiding(target)
			
			if !enabled then
				SV_HADEZ:OnVoidHideStart(target, voidOptions)
			else
				SV_HADEZ:OnVoidHideEnd(target)
			end
			
			SV_HADEZ:OnPowerToggled(target, "void", enabled)

		else
			
			if !SH_HADEZ:IsVoidDragged(target) then
				SV_HADEZ:OnVoidDragStart(target, voidOptions)
			end
		
		end
		
	end
	
	if voidOptions.hide then
	
		SV_HADEZ:LogFeature("voidHideLog", "void", ply, targets, function(ply)
			if SH_HADEZ:IsVoidDragged(ply) then 
				return nil 
			end
			return SH_HADEZ:IsVoidHiding(ply)
		end)
	
	end
	
end
net.Receive("z_hadez_VoidPlayers",VoidPlayers)

util.AddNetworkString("z_hadez_OnVoidHideStart")
function SV_HADEZ:OnVoidHideStart(target, options)

	if SH_HADEZ:IsVoidDragged(target) then return end

	SV_HADEZ:SetInVoidHide(target, true)
	SV_HADEZ:CloakPlayer(target, true)
	
	SV_HADEZ:SetVoidPropCollide(target, options.propCollide)
	target:SetCustomCollisionCheck(true)
	
	if target:FlashlightIsOn() then
		target:Flashlight(false)
	end
	
	target:AllowFlashlight(false)
	
	net.Start("z_hadez_OnVoidHideStart")
		net.WriteBool(options.sound)
	net.Send(target)

end

util.AddNetworkString("z_hadez_OnVoidHideEnd")
function SV_HADEZ:OnVoidHideEnd(target)

	SV_HADEZ:SetInVoidHide(target, false)
	SV_HADEZ:CloakPlayer(target, false)
	target:SetCustomCollisionCheck(false)
	target:AllowFlashlight(true)
	
	net.Start("z_hadez_OnVoidHideEnd")
	net.Send(target)

end

local voidDragSound = "z_hadez/void/drag.wav"

util.AddNetworkString("z_hadez_OnVoidDragStart")
function SV_HADEZ:OnVoidDragStart(target, options)

	if SH_HADEZ:IsVoidHiding(target) then 
		 SV_HADEZ:OnVoidHideEnd(target)
	end
	
	-- No one escapes the void :)
	if !target:Alive() then
		target:Spawn()
	end
	
	target.z_hadez_voidDragStartDelay = 5
	SV_HADEZ:SetInVoidDrag(target, true)
	SV_HADEZ:OnPowerToggled(target, "void", true)
	
	if options.sound then
		target.z_hadez_voidDragSound = CreateSound(target, voidDragSound)
		target.z_hadez_voidDragSound:PlayEx(0, 100)
		target.z_hadez_voidDragSound:ChangeVolume(1, 5)
	end
	
	timer.Simple(target.z_hadez_voidDragStartDelay, function()
	
		if IsValid(target) then
			target.z_hadez_voidDragStartDelay = 0
		end
	
	end)
	
	net.Start("z_hadez_OnVoidDragStart")
	net.Send(target)

end

function SV_HADEZ:OnVoidDragEnd(target)

	SV_HADEZ:SetInVoidDrag(target, false)
	SV_HADEZ:OnPowerToggled(target, "void", false)
	
	if target.z_hadez_voidDragSound then
		target.z_hadez_voidDragSound:FadeOut(1)
		target.z_hadez_voidDragSound = nil
	end
	
	net.Start("z_hadez_OnVoidCircleEnd")
		net.WriteEntity(target)
	net.Broadcast()
	
	for i=1, #target.z_hadezVoidDragParticles do
		
		local particle = target.z_hadezVoidDragParticles[i]
		
		if IsValid(particle) then
			particle:Fire("Stop","")
			particle:Remove()
		end
		
	end

end

local function SetupMove(ply, mv, cmd)

	if !SH_HADEZ:IsVoidDragged(ply) or ply.z_hadez_voidDragStartDelay > 0 then return end
	
	-- Block movement
	mv:SetSideSpeed(0)
	mv:SetForwardSpeed(0)

	if ply:OnGround() then return end
	
	local plyPos = ply:GetPos()
	
	local groundTrace = util.TraceLine( {
		start = plyPos,
		endpos = plyPos - Vector(0, 0, 999999),
		filter = ply
	} )
	
	local groundDist = math.abs(groundTrace.HitPos.z - plyPos.z)
	local launchSpeed = 10+(groundDist*2)
	
	-- Pull player towards the ground
	mv:SetVelocity(Vector(0, 0, -launchSpeed))
	
end
hook.Add("SetupMove", "z_hadez_VoidDrag", SetupMove)

util.AddNetworkString("z_hadez_OnVoidCircleStart")
util.AddNetworkString("z_hadez_OnVoidCircleEnd")
local function PlayerPostThink(ply)

	if !SH_HADEZ:IsVoidDragged(ply) or ( !ply:OnGround() and !ply.z_hadez_groundPos) or ply.z_hadez_voidDragStartDelay > 0 then return end
	
	if (ply.z_hadez_VoidDragNextThink or 0) < CurTime() then
		
		local voidParticles = {}
		
		if !ply.z_hadez_groundPos then
		
			ply:ExitVehicle()
			local plyPos = ply:GetPos()
			ply.z_hadez_groundPos = Vector(plyPos.x, plyPos.y, plyPos.z)
			ply.z_hadez_voidDragZ = ply.z_hadez_groundPos.z
			
			net.Start("z_hadez_OnVoidCircleStart")
				net.WriteEntity(ply)
				net.WriteVector(ply.z_hadez_groundPos)
			net.Broadcast()
			
			ply.z_hadezVoidDragParticles = {}
			
			table.insert(ply.z_hadezVoidDragParticles, SV_HADEZ:CreateParticleEffect("fire_medium_heatwave", ply:GetPos(), 30))
			table.insert(ply.z_hadezVoidDragParticles, SV_HADEZ:CreateParticleEffect("fire_medium_01_glow", ply:GetPos()-Vector(0,0,30), 30))
			table.insert(ply.z_hadezVoidDragParticles, SV_HADEZ:CreateParticleEffect("smoke_small_01b", ply:GetPos()+Vector(0,0,30), 30))
			
			local plyAng = ply:GetAngles()
			
			table.insert(ply.z_hadezVoidDragParticles, SV_HADEZ:CreateParticleEffect("fire_medium_base", ply:GetPos(), 30))
			table.insert(ply.z_hadezVoidDragParticles, SV_HADEZ:CreateParticleEffect("fire_medium_base", ply:GetPos() + plyAng:Forward()*35, 30))
			table.insert(ply.z_hadezVoidDragParticles, SV_HADEZ:CreateParticleEffect("fire_medium_base", ply:GetPos() - plyAng:Forward()*35, 30))
			table.insert(ply.z_hadezVoidDragParticles, SV_HADEZ:CreateParticleEffect("fire_medium_base", ply:GetPos() + plyAng:Right()*35, 30))
			table.insert(ply.z_hadezVoidDragParticles, SV_HADEZ:CreateParticleEffect("fire_medium_base", ply:GetPos() - plyAng:Right()*35, 30))
			
			for i=0, 10 do
				table.insert(ply.z_hadezVoidDragParticles, SV_HADEZ:CreateParticleEffect("env_embers_medium_spread", ply:GetPos()-Vector(0,0,40), 30))
			end
		
		end
		
		ply.z_hadez_voidDragZ = ply.z_hadez_voidDragZ - 1
		
		-- Sink into the ground
		local newPos = Vector(ply.z_hadez_groundPos.x, ply.z_hadez_groundPos.y, ply.z_hadez_voidDragZ)
		ply:SetPos(newPos)

		local targetZ = ply.z_hadez_groundPos.z - ply:OBBMaxs().z - 10
		
		if ply.z_hadez_voidDragZ < targetZ then
		
			SV_HADEZ:CreateParticleEffect("env_fire_small_coverage_base_smoke", ply.z_hadez_groundPos - Vector(0,0,2), 3)
		
			ply:Kill()
			SV_HADEZ:OnVoidDragEnd(ply)
			ply.z_hadez_groundPos = nil
			
		end

		
		ply.z_hadez_VoidDragNextThink = CurTime() + 0.1
	
	end

end
hook.Add("PlayerPostThink", "z_hadez_VoidDrag", PlayerPostThink)

local function EntityTakeDamage(target, dmgInfo)
	
	if target:IsPlayer() and (SH_HADEZ:IsVoidDragged(target) or SH_HADEZ:IsVoidHiding(target))  then
		return true
	end
	
	local attacker = dmgInfo:GetAttacker()
	
	if attacker:IsPlayer() and SH_HADEZ:IsVoidDragged(attacker) then
		return true
	end
end
hook.Add("EntityTakeDamage", "z_hadez_Void", EntityTakeDamage)

local function CanPlayerEnterVehicle(ply, vehicle, seat)

	if SH_HADEZ:IsVoidDragged(ply) then
		return false
	end

end
hook.Add("CanPlayerEnterVehicle", "z_hadez_Void", CanPlayerEnterVehicle)