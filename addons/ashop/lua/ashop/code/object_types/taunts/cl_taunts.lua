local OBJECT_TYPE = {}

OBJECT_TYPE.Name = ashop.L('TauntsClass')
OBJECT_TYPE.UniqueIdentifier = "Taunts"
OBJECT_TYPE.DefaultRender = "Accessories"

local ang90 = Angle(0, 90, 0)

function OBJECT_TYPE.UI_FILL(plyItem, item, pnl, parent, w, h, noCircle)
    local circleParent = vgui.Create("EditablePanel", pnl)
    circleParent:SetSize(w, h)
    circleParent:SetMouseInputEnabled(false)

    local m = vgui.Create( "DModelPanel" , pnl ) -- SpawnIcon
    m:Dock(FILL)
    m:SetModel( LocalPlayer():GetModel() ) -- Model we want for this spawn icon
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
    m.Entity:SetAngles(m.Entity:GetAngles() + ang90)
    m.Entity:ResetSequence(item.metadata[2])

    function m:LayoutEntity() end

    function m:PreDrawModel(ent)
        local fr = FrameTime()
        local c = ent:GetCycle()
        local seqD = ent:SequenceDuration()
        local mdRat = item.metadata[5] or 1

        ratio = fr * mdRat
        c = (c + ratio/seqD) % 1

        ent:SetCycle(c)
        render.SetLightingMode(1)
    end

    function m:PostDrawModel(ent)
        render.SetLightingMode(0)
    end

    return true, {m}
end

function OBJECT_TYPE.OnLocalRemove(ply, plyItem, item)
    OBJECT_TYPE.OnRemove(ply, plyItem, item)
end

function OBJECT_TYPE.OnLocalFPDraw(ply)
end

function OBJECT_TYPE.OnRemove(ply, plyItem, item)
    // Remove the anim taunt from player, if any
    ply.ashop_anim = nil
end

// Check if player was visible this frame
local radios = {}

// Get all radios from players, if lua refresh
for k, v in ipairs(player.GetHumans()) do
    if v.ashop_animmusic then
        radios[v.ashop_animmusic[1]] = v
    end
end

function OBJECT_TYPE.OnPostPlayerDraw(ply, plyItem, item, inModelPanel)
    if ply.ashop_animmusic then
        ply.ashop_animmusic[1]:SetPos(ply:GetPos() + ply:OBBMaxs())
    end
end

// When gmod is waiting to get the URL, you can't disconnect
// Making painful to disconnect when there a loop looping to get links
local blockedURLs = {}

ashop.RegisterObjectType(OBJECT_TYPE)

// The "most" optimised method I found, avoiding think or PostPlayerDraw
timer.Create("ashop_checkradios", 0.33, 0, function()
    for k, v in pairs(radios) do
        // Player not valid
        if !IsValid(v) then
            if k:IsValid() then
                k:Stop()
            end

            radios[k] = nil
            continue
        end

        
        // Radio not valid, happens sometimes
        if !k:IsValid() then
            local url = v.ashop_animmusic[2]

            if !blockedURLs[url] then
                sound.PlayURL ( url, "noblock" .. (LocalPlayer() == v and "" or "3d"), function( station )
                    if !IsValid(v) then return end

                    if ( IsValid( station ) ) then
                        station:SetPos( v:GetPos() )
                        station:Play()
                        station:EnableLooping(true)
                        v.ashop_animmusic = {station, url}
                        radios[station] = v
                    else
                        print( "[AShop] Invalid Anim music URL !" )
                        blockedURLs[url] = true
                    end
                end )
            end
            
            radios[k] = nil
            continue
        end

        if v:IsDormant() then
            k:Pause()
        else
            k:Play()
            k:SetPos(v:GetPos())
        end
    end
end)

