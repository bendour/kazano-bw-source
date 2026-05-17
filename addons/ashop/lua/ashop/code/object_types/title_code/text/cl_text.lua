local OBJECT_TYPE = {}
OBJECT_TYPE.Name = ashop.L('TextClass')
OBJECT_TYPE.UniqueIdentifier = "TitleText"

function OBJECT_TYPE.UI_FILL(plyItem, item, pnl, parent, w, h)
    local circleParent = vgui.Create("EditablePanel", pnl)
    circleParent:Dock(FILL)
    circleParent:SetMouseInputEnabled(false)

    local t = {}
    local str = item.metadata[1]
    
    for i = 1, string.len(str) do
        t[i] = utf8.sub(str, i, i )
    end

    function circleParent:Paint(w, h)
        //surface.SetDrawColor(ashop.rarity[item.rarity])
        //surface.SetMaterial(circle)
        //surface.DrawTexturedRect(w*0.1, h*0.1, w*0.8, h*0.8)

        ashop.DrawTitle(t, color_white, nil, w/2, h/2, item.metadata[1], TEXT_ALIGN_CENTER)
    end
end

function OBJECT_TYPE.OnLocalEquip(ply, plyItem, item)
    OBJECT_TYPE.OnEquip(ply, plyItem, item)
end

function OBJECT_TYPE.OnEquip(ply, plyItem, item)
    local t = {}

    for i = 1, string.len(item.metadata[1]) do
        t[i] = utf8.sub( item.metadata[1], i, i )
    end

    ply.ashop_splittedTitle = t
    ply.ashop_title = item.metadata[1]
end

function OBJECT_TYPE.OnMetadataUpdate(ply, plyItem, item)
    OBJECT_TYPE.OnEquip(ply, plyItem, item)
end

function OBJECT_TYPE.OnLocalRemove(ply)
    OBJECT_TYPE.OnRemove(ply)
end

function OBJECT_TYPE.OnLocalFPDraw(ply)
end

function OBJECT_TYPE.OnRemove(ply)
    ply.ashop_splittedTitle = nil
    ply.ashop_title = nil
end

local function drawTitle(ply, font, fontHeight)
    if ply.ashop_splittedTitle then
        ashop.DrawTitle(ply.ashop_splittedTitle, ply.ashop_titlecolor, ply.ashop_titlestyle, 0, -fontHeight*1.25, ply.ashop_title, nil, font)
    end
end

local offset = Vector( 0, 0, 75 )
local offsetHead = Vector(0, 0, 15)
local angHead = Angle( 0, 0, 90 )

local drawTbl = {}

hook.Add("PostDrawTranslucentRenderables", "AShop:DrawTitle", function()
    for k, v in ipairs(drawTbl) do
        cam.Start3D2D( v[1], v[2], 0.05 )
            drawTitle(v[3], v[4], v[5])
        cam.End3D2D()
    end

    drawTbl = {}
end)

local addVec = Vector(0, 0, ashop.Config.TitleVerticalPosAdd or 0)
function OBJECT_TYPE.OnPostPlayerDraw(ply, plyItem, item, inModelPanel)
    if inModelPanel then
        cam.Start2D()
            cam.IgnoreZ(true)

            ashop.DrawTitle(ply.ashop_splittedTitle, ply.ashop_titlecolor, ply.ashop_titlestyle, ScrW()/2, ScrH()*0.15, item.metadata[1])
            cam.IgnoreZ(false)
        cam.End2D()
    elseif hook.Run("ashop_OverrideTitleDrawingCam", ply, plyItem, item, inModelPanel) then
        return
    else
        local l = LocalPlayer()
        if ( l:GetPos():DistToSqr( ply:GetPos() ) > 300 * 300 ) then return end

        local ang = l:EyeAngles()
        local pos = ply:GetPos() + offset
        local targethead = ply:LookupBone("ValveBiped.Bip01_Head1")
        if isnumber(targethead) then
            local targetheadpos = ply:GetBonePosition(targethead)
            pos = targetheadpos + offsetHead
        end

        if l:InVehicle() then
            ang = l:GetVehicle():LocalToWorldAngles( l:EyeAngles() )
        end

        ang:RotateAroundAxis( ang:Forward(), 90 )
        ang:RotateAroundAxis( ang:Right(), 90 )

        angHead.y = ang.y

        if Flux then
            table.insert(drawTbl, {pos + Vector(0, 0, 0.5), angHead, ply, "ashop_3D2D_" .. ashop.Config.FontSizeTitle, 18})
        else
            table.insert(drawTbl, {pos + addVec, angHead, ply, "ashop_3D2D_" .. ashop.Config.FontSizeTitle, 18})
        end
    end
end

hook.Add('ahud_afterSHUDDraw', "AShopDrawTitle", drawTitle)

ashop.RegisterObjectType(OBJECT_TYPE)