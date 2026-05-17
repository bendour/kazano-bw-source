local icons = {
    model = Material("basewars_materials/user.png", "smooth"),
    price = Material("basewars_materials/money.png", "smooth"),
    vip = Material("basewars_materials/scoreboard/vip.png", "smooth")
}

local roundness = BaseWars.ScreenScale * 4
local buttonTall = BaseWars.ScreenScale * 36
local elementTall = BaseWars.ScreenScale * 40
local bigMargin = BaseWars.ScreenScale * 10
local margin = BaseWars.ScreenScale * 5
local iconSize = elementTall - bigMargin * 2

local sectionTall = elementTall * 2 + bigMargin * 3

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
    self:MakePopup()

    self.Frame = self:Add("DPanel")
    self.Frame:SetSize(BaseWars.ScreenScale * 700, sectionTall * 3 + bigMargin * 5 + buttonTall)
    self.Frame:Center()
    self.Frame.Paint = nil

    self.Frame.ModelPreview = self.Frame:Add("DModelPanel")
    self.Frame.ModelPreview:Dock(LEFT)
    self.Frame.ModelPreview:SetWide(BaseWars.ScreenScale * 210)
    self.Frame.ModelPreview:DockMargin(0, 0, bigMargin, 0)
    self.Frame.ModelPreview:SetFOV(50)
    self.Frame.ModelPreview:SetModel("error.mdl")
    self.Frame.ModelPreview:SetMouseInputEnabled(false)
    self.Frame.ModelPreview.oldPaint = self.Frame.ModelPreview.Paint
    self.Frame.ModelPreview.Paint = function(s,w,h)
        BaseWars:DrawRoundedBox(roundness, 0, 0, w, h, self.colors.background)
        s.oldPaint(s,w,h)
    end

    self.Frame.Right = self.Frame:Add("DPanel")
    self.Frame.Right:Dock(FILL)
    self.Frame.Right.Paint = nil

    self.Frame.Right.Model = self.Frame.Right:Add("DPanel")
    self.Frame.Right.Model:Dock(TOP)
    self.Frame.Right.Model:SetTall(sectionTall)
    self.Frame.Right.Model.Paint = function(s,w,h)
        BaseWars:DrawRoundedBox(roundness, 0, 0, w, h, self.colors.background)
        BaseWars:DrawRoundedBox(roundness, bigMargin, bigMargin, elementTall, elementTall, self.colors.contentBackground)
        BaseWars:DrawMaterial(icons["model"], bigMargin * 2, bigMargin * 2, iconSize, iconSize, self.colors.text)
        draw.SimpleText(self.localPlayer:GetLang("pointshop_title_model"), "BaseWars.20", bigMargin * 2 + elementTall, bigMargin + elementTall * .5, self.colors.text, 0, 1)
    end

    self.Frame.Right.Model.TextEntry = self.Frame.Right.Model:Add("BaseWars.TextEntry")
    self.Frame.Right.Model.TextEntry:Dock(BOTTOM)
    self.Frame.Right.Model.TextEntry:DockMargin(bigMargin, bigMargin, bigMargin, bigMargin)
    self.Frame.Right.Model.TextEntry:SetTall(elementTall)
    self.Frame.Right.Model.TextEntry:SetColor(self.colors.contentBackground)
    self.Frame.Right.Model.TextEntry:SetTextColor(self.colors.text)
    self.Frame.Right.Model.TextEntry:SetPlaceHolder(self.localPlayer:GetLang("pointshop_textEntry_model"))
    self.Frame.Right.Model.TextEntry:SetPlaceHolderColor(self.colors.darkText)
    self.Frame.Right.Model.TextEntry.OnChange = function(s, text)
        if string.Right(text, 4) != ".mdl" then
            text = "error.mdl"
        end

        self.Frame.ModelPreview:SetModel(text)
    end

    self.Frame.Right.Price = self.Frame.Right:Add("DPanel")
    self.Frame.Right.Price:Dock(TOP)
    self.Frame.Right.Price:DockMargin(0, bigMargin, 0, 0)
    self.Frame.Right.Price:SetTall(sectionTall)
    self.Frame.Right.Price.Paint = function(s,w,h)
        BaseWars:DrawRoundedBox(roundness, 0, 0, w, h, self.colors.background)
        BaseWars:DrawRoundedBox(roundness, bigMargin, bigMargin, elementTall, elementTall, self.colors.contentBackground)
        BaseWars:DrawMaterial(icons["price"], bigMargin * 2, bigMargin * 2, iconSize, iconSize, self.colors.text)
        draw.SimpleText(self.localPlayer:GetLang("pointshop_title_price"), "BaseWars.20", bigMargin * 2 + elementTall, bigMargin + elementTall * .5, self.colors.text, 0, 1)
    end

    self.Frame.Right.Price.TextEntry = self.Frame.Right.Price:Add("BaseWars.TextEntry")
    self.Frame.Right.Price.TextEntry:Dock(BOTTOM)
    self.Frame.Right.Price.TextEntry:DockMargin(bigMargin, bigMargin, bigMargin, bigMargin)
    self.Frame.Right.Price.TextEntry:SetTall(elementTall)
    self.Frame.Right.Price.TextEntry:SetColor(self.colors.contentBackground)
    self.Frame.Right.Price.TextEntry:SetTextColor(self.colors.text)
    self.Frame.Right.Price.TextEntry:SetPlaceHolder(self.localPlayer:GetLang("pointshop_textEntry_price"))
    self.Frame.Right.Price.TextEntry:SetPlaceHolderColor(self.colors.darkText)
    self.Frame.Right.Price.TextEntry:SetNumeric(true)
    self.Frame.Right.Price.TextEntry:SetText("1000")
    self.Frame.Right.Price.TextEntry.OnChange = function(s, text)
        local num = tonumber(text)

        if not num then
            s:SetText("0")

            return
        end

        for i = 1, #text do
            if text[i] == "." then
                s:SetText(math.floor(num))

                break
            end
        end

        if num < 0 or text == "-0" then
            s:SetText("0")
        end

        if num > BASEWARS_MAX_I32 then
            s:SetText(BASEWARS_MAX_I32)
        end
    end

    self.Frame.Right.VIP = self.Frame.Right:Add("DPanel")
    self.Frame.Right.VIP:Dock(TOP)
    self.Frame.Right.VIP:DockMargin(0, bigMargin, 0, 0)
    self.Frame.Right.VIP:SetTall(sectionTall)
    self.Frame.Right.VIP.Paint = function(s,w,h)
        BaseWars:DrawRoundedBox(roundness, 0, 0, w, h, self.colors.background)
        BaseWars:DrawRoundedBox(roundness, bigMargin, bigMargin, elementTall, elementTall, self.colors.contentBackground)
        BaseWars:DrawMaterial(icons["vip"], bigMargin * 2, bigMargin * 2, iconSize, iconSize, self.colors.text)
        draw.SimpleText(self.localPlayer:GetLang("pointshop_title_vip"), "BaseWars.20", bigMargin * 2 + elementTall, bigMargin + elementTall * .5, self.colors.text, 0, 1)
    end

    self.Frame.Right.VIP.Bottom = self.Frame.Right.VIP:Add("DPanel")
    self.Frame.Right.VIP.Bottom:Dock(BOTTOM)
    self.Frame.Right.VIP.Bottom:DockMargin(bigMargin, 0, bigMargin, bigMargin)
    self.Frame.Right.VIP.Bottom:SetTall(elementTall)
    self.Frame.Right.VIP.Bottom.Paint = nil

    local buttonWide = (self.Frame:GetWide() - self.Frame.ModelPreview:GetWide() - bigMargin * 3 - margin) * .5
    self.Frame.Right.VIP.Bottom.Everyone = self.Frame.Right.VIP.Bottom:Add("BaseWars.Button")
    self.Frame.Right.VIP.Bottom.Everyone:Dock(LEFT)
    self.Frame.Right.VIP.Bottom.Everyone:SetWide(buttonWide)
    self.Frame.Right.VIP.Bottom.Everyone:SetColor(self.colors.contentBackground, true)
    self.Frame.Right.VIP.Bottom.Everyone.Draw = function(s,w,h)
        draw.SimpleText(self.localPlayer:GetLang("pointshop_everyone"), "BaseWars.18", w * .5, h * .5, self.colors.text, 1, 1)
    end
    self.Frame.Right.VIP.Bottom.Everyone.LerpFunc = function(s)
        return s:IsHovered() or self.modelFor == "everyone"
    end
    self.Frame.Right.VIP.Bottom.Everyone.DoClick = function(s)
        if self.modelFor == "everyone" then return end

        s:ButtonSound()
        self.modelFor = "everyone"
    end

    self.Frame.Right.VIP.Bottom.VIP = self.Frame.Right.VIP.Bottom:Add("BaseWars.Button")
    self.Frame.Right.VIP.Bottom.VIP:Dock(RIGHT)
    self.Frame.Right.VIP.Bottom.VIP:SetWide(buttonWide)
    self.Frame.Right.VIP.Bottom.VIP:SetColor(self.colors.contentBackground, true)
    self.Frame.Right.VIP.Bottom.VIP.Draw = function(s,w,h)
        draw.SimpleText(self.localPlayer:GetLang("pointshop_vip"), "BaseWars.18", w * .5, h * .5, self.colors.text, 1, 1)
    end
    self.Frame.Right.VIP.Bottom.VIP.LerpFunc = function(s)
        return s:IsHovered() or self.modelFor == "vip"
    end
    self.Frame.Right.VIP.Bottom.VIP.DoClick = function(s)
        if self.modelFor == "vip" then return end

        s:ButtonSound()
        self.modelFor = "vip"
    end

    self.Frame.Right.SubmitModel = self.Frame.Right:Add("DPanel")
    self.Frame.Right.SubmitModel:Dock(BOTTOM)
    self.Frame.Right.SubmitModel:SetTall(buttonTall + bigMargin * 2)
    self.Frame.Right.SubmitModel.Paint = function(s,w,h)
        BaseWars:DrawRoundedBox(roundness, 0, 0, w, h, self.colors.background)
    end

    self.Frame.Right.SubmitModel.Buttom = self.Frame.Right.SubmitModel:Add("BaseWars.Button")
    self.Frame.Right.SubmitModel.Buttom:Dock(FILL)
    self.Frame.Right.SubmitModel.Buttom:DockMargin(bigMargin, bigMargin, bigMargin, bigMargin)
    self.Frame.Right.SubmitModel.Buttom:SetColor(self.colors.contentBackground, true)
    self.Frame.Right.SubmitModel.Buttom.Draw = function(s,w,h)
        local text = "pointshop_addSkin"

        if self.Frame.ModelPreview:GetModel() == "error.mdl" then
            text = "pointshop_invalidModel"
        end

        if not tonumber(self.Frame.Right.Price.TextEntry:GetText()) then
            text = "pointshop_invalidPrice"
        end

        draw.SimpleText(self.localPlayer:GetLang(text), "BaseWars.18", w * .5, h * .5, self.colors.text, 1, 1)
    end
    self.Frame.Right.SubmitModel.Buttom.DoClick = function(s)
        local model = self.Frame.ModelPreview:GetModel()
        local price = tonumber(self.Frame.Right.Price.TextEntry:GetText())
        local isVIP = self.modelFor == "vip"

        if model == "error.mdl" then
            s:Disable(1.5, self.colors.disabled, s.Draw)

            return
        end

        if not price then
            s:Disable(1.5, self.colors.disabled, s.Draw)

            return
        end

        net.Start("BaseWars:Pointshop:AddSkin")
            net.WriteString(model)
            net.WriteUInt(price, 31)
            net.WriteBool(isVIP)
        net.SendToServer()

        self:Remove()
    end

    BaseWars:EaseInBlurBackground(self, 0, .9)
end

function PANEL:OnMousePressed()
    self:Remove()
end

function PANEL:Paint()
end

vgui.Register("BaseWars.Pointshop.AddSkin", PANEL, "EditablePanel")