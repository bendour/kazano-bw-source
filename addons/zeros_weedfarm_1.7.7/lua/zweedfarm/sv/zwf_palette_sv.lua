if CLIENT then return end
zwf = zwf or {}
zwf.f = zwf.f or {}

function zwf.f.Palette_Initialize(Palette)
    Palette.WeedList = {}
end

function zwf.f.Palette_GetWeedValue(id,amount,thc)
    local wBlockValue = zwf.config.Plants[id].sellvalue

    local amount_mul = (1 / (zwf.config.Jar.Capacity * 4)) * amount
    wBlockValue = wBlockValue * amount_mul

    local finalValue = wBlockValue * (1 + ((zwf.config.THC.sellprice_influence / zwf.config.THC.Max) * thc))

    zwf.f.Debug("Weed: " .. zwf.config.Plants[id].name)
    zwf.f.Debug("THC: " .. thc)
    zwf.f.Debug("wBlockValue: " .. wBlockValue)
    zwf.f.Debug("finalValue: " .. finalValue)
    return finalValue
end

util.AddNetworkString("zwf_Palette_Update")
function zwf.f.Palette_Update(Palette)
    net.Start("zwf_Palette_Update")
    net.WriteEntity(Palette)
    net.WriteTable(Palette.WeedList)
    net.Broadcast()
end

function zwf.f.Palette_AddWeed(Palette,weed)

    local weedID = weed:GetWeedID()

    local finalValue = zwf.f.Palette_GetWeedValue(weedID,weed:GetWeedAmount(),weed:GetTHC())

    Palette:SetMoney(Palette:GetMoney() + finalValue)

    local data = {
        id = weedID,
        am = weed:GetWeedAmount(),
        thc = math.Round(weed:GetTHC()),
    }

    table.insert(Palette.WeedList,data)

    zwf.f.Palette_Update(Palette)

    SafeRemoveEntity(weed)
end

function zwf.f.Palette_RemoveWeed(Palette)

    local key = math.random(#Palette.WeedList)
    local dat = Palette.WeedList[key]

    local finalValue = zwf.f.Palette_GetWeedValue(dat.id,dat.am,dat.thc)
    Palette:SetMoney(Palette:GetMoney() - finalValue)

    table.remove(Palette.WeedList,key)

    // Spawn WeedBlock
    zwf.f.Palette_SpawnWeedBlock(Palette, dat.id, dat.am, dat.thc)

    zwf.f.Palette_Update(Palette)
end

function zwf.f.Palette_SpawnWeedBlock(Palette, id, am, thc)
    local ent = ents.Create("zwf_weedblock")
    ent:SetPos(Palette:LocalToWorld(Vector(50, 0, 50)))
    ent:SetAngles(Angle(0, 0, 0))
    ent:Spawn()
    ent:Activate()
    ent:SetWeedID(id)
    ent:SetWeedName(zwf.config.Plants[id].name)
    ent:SetTHC(thc)
    ent:SetWeedAmount(am)
    zwf.f.SetOwnerByID(ent, zwf.f.GetOwnerID(Palette))
end

function zwf.f.Palette_Touch(Palette, other)
    if not IsValid(Palette) then return end

    if not IsValid(other) then return end

    if other:GetClass() ~= "zwf_weedblock" then return end

    if Palette:GetBlockCount() >= zwf.config.Palette.limit then return end

    if zwf.f.CollisionCooldown(other) then return end

    if zwf.config.Sharing.Palette == false and zwf.f.OwnerID_Check(Palette,other) == false then return end

    zwf.f.Palette_AddWeed(Palette,other)
end

function zwf.f.Palette_USE(Palette, ply)
    if not IsValid(Palette) then return end
    if not IsValid(ply) then return end
    if Palette.LastUse and (Palette.LastUse + 0.5) > CurTime() then return end
    if Palette:GetBlockCount() <= 0 then return end
    zwf.f.Palette_RemoveWeed(Palette)
end
