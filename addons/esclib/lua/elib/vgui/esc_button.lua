local PANEL = {}

AccessorFunc(PANEL, "m_nBorderRadius", "BorderRadius", FORCE_NUMBER)
AccessorFunc(PANEL, "m_sButtonText", "ButtonText", FORCE_STRING)
AccessorFunc(PANEL, "m_cTextAlignX", "TextAlignX", FORCE_NUMBER)
AccessorFunc(PANEL, "m_cTextAlignY", "TextAlignY", FORCE_NUMBER)
AccessorFunc(PANEL, "icon_size", "IconSize", FORCE_NUMBER)
AccessorFunc(PANEL, "icon_offset", "IconOffset", FORCE_NUMBER)
AccessorFunc(PANEL, "m_matIcon", "Icon")

AccessorFunc(PANEL, "bg_col", "BackgroundColor", FORCE_COLOR)
AccessorFunc(PANEL, "bg_col_hover", "BackgroundHoverColor", FORCE_COLOR)

AccessorFunc(PANEL, "text_col", "TextColor", FORCE_COLOR)
AccessorFunc(PANEL, "text_col_hover", "TextHoverColor", FORCE_COLOR)

AccessorFunc(PANEL, "icon_col", "IconColor", FORCE_COLOR)
AccessorFunc(PANEL, "icon_col_hover", "IconHoverColor", FORCE_COLOR)

function PANEL:Init()
    self:SetMouseInputEnabled(true)
    self:SetEnabled(true)

    self.skin = esclib.addon:GetCurrentSkin()
    self.colors = self.skin.colors
    self.maskcol = Color(13, 13, 13, 220)

    self:SetTextAlignX(TEXT_ALIGN_CENTER)
    self:SetTextAlignY(TEXT_ALIGN_CENTER)

    self:SetText("")
    self:SetIcon(nil)
    self:SetIconSize(1)
    self:SetIconOffset(esclib:AdaptiveSize(8))

    self:SetBorderRadius(0)
    self:SetButtonText("SetButtonText")

    self:SetCursor("hand")
    self:SetFont(esclib:AdaptiveFont("esclib", 24, 500))

    self:SetBackgroundColor(self.colors.button.main)
    self:SetBackgroundHoverColor(self.colors.button.hover)

    self:SetTextColor(self.colors.button.text)
    self:SetTextHoverColor(self.colors.button.text_hover)

	self:SetIconColor(self.colors.button.text)
    self:SetIconHoverColor(self.colors.button.text_hover)

    function self.SetText(pnl, text)
        self:SetButtonText(text)
    end
end

function PANEL:IsDown()
    return self.Depressed
end

function PANEL:PaintBackground(w,h)
	local active = self:IsEnabled()
	local hovered = self:IsHovered() and active
    draw.RoundedBox(self:GetBorderRadius(), 1, 1, w - 2, h - 2, hovered and self.bg_col_hover or self.bg_col)
end

function PANEL:Paint(w, h)
    self:SetCursor("hand")
    local active = self:IsEnabled()
    local hovered = self:IsHovered() and active
    self:PaintBackground(w,h)
    
    local tax = self:GetTextAlignX()
    local text = self:GetButtonText()
    local font = self:GetFont()
    local icon = self:GetIcon()
    local iconSize = h * (0.5 * self.icon_size) -- Размер иконки
    surface.SetFont(font)
    local textWidth, textHeight = surface.GetTextSize(text)

	local icon_color = hovered and self.icon_col_hover or self.icon_col

    if text == "" then
        if icon then
            local iconOffsetX = (w - iconSize) * 0.5
            local iconOffsetY = (h - iconSize) * 0.5 + 1
            surface.SetDrawColor(icon_color.r, icon_color.g, icon_color.b, icon_color.a)
            surface.SetMaterial(icon)
            surface.DrawTexturedRect(iconOffsetX, iconOffsetY, iconSize, iconSize)
        end
    else
        if icon then
            local totalWidth = textWidth + iconSize + 5
            local iconOffsetX, textOffsetX
            
            if tax == TEXT_ALIGN_LEFT then
                iconOffsetX = 10
                textOffsetX = iconOffsetX + iconSize + self.icon_offset
            elseif tax == TEXT_ALIGN_RIGHT then
                textOffsetX = w - 10 - textWidth
                iconOffsetX = textOffsetX - iconSize - self.icon_offset
            else
                local startX = (w - totalWidth) * 0.5
                iconOffsetX = startX
                textOffsetX = startX + iconSize + self.icon_offset
            end
            
            local iconOffsetY = (h - iconSize) * 0.5 + 1
            
            surface.SetDrawColor(icon_color.r, icon_color.g, icon_color.b, icon_color.a)
            surface.SetMaterial(icon)
            surface.DrawTexturedRect(iconOffsetX, iconOffsetY, iconSize, iconSize)
            draw.SimpleText(text, font, textOffsetX, h * 0.5, hovered and self.text_col_hover or self.text_col, TEXT_ALIGN_LEFT, self:GetTextAlignY())
        else
            local textOffsetX
            if tax == TEXT_ALIGN_LEFT then
                textOffsetX = 10
            elseif tax == TEXT_ALIGN_RIGHT then
                textOffsetX = w - 10 - textWidth
            else
                textOffsetX = w * 0.5
            end
            draw.SimpleText(text, font, textOffsetX, h * 0.5, hovered and self.text_col_hover or self.text_col, tax, self:GetTextAlignY())
        end
    end

    if not active then
        self:SetCursor("no")
        draw.RoundedBox(self:GetBorderRadius(), 0, 0, w, h, self.maskcol)
    end
end

function PANEL:SetIcon(material)
    self.m_matIcon = material
end

function PANEL:GetIcon()
    return self.m_matIcon
end

derma.DefineControl("esclib.button", "A button for esclib", PANEL, "DLabel")
