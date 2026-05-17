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
    self.Frame:SetSize(BaseWars.ScreenScale * 350, BaseWars.ScreenScale * 200)
    self.Frame:Center()
    self.Frame.Paint = function(s, w, h)
        BaseWars:DrawRoundedBox(roundness, 0, 0, w, h, self.colors.background)
    end

    self.Frame.Bottom = self.Frame:Add("DPanel")
    self.Frame.Bottom:Dock(FILL)
    self.Frame.Bottom:DockMargin(bigMargin, bigMargin, bigMargin, bigMargin)
    self.Frame.Bottom.Paint = function(s, w, h)
        BaseWars:DrawRoundedBox(roundness, 0, 0, w, h, self.colors.background)
    end

    BaseWars:EaseInBlurBackground(self, 0, .9)
end

function PANEL:SetData(itemID, itemData)
    if not itemData then
        error("itemData is nil")
    end

    self.Frame.Bottom.Buttom = self.Frame.Bottom:Add("BaseWars.Button")
    self.Frame.Bottom.Buttom:Dock(FILL)
    self.Frame.Bottom.Buttom:DockMargin(bigMargin, bigMargin, bigMargin, bigMargin)
    self.Frame.Bottom.Buttom:SetColor(self.colors.contentBackground, true)
    self.Frame.Bottom.Buttom.Draw = function(s, w, h)
        local text = "pointshop_buyFor"
        if itemData.is_vip and not BaseWars:IsVIP(self.localPlayer) then
            text = "pointshop_vipOnly"
        end

        draw.SimpleText(Format(self.localPlayer:GetLang(text), itemData.price), "BaseWars.20", w * .5, h * .5, self.colors[(self.localPlayer:GetCredit() >= itemData.price) and "text" or "darkText"], 1, 1)
    end
    self.Frame.Bottom.Buttom.DoClick = function(s)
        if not IsValid(self.itemPanelParent) then
            self:Remove()
            return
        end

        if itemData.is_vip and not BaseWars:IsVIP(self.localPlayer) then
            s:Disable(1.5, self.colors.disabled, s.Draw)
            BaseWars:Notify("#pointshop_vipItem", NOTIFICATION_ERROR, 5)
            return
        end

        if self.localPlayer:GetCredit() < itemData.price then
            s:Disable(1.5, self.colors.disabled, s.Draw)
            BaseWars:Notify("#pointshop_tooExpensive", NOTIFICATION_ERROR, 5)
            return
        end

        net.Start("BaseWars:Pointshop:PlayerBuyCreditItem")
            net.WriteUInt(itemID, 31)
        net.SendToServer()

        -- Close the main shop menu after purchase
        if IsValid(thisPanel) then
            thisPanel:Remove()
        end
        self.itemPanelParent = panel
        self:Remove()
    end
end

function PANEL:SetItemPanelParent(panel)
    self.itemPanelParent = panel
end

function PANEL:OnMousePressed()
    self:Remove()
end

function PANEL:Paint()
end

vgui.Register("BaseWars.Pointshop.BuyItem", PANEL, "EditablePanel")