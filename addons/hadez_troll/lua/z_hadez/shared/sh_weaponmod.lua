-- [[ CREATED BY ZOMBIE EXTINGUISHER ]]

function SH_HADEZ:HasWeaponMod(ply)
	return ply:GetNWBool("z_hadez_WeaponMod")
end

function SH_HADEZ:GetWeaponModOption(ply, option)
	return ply:GetNWBool("z_hadez_WeaponMod_"..option)
end

if SERVER then

	function SV_HADEZ:SetInWeaponMod(ply, bool)
		ply:SetNWBool("z_hadez_WeaponMod", bool)
	end
	
	function SV_HADEZ:SetWeaponModOptions(ply, options)
	
		for name, value in pairs(options) do
			ply:SetNWBool("z_hadez_WeaponMod_"..name, value)
		end
		
	end
	
end

local rapidfireBlacklist = {
	["weapon_smg1"] = true,
	["weapon_pistol"] = true,
	["weapon_ar2"] = true
}

local function PlayerPostThink(ply) 

	if !SH_HADEZ:HasWeaponMod(ply) then return end

	local activeWep = ply:GetActiveWeapon()
	
	if !IsValid(activeWep) then return end
	
	-- Ammo
	if SERVER then
	
		local hasInfiniteClip = SH_HADEZ:GetWeaponModOption(ply, "infiniteClip")
		local hasInfiniteReserve = SH_HADEZ:GetWeaponModOption(ply, "infiniteReserve")
	
		if hasInfiniteClip or hasInfiniteReserve then
		
			local maxClip = activeWep:GetMaxClip1()
			local maxClip2 = activeWep:GetMaxClip2()
			local primAmmoType = activeWep:GetPrimaryAmmoType()
			local secAmmoType = activeWep:GetSecondaryAmmoType()
		
			-- Energy weapons
			if maxClip == -1 and maxClip2 == -1 then
				maxClip = 100 
				maxClip2 = 100
			end
			
			-- Projectile weapons
			if maxClip <= 0 and primAmmoType ~= -1 then
				maxClip = 1
			end
			
			-- Projectile alt
			if maxClip2 == -1 and secAmmoType ~= -1 then
				maxClip2 = 1
			end
			
			if hasInfiniteClip then
			
				if maxClip > 0 then
					activeWep:SetClip1(maxClip)
				end
				
				if maxClip2 > 0 then
					activeWep:SetClip2(maxClip2)
				end
				
			end
			
			if hasInfiniteReserve then
			
				if primAmmoType ~= -1 then
					ply:SetAmmo(maxClip, primAmmoType, true)
				end
			
				if secAmmoType ~= -1 and secAmmoType ~= primAmmoType then
					ply:SetAmmo(maxClip2, secAmmoType, true)
				end
			
			end
			
		end
		
	end
	
	-- Rapidfire
	if SH_HADEZ:GetWeaponModOption(ply, "rapidfire") and !rapidfireBlacklist[activeWep:GetClass()] then
	
		activeWep:SetNextPrimaryFire(0)
		activeWep:SetNextSecondaryFire(0)
		
	end
	
	-- Rapidfire Toolgun
	if SH_HADEZ:GetWeaponModOption(ply, "rapidfireToolgun") and activeWep:GetClass() == "gmod_tool" then
	
		if ply:KeyDown(IN_ATTACK) then 
			activeWep:PrimaryAttack()
		end
		
	end
	
end
hook.Add("PlayerPostThink", "z_hadez_WeaponMod",PlayerPostThink)

local noSpreadKeys = {
	-- M9K & TFA
	{"Primary","Spread"},
	{"Primary","IronAccuracy"},
	-- FAS
	"HipCone",
	"AimCone",
	-- CW2.0
	"SpreadPerShot",
	"HipSpread",
	"AimSpread",
	"SpreadCooldown",
	"VelocitySensitivity",
	// "MaxSpreadInc" --> bug CW 2.0 DONT THOUCH
	-- ArcCW
	"AccuracyMOA",
	"HipDispersion",
	-- CS1.6
	{"Primary","Cone"},
}

local noRecoilKeys = {
	-- M9K & TFA 
	{"Primary","Recoil"},
	{"Primary","KickUp"},
	{"Primary","KickDown"},
	{"Primary","KickHorizontal"},
	-- FAS
	"ViewKick",
	-- CW2.0
	"Recoil",
	-- ArcCW
	"RecoilSide",
	"RecoilRise",
	-- CS1.6
	{"Primary","Recoil"},
}

