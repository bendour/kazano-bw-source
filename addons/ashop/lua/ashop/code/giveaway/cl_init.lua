//if true then return end
local circlePattern = Material('akulla/pattern_circle.png', "noclamp smooth")
local grad = Material('akulla/gradient-d.png')
local function spawnGiveawayPanel(itemName, restrictGroup, winnerPly, playerCountLoop, secExec)
    local pW = ashop.GetSize(12)
    local clrGrad1_0 = ashop.GetColor('Grad2_1')
    local fontSize = ashop.GetFontHeight('ashop_16')
    local clrStateOn = ashop.GetColor('StateOn', 125)
    local p = vgui.Create('EditablePanel')
    local wBarGrad = ashop.GetSize(10)
    p:SetSize(ScrW() * 0.4, ashop.GetSize(64) + fontSize * 2)
    p:SetPos(ScrW() / 2 - p:GetWide() / 2)

    local top = vgui.Create('EditablePanel', p)
    top:SetTall(p:GetTall() - fontSize * 2)
    top:Dock(TOP)

    function top:Paint(w, h)
        surface.SetDrawColor(clrGrad1_0)
        surface.DrawRect(0, 0, w, h)
    end

    function top:PaintOver(w, h)
        surface.SetDrawColor(color_white)
        surface.DrawRect(w/2-2, 0, 4, h)

        surface.SetMaterial(grad)
        surface.SetDrawColor(clrStateOn)
        surface.DrawTexturedRectRotated(w/2-2 - wBarGrad*0.5, h/2, h, wBarGrad, 90 )
        surface.DrawTexturedRectRotated(w/2+2 + wBarGrad*0.5, h/2, h, wBarGrad, 270 )
    end

    local bonusCountLoop = math.ceil(p:GetWide() / top:GetTall()) + 1

    local avatarPanel = vgui.Create('EditablePanel', top)
    avatarPanel:SetSize(top:GetTall() * (playerCountLoop+bonusCountLoop), top:GetTall())

    local bottom = vgui.Create('EditablePanel', p)
    bottom:Dock(FILL)
    bottom:DockPadding(fontSize, fontSize/2, fontSize, fontSize/2)

    function bottom:Paint(w, h)
        local rat = (w + h) / pW
        local bonus = (UnPredictedCurTime()*0.5 % 1)
        draw.RoundedBoxEx(8, 0, 0, w, h, clrGrad1_0, false, false, true, true)

        surface.SetMaterial(circlePattern)
        surface.SetDrawColor(ashop.GetColor('StateOn', 60))
        surface.DrawTexturedRectUV(0, 0, w + h, w + h, -bonus, bonus, rat-bonus, rat+bonus)

        surface.SetDrawColor(ashop.GetColor('StateOn'))
        surface.DrawRect(0, 0, w, 2)
    end

    if restrictGroup then
        local restrictedTo = vgui.Create('DLabel', bottom)
        restrictedTo:Dock(RIGHT)
        restrictedTo:SetFont('ashop_16_600')
        restrictedTo:SetTextColor(color_white)
        restrictedTo:SetText(ashop.L('RestrictedTo', restrictGroup))
        restrictedTo:SetWide(restrictedTo:GetContentSize())
    end

    local iconGift = vgui.Create('DLabel', bottom)
    iconGift:Dock(LEFT)
    iconGift:SetTextColor(color_white)
    iconGift:SetFont('ashop_icon_20')
    iconGift:SetText("3")
    iconGift:SetWide(iconGift:GetContentSize())
    iconGift:DockMargin(0, 0, fontSize, 0)

    local itemNameLabel = vgui.Create('DLabel', bottom)
    itemNameLabel:Dock(LEFT)
    itemNameLabel:SetTextColor(color_white)
    itemNameLabel:SetFont('ashop_16_600')
    itemNameLabel:SetText('"' .. itemName .. '"')
    itemNameLabel:SetWide(itemNameLabel:GetContentSize())

    local plys = {}
    for k, v in ipairs(player.GetHumans()) do
        if restrictGroup and ashop.groupranks[restrictGroup] and !ashop.groupranks[restrictGroup].ranks[v:GetUserGroup()] then continue end

        table.insert(plys, v)
    end

    for i = 0, playerCountLoop + bonusCountLoop do
        local ply = plys[math.random(#plys)]
        local avatar = vgui.Create('AvatarImage', avatarPanel)
        avatar:Dock(LEFT)

        if playerCountLoop == i then
            avatar:SetPlayer(winnerPly, 184)
        else
            avatar:SetPlayer(ply, 184)
        end
        avatar:SetWide(top:GetTall())
    end

    local goodPos = playerCountLoop * top:GetTall()
    local randOffset = math.Rand(-top:GetTall()*0.45, top:GetTall()*0.45)

    timer.Simple(2, function()
        avatarPanel:MoveTo(-goodPos - top:GetTall()/2 + p:GetWide()/2 + randOffset, 0, secExec, 0, 0.5, function()
            p:MoveTo(p:GetX(), -p:GetTall(), 1, 3, 0.5, function()
                p:Remove()
            end)
            if !IsValid(winnerPly) then return end

            local winnerLabel = vgui.Create('DLabel', bottom)
            winnerLabel:SetTextColor(color_white)
            winnerLabel:SetFont('ashop_16_600')
            winnerLabel:SetText(ashop.L('WinnerIs', (IsValid(winnerPly) and winnerPly:Nick() or "Unknown")))
            winnerLabel:SetWide(winnerLabel:GetContentSize())
            winnerLabel:SetPos(-winnerLabel:GetWide()/2 + p:GetWide()/2, fontSize/2)
            winnerLabel:SetTall(fontSize)
            winnerLabel:SetAlpha(0)
            winnerLabel:AlphaTo(255, 0.5)
        end)
    end)

    p:SetY(-p:GetTall())
    p:MoveTo(p:GetX(), 0, 1, 0, 0.5)
end

net.Receive('ashop_giveaway', function()
    local ply = net.ReadEntity()
    local name = net.ReadString()
    local restrictGroup = net.ReadBool() and net.ReadUInt(8) or nil
    local playerCountLoop = net.ReadUInt(9)
    local secExec = net.ReadUInt(6)

    spawnGiveawayPanel(name, restrictGroup, ply, playerCountLoop, secExec)
end)

// spawnGiveawayPanel("The Nicest Accessory !", "Test Rank", LocalPlayer(), 100, 5)