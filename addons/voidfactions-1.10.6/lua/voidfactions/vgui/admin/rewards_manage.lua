local L = VoidFactions.Lang.GetPhrase

local PANEL = {}

function PANEL:Init()
    self:SetOrigSize(648, 411)

    local rewardGrid = self:Add("VoidUI.Grid")
    rewardGrid:Dock(FILL)

    rewardGrid:SetColumns(6)
    rewardGrid:SetHorizontalMargin(10)
    rewardGrid:SetVerticalMargin(10)

    local buttonPanel = self:Add("Panel")
    buttonPanel:Dock(BOTTOM)
    
    local createButton = buttonPanel:Add("VoidUI.Button")
    createButton:Dock(BOTTOM)
    createButton:SetText(L"createReward")
    createButton:SetMedium()

    createButton.DoClick = function ()
        local frame = vgui.Create("VoidFactions.UI.RewardCreate")
        frame:SetParent(self)
    end

    self.rewardGrid = rewardGrid
    self.buttonPanel = buttonPanel
    self.createButton = createButton

    self:UpdateHook()
    self:LoadRewards()
end

function PANEL:UpdateHook()
    hook.Add("VoidFactions.Rewards.RewardsReceived", "VoidFactions.UI.RewardsManage.RewardsReceived", function ()
        self:LoadRewards()
    end)
end

function PANEL:OnRemove(w, h)
    hook.Remove("VoidFactions.Rewards.RewardsReceived", "VoidFactions.UI.RewardsManage.RewardsReceived")
end

function PANEL:LoadRewards()
    if (!VoidFactions.Rewards.List) then
        VoidFactions.Rewards:RequestRewards()
    else
        self:CreateRewards()
    end
end

function PANEL:CreateRewards()
    local rewards = VoidFactions.Rewards.List

    self.rewardGrid:Clear()

    for k, reward in pairs(rewards) do
        local rewardBox = self.rewardGrid:Add("DButton")
        rewardBox:SetText("")
        rewardBox:SSetSize(90, 90)
        rewardBox.Paint = function (self, w, h)
            local color = self:IsHovered() and VoidUI.Colors.TextGray or VoidUI.Colors.InputLight
            draw.RoundedBox(8, 0, 0, w, h, color)

            local iconSize = w * 0.6
            local iconX, iconY = w/2 - iconSize/2, h/2 - iconSize / 2 - 5

            VoidLib.FetchImage(reward.icon, function (mat)
                if (!mat) then return end

                surface.SetMaterial(mat)
                surface.SetDrawColor(VoidUI.Colors.White)
                surface.DrawTexturedRect(iconX, iconY, iconSize, iconSize)
            end)

            surface.SetFont("VoidUI.R14")
            local textSize = surface.GetTextSize(reward.name)
            local shortenedText = textSize > w * 0.9 and reward.name:sub(1, 12) or reward.name
            draw.SimpleText(shortenedText, "VoidUI.R14", w/2, h-5, VoidUI.Colors.Gray, TEXT_ALIGN_CENTER, TEXT_ALIGN_BOTTOM)
        end

        rewardBox.DoClick = function ()
            local frame = vgui.Create("VoidFactions.UI.RewardCreate")
            frame:SetParent(self)
            frame:EditMode(reward)
        end

        self.rewardGrid:AddCell(rewardBox, true)
    end
end



function PANEL:PerformLayout(w, h)
    self.rewardGrid:MarginSides(22, self)
    self.rewardGrid:MarginTop(40, self)
    self.rewardGrid:MarginBottom(20, self)

    self.buttonPanel:SSetTall(35, self)
    self.buttonPanel:MarginSides(200, self)
    self.buttonPanel:MarginBottom(10, self)

    self.createButton:SSetTall(35, self)
end

function PANEL:Paint(w, h)
    draw.SimpleText(L("rewardCount", VoidFactions.Rewards.List and #VoidFactions.Rewards.List or 0), "VoidUI.R24", 0, 0, VoidUI.Colors.Gray, TEXT_ALIGN_LEFT)
end

vgui.Register("VoidFactions.UI.RewardsManage", PANEL, "VoidUI.PanelContent")