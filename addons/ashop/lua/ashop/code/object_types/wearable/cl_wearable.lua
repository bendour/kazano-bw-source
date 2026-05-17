local OBJECT_TYPE = {}

OBJECT_TYPE.Name = ashop.L('ClothesClass')
OBJECT_TYPE.UniqueIdentifier = "Wearables"

function OBJECT_TYPE.UI_FILL(plyItem, item, pnl, parent, w, h, noCircle, fullSize)
    local circleParent = vgui.Create("EditablePanel", pnl)
    circleParent:SetSize(w, h)
    circleParent:SetMouseInputEnabled(false)
    circleParent:SetPaintedManually(true)

    local c = fullSize and math.max(w, h) or math.max(w, h) * 0.6

    local SpawnI = vgui.Create( "DModelPanel" , circleParent )
    SpawnI:SetSize(c, c)
    SpawnI:Center()
    SpawnI:SetModel(item.metadata[1])
    SpawnI:SetMouseInputEnabled(false)
    SpawnI:SetPaintedManually(true)

    local oldPaint = SpawnI.Paint
    function SpawnI:Paint(w, h)
        oldPaint(SpawnI, w, h)
    end
    
    if item.metadata[11] and isnumber(item.metadata[11]) then
        SpawnI.Entity:SetSkin(item.metadata[11])
    end

    if item.metadata[9] then
        SpawnI:SetColor(item.metadata[9])
    end
    local mdlMin, mdlMax = SpawnI.Entity:GetModelBounds()
    local center = (mdlMax - mdlMin)/2 + mdlMin
    local tab = PositionSpawnIcon(SpawnI.Entity, center)

    function SpawnI:PreDrawModel(ent)
        render.SetLightingMode(1)
    end

    function SpawnI:PostDrawModel(ent)
        render.SetLightingMode(0)
    end

    if item.metadata[13] then
        tab.origin = item.metadata[13]
    end

    SpawnI:SetFOV(tab.fov)
    SpawnI:SetCamPos(tab.origin)
    SpawnI:SetLookAt(center)

    function SpawnI:LayoutEntity() end
    SpawnI.ZFar = tab.zfar

    if item.metadata[12] then
        // Have fun looking the DModelPanel code for an explanation
        SpawnI:SetCamPos(( tab.origin - center ):Angle():Forward() * item.metadata[12])
    end

    return true, {SpawnI}
end

function OBJECT_TYPE.OnLocalEquip(ply, plyItem, item)
    OBJECT_TYPE.OnEquip(ply, plyItem, item)
end

local emptyAng = Angle()
local emptyVec = Vector()
local vec1 = Vector(1, 1, 1)
local seqAnim, actAnim = "idle_camera", ACT_HL2MP_IDLE_CAMERA

local function playEquipAnim(ply)
    local seqNum = ply:LookupSequence(seqAnim)
    local seqDur = ply:SequenceDuration(seqNum)/4

    if ply:IsPlayer() then
        hook.Add("CalcMainActivity", "ashop_animwearable", function(plyAnim, vel)
            if ply == plyAnim then
                return actAnim, seqNum
            end
        end)

        timer.Simple(seqDur, function()
            hook.Remove("CalcMainActivity", "ashop_animwearable")
        end)
    end
end

// Ghetto trick
// I can't verify if the player was visible this frame
// So I use the last frame
// PrepLayerDraw does not work, since some PM are rendered after some accessories ( Ex. Opaque acc, translucent ply )
// I can't use DrawModel because of bonemerged accessories
// It could be do-able, but this would be painful
local wasRenderedThisFrame = {}
local wasRenderedPostFrame = {}

hook.Add('PrePlayerDraw', 'ashop_AddFrameWearable', function(ply)
    wasRenderedThisFrame[ply] = true
end)

hook.Add('PostRender', 'ashop_ClearFrameWearable', function()
    wasRenderedPostFrame = wasRenderedThisFrame
    wasRenderedThisFrame = {}
end)

