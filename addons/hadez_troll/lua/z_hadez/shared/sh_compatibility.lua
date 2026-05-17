-- [[ CREATED BY ZOMBIE EXTINGUISHER]]

/*
	Can be used to integrate with other addons
*/

if SERVER then

	function SV_HADEZ:OnPowerToggled(ply, power, enabled)
	
		hook.Run( "z_hadez_OnPowerToggled", ply, power, enabled )

	end
	
end

// Leys Serverside AntiCheat (LSAC)
local function LSACCompatility(ply, power, enabled)

	if LSAC and LSAC.detections then
		local time = enabled and 9999 or nil
		LSAC.detections:ExtIgnorePlayerForSeconds(ply, "z_hadez_"..power, time)
	end
	
end
hook.Add("z_hadez_OnPowerToggled", "lsac_anticheat", LSACCompatility)

function SH_HADEZ:HasLSACBot()

	if !LSAC then return false end

	if CLIENT then
	
		local plys = player.GetAll()
		
		for i=1, #plys do
		
			local ply = plys[i]
			
			if !ply:IsBot() and !ply:IsNextBot() and ply:SteamID64() == nil then
				return true
			end
			
		end
		
		return false
	
	else

		return LSAC.AimbotBreakerBot ~= nil

	end

end

function SH_HADEZ:IsLSACBot(ply)

	if !LSAC or !IsValid(ply) then return false end

	if CLIENT then
	
		if !ply:IsBot() and !ply:IsNextBot() and ply:SteamID64() == nil then
			return true
		end
	
	else

		return ply == LSAC.AimbotBreakerBot

	end
	
end