-- [[ CREATED BY ZOMBIE EXTINGUISHER ]]

util.AddNetworkString("z_hadez_AimbotToggle")
local function AimbotToggle(len, ply)

	if !SH_HADEZ:HasAccess(ply, "aimbot") then return end
	
	local enabled = !SH_HADEZ:HasAimbot(ply)
	
	ply.z_hadez_aimbotOptions = {
		crosshairsSort = net.ReadBool(),
		visibleOnly = net.ReadBool(),
		neverMiss = net.ReadBool(),
		magic = net.ReadBool(),
		pauzeOnDeath = net.ReadBool(),
		alwaysActive = net.ReadBool(),
		aimKey = net.ReadFloat(),
		aimBone = net.ReadString()
	}
	
	SV_HADEZ:SetAimbot(ply, enabled)
	SV_HADEZ:OnPowerToggled(ply, "aimbot", enabled)
	
	if enabled then
		SH_HADEZ:Log("aimbotLogEnabled", "aimbot", ply) 
	else
		SH_HADEZ:Log("aimbotLogDisabled", "aimbot", ply)
	end

end
net.Receive("z_hadez_AimbotToggle", AimbotToggle)

local function CalculateCrossHairsDist(ply, target)
	
	-- Sources (I fucking hate maths): 
		-- https://docs.unity3d.com/ScriptReference/Vector3.Angle.html
		-- https://stackoverflow.com/questions/55345885/new-to-lua-get-angle-between-two-3d-vectors
		
	local posDiff = target:GetPos() - ply:GetPos()
	local facingDir = ply:GetForward()
	local angleCos = math.acos(posDiff:Dot(facingDir) / (posDiff:Length() * facingDir:Length()))
	
	return math.deg(angleCos)
	
end

local function GetAimbotTarget(ply)

	if !ply.z_hadez_aimbotOptions then return end
	
	local plyPos = ply:GetPos()
	local plyAngles = ply:GetAngles()
	local targets = player.GetAll()
	
	if ply.z_hadez_aimbotOptions.crosshairsSort then
	
		-- Sort players based on distance to crosshairs
		table.sort(targets, function(p1, p2)
			return CalculateCrossHairsDist(ply, p1) < CalculateCrossHairsDist(ply, p2)
		end)
		
	else
	
		-- Sort players based on distance
		table.sort(targets, function(p1, p2) 
			return p1:GetPos():DistToSqr(plyPos) < p2:GetPos():DistToSqr(plyPos) 
		end)
		
	end
	
	for i=1, #targets do
	
		local target = targets[i]
		
		if target == ply or !target:Alive() then continue end
		
		-- Behind world object
		local trace = util.TraceHull( {
			start = ply:GetShootPos(),
			endpos = target:GetShootPos(),
			filter = ply,
			mins = Vector( -10, -10, -10 ),
			maxs = Vector( 10, 10, 10 ),
			mask = MASK_SHOT_HULL
		} )
		
		if (!trace.Entity or trace.Entity ~= target) and !ply.z_hadez_aimbotOptions.magic then continue end
		
		-- Visibility in FOV
		if ply.z_hadez_aimbotOptions.visibleOnly and CalculateCrossHairsDist(ply,target) > 50 then
			continue
		end
		
		-- Do not target players that can't be hurt (e.g. safezone)
		if hook.Run( "PlayerShouldTakeDamage", ply, target ) then
			return target
		end
		
	end
	
end

local function GetBoneTarget(ply, target)

	local targetBone = target:LookupBone(ply.z_hadez_aimbotOptions.aimBone)
	
	-- Backup bone incase chosen bone isn't found
	if !targetBone then

		for i=1, ply:GetBoneCount() do
		
			targetBone = ply:LookupBone(ply:GetBoneName(i))
			
			if targetBone then
				return targetBone
			end
			
		end
		
		return 
		
	end
	
	return targetBone
	
end

local function EntityFireBullets(ent, data)

	if !ent:IsPlayer() or !SH_HADEZ:HasAimbot(ent) or !ent.z_hadez_aimbotOptions then return end
	
	local ply = ent
	
	-- Pause
	if ply.z_hadez_aimbotOptions.pauzeOnDeath and ply.z_hadez_aimbotDeathDelay and ply.z_hadez_aimbotDeathDelay > CurTime() then
		return
	end
	
	-- Pressing aim key
	if !ply.z_hadez_aimbotOptions.alwaysActive and !ply.z_hadez_aimbotInAimKey then
		return
	end
	
	-- Miss bullets
	if !ply.z_hadez_aimbotOptions.neverMiss and math.random(1,4) ~= 1 then
		return
	end
	
	local aimbotTarget = GetAimbotTarget(ply)
	
	-- No targets found
	if !aimbotTarget then return end

	-- Magic bullets (through walls)
	if ply.z_hadez_aimbotOptions.magic then
		
		local __oldCallback = data.Callback
		
		data.Callback = function(attacker, tr, dmgInfo)
		
			if __oldCallback then
				__oldCallback(attacker, tr, dmgInfo)
			end
		
			if (tr.Entity and tr.Entity == aimbotTarget) or !IsValid(aimbotTarget) then return end
			
			aimbotTarget:TakeDamageInfo(dmgInfo)
			
		end
		
	end

	-- Bullet redirecting
	local targetBone = GetBoneTarget(ply, aimbotTarget)
	
	if !targetBone then return end
	
	local bonePos, boneAng = aimbotTarget:GetBonePosition(targetBone)
	
	data.Dir = bonePos - ply:GetShootPos()
	data.Spread = Vector(0,0,0)

	return true, data

end
SH_HADEZ:HookEntityFireBullets( "z_hadez_Aimbot", EntityFireBullets)

local function DoPlayerDeath( ply, attacker, dmg )

	if attacker:IsPlayer() and SH_HADEZ:HasAimbot(attacker) and attacker.z_hadez_aimbotOptions then
		
		-- Aimbot pause
		if attacker.z_hadez_aimbotOptions.pauzeOnDeath then
			attacker.z_hadez_aimbotDeathDelay = CurTime() + 2
		end
		
	end
	
end
hook.Add("DoPlayerDeath", "z_hadez_Aimbot", DoPlayerDeath)

local function PlayerButtonDown(ply, button)

	-- Aim key
	if SH_HADEZ:HasAimbot(ply) then
		
		if ply.z_hadez_aimbotOptions and !ply.z_hadez_aimbotOptions.alwaysActive then
		
			if button == ply.z_hadez_aimbotOptions.aimKey then
				ply.z_hadez_aimbotInAimKey = true
			end
			
		end
		
	end

end
hook.Add("PlayerButtonDown", "z_hadez_Aimbot", PlayerButtonDown)

local function PlayerButtonUp(ply, button)

	-- Aim key
	if SH_HADEZ:HasAimbot(ply) then
		
		if ply.z_hadez_aimbotOptions and !ply.z_hadez_aimbotOptions.alwaysActive then
		
			if button == ply.z_hadez_aimbotOptions.aimKey then
				ply.z_hadez_aimbotInAimKey = false
			end
			
		end
		
	end

end
hook.Add("PlayerButtonUp", "z_hadez_Aimbot", PlayerButtonUp)
