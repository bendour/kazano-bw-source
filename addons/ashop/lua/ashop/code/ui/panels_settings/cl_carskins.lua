local function DrawInterior(editor, carClass, value, parent)
    local horizontalMargin = ashop.GetSize(64)
    local round = ashop.Config.round
    local veh = list.Get("Vehicles")[carClass]
    local marginVertical = ashop.GetSize(20)
    local clr = ashop.GetColor('Grad2_0')
    local clr2 = ashop.GetColor('Grad2_1')

    local tex, myMat = ashop.GetRT()

    local p = vgui.Create("DPanel", editor)
    p:Dock(TOP)
    p:SetTall(editor:GetTall()/2 - horizontalMargin/2)
    p:DockMargin(0, 0, 0, horizontalMargin)
    p:DockPadding(marginVertical, marginVertical, marginVertical, marginVertical)
    function p:Paint(w, h)
        local c = HSVToColor(CurTime()*100, 1, 1)
        render.PushRenderTarget( tex )
        cam.Start2D()
            surface.SetDrawColor( c )
            surface.DrawRect( 0, 0, 512, 512 )
        cam.End2D()
        render.PopRenderTarget()
    end

    local modelContainer = vgui.Create("DPanel", p)
    modelContainer:Dock(RIGHT)
    modelContainer:SetWide(p:GetTall() - marginVertical)
    modelContainer:DockMargin(marginVertical, 0, 0, 0)

    function modelContainer:Paint(w, h)
        draw.RoundedBox(round, 0, 0, w, h, clr2)
    end

    modelContainer:InvalidateLayout(true)

    local model = vgui.Create("DAdjustableModelPanel", modelContainer)
    model:Dock(FILL)
    model:SetModel(veh.Model)
    function model:LayoutEntity()
        self:RunAnimation()
    end

    local oldPress = model.OnMousePressed
    local oldOnMouseReleased = model.OnMouseReleased

    function model:OnMousePressed(mousecode)
        ashop.menu.noquit = true
        oldPress(self, mousecode)
    end

    function model:OnMouseReleased(mousecode)
        oldOnMouseReleased(self, mousecode)
        ashop.menu.noquit = false
    end

    local scroll = vgui.Create("DScrollPanel", p)
    scroll:Dock(FILL)
    ashop.ui.SkinScrollPanel(scroll)

    local r = ashop.Config.round

    for k, v in ipairs(model.Entity:GetMaterials()) do
        local c = vgui.Create('AShop_Entry', scroll)
        c:Dock(TOP)
        c:SetTall(0)
        c:DockMargin(0, marginVertical, 0, 0)
        c:SetInput(v .. "(ID: " .. (k-1) .. ")", TYPE_BOOL, value[k-1], {required = true})
        c.boxcolor = ashop.GetColor('entryColor')

        function c:OnValueChanged(b)
            model.Entity:SetSubMaterial(k-1, b and "!ashop_white" or "")
        end

        function c:Paint(w, h)
            draw.RoundedBox(r, 0, 0, w, h, self.boxcolor)
        end
        
        function c:OnSave(value)
            net.Start('ashop_CarMaterial_Edit')
                net.WriteString(carClass)
                net.WriteBool(value)
                net.WriteUInt(k-1, 8)
            net.SendToServer()
        end

        model.Entity:SetSubMaterial(k-1, value[k-1] and "!ashop_white" or "")
    end
end

ashop.registerParameter(ashop.L('CarSkins'), DrawInterior, function()
    local o = {}

    for k, v in pairs(ashop.carmaterials) do
        table.insert(o, {k, k, v})
    end

    return o
end, function()
    local a = vgui.Create('AShop_Form', ashop.menu)
    a:SetTitle(ashop.L('CarSkins_Create'))
    a:CreateEntry(true, 'Car Class', TYPE_STRING)

    function a:OnSend(wep, ...)
        if ashop.carmaterials[wep] then
            ashop.DermaNotify(ashop.L('CarSkins_AlreadyExist'), 1, 3)
            return
        end

        net.Start('ashop_CarMaterial_Create')
            net.WriteString(wep)
        net.SendToServer()
    end
    a:Center()
end, function(but, settingButton, objectTarget, completeObject)
    function but:DoRightClick()
        CloseDermaMenus()
        local menu = vgui.Create( "AShop_DMenu", but )
        menu:AddOption(ashop.L('Remove'), function()
            ashop.ui.popAskbox(ashop.L('DeleteCarClassSkin', completeObject[1]), ashop.L('CantUndoOperation'), function()
                net.Start('ashop_CarMaterial_Delete')
                    net.WriteString(completeObject[1])
                net.SendToServer()
            end)
        end)

        menu:Open()
    end
end)