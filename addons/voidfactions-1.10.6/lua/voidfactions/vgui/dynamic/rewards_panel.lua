local sc = VoidUI.Scale
local L = VoidFactions.Lang.GetPhrase

local PANEL = {}

function PANEL:Init()
    self:SetOrigSize(1000, 600)

    self:SetTitle(string.upper(L"rewards"))

    local root = self
    self.selectedCategory = nil

    local container = self:Add("Panel")
    container:Dock(FILL)

    local selectionPanel = container:Add("Panel")
    selectionPanel:Dock(LEFT)
    selectionPanel.Paint = function (self, w, h)
        draw.RoundedBox(12, 0, 0, w, h, VoidUI.Colors.Primary)
    end
    selectionPanel:SDockPadding(8,8,8,8)

    local rowPanel = selectionPanel:Add("VoidUI.RowPanel")
    rowPanel:Dock(FILL)
    rowPanel:SDockMargin(0, 0, 0, 10)
    rowPanel:SetSpacing(5)

    function selectionPanel:AddCategory(category)

        local panel = rowPanel:Add("DButton")
        panel:SetText("")
        panel.Paint = function (self, w, h)
            if (self:IsHovered() or root.selectedCategory == category) then
                if (root.selectedCategory == category) then
                    draw.RoundedBox(8, 0, 0, w, h, VoidFactions.UI.Accent)
                else
                    draw.RoundedBox(8, 0, 0, w, h, VoidUI.Colors.TextGray)
                end
            end

            draw.SimpleText(L(category), "VoidUI.R26", sc(10), h/2, VoidUI.Colors.Gray, TEXT_ALIGN_LEFT, TEXT_ALIGN_CENTER)
        end
        panel.DoClick = function ()
            root:SelectCategory(category)
        end

        rowPanel:AddRow(panel)
    end

    local rewardContainer = container:Add("Panel")
    rewardContainer:Dock(FILL)
    rewardContainer.Paint = function (self, w, h)
        draw.RoundedBox(8, 0, 0, w, h, VoidUI.Colors.Primary)
    end

    local contentRow = rewardContainer:Add("VoidUI.RowPanel")
    contentRow:Dock(FILL)
    contentRow:SetSpacing(20)

    self.selectionPanel = selectionPanel
    self.container = container

    self.rewardContainer = rewardContainer
    self.rowPanel = rowPanel

    self.contentRow = contentRow

    self:UpdateHook()
    self:LoadRewards()
end

function PANEL:UpdateHook()
    hook.Add("VoidFactions.Rewards.RewardsReceived", "VoidFactions.UI.Rewards.RewardsReceived", function ()
        self:LoadRewards()
    end)
end

function PANEL:OnRemove(w, h)
    hook.Remove("VoidFactions.Rewards.RewardsReceived", "VoidFactions.UI.Rewards.RewardsReceived")
end

function PANEL:LoadRewards()
    if (!VoidFactions.Rewards.List) then
        VoidFactions.Rewards:RequestRewards()
    else
        self:CreateRewards()
    end
end

function PANEL:CreateRewards()
    self.rowPanel:Clear()

    local rewards = VoidFactions.Rewards.List
    local modules = {}
    for k, v in pairs(rewards) do
        if (!modules[v.module]) then
            modules[v.module] = {}
            self:SelectCategory(v.module:PrintName())
        end

        modules[v.module][#modules[v.module] + 1] = v
    end

    -- Sort by modules
    for module, rewards in pairs(modules) do
        self.selectionPanel:AddCategory(module:PrintName())
    end
end

function PANEL:SelectCategory(category)
    self.contentRow:Clear()

    local member = VoidFactions.PlayerMember
    local faction = member.faction

    local currency = VoidFactions.Currencies.List[VoidFactions.Config.DepositCurrency]

    self.selectedCategory = category

    local rewards = VoidFactions.Rewards.List
    local selectedRewards = {}
    for k, v in pairs(rewards) do
        if (v.module:PrintName() == category) then
            selectedRewards[v.id] = v
        end
    end

    for id, reward in SortedPairs(selectedRewards) do

        local rewardValue = faction.rewardValues[reward.module.name]
        local progress = math.Clamp(rewardValue.value / reward.requiredValue, 0, 1)

        local panel = self.contentRow:Add("Panel")
        panel.Paint = function (self, w, h)

            rewardValue = faction.rewardValues[reward.module.name]
            progress = math.Clamp(rewardValue.value / reward.requiredValue, 0, 1)

            draw.RoundedBox(8, 0, 0, w, h, VoidUI.Colors.InputLight)

            local iconSize = 50

            VoidLib.FetchImage(reward.icon, function (mat)
                if (!mat) then return end

                surface.SetMaterial(mat)
                surface.SetDrawColor(VoidUI.Colors.White)
                surface.DrawTexturedRect(sc(20), h/2 - iconSize/2, iconSize, iconSize) 
            end)

            local progressColor = progress >= 1 and VoidUI.Colors.Green or VoidUI.Colors.Orange
            local barWidth, barHeight = sc(200), sc(15)
            
            draw.SimpleText(string.upper(reward.name), "VoidUI.B26", sc(20) + iconSize + sc(20), h/2, VoidUI.Colors.Gray, TEXT_ALIGN_LEFT, TEXT_ALIGN_BOTTOM)

            local barX, barY = sc(20) + iconSize + sc(20), h/2+sc(5)

            draw.RoundedBox(6, barX, barY, barWidth, barHeight, VoidUI.Colors.BackgroundTransparent)
            draw.RoundedBox(6, barX, barY, barWidth * progress, barHeight, progressColor)

            local progressStr = progress >= 1 and L"claimed" or rewardValue.value .. "/" .. reward.requiredValue
            draw.SimpleText(progressStr, "VoidUI.R14", barX+barWidth/2, barY+barHeight/2, VoidUI.Colors.Gray, TEXT_ALIGN_CENTER, TEXT_ALIGN_CENTER)

            local rewardX = w - sc(150)
            draw.SimpleText(string.upper(L"reward"), "VoidUI.B26", rewardX, h/2, VoidUI.Colors.Gray, TEXT_ALIGN_CENTER, TEXT_ALIGN_BOTTOM)

            local rewardXP = reward.xp > 0 and reward.xp .. " XP"
            local rewardMoney = reward.money > 0 and currency:FormatMoney(reward.money)
            local rewardStr = (rewardMoney and rewardXP) and rewardMoney .. " & " .. rewardXP or (rewardMoney or rewardXP)

            draw.SimpleText(rewardStr, "VoidUI.R22", rewardX, h/2, VoidUI.Colors.Gray, TEXT_ALIGN_CENTER, TEXT_ALIGN_TOP)
        end

        self.contentRow:AddRow(panel, 85)
    end
end

function PANEL:PerformLayout(w, h)
    self:SDockPadding(0, 0, 0, 30, self)

    self.container:MarginSides(45, self)
    self.container:MarginTop(10, self)

    self.contentRow:SDockMargin(20, 20, 20, 20, self)

    self.rewardContainer:MarginLeft(12, self)
    
    self.selectionPanel:SSetWide(240, self)
    -- self.settingsContainer:MarginLeft(12, self)
    -- self.settingTitle:SSetTall(45, self)
    -- self.settingsContent:MarginTop(10, self)
end

vgui.Register("VoidFactions.UI.RewardsPanel", PANEL, "VoidUI.PanelContent")
