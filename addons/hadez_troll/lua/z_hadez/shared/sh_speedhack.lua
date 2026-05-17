-- [[ CREATED BY ZOMBIE EXTINGUISHER ]]

function SH_HADEZ:HasSpeedHack(ply)
	return ply:GetNWBool("z_hadez_SpeedHack")
end

function SH_HADEZ:GetSpeedHackOption(ply, option)
	return ply:GetNWBool("z_hadez_SpeedHack"..option)
end

if SERVER then

	function SV_HADEZ:SetSpeedHack(ply, bool)
		ply:SetNWBool("z_hadez_SpeedHack", bool)
	end

	function SV_HADEZ:SetSpeedHackOptions(ply, options)
	
		for name, value in pairs(options) do
			ply:SetNWBool("z_hadez_SpeedHack"..name, value)
		end
		
	end
	
end

-- Infinite jump
local function SetupMove(ply, mv)

	if !SH_HADEZ:HasSpeedHack(ply) or SH_HADEZ:GetSpeedHackOption(ply, "jumpInfinite") or ply:OnGround() or !mv:KeyPressed(IN_JUMP) then return end

	local vel = ply:GetVelocity()
	vel.z = ply:GetJumpPower()

	mv:SetVelocity(vel)

	ply:DoCustomAnimEvent(PLAYERANIMEVENT_JUMP , -1)

end
hook.Add("SetupMove", "z_hadez_SpeedHack", SetupMove)