local sc = VoidUI.Scale
local L = VoidFactions.Lang.GetPhrase

local PANEL = {}

function PANEL:Init()
    self:SSetSize(600, 500)
    self:Center()
    self:SetTitle(L"createUpgrade")

    self.tabs = self:Add("VoidUI.Tabs")

    local generalPanel = self:CreateGeneral()
    local visualPanel = self:CreateVisual()

    self.tabs:AddTab(string.upper(L"general"), generalPanel)
    self.tabs:AddTab(string.upper(L"visual"), visualPanel)

    self.tabs:SetAccentColor(VoidUI.Colors.Green)
    
    local buttonPanel = self.tabs:Add("Panel")
    buttonPanel:Dock(BOTTOM)
    buttonPanel:SSetTall(40)
    buttonPanel:MarginSides(200)
    buttonPanel:MarginBottom(30)

    local createButton = buttonPanel:Add("VoidUI.Button")
    createButton:Dock(FILL)
    createButton:SetMedium()
    createButton:SetColor(VoidUI.Colors.Green, VoidUI.Colors.Background)
    createButton:SetText(L"create")

    createButton.DoClick = function ()
        VoidFactions.Upgrades:CreateUpgrade(self:GetValues())

        self:Remove()
    end

    self.createButton = createButton
    self.buttonPanel = buttonPanel

    self.generalPanel = generalPanel
    self.visualPanel = visualPanel
end

function PANEL:CreateGeneral()
    local panel = self.tabs:Add("Panel")
    panel:Dock(FILL)

    local container = panel:Add("Panel")
    container:Dock(FILL)
    container:SDockMargin(30, 20, 30, 20)

    local grid = container:Add("VoidUI.ElementGrid")
    grid:Dock(FILL)
    grid:MarginBottom(20)

    panel.name = grid:AddElement(L"name", "VoidUI.TextInput")
    panel.currency = grid:AddElement(L"currency", "VoidUI.Dropdown")
    local i = 1
    for k, currency in pairs(VoidFactions.Currencies.List) do
        if (!currency:IsInstalled()) then continue end
        panel.currency:AddChoice(currency.name)
        if (currency.name == "Upgrade Points") then
            panel.currency:ChooseOptionID(i)
        end

        i = i + 1
    end

    if (panel.currency:GetSelectedID() == nil) then
        panel.currency:ChooseOptionID(1)
    end

    panel.cost = grid:AddElement(L"price", "VoidUI.TextInput")
    panel.cost:SetNumeric(true)

    panel.module = grid:AddElement(L"upgradeModule", "VoidUI.SelectorButton")

    panel.module.DoClick = function ()
        local selector = vgui.Create("VoidUI.ItemSelect")
        selector:SetParent(self)

        local moduleTbl = {}
        for id, module in pairs(VoidFactions.Upgrades.Modules) do
            if (!module:IsInstalled()) then continue end
            moduleTbl[module] = module:PrintName()
        end

        selector:InitItems(moduleTbl, function (id, v)
            panel.module:Select(id, v)
            panel.valueInput:SetVisible(true)

            panel.valueInput:SetNumeric(id.isNumeric)

            if (self.visualPanel.icon.textInput:GetValue() == "") then
                self.visualPanel.icon.textInput:SetValue(id.icon)
            end
        end)
    end

    local this = self


    local valuePanel = container:Add("Panel")
    valuePanel:Dock(BOTTOM)
    valuePanel:SSetTall(100)
    valuePanel:MarginBottom(70)

    valuePanel.Paint = function (self, w, h)
        if (panel.module.value) then
            draw.SimpleText(string.upper(L"moduleValue"), "VoidUI.B24", 0, 0, VoidUI.Colors.GrayText, TEXT_ALIGN_LEFT, TEXT_ALIGN_TOP)
            draw.SimpleText(panel.module.value:PrintValueDescription(), "VoidUI.R24", 0, sc(25), VoidUI.Colors.GrayText, TEXT_ALIGN_LEFT, TEXT_ALIGN_TOP)
        end
    end

    local valueInput = valuePanel:Add("VoidUI.TextInput")
    valueInput:Dock(BOTTOM)
    valueInput:SSetTall(45)
    valueInput:SetVisible(false)

    panel.valueInput = valueInput


    return panel