function OBJECT_TYPE.OnEquip(ply, plyItem, item)
    // item object: {itemTable, metadata, sub_category}
    local boneName = ashop.GetSubTypeAttributeByPlayerItem(plyItem, 1)
    local model = ashop.GetItemAttribute(plyItem, item, 1)
    local pac3 = ashop.GetItemAttribute(plyItem, item, 2)

    local boneID = ply:LookupBone(boneName)

    if !boneID then
        print('[AShop] Wearable object_type. This model "' .. ply:GetModel() .. '" does not have the bone "' .. boneName .. '"')
        return
    end

    playEquipAnim(ply)
    local cm = ClientsideModel(model)
    cm.owner = ply:GetClass()

    if !ply:IsPlayer() then
        cm:SetNoDraw(true)
    elseif ply == LocalPlayer() then
        function cm:RenderOverride(f)
            // The issue is that PrePlayerDraw may not use the correct flags to render
            // the prop, I think. This way is less intrusive since it let source
            // handle rendering flags without having me to interfere with a custom
            // entity or any bullshit.
            if (!ply.ShouldDrawLocalPlayer or ply:ShouldDrawLocalPlayer()) then
                self:DrawModel(f)
            end
        end
    else
        function cm:RenderOverride(f)
            if wasRenderedPostFrame[ply] then
                self:DrawModel(f)
            end
        end
    end

    local offsetPos = (ashop.GetItemAttribute(plyItem, item, 3) or emptyVec) +
        (ashop.GetItemAttribute(plyItem, item, 6) or emptyVec)

    local offsetAng = (ashop.GetItemAttribute(plyItem, item, 4) or emptyAng) +
        (ashop.GetItemAttribute(plyItem, item, 5) or emptyAng)

    local offsetScale = vec1 *
        (ashop.GetItemAttribute(plyItem, item, 7) or vec1) +
        (ashop.GetItemAttribute(plyItem, item, 8) or emptyVec)

    offsetScale.x = math.Clamp(offsetScale.x, 0.02, 5)
    offsetScale.y = math.Clamp(offsetScale.y, 0.02, 5)
    offsetScale.z = math.Clamp(offsetScale.z, 0.02, 5)

    if offsetScale != emptyVec then
        local mat = Matrix()
        mat:Scale(offsetScale)
        cm:EnableMatrix("RenderMultiply", mat)
    end

    local s = ashop.GetItemAttribute(plyItem, item, 11)
    cm:SetSkin(isnumber(s) and s or 1)

    local clr = ashop.GetItemAttribute(plyItem, item, 9)
    if clr then
        cm:SetRenderMode(RENDERMODE_TRANSCOLOR)
        cm:SetColor(clr)
    end
    
    if pac and pac3 and ashop.pac3[pac3] and ashop.pac3[pac3].outfit then
        local e = ashop.pac3[pac3].model_attach and cm or ply

        pac.SetupENT(e)
        e:AttachPACPart(ashop.pac3[pac3].outfit)
    end

    if item.metadata[10] then
        cm:SetParent(ply)
        cm:AddEffects(EF_BONEMERGE)
    end

    cm:Spawn()

    if ply.Team and ashop.Config.jobsBlockEquipAccessories[ply:Team()] and IsValid(cm) then
        plyItem.ent[1]:Remove()
    end

    plyItem.ent = {cm, boneName, model, offsetPos, offsetAng, offsetScale}
end

function OBJECT_TYPE.OnLocalRemove(ply, plyItem, item)
    OBJECT_TYPE.OnRemove(ply, plyItem, item)
end

function OBJECT_TYPE.OnLocalFPDraw(ply)
end

