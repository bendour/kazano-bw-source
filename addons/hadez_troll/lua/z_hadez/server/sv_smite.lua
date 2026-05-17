-- [[ CREATED BY ZOMBIE EXTINGUISHER ]]

local takeOffSound = "npc/waste_scanner/grenade_fire.wav"
local rocketSound = "ambient/fire/fire_big_loop1.wav"
local soundLevel = 300
local cloudLifetime = 5

util.AddNetworkString("z_hadez_SmitePlayers")
local function SmitePlayers(len, ply)

	if !SH_HADEZ:HasAccess(ply, "smite") then return end
	
	local targets = SH_HADEZ:NetReadPlayers()
	
	local smiteOptions = {
		sound = net.ReadBool()
	}
	
	SV_HADEZ:LogFeature("smiteLog", "smite", ply, targets, function(ply)
		if !IsValid(ply) or !ply:Alive() or SH_HADEZ:IsInSmite(ply) then
			return nil
		end
		return true
	end)
	
	for i=1, #targets do
		SV_HADEZ:OnSmiteStart(targets[i], smiteOptions)
	end

end
net.Receive("z_hadez_SmitePlayers",SmitePlayers)

function SV_HADEZ:OnSmiteStart(target, smiteOptions)

	if !IsValid(target) or !target:Alive() or SH_HADEZ:IsInSmite(target) then return end

	SV_HADEZ:SetInSmite(target, true)
	SV_HADEZ:OnPowerToggled(target, "smite", true)
	
	local thunderOrigin = target:GetPos() + Vector(0,0,1000)
	local impactPos = target:GetPos()

	-- Sounds
	if smiteOptions.sound then
		SV_HADEZ:BroadcastSound("ambient/atmosphere/thunder"..math.random(3,4)..".wav", soundLevel, thunderOrigin, 10000)
	end
	
	timer.Simple(4, function()
		if smiteOptions.sound then
			SV_HADEZ:BroadcastSound("ambient/levels/labs/teleport_postblast_thunder1.wav", soundLevel, thunderOrigin, 10000)
		end
		util.ScreenShake( impactPos, 100, 100, 1, 2000 )
	end)

	-- Thunder cloud
	local steamParticle = ents.Create("env_steam")   
	if IsValid(steamParticle) then
		steamParticle:SetKeyValue("spreadspeed","200")
		steamParticle:SetKeyValue("speed","15")
		steamParticle:SetKeyValue("startsize","10")
		steamParticle:SetKeyValue("endsize","50")
		steamParticle:SetKeyValue("rate","1000")
		steamParticle:SetKeyValue("Jetlength","50")
		steamParticle:SetKeyValue("angles","90")
		steamParticle:SetKeyValue("rendercolor","100 100 100")
		steamParticle:Fire("turnon","",0)
		steamParticle:Fire("kill","",cloudLifetime)
		steamParticle:Spawn()
		steamParticle:SetPos(thunderOrigin)
	end
	
	-- Target point
	local targetPoint = ents.Create("info_target")
	if IsValid(targetPoint) then
		targetPoint:SetPos(impactPos)
		targetPoint:SetName(target:UniqueID())
		targetPoint:Spawn()
		targetPoint:SetParent(target)
		targetPoint:Fire("kill", "", cloudLifetime)
	end
	
    -- Lightning
	local thunderStrike = ents.Create("env_laser")
	if IsValid(thunderStrike) then
		thunderStrike:SetKeyValue("lasertarget", target:UniqueID())
		thunderStrike:SetKeyValue("renderamt", "255")
		thunderStrike:SetKeyValue("renderfx", "15")
		-- thunderStrike:SetKeyValue("rendercolor", "0 100 255")
		-- thunderStrike:SetKeyValue("texture", "sprites/laserbeam.spr")
		thunderStrike:SetKeyValue("rendercolor", "255 255 255")
		thunderStrike:SetKeyValue("texture", "effects/laser1.vmt")
		thunderStrike:SetKeyValue("texturescroll", "35")
		thunderStrike:SetKeyValue("dissolvetype", "1")
		thunderStrike:SetKeyValue("spawnflags", "32")
		thunderStrike:SetKeyValue("width", "1000")
		thunderStrike:SetKeyValue("damage", "50000")
		thunderStrike:SetKeyValue("noiseamplitude", "25")
		thunderStrike:Spawn()
		thunderStrike:Fire("Kill","",cloudLifetime-0.5)
		thunderStrike:Fire("turnoff","",0)
		thunderStrike:Fire("turnon","",cloudLifetime-1)
		thunderStrike:SetPos(thunderOrigin)
	end
	
	-- Tesla sparks
	local teslaSpark = ents.Create("point_tesla")
	if IsValid(teslaSpark) then
		teslaSpark:SetKeyValue("m_flRadius", "250")
		teslaSpark:SetKeyValue("m_Color", "255 255 255")
		teslaSpark:SetKeyValue("texture", "effects/laser1.vmt")
		teslaSpark:SetKeyValue("beamcount_min", "6")
		teslaSpark:SetKeyValue("beamcount_max", "10")
		teslaSpark:SetKeyValue("thick_min", "20")
		teslaSpark:SetKeyValue("thick_max", "50")
		teslaSpark:SetKeyValue("lifetime_min", "0.5")
		teslaSpark:SetKeyValue("lifetime_max", "1")
		teslaSpark:SetKeyValue("interval_min", "0.1")
		teslaSpark:SetKeyValue("interval_max", "0.25")
		teslaSpark:Spawn()
		teslaSpark:SetPos(thunderOrigin)
		teslaSpark:Fire("DoSpark", "", cloudLifetime-1)
		teslaSpark:Fire("kill", "", cloudLifetime-0.5)
	end
	
	timer.Simple(cloudLifetime, function()
		
		if IsValid(target) then
			SV_HADEZ:OnSmiteEnd(target)
		end
		
	end)
	
end

function SV_HADEZ:OnSmiteEnd(target)

	SV_HADEZ:SetInSmite(target, false)
	SV_HADEZ:OnPowerToggled(target, "smite", false)

end