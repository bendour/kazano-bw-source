-- [[ CREATED BY ZOMBIE EXTINGUISHER ]]

local HandleAmmoStripping

util.AddNetworkString("z_hadez_WeaponBreakPlayers")
local function WeaponBreakPlayers(len, ply)

	if !SH_HADEZ:HasAccess(ply, "weaponBreak") then return end
	
	local targets = SH_HADEZ:NetReadPlayers()
	local weaponBreakOptions = {
		suicide = net.ReadBool(),
		missAll = net.ReadBool(),
		noClipAmmo = net.ReadBool(),
		noReserveAmmo = net.ReadBool()
	}
	
	for i=1, #targets do
	
		local target = targets[i]
		
		if !IsValid(target) then continue end
		
		local enabled = !SH_HADEZ:IsInWeaponBreak(target)
	
		if enabled then
			target.z_hadez_weaponBreakOptions = weaponBreakOptions
			HandleAmmoStripping(target)
		end
	
		SV_HADEZ:SetInWeaponBreak(target, enabled)
		SV_HADEZ:OnPowerToggled(target, "weaponBreak", enabled)
		
	end
	
	SV_HADEZ:LogFeature("weaponBreakLog", "weaponBreak", ply, targets, function(ply)
		return SH_HADEZ:IsInWeaponBreak(ply)
	end)
	
end
net.Receive("z_hadez_WeaponBreakPlayers", WeaponBreakPlayers)

local function EntityTakeDamage( ent, dmgInfo )

	if !IsValid(ent) then return end
	
	local target = ent
	local attacker = dmgInfo:GetAttacker()
	
	if !attacker:IsPlayer() or !SH_HADEZ:IsInWeaponBreak(attacker) or !attacker.z_hadez_weaponBreakOptions then return end
	
	local shouldMiss = attacker.z_hadez_weaponBreakOptions.missAll or math.random(1,2) == 1
	
	if shouldMiss then
	
		if attacker.z_hadez_weaponBreakOptions.suicide then
	
			dmgInfo:SetAttacker(game.GetWorld())
			attacker:TakeDamageInfo(dmgInfo)
			
		end
		
		return true

	end

end
hook.Add("EntityTakeDamage", "z_hadez_WeaponBreak", EntityTakeDamage)

function HandleAmmoStripping(ply)
	
	-- Strip all clip ammo
	if ply.z_hadez_weaponBreakOptions.noClipAmmo then
	
		local wepTbl = ply:GetWeapons()
		
		for i=1, #wepTbl do
		
			local wep = wepTbl[i]			
			wep:SetClip1(0)
			wep:SetClip2(0)

		end
	end
	
	-- Strip all reserve ammo
	if ply.z_hadez_weaponBreakOptions.noReserveAmmo then
		-- ply:StripAmmo() -> BUG: possible segmentation fault
		ply:RemoveAllAmmo()
	end
	
end

local nextThink = 0

local function PlayerPostThink(ply)
	
	if nextThink < CurTime() then
	
		if !SH_HADEZ:IsInWeaponBreak(ply) or !ply.z_hadez_weaponBreakOptions then return end
	
		HandleAmmoStripping(ply)
		
		nextThink = CurTime() + 0.25
		
	end

end
hook.Add("PlayerPostThink", "z_hadez_WeaponBreak",PlayerPostThink)