local L = VoidFactions.Lang.GetPhrase
local sc = VoidUI.Scale

local PANEL = {}

function PANEL:Init()
	self:MakePopup()
	self:SetDraggable(false)
	self:SetTitle("")
	self:ShowCloseButton(false)

	local factions = {}
	for k, v in pairs(VoidFactions.LoadedFactions) do
		if (v.isDefaultFaction) then
			factions[#factions + 1] = v
		end
	end

	local titlePanel = self:Add("Panel")
	titlePanel:Dock(TOP)
	titlePanel.Paint = function (s, w, h)
		draw.RoundedBox(10, 0, 0, w, h, VoidUI.Colors.Primary)

		draw.SimpleText(string.upper(L"chooseFaction"), "VoidUI.R32", w/2, h/2, VoidUI.Colors.Gray, TEXT_ALIGN_CENTER, TEXT_ALIGN_CENTER)
	end

	self.titlePanel = titlePanel

	local cardContainer = self:Add("DHorizontalScroller")
	cardContainer:Dock(FILL)
	cardContainer:MarginTop(40)
	cardContainer:MarginBottom(35)
	cardContainer:SetOverlap(-sc(30))

	cardContainer.btnLeft.Paint = function (self, w, h)
		local paintColor = self:IsHovered() and VoidUI.Colors.GrayText or VoidUI.Colors.InputLight
		draw.RoundedBox(6, 0, 0, w, h, paintColor)

		draw.SimpleText("<", "VoidUI.B26", w/2, h/2, VoidUI.Colors.Gray, TEXT_ALIGN_CENTER, TEXT_ALIGN_CENTER)
	end

	cardContainer.btnRight.Paint = function (self, w, h)
		local paintColor = self:IsHovered() and VoidUI.Colors.GrayText or VoidUI.Colors.InputLight
		draw.RoundedBox(6, 0, 0, w, h, paintColor)

		draw.SimpleText(">", "VoidUI.B26", w/2, h/2, VoidUI.Colors.Gray, TEXT_ALIGN_CENTER, TEXT_ALIGN_CENTER)
	end

	local origPerformLayout = cardContainer.PerformLayout
	function cardContainer:PerformLayout(w, h)
		origPerformLayout(self, w, h)

		self.btnLeft:SSetSize(30, 30)
		self.btnRight:SSetSize(30, 30)

		self.btnLeft.y = self.btnLeft.y - 15
		self.btnRight.y = self.btnRight.y - 15
		self.btnRight.x = self.btnRight.x - 15
	end

	local factionCount = #factions
	if (factionCount == 2) then
		-- Ugly workaround
		cardContainer:MarginLeft(200)
	end

	local selectButton = self:Add("VoidUI.Button")

	self.selectedFaction = nil

	if (factionCount == 0) then
		VoidLib.Notify(L"error", L"noDefaultFactions", VoidUI.Colors.Red, 20)
		self:Remove()
		return
	end

	-- Select automatically the first one
	if (factionCount == 1) then
		net.Start("VoidFactions.FactionSelection.Select")
			net.WriteUInt(factions[1].id, 20)
		net.SendToServer()
		self:Remove()
	end

	for _, faction in pairs(factions) do
		local card = cardContainer:Add("DButton")
		card:SetText("")
		card:SetWide(356)

		local iconMat = nil
		VoidLib.FetchImage(faction.logo or "none", function (mat)
			if (!mat) then return end

			iconMat = mat
		end)

		local logoSize = sc(215)

		local facSelectedColor = Color(faction.color.r, faction.color.g, faction.color.b, 60)
		local facHoveredColor = Color(faction.color.r, faction.color.g, faction.color.b, 1)

		local this = self

		local wrappedDesc = VoidUI.TextWrap(faction.description, "VoidUI.R20", sc(260))

		card.Paint = function (self, w, h)
			draw.RoundedBox(8, 0, 0, w, h, faction.color)
			draw.RoundedBox(8, 3, 3, w-6, h-6, VoidUI.Colors.Background)
			draw.RoundedBox(8, 3, 3, w-6, h-6, (this.selectedFaction == faction and facSelectedColor) or (self:IsHovered() and facHoveredColor) or VoidUI.Colors.Primary)

			draw.SimpleText(faction.name, "VoidUI.R32", w/2, sc(15), VoidUI.Colors.Gray, TEXT_ALIGN_CENTER, TEXT_ALIGN_TOP)

			if (iconMat) then
				surface.SetDrawColor(VoidUI.Colors.White)
				surface.SetMaterial(iconMat)
				surface.DrawTexturedRect(w/2-logoSize/2, sc(65), logoSize, logoSize)
			end

			draw.DrawText(wrappedDesc, "VoidUI.R24", w/2, sc(315), VoidUI.Colors.Gray, TEXT_ALIGN_CENTER, TEXT_ALIGN_CENTER)

		end

		card.DoClick = function ()
			this.selectedFaction = faction
			selectButton:SetEnabled(true)
		end

		cardContainer:AddPanel(card)
	end

	selectButton:Dock(BOTTOM)

	selectButton:MarginBottom(25)
	selectButton:MarginSides(460)
	selectButton:SSetTall(60)

	selectButton.rounding = 32

	selectButton:SetText(L"select")

	selectButton:SetColor(VoidUI.Colors.Green, VoidUI.Colors.Background)
	selectButton:SetEnabled(false)

	selectButton.DoClick = function ()
		-- Send data to server
		net.Start("VoidFactions.FactionSelection.Select")
			net.WriteUInt(self.selectedFaction.id, 20)
		net.SendToServer()
		self:Remove()
	end
end

function PANEL:PerformLayout(w, h)
	self:SDockPadding(35, 35, 35, 20)
	self.titlePanel:SSetTall(60)
end

function PANEL:Paint(w, h)
	surface.SetDrawColor(VoidUI.Colors.Background)
	surface.DrawRect(0, 0, w, h)
end

vgui.Register("VoidFactions.UI.FactionSelection", PANEL, "DFrame")
