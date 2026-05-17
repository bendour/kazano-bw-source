local OBJECT_TYPE = {}
local methods = include('sh_hiddenmethods.lua')

OBJECT_TYPE.Name = "Case Opening"
OBJECT_TYPE.UniqueIdentifier = "CaseOpening"
OBJECT_TYPE.HideOnUse = true

local bg = Material('akulla/case_texture.jpg')

local function findMat(mdl, name)
    for k, v in ipairs(mdl:GetMaterials()) do
        if string.find(v, name) then
            return k
        end
    end
end

function OBJECT_TYPE.UI_FILL(plyItem, item, pnl, parent, w, h, noCircle, fullSize)
    local circleParent = vgui.Create("EditablePanel", pnl)
    circleParent:SetSize(w, h)
    circleParent:SetMouseInputEnabled(false)

    local c = fullSize and math.max(w, h) or math.max(w, h) * 0.6

    local SpawnI = vgui.Create( "DModelPanel" , circleParent ) -- SpawnIcon
    SpawnI:SetSize(c, c)
    SpawnI:Center()
    SpawnI:SetModel( item.metadata[1] ) -- Model we want for this spawn icon
    SpawnI:SetMouseInputEnabled(false)
    SpawnI:SetPaintedManually(true)

    local mn, mx = SpawnI.Entity:GetRenderBounds()
    local size = 0
    size = math.max( size, math.abs(mn.x) + math.abs(mx.x) )
    size = math.max( size, math.abs(mn.y) + math.abs(mx.y) )
    size = math.max( size, math.abs(mn.z) + math.abs(mx.z) )

    SpawnI:SetFOV( 45 )
    SpawnI:SetCamPos( Vector( -size, size, size ) )
    SpawnI:SetLookAt( (mn + mx) * 0.5 )

    if item.metadata[5] then
        SpawnI.Entity.AShopCase = item.metadata[5]
    end

    if item.metadata[6] then
        SpawnI.Entity.AShopCase2 = item.metadata[5]
    end

    function SpawnI:LayoutEntity(ent)
        return 
    end

    for k, v in pairs({
        [4] = {findMat(SpawnI:GetEntity(), "sticker")},
        [7] = {findMat(SpawnI:GetEntity(), "body")},
        [8] = {findMat(SpawnI:GetEntity(), "colorized")}
    }) do
        if item.metadata[k] and IsValid(SpawnI) then
            local removeFunc = ashop.ui.setMaterialByLink(item.metadata[k], {
                ["$translucent"] = 1,
                ["$vertexalpha"] = 1,
                ["$vertexcolor"] = 1
            }, function(mat)
                mat = mat

                if isfunction(mat) then
                    local thinkFunc = SpawnI.LayoutEntity

                    function SpawnI:LayoutEntity(ent)
                        local mat = mat()

                        for i, j in ipairs(v) do
                            ent:SetSubMaterial(j-1, "!" .. mat:GetName())
                        end

                        if thinkFunc then
                            return thinkFunc(self, ent)
                        end
                    end
                else
                    if !IsValid(SpawnI.Entity) then return end

                    for i, j in ipairs(v) do
                        SpawnI.Entity:SetSubMaterial(j-1, "!" .. mat:GetName())
                    end
                end
            end)

            if removeFunc then
                local f = SpawnI.OnRemove
                function SpawnI:OnRemove()
                    removeFunc()

                    if f then f(self) end
                end
            end
        end
    end

    SpawnI.Entity.AShopCase = item.metadata[5]
    SpawnI.Entity.AShopCase2 = item.metadata[6]

    return true, {SpawnI}, circleParent
end

local grad = Material('akulla/gradient-d25.png')
local eyePos = Vector()
local ang = Angle(0, 0, 0)
local matCircle = Material('akulla/circle.png')

local caseStartPos = Vector(150, 100, -10)
local caseStartAng = Angle(15, 245, 15)
caseStartAng:RotateAroundAxis(caseStartAng:Up(), -90)

local caseEndPos = Vector(100, 0, -60)
local caseEndAng = Angle(0, 180, 0)
caseEndAng:RotateAroundAxis(caseEndAng:Up(), -90)