// All players
function OBJECT_TYPE.OnMetadataUpdate(ply, plyItem, item, metadataKey, oldValue, newValue)
    if !plyItem.ent then return end

    local cm = plyItem.ent[1]

    if metadataKey == 1 then
        if IsValid(cm) then
            cm:Remove()
        end

        OBJECT_TYPE.OnEquip(ply, plyItem, item)
    elseif metadataKey == 5 or metadataKey == 4 then
        plyItem.ent[5] = (ashop.GetItemAttribute(plyItem, item, 4) or emptyAng) +
            (ashop.GetItemAttribute(plyItem, item, 5) or emptyAng)
    elseif metadataKey == 3 or metadataKey == 6 then
        plyItem.ent[4] = (ashop.GetItemAttribute(plyItem, item, 3) or emptyVec) +
            (ashop.GetItemAttribute(plyItem, item, 6) or emptyVec)
    elseif metadataKey == 7 or metadataKey == 8 then
        plyItem.ent[6] = vec1 *
            (ashop.GetItemAttribute(plyItem, item, 7) or vec1) +
            (ashop.GetItemAttribute(plyItem, item, 8) or emptyVec)

        plyItem.ent[6].x = math.Clamp(plyItem.ent[6].x, 0.02, 5)
        plyItem.ent[6].y = math.Clamp(plyItem.ent[6].y, 0.02, 5)
        plyItem.ent[6].z = math.Clamp(plyItem.ent[6].z, 0.02, 5)

        local mat = Matrix()
        mat:Scale(plyItem.ent[6])
        cm:EnableMatrix("RenderMultiply", mat)
    elseif metadataKey == 9 then
        if newValue then
            cm:SetColor(newValue)
            cm:SetRenderMode(RENDERMODE_TRANSCOLOR)
        else
            cm:SetRenderMode(0)
            cm:SetColor(color_white)
        end
    elseif metadataKey == 11 then
        cm:SetSkin(newValue or 1)
    elseif metadataKey == 2 then
        if oldValue and ashop.pac3[oldValue] and ashop.pac3[oldValue].outfit then
            ply:RemovePACPart(ashop.pac3[oldValue].outfit)
        end

        if newValue and ashop.pac3[newValue] and ashop.pac3[newValue].outfit then
            if !ply.AttachPACPart then
                pac.SetupENT(ply)
            end

            ply:AttachPACPart(ashop.pac3[newValue].outfit)
        end
    elseif metadataKey == 10 then
        if newValue then
            cm:AddEffects(EF_BONEMERGE)
        else
            cm:RemoveEffects(EF_BONEMERGE)
        end
    elseif metadataKey == 11 then
        cm:SetSkin(newValue or 0)
    end
end

function OBJECT_TYPE.OnRemove(ply, plyItem, item)
    if plyItem.ent then
        local pac3 = ashop.GetItemAttribute(plyItem, item, 2)

        if pac3 and ashop.pac3[pac3] then
            if ashop.pac3[pac3].model_attach then
                plyItem.ent[1]:RemovePACPart(ashop.pac3[pac3].outfit)
            else
                ply:RemovePACPart(ashop.pac3[pac3].outfit)
            end
        end

        plyItem.ent[1]:Remove()
        playEquipAnim(ply)
    end

    plyItem.ent = nil
end