end

function PANEL:CreateVisual()
    local panel = self.tabs:Add("Panel")
    panel:Dock(FILL)

    local container = panel:Add("Panel")
    container:Dock(FILL)
    container:SDockMargin(30, 20, 30, 20)

    local grid = container:Add("VoidUI.ElementGrid")
    grid:Dock(FILL)
    grid:MarginBottom(60)

    panel.icon = grid:AddElement(L"icon", "VoidUI.IconSelector", sc(200))

    return panel
end

function PANEL:EditMode(upgrade)
    self:SetTitle(L("editUpgrade", upgrade.name))
    self.isEditing = true

    local panel = self.generalPanel

    panel.name.entry:SetValue(upgrade.name)
    panel.cost.entry:SetValue(upgrade.cost)

    panel.module:Select(upgrade.module, upgrade.module:PrintName())
    panel.valueInput:SetVisible(true)

    panel.valueInput:SetNumeric(upgrade.module.isNumeric)

    panel.valueInput.entry:SetValue(upgrade.value)
    
    local choices = panel.currency.Choices
    for k, v in pairs(choices) do
        if (v == upgrade.currency.name) then
            panel.currency:ChooseOptionID(k)
        end
    end

    self.buttonPanel:MarginSides(105)

    self.createButton:Dock(LEFT)
    self.createButton:SSetWide(150)
    self.createButton:SetText(L"edit")

    self.createButton.DoClick = function ()
        VoidFactions.Upgrades:UpdateUpgrade(upgrade, self:GetValues())
        self:Remove()
    end

    self.visualPanel.icon.textInput:SetValue(upgrade.icon)

    local deleteButton = self.buttonPanel:Add("VoidUI.Button")
    deleteButton:Dock(RIGHT)
    deleteButton:SetMedium()
    deleteButton:SetColor(VoidUI.Colors.Red, VoidUI.Colors.Background)
    deleteButton:SetText(L"delete")

    deleteButton:SSetWide(150)

    deleteButton.DoClick = function ()
        local popup = vgui.Create("VoidUI.Popup")
		popup:SetText(L"deleteUpgrade", L("deleteUpgradePrompt", upgrade.name))
		popup:SetDanger()
		popup:Continue(L"delete", function ()
			VoidFactions.Upgrades:DeleteUpgrade(upgrade)
            self:Remove()
		end)
		popup:Cancel(L"cancel")
    end
end

function PANEL:GetValues()
    local panel = self.generalPanel
    local nameVal = panel.name.entry:GetText()
    local moduleVal = panel.module.value
    local currencyVal = panel.currency:GetSelected()
    local valueVal = panel.valueInput.entry:GetText()
    local costVal = tonumber(panel.cost.entry:GetText())
    local iconVal = self.visualPanel.icon.textInput.entry:GetText()

    return nameVal, moduleVal.name, valueVal, currencyVal, costVal, iconVal
end


function PANEL:Think()
    local conditionsMet = true

    local panel = self.generalPanel
    local nameVal = panel.name.entry:GetText()
    if (!nameVal or nameVal == "") then
        conditionsMet = false
    end

    local moduleVal = panel.module.value
    if (!moduleVal) then
        conditionsMet = false
    end

    local valueVal = panel.valueInput.entry:GetText()
    if (!valueVal or valueVal == "") then
        conditionsMet = false
    end

    local costVal = panel.cost.entry:GetText()
    if (!costVal or costVal == "") then
        conditionsMet = false
    end

    if (self.createButton) then
        self.createButton:SetEnabled(conditionsMet)
    end
end

vgui.Register("VoidFactions.UI.UpgradeCreate", PANEL, "VoidUI.ModalFrame")