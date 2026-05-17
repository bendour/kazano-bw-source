local thisPanel
local icons = {
    ["loading"] = {
        icon = Material("basewars_materials/loading.png", "smooth"),
        size = BaseWars.ScreenScale * 150
    },
    ["trash_all"] = {
        icon = Material("basewars_materials/trash.png", "smooth"),
        size = BaseWars.ScreenScale * 20
    },
    ["trash_warn"] = {
        icon = Material("basewars_materials/trash.png", "smooth"),
        size = BaseWars.ScreenScale * 18
    },
    ["edit"] = {
        icon = Material("basewars_materials/edit.png", "smooth"),
        size = BaseWars.ScreenScale * 18
    },
    ["plus"] = {
        icon = Material("basewars_materials/plus.png", "smooth"),
        size = BaseWars.ScreenScale * 20
    }
}

local warnTall = BaseWars.ScreenScale * 60
local elementTall = BaseWars.ScreenScale * 40
local buttonTall = BaseWars.ScreenScale * 36
local bigMargin = BaseWars.ScreenScale * 10
local margin = BaseWars.ScreenScale * 5
local roundness = BaseWars.ScreenScale * 4

local PANEL = {}
function PANEL:Init()
    self.localPlayer = LocalPlayer()
    self.activePlayer = "0"
    self.canRequestData = true
    self.hasData = 0
    self.data = {}
    self.colors = {
        accent = GetBaseWarsTheme("gen_accent"),
        text = GetBaseWarsTheme("am_text"),
        darkText = GetBaseWarsTheme("am_darkText"),
        contentBackground = GetBaseWarsTheme("am_contentBackground"),
        contentBackground2 = GetBaseWarsTheme("am_contentBackground2"),
        disabled = GetBaseWarsTheme("button_disabled"),
        green = GetBaseWarsTheme("button_green")
    }

    thisPanel = self

    self.SideBar = self:Add("DPanel")
    self.SideBar:Dock(RIGHT)
    self.SideBar:DockMargin(bigMargin, bigMargin, bigMargin, bigMargin)
    self.SideBar:SetWide(BaseWars.ScreenScale * 300)
    self.SideBar.minus = 0
    self.SideBar.Paint = function(s,w,h)
        BaseWars:DrawRoundedBox(roundness, 0, 0, w, h - s.minus, self.colors.contentBackground)
    end

    self.SideBar.Title = self.SideBar:Add("DPanel")
    self.SideBar.Title:Dock(TOP)
    self.SideBar.Title:DockMargin(bigMargin, bigMargin, bigMargin, 0)
    self.SideBar.Title:SetTall(elementTall)
    self.SideBar.Title.Paint = function(s,w,h)
        BaseWars:DrawRoundedBox(roundness, 0, 0, w, h, self.colors.contentBackground2)

        draw.SimpleText(self.localPlayer:GetLang("warnings_admin_allPlayers"), "BaseWars.20", w * .5, h * .5, self.colors.text, 1, 1)
    end

    self.SideBar.Scroll = self.SideBar:Add("DScrollPanel")
    self.SideBar.Scroll:Dock(FILL)
    self.SideBar.Scroll:DockMargin(bigMargin, bigMargin, bigMargin, bigMargin)
    self.SideBar.Scroll:GetVBar():SetWide(0)

    self.SideBar.Search = self.SideBar:Add("DPanel")
    self.SideBar.Search:Dock(BOTTOM)
    self.SideBar.Search:SetTall(elementTall + buttonTall + bigMargin * 3)
    self.SideBar.Search.Paint = function(s,w,h)
        BaseWars:DrawRoundedBox(roundness, 0, 0, w, h, self.colors.contentBackground)
    end

    self.SideBar.Search.Entry = self.SideBar.Search:Add("BaseWars.TextEntry")
    self.SideBar.Search.Entry:Dock(TOP)
    self.SideBar.Search.Entry:DockMargin(bigMargin, bigMargin, bigMargin, 0)
    self.SideBar.Search.Entry:SetTall(elementTall)
    self.SideBar.Search.Entry:SetColor(self.colors.contentBackground2)
    self.SideBar.Search.Entry:SetTextColor(self.colors.text)
    self.SideBar.Search.Entry:SetPlaceHolder(self.localPlayer:GetLang("warnings_search"))
    self.SideBar.Search.Entry:SetPlaceHolderColor(self.colors.darkText)

    self.SideBar.Search.Button = self.SideBar.Search:Add("OLD.BaseWars.Button")
    self.SideBar.Search.Button:Dock(BOTTOM)
    self.SideBar.Search.Button:DockMargin(bigMargin, 0, bigMargin, bigMargin)
    self.SideBar.Search.Button:SetTall(buttonTall)
    self.SideBar.Search.Button:DrawSide(true, true)
    self.SideBar.Search.Button.Draw = function(s,w,h)
        draw.SimpleText(self.localPlayer:GetLang("search"), "BaseWars.18", w * .5, h * .5, self.colors.text, 1, 1)
    end
    self.SideBar.Search.Button.DoClick = function(s)
        local target_id = string.Trim(self.SideBar.Search.Entry:GetText())

        if target_id == "" then
            return
        end

        if not self.canRequestData then
            return
        end

        local target_id64 = BaseWars:GetSteamID64(target_id)
        if target_id64 == "none" then
            return
        end

        s:ButtonSound()

        self.Warnings:Clear()
        self:RequestData(target_id64)
    end

    self.SideBar.minus = self.SideBar.Search:GetTall() + bigMargin

    for _, ply in player.Iterator() do
        local playerPanel = self.SideBar.Scroll:Add("OLD.BaseWars.Button")
        playerPanel:Dock(TOP)
        playerPanel:DockMargin(0, 0, 0, margin)
        playerPanel:SetTall(buttonTall)
        playerPanel:DrawSide(true, true)
        playerPanel.Draw = function(s,w,h)
            draw.SimpleText(ply:Name(), "BaseWars.18", w * .5, h * .5, self.colors.text, 1, 1)
        end
        playerPanel.LerpFunc = function(s)
            return s:IsHovered() or self.activePlayer == ply:SteamID64()
        end
        playerPanel.DoClick = function(s)
            if not self.canRequestData then
                return
            end

            s:ButtonSound()

            self.Warnings:Clear()
            self:RequestData(ply:SteamID64())
        end
        playerPanel.Tick = function(s)
            if not IsValid(ply) then
                s:Remove()
            end
        end
    end

    self.Warnings = self:Add("DPanel")
    self.Warnings:Dock(FILL)
    self.Warnings:DockMargin(bigMargin, bigMargin, 0, bigMargin)
    self.Warnings.Paint = function(s,w,h)
        if not self.hasData then
            BaseWars:DrawMaterial(icons["loading"].icon, w * .5, h * .5, icons["loading"].size, icons["loading"].size, self.colors.accent, -CurTime() * 540 % 360)
        end
    end
