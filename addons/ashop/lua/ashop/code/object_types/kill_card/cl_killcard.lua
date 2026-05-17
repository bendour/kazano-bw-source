local OBJECT_TYPE = {}

OBJECT_TYPE.Name = "Kill Cards"
OBJECT_TYPE.UniqueIdentifier = "KillCards"

local lastKillCard

local function simpleFormat(num)
    if num > 1000000 then
        return math.floor(num / 1000000) .. "m"
    elseif num > 1000 then
        return math.floor(num / 1000) .. "k"
    else
        return num
    end
end

local function spawnCard(mat, ourDmg, ourBullet, theirDmg, theirBullet, wep, n, item)
    local w = ashop.GetSize(466)
    local h = w * (128 / 512)
    local fontSize = ashop.GetFontHeight('ashop_16_600')
    local white25 = ashop.GetColor('White25')
    local poly
    local cR, cG, cB = item.metadata[2]:Unpack()
    local shotCount = math.min(theirBullet, 1000)
    local logoMargin = fontSize/3*2
    local logoSize = ashop.GetFontHeight('ashop_icon_18')
    local fontSize = ashop.GetFontHeight('ashop_16_600')
    local kcR, kcG, kcB = 40, 40, 40

    theirDmg = simpleFormat(theirDmg)
    ourDmg = simpleFormat(ourDmg)

    local p = vgui.Create('DPanel')
    p:SetSize(w, h + fontSize + fontSize*1.5)
    p:SetPos(ScrW()/2 - w/2, ScrH()*0.8 - p:GetTall()/2)
    p:SetAlpha(0)
    p:AlphaTo(255, 0.25)

    function p:Paint(w, h)
        surface.SetDrawColor(kcR, kcG, kcB)
        surface.DrawRect(0, 0, w, h)
    end

    local topPart = vgui.Create('EditablePanel', p)
    topPart:Dock(TOP)
    topPart:SetTall(fontSize + fontSize*1.5)
    topPart:DockPadding(fontSize/2, fontSize/2, fontSize/2, fontSize/2)

    local rightPart = vgui.Create('EditablePanel', topPart)
    rightPart:Dock(RIGHT)
    rightPart:SetWide(logoMargin)

    for k, v in ipairs({{"/", ourDmg}, {".", ourBullet}}) do
        local amt = vgui.Create('DLabel', rightPart)
        amt:SetFont('ashop_16_600')
        amt:Dock(RIGHT)
        amt:SetText(v[2])
        amt:SetWide(amt:GetContentSize()+1)
        amt:SetTextColor(color_white)
        amt:DockMargin(fontSize/4, 0, 0, 0)

        local icon = vgui.Create('DLabel', rightPart)
        icon:SetFont('ashop_icon_18')
        icon:Dock(RIGHT)
        icon:SetText(v[1])
        icon:SetWide(icon:GetContentSize()+1)
        icon:SetTextColor(white25)
        icon:DockMargin(logoMargin, 0, 0, 0)

        rightPart:SetWide(rightPart:GetWide() + logoMargin + fontSize/4 + icon:GetWide() + amt:GetWide())
    end

    local leftPart = vgui.Create('EditablePanel', topPart)
    leftPart:Dock(FILL)

    function leftPart:Paint(w, h)
        if !poly then
            poly = {
                {
                    x = math.ceil(-fontSize/2),
                    y = -fontSize/2
                },

                {
                    x = w - (h + fontSize)/2,
                    y = -fontSize/2,
                },

                {
                    x = w + (h + fontSize)/2,
                    y = h + fontSize/2,
                },

                {
                    x =  math.ceil(-fontSize/2),
                    y = (h + fontSize)
                }
            }
        end

        DisableClipping(true)
        surface.SetDrawColor(cR, cG, cB)
        draw.NoTexture()
        surface.DrawPoly(poly)
        DisableClipping(false)
    end

    surface.SetFont("ashop_16_600")

    local leftWide = p:GetWide() - fontSize*2 - rightPart:GetWide()
    leftWide = leftWide - surface.GetTextSize(theirDmg)
        - surface.GetTextSize(shotCount) - (logoMargin + logoSize + fontSize/4) * (wep and 4 or 3)

    local nameSize, nameScroll
    local wepSize, wepScroll
    nameSize = surface.GetTextSize(n)
    wepSize = surface.GetTextSize(wep or "")

    if wepSize == 0 then
        nameScroll = nameSize > leftWide and leftWide or nil
    elseif nameSize + wepSize > leftWide then
        // We should make wepScroll, in this case
        // Name size isn't that big
        if nameSize < leftWide/2 then
            wepScroll = leftWide - nameSize
        elseif wepSize < leftWide/2 then
            nameScroll = leftWide - wepSize
        else
            nameScroll = leftWide / 2
            wepScroll = leftWide / 2
        end
    end

    for k, v in ipairs({{"1", n, nameScroll}, {"0", wep, wepScroll}, {"/", theirDmg}, {".", shotCount}}) do
        if !v[2] then continue end

        local icon = vgui.Create('DLabel', leftPart)
        icon:SetFont('ashop_icon_18')
        icon:Dock(LEFT)
        icon:SetText(v[1])
        icon:SetTextColor(white25)
        icon:DockMargin(logoMargin, 0, 0, 0)
        icon:SetWide(icon:GetContentSize()+1)

        leftPart:SetWide(leftPart:GetWide() + logoMargin + icon:GetWide())
        local refCurTime = CurTime() - 1

        local amt = vgui.Create(v[3] and 'EditablePanel' or 'DLabel', leftPart)
        amt:Dock(LEFT)
        amt:DockMargin(fontSize/4, 0, 0, 0)

        if v[3] then
            surface.SetFont("ashop_16_600")
            amt:SetWide(v[3])
            local tX = surface.GetTextSize(v[2])

            function amt:Paint(w, h)
                local sub = (CurTime() - refCurTime)/4
                local rat

                if sub > 1 then
                    rat = math.abs(sub % 2) - 1
                else
                    rat = 0
                end

                draw.SimpleText(v[2], "ashop_16_600", (tX - w) * -rat, h/2, color_white, 0, 1)
            end
        else
            amt:SetFont('ashop_16_600')
            amt:SetText(v[2])
            amt:SetTextColor(color_white)
            amt:SetWide(amt:GetContentSize()+1)
        end

        leftPart:SetWide(leftPart:GetWide() + fontSize / 3 * 2 + amt:GetWide())
    end

    local paint = vgui.Create('EditablePanel', p)
    paint:Dock(FILL)
    
    function paint:Paint(w, h)
        if !mat then return end

        surface.SetDrawColor(255, 255, 255)
        surface.SetMaterial(isfunction(mat) and mat() or mat)
        surface.DrawTexturedRect(0, 0, w, h)
    end
    
    function p:OnRemove()
        if removeFunc then
            removeFunc()
        end
    end

    return p
