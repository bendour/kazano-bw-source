local vgui = vgui
local IsValid = IsValid
local Color = Color
local draw = draw
local surface = surface
local derma = derma


--
-- The delay before a tooltip appears
--
local PANEL = {}

function PANEL:Init()
	self:NoClipping(true)
	self:SetDrawOnTop( true )
	self.DeleteContentsOnClose = false

	self.label = vgui.Create("DLabel", self)
	self.label:Dock(FILL)
	self.label:SetFont( "ashop_18" )
	self.label:SetText("")
	self.label:DockMargin(10, 10, 10, 10)
	self.label:SetTextColor(color_white)
end

function PANEL:SetContents( panel, bDelete )
	panel:SetParent( self )

	self.Contents = panel
	self.DeleteContentsOnClose = bDelete or false
	self.Contents:SizeToContents()
	self.Contents:SetVisible( false )
end

function PANEL:PositionTooltip()
	if ( !IsValid( self.TargetPanel ) ) then
		self:Close()
		return
	end

	local w, h = self.TargetPanel:GetSize()
	local w2, h2 = self:GetSize()
	local x, y = self.TargetPanel:LocalToScreen(w/2 - w2/2, -h2 - 10)

	self:SetPos(x, y)
end

local blue = ashop.GetColor('StateOff')
local blueR, blueG, blueB = blue:Unpack()
function PANEL:Paint( w, h )
	if !self.cachePoly then
		self.cachePoly = {
			{x = w/2 - 5, y = h },
			{x = w/2 + 5, y = h },
			{x = w/2, y = h + 5 },
		}
	end
	self:PositionTooltip()

	draw.RoundedBox(4, 0, 0, w, h, blue)

	surface.SetDrawColor(blueR, blueG, blueB)
	draw.NoTexture()
	surface.DrawPoly(self.cachePoly)

	local txtw, txth = self.label:GetTextSize()
	self:SetSize(txtw + 20, txth + 20)
end

function PANEL:SetText(txt)
	self.cachePoly = nil
	self.label:SetText(txt)
end

function PANEL:OpenForPanel( panel )
	if string.len(self.label:GetText()) == 0 then return end

	self.TargetPanel = panel

	surface.SetFont("ashop_18")
	local size_x, sizey = surface.GetTextSize(self.label:GetText())

	self:SetSize(size_x + 20, sizey + 20)
	self:PositionTooltip()
	self:SetVisible( true )
end

function PANEL:Close()
	self:Remove()
end

derma.DefineControl( "AShop_Tooltip", "", PANEL, "DPanel" )