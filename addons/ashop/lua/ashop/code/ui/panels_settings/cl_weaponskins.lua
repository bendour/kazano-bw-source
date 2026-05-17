local TEX_SIZE = 512

-- Create the RT
local tex = GetRenderTarget( "AShopWhite", TEX_SIZE, TEX_SIZE )

-- Create a render-able material for our render target
local myMat = CreateMaterial( "ashop_white", "UnlitGeneric", {
	["$basetexture"] = tex:GetName() -- Make the material use our render target texture
} )

function ashop.GetRT()
    return tex, myMat
end

local function DrawInterior(editor, wepKey, value, parent)
    local horizontalMargin = ashop.GetSize(64)
    local round = ashop.Config.round
    local wep = weapons.Get(wepKey) or ashop.DefaultWeaponsHL2[wepKey]
    local marginVertical = ashop.GetSize(20)
    local clr = ashop.GetColor('Grad2_0')
    local clr2 = ashop.GetColor('Grad2_1')

    for i = 1, 2 do
        local key

        if string.find(wepKey, 'fas2') then
            key = i == 1 and "WM" or "VM"
        elseif ashop.DefaultWeaponsHL2[wepKey] then
            key = i
        else
            key = i == 1 and "WorldModel" or "ViewModel"
        end
        local key2 = i == 1 and "wm" or "vm"

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
                surface.DrawRect( 0, 0, TEX_SIZE, TEX_SIZE )
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
        model:SetModel(wep[key])
        function model:LayoutEntity()
            self:RunAnimation()
        end

        //
        timer.Simple(0, function()
            local mX, mY = input.GetCursorPos()
            //input.SetCursorPos(model:GetWide()/2-2, model:GetTall()/2-2)
            
            timer.Simple(0, function()
                model:OnMousePressed( MOUSE_FIRST )
                timer.Simple(0.01, function()
                    model:OnMouseReleased(MOUSE_FIRST)
                    input.SetCursorPos(mX, mY)
                end)
            end)
        end)

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

        local title = vgui.Create("DLabel", p)
        title:Dock(TOP)
        title:SetFont("ashop_14_600")
        title:SetText(key)
        title:SetTall(select(2, title:GetContentSize()))
        title:SetTextColor(color_white)

        local scroll = vgui.Create("DScrollPanel", p)
        scroll:Dock(FILL)
        ashop.ui.SkinScrollPanel(scroll)

        local r = ashop.Config.round

        for k, v in ipairs(model.Entity:GetMaterials()) do
            local c = vgui.Create('AShop_Entry', scroll)
            c:Dock(TOP)
            c:SetTall(0)
            c:DockMargin(0, marginVertical, 0, 0)
            c:SetInput(v .. "(ID: " .. (k-1) .. ")", TYPE_BOOL, value[key2][k-1], {required = true})
            c.boxcolor = ashop.GetColor('entryColor')

            function c:OnValueChanged(b)
                model.Entity:SetSubMaterial(k-1, b and "!ashop_white" or "")
            end

            function c:Paint(w, h)
                draw.RoundedBox(r, 0, 0, w, h, self.boxcolor)
            end
        
            function c:OnSave(value)
                net.Start('ashop_WeaponMaterial_EditBulk')
                    net.WriteString(wepKey)
                    net.WriteBool(value)
                    net.WriteBool(i == 1)
                    net.WriteUInt(k-1, 8)
                net.SendToServer()
            end

            c:OnValueChanged(value[key2][k-1])
        end
    end
end

ashop.registerParameter(ashop.L('WeaponSkins'), DrawInterior, function()
    local o = {}

    for k, v in pairs(ashop.weaponmaterials) do
        table.insert(o, {k, k, v})
    end

    return o
end, function()
    local a = vgui.Create('AShop_Form', ashop.menu)
    a:SetTitle(ashop.L('CreateAWepClassSkin'))
    a:CreateEntry(true, ashop.L('TempWeapon_1'), TYPE_STRING, {
        maxLength = 64,
        minLength = 4
    })

    function a:OnSend(wep, ...)
        if ashop.weaponmaterials[wep] then
            ashop.DermaNotify(ashop.L('AWeaponWithThisClass'), 1, 3)
            return
        end

        local t = {...}

        net.Start('ashop_WeaponMaterial_Create')
            net.WriteString(wep)
        net.SendToServer()
    end
    a:Center()
end, function(but, settingButton, objectTarget, completeObject)
    function but:DoRightClick()
        CloseDermaMenus()
        local menu = vgui.Create( "AShop_DMenu", but )
        menu:AddOption(ashop.L('Remove'), function()
            ashop.ui.popAskbox(ashop.L('DeleteWeaponClassSkin', completeObject[1]), ashop.L('CantUndoOperation'), function()
                net.Start('ashop_WeaponMaterial_Delete')
                    net.WriteString(completeObject[1])
                net.SendToServer()
            end)
        end)

        menu:Open()
    end
end)