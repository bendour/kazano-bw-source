local PANEL = {}

local vec40 = Vector( 0, 0, 40 )
local clr50 = Color( 50, 50, 50 )

function PANEL:Init()
	self.Entity = nil

	self.LastPaint = 0
	self.DirectionalLight = {}
	self.FarZ = 4096*10

	self:SetLookAt( vec40 )
	self:SetFOV( 70 )

	self:SetText( "" )
	self:SetAnimSpeed( 0.5 )
	self:SetAnimated( false )

	self:SetAmbientLight( clr50 )

	self:SetDirectionalLight( BOX_TOP, color_white )
	self:SetDirectionalLight( BOX_FRONT, color_white )

	self:SetColor( color_white )

    self:DoClick()

    local marginVertical = ashop.GetSize(20)
    local hFont = ashop.GetFontHeight('ashop_icon_20')
    local modeltoolbox = vgui.Create('EditablePanel', self)
    modeltoolbox:Dock(TOP)
    modeltoolbox:SetTall(hFont)
    modeltoolbox:SetMouseInputEnabled(true)
    modeltoolbox:DockMargin(modeltoolbox:GetTall()/4, modeltoolbox:GetTall()/4, 0, 0)

    local modelBG = vgui.Create('DButton', modeltoolbox)
    modelBG:Dock(LEFT)
    modelBG:SetFont('ashop_icon_16')
    modelBG:SetTextColor(color_white)
    modelBG:SetText("*")
    modelBG:SetWide(modeltoolbox:GetTall())

    local stateOn = ashop.GetColor('StateOn')
    local stateOff = ashop.GetColor('blurpleBg')
    local blurpleBg = ashop.GetColor('blurpleBg')

    function modelBG:Paint(w, h)
        draw.RoundedBox(4, 0, 0, w, h, self.toggled and stateOn or stateOff)
    end

    modelBG.DoClick = function()
        self.colorBgOverride = !self.colorBgOverride and Color(200, 200, 200) or nil
        modelBG.toggled = !modelBG.toggled
    end

    local modelHeadFocus = vgui.Create('DButton', modeltoolbox)
    modelHeadFocus:Dock(LEFT)
    modelHeadFocus:SetFont('ashop_icon_16')
    modelHeadFocus:SetTextColor(color_white)
    modelHeadFocus:SetText(",")
    modelHeadFocus:SetWide(modeltoolbox:GetTall())
    modelHeadFocus:DockMargin(modeltoolbox:GetTall()/4, 0, 0, 0)

    function modelHeadFocus:Paint(w, h)
        draw.RoundedBox(4, 0, 0, w, h, self.toggled and stateOn or blurpleBg)
    end

    modelHeadFocus.DoClick = function(s)
        s.toggled = !s.toggled

        if s.toggled then
            self:BoneFocus('ValveBiped.Bip01_Head1', 0.33)
        else
            self:BoneFocus('ValveBiped.Bip01_Spine2')
        end
    end
end

local mdlpnlBg = ashop.GetColor('Grad2_0')
local blurpleOutline = ashop.GetColor('blurple')
local blurpleOutlineR, blurpleOutlineG, blurpleOutlineB = blurpleOutline:Unpack()

local mdlpnlGradBg = ashop.GetColor('Grad2_1')
local mdlpnlGradBgR, mdlpnlGradBgG, mdlpnlGradBgB = mdlpnlGradBg:Unpack()
local grad = Material('akulla/gradient-d')

