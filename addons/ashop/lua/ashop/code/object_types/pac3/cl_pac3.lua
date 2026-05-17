local OBJECT_TYPE = {}

OBJECT_TYPE.Name = ashop.L('Pac3')
OBJECT_TYPE.UniqueIdentifier = "Pac3"

function OBJECT_TYPE.UI_FILL(plyItem, item, pnl, parent, w, h, noCircle)
    local m = vgui.Create( "DModelPanel" , parent ) -- SpawnIcon
    m:SetSize(parent:GetSize())
    m:SetModel( LocalPlayer():GetModel() ) -- Model we want for this spawn icon
    m:SetMouseInputEnabled(false)
    m:SetPaintedManually(true)

    local fov = LocalPlayer():GetFOV()
    m:SetFOV(fov)
    m.FarZ = 4096*10

    local mn, mx = m.Entity:GetRenderBounds()
    local size = 0
    size = math.max( size, math.abs(mn.x) + math.abs(mx.x) )
    size = math.max( size, math.abs(mn.y) + math.abs(mx.y) )
    size = math.max( size, math.abs(mn.z) + math.abs(mx.z) )

    m:SetFOV( 45 )
    m:SetCamPos( Vector( size, size, size ) )
    m:SetLookAt( (mn + mx) * 0.5 )

    if item.metadata[1] then
        local pac3 = item.metadata[2]
        if pac and pac3 and ashop.pac3[pac3] and ashop.pac3[pac3].outfit then
            pac.SetupENT(m.Entity)
            m.Entity:AttachPACPart(ashop.pac3[pac3].outfit)

            function m:PreDrawModel(ent)
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
            
                if ent.RemovePACPart then
                    pac.RenderOverride(ent, "opaque")
                    pac.RenderOverride(ent, "translucent")
                    pac.ForceRendering(false)
                end

                ashop.PostPlayerDraw(ent, nil, self)
            
                return true
            end
        end
    else
        ashop.loadParticle(item.metadata[3], item.metadata[4])
        local ply = m:GetEntity()

        /*

        if item.metadata[5] and item.metadata[5] != '' then
            local b = ply:LookupBone(item.metadata[5] or '')
            
            if !b and item.metadata[5] != '' then
                print('[AShop] This bone does not exist on this model:', ply:GetModel())
                print('[AShop] We will use the first, found bone')
            end
            
            local mdl = ClientsideModel("models/hunter/blocks/cube025x025x025.mdl")
            mdl:SetMoveType( MOVETYPE_NONE )
            mdl:SetNoDraw(true)
            
            local boneVec, boneAngle = ply:GetBonePosition(b or 1)
            mdl:Spawn()
            mdl:SetAngles(ply:GetAngles())
            mdl:SetPos(ply:GetPos())
            
            mdl:FollowBone(ply, b or 1)
            //plyItem.particle = {CreateParticleSystem( mdl, item.metadata[4], 4, 0 ), mdl}
        else
            if item.metadata[4] then
                //    plyItem.particle = {CreateParticleSystem( ply, item.metadata[4], item.metadata[7] or 0, 0 )}
            end
        end
        */
    end

    m.LayoutEntity = function() end

    return true, {m}
end

function OBJECT_TYPE.OnLocalEquip(ply, plyItem, item)
    OBJECT_TYPE.OnEquip(ply, plyItem, item)
end

function OBJECT_TYPE.OnEquip(ply, plyItem, item)
    if item.metadata[1] then
        local pac3 = ashop.GetItemAttribute(plyItem, item, 2)

        if pac and pac3 and ashop.pac3[pac3] and ashop.pac3[pac3].outfit then
            pac.SetupENT(ply)
            ply:AttachPACPart(ashop.pac3[pac3].outfit, ply)
        end
    else
        ashop.loadParticle(item.metadata[3], item.metadata[4])

        if item.metadata[5] and item.metadata[5] != '' then
            local b = ply:LookupBone(item.metadata[5] or '')

            if !b and item.metadata[5] != '' then
                print('[AShop] This bone does not exist on this model:', ply:GetModel())
                print('[AShop] We will use the first, found bone')
            end

            local mdl = ClientsideModel("models/hunter/blocks/cube025x025x025.mdl")
            mdl:SetMoveType( MOVETYPE_NONE )
            mdl:SetNoDraw(true)

            local boneVec, boneAngle = ply:GetBonePosition(b or 1)
            mdl:Spawn()

            mdl:SetPos(ply:GetPos())
            mdl:FollowBone(ply, b or 1)
            mdl:SetAngles(ply:GetAngles() + (item.metadata[8] or Angle()))
            plyItem.particle = {mdl:CreateParticleEffect(item.metadata[4], 0)}
        else
            if item.metadata[4] then
                plyItem.particle = {CreateParticleSystem( ply, item.metadata[4], item.metadata[7] or 0, 0 )}
            end
        end

        plyItem.particle[1]:SetShouldDraw(ply:IsPlayer())
    end
end

function OBJECT_TYPE.OnLocalRemove(ply, plyItem, item)
    OBJECT_TYPE.OnRemove(ply, plyItem, item)
end

// All players
function OBJECT_TYPE.OnMetadataUpdate(ply, plyItem, item, metadataKey, oldValue, newValue)
    if item.metadata[1] and metadataKey == 2 then
        if oldValue and ashop.pac3[oldValue] and ashop.pac3[oldValue].outfit then
            ply:RemovePACPart(ashop.pac3[oldValue].outfit)
        end

        if newValue and ashop.pac3[newValue] and ashop.pac3[newValue].outfit then
            if !ply.AttachPACPart then
                pac.SetupENT(ply)
            end

            ply:AttachPACPart(ashop.pac3[newValue].outfit)
        end
    elseif metadataKey == 8 and plyItem.particle and plyItem.particle[2] then
        plyItem.particle[2]:SetAngles(newValue or Angle())
    end
end

function OBJECT_TYPE.OnRemove(ply, plyItem, item)
    if item.metadata[1] then
        if !item.metadata[2] then return end
        ply:RemovePACPart(ashop.pac3[item.metadata[2]].outfit)
    else
        if !plyItem.particle then return end

        if plyItem.particle[1] and plyItem.particle[1]:IsValid() then
            plyItem.particle[1]:StopEmission(false, true)
        end
    
        if IsValid(plyItem.particle[2]) then
            plyItem.particle[2]:Remove()
        end
    
        plyItem.particle = nil
    end
end

function OBJECT_TYPE.OnPostPlayerDraw(ply, plyItem, item, inModelPanel)
    if !inModelPanel then return end

    if item.metadata[1] then
        if !ply.RemovePACPart then return end
        //pac.RenderOverride(ply, "opaque")
        //pac.RenderOverride(ply, "translucent", true)
    else
        plyItem.particle[1]:Render()
    end
end

ashop.RegisterObjectType(OBJECT_TYPE)