local function createPnl(item, plyItem)
    local marginVertical = ashop.GetSize(16)
    local rarity = ashop.rarity[item.rarity]
    local caseClr = item.metadata[5] or rarity.clr

    // We want to make it not completely bright
    local h, s, v = ColorToHSV(caseClr)

    s = math.min(1, s)
    v = math.min(0.5, v)
    caseClr = HSVToColor(h, s, v)
    local caseClr25 = ColorAlpha(caseClr, 255*0.25)

    local case = vgui.Create('EditablePanel', ashop.menu)
    case:SetSize(ashop.menu:GetSize())
    case:DockPadding(ashop.menu:GetWide()*0.1, ashop.menu:GetTall()*0.25, ashop.menu:GetWide()*0.1, ashop.menu:GetTall()*0.25)

    ashop.menu:PushFocus(case)

    local mdl = ClientsideModel(item.metadata[1], RENDERGROUP_OTHER)
    mdl:SetNoDraw( true )
    mdl:SetPos(caseStartPos)
    mdl:SetAngles(caseStartAng)
    mdl:ResetSequence('open')

    if item.metadata[5] then
        mdl.AShopCase = item.metadata[5]
    else
        mdl.AShopCase = rarity.clr
    end

    if item.metadata[6] then
        mdl.AShopCase2 = item.metadata[6]
    end

    mdl:SetRenderMode(RENDERMODE_TRANSCOLOR)
    mdl:Spawn()
    //mdl:Spawn()

    function case:OnRemove()
        ashop.menu:PopFocus(self)

        if IsValid(mdl) then
            mdl:Remove()
        end
    end

    local p = eyePos + ang:Forward()*70 + ang:Up()*15
    local particleEmitter = ParticleEmitter(p)
    particleEmitter:SetNoDraw(true)

    local particleEmitterItem = ParticleEmitter(caseEndPos)
    particleEmitterItem:SetNoDraw(true)

    local hue, sat, val = ColorToHSV(caseClr)
    sat = math.max(sat/2, 0)
    val = 1

    local clrEffect = HSVToColor(hue, sat, val)
    local itemEntity

    local display = vgui.Create('EditablePanel', case)
    display:Dock(LEFT)
    display:SetWide(case:GetTall()*0.5)

    local container = vgui.Create('EditablePanel', case)
    container:Dock(RIGHT)
    container:SetWide(case:GetWide() - case:GetWide()*0.3 - case:GetTall()*0.5)

    local title = vgui.Create('DLabel', container)
    title:Dock(TOP)
    title:SetText(item.name)
    title:SetFont('ashop_60_600')
    title:SetTall(select(2, title:GetContentSize()))
    title:SetTextColor(ashop.GetColor('White'))

    local desc = vgui.Create('DLabel', container)
    desc:Dock(TOP)
    desc:SetText(item.metadata[3])
    desc:SetFont('ashop_30_600')
    desc:SetTall(select(2, title:GetContentSize()))
    desc:SetTextColor(ashop.GetColor('White'))

    local itemPerRow = 4
    local itemWidth = math.floor((container:GetWide() - math.ceil(marginVertical * (itemPerRow-1)))/itemPerRow) - 3

    local scroll = vgui.Create("DScrollPanel", container)
    scroll:Dock(TOP)
    scroll:SetTall(ashop.GetSize(189))
    scroll:DockMargin(0, marginVertical, 0, marginVertical)
    ashop.ui.SkinScrollPanel(scroll)

    local vbar = scroll:GetVBar()
    local clrw = ColorAlpha(color_white, 40)
    function vbar:Paint(w, h)
        draw.RoundedBox(2, w - 2, 8, 2, h-16, clrw)
    end

    local itemList = vgui.Create("DIconLayout", scroll)
    itemList:Dock(TOP)
    itemList:SetSpaceY(marginVertical)
    itemList:SetSpaceX(marginVertical)

    for k, v in SortedPairsByMemberValue(item.metadata[2], 2, false) do
        local p = vgui.Create("AShop_ShopItem", itemList)
        p:SetSize(itemWidth, ashop.GetSize(189))

        function p:Paint()
            p:SetItem(nil, v[1], true)
        end
    end

    local buttons = vgui.Create('EditablePanel', container)
    buttons:Dock(TOP)
    buttons:SetTall(ashop.GetFontHeight('ashop_16') * 1.5)

    local close = vgui.Create('DButton', buttons)
    close:SetWide(itemWidth)
    close:Dock(LEFT)
    close:SetFont('ashop_16')
    close:SetText(ashop.L('Close'))

    function close:OnCursorEntered()
        self.clr = ashop.GetColor('White')
        self:SetTextColor(caseClr)
    end

    function close:OnCursorExited()
        self.clr = nil
        self:SetTextColor(ashop.GetColor('White'))
    end

    function close:DoClick()
        case:Remove()
    end

    local h,s,v = ColorToHSV(caseClr)
    s = 0.8
    v = 0.2
    local blackClr = HSVToColor(h,s,v)
    function close:Paint(w, h)
        draw.RoundedBox(ashop.Config.round, 0, 0, w, h, self.clr or blackClr or ashop.GetColor('Grad1_0'))
    end

    if plyItem then
        local open = vgui.Create('DButton', buttons)
        open:SetWide(itemWidth)
        open:Dock(LEFT)
        open:DockMargin(marginVertical, 0, 0, 0)
        open:SetText(ashop.L('Open'))
        open:SetFont('ashop_16_600')
        open:SetTextColor(ashop.GetColor('White'))

        function open:OnCursorEntered()
            self.clr = ashop.GetColor('White')
            self:SetTextColor(caseClr)
        end

        function open:OnCursorExited()
            self.clr = nil
            self:SetTextColor(ashop.GetColor('White'))
        end

        function open:DoClick()
            net.Start('ashop_PlayerEquippedItem')
                net.WriteUInt(plyItem.id, ashop.Config.BitsPlyItemID)
                net.WriteBool(false)
            net.SendToServer()

            net.Receive('AShop_CaseOpening', function()
                local id = net.ReadUInt(ashop.Config.BitsItemID)
                local timerFloat = net.ReadFloat()

                if IsValid(case) then
                    case:StartCaseTransition(id, timerFloat)
                end
            end)
        end
        
        function open:Paint(w, h)
            draw.RoundedBox(ashop.Config.round, 0, 0, w, h, self.clr or caseClr)
        end
    end

    // Put these functions at the end
    function case:StartCaseTransition(itemID, timerFloat)
        local itemTable = ashop.items[itemID]
        local rarity = ashop.rarity[itemTable.rarity]
        local rarityItemClr = rarity.clr

        local hue, sat, val = ColorToHSV(rarityItemClr)
        sat = math.max(sat/2, 0)
        val = 0.5

        local rarityItemClrHSV = HSVToColor(hue, sat, val)

        local pX, pY = container:LocalToScreen(0, 0)
        container:SetParent(case)

        local cursorX, cursorY = case:ScreenToLocal(pX, pY)
        container:SetPos(cursorX, cursorY)

        container:MoveTo(case:GetWide(), cursorY, 1, 0, 0.5)
        container:AlphaTo(0, 0.5, 0)

        local c = CurTime()

        local oldSelf = self.Think
        function self:Think()
            self.LastPaint = RealTime()
            local Cur = CurTime()
            local ratio = Cur - c

            if ratio < 1 then
                local r = math.ease.InOutSine(math.min(Cur - c, 1))
                mdl:SetPos(LerpVector(r, caseStartPos, caseEndPos))
                mdl:SetAngles(LerpAngle(r, caseStartAng, caseEndAng))
            else
                mdl:SetAngles(caseEndAng)
            end

            mdl:FrameAdvance( ( RealTime() - self.LastPaint )  )

            if oldSelf then oldSelf() end
        end

        timer.Simple(1, function()
            if !IsValid(case) or !IsValid(mdl) then return end
            mdl:ResetSequence(2)
        end)

        timer.Simple(2, function()
            if !IsValid(case) then return end

            local wBarGrad = ashop.GetSize(10)
            local itemWidth = ashop.GetSize(150)
            local gradWidth = ashop.GetSize(40)
            case:Clear()
            local holder = vgui.Create('EditablePanel', case)
            holder:Dock(TOP)
            holder:SetTall(ashop.GetSize(189))

            function holder:PaintOver(w, h)
                //ashop.EndStencil()

                DisableClipping(true)
                    surface.SetDrawColor(caseClr)
                    surface.DrawLine(-1, -1, -1, h+2)

                    surface.SetDrawColor(caseClr)
                    surface.DrawLine(w+1, -1, w+1, h+2)

                    surface.SetMaterial(grad)
                    surface.SetDrawColor(caseClr)
                    surface.DrawTexturedRectRotated(-gradWidth/2, h/2, h, gradWidth, 90 )

                    surface.SetMaterial(grad)
                    surface.SetDrawColor(caseClr)
                    surface.DrawTexturedRectRotated(w+gradWidth/2, h/2, h, gradWidth, 270 )
                DisableClipping(false)

                surface.SetDrawColor(color_white)
                surface.DrawRect(w/2 - 2, 0, 4, h)

                surface.SetDrawColor(caseClr)
                surface.DrawTexturedRectRotated(w/2-2 - wBarGrad*0.5, h/2, h, wBarGrad, 90 )
                surface.DrawTexturedRectRotated(w/2+2 + wBarGrad*0.5, h/2, h, wBarGrad, 270 )
            end

            local itemScroller = vgui.Create('EditablePanel', holder)
            itemScroller:SetPos(self:GetWide(), 0)

            local itemNum = math.random(30, 60)
            itemScroller:SetSize(itemWidth * (itemNum + 10), holder:GetTall())

            local generatedItems = methods.GetCaseLuck(item.metadata[2], itemNum + 10)
            generatedItems[itemNum] = itemID

            local pnls = {}

            // We want to put the cursor at the center.
            local itemX = itemNum * itemWidth - case:GetWide()/2 + math.random(itemWidth * 0.25, itemWidth * 0.75)
            // math.random(6, 12)
            itemScroller:MoveTo(-itemX, 0, timerFloat, 0, 0.23, function()
                local white50 = ashop.GetColor('White50', 255*0.5)

                local winPnl = pnls[itemNum]
                local pX, pY = winPnl:LocalToScreen(0, 0)
                //winPnl:Dock(NODOCK)
                //winPnl:SetParent(case)

                local cursorX, cursorY = case:ScreenToLocal(pX, pY)
                winPnl:SetPos(cursorX, cursorY)

                // I need to create a new panel, since removing it from the ItemScroller would shift others panels
                local p = vgui.Create("AShop_ShopItem", case)
                p:SetSize(itemWidth, ashop.GetSize(189))
                p:SetPos(cursorX, cursorY)

                function p:Paint()
                    p:SetItem(nil, itemID, true)
                end

                if rarity.notif_unboxsound then
                    if string.StartsWith(rarity.notif_unboxsound, "http") then
                        sound.PlayURL(rarity.notif_unboxsound, "", function(station, errorID, errorName)
                            if IsValid(station) then
                                station:Play()
                            else
                                print("[AShop] Invalid case opening URL: ", errorID, errorName)
                            end
                        end)
                    else
                        surface.PlaySound(rarity.notif_unboxsound)
                    end
                end

                holder:MoveTo(case:GetWide()/2, holder:GetY(), 0.75)
                itemScroller:MoveTo(itemScroller:GetX() - case:GetWide()/2 + itemWidth, 0, 0.75)
                holder:SizeTo(0, -1, 0.75, 0, nil, function()
                    itemScroller:Remove()
                    holder:Remove()

                    p:MoveTo(case:GetWide()/2 - itemWidth/2, p:GetY(), 0.4, 0, 0.5)
                    local c = CurTime()

                    local quitButton = vgui.Create('DButton', case)
                    quitButton:SetPos(case:GetWide()/2 - itemWidth/2, p:GetY() + p:GetTall() + case:GetTall() * 0.02)
                    quitButton:SetFont('ashop_16')
                    quitButton:SetText(ashop.L('Close'))
                    quitButton:SetTextColor(ashop.GetColor('White'))
                    quitButton:SetSize(itemWidth, select(2, quitButton:GetContentSize()) * 1.5)

                    local h,s,v = ColorToHSV(caseClr)
                    s = 0.8
                    v = 0.2
                    local blackClr = HSVToColor(h,s,v)
                    function quitButton:Paint(w, h)
                        draw.RoundedBox(ashop.Config.round, 0, 0, w, h, blackClr or ashop.GetColor('Grad1_0'))
                    end
                    
                    function quitButton:DoClick()
                        case:Remove()
                    end

                    function quitButton:OnCursorEntered()
                        self.clr = ashop.GetColor('White')
                        self:SetTextColor(caseClr)
                    end
            
                    function quitButton:OnCursorExited()
                        self.clr = nil
                        self:SetTextColor(ashop.GetColor('White'))
                    end

                    function quitButton:Paint(w, h)
                        draw.RoundedBox(ashop.Config.round, 0, 0, w, h, self.clr or caseClr)
                    end

                    function case:PaintOver(w, h)
                        local r = math.min(1, (CurTime() - c)*4)
                        // Detach our item panel
                        white50.a = math.ease.InOutQuad(r) * 200 + 55
                        draw.SimpleText(ashop.L('Obtained'), 'ashop_60_600', w/2, p:GetY() - h*0.02, white50, 1, 4)

                        local part = particleEmitterItem:Add( matCircle, caseEndPos + Vector(0, 0, 80) ) -- Create a new particle at pos
                        if ( part ) then
                            part:SetDieTime( 3 ) -- How long the particle should "live"
                        
                            part:SetStartAlpha( math.Rand(20, 150) ) -- Starting alpha of the particle
                            part:SetEndAlpha( 0 ) -- Particle size at the end if its lifetime
                        
                            part:SetStartSize( math.Rand(0.3, 0.4) ) -- Starting size
                            part:SetEndSize( 0 ) -- Size when removed

                            local clr = (Color(rarityItemClrHSV.r, rarityItemClrHSV.g, rarityItemClrHSV.b):ToVector():GetNormalized() * math.random(-15, 15)):ToColor()
                            part:SetColor(clr.r + rarityItemClrHSV.r, clr.g + rarityItemClrHSV.g, clr.b + rarityItemClrHSV.b)
                        
                            part:SetGravity( Vector( 0, 0, 0 ) ) -- Gravity of the particle
                
                            local vec = VectorRand(-15, 15)
                            //vec.y = -5
                            part:SetVelocity( vec ) -- Initial velocity of the particle
                        end
                    end
                end)
            end)

            for i=0, itemNum + 9 do
                local p = vgui.Create("AShop_ShopItem", itemScroller)
                p:Dock(LEFT)
                p.OutlineOverride = 0
                p:SetSize(itemWidth, ashop.GetSize(189))
                
                function p:Paint()
                    p:SetItem(nil, generatedItems[i+1], true)
                end

                pnls[i+1] = p
            end
        end)
    end

    local findStickersMat = "models/akulla/case/shared/sticker"
    for k, v in ipairs(mdl:GetMaterials()) do
        if v == findStickersMat then
            findStickersMat = v
            break
        end
    end

    for k, v in pairs({
        [4] = {findMat(mdl, "sticker")},
        [7] = {findMat(mdl, "body")},
        [8] = {findMat(mdl, "colorized")}
    }) do
        if item.metadata[k] then
            local removeFunc = ashop.ui.setMaterialByLink(item.metadata[k], {
                ["$translucent"] = 1,
                ["$vertexalpha"] = 1,
                ["$vertexcolor"] = 1
            }, function(mat)
                mat = mat

                if isfunction(mat) then
                    local thinkFunc = case.Think
                    function case:Think()
                        local mat = mat()

                        for i, j in ipairs(v) do
                            mdl:SetSubMaterial(j-1, "!" .. mat:GetName())
                        end

                        if thinkFunc then
                            thinkFunc(self)
                        end
                    end
                else
                    for i, j in ipairs(v) do
                        mdl:SetSubMaterial(j-1, "!" .. mat:GetName())
                    end
                end
            end, 'UnlitGeneric')

            if removeFunc then
                local f = case.OnRemove
                function case:OnRemove()
                    removeFunc()

                    if f then f(self) end
                end
            end
        end
    end

    function case:Paint(w, h)
        // Get Imgur link
        surface.SetMaterial(bg)
        surface.SetDrawColor(255, 255, 255, 255*0.1*ashop.menu.formAlpha)
        surface.DrawTexturedRect(0, 0, w, h)

        surface.SetMaterial(grad)
        surface.SetDrawColor(caseClr)
        surface.DrawTexturedRect(0, h*0.7, w, h*0.3 )

        //local c = mdl:GetColor()
        //render.SetColorModulation( c.r/255, c.g/255, c.b/255 )
        render.SuppressEngineLighting( true )

        local xS, yS = self:LocalToScreen(0, 0)
        cam.Start3D(eyePos, ang, 110, xS, yS, w, h)
            local part = particleEmitter:Add( matCircle, p + Vector(0, math.random(-100, 105), -70) ) -- Create a new particle at pos
            if ( part ) then
                part:SetDieTime( 3 ) -- How long the particle should "live"
            
                part:SetStartAlpha( math.Rand(20, 170) ) -- Starting alpha of the particle
                part:SetEndAlpha( 0 ) -- Particle size at the end if its lifetime
            
                part:SetStartSize( math.Rand(0.2, 0.6) ) -- Starting size
                part:SetEndSize( 0 ) -- Size when removed
                part:SetColor(clrEffect.r, clrEffect.g, clrEffect.b)
            
                part:SetGravity( Vector( 0, 0, 0.5 ) ) -- Gravity of the particle
    
                local vec = VectorRand(-5, 5)
                vec.z = math.Rand(2, 10)
                //vec.y = -5
                part:SetVelocity( vec ) -- Initial velocity of the particle
            end
    
            particleEmitter:Draw()
            particleEmitterItem:Draw()

            render.SuppressEngineLighting( false )
            cam.IgnoreZ(true)

            render.SuppressEngineLighting( true )

            render.SetLightingOrigin( eyePos )
            render.ResetModelLighting( 0.01, 0.01, 0.01 )
            render.SetColorModulation( 1, 1, 1 )
            render.SetBlend(1)

            render.SetModelLighting( BOX_TOP, 1, 1, 1 )
            render.SetModelLighting( BOX_BACK, 0.3, 0.3, 0.3 )
            render.SetModelLighting( BOX_LEFT, 1, 1, 1 )

            mdl:DrawModel()

            cam.IgnoreZ(false)
            render.SuppressEngineLighting( false )
        cam.End3D()

        //render.SetColorModulation( 1, 1, 1 )

    end