function PANEL:Paint(w, h)
    if !self.displayerContainerPaint then
        self.displayerContainerPaint, self.polyPaint = ashop.ui.RoundedBoxOutlined(ashop.Config.round, 0, 0, w, h, mdlpnlBg, blurpleOutline, 2, function()
            surface.SetMaterial(grad)
            surface.SetDrawColor(mdlpnlGradBgR, mdlpnlGradBgG, mdlpnlGradBgB)
            surface.DrawTexturedRectRotated( w/2, h/2, w*1.5, h*1.05, 5 )
        end, true)
    end

	if ( !IsValid( self.Entity ) ) then
        ashop.EndStencil()
        return
    end

    render.SetStencilPassOperation( STENCIL_KEEP )
    self.displayerContainerPaint(nil, self.colorBgOverride)

	local x, y = self:LocalToScreen( 0, 0 )

	self:LayoutEntity( self.Entity )

	local ang = self.aLookAngle
	if ( !ang ) then
		ang = ( self.vLookatPos - self.vCamPos ):Angle()
	end

	cam.Start3D( self.vCamPos, ang, self.fFOV, x, y, w, h, 5, self.FarZ )
        local blend = render.GetBlend()
        local old_r, old_g, old_b = render.GetColorModulation()

        render.SuppressEngineLighting( true )
        render.SetColorModulation( self.colColor.r / 255, self.colColor.g / 255, self.colColor.b / 255 )
        render.SetBlend( ( self:GetAlpha() / 255 ) * ( self.colColor.a / 255 ) ) -- * surface.GetAlphaMultiplier()

        for i = 0, 6 do
            local col = self.DirectionalLight[ i ]
            if ( col ) then
                render.SetModelLighting( i, col.r / 255, col.g / 255, col.b / 255 )
            end
        end

        self:DrawModel()

        render.SuppressEngineLighting( false )
        render.SetColorModulation( old_r, old_g, old_b )
        render.SetBlend( blend )
	cam.End3D()

    // Redraw the bar

    surface.SetDrawColor(blurpleOutlineR, blurpleOutlineG, blurpleOutlineB)
    surface.DrawRect(0, h-2, w, 2)
    ashop.EndStencil()

	self.LastPaint = RealTime()
end

function PANEL:CreateUserEntry(plyItem, itemParamTable, itemParamID)
    local oldValue = (plyItem.metadata or {})[itemParamID]

    if oldValue then
        if itemParamTable.type == TYPE_VECTOR then
            oldValue = Vector(oldValue)
        elseif itemParamTable.type == TYPE_ANGLE then
            oldValue = Angle(oldValue)
        end
    end

    if IsValid(self.bonusPanel) then
        self.bonusPanel:Remove()
    end

    local realItem = ashop.items[plyItem.item_id]
    local object_data = ashop.object_types[realItem.object_types]

    local p = vgui.Create('AShop_Entry', self)
    p:Dock(BOTTOM)
    p.SmallVersion = true
    p:SetTall(0)
    p:DockMargin(ashop.GetSize(ashop.Config.round*2), 0, ashop.GetSize(ashop.Config.round*2), ashop.GetSize(ashop.Config.round*2))
    p:SetInput(itemParamTable.name, itemParamTable.type, oldValue, itemParamTable.options)

    local c = ashop.GetColor('entryColor')
    function p:Paint(w, h)
        draw.RoundedBox(8, 0, 0, w, h, c)
    end

    p.OnValueChanged = function(_, newVal)
        local tbl = self.Entity.ashop_data.items[plyItem.id].metadata
        if itemParamTable.type == TYPE_VECTOR or itemParamTable.type == TYPE_ANGLE then
            local cpy = tbl[itemParamID] and Vector(tbl[itemParamID]) or nil
            tbl[itemParamID] = newVal

            object_data.OnMetadataUpdate(self.Entity, self.Entity.ashop_data.items[plyItem.id],
                realItem, itemParamID, cpy, tbl[itemParamID])
        else
            object_data.OnMetadataUpdate(self.Entity, self.Entity.ashop_data.items[plyItem.id],
                realItem, itemParamID, tbl[itemParamID], tbl[itemParamID])
        end
    end

    p.OnSave = function(_, value)
        p:Remove()

        net.Start('ashop_PlayerItem_MetaDataUpdate')
            net.WriteUInt(plyItem.id, ashop.Config.BitsPlyItemID)
            net.WriteUInt(itemParamID, 8)

            ashop.Network.GetWriteFunction(itemParamTable.type,
                value, p.options)
        net.SendToServer()
    end

    p.OnCancel = function()
        p:Remove()
    
        self.Entity.ashop_data.items[plyItem.id].metadata = self.Entity.ashop_data.items[plyItem.id].metadata or {}
        self.Entity.ashop_data.items[plyItem.id].metadata[itemParamID] = oldValue
    
        object_data.OnMetadataUpdate(self.Entity, self.Entity.ashop_data.items[plyItem.id],
            realItem, itemParamID, cpy, self.Entity.ashop_data.items[plyItem.id].metadata)
    end

    self.bonusPanel = p
end

