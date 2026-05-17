-- [[ CREATED BY ZOMBIE EXTINGUISHER ]]

function SH_HADEZ:IsInSmite(ply)
	return ply:GetNWBool("z_hadez_Smite")
end

if SERVER then

	function SV_HADEZ:SetInSmite(ply, bool)
		ply:SetNWBool("z_hadez_Smite", bool)
	end
	
end