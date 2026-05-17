-- Profile auto-loading system - no UI needed
net.Receive("BaseWars:PlayerChoseProfile", function(len, ply)
	LocalPlayer().basewarsProfileID = net.ReadUInt(31)
	
	-- Profile loaded automatically, no selector UI needed
	print("[BaseWars] Profile auto-loaded: " .. LocalPlayer().basewarsProfileID)
end)