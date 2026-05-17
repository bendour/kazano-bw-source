local L = VoidFactions.Lang.GetPhrase
local sc = VoidUI.Scale

local PANEL = {}

function PANEL:Init()
    self:SetOrigSize(1000, 600)
    self:SetTitle(string.upper(L"upgrades"))

    local member = VoidFactions.PlayerMember
    local faction = member.faction

    self.connections = {}
    self.points = {}

    self.selectedUpgrade = nil

    local container = self:Add("Panel")
    container:Dock(FILL)

    local infoPanel = container:Add("Panel")
    infoPanel:Dock(LEFT)
    
    local upgradePoints = infoPanel:Add("Panel")
    upgradePoints:Dock(TOP)
    upgradePoints.Paint = function (self, w, h)
        local points = VoidFactions.Settings:IsDynamicFactions() and faction:GetUpgradePoints() or #faction.upgrades

        draw.RoundedBox(8, 0, 0, w, h, VoidUI.Colors.Primary)
        
        draw.SimpleText(string.upper(VoidFactions.Settings:IsDynamicFactions() and L"upgradepoints" or L"totalUpgrades") .. ":", "VoidUI.B24", w/2, h/2-sc(20), VoidFactions.UI.Accent, TEXT_ALIGN_CENTER, TEXT_ALIGN_CENTER)
        draw.SimpleText(points .. "x", "VoidUI.B36", w/2, h/2+sc(10), VoidUI.Colors.Gray, TEXT_ALIGN_CENTER, TEXT_ALIGN_CENTER)
    end

    local wrappedPointText = nil

    local upgradeInfo = infoPanel:Add("Panel")
    upgradeInfo:Dock(FILL)
    upgradeInfo.Paint = function (s, w, h)
        draw.RoundedBox(8, 0, 0, w, h, VoidUI.Colors.Primary)

        if (!wrappedPointText) then
            surface.SetFont("VoidUI.R28")
            wrappedPointText = VoidUI.TextWrap(L"selectPointToView", "VoidUI.R28", w*0.9)
        end

        if (!self.selectedUpgrade) then
            draw.DrawText(wrappedPointText, "VoidUI.R28", w/2, sc(60), VoidUI.Colors.Gray, TEXT_ALIGN_CENTER, TEXT_ALIGN_CENTER)
        else
            local boxSize = w*0.9
            local boxHeight = sc(65)

            local x = w/2 - boxSize/2
            local y = sc(10)

            local spacing = boxHeight + sc(10)

            draw.RoundedBox(8, x, y, boxSize, boxHeight, VoidUI.Colors.Background)
            draw.SimpleText(string.upper(L"name") .. ":", "VoidUI.B24", x + boxSize / 2, y + sc(8), VoidFactions.UI.Accent, TEXT_ALIGN_CENTER, TEXT_ALIGN_TOP)
            draw.SimpleText(self.selectedUpgrade.upgrade.name, "VoidUI.R22", x + boxSize / 2, y + boxHeight - sc(10), VoidUI.Colors.Gray, TEXT_ALIGN_CENTER, TEXT_ALIGN_BOTTOM)

            y = y + spacing

            local wrappedDesc = VoidUI.TextWrap(L(self.selectedUpgrade.upgrade.module.description), "VoidUI.R22", boxSize*0.9)

            draw.RoundedBox(8, x, y, boxSize, sc(95), VoidUI.Colors.Background)
            draw.SimpleText(string.upper(L"description") .. ":", "VoidUI.B24", x + boxSize / 2, y + sc(8), VoidFactions.UI.Accent, TEXT_ALIGN_CENTER, TEXT_ALIGN_TOP)
            draw.DrawText(wrappedDesc, "VoidUI.R22", x + boxSize / 2, y + sc(35), VoidUI.Colors.Gray, TEXT_ALIGN_CENTER, TEXT_ALIGN_TOP)

            y = y + spacing + sc(30)

            local formattedValue = self.selectedUpgrade.upgrade.module:PrintValue(self.selectedUpgrade.upgrade.value)

            draw.RoundedBox(8, x, y, boxSize, boxHeight, VoidUI.Colors.Background)
            draw.SimpleText(string.upper(L"details") .. ":", "VoidUI.B24", x + boxSize / 2, y + sc(8), VoidFactions.UI.Accent, TEXT_ALIGN_CENTER, TEXT_ALIGN_TOP)
            draw.SimpleText(formattedValue, "VoidUI.R22", x + boxSize / 2, y + boxHeight - sc(10), VoidUI.Colors.Gray, TEXT_ALIGN_CENTER, TEXT_ALIGN_BOTTOM)

            y = y + spacing

            local currency = self.selectedUpgrade.upgrade.currency
            local cost = self.selectedUpgrade.upgrade.cost

            local canAfford = currency:CanAfford(LocalPlayer(), cost)

            draw.RoundedBox(8, x, y, boxSize, boxHeight, VoidUI.Colors.Background)
            draw.SimpleText(string.upper(L"neededToUnlock") .. ":", "VoidUI.B24", x + boxSize / 2, y + sc(8), VoidFactions.UI.Accent, TEXT_ALIGN_CENTER, TEXT_ALIGN_TOP)
            draw.SimpleText(currency:FormatMoney(cost), "VoidUI.R22", x + boxSize / 2, y + boxHeight - sc(10), canAfford and VoidUI.Colors.Gray or VoidUI.Colors.Red, TEXT_ALIGN_CENTER, TEXT_ALIGN_BOTTOM)
            

        end
    end
    

    local upgradePanel = container:Add("Panel")
    upgradePanel:Dock(FILL)
    upgradePanel.Paint = function (self, w, h)
        draw.RoundedBox(8, 0, 0, w, h, VoidUI.Colors.Primary)
    end

    local treeContent = upgradePanel:Add("VoidUI.ScrollPanel")
    treeContent:Dock(FILL)
    treeContent.Paint = function (s, w, h)

        local vbar = treeContent:GetVBar()
        local scroll = vbar:GetScroll()

        for k, v in ipairs(self.connections) do
            local first = v[1]
            local second = v[2]

            local size = 75

            local firstX = first.x + size/2
            local secondX = second.x + size/2

            local firstY = first.y + size/2 - scroll
            local secondY = second.y + size/2 - scroll

            surface.SetDrawColor(VoidUI.Colors.Gray)
            surface.DrawLine(firstX, firstY, secondX, secondY)
        end
    end

    local unlockButton = upgradePanel:Add("VoidUI.Button")
    unlockButton:Dock(BOTTOM)
    unlockButton:SetMedium()
    unlockButton:SetText(L"unlock")
    unlockButton:SetEnabled(false)

    unlockButton.DoClick = function ()
        if (!self.selectedUpgrade) then return end
        VoidFactions.Upgrades:PurchaseUpgrade(self.selectedUpgrade)
    end

    self.infoPanel = infoPanel
    self.upgradePanel = upgradePanel
    self.container = container
    self.treeContent = treeContent
    self.upgradePoints = upgradePoints
    self.unlockButton = unlockButton

    self:UpdateHook()
    self:LoadPoints()

