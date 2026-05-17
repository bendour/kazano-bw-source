-- [[ CREATED BY ZOMBIE EXTINGUISHER ]]

util.AddNetworkString("z_hadez_BulletTimePlayers")
local function BulletTimePlayers(len, ply)

	if !SH_HADEZ:HasAccess(ply, "bulletTime") then return end
	
	local targets = SH_HADEZ:NetReadPlayers()
	local bulletTimeOptions = {
		invincible = net.ReadBool(),
		returnDmg = net.ReadBool(),
		dodge = net.ReadBool(),
		slowmo = net.ReadBool()
	}
	
	for i=1, #targets do
	
		local target = targets[i]
		
		if !IsValid(target) then continue end
		
		local enabled = !SH_HADEZ:HasBulletTime(target)
	
		if enabled then
			target.z_hadez_bulletTimeOptions = bulletTimeOptions
		end
	
		SV_HADEZ:SetBulletTime(target, enabled)
		SV_HADEZ:OnPowerToggled(target, "bulletTime", enabled)
		
	end
	
	SV_HADEZ:LogFeature("bulletTimeLog", "bulletTime", ply, targets, function(ply)
		return SH_HADEZ:HasBulletTime(ply)
	end)
	
end
net.Receive("z_hadez_BulletTimePlayers", BulletTimePlayers)

// Cheers to the ULX boyz
local function FindDodgePos(ply)

	local plyPos = ply:GetPos()

	if !ply:IsInWorld() then
		return plyPos
	end

	local yawForward = ply:EyeAngles().yaw
	local directions = {}
	
	-- switch between right and left
	if math.random(1,2) == 1 then

		directions[1] = math.NormalizeAngle( yawForward + 90 ) -- Right
		directions[2] = math.NormalizeAngle( yawForward - 90 ) -- Left
		
	else
	
		directions[1] = math.NormalizeAngle( yawForward - 90 ) -- Left 
		directions[2] = math.NormalizeAngle( yawForward + 90 ) -- Right

	end
	
	directions[3] = yawForward -- Forward
	
	for i=1, #directions do
	
		local dir = directions[i]
		local posTrace = util.TraceLine( {
			start = plyPos + Vector( 0, 0, 32 ),
			endpos = plyPos + Angle( 0, dir, 0 ):Forward() * 55, -- 47
			filter = ply
		} )
	
		if !posTrace.Hit then
			return posTrace.HitPos
		end
	
	end
	
	return plyPos

end

local function EntityTakeDamage( ent, dmgInfo )

	if !IsValid(ent) or !ent:IsPlayer() or !SH_HADEZ:HasBulletTime(ent) then return end
	
	local ply = ent
	
	if ply.z_hadez_bulletTimeOptions then
		
		local originalAttacker = dmgInfo:GetAttacker()
		
		if originalAttacker == ply or SH_HADEZ:HasBulletTime(originalAttacker) then 
			return true 
		end
		
		if ply.z_hadez_bulletTimeOptions.returnDmg then

			dmgInfo:SetAttacker(ply)
			originalAttacker:TakeDamageInfo(dmgInfo)
				
		end
		
		if ply.z_hadez_bulletTimeOptions.dodge then
	
			local eyeTrace = ply:GetEyeTrace()
			local newPos = FindDodgePos(ply)
			
			ply:SetPos(newPos)
			
			local newAngle = (eyeTrace.HitPos - ply:GetShootPos()):Angle()
			ply:SetEyeAngles(newAngle)
			
		
		end
		
		if ply.z_hadez_bulletTimeOptions.slowmo and originalAttacker:IsPlayer() and dmgInfo:IsBulletDamage() then
			
			originalAttacker:SetLaggedMovementValue(0.3)
			ply:SetLaggedMovementValue(0.3)
			
			timer.Create( "z_hadez_BulletTimeSlowmo", 3, 1, function()
			
				if IsValid(originalAttacker) then
					originalAttacker:SetLaggedMovementValue(1)
				end
				
				if IsValid(ply) then
					ply:SetLaggedMovementValue(1)
				end
				
			end)
		
		end
		
	end
	
	if ply.z_hadez_bulletTimeOptions.invincible then
		return true
	end

end
hook.Add("EntityTakeDamage", "z_hadez_BulletTime", EntityTakeDamage)