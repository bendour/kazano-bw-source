VoidFactions.FactionSelection = VoidFactions.FactionSelection or {}
VoidFactions.FactionSelection.Panel = nil

function VoidFactions.FactionSelection:OpenMenu()
	local panel = vgui.Create("VoidFactions.UI.FactionSelection")
	panel:SSetSize(1200, 770)
	panel:Center()

	VoidFactions.FactionSelection.Panel = panel
end

net.Receive("VoidFactions.FactionSelection.Open", function ()
	if (VoidFactions.Lang.LanguagesLoaded) then
		VoidFactions.FactionSelection:OpenMenu()
	else
		hook.Add("VoidFactions.Lang.LanguagesLoaded", "VoidFactions.FactionSelection.OnLangugeLoad", function ()
			VoidFactions.FactionSelection:OpenMenu()
			hook.Remove("VoidFactions.Lang.LanguagesLoaded", "VoidFactions.FactionSelection.OnLangugeLoad")
		end)
	end
end)