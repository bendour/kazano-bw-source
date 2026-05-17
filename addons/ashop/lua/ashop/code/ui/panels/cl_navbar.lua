local PANEL = {}

local blurpleClr = ashop.GetColor('blurple')
local blurpleClrR, blurpleClrG, blurpleClrB = ashop.GetColor('blurple'):Unpack()
local bg = ashop.GetColor('Grad1_0')
local white = ashop.GetColor('White')

function PANEL:Init()
    local sH = ashop.GetSize(80)
    local rightPartVerticalMargin = ashop.GetSize(20)
    local moneyTextHorizontalMargin = ashop.GetSize(12)
    local moneyTextInnerHorizontalMargin = ashop.GetSize(10)

    local roundValue = ashop.Config.round
    local lp = LocalPlayer()

    // Left
    surface.SetFont("ashop_logo_top48")

    local s = "Kazano BaseWars"
    local logoW = surface.GetTextSize(s)
    local logoPanel = vgui.Create("EditablePanel", self)
    logoPanel:Dock(LEFT)
    logoPanel:SetWide(logoW + 5)

    function logoPanel:Paint(w, h)
        // this is on purpose
        draw.SimpleText(s, "ashop_logo_top48", 0, h/2, color_white, 0, 1)
        draw.SimpleTextOutlined("N", "ashop_logo_bottom54", w*0.1, h/4*3, color_white, 0, 1, 1, bg)
    end
    
    self.leftSpace = logoPanel:GetWide() * 2 + rightPartVerticalMargin

    // Right, avatar + money
    local close = vgui.Create("DButton", self)
    close:DockMargin(rightPartVerticalMargin, rightPartVerticalMargin, 0, rightPartVerticalMargin)
    close:SetWide(sH - rightPartVerticalMargin*2)
    close:Dock(RIGHT)
    close:SetText(":")
    close:SetFont("ashop_icon_20")
    close:SetTextColor(ColorAlpha(color_white, 60))

    local c = ashop.GetColor('Grad2_0')
    function close:Paint(w, h)
        draw.RoundedBox(roundValue, 0, 0, w, h, c)
    end

    function close:DoClick()
        self:GetParent():GetParent():Remove()
    end

    ashop.ui.WhiteHover(close, 30)

    // Right, avatar + money
    local avatar = vgui.Create("AShop_RoundedAvatar", self)
    avatar:DockMargin(rightPartVerticalMargin, rightPartVerticalMargin, 0, rightPartVerticalMargin)
    avatar:SetWide(sH - rightPartVerticalMargin*2)
    avatar:Dock(RIGHT)

    // Loop, so I make the 2 panels at the same moment
    local moneyObjects = {}
    for k, v in ipairs({
        {
            ashop.GetColor('pink'),
            ashop.GetColor('premiumMoneyLogo'),
            lp:ashopMoneyGet(true),
            "!",
        },

        {
            ashop.GetColor('normalMoneyBg'),
            ashop.GetColor('normalMoney'),
            lp:ashopMoneyGet(false),
            "\"",
        }
    }) do
        surface.SetFont('ashop_16')
        local tW, tH = surface.GetTextSize(v[3])
        local font = 'ashop_icon_20'

        surface.SetFont(font)
        local iW, iH = surface.GetTextSize(v[4])

        local m = vgui.Create("EditablePanel", self)
        m:Dock(RIGHT)
        m:DockMargin(rightPartVerticalMargin, rightPartVerticalMargin, 0, rightPartVerticalMargin)
        m:DockPadding(moneyTextHorizontalMargin, 0, moneyTextHorizontalMargin, 0)

        m.minWide = iW + moneyTextHorizontalMargin*2 + moneyTextInnerHorizontalMargin
        m:SetWide(tW + m.minWide)
        moneyObjects[k] = m

        function m:Paint(w, h)
            draw.RoundedBox(roundValue, 0, 0, w, h, v[1])
        end

        local logo = vgui.Create("DLabel", m)
        logo:Dock(LEFT)
        logo:SetFont(font)
        logo:SetText(v[4])
        logo:SetTextColor(v[2])
        logo:SetWide(iW)

        local text = vgui.Create("DLabel", m)
        text:Dock(FILL)
        text:SetFont('ashop_16')
        text:SetText(v[3])
        text:SetTextColor(white)
        text:SetContentAlignment(6)
        m.moneyText = text

        self['moneyPanel_' .. k] = m
    end

    hook.Add('ashop_moneyChanged', 'RefreshMoneyNavbar', function(id, amt)
        local p = moneyObjects[id == "money_premium" and 1 or 2]
        if !IsValid(p) then return end

        p.moneyText:SetText(amt)

        surface.SetFont('ashop_16')
        local tW, tH = surface.GetTextSize(amt)
        p:SetWide(p.minWide + tW)
    end)
