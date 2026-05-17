-- [[ CREATED BY ZOMBIE EXTINGUISHER ]]

util.AddNetworkString("z_hadez_AmmoModPlayers")
local function AmmoModPlayers(len, ply)

	if !SH_HADEZ:HasAccess(ply, "ammoMod") then return end
	
	local targets = SH_HADEZ:NetReadPlayers()
	local ammoModOptions = {
		effect = net.ReadString(),
		damage = net.ReadString()
	}
	ammoModOptions.damageType = SH_HADEZ:GetDamageTypeInfo(ammoModOptions.damage)
	
	for i=1, #targets do
	
		local target = targets[i]
		
		if !IsValid(target) then continue end
		
		local enabled = !SH_HADEZ:HasAmmoMod(target)
	
		if enabled then
			target.z_hadez_ammoModOptions = ammoModOptions
		end
		
		SV_HADEZ:SetInAmmoMod(target, enabled)
		SV_HADEZ:OnPowerToggled(target, "ammoMod", enabled)
		
	end
	
	SV_HADEZ:LogFeature("ammoModLog", "ammoMod", ply, targets, function(ply)
		return SH_HADEZ:HasAmmoMod(ply)
	end)
	
end
net.Receive("z_hadez_AmmoModPlayers", AmmoModPlayers)

local effectID = 0

local function GetUniqueEffectID()

	effectID = effectID + 1

	return "z_hadez_AmmoMod_EffectID_"..effectID
	
end

local ammoEffects = {}

util.AddNetworkString("z_hadez_AmmoModEffect")
local function AmmoModEffect(len, ply)

	if !SH_HADEZ:HasAmmoMod(ply) then return end
	
	local muzzlePos = net.ReadVector()
	local hitPos = net.ReadVector()
	local effectFunc = ammoEffects[ply.z_hadez_ammoModOptions.effect]
	
	if effectFunc then 
		effectFunc(muzzlePos, hitPos)
	end
	
end
net.Receive("z_hadez_AmmoModEffect", AmmoModEffect)

local function EntityTakeDamage(target, dmgInfo)

	local attacker = dmgInfo:GetAttacker()
	
	if !attacker:IsPlayer() or !SH_HADEZ:HasAmmoMod(attacker) then return end
	
	-- Modify damage type
	dmgInfo:SetDamageType(attacker.z_hadez_ammoModOptions.damageType)

end
hook.Add("EntityTakeDamage", "z_hadez_AmmoMod", EntityTakeDamage)

ammoEffects["Tesla"] = function(origin, hitPos)

	local effectID = GetUniqueEffectID()
	
	-- Target point
	local targetPoint = ents.Create("info_target")
	if IsValid(targetPoint) then
		targetPoint:SetPos(hitPos)
		targetPoint:SetName(effectID)
		targetPoint:Spawn()
		targetPoint:Fire("kill", "", 0.15)
	end
	
    -- Lightning
	local thunderStrike = ents.Create("env_laser")
	if IsValid(thunderStrike) then
		thunderStrike:SetKeyValue("lasertarget", effectID)
		thunderStrike:SetKeyValue("renderamt", "255")
		thunderStrike:SetKeyValue("renderfx", "15")
		thunderStrike:SetKeyValue("rendercolor", "255 255 255")
		thunderStrike:SetKeyValue("texture", "effects/laser1.vmt")
		thunderStrike:SetKeyValue("texturescroll", "35")
		thunderStrike:SetKeyValue("dissolvetype", "1")
		thunderStrike:SetKeyValue("effects", "0")
		thunderStrike:SetKeyValue("width", "2.5")
		thunderStrike:SetKeyValue("damage", "5")
		thunderStrike:SetKeyValue("noiseamplitude", "1")
		thunderStrike:SetPos(origin)
		thunderStrike:Spawn()
		thunderStrike:Fire("Kill","",0.15)
		thunderStrike:Fire("turnon","",0)
	end
	
	-- Tesla sparks
	local teslaSpark = ents.Create("point_tesla")
	if IsValid(teslaSpark) then
		teslaSpark:SetKeyValue("m_flRadius", "100")
		teslaSpark:SetKeyValue("m_Color", "255 255 255")
		teslaSpark:SetKeyValue("texture", "effects/laser1.vmt")
		teslaSpark:SetKeyValue("beamcount_min", "6")
		teslaSpark:SetKeyValue("beamcount_max", "10")
		teslaSpark:SetKeyValue("thick_min", "1")
		teslaSpark:SetKeyValue("thick_max", "2")
		teslaSpark:SetKeyValue("lifetime_min", "0.01")
		teslaSpark:SetKeyValue("lifetime_max", "0.15")
		teslaSpark:SetKeyValue("interval_min", "0.01")
		teslaSpark:SetKeyValue("interval_max", "0.15")
		teslaSpark:SetPos(hitPos)
		teslaSpark:Spawn()
		teslaSpark:Fire("DoSpark", "", 0)
		teslaSpark:Fire("kill", "", 0.15)
	end
	
