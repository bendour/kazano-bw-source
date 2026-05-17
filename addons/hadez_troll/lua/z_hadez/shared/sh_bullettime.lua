-- [[ CREATED BY ZOMBIE EXTINGUISHER ]]

function SH_HADEZ:HasBulletTime(ply)
	return ply:GetNWBool("z_hadez_BulletTime")
end

if SERVER then

	function SV_HADEZ:SetBulletTime(ply, bool)
		ply:SetNWBool("z_hadez_BulletTime", bool)
	end
	
end