end

OBJECT_TYPE.ExtraMenuOptions = {
    [ashop.L('Inspect')] = function(plyItemTable, item, displayer, p)
        createPnl(item, plyItemTable)
    end,
}

matproxy.Add({
    name = "AShopCase", 
    init = function( self, mat, values )
        -- Store the name of the variable we want to set
        self.ResultTo = values.resultvar
    end,
    bind = function( self, mat, ent )
        if ( ent.AShopCase ) then
            mat:SetVector( self.ResultTo, ent.AShopCase:ToVector() )
        end
    end 
})

matproxy.Add({
    name = "AShopCase2", 
    init = function( self, mat, values )
        -- Store the name of the variable we want to set
        self.ResultTo = values.resultvar
    end,
    bind = function( self, mat, ent )
        if ( ent.AShopCase2 ) then
            mat:SetVector( self.ResultTo, ent.AShopCase2:ToVector() )
        end
    end 
})

//
local itemBgClr = ashop.GetColor('ItemBg')
local itemBgClrR, itemBgClrG, itemBgClrB = ashop.GetColor('ItemBg'):Unpack()
local white = ashop.GetColor('White')

local grad = Material('akulla/gradient-d')
local circle = Material('akulla/circle.png', 'smooth')

net.Receive("AShop_CaseOpeningAlert", function()
    local ply = net.ReadPlayer()

    if !IsValid(ply) then return end

    local itemID = net.ReadUInt(ashop.Config.BitsItemID)
    local obtainedItem = ashop.items[itemID]
    local rarity = ashop.rarity[obtainedItem.rarity]
    local rarityStyle = ashop.itemShopEffects[rarity.style]
    local cR = ashop.rarity[obtainedItem.rarity]
    local objectType = ashop.object_types[obtainedItem.object_types]

    if ashop.Config.UnboxChatPrint then
        chat.AddText(ashop.L("Unbox", ply:Nick()), ":", Color(rarity.r, rarity.g, rarity.b), obtainedItem.name)
        return
    end

    local textSizeMain = draw.GetFontHeight('ashop_32_600')
    local textSizeSub = draw.GetFontHeight('ashop_24_600')
    local m = ashop.GetSize(8)

    surface.SetFont("ashop_32_600")
    local w = surface.GetTextSize(obtainedItem.name)

    surface.SetFont("ashop_16")
    local w2 = surface.GetTextSize(ashop.L("Unbox", ply:Nick()))
    local h = textSizeMain + textSizeSub + m * 4

    local p = vgui.Create('EditablePanel')
    p:SetSize(m * 4 + math.max(w, w2) + h + m * 2, h)
    p:DockPadding(m * 2, m * 2, m * 2, m * 2)
    local y = ScrH()*0.25 - p:GetTall()/2
    p:SetPos(-p:GetWide(), y)

    local start = CurTime()
    local time = ashop.Config.notif_time or 5
    local holdDiv = ashop.Config.notif_holdDiv or 5
    local holdPart = ashop.Config.notif_holdPart or 3

    if rarity.notif_unboxsound and (ply != LocalPlayer() or !IsValid(ashop.menu)) then
        if string.StartsWith(rarity.notif_unboxsound, "http") then
            sound.PlayURL(rarity.notif_unboxsound, "", function(station, errorID, errorName)
                if IsValid(station) then
                    station:Play()
                else
                    print("[AShop] Invalid case opening URL: ", errorID, errorName)
                end
            end)
        else
            surface.PlaySound(rarity.notif_unboxsound)
        end
    end

    function p:Think()
        local diff = 1 - (start + time - CurTime()) / time
        local value = 0

        if diff < 1 / holdDiv then
            value = math.ease.InOutCubic(diff * holdDiv) / 2
        elseif diff > 1 / holdDiv * (holdPart + (holdDiv - holdPart) / 2) then
            local cur = diff - (1 / holdDiv) * (holdPart + (holdDiv - holdPart) / 2)
            local localDiff = cur * holdDiv

            value = 0.5 + math.ease.InOutCubic(localDiff) / 2
        else
            value = 0.5
        end

		self:SetX((ScrW() + self:GetWide()) * value - self:GetWide())
	end

    timer.Simple(time, function()
        p:Remove()
    end)

    local container = vgui.Create('EditablePanel', p)
    container:Dock(LEFT)
    container:SetWide(h - m * 4)
    container:DockMargin(0, 0, m, 0)

    if obtainedItem.picture_link then
        local mat
        function container:Paint(w, h)
            local m = isfunction(mat) and mat() or mat
    
            if m and !m:IsError() then
                local mW = math.min(w*0.6, h*0.6)
                surface.SetDrawColor(255, 255, 255)
                surface.SetMaterial(m)
                surface.DrawTexturedRect((w - mW)/2, h*0.2, mW, mW)
            end
        end
                
        local removeFunc = ashop.ui.setMaterialByLink(obtainedItem.picture_link, {
            ["$translucent"] = 1,
            ["$vertexalpha"] = 1,
            ["$vertexcolor"] = 1
        }, function(m)
            mat = m
        end, 'UnlitGeneric')
    
        if removeFunc then
            function container:OnRemove()
                removeFunc()
            end
        end
    elseif objectType.UI_FILL then
        local ModelDrawTable = nil
        _, ModelDrawTable = objectType.UI_FILL(nil, obtainedItem, container, container, h - m * 4,
            h - m * 4, false, true)
        container.ModelDrawTable = ModelDrawTable
    end

    local title = vgui.Create('DLabel', p)
    title:Dock(TOP)
    title:SetText(ashop.L("Unbox", ply:Nick()))
    title:SetFont('ashop_16')
    title:SetTextColor(ColorAlpha(color_white, 120))
    title:SetTall(textSizeSub)
    title:SetContentAlignment(2)
    //title:DockMargin(0, 0, 0, m)

    local title2 = vgui.Create('DLabel', p)
    title2:Dock(TOP)
    title2:SetText(obtainedItem.name)
    title2:SetFont('ashop_32_600')
    title2:SetTextColor(color_white)
    title2:SetTall(textSizeMain)
    title2:SetContentAlignment(8)

    function p:Paint(w, h)
        if !p.outlinedItemBox then
            p.outlinedItemBox, p.polyshape = ashop.ui.RoundedBoxOutlined(p.OutlineOverride or ashop.Config.round, 0, 0, w, h, itemBgClr, rarity.clr, 2, function()
                surface.SetMaterial(grad)
                surface.SetDrawColor(cR.r, cR.g, cR.b, 25)
                surface.DrawTexturedRect(0, h*0.6, w, h*0.4 )
            end)
        end

        if rarityStyle and rarityStyle.preDraw then
			if !self.isEquipped then
				ashop.StartStencil()
					draw.NoTexture()
					surface.SetDrawColor(itemBgClrR, itemBgClrG, itemBgClrB)
					surface.DrawPoly(self.polyshape)
			end

			ashop.ReplaceStencil(1)

			if rarityStyle then
				rarityStyle.preDraw(self, w, h, self.isEquipped, rarity.clr)
			end

			surface.SetDrawColor(cR.r, cR.g, cR.b, 20)
			surface.SetMaterial(circle)
			surface.DrawTexturedRect(w*0.1, h*0.1, w*0.8, w*0.8)
        end

        self.outlinedItemBox(tobool((rarityStyle and rarityStyle.preDraw) or self.isEquipped))
    end
end)

ashop.RegisterObjectType(OBJECT_TYPE)