end

function PANEL:CenterCategories(holder)
    // Refresh margin
    local rightPartVerticalMargin = ashop.GetSize(20)
    local left = self.leftSpace
    local right = 0

    for i = 1, 2 do
        local p = self['moneyPanel_' .. i]
        right = right + p:GetWide() + rightPartVerticalMargin
    end

    right = right + rightPartVerticalMargin + (self:GetTall() - rightPartVerticalMargin*2)

    // Center it now
    local sW = ashop.GetSize(1536) - ashop.GetSize(64)*2
    local lastChild = holder:GetChild(holder:ChildCount()-1)

    // (X + W) of last child - X of the first child
    lastChild:InvalidateParent(true)
    local childSize = (holder:GetChildPosition(lastChild) - holder:GetChildPosition(holder:GetChild(0))) + lastChild:GetWide()
    sW = sW - right - left - childSize

    // Can we atleast put some extra margin at left ?
    local diff = right - left

    if diff > sW then
        holder:DockMargin(0, 0, 0, 0)
    else
        sW = math.floor((sW - diff) / 2)

        holder:DockPadding(sW + diff, 0, sW, 0)
        holder:InvalidateLayout()
    end
end

function PANEL:Fill(tbl, container)
    assert(tbl, "Navbar table shouldn't be empty")

    if self.holder then
        self.holder:Remove()
    end

    local panels = {}
    local holder = vgui.Create("EditablePanel", self)
    holder:Dock(FILL)
    holder:SetMouseInputEnabled(true)

    /*
        1: Name
        2: Callback to create the UI
    */
    local lastSelected
    local rightPartVerticalMargin = ashop.GetSize(20)

    for k, v in ipairs(tbl) do
        local w25 = ashop.GetColor('White25')

        local l = vgui.Create("DButton", holder)
        l:Dock(LEFT)
        l:SetFont('ashop_18')
        l:SetTextColor(w25)
        l:SetText(v[1])
        l:SetWide(l:GetContentSize())
        l:SetContentAlignment(5)
        l:DockMargin(rightPartVerticalMargin/2, 0, rightPartVerticalMargin/2, 0)

        function l:Paint(w, h)
            if self.perc > 0 then
                l:SetTextColor(ashop.GetColor('White25', (255 - w25.a) * self.perc + w25.a))

                if self.forceanim then
                    surface.SetDrawColor(blurpleClrR, blurpleClrG, blurpleClrB)
                    draw.RoundedBox(999, w/2 - 4, h/4*3, 8, 8, blurpleClr)
                end
            end
        end

        local navbar = self
        function l:DoClick()
            if lastSelected then
                lastSelected:SetFont('ashop_18')
                lastSelected.forceanim = false
                lastSelected.perc = 0
                lastSelected:SetTextColor(ashop.GetColor('White25'))
                lastSelected:SetWide(lastSelected:GetContentSize())
            end

            self.forceanim = true
            self.perc = 1
            self:SetFont('ashop_24_600')
            self:SetWide(self:GetContentSize())
            lastSelected = self

            navbar:CenterCategories(holder)
            container:Clear()
            v[2](container)
        end

        ashop.ui.AddHoverTimer(l, 8)

        table.insert(panels, l)
    end

    // Need to, since else it would imply to make 2 branchs of code, for CenterCategories
    holder:InvalidateLayout(true)
    self:CenterCategories(holder)

    return panels
end

derma.DefineControl( "AShop_Navbar", "", PANEL, "EditablePanel" )