function PANEL:LayoutEntity( ent )
    local c = self.progressCam

    if !c or c >= 1 then return end

    c = c + (FrameTime() * 1.5)
    c = c > 1 and 1 or c

    self.progressCam = c

    oldCamPos(self, LerpVector(c, self.oldPos, self.targetPos))
    oldLookAt(self, LerpVector(c, self.oldLook, self.targetLook))
end

function PANEL:BoneFocus(bone, ratio, offset)
    local b = self.Entity:LookupBone(bone)
    local r = (self.Entity:GetModelRadius()  * (ratio or 1)) * 0.75

    if !b then return end

    self:SetCamPos(self.Entity:GetBonePosition(b) + Vector(r, r, 5))
    self:SetLookAt(self.Entity:GetBonePosition(b))
end

function PANEL:InitItems(c)
    local lp = LocalPlayer()
    self.Entity.ashop_oldmodel = lp.ashop_oldmodel
    self.Entity.ashop_data = {items = c and c.items or {}, equipped = {}}
    self.Entity.DModelPanel = self

    for object_type, v in pairs((c or lp.ashop_data or {}).equipped or {}) do
        for sub_type, data in pairs(v) do
            for slot, plyItemID in pairs(data) do
                self:EquipItem(plyItemID, slot)
            end
        end
    end
end

function PANEL:PreDrawModel(ent)
    local ang = self.aLookAngle
    if ( !ang ) then
        ang = ( self.vLookatPos - self.vCamPos ):Angle()
    end

    local ent = self:GetEntity()

    if ent.RemovePACPart then
        pac.ForceRendering(true)
        pac.ShowEntityParts(ent)
    end

    ent:DrawModel()

    if self.WeaponModel then
        self.WeaponModel:DrawModel()

        if self.WeaponModel.WMAng && self.WeaponModel.WMPos then
            local b = ent:LookupBone("ValveBiped.Bip01_R_Hand")

            if !b then return end
            pos, ang = ent:GetBonePosition(b)
        
            if pos and ang then
                ang:RotateAroundAxis(ang:Right(), self.WeaponModel.WMAng[1])
                ang:RotateAroundAxis(ang:Up(), self.WeaponModel.WMAng[2])
                ang:RotateAroundAxis(ang:Forward(), self.WeaponModel.WMAng[3])

                pos = pos + self.WeaponModel.WMPos[1] * ang:Right() 
                pos = pos + self.WeaponModel.WMPos[2] * ang:Forward()
                pos = pos + self.WeaponModel.WMPos[3] * ang:Up()
                
                self.WeaponModel:SetRenderOrigin(pos)
                self.WeaponModel:SetRenderAngles(ang)
                self.WeaponModel:DrawModel()
            end
        end
    end

    ashop.PostPlayerDraw(ent, nil, self)

    if ent.RemovePACPart then
        pac.RenderOverride(ent, "opaque")
        pac.RenderOverride(ent, "translucent")
        pac.ForceRendering(false)
    end

    return true
end

local uid = -1
function PANEL:EquipItem(plyItem, slot, itemID)
    local is_remove = false
    local plyItemTable = self.Entity.ashop_data.items[plyItem]
    local returnValue

    if !plyItemTable then
        local lp = LocalPlayer()
        if lp.ashop_data.items[plyItem] then
            local t = lp.ashop_data.items[plyItem]

            // Since some object_types hold variable inside the plyItem, we need to recreate a clean one
            self.Entity.ashop_data.items[plyItem] = {
                id = t.id,
                item_id = t.item_id,
                metadata = t.metadata,
                premium_buy = t.premium_buy,
                price_buy = t.price_buy,
                when = t.when
            }
        else
            self.Entity.ashop_data.items[uid] = {
                id = uid,
                item_id = itemID or plyItem,
            }

            plyItem = uid
            returnValue = uid
            uid = uid - 1
        end
    else
        local itemTable = ashop.items[plyItemTable.item_id]

        if itemTable and (self.Entity.Entity.ashop_data.equipped[itemTable.object_types] or {})[itemTable.sub_types or 0] then
            for key, v in ipairs(self.Entity.Entity.ashop_data.equipped[itemTable.object_types][itemTable.sub_types or 0] or {}) do
                if plyItem == v then
                    slot = key
                    is_remove = true
                    break
                end
            end
        end
    end

    ashop.EquipChange(self.Entity, plyItem, slot, is_remove)
    return returnValue, uid