end


function PANEL:UpdateHook()
    hook.Add("VoidFactions.Upgrade.UpgradesReceived", "VoidFactions.UI.UpgradesTreePanel.UpgradesReceived", function ()
        self:LoadPoints()
    end)

    hook.Add("VoidFactions.Faction.DataUpdated", "VoidFactions.UI.UpgradesTreePanel.DataUpdate", function ()
        self:LoadPoints()
    end)
end

function PANEL:OnRemove(w, h)
    hook.Remove("VoidFactions.Upgrade.UpgradesReceived", "VoidFactions.UI.UpgradesTreePanel.UpgradesReceived")
    hook.Remove("VoidFactions.Faction.DataUpdated", "VoidFactions.UI.UpgradesTreePanel.DataUpdate")
end

function PANEL:LoadPoints()
    if (!VoidFactions.UpgradePoints.List) then
        VoidFactions.Upgrades:RequestUpgrades()
    else
        self.connections = {}
        self.points = {}
        local pointsKeys = {}

        self.unlockButton:SetEnabled(false)

        self.treeContent:Clear()
        for k, point in pairs(VoidFactions.UpgradePoints.List) do
            local pointPanel = self:NewUpgradePoint(point.id, point.upgrade, point.posX, point.posY)
            pointsKeys[point.id] = pointPanel
        end

        for _, point in ipairs(self.points) do
            for k, to in ipairs(point.point.to) do
                self.connections[#self.connections + 1] = {point, pointsKeys[to.id]}
            end
        end

    end
end

function PANEL:CreateUpgradePoint(upgrade)
    local treeContent = self.treeContent
    local width, height = treeContent:GetSize()
    local size = 75

    local centerX, centerY = width / 2, height / 2
    centerX = centerX - size/2
    centerY = centerY - size/2
    
    centerX, centerY = math.Round(centerX / 10) * 10, math.Round(centerY / 10) * 10

    VoidFactions.Upgrades:CreatePoint(upgrade, centerX, centerY)
end


function PANEL:NewUpgradePoint(id, upgrade, x, y)

    local member = VoidFactions.PlayerMember
    local faction = member.faction

    local point = VoidFactions.UpgradePoints.List[id]

    local isUpgradePurchased = faction.upgrades[id]
    local canUnlock = point:CanPurchase(faction)

    local treeContent = self.treeContent
    local size = 75

    local this = self

    local upgradePoint = treeContent:Add("DButton")
    upgradePoint:SetText("")
    upgradePoint:SetSize(size, size)
    upgradePoint:SetPos(x, y)

    upgradePoint.point = point

    upgradePoint.borderColor = VoidUI.Colors.Background

    function upgradePoint:DoClick()
        if (!canUnlock) then return end
        this.selectedUpgrade = upgradePoint.point

        local upgrade = upgradePoint.point.upgrade
        local isEnabled = (upgrade.currency:CanAfford(LocalPlayer(), upgrade.cost) and LocalPlayer():GetVFMember():Can("PurchasePerks") and canUnlock) and !isUpgradePurchased

        this.unlockButton:SetEnabled(isEnabled)
    end

    function upgradePoint:Paint(w, h)
        local borderColor = self.borderColor
        local color = VoidUI.Colors.GrayText
        local iconColor = VoidUI.Colors.Black

        if (!canUnlock) then
            color = VoidUI.Colors.Background
            self:SetCursor("no")
        end

        if (isUpgradePurchased) then
            color = VoidFactions.UI.Accent
            iconColor = VoidUI.Colors.White
        end


        if (this.selectedUpgrade == upgradePoint.point) then
            borderColor = VoidUI.Colors.White
            iconColor = VoidUI.Colors.White
        end

        

        surface.SetDrawColor(borderColor)
        VoidUI.DrawCircle(w/2, h/2, w/2, 1)

        surface.SetDrawColor(color)
        VoidUI.DrawCircle(w/2, h/2, w/2-2, 1)

        VoidLib.FetchImage(upgrade.icon, function (mat)
            if (!mat) then return end

            local logoSize = 50

            surface.SetDrawColor(iconColor)
            surface.SetMaterial(mat)
            surface.DrawTexturedRect(w/2-logoSize/2, h/2-logoSize/2, logoSize, logoSize)
        end)

        if (!canUnlock) then

            local lockWidth = 27
            local lockHeight = 32

            surface.SetDrawColor(VoidUI.Colors.InputLight)
            surface.SetMaterial(VoidUI.Icons.Lock)
            surface.DrawTexturedRect(w/2 - lockWidth/2, h/2 - lockHeight/2, lockWidth, lockHeight)
        end
        
    end 

    self.points[#self.points + 1] = upgradePoint

    return upgradePoint
end



function PANEL:PerformLayout(w, h)
    self.container:SDockMargin(45, 10, 45, 40, self)

    self.infoPanel:SSetWide(260, self)

    self.upgradePanel:MarginLeft(10, self)

    self.treeContent:SDockMargin(10, 10, 10, 10, self)

    self.upgradePoints:SSetTall(120, self)
    self.upgradePoints:MarginBottom(10, self)

    self.unlockButton:MarginSides(230, self)
    self.unlockButton:MarginTops(15, self)
    self.unlockButton:MarginTop(10, self)
    self.unlockButton:SSetTall(35, self)
end

vgui.Register("VoidFactions.UI.UpgradesPanel", PANEL, "VoidUI.PanelContent")