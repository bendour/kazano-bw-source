-- [[ CREATED BY ZOMBIE EXTINGUISHER ]]

function SH_HADEZ:IsNukeActive()
	return GetGlobalBool("z_hadez_NukeLaunch")
end

function SH_HADEZ:GetNukeDelay()
	return GetGlobalInt("z_hadez_NukeLaunchDelay")
end 

if SERVER then

	function SV_HADEZ:LaunchNuke(target, delay, options)
	
		SetGlobalBool("z_hadez_NukeLaunch", true)
		SetGlobalInt("z_hadez_NukeLaunchDelay", delay)
		
		local backupPos = target:GetPos()
		
		timer.Create("z_hadez_nukeDelay", delay+1, 1, function()
			SV_HADEZ:OnNuke(target, backupPos, options)
		end)
		
		-- Updating delay
		SetGlobalInt("z_hadez_NukeLaunchDelay",delay)
		
		timer.Create("z_hadez_nukeDelayTimer", 1, delay, function()
			SetGlobalInt("z_hadez_NukeLaunchDelay",math.Round((timer.TimeLeft("z_hadez_nukeDelay") or 1) -1))
		end)
		
		-- Mark nuke as finished
		timer.Simple(delay+20, function()
			SetGlobalBool("z_hadez_NukeLaunch", false)
			SV_HADEZ:OnNukeEnd()
		end)
		
	end
	
end