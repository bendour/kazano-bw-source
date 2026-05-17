local sc = VoidUI.Scale
local L = VoidFactions.Lang.GetPhrase

local PANEL = {}

function PANEL:Init()
    self:SetOrigSize(648, 411)

    local upgradeGrid = self:Add("VoidUI.Grid")
    upgradeGrid:Dock(FILL)

    upgradeGrid:SetColumns(6)
    upgradeGrid:SetHorizontalMargin(10)
    upgradeGrid:SetVerticalMargin(10)

    local buttonPanel = self:Add("Panel")
    buttonPanel:Dock(BOTTOM)
    
    local createButton = buttonPanel:Add("VoidUI.Button")
    createButton:Dock(BOTTOM)
    createButton:SetText(L"createUpgrade")
    createButton:SetMedium()

    createButton.DoClick = function ()
        local frame = vgui.Create("VoidFactions.UI.UpgradeCreate")
        frame:SetParent(self)
    end

    self.upgradeGrid = upgradeGrid
    self.buttonPanel = buttonPanel
    self.createButton = createButton

    self:UpdateHook()
    self:LoadUpgrades()
end

function PANEL:UpdateHook()
    hook.Add("VoidFactions.Upgrade.UpgradesReceived", "VoidFactions.UI.UpgradesManage.UpgradesReceived", function ()
        self:LoadUpgrades()
    end)
end

function PANEL:OnRemove(w, h)
    hook.Remove("VoidFactions.Upgrade.UpgradesReceived", "VoidFactions.UI.UpgradesManage.UpgradesReceived")
end

function PANEL:LoadUpgrades()
    if (!VoidFactions.Upgrades.Custom) then
        VoidFactions.Upgrades:RequestUpgrades()
    else
        self:CreateUpgrades()
    end
end

function PANEL:CreateUpgrades()
    local upgrades = VoidFactions.Upgrades.Custom

    self.upgradeGrid:Clear()

    for k, upgrade in pairs(upgrades) do
        local upgradeBox = self.upgradeGrid:Add("DButton")
        upgradeBox:SetText("")
        upgradeBox:SSetSize(90, 90)
        upgradeBox.Paint = function (self, w, h)
            local color = self:IsHovered() and VoidUI.Colors.TextGray or VoidUI.Colors.InputLight
            draw.RoundedBox(8, 0, 0, w, h, color)

            local iconSize = w * 0.6
            local iconX, iconY = w/2 - iconSize/2, h/2 - iconSize / 2 - 5

            VoidLib.FetchImage(upgrade.icon, function (mat)
                if (!mat) then return end

                surface.SetMaterial(mat)
                surface.SetDrawColor(VoidUI.Colors.White)
                surface.DrawTexturedRect(iconX, iconY, iconSize, iconSize)
            end)

            surface.SetFont("VoidUI.R14")
            local textSize = surface.GetTextSize(upgrade.name)
            local shortenedText = textSize > w * 0.9 and upgrade.name:sub(1, 12) or upgrade.name
            draw.SimpleText(shortenedText, "VoidUI.R14", w/2, h-5, VoidUI.Colors.Gray, TEXT_ALIGN_CENTER, TEXT_ALIGN_BOTTOM)
        end

        upgradeBox.DoClick = function ()
            local frame = vgui.Create("VoidFactions.UI.UpgradeCreate")
            frame:SetParent(self)
            frame:EditMode(upgrade)
        end

        self.upgradeGrid:AddCell(upgradeBox, true)
    end
end

function PANEL:PerformLayout(w, h)
    self.upgradeGrid:MarginSides(22, self)
    self.upgradeGrid:MarginTop(40, self)
    self.upgradeGrid:MarginBottom(20, self)

    self.buttonPanel:SSetTall(35, self)
    self.buttonPanel:MarginSides(200, self)
    self.buttonPanel:MarginBottom(10, self)

    self.createButton:SSetTall(35, self)
end

function PANEL:Paint(w, h)
    draw.SimpleText(L("upgradeCount", VoidFactions.Upgrades.Custom and #VoidFactions.Upgrades.Custom or 0), "VoidUI.R24", 0, 0, VoidUI.Colors.Gray, TEXT_ALIGN_LEFT)
end


vgui.Register("VoidFactions.UI.UpgradesManage", PANEL, "VoidUI.PanelContent")