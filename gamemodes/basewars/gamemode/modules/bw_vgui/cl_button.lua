local bigMargin = BaseWars.ScreenScale * 10
local margin = BaseWars.ScreenScale * 5
local roundness = BaseWars.ScreenScale * 4

local OLD_BUTTON = {}
function OLD_BUTTON:Init()
    self._lerpAlpha = 0

    -- Initialize a safe accent color to avoid nil during first Paint
    self._accentColor = GetBaseWarsTheme("gen_accent") or GetBaseWarsTheme("bws_accent") or color_white
    self:SetAccentColor(self._accentColor)
    self:DrawSide(true, false)

    self:SetText("")
    self:SetTall(BaseWars.ScreenScale * 40)
end

function OLD_BUTTON:Paint(w, h)
    local accentColor = (IsColor(self._color) and self._color) or self._accentColor or color_white

    self._lerpAlpha = Lerp(FrameTime() * 15, self._lerpAlpha, self:LerpFunc() and 1 or 0)

    BaseWars:DrawRoundedBox(4, 0, 0, w, h, ColorAlpha(accentColor, 50 * self._lerpAlpha))

    if self._drawLeft then
        BaseWars:DrawRoundedBoxEx(4, 0, 0, margin, h, ColorAlpha(accentColor, accentColor.a * self._lerpAlpha), true, false, true, false)
    end

    if self._drawRight then
        BaseWars:DrawRoundedBoxEx(4, w - margin, 0, margin, h, ColorAlpha(accentColor, accentColor.a * self._lerpAlpha), false, true, false, true)
    end

    self:Draw(w, h)

    -- Contour animé subtil
    local a = math.floor(120 * self._lerpAlpha)
    surface.SetDrawColor((accentColor.r or 255), (accentColor.g or 255), (accentColor.b or 255), a)
    surface.DrawOutlinedRect(1, 1, w - 2, h - 2)
end

function OLD_BUTTON:Tick()
end

function OLD_BUTTON:Think()
    -- Continuously refresh accent color with robust fallback
    self._accentColor = GetBaseWarsTheme("gen_accent") or GetBaseWarsTheme("bws_accent") or self._accentColor or color_white

    self:Tick()
end

function OLD_BUTTON:LerpFunc()
    return self:IsHovered()
end

function OLD_BUTTON:Draw(w, h)
end

function OLD_BUTTON:DoClick()
    self:ButtonSound()
end

function OLD_BUTTON:SetAccentColor(color)
    -- Only accept Color values; otherwise rely on accent fallback
    self._color = IsColor(color) and color or nil
end

function OLD_BUTTON:GetAccentColor()
    return (IsColor(self._color) and self._color) or self._accentColor or color_white
end

function OLD_BUTTON:DrawSide(left, right)
    self._drawLeft = left
    self._drawRight = right
end

function OLD_BUTTON:ButtonSound()
    surface.PlaySound("bw_button.wav")
end

vgui.Register("OLD.BaseWars.Button", OLD_BUTTON, "DButton")

local BUTTON = {}
function BUTTON:Init()
    self:SetText("")
    self:SetAccentColor(GetBaseWarsTheme("gen_accent"))
    self:SetColor(Color(math.random(0, 255), math.random(0, 255), math.random(0, 255)))
    self:SetTall(BaseWars.ScreenScale * 36)
end

function BUTTON:LerpFunc()
    return self:IsHovered()
end

function BUTTON:SetAccentColor(color)
    self._accentColor = color
end

function BUTTON:GetAccentColor()
    return self._accentColor
end

function BUTTON:SetColor(color, resetLerpColor)
    self._color = color

    if resetLerpColor then
        self._lerpColor = color
    end
end

function BUTTON:GetColor()
    return self._color
end

function BUTTON:ButtonSound()
    surface.PlaySound("bw_button.wav")
end

function BUTTON:DoClick()
    self:ButtonSound()
end

function BUTTON:Disable(time, color, drawFunc)
    self:ResetCustomTempDraw()

    if self._disabledTime then
        self._disabledTime = CurTime() + time
        return
    end

    self._oldAccentColor = self:GetAccentColor()
    self._oldColor = self:GetColor()
    self._disabledTime = CurTime() + time
    self._oldDrawFunc = self.Draw

    self:SetAccentColor(color)
    self:SetColor(color)
    self.Draw = drawFunc