local allWeaponKeys = table.Copy(noSpreadKeys)
table.Add(allWeaponKeys, noRecoilKeys)

local function ModifyWeaponKeys(wep, weaponKeys, shouldRestore)

	wep.z_hadez_WeaponMod = !shouldRestore

	for i=1, #weaponKeys do
	
		local weaponKey = weaponKeys[i]
	
		if istable(weaponKey) then
		
			if wep[weaponKey[1]] ~= nil and wep[weaponKey[1]][weaponKey[2]] ~= nil and isnumber(wep[weaponKey[1]][weaponKey[2]]) then
				
				if shouldRestore then
					
					if wep["z_hadez_WeaponMod_"..weaponKey[1]..weaponKey[2]] then
						wep[weaponKey[1]][weaponKey[2]] = wep["z_hadez_WeaponMod_"..weaponKey[1]..weaponKey[2]]
					end
					
				else
				
					-- Save real value
					if !wep["z_hadez_WeaponMod_"..weaponKey[1]..weaponKey[2]] then
						wep["z_hadez_WeaponMod_"..weaponKey[1]..weaponKey[2]] = wep[weaponKey[1]][weaponKey[2]]
					end
				
					wep[weaponKey[1]][weaponKey[2]] = 0
				
				end
				
			end
			
		else
		
			if wep[weaponKey] ~= nil and isnumber(wep[weaponKey]) then
			
				if shouldRestore then
				
					if wep["z_hadez_WeaponMod_"..weaponKey] then
						wep[weaponKey] = wep["z_hadez_WeaponMod_"..weaponKey]
					end
					
				else
				
					-- Save real value
					if !wep["z_hadez_WeaponMod_"..weaponKey] then
						wep["z_hadez_WeaponMod_"..weaponKey] = wep[weaponKey]
					end
					
					wep[weaponKey] = 0
				
				end
				
			end
			
		end
	
	end

end

local function PlayerSwitchWeapon(ply, oldWep, newWep)

	if SERVER then
		
		SH_HADEZ:PlayerSwitchWeapon(ply, oldWep, newWep)
		
		net.Start("z_hadez_PlayerSwitchWeapon")
			net.WriteInt(oldWep:EntIndex(), 16)
			net.WriteInt(newWep:EntIndex(), 16)
		net.Send(ply)
		
	end

end
hook.Add("PlayerSwitchWeapon","z_hadez_WeaponMod",PlayerSwitchWeapon)

-- Need function that gets called every time in both realm (PlayerSwitchWeapon cl bug)
function SH_HADEZ:PlayerSwitchWeapon(ply, oldWep, newWep)
	
	if !oldWep:IsValid() or !newWep:IsValid() then return end
	
	if oldWep.z_hadez_WeaponMod then
		-- print(oldWep,"restoring all")
		ModifyWeaponKeys(oldWep, allWeaponKeys, true)
	end
	
	if SH_HADEZ:HasWeaponMod(ply) then
	
		if SH_HADEZ:GetWeaponModOption(ply, "noSpread") then
			-- print(newWep,"activating noSpread")
			ModifyWeaponKeys(newWep, noSpreadKeys, false)
		end
		
		if SH_HADEZ:GetWeaponModOption(ply, "noRecoil") then
			-- print(newWep,"activating noRecoil")
			ModifyWeaponKeys(newWep, noRecoilKeys, false)
		end
	
	end
	
end

if SERVER then
	util.AddNetworkString("z_hadez_PlayerSwitchWeapon")
end

if CLIENT then

	net.Receive("z_hadez_PlayerSwitchWeapon", function()

		local oldWepIndex = net.ReadInt(16)
		local newWepIndex = net.ReadInt(16)
		local timerID = "z_hadez_PlayerSwitchWeaponTimer_"..oldWepIndex+newWepIndex

		timer.Create(timerID, 0.5, 10, function()
			
			local oldWep = Entity(oldWepIndex)
			local newWep = Entity(newWepIndex)
			
			if oldWep:IsValid() and newWep:IsValid() then
				-- print(oldWep, newWep)
				SH_HADEZ:PlayerSwitchWeapon(LocalPlayer(), oldWep, newWep)
				
				timer.Remove(timerID)
				
			end
		
		end)

		SH_HADEZ:PlayerSwitchWeapon(LocalPlayer(), net.ReadEntity(), net.ReadEntity())
		
	end)
	
end