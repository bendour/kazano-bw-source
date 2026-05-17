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
local clr = ashop.GetColor('Grad2_1')

function PANEL:Paint( w, h )
	self:PositionTooltip()
	draw.RoundedBox(4, 0, 0, w, h, self.bgclr or clr)
end

function PANEL:PositionTooltip()
	if ( !IsValid( self.TargetPanel ) ) then
		self:Close()
		return
	end

	self:InvalidateLayout( true )

	local x, y = input.GetCursorPos()
	local w, h = self:GetSize()

	local lx, ly = self.TargetPanel:LocalToScreen( 0, 0 )

	y = math.min( y, ly - h - 20 )
	if ( y < 2 ) then y = 2 end

	-- Fixes being able to be drawn off screen
	self:SetPos( math.Clamp( x - w * 0.5, 0, ScrW() - self:GetWide() ), math.Clamp( y, 0, ScrH() - self:GetTall() ))

end

function PANEL:SetContents( panel, bDelete )
	panel:SetParent( self )

	self.Contents = panel
	self.DeleteContentsOnClose = bDelete or false
	self.Contents:SizeToContents()
	self.Contents:SetVisible( false )
	self.bgclr = panel.tooltipColor
end

-- Register the new control so that we can use it by doing vgui.Create("panel_example");
derma.DefineControl( "ashop_TooltipAvatar", "", PANEL, "DTooltip" )