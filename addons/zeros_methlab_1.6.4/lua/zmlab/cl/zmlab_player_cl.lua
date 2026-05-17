if SERVER then return end

zmlab = zmlab or {}
zmlab.f = zmlab.f or {}

function zmlab.f.Player_Initialize()
	zmlab.f.Debug("zmlab.f.Player_Initialize")

	net.Start("zmlab_Player_Initialize")
	net.SendToServer()
end

// Sends a net msg to the server that the player has fully initialized and removes itself
hook.Add("HUDPaint", "a_zmlab_PlayerInit_HUDPaint", function()
	zmlab.f.Debug("zmlab_PlayerInit_HUDPaint")

	zmlab.f.Player_Initialize()

	hook.Remove("HUDPaint", "a_zmlab_PlayerInit_HUDPaint")
end)
