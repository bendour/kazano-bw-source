
local titleTall = BaseWars.ScreenScale * 50
local elementTall = BaseWars.ScreenScale * 40
local buttonTall = BaseWars.ScreenScale * 36
local bigMargin = BaseWars.ScreenScale * 10
local roundness = BaseWars.ScreenScale * 4

local PANEL = {}
function PANEL:Init()
    self.localPlayer = LocalPlayer()

    self.warning_id = -1
    self.playerName = ""
    self.oldReason = ""

    self.colors = {
        text = GetBaseWarsTheme("am_text"),
        darkText = GetBaseWarsTheme("am_darkText"),
        background = GetBaseWarsTheme("am_background"),
        contentBackground = GetBaseWarsTheme("am_contentBackground"),
        disabled = GetBaseWarsTheme("button_disabled")
    }

    self:SetSize(ScrW(), ScrH())
    self:MakePopup()

    self.Frame = self:Add("DPanel")
    self.Frame:SetSize(BaseWars.ScreenScale * 500, titleTall + elementTall + buttonTall + bigMargin * 5)
    self.Frame:Center()
    self.Frame.Paint = function(s,w,h)
        BaseWars:DrawRoundedBox(roundness, 0, 0, w, h, self.colors.background)
    end

    self.Frame.Title = self.Frame:Add("DPanel")
    self.Frame.Title:Dock(TOP)
    self.Frame.Title:SetTall(titleTall)
    self.Frame.Title.Paint = function(s,w,h)
        BaseWars:DrawRoundedBoxEx(roundness, 0, 0, w, h, self.colors.contentBackground, true, true)

        draw.SimpleText(Format(self.localPlayer:GetLang("warnings_admin_editWarningTitle"), self.playerName), "BaseWars.24", w * .5, h * .5, self.colors.text, 1, 1)
    end

    self.Frame.Middle = self.Frame:Add("DPanel")
    self.Frame.Middle:Dock(FILL)
    self.Frame.Middle:DockMargin(0, bigMargin, 0, 0)
    self.Frame.Middle.Paint = nil

    self.Frame.Middle.Entry = self.Frame.Middle:Add("BaseWars.TextEntry")
    self.Frame.Middle.Entry:Dock(FILL)
    self.Frame.Middle.Entry:DockMargin(bigMargin, bigMargin, bigMargin, bigMargin)
    self.Frame.Middle.Entry:SetColor(self.colors.contentBackground)
    self.Frame.Middle.Entry:SetTextColor(self.colors.text)
    self.Frame.Middle.Entry:SetPlaceHolder(self.localPlayer:GetLang("warnings_reasonPlaceholder"))
    self.Frame.Middle.Entry:SetPlaceHolderColor(self.colors.darkText)
    self.Frame.Middle.Entry:RequestFocus()
    self.Frame.Middle.Entry.OnEnter = function(s)
        local reason = string.Trim(s:GetText())

        if reason == "" or self.oldReason == reason then
            return
        end

        net.Start("BaseWars:Warnings:EditWarn")
            net.WriteUInt(self.warning_id, 8)
            net.WriteString(reason)
        net.SendToServer()

        self.callback(reason)
        self:Remove()
    end


    self.Frame.Bottom = self.Frame:Add("DPanel")
    self.Frame.Bottom:Dock(BOTTOM)
    self.Frame.Bottom:SetTall(buttonTall + bigMargin * 2)
    self.Frame.Bottom.Paint = nil

    self.Frame.Bottom.Confirm = self.Frame.Bottom:Add("BaseWars.Button")
    self.Frame.Bottom.Confirm:Dock(LEFT)
    self.Frame.Bottom.Confirm:DockMargin(bigMargin, bigMargin, 0, bigMargin)
    self.Frame.Bottom.Confirm:SetWide((self.Frame:GetWide() - bigMargin * 3) * .5)
    self.Frame.Bottom.Confirm:SetColor(self.colors.contentBackground, true)
    self.Frame.Bottom.Confirm.Draw = function(s,w,h)
        draw.SimpleText(self.localPlayer:GetLang("warnings_admin_editWarningButton"), "BaseWars.18", w * .5, h * .5, self.colors.text, 1, 1)
    end
    self.Frame.Bottom.Confirm.DoClick = function(s)
        local reason = string.Trim(self.Frame.Middle.Entry:GetText())

        if reason == "" or self.oldReason == reason then
            s:Disable(1.5, self.colors.disabled, s.Draw)

            return
        end

        s:ButtonSound()

        net.Start("BaseWars:Warnings:EditWarn")
            net.WriteUInt(self.warning_id, 8)
            net.WriteString(reason)
        net.SendToServer()

        self.callback(reason)
        self:Remove()
    end

    self.Frame.Bottom.Cancel = self.Frame.Bottom:Add("BaseWars.Button")
    self.Frame.Bottom.Cancel:Dock(RIGHT)
    self.Frame.Bottom.Cancel:DockMargin(0, bigMargin, bigMargin, bigMargin)
    self.Frame.Bottom.Cancel:SetWide((self.Frame:GetWide() - bigMargin * 3) * .5)
    self.Frame.Bottom.Cancel:SetColor(self.colors.contentBackground, true)
    self.Frame.Bottom.Cancel.Draw = function(s,w,h)
        draw.SimpleText(self.localPlayer:GetLang("cancel"), "BaseWars.18", w * .5, h * .5, self.colors.text, 1, 1)
    end
    self.Frame.Bottom.Cancel.DoClick = function(s)
        s:ButtonSound()

        self:Remove()
    end

    BaseWars:EaseInBlurBackground(self, 3, .9)
end

function PANEL:SetWarningID(warning_id)
    self.warning_id = warning_id
end

function PANEL:SetPlayerName(playerName)
    self.playerName = playerName
end

function PANEL:SetReason(reason)
    self.oldReason = reason

    self.Frame.Middle.Entry:SetText(reason)
end

function PANEL:SetCallback(func)
    self.callback = func
end

function PANEL:OnMousePressed()
    self:Remove()
end

function PANEL:Paint(w,h)
end

vgui.Register("BaseWars.Warnings.EditWarning", PANEL, "EditablePanel")