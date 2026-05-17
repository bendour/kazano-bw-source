local sc = VoidUI.Scale
local L = VoidFactions.Lang.GetPhrase

local totalPoints = {}

local PANEL = {}

function PANEL:Init()
    self:SetOrigSize(648, 411)

    totalPoints = {}

    self.selectedTool = nil
    self.connections = {}
    self.selectedConnection = nil
    self.points = {}

    local toolHeader = self:Add("Panel")
    toolHeader:Dock(TOP)
    toolHeader.Paint = function (self, w, h)
        surface.SetDrawColor(VoidUI.Colors.GrayTransparent)
        surface.DrawRect(0, h-2, w, 2)

        draw.SimpleText(string.upper(L"tools") .. ":", "VoidUI.R24", sc(10), h/2-1, VoidUI.Colors.Gray, TEXT_ALIGN_LEFT, TEXT_ALIGN_CENTER)
    end

    local buttonPanel = toolHeader:Add("Panel")
    buttonPanel:Dock(RIGHT)


    local moveButton = buttonPanel:Add("DButton")
    moveButton:Dock(RIGHT)
    moveButton:SetText("")
    moveButton.Paint = function (s, w, h)
        local drawColor = self.selectedTool == s and VoidUI.Colors.Green or VoidUI.Colors.White

        surface.SetMaterial(VoidUI.Icons.Move)
        surface.SetDrawColor(drawColor)
        surface.DrawTexturedRect(0, 0, w, h)
    end

    moveButton:SetTooltip(L"moveTool")

    moveButton.DoClick = function (s)
        self.selectedTool = s
    end

    local connectorButton = buttonPanel:Add("DButton")
    connectorButton:Dock(RIGHT)
    connectorButton:SetText("")
    connectorButton.Paint = function (s, w, h)
        local drawColor = self.selectedTool == s and VoidUI.Colors.Green or VoidUI.Colors.White

        local btnSize = 17

        surface.SetMaterial(VoidUI.Icons.Rename)
        surface.SetDrawColor(drawColor)
        surface.DrawTexturedRect(w/2-btnSize/2, h/2-btnSize/2, btnSize, btnSize)
    end

    connectorButton:SetTooltip(L"connectorTool")

    connectorButton.DoClick = function (s)
        self.selectedTool = s
    end

    local divider = buttonPanel:Add("DButton")
    divider:Dock(RIGHT)
    divider:SetText("")
    divider.Paint = function (s, w, h)
        surface.SetDrawColor(VoidUI.Colors.GrayText)
        surface.DrawRect(0, 0, w, h)
    end

    local removeButton = buttonPanel:Add("DButton")
    removeButton:Dock(RIGHT)
    removeButton:SetText("")
    removeButton.Paint = function (s, w, h)
        local drawColor = self.selectedTool == s and VoidUI.Colors.Red or VoidUI.Colors.White

        surface.SetMaterial(VoidUI.Icons.Remove)
        surface.SetDrawColor(drawColor)
        surface.DrawTexturedRect(0, 0, w, h)
    end

    removeButton.DoClick = function (s)
        self.selectedTool = s
    end
    removeButton:SetTooltip(L"deleteUpgrade")

    local addButton = buttonPanel:Add("DButton")
    addButton:Dock(RIGHT)
    addButton:SetText("")
    addButton.Paint = function (s, w, h)
        surface.SetMaterial(VoidUI.Icons.Add)
        surface.SetDrawColor(VoidUI.Colors.White)
        surface.DrawTexturedRect(0, 0, w, h)
    end

    addButton.DoClick = function ()
        -- Select upgrade
        local selector = vgui.Create("VoidUI.ItemSelect")
        selector:SetParent(self)

        local upgradeTbl = {}
        for id, upgrade in pairs(VoidFactions.Upgrades.Custom) do
            upgradeTbl[upgrade] = upgrade.name
        end

        selector:InitItems(upgradeTbl, function (id, v)
            self:CreateUpgradePoint(id)
        end)
    end
    addButton:SetTooltip(L"addUpgrade")
    

    local treeContent = self:Add("VoidUI.ScrollPanel")
    treeContent:Dock(FILL)

    treeContent.Paint = function (s, w, h)
        draw.RoundedBox(8, 0, 0, w, h, VoidUI.Colors.LightGray)
        draw.RoundedBox(8, 1, 1, w-2, h-2, VoidUI.Colors.Background)

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

            surface.SetDrawColor(VoidUI.Colors.White)
            surface.DrawLine(firstX, firstY, secondX, secondY)

            local centerX, centerY = (firstX + secondX) / 2, (firstY + secondY) / 2
        end

        if (self.selectedConnection) then
            local cursorX, cursorY = s:CursorPos()

            local size = 75

            surface.SetDrawColor(VoidUI.Colors.Green)
            surface.DrawLine(cursorX, cursorY + 8, self.selectedConnection.x + size/2, self.selectedConnection.y + size/2 - scroll)
        end
    end

    self.toolHeader = toolHeader
    self.buttonPanel = buttonPanel
    self.treeContent = treeContent

    self.addButton = addButton
    self.moveButton = moveButton
    self.connectorButton = connectorButton
    self.divider = divider
    self.removeButton = removeButton

    self:UpdateHook()
    self:LoadPoints()

