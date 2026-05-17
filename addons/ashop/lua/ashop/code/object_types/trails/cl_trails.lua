local alreadyLoaded = {}

function ashop.loadParticle(fileName, particleName)
    if !fileName then return end
    if !alreadyLoaded[fileName] then
        alreadyLoaded[fileName] = {}
        game.AddParticles( fileName )
    end

    if !particleName then return end
    if !alreadyLoaded[fileName][particleName] then
        alreadyLoaded[fileName][particleName] = true
        PrecacheParticleSystem( particleName )
    end
end

local OBJECT_TYPE = {}

OBJECT_TYPE.Name = ashop.L('TrailsClass')
OBJECT_TYPE.UniqueIdentifier = "Trails"

function OBJECT_TYPE.UI_FILL(plyItem, item, pnl, parent, w, h, noCircle, fullSize)
    local circleParent = vgui.Create("EditablePanel", pnl)
    circleParent:SetSize(w, h)
    circleParent:SetMouseInputEnabled(false)

    local c = fullSize and math.max(w, h) or math.max(w, h) * 0.4

    // What an hack...
    local SpawnI = vgui.Create( "DPanel" , circleParent ) -- SpawnIcon
    SpawnI:SetSize(c, c)
    SpawnI:Center()
    
    local r1
    function SpawnI:Paint(w, h)
        if !r1 then
            r1 = ashop.ui.RoundedBox(ashop.Config.round, 0, 0, w, h)
        end

        ashop.StartStencil()
            surface.SetDrawColor(1,1,1,1)
            draw.NoTexture()
            surface.DrawPoly(r1)
        ashop.ReplaceStencil(1)
            surface.SetDrawColor(255, 255, 255)
            surface.SetTexture(surface.GetTextureID(item.metadata[2]))
            surface.DrawTexturedRect(0, 0, w, h)
        ashop.EndStencil()
    end
end

// Rendering
function OBJECT_TYPE.OnLocalEquip(ply, plyItem, item)
    OBJECT_TYPE.OnEquip(ply, plyItem, item)
end

function OBJECT_TYPE.OnEquip(ply, plyItem, item)
    if !item.metadata[1] then
        OBJECT_TYPE.OnRemove(ply, plyItem, item)
        assert(item.metadata[6], "Trail particle-based don't have a file dir, item name: " .. item.name)

        ashop.loadParticle(item.metadata[6], item.metadata[2])

        // Get attachment
        if item.metadata[3] then
            local attach = ply:LookupAttachment(item.metadata[4] or '') or 0

            local particle = CreateParticleSystem( ply, item.metadata[2], PATTACH_POINT_FOLLOW, attach )
            plyItem.particle = {particle}
        else
            // Look at these tricks bro
            local mdl = ClientsideModel("models/hunter/blocks/cube025x025x025.mdl")
            mdl:SetMoveType( MOVETYPE_NONE )
            mdl:SetNoDraw(true)

            local b = ply:LookupBone(item.metadata[4] or '')
            
            if !b then 
                print('[AShop] This bone does not exist on this model:', ply:GetModel())
                print('[AShop] We will use the first, found bone')
            end

            local boneVec, boneAngle = ply:GetBonePosition(b or 1)
            mdl:Spawn()
            mdl:SetAngles(ply:GetAngles())
            mdl:SetPos(ply:GetPos())

            mdl:FollowBone(ply, b or 1)
            plyItem.particle = {CreateParticleSystem( mdl, item.metadata[2], 4, 0 ), mdl}
        end
    end
end

function OBJECT_TYPE.OnLocalRemove(ply, plyItem, item)
    OBJECT_TYPE.OnRemove(ply, plyItem, item)
end

// All players
function OBJECT_TYPE.OnMetadataUpdate(ply, plyItem, item, metadataKey, oldValue, newValue)
    if IsValid(plyItem.particle) then
        plyItem.particle:Remove()
    end

    if !item.metadata[1] then return end

    OBJECT_TYPE.OnEquip(ply, plyItem, item)
end

function OBJECT_TYPE.OnRemove(ply, plyItem, item)
    if !plyItem.particle then return end

    if plyItem.particle[1] and plyItem.particle[1]:IsValid() then
        plyItem.particle[1]:StopEmission(false, true)
    end

    if IsValid(plyItem.particle[2]) then
        plyItem.particle[2]:Remove()
    end

    plyItem.particle = nil
end

ashop.RegisterObjectType(OBJECT_TYPE)