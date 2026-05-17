
local sc = VoidUI.Scale
local L = VoidFactions.Lang.GetPhrase

local PANEL = {}

function PANEL:Init()

	self:SetOrigSize(270, 506)

	local rowPanel = self:Add("VoidUI.RowPanel")
	rowPanel:Dock(FILL)
	rowPanel:SDockMargin(0, 0, 0, 10)
	rowPanel.defaultColor = VoidUI.Colors.TextGray
	rowPanel.hoverColor = VoidUI.Colors.GrayText

	rowPanel:SetSpacing(0)

	local addButton = self:Add("VoidUI.Button")
	addButton:Dock(BOTTOM)
	addButton:MarginSides(10)
	addButton:MarginBottom(10)
	addButton:SetText(L"addFaction")
	addButton:SetFont("VoidUI.R22")
	addButton:SetColor(VoidFactions.UI.Accent)
	addButton.DoClick = function ()
		local frame = vgui.Create("VoidFactions.UI.FactionCreate")
		frame:SetParent(self)
	end
        
	local ply = LocalPlayer()
	if (!CAMI.PlayerHasAccess(ply, "VoidFactions_EditFactions")) then
		addButton:SetEnabled(false)
	end

	self.rowPanel = rowPanel
	self.addButton = addButton

	self.selectedFaction = nil
end

function PANEL:OnSelect(faction)

end

function PANEL:SetFactions(factions)

	self.rowPanel:Clear()
	local rootFactions = VoidFactions.Utils:BuildSubfactions(factions)

	self:AddFaction({
		id = 0,
		name = L"rankTemplate"
	}, true, false, false, true)

	for _, faction in pairs(rootFactions) do
		self:AddFaction(faction, true, false, false)
		for k, v in pairs(faction.subfactions or {}) do
			self:AddFaction(v, false, true, false)
			for _, p in pairs(v.subfactions or {}) do
				self:AddFaction(p, false, false, true)
			end
		end
	end
end

function PANEL:AddFaction(faction, isRoot, isFaction, isSubfaction, isTemplate)
	local this = self
	local panel = self.rowPanel:Add("DButton")
	panel:SetText("")
	panel.Paint = function (self, w, h)
		if (self:IsHovered() or (this.selectedFaction and this.selectedFaction.id == faction.id) ) then
			if (this.selectedFaction and this.selectedFaction.id == faction.id) then
				draw.RoundedBox(8, 0, 0, w, h, VoidFactions.UI.Accent)
			else
				draw.RoundedBox(8, 0, 0, w, h, VoidUI.Colors.TextGray)
			end
		end

		if (isRoot) then
			draw.SimpleText(string.upper(faction.name), isTemplate and "VoidUI.B24" or "VoidUI.B28", sc(10), h/2-1, VoidUI.Colors.Gray, TEXT_ALIGN_LEFT, TEXT_ALIGN_CENTER)
		end
		if (isFaction) then
			local dotSize = 4
			draw.RoundedBox(4, sc(15), h/2-dotSize/2+1, dotSize, dotSize, VoidUI.Colors.Gray)
			draw.SimpleText(faction.name, "VoidUI.R24", sc(25), h/2-1, VoidUI.Colors.Gray, TEXT_ALIGN_LEFT, TEXT_ALIGN_CENTER)
		end
		if (isSubfaction) then
			draw.SimpleText(faction.name, "VoidUI.R20", sc(35), h/2-1, VoidUI.Colors.Gray, TEXT_ALIGN_LEFT, TEXT_ALIGN_CENTER)
		end
	end

	panel.DoClick = function ()
		local _faction = VoidFactions.LoadedFactions[faction.id] -- We need to use the original reference
		self.selectedFaction = _faction or faction
		self:OnSelect(faction, isTemplate)
	end

	local function duplicatePopup()
		local popup = vgui.Create("VoidUI.Popup")
		popup:SetText(L"duplicate", L("duplicate_confirm", { faction = faction.name }))

		popup:Continue(L"duplicate", function (val)
			PrintTable(faction)
			VoidFactions.Faction:UpdateStaticFaction(nil, faction.name .. " (copy)", faction.tag, faction.parentFaction and faction.parentFaction.id, faction.color, faction.maxMembers, faction.logo or "", faction.inviteRequired, faction.canCaptureTerritory, faction.showOnBoard, faction.isDefaultFaction, faction.description, faction.requiredUsergroups)
		end)
		
		popup:Cancel(L"cancel")
	end

	local origPress = panel.OnMousePressed
	panel.OnMousePressed = function (s, keycode)
		origPress(s, keycode)

		if (keycode == MOUSE_RIGHT) then
			local ctxMenu = VoidUI:CreateDropdownPopup()

			local duplicate = ctxMenu:AddOption(L"duplicate", function ()
				duplicatePopup()
			end)

			ctxMenu.y = ctxMenu.y - 15
			ctxMenu.x = ctxMenu.x + 10
		end
	end

	self.rowPanel:AddRow(panel)

	if (isTemplate) then
		panel:MarginBottom(10)
	end
end

function PANEL:PerformLayout(w, h)
	self.addButton:SSetTall(40, self)
end

vgui.Register("VoidFactions.UI.FactionListSelect", PANEL, "VoidUI.BackgroundPanel")
