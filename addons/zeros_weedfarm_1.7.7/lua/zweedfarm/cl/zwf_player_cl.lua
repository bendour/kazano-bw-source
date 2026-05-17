if SERVER then return end

// Sends a net msg to the server that the player has fully initialized and removes itself
hook.Add("HUDPaint", "a_zwf_PlayerInit_HUDPaint", function()
	zwf.f.Debug("zwf_PlayerInit_HUDPaint")

	net.Start("zwf_Player_Initialize")
	net.SendToServer()
	hook.Remove("HUDPaint", "a_zwf_PlayerInit_HUDPaint")
end)
