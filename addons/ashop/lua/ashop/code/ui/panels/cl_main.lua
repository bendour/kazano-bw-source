local PANEL = {}

local r = ashop.Config.round
local grad = Material('akulla/gradient-d')
local c1R, c1G, c1B = ashop.GetColor('Grad1_0'):Unpack()
local c2R, c2G, c2B = ashop.GetColor('Grad1_1'):Unpack()

function PANEL:Init()
    local sideMargin = ashop.GetSize(64)
    local marginVertical = ashop.GetSize(20)

    self.formAlpha = 0

    self.notifications = {}
    self:MakePopup()
    self:SetSize(ashop.GetSize(1536), ashop.GetSize(864))
    self:Center()
    self:SetMouseInputEnabled(true)
    self:SetKeyboardInputEnabled(true)

    ashop.ui.QuitOnClick(self)

    local navbar = vgui.Create("AShop_Navbar", self)
    navbar:Dock(TOP)
    navbar:SetTall(ashop.GetSize(80))
    navbar:DockMargin(sideMargin, 0, sideMargin, 0)

    local separator = vgui.Create("DPanel", self)
    separator:SetTall(2)
    separator:Dock(TOP)
    separator:SetBackgroundColor(ashop.GetColor("Separator"))

    local rightPartVerticalMargin = ashop.GetSize(20)
    local container = vgui.Create("EditablePanel", self)
    container:DockMargin(sideMargin, rightPartVerticalMargin, sideMargin, rightPartVerticalMargin)
    container:Dock(FILL)

    local t = {}

    for k, v in pairs(ashop.render) do
        table.insert(t, {v.name, function(p)
            local a = vgui.Create('AShop_ShopDisplay', p)
            a:Dock(FILL)
            a:Fill(k)
        end})
    end

    --table.insert(t, {ashop.L('Actions'), function(p)
     --   local a = vgui.Create("AShop_ConfigDisplay", p)
     --   a:Dock(FILL)
     --   a:DockMargin(0, 0, 0, marginVertical)
     --   a:TableFill(ashop.UIUserOptions)
   -- end})

    if (ashop.Config.fullEdit and ashop.Config.fullEdit[LocalPlayer():GetUserGroup()]) or LocalPlayer():IsSuperAdmin() then
        table.insert(t, {ashop.L('Parameters'), function(p)
            local a = vgui.Create("AShop_ConfigDisplay", p)
            a:Dock(FILL)
            a:DockMargin(0, 0, 0, marginVertical)
            a:TableFill(ashop.UIOptions)
        end})
    end

    local pnls = navbar:Fill(t, container)
    local r = math.random(table.Count(ashop.render))

    pnls[r]:DoClick()
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

function PANEL:PushFocus(pnl)
    if !self.form then
        self.blockClicks = vgui.Create('EditablePanel', self)
        self.blockClicks:SetSize(self:GetSize())
        self.blockClicks:SetMouseInputEnabled(true)
        self.blockClicks:SetZPos(10)

        function self.blockClicks:Paint(w, h)
            draw.NoTexture()
            surface.SetDrawColor(0, 0, 0, math.ease.OutQuint(self:GetParent().formAlpha)*230)
            surface.DrawPoly(self:GetParent().boxPoly)

            render.ClearDepth(true)
        end

        self.form = util.Stack()
    else
        self.form:Top():SetMouseInputEnabled(false)
    end

    self.form:Push(pnl)
    pnl:SetZPos(self.form:Size() + 15)
end

function PANEL:PopFocus()
    self.form:Pop()

    if self.form:Size() == 0 then
        self.form = nil
        self.blockClicks:Remove()
    else
        self.form:Top():SetMouseInputEnabled(true)
    end
end

local ft = FrameTime
function PANEL:PaintOver()
    if self.form then
        if self.formAlpha < 220 then
            local b = ft()
            self.formAlpha = math.min(self.formAlpha + b, 1)
        end
    else
        self.formAlpha = 0
    end

    self.notifications = self.notifications or {}
    if !table.IsEmpty(self.notifications) then
        for k, v in ipairs(self.notifications) do
            v:PaintManual()
        end
    end
end

function PANEL:OnRemove()
    net.Start('ashop_openUI')
    net.SendToServer()
end

derma.DefineControl( "AShop_Main", "", PANEL, "EditablePanel" )