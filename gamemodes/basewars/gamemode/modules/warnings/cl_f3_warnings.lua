local thisPanel

local warnTall = BaseWars.ScreenScale * 60
local bigMargin = BaseWars.ScreenScale * 10
local margin = BaseWars.ScreenScale * 5
local roundness = BaseWars.ScreenScale * 4

local PANEL = {}
function PANEL:Init()
    self.localPlayer = LocalPlayer()
    self.colors = {
        text = GetBaseWarsTheme("bwm_text"),
        darkText = GetBaseWarsTheme("bwm_darkText"),
        contentBackground = GetBaseWarsTheme("bwm_contentBackground")
    }

    thisPanel = self

    self.Scroll = self:Add("DScrollPanel")
    self.Scroll:Dock(FILL)
    self.Scroll:DockMargin(bigMargin, bigMargin, bigMargin, bigMargin)
    self.Scroll:GetVBar():SetWide(0)
    self.Scroll.Paint = function(s,w,h)
        if s:GetCanvas():ChildCount() <= 0 then
            draw.SimpleText(self.localPlayer:GetLang("warnings_noWarns"), "BaseWars.30", w * .5, h * .5, self.colors.text, 1, 1)
        end
    end

    self:Build()
end

function PANEL:Build()
    self.Scroll:GetCanvas():Clear()

    local warnedBy = self.localPlayer:GetLang("warnings_warnInfos", "warnedBy")
    local warnDate = self.localPlayer:GetLang("warnings_warnInfos", "warnDate")
    local warnID = self.localPlayer:GetLang("warnings_warnInfos", "warnID")
    local warnReason = self.localPlayer:GetLang("warnings_warnInfos", "warnReason")

    local warnedByW, _ = BaseWars:GetTextSize(warnedBy, "BaseWars.18")
    local warnReasonW, _ = BaseWars:GetTextSize(warnReason, "BaseWars.18")

    local leftMargin = math.max(warnedByW, warnReasonW) + bigMargin * 2

    for k, warnData in ipairs(BaseWars.Warns:GetWarnings()) do
        local date = os.date("%H:%M:%S - %d/%m/%Y", warnData.date)

        BaseWars:RequestSteamName(warnData.admin_id64)

        local warnPanel = self.Scroll:Add("DPanel")
        warnPanel:Dock(TOP)
        warnPanel:DockMargin(0, 0, 0, margin)
        warnPanel:SetTall(warnTall)
        warnPanel.Paint = function(s,w,h)
            BaseWars:DrawRoundedBox(roundness, 0, 0, w, h, self.colors.contentBackground)

            draw.SimpleText(warnedBy, "BaseWars.18", leftMargin, h * .35, self.colors.text, 2, 1)
            draw.SimpleText(BaseWars:GetSteamName(warnData.admin_id64), "BaseWars.18", leftMargin + margin, h * .35, self.colors.darkText, 0, 1)

            draw.SimpleText(warnDate, "BaseWars.18", w * .4, h * .35, self.colors.text, 2, 1)
            draw.SimpleText(date, "BaseWars.18", w * .4 + margin, h * .35, self.colors.darkText, 0, 1)

            draw.SimpleText(warnID, "BaseWars.18", w * .8, h * .35, self.colors.text, 2, 1)
            draw.SimpleText(string.Comma(warnData.warning_id), "BaseWars.18", w * .8 + margin, h * .35, self.colors.darkText, 0, 1)

            draw.SimpleText(warnReason, "BaseWars.18", leftMargin, h * .65, self.colors.text, 2, 1)
            draw.SimpleText(warnData.reason, "BaseWars.18", leftMargin + margin, h * .65, self.colors.darkText, 0, 1)
        end
    end
end

function PANEL:Paint()
end

vgui.Register("BaseWars.F3Menu.Warnings", PANEL, "DPanel")

net.Receive("BaseWars:Warnings:SendDataToClient", function(len)
    local data = util.JSONToTable(util.Decompress(net.ReadData(len / 8)))

    LocalPlayer().basewarsWarnings = data

    if IsValid(thisPanel) then
        thisPanel:Build()
    end
end)