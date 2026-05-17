
local PANEL = {}

local strAllowedNumericCharacters = "1234567890.-"

AccessorFunc( PANEL, "m_bAllowEnter", "EnterAllowed", FORCE_BOOL )
AccessorFunc( PANEL, "m_bUpdateOnType", "UpdateOnType", FORCE_BOOL ) -- Update the convar as we type
AccessorFunc( PANEL, "m_bNumeric", "Numeric", FORCE_BOOL )
AccessorFunc( PANEL, "m_bHistory", "HistoryEnabled", FORCE_BOOL )
AccessorFunc( PANEL, "m_bDisableTabbing", "TabbingDisabled", FORCE_BOOL )

AccessorFunc( PANEL, "m_FontName", "Font" )
AccessorFunc( PANEL, "m_bBorder", "DrawBorder" )
AccessorFunc( PANEL, "m_bBackground", "PaintBackground" )
AccessorFunc( PANEL, "m_bBackground", "DrawBackground" ) -- Deprecated

AccessorFunc( PANEL, "m_colText", "TextColor" )
AccessorFunc( PANEL, "m_colHighlight", "HighlightColor" )
AccessorFunc( PANEL, "m_colCursor", "CursorColor" )

AccessorFunc( PANEL, "m_colPlaceholder", "PlaceholderColor" )
AccessorFunc( PANEL, "m_txtPlaceholder", "PlaceholderText" )

Derma_Install_Convar_Functions( PANEL )

function PANEL:Init()

	self:SetHistoryEnabled( false )
	self.History = {}
	self.HistoryPos = 0

	--
	-- We're going to draw these ourselves in
	-- the skin system - so disable them here.
	-- This will leave it only drawing text.
	--
	self:SetPaintBorderEnabled( false )
	self:SetPaintBackgroundEnabled( false )

	--
	-- These are Lua side commands
	-- Defined above using AccessorFunc
	--
	self:SetDrawBorder( true )
	self:SetPaintBackground( true )
	self:SetEnterAllowed( true )
	self:SetUpdateOnType( false )
	self:SetNumeric( false )
	self:SetAllowNonAsciiCharacters( true )

	-- Nicer default height
	self:SetTall( 20 )

	-- Clear keyboard focus when we click away
	self.m_bLoseFocusOnClickAway = true

	-- Beam Me Up Scotty
	self:SetCursor( "beam" )

	self:SetFont( "ashop_12" )
    self:SetDrawLanguageID(false)
    self:SetDrawLanguageIDAtLeft(false)
	self:SetHighlightColor(ashop.GetColor('StateOn'))
	self:SetCursorColor(ashop.GetColor('White'))

end

local focusOutline = ashop.GetColor('StateOn')
local normalOutline = ashop.GetColor('StateOff')
local lockedOutline = ashop.GetColor('StateOff')

local focusColor = ashop.GetColor('Grad1_0')
local normalColor = focusColor
local lockedColor = ashop.GetColor('Grad1_1')

function PANEL:Paint( w, h )
	if self:HasFocus() then
		draw.RoundedBox(ashop.Config.round/2, 0, 0, w, h, self.focusOutline or focusOutline)
		draw.RoundedBox(ashop.Config.round/2, 1, 1, w-2, h-2, self.focusColor or focusColor)
	elseif self:GetDisabled() then
		draw.RoundedBox(ashop.Config.round/2, 0, 0, w, h, lockedOutline)
		draw.RoundedBox(ashop.Config.round/2, 1, 1, w-2, h-2, lockedColor)
	else
		draw.RoundedBox(ashop.Config.round/2, 0, 0, w, h, self.normalOutline or normalOutline)
		draw.RoundedBox(ashop.Config.round/2, 1, 1, w-2, h-2, self.normalColor or normalColor)
	end
    local panel = self
    
    -- Hack on a hack, but this produces the most close appearance to what it will actually look if text was actually there
    if ( panel.GetPlaceholderText && panel.GetPlaceholderColor && panel:GetPlaceholderText() && panel:GetPlaceholderText():Trim() != "" && panel:GetPlaceholderColor() && ( !panel:GetText() || panel:GetText() == "" ) ) then
        local oldText = panel:GetText()
        
        local str = panel:GetPlaceholderText()
        if ( str:StartWith( "#" ) ) then str = str:sub( 2 ) end
        str = language.GetPhrase( str )
        
        panel:SetText( str )
        panel:DrawTextEntryText( panel:GetPlaceholderColor(), panel:GetHighlightColor(), panel:GetCursorColor() )
        panel:SetText( oldText )
        
        return
    end
    
    panel:DrawTextEntryText( panel:GetTextColor(), panel:GetHighlightColor(), panel:GetCursorColor() )
    
	return false
end

derma.DefineControl( "AShop_DTextEntry", "A simple TextEntry control", PANEL, "DTextEntry" )