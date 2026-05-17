local notif_pnl = {}

local clrtbl = {
    [NOTIFY_ERROR] = {Color(146, 48, 76)},
    [NOTIFY_HINT] = {Color(57, 49, 131)},
    [NOTIFY_CLEANUP] = {Color(36, 121, 82)}
}

local logotbl = {
    [NOTIFY_ERROR] = "%",
    [NOTIFY_HINT] = "&",
    [NOTIFY_CLEANUP] = "$"
}

local font, logoFont = "ashop_16", 'ashop_icon_20'

local function getPos(spawn)
    local height = ashop.menu:GetTall()*0.95

    for k,v in pairs(notif_pnl) do
        if !IsValid(v) then
            notif_pnl[k] = nil
            continue
        end

        height = height - v:GetTall()
        v:SetY(height)
        height = height - ashop.GetSize(10)
    end
end

function ashop.DermaNotify(txt, type, length)
    if !IsValid(ashop.menu) then return end

    surface.SetFont(font)
    local size_x, size_y = surface.GetTextSize(txt)
    local logo = ashop.GetFontHeight(logoFont)

    local pnl = vgui.Create("EditablePanel", ashop.menu)
    pnl:AlphaTo(255, 0.25, 0)
    pnl:SetAlpha(0)
    pnl:DockPadding(logo/2, logo/2, logo/2, logo/2)
    pnl:SetSize(size_x + logo*2.5, math.max(size_y, logo) + logo)
    pnl:SetPaintedManually(true)
    pnl:CenterHorizontal()

    ashop.menu.notifications = ashop.menu.notifications or {}
    table.insert(ashop.menu.notifications, pnl)
    table.insert(notif_pnl, pnl)
    getPos()

    local r1

    local clr2R, clr2G, clr2B = clrtbl[type][1]:Unpack()
    function pnl:Paint(w, h)
        if !r1 then
            r1 = ashop.ui.RoundedBox(ashop.Config.round, 0, 0, w, h)
        end

        surface.SetDrawColor(clr2R, clr2G, clr2B)
        draw.NoTexture()
        surface.DrawPoly(r1)
    end

    local pnl_logo = vgui.Create("DLabel", pnl)
    pnl_logo:Dock(LEFT)
    pnl_logo:SetWide(logo)
    pnl_logo:SetText(logotbl[type])
    pnl_logo:SetFont(logoFont)
    pnl_logo:SetTextColor(color_white)
    pnl_logo:DockMargin(0, 0, logo/2, 0)

    local pnl_follower = vgui.Create("DLabel", pnl)
    pnl_follower:SetContentAlignment(4)
    pnl_follower:SetText(txt)
    pnl_follower:SetFont(font)
    pnl_follower:SetWide(pnl_follower:GetContentSize())
    pnl_follower:Dock(LEFT)
    pnl_follower:SetWide(size_x)
    pnl_follower:SetTextColor(color_white)

    function pnl:OnRemove()
        // Can't use ipairs for a simple reason
        // A notif that pop after, can be removed before a older one, making holes in the code
        for k, v in pairs(notif_pnl) do
            if v == self or not IsValid(pnl) then
                notif_pnl[k] = nil
            end
        end

        ashop.menu.notifications = ashop.menu.notifications or {}
        table.RemoveByValue(ashop.menu.notifications, self)
        getPos()
    end

    timer.Simple(length or 5, function()
        if IsValid(pnl) then
            pnl:Remove()
        end
    end)
end

/*

net.Receive("Flux_Notify", function()
    local str
    if net.ReadBool() then
        local uid = net.ReadUInt(12)
        local tbl = {}
        
        for i = 1, net.ReadUInt(3) do
            table.insert(tbl, net.ReadString())
        end
        
        local good, res = pcall(function()
            return Flux.FormatLanguage(uid, unpack(tbl))
        end)

        if !good then
            notification.AddLegacy("Erreur lors de la lecture de : " .. Flux.Lang_IDToStr[uid], 1, 4)
            return
        else
            str = res
        end
    else
        str = net.ReadString()
    end
    
    notification.AddLegacy(str, net.ReadInt(5) or 0, net.ReadInt(5) or 4)
end)
*/