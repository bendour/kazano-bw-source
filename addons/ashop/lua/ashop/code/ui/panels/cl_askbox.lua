
local IsValid = IsValid
local ScrW = ScrW
local ScrH = ScrH
local vgui = vgui
local select = select
local draw = draw

local PANEL = {}
local oldAskBox
local black

function PANEL:Init()
    black = ashop.GetColor('entryColor')
    if oldAskBox and IsValid(oldAskBox) then
        oldAskBox:Remove()
    end

    local w = ScrW()*0.35

    self:SetSize(w, ScrH()*0.12)
    self:Center()
    self:DockPadding(w * 0.03, w * 0.03, w * 0.03, w * 0.03)

    local title = vgui.Create("DLabel", self)
    title:SetFont("ashop_30_600")
    title:SetText("Sans titre")
    title:Dock(TOP)
    title:SetTall(select(2, title:GetContentSize()))
    title:SetContentAlignment(5)
    title:SetTextColor(color_white)

    self.title = title

    local title2 = vgui.Create("DLabel", self)
    title2:SetFont("ashop_16")
    title2:SetText("")
    title2:SetContentAlignment(5)
    title2:Dock(TOP)
    title2:SetTall(select(2, title:GetContentSize()))
    title2:SetTextColor(color_white)
    self.desc = title2

    local container = vgui.Create("EditablePanel", self)
    container:Dock(BOTTOM)

    container:SetTall(draw.GetFontHeight("ashop_14_600"))

    local buttonValid = vgui.Create("DButton", container)
    buttonValid:Dock(RIGHT)
    buttonValid:SetWide(self:GetWide()/2)
    buttonValid:SetFont("ashop_14_600")
    buttonValid:SetText(ashop.L('Accept'))
    ashop.ui.WhiteHover(buttonValid, 50)

    function buttonValid:Paint() end

    local buttonCancel = vgui.Create("DButton", container)
    buttonCancel:Dock(RIGHT)
    buttonCancel:SetWide(self:GetWide()/2)
    buttonCancel:SetFont("ashop_14_600")
    buttonCancel:SetText(ashop.L('Cancel'))
    ashop.ui.WhiteHover(buttonCancel, 50)

    local oldSelf = self
    function buttonCancel:DoClick()
        local a = oldSelf.OnRefuse
        ashop.menu:PopFocus()
        oldSelf.cleanedFocus = true
        oldSelf:Remove()

        if a then
            a()
        end
    end
    
    function buttonValid:DoClick()
        local a = oldSelf.OnAccept
        ashop.menu:PopFocus()
        oldSelf.cleanedFocus = true
        oldSelf:Remove()

        if a then
            a()
        end
    end
    
    function buttonCancel:Paint() end
    function buttonValid:Paint() end

    oldAskBox = self
    ashop.menu:PushFocus(self)
end

function PANEL:Paint(w, h)
    draw.RoundedBox(ashop.Config.round, 0, 0, w, h, black)
end

function PANEL:OnRemove()
    if !self.cleanedFocus then
        ashop.menu:PopFocus()
    end
end

function PANEL:OnAccept()
end

vgui.Register("ashop_AskBox", PANEL, "EditablePanel")