end

function PANEL:Build(data)
    self.data = data

    BaseWars:RequestSteamName(self.activePlayer, function(plyName)
        self.canRequestData = true
        self.hasData = true

        self.Warnings:Clear()

        self.Warnings.Title = self.Warnings:Add("DPanel")
        self.Warnings.Title:Dock(TOP)
        self.Warnings.Title:DockMargin(0, 0, 0, bigMargin)
        self.Warnings.Title:SetTall(elementTall)
        self.Warnings.Title.Paint = nil

        self.Warnings.Title.WarningsOf = self.Warnings.Title:Add("DPanel")
        self.Warnings.Title.WarningsOf:Dock(FILL)
        self.Warnings.Title.WarningsOf.Paint = function(s,w,h)
            BaseWars:DrawRoundedBox(roundness, 0, 0, w, h, self.colors.contentBackground)

            draw.SimpleText(Format(self.localPlayer:GetLang("warnings_admin_warningsOf"), plyName, table.Count(self.data)), "BaseWars.20", w * .5, h * .5, self.colors.text, 1, 1)
        end

        self.Warnings.Title.AddWarning = self.Warnings.Title:Add("BaseWars.Button")
        self.Warnings.Title.AddWarning:Dock(RIGHT)
        self.Warnings.Title.AddWarning:DockMargin(margin, 0, 0, 0)
        self.Warnings.Title.AddWarning:SetWide(elementTall * 2)
        self.Warnings.Title.AddWarning:SetColor(self.colors.contentBackground, true)
        self.Warnings.Title.AddWarning.Draw = function(s,w,h)
            BaseWars:DrawMaterial(icons["plus"].icon, w * .5, h * .5, icons["plus"].size, icons["plus"].size, self.colors.text, 0)
        end
        self.Warnings.Title.AddWarning.DoClick = function(s)
            s:ButtonSound()

            self.addWarnPanel = vgui.Create("BaseWars.Warnings.AddWarning")
            self.addWarnPanel:SetPlayerName(plyName)
            self.addWarnPanel:SetPlayerID(self.activePlayer)
            self.addWarnPanel.Think = function(thinkSelf)
                if not IsValid(self) then
                    thinkSelf:Remove()
                end
            end
        end

        self.Warnings.Title.DeleteAllWarning = self.Warnings.Title:Add("BaseWars.Button")
        self.Warnings.Title.DeleteAllWarning:Dock(RIGHT)
        self.Warnings.Title.DeleteAllWarning:DockMargin(margin, 0, 0, 0)
        self.Warnings.Title.DeleteAllWarning:SetWide(elementTall * 2)
        self.Warnings.Title.DeleteAllWarning:SetColor(self.colors.contentBackground, true)
        self.Warnings.Title.DeleteAllWarning.Draw = function(s,w,h)
            BaseWars:DrawMaterial(icons["trash_all"].icon, w * .5, h * .5, icons["trash_all"].size, icons["trash_all"].size, self.colors.text, 0)
        end
        self.Warnings.Title.DeleteAllWarning.DoClick = function(s)
            if table.Count(self.data) == 0 then
                s:Disable(1.5, self.colors.disabled, s.Draw)

                return
            end

            s:ButtonSound()

            self.deleteAllConfirmPopup = vgui.Create("BaseWars.Popup")
            self.deleteAllConfirmPopup:SetTitle("#warnings_admin_deleteAllWarnings")
            self.deleteAllConfirmPopup:SetText("#warnings_admin_deleteAllWarningsFrom", #data, plyName)
            self.deleteAllConfirmPopup:SetConfirm(self.localPlayer:GetLang("warnings_admin_deleteAllButton"), function()
                self.Warnings.Scroll:GetCanvas():Clear()
                self.data = {}

                net.Start("BaseWars:Warnings:DeleteAllWarn")
                    net.WriteString(self.activePlayer)
                net.SendToServer()

                s:CustomTempDraw(1.5, self.colors.green, s.Draw)
            end)
            self.deleteAllConfirmPopup.Think = function(thinkSelf)
                if not IsValid(self) then
                    thinkSelf:Remove()
                end
            end
        end

        self.Warnings.Scroll = self.Warnings:Add("DScrollPanel")
        self.Warnings.Scroll:Dock(FILL)
        self.Warnings.Scroll:GetVBar():SetWide(0)

        local warnedBy = self.localPlayer:GetLang("warnings_warnInfos", "warnedBy")
        local warnDate = self.localPlayer:GetLang("warnings_warnInfos", "warnDate")
        local warnID = self.localPlayer:GetLang("warnings_warnInfos", "warnID")
        local warnReason = self.localPlayer:GetLang("warnings_warnInfos", "warnReason")

        local warnedByW, _ = BaseWars:GetTextSize(warnedBy, "BaseWars.18")
        local warnReasonW, _ = BaseWars:GetTextSize(warnReason, "BaseWars.18")

        local leftMargin = math.max(warnedByW, warnReasonW) + bigMargin * 2

        for k, warnData in ipairs(self.data) do
            local date = os.date("%H:%M:%S - %d/%m/%Y", warnData.date)
            local reason = warnData.reason

            BaseWars:RequestSteamName(warnData.admin_id64)

            local warnPanel = self.Warnings.Scroll:Add("DPanel")
            warnPanel:Dock(TOP)
            warnPanel:DockMargin(0, 0, 0, margin)
            warnPanel:SetTall(warnTall)
            warnPanel.Paint = function(s,w,h)
                BaseWars:DrawRoundedBox(roundness, 0, 0, w, h, self.colors.contentBackground)

                draw.SimpleText(warnedBy, "BaseWars.18", leftMargin, h * .35, self.colors.text, 2, 1)
                draw.SimpleText(BaseWars:GetSteamName(warnData.admin_id64), "BaseWars.18", leftMargin + margin, h * .35, self.colors.darkText, 0, 1)

                draw.SimpleText(warnDate, "BaseWars.18", w * .5, h * .35, self.colors.text, 2, 1)
                draw.SimpleText(date, "BaseWars.18", w * .5 + margin, h * .35, self.colors.darkText, 0, 1)

                draw.SimpleText(warnID, "BaseWars.18", w * .80, h * .35, self.colors.text, 2, 1)
                draw.SimpleText(string.Comma(warnData.warning_id), "BaseWars.18", w * .80 + margin, h * .35, self.colors.darkText, 0, 1)

                draw.SimpleText(warnReason, "BaseWars.18", leftMargin, h * .65, self.colors.text, 2, 1)
                draw.SimpleText(reason, "BaseWars.18", leftMargin + margin, h * .65, self.colors.darkText, 0, 1)
            end

            warnPanel.Delete = warnPanel:Add("BaseWars.Button")
            warnPanel.Delete:Dock(RIGHT)
            warnPanel.Delete:DockMargin(margin, bigMargin, bigMargin, bigMargin)
            warnPanel.Delete:SetWide(warnTall - bigMargin * 2)
            warnPanel.Delete:SetColor(self.colors.contentBackground, true)
            warnPanel.Delete.Draw = function(s,w,h)
                BaseWars:DrawMaterial(icons["trash_warn"].icon, w * .5, h * .5, icons["trash_warn"].size, icons["trash_warn"].size, self.colors.text, 0)
            end
            warnPanel.Delete.DoClick = function(s)
                s:ButtonSound()
                warnPanel:Remove()

                self.data[k] = nil

                net.Start("BaseWars:Warnings:RemoveWarn")
                    net.WriteUInt(warnData.warning_id, 8)
                net.SendToServer()
            end

            warnPanel.Edit = warnPanel:Add("BaseWars.Button")
            warnPanel.Edit:Dock(RIGHT)
            warnPanel.Edit:DockMargin(0, bigMargin, 0, bigMargin)
            warnPanel.Edit:SetWide(warnTall - bigMargin * 2)
            warnPanel.Edit:SetColor(self.colors.contentBackground, true)
            warnPanel.Edit.Draw = function(s,w,h)
                BaseWars:DrawMaterial(icons["edit"].icon, w * .5, h * .5, icons["edit"].size, icons["edit"].size, self.colors.text, 0)
            end
            warnPanel.Edit.DoClick = function(s)
                s:ButtonSound()

                self.editWarning = vgui.Create("BaseWars.Warnings.EditWarning")
                self.editWarning:SetPlayerName(plyName)
                self.editWarning:SetWarningID(warnData.warning_id)
                self.editWarning:SetReason(warnData.reason)
                self.editWarning:SetCallback(function(newReason)
                    reason = newReason
                    self.data[k].reason = newReason

                    s:CustomTempDraw(1.5, self.colors.green, s.Draw)
                end)
                self.editWarning.Think = function(thinkSelf)
                    if not IsValid(self) then
                        thinkSelf:Remove()
                    end
                end
            end
        end
    end)
end

function PANEL:RequestData(player_id64)
    self.activePlayer = player_id64
    self.canRequestData = false
    self.hasData = false

    net.Start("BaseWars:Warnings:RequestPlayerData")
        net.WriteString(player_id64)
    net.SendToServer()
end

function PANEL:Paint()
end

vgui.Register("BaseWars.AdminMenu.Warnings", PANEL, "DPanel")

net.Receive("BaseWars:Warnings:RequestPlayerData", function(len)
    local data = util.JSONToTable(util.Decompress(net.ReadData(len / 8)))

    if IsValid(thisPanel) then
        thisPanel:Build(data)
    end
end)