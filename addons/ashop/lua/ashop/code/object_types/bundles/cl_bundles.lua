local OBJECT_TYPE = {}

OBJECT_TYPE.Name = ashop.L('Bundles')
OBJECT_TYPE.UniqueIdentifier = "Bundles"

function OBJECT_TYPE.UI_FILL(plyItem, item, pnl, parent, w, h, noCircle)
    local circleParent = vgui.Create("EditablePanel", pnl)
    circleParent:SetSize(w, h)
    circleParent:SetMouseInputEnabled(false)
end

OBJECT_TYPE.ExtraMenuOptions = {
    ['See package'] = function(plyItemTable, item)
        local marginVertical = ashop.GetSize(16)
        local case = vgui.Create('EditablePanel', ashop.menu)
        case:SetSize(ashop.menu:GetWide()/2, ashop.menu:GetTall()/2)
        case:Center()
        case:DockPadding(marginVertical, marginVertical, marginVertical, marginVertical)

        local header = vgui.Create('EditablePanel', case)
        header:Dock(TOP)
        header:SetTall(ashop.GetFontHeight('ashop_16') * 1.5)
        header:DockMargin(0, 0, 0, marginVertical)
        
        local title = vgui.Create('DLabel', header)
        title:Dock(LEFT)
        title:SetText('Items of the bundle')
        title:SetTextColor(color_white)
        title:SetFont("ashop_16")
        title:SetWide(title:GetContentSize())

        local close = vgui.Create('DButton', header)
        close:Dock(RIGHT)
        close:SetFont('ashop_16_600')
        close:SetText('x')
        close:SetPaintBackground(false)
        close:SetTextColor(color_white)
        close:SetWide(header:GetTall())

        function close:DoClick()
            case:Remove()
        end

        ashop.menu:PushFocus(case)

        function case:OnRemove()
            ashop.menu:PopFocus(self)
        end

        function case:Paint(w, h)
            draw.RoundedBox(8, 0, 0, w, h, ashop.GetColor('Grad2_0'))
        end

        local items = vgui.Create('DScrollPanel', case)
        items:Dock(FILL)
        ashop.ui.SkinScrollPanel(items)

        local itemList = vgui.Create('DIconLayout', items)
        itemList:Dock(FILL)
        itemList:SetSpaceX(5)
        itemList:SetSpaceY(5)

        local boxSize = (case:GetWide() - marginVertical*2 - 5 * 5 - 8) / 6

        for k, v in pairs(item.metadata[1]) do
            local p = vgui.Create("AShop_ShopItem", itemList)
            p:SetSize(boxSize, ashop.GetSize(189))
            
            function p:Paint()
                p:SetItem(nil, v[1], true)
            end
        end
    end,
}

ashop.RegisterObjectType(OBJECT_TYPE)