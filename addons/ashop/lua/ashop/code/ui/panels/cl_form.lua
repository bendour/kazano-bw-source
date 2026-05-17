local stateOff = ashop.GetColor('StateOff')
local white = ashop.GetColor('White')

local clr = ashop.GetColor('Grad1_1')
local r = ashop.Config.round
local c1R, c1G, c1B = ashop.GetColor('Grad1_0'):Unpack()
local c2R, c2G, c2B = ashop.GetColor('Grad1_1'):Unpack()
local grad = Material('akulla/gradient-d')

local PANEL = {}

function PANEL:Init()
    self:SetMouseInputEnabled(true)
    self:SetKeyboardInputEnabled(true)
end

function PANEL:CrossClose()
    self.buttons:Remove()

    local close = vgui.Create('DButton', self.title)
    close:Dock(RIGHT)
    close:SetFont('ashop_16_600')
    close:SetText('x')
    close:SetPaintBackground(false)
    close:SetTextColor(color_white)
    close:SetWide(self.title:GetTall())

    close.DoClick = function(s)
        self:Remove()
    end
end

function PANEL:Init()
    self:SetSize(ScrW()/2, ScrH()/2)
    local marginVertical = ashop.GetSize(20)
    self:DockPadding(marginVertical/2, marginVertical/2, marginVertical/2, marginVertical/2)
    
    local title = vgui.Create('DLabel', self)
    title:SetFont('ashop_14_600')
    title:SetTall(ashop.GetFontHeight('ashop_14_600'))
    title:Dock(TOP)
    title:SetContentAlignment(4)
    title:SetMouseInputEnabled(true)
    title:SetTextColor(color_white)
    self.title = title

    local top = ashop.GetFontHeight('ashop_14_600')
    local buttons = vgui.Create('EditablePanel', self)
    buttons:Dock(BOTTOM)
    buttons:SetTall(top * 1.5)
    buttons:DockMargin(0, marginVertical/2, 0, 0)
    self.buttons = buttons

    local cancel = vgui.Create("DButton", buttons)
    cancel:Dock(LEFT)
    cancel:SetFont('ashop_14_600')
    cancel:SetWide((self:GetWide() - marginVertical)/2 - marginVertical/4)
    cancel:SetText(ashop.L('Cancel'))
    cancel:SetTextColor(white)

    function cancel:Paint(w, h)
        draw.RoundedBox(r/2, 0, 0, w, h, stateOff)
    end

    local send = vgui.Create("DButton", buttons)
    send:Dock(RIGHT)
    send:SetFont('ashop_14_600')
    send:SetWide((self:GetWide() - marginVertical)/2 - marginVertical/4)
    send:SetText(ashop.L('Send'))
    send:SetTextColor(white)

    function send:Paint(w, h)
        draw.RoundedBox(r/2, 0, 0, w, h, stateOff)
    end

    local scroll = vgui.Create('DScrollPanel', self)
    scroll:Dock(FILL)

    send.DoClick = function()
        local keys = {}
        for k, v in ipairs(self.entries) do
            if !v or (!v.ValidInput) or (!v:ValidInput()) then
                return
            end

            if !IsValid(v.nullButton) or v.nullButton.toggled then
                keys[k] = v.currentValue
            end
        end

        self:OnSend(unpack(keys, 1, #self.entries))
        self:Remove()
    end

    cancel.DoClick = function()
        self:Remove()
    end

    ashop.ui.SkinScrollPanel(scroll)
    self.scroll = scroll
    self.entries = {}

    if IsValid(ashop.menu) then
        ashop.menu:PushFocus(self)
    end
end

function PANEL:OnRemove()
    if IsValid(ashop.menu) then
        ashop.menu:PopFocus()
    end
end

function PANEL:ClearAccept()
    self.buttons:Clear()
    local cancel = vgui.Create("DButton", self.buttons)
    cancel:Dock(FILL)
    cancel:SetFont('ashop_14_600')
    cancel:SetText(ashop.L('Cancel'))
    cancel:SetTextColor(white)

    function cancel:Paint(w, h)
        draw.RoundedBox(r/2, 0, 0, w, h, stateOff)
    end
end

function PANEL:OnSend(values)
end

function PANEL:CreateEntry(required, name, type, options, defaultValue)
    local c = vgui.Create('AShop_Entry', self.scroll)
    c:Dock(TOP)
    c:SetTall(0)
    c:DockMargin(0, ashop.GetSize(20), 0, 0)
    c:IsRequired(required)
    c:AddSeparator()

    options = options or {}

    if options.hideSave == nil then
        options.hideSave = true
    end

    if options.nullable == nil then
        options.nullable = !required
    end

    c:SetInput(name, type, defaultValue, options)
    c.boxcolor = ashop.GetColor('Grad2_0')

    table.insert(self.entries, c)

    self:InvalidateLayout( true )
    self:SizeToChildren(false, true)

    return c
end

function PANEL:Paint(w, h)
    draw.RoundedBox(r, 0, 0, w, h, clr)
end

function PANEL:SetTitle(t)
    self.title:SetText(t)
end

function PANEL:Paint(w, h)
    self.boxPoly = self.boxPoly or ashop.ui.RoundedBox(r, 0, 0, w, h)

    ashop.StartStencil()
        draw.NoTexture()
        surface.SetDrawColor(c1R, c1G, c1B)
        surface.DrawPoly(self.boxPoly)
    ashop.ReplaceStencil(1)
        surface.SetDrawColor(c2R, c2G, c2B)
        surface.SetMaterial(grad)
        surface.DrawTexturedRect(0, 0, w, h)
    ashop.EndStencil()
end

derma.DefineControl( "AShop_Form", "", PANEL, "EditablePanel" )