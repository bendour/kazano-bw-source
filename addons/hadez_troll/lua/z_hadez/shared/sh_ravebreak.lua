-- [[ CREATED BY ZOMBIE EXTINGUISHER ]]

function SH_HADEZ:IsRaving(ply)
	return ply:GetNWBool("z_hadez_Ravebreak")
end

function SH_HADEZ:GetRavebreakOption(ply, option)
	return ply:GetNWBool("z_hadez_RavebreakOption"..option)
end

local ravebreakSongs = {
	"ravebreak.mp3",
	"ravedance.mp3",
	"raveprayer.mp3",
	"ravegrave.mp3",
	"raveflute.mp3"
}

function SH_HADEZ:GetRavebreakSongs()
	return table.Copy(ravebreakSongs)
end

if SERVER then

	function SV_HADEZ:SetRavebreakOptions(ply, options)
	
		for name, enabled in pairs(options) do
			ply:SetNWBool("z_hadez_RavebreakOption"..name, enabled)
		end
		
	end

	util.AddNetworkString("z_hadez_RavebreakPlayers")
	local function RavebreakPlayers(len, ply)
	
		if !SH_HADEZ:HasAccess(ply, "ravebreak") then return end
		
		local targets = SH_HADEZ:NetReadPlayers()
		local song = net.ReadString()
		local ravebreakOptions = {
			dance = net.ReadBool(),
			colorize = net.ReadBool()
		}
		
		SV_HADEZ:LogFeature("ravebreakLog", "ravebreak", ply, targets, function(ply)
			if !IsValid(ply) or SH_HADEZ:IsRaving(ply) then 
				return nil
			end
			return true
		end)
		
		for i=1, #targets do
			SV_HADEZ:OnRaveStart(targets[i], song, ravebreakOptions)
		end
		
	end
	net.Receive("z_hadez_RavebreakPlayers", RavebreakPlayers)
	
	util.AddNetworkString("z_hadez_StartRaveBreak")
	function SV_HADEZ:OnRaveStart(target, song, options)
	
		if !IsValid(target) or SH_HADEZ:IsRaving(target) then return end
		
		SV_HADEZ:SetRavebreakOptions(target, options)
		target:SetNWBool("z_hadez_Ravebreak", true)
		SV_HADEZ:OnPowerToggled(target, "ravebreak", true)
		
		timer.Simple(28, function()
			if IsValid(target) then
				SV_HADEZ:OnRaveEnd(target)
			end
		end)
		
		net.Start("z_hadez_StartRaveBreak")
			net.WriteString("z_hadez/"..song)
		net.Send(target)
	
	end
	
	function SV_HADEZ:OnRaveEnd(target)
	
		target:SetNWBool("z_hadez_Ravebreak", false)
		SV_HADEZ:OnPowerToggled(target, "ravebreak", false)
		
	end
	
end

if CLIENT then

	// Thanks to Tarpenman the original creator of ravebreak
	local ravebreakEffects = {
		{
			[ "$pp_colour_addr" ] 		= 0.05,
			[ "$pp_colour_addg" ] 		= 0,
			[ "$pp_colour_addb" ] 		= 0.05,
			[ "$pp_colour_brightness" ] = 0.1,
			[ "$pp_colour_contrast" ] 	= 1,
			[ "$pp_colour_colour" ] 	= 0,
			[ "$pp_colour_mulr" ] 		= 10,
			[ "$pp_colour_mulg" ] 		= 0,
			[ "$pp_colour_mulb" ] 		= 10
		},
		{
			[ "$pp_colour_addr" ] 		= 0,
			[ "$pp_colour_addg" ] 		= 0,
			[ "$pp_colour_addb" ] 		= 0.05,
			[ "$pp_colour_brightness" ] = 0.1,
			[ "$pp_colour_contrast" ] 	= 1,
			[ "$pp_colour_colour" ] 	= 0,
			[ "$pp_colour_mulr" ] 		= 0,
			[ "$pp_colour_mulg" ] 		= 0,
			[ "$pp_colour_mulb" ] 		= 20
		},
		{
			[ "$pp_colour_addr" ] 		= 0,
			[ "$pp_colour_addg" ] 		= 0.05,
			[ "$pp_colour_addb" ] 		= 0,
			[ "$pp_colour_brightness" ] = 0.1,
			[ "$pp_colour_contrast" ] 	= 1,
			[ "$pp_colour_colour" ] 	= 0,
			[ "$pp_colour_mulr" ] 		= 0,
			[ "$pp_colour_mulg" ] 		= 20,
			[ "$pp_colour_mulb" ] 		= 0
		},
		{
			[ "$pp_colour_addr" ] 		= 0.05,
			[ "$pp_colour_addg" ] 		= 0,
			[ "$pp_colour_addb" ] 		= 0,
			[ "$pp_colour_brightness" ] = 0.1,
			[ "$pp_colour_contrast" ] 	= 1,
			[ "$pp_colour_colour" ] 	= 0,
			[ "$pp_colour_mulr" ] 		= 20,
			[ "$pp_colour_mulg" ] 		= 0,
			[ "$pp_colour_mulb" ] 		= 0
		},
		{
			[ "$pp_colour_addr" ] 		= 0.05,
			[ "$pp_colour_addg" ] 		= 0.05,
			[ "$pp_colour_addb" ] 		= 0,
			[ "$pp_colour_brightness" ] = 0.1,
			[ "$pp_colour_contrast" ] 	= 1,
			[ "$pp_colour_colour" ] 	= 0,
			[ "$pp_colour_mulr" ] 		= 10,
			[ "$pp_colour_mulg" ] 		= 10,
			[ "$pp_colour_mulb" ] 		= 0
		}
	}

	local nextColorize = 0
	local prevColorizeEffect
	
	local function RenderScreenspaceEffects()
		
		local curTime = CurTime()
		local ply = LocalPlayer()
		
		if SH_HADEZ:GetRavebreakOption(ply, "dance") then
		
			local ang = ply:EyeAngles()
			ang.p = 30*math.sin((curTime%2*math.pi)*2)
			ply:SetEyeAngles( ang )
			
		end
		
		if SH_HADEZ:GetRavebreakOption(ply, "colorize") then
		
			if nextColorize < curTime then
			
				local nextColorizeEffect = prevColorizeEffect
			
				while (nextColorizeEffect == prevColorizeEffect) do
					nextColorizeEffect = math.random(1,#ravebreakEffects)
				end
				
				prevColorizeEffect = nextColorizeEffect
				
				nextColorize = curTime + 0.5
			
			end
			
			DrawColorModify( ravebreakEffects[prevColorizeEffect] )
		
		end
		
	end

	local function StartRaveBreak()
		
		local ply = LocalPlayer()
		local song = net.ReadString()
	
		surface.PlaySound(song)
		
		hook.Add("RenderScreenspaceEffects", "z_hadez_Ravebreak", RenderScreenspaceEffects)
		
		-- Cleanup
		timer.Simple(26, function()
			hook.Remove("RenderScreenspaceEffects", "z_hadez_Ravebreak")
		end)
		
	end
	net.Receive("z_hadez_StartRaveBreak", StartRaveBreak)
	
end