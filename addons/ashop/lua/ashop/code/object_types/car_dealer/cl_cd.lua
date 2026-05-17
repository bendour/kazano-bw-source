local OBJECT_TYPE = {}

OBJECT_TYPE.Name = "Cars"
OBJECT_TYPE.UniqueIdentifier = "Cars"

// It was... special to read in the simfphys code
local function createWheel(index, attachmentpos, height, swap_y, entList, ent, locaLAngForward, LocalAngRight)
    local mdl

    if entList.CustomWheelModel_R and (index > 2) then
        mdl = entList.CustomWheelModel_R
    elseif entList.CustomWheelModel then
        mdl = entList.CustomWheelModel
    else
        mdl = "models/props_vehicles/tire001c_car.mdl"
    end

    local fAng = ent:LocalToWorldAngles( locaLAngForward )
	local rAng = ent:LocalToWorldAngles( LocalAngRight )
	local Forward = fAng:Forward() 
	local Right = swap_y and -rAng:Forward() or rAng:Forward()
	local Up = ent:GetUp()

    if entList.CustomWheelModel then
        local ghostAng = Right:Angle()
        local mirAng = swap_y and 1 or -1
		ghostAng:RotateAroundAxis(Forward, entList.CustomWheelAngleOffset.p * mirAng)
		ghostAng:RotateAroundAxis(Right, entList.CustomWheelAngleOffset.r * mirAng)
		ghostAng:RotateAroundAxis(Up, -entList.CustomWheelAngleOffset.y)

        local Camber = entList.CustomWheelCamber or 0
		ghostAng:RotateAroundAxis(Forward, Camber * mirAng)
        fAng = ghostAng
    end

    local cm = ClientsideModel(mdl)
    cm:SetPos(attachmentpos - Up * height)
    cm:SetAngles(fAng)
    cm:Spawn()
    cm:SetParent(ent)
    cm:SetNoDraw(true)
    return cm
end

local ang0900 = Angle(0,90,0)
local function createWheels(entList, ent)
    local t = {}
    for k, v in ipairs({"FL", "FR", "RL", "RR"}) do
        local completeName = "CustomWheelPos" .. v

        if entList[completeName] then
            t[v] = ent:LocalToWorld( entList[completeName] )
        else
            t[v] = ent:GetAttachment( ent:LookupAttachment( "wheel_" .. string.lower(v) ) ).Pos
        end
    end

    local pAngL = ent:WorldToLocalAngles( ((t['FL'] + t['FR']) / 2 - (t['RL'] + t['RR']) / 2):Angle() )
    pAngL.r = 0
    pAngL.p = 0

    local yAngL = pAngL - ang0900
    yAngL:Normalize()

    local wheels = {}

    for k, v in ipairs({"FL", "FR", "RL", "RR", "ML", "MR"}) do
        local completeName = "CustomWheelPos" .. v

        if entList[completeName] or (v != "ML" and v != "MR") then
            table.insert(wheels, createWheel(k,
                entList[completeName] and ent:LocalToWorld( entList[completeName] ) or ent:GetAttachment( ent:LookupAttachment( "wheel_" .. string.lower(v) ) ).Pos, 
                k <= 2 and entList.FrontHeight or entList.RearHeight,
                v[2] == "R",
                entList,
                ent,
                pAngL, yAngL))
        end
    end

    return wheels
end

function OBJECT_TYPE.UI_FILL(plyItem, item, pnl, parent, w, h, noCircle)
    local circleParent = vgui.Create("EditablePanel", pnl)
    circleParent:SetSize(w, h)
    circleParent:SetMouseInputEnabled(false)

    local id = item.metadata[2] or item.metadata[1]
    local isSimfphys = string.find(id, "sim_fphys")
    local car

    if isSimfphys then
        car = list.Get("simfphys_vehicles")[id]
    else
        car = list.Get("Vehicles")[id]
    end

    if !car then return end

    local m = vgui.Create( "DModelPanel" , pnl ) -- SpawnIcon
    m:Dock(FILL)
    m:SetModel( car.Model ) -- Model we want for this spawn icon
    m:SetMouseInputEnabled(false)
    m:SetPaintedManually(true)

    m.FarZ = 4096*10

    local wheels

    if isSimfphys then
        wheels = createWheels(car.Members, m.Entity)
    end

    local mn, mx = m.Entity:GetRenderBounds()
    local size = 0
    size = math.max( size, math.abs(mn.x) + math.abs(mx.x) )
    size = math.max( size, math.abs(mn.y) + math.abs(mx.y) )
    size = math.max( size, math.abs(mn.z) + math.abs(mx.z) )

    m:SetFOV( 45 )
    m:SetLookAt( (mn + mx) * 0.5 )
    m:SetCamPos( Vector(size, size, size))

    function m:LayoutEntity() end

    function m:PreDrawModel(ent)
        render.SetLightingMode(1)
    end

    function m:PostDrawModel(ent)
        render.SetLightingMode(0)

        if !wheels then return end
        for k, v in ipairs(wheels) do
            v:DrawModel()
        end
    end

    function m:OnRemove()
        if !wheels then return end
        for k, v in ipairs(wheels) do
            v:Remove()
        end
    end

    if item.metadata[4] then
        m:SetCamPos(item.metadata[4])
    end

    return true, {m}
end

ashop.RegisterObjectType(OBJECT_TYPE)