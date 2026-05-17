local elementTall = BaseWars.ScreenScale * 40
local bigMargin = BaseWars.ScreenScale * 10
local margin = BaseWars.ScreenScale * 5
local roundness = BaseWars.ScreenScale * 4
local delay = .25

local minWidth = BaseWars.ScreenScale * 220
local PANEL = {}
function PANEL:Init()
    self.localPlayer = LocalPlayer()
    self.text = "text"
    self.time = CurTime() + 10

    self:SetAlpha(0)
    self:AlphaTo(255, delay, 0, nil)

    self:SetSize(minWidth, elementTall * 2 + bigMargin)
    self:SetPos((ScrW() - self:GetWide()) * .5, elementTall)

    self.colors = {
        background = GetBaseWarsTheme("popup_background"),
        text = GetBaseWarsTheme("popup_text"),
    }

    surface.PlaySound("bw_annoncement.wav")
end

function PANEL:SetText(text)
    self.text = text

    self.textW, self.textH = BaseWars:GetTextSize(text, "BaseWars.20")

    self.textW = self.textW + bigMargin * 2
    if self.textW > minWidth then
        self:SetWide(self.textW)
        self:SetPos((ScrW() - self:GetWide()) * .5, elementTall)
    end
end

function PANEL:Think()
    if CurTime() > self.time and not self.closing then
        self.closing = true

        self:AlphaTo(0, delay, 0, function()
            if IsValid(self) then
                self:Remove()
            end
        end)
    end
end

function PANEL:Paint(w,h)
    BaseWars:DrawRoundedBox(roundness, (w - minWidth) * .5, 0, minWidth, elementTall, self.colors.background)
    draw.SimpleText(self.localPlayer:GetLang("announcement_title"):format(math.abs(math.ceil(math.max(self.time - CurTime()), 0))), "BaseWars.24", w * .5, h * .2, self.colors.text, 1, 1)

    BaseWars:DrawRoundedBox(roundness, (w - self.textW) * .5, h * .5 + margin, self.textW, elementTall, self.colors.background)
    draw.SimpleText(self.text, "BaseWars.20", w * .5, h * .77, self.colors.text, 1, 1)
end

vgui.Register("BaseWars.AnnouncementPanel", PANEL, "DPanel")