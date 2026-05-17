local OBJECT_TYPE = {}

OBJECT_TYPE.Name = "Entities"
OBJECT_TYPE.UniqueIdentifier = "Entities"

function OBJECT_TYPE.UI_FILL(plyItem, item, pnl, parent, w, h, noCircle, fullSize)
    local circleParent = vgui.Create("EditablePanel", pnl)
    circleParent:SetSize(w, h)
    circleParent:SetMouseInputEnabled(false)

    local entClass = item.metadata[1]

    // wtf ?: ents.Create cannot be called while rendering
    /*
    local e = ents.CreateClientside(entClass)

    if IsValid(e) then
        mdl = e:GetModel()
        e:Remove()
    end
    */
    local mdl

    if !mdl then
        local eT = scripted_ents.Get(entClass)
        mdl = eT.Model or eT.model or item.metadata[2]
    end

    // rip
    local circleParent = vgui.Create("EditablePanel", pnl)
    circleParent:SetSize(w, h)
    circleParent:SetMouseInputEnabled(false)

    local c = fullSize and math.max(w, h) or math.max(w, h) * 0.6

    if mdl then
        local SpawnI = vgui.Create( "SpawnIcon" , circleParent ) -- SpawnIcon
        SpawnI:SetSize(c, c)
        SpawnI:Center()
        SpawnI:SetModel( mdl ) -- Model we want for this spawn icon
        SpawnI:SetMouseInputEnabled(false)
    else
        local mat = Material('vgui/entities/' .. entClass)

        if item.metadata[2] and (!mat or mat:IsError()) then return end

        local SpawnI = vgui.Create( "DPanel" , circleParent ) -- SpawnIcon
        SpawnI:SetSize(c, c)
        SpawnI:Center()

        function SpawnI:Paint(w, h)
            surface.SetMaterial(mat)
            surface.SetDrawColor(255, 255, 255)
            surface.DrawTexturedRect(0, 0, w, h)
        end
    end
end

ashop.RegisterObjectType(OBJECT_TYPE)