end

function PANEL:UpdateHook()
    hook.Add("VoidFactions.Upgrade.UpgradesReceived", "VoidFactions.UI.UpgradesTreeManage.UpgradesReceived", function ()
        self:LoadPoints()
    end)
end

function PANEL:OnRemove(w, h)
    hook.Remove("VoidFactions.Upgrade.UpgradesReceived", "VoidFactions.UI.UpgradesTreeManage.UpgradesReceived")
end

function PANEL:LoadPoints()
    if (!VoidFactions.UpgradePoints.List) then
        VoidFactions.Upgrades:RequestUpgrades()
    else
        self.connections = {}
        self.selectedConnection = nil
        self.points = {}
        local pointsKeys = {}

        self.treeContent:Clear()
        for k, point in pairs(VoidFactions.UpgradePoints.List) do
            if (!point.upgrade) then continue end
            
            local pointPanel = self:NewUpgradePoint(point.id, point.upgrade, point.posX, point.posY)
            pointsKeys[point.id] = pointPanel
        end

        for _, point in ipairs(self.points) do
            for k, to in ipairs(point.point.to) do
                self.connections[#self.connections + 1] = {point, pointsKeys[to.id]}
            end
        end

        self:VisualizeStartingPoints()
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

function PANEL:VisualizeStartingPoints()
    local points = self:GetStartingPoints()

    for k, v in ipairs(self.points) do
        if (points[v]) then
            v.borderColor = VoidUI.Colors.Green
        else
            v.borderColor = VoidUI.Colors.Background
        end
    end
end

function PANEL:RecalculateStartingPoints()
    for k, point in ipairs(self.connections) do
        local fromPoint = point[1]
        local toPoint = point[2]
        if (fromPoint.y > toPoint.y) then
            self.connections[k] = {toPoint, fromPoint}
        elseif (fromPoint.y == toPoint.y and fromPoint.x > toPoint.x) then
            -- if more to the right
            self.connections[k] = {toPoint, fromPoint}
        end
    end
end

function PANEL:GetStartingPoints()
    self:RecalculateStartingPoints()

    local onePoints = {}
    for k, point in ipairs(self.points) do
        -- select all points without "to"
        local passedCheck = true
        for _, connection in ipairs(self.connections) do
            if (connection[2] == point) then passedCheck = false end
        end

        if (passedCheck) then
            onePoints[point] = true
        end
    end

    return onePoints
end

function PANEL:GetRelationships(id)
    self:RecalculateStartingPoints()

    local tbl = {}
    for k, v in ipairs(self.connections) do
        local from = v[1]
        local to = v[2]

        if (from.point.id != id) then continue end
        tbl[#tbl + 1] = to.point
    end
    return tbl
end

function PANEL:SelectConnect(point)

    if (self.selectedConnection and self.selectedConnection == point) then
        self.selectedConnection = nil
        return
    end

    for k, v in ipairs(self.connections) do
        if ( (v[1] == point and v[2] == self.selectedConnection) or (v[2] == point and v[1] == self.selectedConnection) ) then
            local fromPoint = v[1]
            local toPoint = v[2]

            table.remove(self.connections, k)
            self.selectedConnection = nil


            VoidFactions.Upgrades:UpdatePoint(fromPoint.point.id, fromPoint.point.posX, fromPoint.point.posY, self:GetRelationships(fromPoint.point.id))
            -- VoidFactions.Upgrades:UpdatePoint(toPoint.point.id, toPoint.point.posX, toPoint.point.posY, self:GetRelationships(toPoint.point.id))
            return
        end
    end

    if (self.selectedConnection) then
        -- The first one is "from", second is "to"

        local fromPoint = self.selectedConnection
        local toPoint = point
        if (self.selectedConnection.y > point.y) then
            toPoint = self.selectedConnection
            fromPoint = point
        elseif (self.selectedConnection.y == point.y and self.selectedConnection.x > point.x) then
            -- if more to the right
            toPoint = self.selectedConnection
            fromPoint = point
        end

        self.connections[#self.connections + 1] = {fromPoint, toPoint}
        self.selectedConnection = nil

        VoidFactions.Upgrades:UpdatePoint(fromPoint.point.id, fromPoint.point.posX, fromPoint.point.posY, self:GetRelationships(fromPoint.point.id))
        VoidFactions.Upgrades:UpdatePoint(toPoint.point.id, toPoint.point.posX, toPoint.point.posY, self:GetRelationships(toPoint.point.id))
    else
        self.selectedConnection = point
    end

    self:GetStartingPoints()
end

function PANEL:NewUpgradePoint(id, upgrade, x, y)
    local treeContent = self.treeContent
    local size = 75

    local this = self

    local upgradePoint = treeContent:Add("DButton")
    upgradePoint:SetText("")
    upgradePoint:SetSize(size, size)
    upgradePoint:SetPos(x, y)

    upgradePoint:SetTooltip(upgrade.name)

    upgradePoint.point = VoidFactions.UpgradePoints.List[id]

    upgradePoint.borderColor = VoidUI.Colors.Background


    function upgradePoint:OnMousePressed()
        if (this.selectedTool == this.connectorButton) then
            this:SelectConnect(upgradePoint)
        end

        if (this.selectedTool != this.moveButton) then return end
        self.isHolded = true
    end

    function upgradePoint:OnMouseReleased()
        self.isHolded = false

        if (this.selectedTool == this.removeButton) then
            VoidFactions.Upgrades:DeletePoint(self.point)
        end

        if (this.selectedTool == this.moveButton) then
            local posX, posY = self:GetPos()
            this:VisualizeStartingPoints()
            VoidFactions.Upgrades:UpdatePoint(id, posX, posY, this:GetRelationships(id))
        end
    end

    function upgradePoint:Paint(w, h)

        local borderColor = self.borderColor
        if (self:IsHovered() and this.selectedTool == this.connectorButton) then
            borderColor = VoidUI.Colors.Gray
        end
        if (self:IsHovered() and this.selectedTool == this.removeButton) then
            borderColor = VoidUI.Colors.Red
        end

        surface.SetDrawColor(borderColor)
        VoidUI.DrawCircle(w/2, h/2, w/2, 1)

        surface.SetDrawColor(VoidUI.Colors.GrayText)
        VoidUI.DrawCircle(w/2, h/2, w/2-2, 1)

        VoidLib.FetchImage(upgrade.icon, function (mat)
            if (!mat) then return end

            local logoSize = 50

            surface.SetDrawColor(0,0,0)
            surface.SetMaterial(mat)
            surface.DrawTexturedRect(w/2-logoSize/2, h/2-logoSize/2, logoSize, logoSize)
        end)
        
    end 

    function upgradePoint:Think()

        local vbar = treeContent:GetVBar()

        if (self.x > treeContent:GetWide()) then
            self:SetPos(0, self.y)
        end

        if (self.y < 0) then
            self:SetPos(self.x, 0)
        end

        if (this.selectedTool != this.moveButton) then 
            self:SetCursor("arrow")
            return
        end

        if (self:IsHovered()) then
            self:SetCursor("sizeall")
        end

        if (!self.isHolded) then return end
        
        local x, y = treeContent:CursorPos()

        
        local scrollAmt = vbar:GetScroll()

        y = y + scrollAmt

        local isWithin = x > -1 and y > -1 and x < treeContent:GetWide()
        if (!isWithin) then return end

        self:RequestFocus()

        local finalX, finalY = x - size/2, y - size/2
        finalX, finalY = math.Round(finalX / 10) * 10, math.Round(finalY / 10) * 10

        self:SetPos(finalX, finalY)
    end

    self.points[#self.points + 1] = upgradePoint

    totalPoints = self.points

    return upgradePoint
end

function PANEL:PerformLayout(w, h)
    self:SDockPadding(0, 0, 0, 10, self)

    self.toolHeader:SSetTall(40, self)

    self.buttonPanel:MarginTops(10, self)
    self.buttonPanel:MarginRight(10, self)
    self.buttonPanel:SSetWide(150, self)

    self.treeContent:MarginTop(20, self)
    self.treeContent:MarginSides(10, self)

    self.addButton:SSetWide(20, self)

    self.moveButton:MarginLeft(10, self)
    self.moveButton:SSetWide(20, self)

    self.connectorButton:MarginLeft(10, self)
    self.connectorButton:SSetWide(20, self)

    self.divider:SSetWide(2, self)
    self.divider:MarginLeft(10, self)

    self.removeButton:SSetWide(20, self)
    self.removeButton:MarginLeft(10, self)
    
end

vgui.Register("VoidFactions.UI.UpgradeTreeManage", PANEL, "VoidUI.PanelContent")

hook.Add( "PlayerButtonUp", "VoidFactions.UI.UpgradeTreeManage.ReleaseButton", function( ply, button )
    if (button == MOUSE_FIRST) then
	    for k, v in ipairs(totalPoints) do
            if (IsValid(v) and v.isHolded) then
                v:OnMouseReleased()
            end
        end
    end
end)