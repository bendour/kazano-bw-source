local sc = VoidUI.Scale
local L = VoidFactions.Lang.GetPhrase

local PANEL = {}

function PANEL:Init()
    self:SSetSize(600, 500)
    self:Center()
    self:SetTitle(L"createReward")

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
        VoidFactions.Rewards:CreateReward(self:GetValues())

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
    panel.module = grid:AddElement(L"rewardModule", "VoidUI.SelectorButton")

    panel.module.DoClick = function ()
        local selector = vgui.Create("VoidUI.ItemSelect")
        selector:SetParent(self)

        local moduleTbl = {}
        for id, module in pairs(VoidFactions.RewardModules.List) do
            moduleTbl[module] = module:PrintName()
        end

        selector:InitItems(moduleTbl, function (id, v)
            panel.module:Select(id, v)
            panel.valueInput:SetVisible(true)
            panel.valueInput:SetNumeric(true)

            if (self.visualPanel.icon.textInput:GetValue() == "") then
                self.visualPanel.icon.textInput:SetValue(id.defaultIcon)
            end
        end)
    end

    panel.money = grid:AddElement(L"moneyRewarded", "VoidUI.TextInput")
    panel.money:SetNumeric(true)

    panel.xp = grid:AddElement(L"xpRewarded", "VoidUI.TextInput")
    panel.xp:SetNumeric(true)

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

function PANEL:EditMode(reward)
    self:SetTitle(L("editReward", reward.name))
    self.isEditing = true

    local panel = self.generalPanel

    panel.name.entry:SetValue(reward.name)
    panel.money.entry:SetValue(reward.money)
    panel.xp.entry:SetValue(reward.xp)

    panel.module:Select(reward.module, reward.module:PrintName())
    panel.valueInput:SetVisible(true)

    panel.valueInput:SetNumeric(true)

    panel.valueInput.entry:SetValue(reward.requiredValue)

    self.buttonPanel:MarginSides(105)

    self.createButton:Dock(LEFT)
    self.createButton:SSetWide(150)
    self.createButton:SetText(L"edit")

    self.createButton.DoClick = function ()
        VoidFactions.Rewards:UpdateReward(reward, self:GetValues())
        self:Remove()
    end

    self.visualPanel.icon.textInput:SetValue(reward.icon)

    local deleteButton = self.buttonPanel:Add("VoidUI.Button")
    deleteButton:Dock(RIGHT)
    deleteButton:SetMedium()
    deleteButton:SetColor(VoidUI.Colors.Red, VoidUI.Colors.Background)
    deleteButton:SetText(L"delete")

    deleteButton:SSetWide(150)

    deleteButton.DoClick = function ()
        local popup = vgui.Create("VoidUI.Popup")
		popup:SetText(L"deleteReward", L("deleteRewardPrompt", reward.name))
		popup:SetDanger()
		popup:Continue(L"delete", function ()
			VoidFactions.Rewards:DeleteReward(reward)
            self:Remove()
		end)
		popup:Cancel(L"cancel")
    end
end

function PANEL:GetValues()
    local panel = self.generalPanel
    local nameVal = panel.name.entry:GetText()
    local moduleVal = panel.module.value
    local moneyVal = panel.money.entry:GetText() != "" and tonumber(panel.money.entry:GetText()) or 0
    local xpVal = panel.xp.entry:GetText() != "" and tonumber(panel.xp.entry:GetText()) or 0
    local valueVal = panel.valueInput.entry:GetText() != "" and tonumber(panel.valueInput.entry:GetText()) or 0
    local iconVal = self.visualPanel.icon.textInput.entry:GetValue()

    return nameVal, moduleVal, valueVal, moneyVal, xpVal, iconVal
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

    local xpVal = panel.xp.entry:GetText()
    if (!xpVal or xpVal == "") then
        conditionsMet = false
    end

    local moneyVal = panel.money.entry:GetText()
    if (!moneyVal or moneyVal == "") then
        conditionsMet = false
    end

    if (self.createButton) then
        self.createButton:SetEnabled(conditionsMet)
    end
end

vgui.Register("VoidFactions.UI.RewardCreate", PANEL, "VoidUI.ModalFrame")