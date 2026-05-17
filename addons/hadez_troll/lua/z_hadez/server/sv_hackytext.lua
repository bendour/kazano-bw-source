-- [[ CREATED BY ZOMBIE EXTINGUISHER ]]

util.AddNetworkString("z_hadez_ShowHackyText")
util.AddNetworkString("z_hadez_HackyTextPlayers")
local function HackyTextPlayers(len, ply)

	if !SH_HADEZ:HasAccess(ply, "hackyText") then return end
	
	local targets = SH_HADEZ:NetReadPlayers()
	local text = net.ReadString()
	local size = net.ReadUInt(8)
	local font = net.ReadString()
	local color = net.ReadString()
	local time = 8
	
	net.Start("z_hadez_ShowHackyText")
		net.WriteString(text)
		net.WriteUInt(size, 8)
		net.WriteString(font)
		net.WriteString(color)
		net.WriteUInt(time, 4)
	net.Send(targets)
	
	for i=1, #targets do
	
		local target = targets[i]
		
		if !IsValid(target) then continue end
	
		SV_HADEZ:SetHackyText(target, true)
		SV_HADEZ:OnPowerToggled(target, "hackyText", true)
		
		timer.Create( "z_hadez_DisableHackyTextDelay_"..target:UniqueID(), time, 1, function()
			if IsValid(target) then
				SV_HADEZ:SetHackyText(target, false)
				SV_HADEZ:OnPowerToggled(target, "hackyText", false)
			end
		end)
		
	end
	
	SV_HADEZ:LogFeature("hackyTextLog", "hackyText", ply, targets, function(ply)
		return true
	end)

end
net.Receive("z_hadez_HackyTextPlayers",HackyTextPlayers)