function OBJECT_TYPE.OnPostPlayerDraw(ply, plyItem, item, inModelPanel)
    if !plyItem.ent or item.metadata[10] then return end

    local cm = plyItem.ent[1]
    if ply.Team and ashop.Config.jobsBlockEquipAccessories[ply:Team()] then
        if IsValid(cm) then
            plyItem.ent[1]:Remove()
        end

        return
    end

    if !IsValid(cm) then
        plyItem.ent[1]:Remove()
        OBJECT_TYPE.OnEquip(ply, plyItem, item)
        cm = plyItem.ent[1]
    end

    local boneName = plyItem.ent[2]

    local boneID = ply:LookupBone(boneName)

    if !inModelPanel then
        if !boneID then
            cm:SetNoDraw(true)
            return
        else
            cm:SetNoDraw(false)
        end
    end

    // Uh oh, lag deleted it
    local matrix = ply:GetBoneMatrix(boneID)
    if !matrix then return end
    local bonePos, boneAng = LocalToWorld( plyItem.ent[4], plyItem.ent[5], matrix:GetTranslation(), matrix:GetAngles() )

    cm:SetPos(bonePos)
    cm:SetAngles(boneAng)
    cm:SetPredictable(false)
    cm:SetupBones()

    if !inModelPanel then
        //cm:DrawModel(8)
    else
        // Don't throw tomatoes at me, this is how DModelPanel manage this
        if cm.RemovePACPart then
            pac.ShowEntityParts(cm)
            pac.ForceRendering(true)
            cm:SetupBones()
            pac.FlashlightDisable(true)

            force_draw_localplayer = true
        end
        local c = cm:GetColor()
        local old_r, old_g, old_b = render.GetColorModulation()

        render.SetColorModulation( c.r / 255, c.g / 255, c.b / 255 )
        cm:DrawModel()
        render.SetColorModulation( old_r, old_g, old_b )

        if cm.RemovePACPart then
            pac.RenderOverride(cm, "opaque")
            pac.RenderOverride(cm, "translucent")

            force_draw_localplayer = false

            pac.FlashlightDisable(false)
            pac.ForceRendering(false)
        end
    end
end

ashop.RegisterObjectType(OBJECT_TYPE)



// Cmd
local backtrack = {}
concommand.Add("ashop_OpenClothesMenu", function()
    local ply = LocalPlayer()
    local b = ashop.GetObjectTypeIDByUID('Wearables')

    local l = {}
    backtrack = backtrack or {}

    for k, v in pairs(ashop.object_types[b].sub_cat) do
        local equipped, count = ply:AShop_SlotStateGet(b, k)
        backtrack[k] = backtrack[k] or {}

        if count < 1 then continue end

        for i = 1, count do
            if !equipped[i] and (!backtrack[k][i] or !ply.ashop_data.items[backtrack[k][i]]) then continue end

            local t = {
                name = v.name .. ": " .. i,
                data = {
                    subCat = k,
                    slotID = i,
                    item = equipped[i] or backtrack[k][i],
                    isEquipped = equipped[i] != nil,
                    count = count
                },
            }

            table.insert(l, t)

            local c = t.data.isEquipped and color_white or ColorAlpha(color_white, 100)

            if string.StartsWith(v.metadata[2], 'ht') then
                ashop.ui.setMaterialByLink(v.metadata[2], {
                    ["$translucent"] = 1,
                }, function(m)
                    t.data.drawMe = function(x, y, w, h)
                        surface.SetMaterial(isfunction(m) and m() or m)
                        surface.SetDrawColor(c)
                        surface.DrawTexturedRect(x, y, w, h)
                    end
                end, 'UnlitGeneric')
            else
                t.data.drawMe = function(x, y, w, h)
                    draw.SimpleText(v.metadata[2], 'ashop_icon_50', x+w/2, y+h/2, c, 1, 1)
                end
            end

            ashop.ui.setMaterialByLink(v.metadata[2], nil, function(m)
                t.data.mat = m
            end, 'UnlitGeneric')
        end
    end

    if table.IsEmpty(l) then return end

    local u = vgui.Create('AShop_RadialMenu')
    function u:CallbackItem(data)
        net.Start('ashop_PlayerEquippedItem')
            net.WriteUInt(data.item, ashop.Config.BitsPlyItemID)
            net.WriteBool(true)
            net.WriteUInt(data.slotID, math.ceil(math.log(data.count, 2)))
        net.SendToServer()

        backtrack[data.subCat][data.slotID] = data.item
        u:Remove()
    end

    function u:DrawItem(data, x, y, w, h, key)
        if data.drawMe then
            data.drawMe(x, y, w, h)
            draw.NoTexture()
        end
    end

    u.desc = "Remove/Add an accessory"

    u:SetContents(table.Count(l), l)
end)