net.Receive("ashop_selectTaunt", function()
    local ply = net.ReadEntity()

    if !IsValid(ply) then return end

    if ply.ashop_anim then
        if ply.ashop_animmusic then
            radios[ply.ashop_animmusic[1]] = nil
            ply.ashop_animmusic[1]:Stop()
            ply.ashop_animmusic = nil
        end
        ply.ashop_anim = nil
    end

    if net.ReadBool() then
        local itemid = net.ReadUInt(ashop.Config.BitsItemID)
        local item = ashop.items[itemid]
        local url = item.metadata[4]
        ply.ashop_anim = {item.metadata[2], item.metadata[5], item.metadata[3] or false}

        if url and !blockedURLs[url] then
            sound.PlayURL ( url, "noblock " .. (ply != LocalPlayer() and "3d" or ""), function( station )
                if !IsValid(ply) then return end

                if ( IsValid( station ) ) then
                    station:SetPos( ply:GetPos() )
                    station:Play()
                    station:EnableLooping(true)
                    ply.ashop_animmusic = {station, url}

                    radios[station] = ply
                else
                    print( "[AShop] Invalid Anim music URL !" )
                    blockedURLs[url] = true
                end
            end )
        end
    end

    ply:SetCycle( 0 )
end)

local ang180 = Angle(0, 180, 0)
local ang45 = Angle(0, 45, 0)
concommand.Add("ashop_OpenTauntMenu", function()
    local ply = LocalPlayer()
    local localModel = ply:GetModel()
    local b = ashop.GetObjectTypeIDByUID('Taunts')
    local equipped, count = ply:AShop_SlotStateGet(b)

    local u = vgui.Create('AShop_RadialMenu')
    function u:CallbackItem(data)
        net.Start('ashop_selectTaunt')
            net.WriteBool(true)
            net.WriteUInt(data, ashop.Config.BitsPlyItemID)
        net.SendToServer()
        u:Remove()
    end

    local radialItems = {}
    if count > 0 then
        for i = 1, count do
            if equipped[i] then
                local item = ashop.items[ply.ashop_data.items[equipped[i]].item_id]
                local cm = ClientsideModel(localModel)
                cm:SetNoDraw(true)
                cm:Spawn()
                cm:ResetSequence(item.metadata[2])
                cm:SetAngles(ang45)

                radialItems[i] = {
                    name = item.name,
                    data = equipped[i],
                    cm = cm,
                    item = item
                }

                local bMin, bMax = cm:GetModelBounds()
                local size = 0
                size = math.max( size, math.abs(bMin.x) + math.abs(bMax.x) )
                local center = (bMax - bMin) / 2 + bMin

                cm.viewPos = Vector( size, size, size ) + Angle():Forward()*100 + Vector(0, 0, size/2)
                cm.ang = (cm.viewPos - center):Angle() + ang180
            end
        end
    end

    function u:DrawItem(data, x, y, w, h, key)
        local mdl = radialItems[key].cm
        local Sx, Sy = self:LocalToScreen(x, y)

        ashop.StartStencil()
            cam.Start3D(mdl.viewPos, mdl.ang, 40, Sx, Sy, w, h, 50, 800)
            mdl:DrawModel()
            mdl:SetCycle(radialItems[key].item.metadata[6] or 0.8)
            cam.End3D()
        ashop.ReplaceStencil(1)
            surface.SetDrawColor(255, 255, 255)
            surface.DrawRect(x, y, w, h)
        ashop.EndStencil()
    end

    function u:OnRemove()
        for k, v in pairs(radialItems) do
            if v.cm and IsValid(v.cm) then
                v.cm:Remove()
            end
        end
    end

    u.desc = ashop.L('ClickTaunt')

    u:SetContents(count, radialItems)
end)

hook.Add("CalcView", "ashop_animFirstPerson", function(ply, origin, angles)
    if ply.ashop_anim and !ply:ShouldDrawLocalPlayer() then
        local b = ply:LookupBone('ValveBiped.Bip01_Head1')
        if !b then return end

        local pos, ang = ply:GetBonePosition(b)
        ang = ang

        ang:RotateAroundAxis(ang:Up(), -90)
        ang:RotateAroundAxis(ang:Forward(), -90)

        return {
            // Get this value with origin - pos
            origin = pos + ang:Forward()*8,
            angles = ang,
            drawviewer = true
        }
    end
end)