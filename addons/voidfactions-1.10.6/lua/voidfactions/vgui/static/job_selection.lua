local sc = VoidUI.Scale
local L = VoidFactions.Lang.GetPhrase

local PANEL = {}

function PANEL:Init()
	self:SSetSize(600, 500)
	self:Center()

	self:SetTitle(L"editingProfile")
end

vgui.Register("VoidFactions.UI.JobSelection", PANEL, "VoidUI.ModalFrame")