end

function PANEL:OnRemove()
    ashop.UnequipAll(self.Entity)

    if IsValid(self.WeaponModel) then
        self.WeaponModel:Remove()
    end

    if IsValid(self.Entity) then
        self.Entity:Remove()
    end
end

function PANEL:EquipWeapon(wepClass)
    if IsValid(self.WeaponModel) then
        self.WeaponModel:Remove()
    end

    local wep
    local stored = weapons.Get(wepClass or ashop.Config.modelPanelDisplayWeapon)
    if stored then
        wep = stored.WorldModel
    end

    if !wep then
        wep = "models/weapons/w_357.mdl"
    end

    local wep = ClientsideModel(wep)

    wep:Spawn()
    wep:SetNoDraw(true)
    wep:SetParent(self:GetEntity(), self:GetEntity():LookupAttachment("anim_attachment_RH"))
    wep:AddEffects(EF_BONEMERGE)

    if stored then
        wep.WMAng = stored.WMAng
        wep.WMPos = stored.WMPos
    end

    self.WeaponModel = wep
    self.Entity.Weapon = wep
    wep.ashop_WepClass = ashop.Config.modelPanelDisplayWeapon
end

function PANEL:SetModel( strModelName )

	-- Note - there's no real need to delete the old
	-- entity, it will get garbage collected, but this is nicer.

    local c = IsValid(self.Entity) and self.Entity.ashop_data or nil

	if ( IsValid( self.Entity ) ) then
        ashop.UnequipAll(self.Entity)
		self.Entity:Remove()
		self.Entity = nil
	end

	-- Note: Not in menu dll
	if ( !ClientsideModel ) then return end

	self.Entity = ClientsideModel( strModelName, RENDERGROUP_OTHER )
	if ( !IsValid( self.Entity ) ) then return end

	self.Entity:SetNoDraw( true )
	self.Entity:SetIK( false )

	-- Try to find a nice sequence to play
	local iSeq = self.Entity:LookupSequence( "walk_all" )
	if ( iSeq <= 0 ) then iSeq = self.Entity:LookupSequence( "WalkUnarmed_all" ) end
	if ( iSeq <= 0 ) then iSeq = self.Entity:LookupSequence( "walk_all_moderate" ) end

	if ( iSeq > 0 ) then self.Entity:ResetSequence( iSeq ) end

    self:InitItems(c)

    if self.WeaponModel then
        self.Entity.Weapon = self.WeaponModel
        self.WeaponModel:SetParent(self:GetEntity(), self:GetEntity():LookupAttachment("anim_attachment_RH"))
        self.WeaponModel:AddEffects(EF_BONEMERGE)
    end

    self.Entity:SetSequence("idle_passive")
end

local startFov, startAng, StartPosX
function PANEL:OnMousePressed(mousecode)
    ashop.menu.noquit = true
end

function PANEL:OnMouseReleased(mousecode)
    ashop.menu.noquit = false
end

function PANEL:Think()
    if not self:IsHovered() and not isnumber(startFov) and not isnumber(startAng) then return end

    local CurX, CurY = self:ScreenToLocal(gui.MouseX(), gui.MouseY())
    
    if input.IsMouseDown(MOUSE_RIGHT) then
        if not isnumber(startFov) then startFov = CurY end
        
        local newFov = self:GetFOV() - (((startFov - CurY)/self:GetTall())*1.5)
        if newFov >= 20 and newFov <= 50 then
            self:SetFOV(newFov)
        end
    else
        startFov = nil
    end

    if input.IsMouseDown(MOUSE_LEFT) then 
        if not isnumber(startAng) then startAng = CurX end
        if not isnumber(startY) then startY = CurY end
        
        local newAng = self.Entity:GetAngles().yaw - (((startAng - CurX)/self:GetWide())*4)
        local newY = (startY - CurY)*0.001
        
        local currentLook = self:GetLookAt()

        local newLookAt = (currentLook.z-newY)
        if newLookAt > -20 && newLookAt < 70 then
            self:SetLookAt(Vector(0, 0, newLookAt))
        end
        
        self.Entity:SetAngles(Angle(0, newAng, 0))
    else
        startAng = nil
        startY = nil
    end
end

derma.DefineControl( "AShop_DModelPanel", "", PANEL, "DModelPanel")