VoidFactions.Menu = VoidFactions.Menu or {}

VoidFactions.Menu.Panel = nil
VoidFactions.Menu.ReopenRequested = false

concommand.Add("voidfactions", function ()
	VoidFactions.Menu:Open()
end)

hook.Add("VoidFactions.Settings.DataReceived", "VoidFactions.Menu.SetAccentColor", function ()
	VoidFactions.UI.Accent = VoidFactions.Config.FactionType == 1 and VoidUI.Colors.Blue or VoidUI.Colors.Green
end)

function VoidFactions.Menu:Open()

	if (VoidFactions.Config.FactionType == 0 and !CAMI.PlayerHasAccess(LocalPlayer(), "VoidFactions_EditSettings")) then
		VoidLib.Notify("Error", "VoidFactions isn't set up yet! Contact an admin!", VoidUI.Colors.Red, 5)
		return
	end

	if (!VoidFactions.PlayerMember) then
		VoidLib.Notify("Error", "Member object does not exist! Check server console for errors", VoidUI.Colors.Red, 5)
		return
	end

	if (IsValid(VoidFactions.Menu.Panel)) then
		VoidFactions.Menu.Panel:Remove()
	end

	local panel = vgui.Create("VoidFactions.UI.MainPanel")
	VoidFactions.Menu.Panel = panel
end

hook.Add("PlayerButtonDown", "VoidFactions.KeyBind", function (ply, key)
	if (IsValid(VoidFactions.Menu.Panel)) then return end

	local keyStr = VoidFactions.Config.MenuBind
	local _key = keyStr and input.GetKeyCode(keyStr) or nil
	if (keyStr and key == _key) then
		LocalPlayer():ConCommand("voidfactions")
	end 
end)
