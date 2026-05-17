local OBJECT_TYPE = {}

OBJECT_TYPE.Name = ashop.L('TempWeaponClass')
OBJECT_TYPE.UniqueIdentifier = "TempWeapons"

function OBJECT_TYPE.UI_FILL(plyItem, item, pnl, parent, w, h, noCircle)
    local circleParent = vgui.Create("EditablePanel", pnl)
    circleParent:SetSize(w, h)
    circleParent:SetMouseInputEnabled(false)

    local wep = weapons.Get(item.metadata[1]) or ashop.DefaultWeaponsHL2[item.metadata[1]]
    local key

    if string.find(item.metadata[1], 'fas2') then
        key = "WM"
    elseif ashop.DefaultWeaponsHL2[item.metadata[1]] then
        key = 1
    else
        key = "WorldModel"
    end

    if !wep then return end

    local m = vgui.Create( "DModelPanel" , pnl ) -- SpawnIcon
    m:Dock(FILL)
    m:SetModel( wep[key] ) -- Model we want for this spawn icon
    m:SetMouseInputEnabled(false)
    m:SetPaintedManually(true)

    m.FarZ = 4096*10

    local mn, mx = m.Entity:GetRenderBounds()
    local size = 0
    size = math.max( size, math.abs(mn.x) + math.abs(mx.x) )
    size = math.max( size, math.abs(mn.y) + math.abs(mx.y) )
    size = math.max( size, math.abs(mn.z) + math.abs(mx.z) )

    m:SetFOV( 45 )
    m:SetLookAt( (mn + mx) * 0.5 )
    m:SetCamPos( Vector(size, size, 0))

    function m:LayoutEntity() end

    function m:PreDrawModel(ent)
        render.SetLightingMode(1)
    end

    function m:PostDrawModel(ent)
        render.SetLightingMode(0)
    end

    if item.metadata[4] then
        m:SetCamPos(item.metadata[4])
    end

    return true, {m}
end

ashop.RegisterObjectType(OBJECT_TYPE)