end

ammoEffects["Lightning Strike"] = function(origin, hitPos)

	local effectID = GetUniqueEffectID()
	
	local strikePos = hitPos + Vector(0, 0, 1000)
	
	local skyTrace = util.TraceLine( {
		start = hitPos,
		endpos = strikePos,
		filter = ply
	} )
	
	origin = skyTrace.HitPos or strikePos
	
	-- Target point
	local targetPoint = ents.Create("info_target")
	if IsValid(targetPoint) then
		targetPoint:SetPos(hitPos)
		targetPoint:SetName(effectID)
		targetPoint:Spawn()
		targetPoint:Fire("kill", "", 0.3)
	end
	
    -- Lightning
	local thunderStrike = ents.Create("env_laser")
	if IsValid(thunderStrike) then
		thunderStrike:SetKeyValue("lasertarget", effectID)
		thunderStrike:SetKeyValue("renderamt", "255")
		thunderStrike:SetKeyValue("renderfx", "15")
		thunderStrike:SetKeyValue("rendercolor", "255 255 255")
		thunderStrike:SetKeyValue("texture", "effects/laser1.vmt")
		thunderStrike:SetKeyValue("texturescroll", "35")
		thunderStrike:SetKeyValue("dissolvetype", "1")
		thunderStrike:SetKeyValue("effects", "0")
		thunderStrike:SetKeyValue("width", "500")
		thunderStrike:SetKeyValue("damage", "100")
		thunderStrike:SetKeyValue("noiseamplitude", "25")
		thunderStrike:SetPos(origin)
		thunderStrike:Spawn()
		thunderStrike:Fire("Kill","",0.3)
		thunderStrike:Fire("turnon","",0)
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
		teslaSpark:SetPos(hitPos)
		teslaSpark:Spawn()
		teslaSpark:Fire("DoSpark", "", 0)
		teslaSpark:Fire("kill", "", 0.3)
	end
	
end

ammoEffects["Laser"] = function(origin, hitPos)

	local effectID = GetUniqueEffectID()
	
	-- Target point
	local targetPoint = ents.Create("info_target")
	if IsValid(targetPoint) then
		targetPoint:SetPos(hitPos)
		targetPoint:SetName(effectID)
		targetPoint:Spawn()
		targetPoint:Fire("kill", "", 0.15)
	end
	
    -- Laser
	local laser = ents.Create("env_laser")
	if IsValid(laser) then
		laser:SetKeyValue("lasertarget", effectID)
		laser:SetKeyValue("renderamt", "255")
		laser:SetKeyValue("renderfx", "15")
		laser:SetKeyValue("rendercolor", "255 0 0")
		laser:SetKeyValue("texture", "effects/laser1.vmt")
		laser:SetKeyValue("texturescroll", "35")
		laser:SetKeyValue("dissolvetype", "2")
		laser:SetKeyValue("effects", "0")
		laser:SetKeyValue("width", "2.5")
		laser:SetKeyValue("damage", "5")
		laser:SetKeyValue("noiseamplitude", "0")
		laser:SetPos(origin)
		laser:Spawn()
		laser:Fire("Kill","",0.15)
		laser:Fire("turnon","",0)
	end
	
end

ammoEffects["Plasma"] = function(origin, hitPos)

	local effectID = GetUniqueEffectID()
	
	-- Target point
	local targetPoint = ents.Create("info_target")
	if IsValid(targetPoint) then
		targetPoint:SetPos(hitPos)
		targetPoint:SetName(effectID)
		targetPoint:Spawn()
		targetPoint:Fire("kill", "", 0.15)
	end
	
    -- Laser
	local plasma = ents.Create("env_laser")
	if IsValid(plasma) then
		plasma:SetKeyValue("lasertarget", effectID)
		plasma:SetKeyValue("renderamt", "255")
		plasma:SetKeyValue("renderfx", "15")
		plasma:SetKeyValue("rendercolor", "255 112 52")
		plasma:SetKeyValue("texture", "effects/laser1.vmt")
		plasma:SetKeyValue("texturescroll", "100")
		plasma:SetKeyValue("dissolvetype", "2")
		plasma:SetKeyValue("spawnflags", "256")
		plasma:SetKeyValue("width", "2.5")
		plasma:SetKeyValue("damage", "10")
		plasma:SetKeyValue("noiseamplitude", "0")
		plasma:SetPos(origin)
		plasma:Spawn()
		plasma:Fire("Kill","",2)
		plasma:Fire("turnon","",0)
	end
	
end