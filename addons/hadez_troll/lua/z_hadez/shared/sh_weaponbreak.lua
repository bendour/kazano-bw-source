-- [[ CREATED BY ZOMBIE EXTINGUISHER ]]

function SH_HADEZ:IsInWeaponBreak(ply)
	return ply:GetNWBool("z_hadez_WeaponBreak")
end

if SERVER then

	function SV_HADEZ:SetInWeaponBreak(ply, bool)
		ply:SetNWBool("z_hadez_WeaponBreak", bool)
	end
	
end