end

function BUTTON:Enable()
    if self._disabledTime == nil then return end

    self:SetAccentColor(self._oldAccentColor)
    self:SetColor(self._oldColor)
    self.Draw = self._oldDrawFunc

    self._oldAccentColor = nil
    self._oldColor = nil
    self._disabledTime = nil
    self._oldDrawFunc = nil
end

function BUTTON:CustomTempDraw(time, color, drawFunc)
    self:Enable()

    if self._customTempDrawTime then
        self._customTempDrawTime = CurTime() + time
        return
    end

    self._oldAccentColor = self:GetAccentColor()
    self._oldColor = self:GetColor()
    self._customTempDrawTime = CurTime() + time
    self._oldDrawFunc = self.Draw

    self:SetAccentColor(color)
    self:SetColor(color)
    self.Draw = drawFunc
end

function BUTTON:ResetCustomTempDraw()
    if self._customTempDrawTime == nil then return end

    self:SetAccentColor(self._oldAccentColor)
    self:SetColor(self._oldColor)
    self.Draw = self._oldDrawFunc

    self._oldAccentColor = nil
    self._oldColor = nil
    self._customTempDrawTime = nil
    self._oldDrawFunc = nil
end

function BUTTON:Think()
    if self._disabledTime and CurTime() >= self._disabledTime then
        self:Enable()
    end

    if self._customTempDrawTime and CurTime() >= self._customTempDrawTime then
        self:ResetCustomTempDraw()
    end

    self:Tick()
end

function BUTTON:Tick()
end

function BUTTON:Draw(w,h)
    draw.SimpleText("", "BaseWars.18", w * .5, h * .5, color_white, 1, 1)
end

function BUTTON:Paint(w,h)
    self._lerpColor = BaseWars:LerpColor(FrameTime() * 15, self._lerpColor, self:LerpFunc() and self._accentColor or self._color)

    BaseWars:DrawRoundedBox(roundness, 0, 0, w, h, self._lerpColor)

    self:Draw(w,h)
end

vgui.Register("BaseWars.Button", BUTTON, "DButton")

--[[-------------------------------------------------------------------------
    CLOSE BUTTON
---------------------------------------------------------------------------]]

local closeIcon = Material("basewars_materials/close.png", "smooth")
local buttonSize = BaseWars.ScreenScale * 40

local PANEL = {}
function PANEL:Init()
    self:SetIcon(closeIcon)

    self:SetText("")
    self:SetSize(buttonSize, buttonSize)
    self:SetColor(Color(math.Rand(0, 255), math.Rand(0, 255), math.Rand(0, 255)))
end

function PANEL:SetColor(color)
    self._color = color
    self._lerpColor = color
end

function PANEL:ButtonSound()
    surface.PlaySound("bw_button.wav")
end

function PANEL:DoClick()
    self:ButtonSound()
end

function PANEL:SetIcon(icon)
    self.icon = icon
end

function PANEL:Paint(w,h)
    self._lerpColor = BaseWars:LerpColor(FrameTime() * 15, self._lerpColor, self:IsHovered() and GetBaseWarsTheme("gen_close") or self._color)

    BaseWars:DrawRoundedBox(roundness, 0, 0, w, h, self._lerpColor)
    BaseWars:DrawMaterial(self.icon, w * .5, h * .5, buttonSize - bigMargin * 2, buttonSize - bigMargin * 2, GetBaseWarsTheme("gen_closeText"), 0)

    -- Contour animé sur survol
    self._hoverProg = Lerp(FrameTime() * 10, self._hoverProg or 0, self:IsHovered() and 1 or 0)
    local borderColor = GetBaseWarsTheme("gen_closeText") or GetBaseWarsTheme("gen_accent") or color_white
    surface.SetDrawColor(borderColor.r or 255, borderColor.g or 255, borderColor.b or 255, math.floor(80 + 100 * (self._hoverProg or 0)))
    surface.DrawOutlinedRect(1, 1, w - 2, h - 2)
end

vgui.Register("BaseWars.IconButton", PANEL, "DButton")