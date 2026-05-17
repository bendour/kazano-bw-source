-- [[ CREATED BY ZOMBIE EXTINGUISHER ]]

game.AddParticles( "particles/fire_01.pcf" )
PrecacheParticleSystem( "fire_medium_base" )
PrecacheParticleSystem( "fire_jet_01" )
PrecacheParticleSystem( "embers_small_01" )

local takeOffSound = "npc/waste_scanner/grenade_fire.wav"
local rocketSound = "ambient/fire/fire_big_loop1.wav"
local soundLevel = 150

util.AddNetworkString("z_hadez_RocketLaunchPlayers")
local function RocketLaunchPlayers(len, ply)

	if !SH_HADEZ:HasAccess(ply, "rocketLaunch") then return end
	
	local targets = SH_HADEZ:NetReadPlayers()
	
	local launchOptions = {
		explode = net.ReadBool(),
		sound = net.ReadBool()
	}
	
	SV_HADEZ:LogFeature("rocketLaunchLog", "rocketLaunch", ply, targets, function(ply)
		if !IsValid(ply) or !ply:Alive() or SH_HADEZ:IsInRocketLaunch(ply) then 
			return nil 
		end
		return true
	end)
	
	for i=1, #targets do
		SV_HADEZ:OnRocketLaunchStart(targets[i], launchOptions)
	end

end
net.Receive("z_hadez_RocketLaunchPlayers",RocketLaunchPlayers)

function SV_HADEZ:OnRocketLaunchStart(target, launchOptions)
	
	if !IsValid(target) or !target:Alive() or SH_HADEZ:IsInRocketLaunch(target) then return end
	
	target:ExitVehicle()
	local plyPos = target:GetPos()
	
	target.z_hadez_launchStartPos = plyPos
	target.z_hadez_launchPaintedScorch = false
	target.z_hadez_launchParticles = {}
	target.z_hadez_launchOptions = launchOptions
	SV_HADEZ:SetInRocketLaunch(target, true)
	SV_HADEZ:OnPowerToggled(target, "rocketLaunch", true)
	
	-- Stop launch on death
	local function PlayerDeath(victim, inflictor, attacker)
	
		if victim ~= target then return end
		
		if SH_HADEZ:IsInRocketLaunch(victim) then
			SV_HADEZ:OnRocketLaunchEnd(victim)
		end
		
		hook.Remove("z_hadez_RocketLaunch_"..victim:UniqueID())
		
	end
	hook.Add("PlayerDeath","z_hadez_RocketLaunch_"..target:UniqueID(),PlayerDeath)
	
	-- Launch particles
	SV_HADEZ:CreateParticleEffect("fire_medium_base", target, 2)
	local embersParticle = SV_HADEZ:CreateParticleEffect("embers_small_01", target, 2)
	embersParticle:SetAngles(Angle(180,0,0))

	timer.Simple(1, function()
	
		if !IsValid(target) then return end
	
		for i=1, 4 do
		
			local offset = i*2
			
			target.z_hadez_launchParticles[i] = SV_HADEZ:CreateParticleEffect("fire_jet_01", target, 5)
			target.z_hadez_launchParticles[i]:SetAngles(Angle(90+offset,90+offset,90+offset))
			target.z_hadez_launchParticles[i]:SetVelocity(Vector(0,0,-90))
			
		end

	end)
	
	-- Launch screenshake
	util.ScreenShake( plyPos, 5, 5, 3, 600 )
	
	-- Launch sounds
	if launchOptions.sound then
		
		target:EmitSound(takeOffSound, soundLevel)
		
		timer.Simple(0.8, function()
		
			if IsValid(target) then
				target:EmitSound(rocketSound, soundLevel)
			end
			
		end)
		
	end

end

function SV_HADEZ:OnRocketLaunchEnd(target)

	SV_HADEZ:SetInRocketLaunch(target, false)
	SV_HADEZ:OnPowerToggled(target, "rocketLaunch", false)
	target:StopSound(rocketSound)

	-- Clear particles
	for i=1, #target.z_hadez_launchParticles do
		
		local particle = target.z_hadez_launchParticles[i]
	
		if IsValid(particle) then
			particle:Fire("Stop","")
			particle:Remove()
		end
		
	end

	-- Explode player
	if target.z_hadez_launchOptions.explode then
	
		local effectData = EffectData()
		effectData:SetOrigin( target:GetPos() )
		util.Effect("Explosion", effectData)
	
		target:KillSilent()
		
	end

end

local function SetupMove(ply, mv, cmd)

	if !SH_HADEZ:IsInRocketLaunch(ply) then return end
	
	local plyPos = ply:GetPos()
	
	local skyTrace = util.TraceLine( {
		start = plyPos,
		endpos = plyPos + Vector(0, 0, 100),
		filter = ply
	} )
	
	if skyTrace.Hit then
		SV_HADEZ:OnRocketLaunchEnd(ply)
		return
	end
	
	local groundDist = math.abs(ply.z_hadez_launchStartPos.z - plyPos.z)
	local launchSpeed = 10+(groundDist*2)
	
	mv:AddKey(IN_JUMP)
	mv:SetVelocity(Vector(0, 0, launchSpeed))
	
	-- Scorch decal
	if !ply.z_hadez_launchPaintedScorch and !ply:OnGround() then
	
		local groundTrace = util.TraceLine( {
			start = plyPos,
			endpos = plyPos - Vector(0, 0, 70),
			filter = ply
		} )
		
		if groundTrace.Hit then
			util.Decal("Scorch", groundTrace.HitPos + groundTrace.HitNormal, groundTrace.HitPos - groundTrace.HitNormal)
		end
		
		ply.z_hadez_launchPaintedScorch = true
		
	end

end
hook.Add("SetupMove", "z_hadez_RocketLaunch", SetupMove)