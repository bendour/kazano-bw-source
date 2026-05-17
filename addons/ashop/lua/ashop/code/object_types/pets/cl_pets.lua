local OBJECT_TYPE = {}

OBJECT_TYPE.Name = ashop.L('PetClass')
OBJECT_TYPE.UniqueIdentifier = "Pets"

net.Receive('ashop_pet', function()
    local eIndex = net.ReadUInt(16)
    local id = net.ReadUInt(ashop.Config.BitsPlyItemID)
    local ply = net.ReadEntity()

    timer.Create('ashop_waitpetEnt_' .. eIndex, 1, 300, function()
        local e = Entity(eIndex)

        if !IsValid(ply) then
            timer.Remove('ashop_waitpetEnt_' .. eIndex)
            return
        end

        if !IsValid(e) or !e.RegenerateClientsideModel or !ply.ashop_data then return end

        local plyItem = ply.ashop_data.items[id]
        local item = ashop.items[plyItem.item_id]

        e.ashop_item = item
        e.ashop_plyitem = plyItem
        ply.ashop_data.items[id].ent = e
        e.owner = ply

        e:RegenerateClientsideModel()

        timer.Remove('ashop_waitpetEnt_' .. eIndex)
    end)
end)

function OBJECT_TYPE.UI_FILL(plyItem, item, pnl, parent, w, h, noCircle, fullSize)
    local circleParent = vgui.Create("EditablePanel", pnl)
    circleParent:SetSize(w, h)
    circleParent:SetMouseInputEnabled(false)

    local c = fullSize and math.max(w, h) or math.max(w, h) * 0.6

    local SpawnI = vgui.Create( "SpawnIcon" , circleParent ) -- SpawnIcon
    SpawnI:SetSize(c, c)
    SpawnI:Center()
    SpawnI:SetModel( item.metadata[1], item.metadata[2] ) -- Model we want for this spawn icon
    SpawnI:SetMouseInputEnabled(false)

    if item.metadata[2] then
        SpawnI:SetSkin(item.metadata[2])
    end
end

function OBJECT_TYPE.OnEquip(ply, plyItem, item, _, slotID)
    if !ply:IsPlayer() then
        if IsValid(plyItem.modelPanelPreview) then
            plyItem.modelPanelPreview:Remove()
        end

        local invertDir = slotID == 1
        local e = ClientsideModel(item.metadata[1])
        e:SetModelScale(math.Clamp((item.metadata[9] or 1), 0.1, 2))
        e:SetNoDraw(true)

        local p = select(2, e:GetModelBounds())*e:GetModelScale()
        p.y = !invertDir and (-p.y) or p.y
        p.z = 0

        p:Rotate(ply:GetAngles())
        e:SetPos(ply:GetPos() + p)
        e:SetAngles(Angle(0, ply:GetAngles().y + (!invertDir and 45 or -45), 0))
        e:SetParent(ply)

        if item.metadata[2] then
            e:SetSkin(item.metadata[2])
        end
        e.offsetY = item.metadata[3] or 0
        e:Spawn()

        plyItem.modelPanelPreview = e
    end
end

function OBJECT_TYPE.OnRemove(ply, plyItem, item)
    if IsValid(plyItem.modelPanelPreview) then
        plyItem.modelPanelPreview:Remove()
    end
end

function OBJECT_TYPE.OnPostPlayerDraw(ply, plyItem, item, inModelPanel)
    if inModelPanel and plyItem.modelPanelPreview and IsValid(plyItem.modelPanelPreview) then
        local self = plyItem.modelPanelPreview
        local seq = item.metadata[5]

        local old = self:GetCycle()
        local new = (CurTime() * (self.seqSpeed or 1) / self:SequenceDuration()) % 1
        self:SetCycle(new)
        
        if old > new or !self.seqSpeed and !table.IsEmpty(seq) then
            local t = seq[math.random(#seq)]
            self.seqSpeed = t[2]
            self:SetSequence(t[1])
        end

        self:DrawModel()
    end
end

// All players / // 00000000000000000
function OBJECT_TYPE.OnMetadataUpdate(ply, plyItem, item, metadataKey, oldValue, newValue)
    return true
end

ashop.RegisterObjectType(OBJECT_TYPE)