end

net.Receive('ashop_killcards', function()
    local id = net.ReadUInt(ashop.Config.BitsItemID)
    local b = net.ReadBool()
    local ent = net.ReadEntity()
    local ourDmg, ourBullet = net.ReadUInt(16), net.ReadUInt(16)
    local theirDmg, theirBullet = net.ReadUInt(16), net.ReadUInt(16)

    local item

    if !net.ReadBool() then
        item = ashop.Network.R_ItemData()
        ashop.items[item.id] = item
    else
        item = ashop.items[id]
    end

    local w = ashop.GetSize(512)
    ashop.ui.setMaterialByLink(item.metadata[1], {
        ["$translucent"] = 1,
    }, function(m)
        if !IsValid(ent) then return end
        if IsValid(lastKillCard) then
            lastKillCard:Remove()
        end

        local p = spawnCard(m, ourDmg, ourBullet, theirDmg, theirBullet, (IsValid(ent:GetActiveWeapon()) and ent:GetActiveWeapon().PrintName or nil), ent:Nick(), item)
        lastKillCard = p

        if !b then
            local lply = LocalPlayer()
            function p:Think()
                if lply:Alive() then
                    self:Remove()
                end
            end
        else
            timer.Simple(5, function()
                if IsValid(lastKillCard) then
                    lastKillCard:Remove()
                end
            end)
        end
    end, 'UnlitGeneric')
end)

function OBJECT_TYPE.UI_FILL(plyItem, item, pnl, parent, w, h, noCircle)
    parent:SetMouseInputEnabled(true)

    local circleParent = vgui.Create("EditablePanel", pnl)
    circleParent:SetSize(w, h)

    local c = math.max(w, h) * 0.6
    local sub = vgui.Create("EditablePanel", circleParent)
    sub:SetSize(c, c)
    sub:Center()
    
    local mat
    ashop.ui.setMaterialByLink(item.metadata[1], nil, function(m)
        mat = m

        if !IsValid(pnl) then
            return
        end
        
        local p = spawnCard(m, 100, 5, 50, 5, "Example Weapon", LocalPlayer():Nick(), item)
        p:SetVisible(false)
        p:SetMouseInputEnabled(false)
        
        parent:SetTooltipPanel(p)
        //sub:SetTooltipPanel(tooltip)
        parent:SetTooltipPanelOverride("ashop_TooltipAvatar")
        
        function circleParent:OnRemove()
            p:Remove()
        end
    end, 'UnlitGeneric')
    
    local r1
    function sub:Paint(w, h)
        if !r1 then
            r1 = ashop.ui.RoundedBox(ashop.Config.round, 0, 0, w, h)
        end

        if !mat then return end
        
        ashop.StartStencil()
        surface.SetDrawColor(1,1,1,1)
        draw.NoTexture()
        surface.DrawPoly(r1)
        ashop.ReplaceStencil(1)
        surface.SetDrawColor(255, 255, 255)
        local m = isfunction(mat) and mat() or mat
        surface.SetMaterial(m)
        
        local wOffset = m:Height() / m:Width()
        surface.DrawTexturedRectUV(0, 0, w, h, 0.5 - wOffset/2, 0, 0.5 + wOffset/2, 1)
        ashop.EndStencil()
    end
end

ashop.RegisterObjectType(OBJECT_TYPE)

local killCardID

hook.Add('ashop_equip', 'loadKillCard', function(_, slot, item, plyItem)
    if !killCardID then
        killCardID = ashop.GetObjectTypeIDByUID("KillCards")
    end

    if item.object_types == killCardID then
        ashop.ui.setMaterialByLink(item.metadata[1], nil, nil, 'UnlitGeneric')
    end
end)