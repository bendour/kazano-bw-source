-- [[ CREATED BY ZOMBIE EXTINGUISHER ]]

util.AddNetworkString("z_hadez_WeaponModPlayers")
local function WeaponModPlayers(len, ply)

	if !SH_HADEZ:HasAccess(ply, "weaponMod") then return end
	
	local targets = SH_HADEZ:NetReadPlayers()
	local weaponModOptions = {
		infiniteClip = net.ReadBool(),
		infiniteReserve = net.ReadBool(),
		rapidfire = net.ReadBool(),
		rapidfireToolgun = net.ReadBool(),
		noSpread = net.ReadBool(),
		noRecoil = net.ReadBool()
	}
	
	for i=1, #targets do
	
		local target = targets[i]
		
		if !IsValid(target) then continue end
		
		local enabled = !SH_HADEZ:HasWeaponMod(target)
	
		if enabled then
			SV_HADEZ:SetWeaponModOptions(target, weaponModOptions)
		end
	
		SV_HADEZ:SetInWeaponMod(target, enabled)
		SV_HADEZ:OnPowerToggled(target, "weaponMod", enabled)
		
		if weaponModOptions.noSpread or weaponModOptions.noRecoil then
		
			local activeWep = target:GetActiveWeapon()
			
			if !IsValid(activeWep) then continue end
		
			SH_HADEZ:PlayerSwitchWeapon(ply, activeWep, activeWep)
		
			net.Start("z_hadez_PlayerSwitchWeapon")
				net.WriteInt(activeWep:EntIndex(), 16)
				net.WriteInt(activeWep:EntIndex(), 16)
			net.Send(ply)
			
		end
		
	end
	
	SV_HADEZ:LogFeature("weaponModLog", "weaponMod", ply, targets, function(ply)
		return SH_HADEZ:HasWeaponMod(ply)
	end)
	
end
net.Receive("z_hadez_WeaponModPlayers", WeaponModPlayers)