local roundness = BaseWars.ScreenScale * 4
local buttonTall = BaseWars.ScreenScale * 36
local bigMargin = BaseWars.ScreenScale * 10

local PANEL = {}
function PANEL:Init()
    self.localPlayer = LocalPlayer()
    self.modelFor = "everyone"
    self.colors = {
        text = GetBaseWarsTheme("bws_text") or GetBaseWarsTheme("bwm_text"),
        darkText = GetBaseWarsTheme("bws_darkText") or GetBaseWarsTheme("bwm_darkText"),
        background = GetBaseWarsTheme("bws_background") or GetBaseWarsTheme("bwm_background"),
        contentBackground = GetBaseWarsTheme("bws_contentBackground") or GetBaseWarsTheme("bwm_contentBackground"),
        disabled = GetBaseWarsTheme("button_disabled")
    }

    self:SetSize(ScrW(), ScrH())
    self:Center()
    self:MakePopup()

    self.Frame = self:Add("DPanel")
    self.Frame:SetSize(BaseWars.ScreenScale * 350, BaseWars.ScreenScale * 600)
    self.Frame:Center()
    self.Frame.Paint = nil

    self.Frame.ModelPreview = self.Frame:Add("DModelPanel")
    self.Frame.ModelPreview:Dock(FILL)
    self.Frame.ModelPreview:DockMargin(0, 0, 0, bigMargin)
    self.Frame.ModelPreview:SetFOV(50)
    self.Frame.ModelPreview:SetModel("error.mdl")
    self.Frame.ModelPreview:SetMouseInputEnabled(false)
    self.Frame.ModelPreview.oldPaint = self.Frame.ModelPreview.Paint
    self.Frame.ModelPreview.Paint = function(s,w,h)
        BaseWars:DrawRoundedBox(roundness, 0, 0, w, h, self.colors.background)
        s.oldPaint(s,w,h)
    end

    self.Frame.Bottom = self.Frame:Add("DPanel")
    self.Frame.Bottom:Dock(BOTTOM)
    self.Frame.Bottom:SetTall(buttonTall + bigMargin * 2)
    self.Frame.Bottom.Paint = function(s,w,h)
        BaseWars:DrawRoundedBox(roundness, 0, 0, w, h, self.colors.background)
    end

    BaseWars:EaseInBlurBackground(self, 0, .9)
end

function PANEL:SetData(skinID, skinData)
    self.Frame.ModelPreview:SetModel(skinData.model)

    self.Frame.Bottom.Buttom = self.Frame.Bottom:Add("BaseWars.Button")
    self.Frame.Bottom.Buttom:Dock(FILL)
    self.Frame.Bottom.Buttom:DockMargin(bigMargin, bigMargin, bigMargin, bigMargin)
    self.Frame.Bottom.Buttom:SetColor(self.colors.contentBackground, true)
    self.Frame.Bottom.Buttom.Draw = function(s,w,h)
        local text = "pointshop_buyFor"
        if skinData.is_vip and not BaseWars:IsVIP(self.localPlayer) then
            text = "pointshop_vipOnly"
        end

        draw.SimpleText(Format(self.localPlayer:GetLang(text), skinData.price), "BaseWars.20", w * .5, h * .5, self.colors[(self.localPlayer:GetPointshop() >= skinData.price and not hasSkin) and "text" or "darkText"], 1, 1)
    end
    self.Frame.Bottom.Buttom.DoClick = function(s)
        if not IsValid(self.skinPanelParent) then
            self:Remove()

            return
        end

        if skinData.is_vip and not BaseWars:IsVIP(self.localPlayer) then
            s:Disable(1.5, self.colors.disabled, s.Draw)
            BaseWars:Notify("#pointshop_vipSkin", NOTIFICATION_ERROR, 5)

            return
        end

        if self.localPlayer:GetPointshop() < skinData.price then
            s:Disable(1.5, self.colors.disabled, s.Draw)
            BaseWars:Notify("#pointshop_tooExpensive", NOTIFICATION_ERROR, 5)

            return
        end

        net.Start("BaseWars:Pointshop:PlayerBuySkin")
            net.WriteUInt(skinID, 31)
        net.SendToServer()

        self.skinPanelParent:Remove()
        self:Remove()
    end
end

function PANEL:SetSkinPanelParent(panel)
    self.skinPanelParent = panel
end

function PANEL:OnMousePressed()
    self:Remove()
end

function PANEL:Paint()
end

vgui.Register("BaseWars.Pointshop.BuySkin", PANEL, "EditablePanel")