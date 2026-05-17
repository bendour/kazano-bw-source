-- [[ CREATED BY ZOMBIE EXTINGUISHER ]]

function SH_HADEZ:HasAimbot(ply)
	return ply:GetNWBool("z_hadez_Aimbot")
end

if SERVER then

	function SV_HADEZ:SetAimbot(ply, bool)
		return ply:SetNWBool("z_hadez_Aimbot", bool)
	end
	
end