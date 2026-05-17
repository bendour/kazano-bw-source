local L = VoidFactions.Lang.GetPhrase
local sc = VoidUI.Scale

local PANEL = {}

function PANEL:Init()
    self:SetOrigSize(1000, 600)

    local currency = VoidFactions.Currencies.List[VoidFactions.Config.FactionCreateCurrency]

    local container = self:Add("Panel")
    container:Dock(FILL)
    
    local title = container:Add("Panel")
    title:Dock(TOP)
    title.Paint = function (self, w, h)
        draw.RoundedBox(8, 0, 0, w, h, VoidUI.Colors.Primary)

        draw.SimpleText(string.upper(L"createFactionOrJoin"), "VoidUI.R28", w/2, h/2, VoidUI.Colors.Gray, TEXT_ALIGN_CENTER, TEXT_ALIGN_CENTER)
    end

    local content = container:Add("Panel")
    content:Dock(FILL)
    content.Paint = function (self, w, h)
        draw.RoundedBox(8, 0, 0, w, h, VoidUI.Colors.Primary)
    end

    local factionCreateCost = tonumber(VoidFactions.Config.FactionCreateCost)

    local formattedMoney = currency and currency:FormatMoney(factionCreateCost) or "MISSING"

    local canAfford = currency and currency:CanAfford(LocalPlayer(), factionCreateCost) or false
    local moneyColor = canAfford and VoidUI.Colors.Green or VoidUI.Colors.Red

    local wrappedText = nil
    local moneyMarkup = markup.Parse("<color=222,222,222,255><font=VoidUI.R24>" .. L("factionCreateCost", {
        money = formattedMoney,
        color = "<color=" .. moneyColor.r .. "," .. moneyColor.g .. "," .. moneyColor.b .. ",255>"
    }) .. "</color></font>")

    local textContainer = content:Add("Panel")
    textContainer:Dock(TOP)
    textContainer.Paint = function (self, w, h)
        draw.RoundedBox(8, 0, 0, w, h, VoidUI.Colors.BackgroundTransparent)

        if (!wrappedText) then
            wrappedText = VoidUI.TextWrap(currency and L"noFactionText" or "You don't have any configured currency. Go to Settings > Options > Factions > Faction creation currency and set up a valid currency.", "VoidUI.R24", w - sc(40))
        end

        draw.DrawText(wrappedText, "VoidUI.R24", w/2, sc(20), currency and VoidUI.Colors.Gray or VoidUI.Colors.Red, TEXT_ALIGN_CENTER)
        moneyMarkup:Draw(w/2, h - sc(20), TEXT_ALIGN_CENTER, TEXT_ALIGN_BOTTOM)
    end

    local buttonPanel = content:Add("Panel")
    buttonPanel:Dock(BOTTOM)

    local createButton = buttonPanel:Add("VoidUI.Button")
    createButton:Dock(LEFT)
    createButton:SetMedium()
    createButton:SetText(L"createFaction")
    createButton:SetEnabled(canAfford)

    createButton.DoClick = function ()
        local frame = vgui.Create("VoidFactions.UI.FactionCreate")
		frame:SetParent(self)
    end

    local joinButton = buttonPanel:Add("VoidUI.Button")
    joinButton:Dock(RIGHT)
    joinButton:SetMedium()
    joinButton:SetText(L"joinFaction")
    joinButton:SetColor(VoidUI.Colors.Blue)
    joinButton.DoClick = function ()
        VoidFactions.Menu.Panel.sidebar:SelectTab(VoidFactions.Menu.Panel.rankingTab)
    end
    
    self.container = container

    self.title = title
    self.content = content

    self.textContainer = textContainer

    self.buttonPanel = buttonPanel
    self.createButton = createButton
    self.joinButton = joinButton
end

function PANEL:PerformLayout(w, h)
    self.container:MarginSides(240, self)
    self.container:MarginTops(75, self)

    self.title:SSetTall(55, self)
    self.content:MarginTop(15, self)
    
    self.textContainer:MarginSides(20, self)
    self.textContainer:MarginTop(45, self)
    self.textContainer:SSetTall(210, self)

    self.buttonPanel:SSetTall(40, self)
    self.buttonPanel:MarginBottom(45, self)
    self.buttonPanel:MarginSides(30, self)

    self.createButton:SSetWide(220, self)
    self.joinButton:SSetWide(220, self)
end

vgui.Register("VoidFactions.UI.NoFactionPanel", PANEL, "VoidUI.PanelContent")