-- [[ CREATED BY ZOMBIE EXTINGUISHER ]]

function SH_HADEZ:HasAmmoMod(ply)
	return ply:GetNWBool("z_hadez_AmmoMod")
end

local ammoEffects = {
	"None",
	"Tesla",
	"Lightning Strike",
	"Laser",
	"Plasma",
}

-- https://wiki.facepunch.com/gmod/Enums/DMG
local damageTypesInfos = {
	["Electric DMG"] = DMG_SHOCK,
	["Laser DMG"] = DMG_ENERGYBEAM,
	["Poison DMG"] = DMG_POISON,
	["Radiation DMG"] = DMG_RADIATION,
	["Dissolve DMG"] = DMG_DISSOLVE,
	["Burn DMG"] = DMG_BURN,
	["Blast DMG"] = DMG_BLAST,
	["Bullet DMG"] = DMG_BULLET,
}

local damageTypes = table.GetKeys(damageTypesInfos)
table.sort(damageTypes, function(a, b) return a:lower() < b:lower() end)
table.sort(ammoEffects, function(a, b) return a:lower() < b:lower() end)

function SH_HADEZ:GetAmmoEffects()
	return table.Copy(ammoEffects)
end

function SH_HADEZ:GetDamageTypes()
	return table.Copy(damageTypes)
end

function SH_HADEZ:GetDamageTypeInfo(dmg)
	return damageTypesInfos[dmg]
end

if SERVER then

	function SV_HADEZ:SetInAmmoMod(ply, bool)
		ply:SetNWBool("z_hadez_AmmoMod", bool)
	end
	
end

local function EntityFireBullets(ent, data)

	if !ent:IsPlayer() or !SH_HADEZ:HasAmmoMod(ent) then return end
	
	local ply = ent
	local __oldCallback = data.Callback
	
	data.Callback = function(attacker, tr, dmgInfo)
	
		if __oldCallback then
			__oldCallback(attacker, tr, dmgInfo)
		end
		
		if !tr.Hit then return end
		
		if CLIENT then
		
			-- Bone pos
			-- local leftHandBoneIndex = attacker:LookupBone( "ValveBiped.Bip01_L_Hand" )
			-- local leftHandBonePos = attacker:GetBonePosition( leftHandBoneIndex )
			-- local leftHandBoneVMatrix = attacker:GetBoneMatrix( leftHandBoneIndex )
			-- local muzzlePos = leftHandBonePos + attacker:GetAngles():Up() * 5 + attacker:GetAngles():Forward() * 10
			-- local muzzlePos = leftHandBonePos
			-- local muzzlePos = leftHandBonePos + leftHandBoneVMatrix:GetForward() * 10 + leftHandBoneVMatrix:GetUp() * 10
			-- self.BackUpPosition = leftHandBonePos + leftHandBoneVMatrix:GetForward() * 10 + leftHandBoneVMatrix:GetRight() * 5 + leftHandBoneVMatrix:GetUp() * 10
		
			-- Weapon attach
			-- local wep = attacker:GetActiveWeapon()
			-- local attach = wep:LookupAttachment(1)
			-- local attach2 = wep:LookupAttachment("muzzle")
			-- local muzzlePos
			
			-- if attach > 0 then
				-- muzzlePos = wep:GetAttachment(attach).Pos
			-- elseif attach2 > 0 then
				-- muzzlePos = wep:GetAttachment(attach2).Pos
			-- else
				-- muzzlePos = tr.StartPos + attacker:GetAngles():Forward() * 10
			-- end
			
			-- TODO: Find better method
			muzzlePos = tr.StartPos + attacker:GetAngles():Forward() * 20
			
			net.Start("z_hadez_AmmoModEffect")
				net.WriteVector(muzzlePos)
				net.WriteVector(tr.HitPos)
			net.SendToServer()
			
		end
		
		if SERVER then
		
			-- Save original collision group
			if !attacker.z_hadez_AmmoModColGroup then
				attacker.z_hadez_AmmoModColGroup = attacker:GetCollisionGroup()
			end
			
			-- Nocollide with env_laser
			attacker:SetCollisionGroup(COLLISION_GROUP_DEBRIS)
			
			timer.Create( "z_hadez_AmmoMod_ColisiongroupReset_"..attacker:UniqueID(),  0.15, 1, function()
			
				if IsValid(attacker) then
					attacker:SetCollisionGroup(attacker.z_hadez_AmmoModColGroup)
					attacker.z_hadez_AmmoModColGroup = nil
				end
			
			end)
		
		end
		
	end
	
	data.Tracer = 0
	
	return true, data

end
SH_HADEZ:HookEntityFireBullets( "z_hadez_AmmoMod", EntityFireBullets)
