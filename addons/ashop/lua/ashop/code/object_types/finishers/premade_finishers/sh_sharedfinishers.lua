ashop.FinisherList = ashop.FinisherList or {}

ashop.FinisherList[7] = {
    client = function(ragdoll, attacker)
        local e = ents.CreateClientProp("models/food/hotdog.mdl")
        e:SetPos(ragdoll:GetPos())
        e:SetAngles(ragdoll:GetAngles())
        e:Spawn()

        ragdoll:SetNoDraw(true)

        return {e}
    end,
    hidePM = true
}

local vec5 = Vector(5,5,5)
ashop.FinisherList[8] = {
    client = function(ragdoll, attacker)
        local bone = ragdoll:LookupBone("ValveBiped.Bip01_Head1")

        if bone then
            ragdoll:ManipulateBoneScale(bone, vec5)
        end
    end
}

ashop.FinisherList[9] = {
    client = function(ragdoll, attacker)
        ragdoll:SetMaterial("models/props_foliage/tree_deciduous_01a_trunk")
    end
}

ashop.FinisherList[10] = {
    client = function(ragdoll, attacker)
        local e = ents.CreateClientProp("models/maxofs2d/companion_doll.mdl")
        e:SetPos(ragdoll:GetPos())
        e:SetAngles(ragdoll:GetAngles())
        e:Spawn()

        ragdoll:SetNoDraw(true)

        return {e}
    end
}

local haloEntities = {}

local function createHalo(id, clr)
    ashop.FinisherList[id] = {
        client = function(ragdoll, attacker)
            if table.IsEmpty(haloEntities) then
                hook.Add("PreDrawHalos", "ashop_finisherhalos_" .. id, function()
                    halo.Add(haloEntities, clr, 5, 5, 2)
                end)
            end
        
            table.insert(haloEntities, ragdoll)
        end,
    
        clientEnd = function(ragdoll)
            table.RemoveByValue(haloEntities, ragdoll)
    
            if table.IsEmpty(haloEntities) then
                hook.Remove("PreDrawHalos", "ashop_finisherhalos_" .. id)
            end
        end
    }
end

createHalo(11, color_white)
createHalo(12, Color(240, 50, 50))
createHalo(13, Color(50, 186, 240))
createHalo(14, Color(237, 240, 50))
createHalo(15, Color(104, 240, 50))
createHalo(16, Color(240, 50, 230))

local internalTable17 = {}
local clr_17 = Color(144, 248, 255)

ashop.FinisherList[17] = {
    client = function(ragdoll, attacker)
        ragdoll:SetRenderMode(RENDERMODE_TRANSCOLOR)
        ragdoll:SetColor(clr_17)
        if table.IsEmpty(internalTable17) then
            hook.Add("PostDrawTranslucentRenderables", "ashop_finisher17", function()
                local old_r, old_g, old_b = render.GetColorModulation()
                render.SetColorModulation( clr_17.r / 5, clr_17.g / 5, clr_17.b / 5 )
                render.SuppressEngineLighting(true)
                for k, v in ipairs(internalTable17) do
                    v:DrawModel()
                end
                render.SuppressEngineLighting(false)
                render.SetColorModulation( old_r, old_g, old_b )
            end)
        end

        if table.IsEmpty(haloEntities) then
            hook.Add("PreDrawHalos", "ashop_finisherhalos", function()
                halo.Add(haloEntities, color_white, 5, 5, 2)
            end)
        end
    
        table.insert(haloEntities, ragdoll)

        // Don't draw if this is a DModelPanel
        if ragdoll:IsRagdoll() then
            table.insert(internalTable17, ragdoll)
        end
    end,

    clientEnd = function(ragdoll)
        table.RemoveByValue(internalTable17, ragdoll)

        if table.IsEmpty(internalTable17) then
            hook.Remove("PostDrawTranslucentRenderables", "ashop_finisher17")
        end

        table.RemoveByValue(haloEntities, ragdoll)
    
        if table.IsEmpty(haloEntities) then
            hook.Remove("PreDrawHalos", "ashop_finisherhalos")
        end
    end,

    overrideModelDraw = function(ragdoll)
        local old_r, old_g, old_b = render.GetColorModulation()
        render.SetColorModulation( clr_17.r / 5, clr_17.g / 5, clr_17.b / 5 )
        render.SuppressEngineLighting(true)
        for k, v in ipairs(internalTable17) do
            ragdoll:DrawModel()
        end
        render.SuppressEngineLighting(false)
        render.SetColorModulation( old_r, old_g, old_b )
    end,
}

local internalTable18 = {}

ashop.FinisherList[18] = {
    client = function(ragdoll, attacker)
        if table.IsEmpty(internalTable18) then
            hook.Add("PostDrawTranslucentRenderables", "ashop_finisher18", function()
                for k, v in ipairs(internalTable18) do
                    local phys = v:GetPhysicsObject()
                    if !IsValid(phys) then
                        return
                    end

                    local old_r, old_g, old_b = render.GetColorModulation()
                    render.SetColorModulation( 0, 0, 0 )

                    local oldP = v:GetPos()
                    phys:SetPos(oldP + VectorRand(-5, 5))
                    v:SetupBones()
                    v:DrawModel()
                    phys:SetPos(oldP)
                    v:SetupBones()

                    render.SetColorModulation( old_r, old_g, old_b )
                end
            end)
        end

        if ragdoll:IsRagdoll() then
            table.insert(internalTable18, ragdoll)
        end
    end,

    clientEnd = function(ragdoll)
        table.RemoveByValue(internalTable18, ragdoll)

        if table.IsEmpty(internalTable18) then
            hook.Remove("PostDrawTranslucentRenderables", "ashop_finisher18")
        end
    end,

    overrideModelDraw = function(ragdoll)
        local old_r, old_g, old_b = render.GetColorModulation()
        render.SetColorModulation( 0, 0, 0 )

        local oldP = ragdoll:GetPos()
        ragdoll:SetPos(oldP + VectorRand(-5, 5))
        ragdoll:SetupBones()
        ragdoll:DrawModel()
        ragdoll:SetPos(oldP)
        ragdoll:SetupBones()

        render.SetColorModulation( old_r, old_g, old_b )
    end,
}

ashop.FinisherList[19] = {
    client = function(ragdoll, attacker)
        ragdoll:SetMaterial('debug/env_cubemap_model')
    end,

    clientEnd = function(ragdoll)
        ragdoll:SetMaterial("")
    end,
}

// What a no-sense finisher
// All this effort for a meme
// But it's so funny
local internalTable20 = {}
local packwatchVectorFrBroGetSmokedHAHAHA = Vector(0, 0, 30)
local mat100 = Material('akulla/emojis/100.png', "smooth")
local matJoy = Material('akulla/emojis/joy.png', "smooth")

hook.Remove("PostDrawTranslucentRenderables", "ashop_finisher20")
ashop.FinisherList[20] = {
    client = function(ragdoll, attacker)
        if table.IsEmpty(internalTable20) then
            surface.SetFont( 'ashop_3D2D_40' )
            local w, h = surface.GetTextSize( 'REST IN PISS YOU WON\'T BE MISSED XD' )
            local transVec = -Vector( w / 2, h / 2, 0 )
            local lply = LocalPlayer()
            local vec = Vector( 40, 100, 0 )
            local plyAng, plyAngRefresh = Angle(0, lply:GetAngles().y - 90, 90), 0
            local dynAng = Angle( 0, 0, 0 )
            local dynVec = Vector( 0, 0, 1 )
    
            hook.Add("PostDrawTranslucentRenderables", "ashop_finisher20", function()
                local c = CurTime()
                for k, v in ipairs(internalTable20) do
                    if c > plyAngRefresh then
                        plyAngRefresh = c + 0.1
                        plyAng.y = lply:GetAngles().y - 90
                    end

                    if !IsValid(v[1]) then
                        table.remove(internalTable20, k)
                        v[2]:Stop()

                        if table.IsEmpty(internalTable20) then
                            hook.Remove("PostDrawTranslucentRenderables", "ashop_finisher20")
                        end
                        continue
                    end

                    cam.Start3D2D(v[1]:GetPos() + packwatchVectorFrBroGetSmokedHAHAHA, plyAng, 0.1)
                        local packX, packY = draw.SimpleText('#PACKWATCH', "ashop_3D2D_40", 0, 0, color_white, 1, 1)
                        surface.SetMaterial(mat100)
                        surface.SetDrawColor(255, 255, 255)
                        surface.DrawTexturedRect(packX/2, -packY/2, 40, packY)

                        local bozoX, bozoY = draw.SimpleText('RIP BOZO', "ashop_3D2D_40", -20, 40, color_white, 1, 1)
                        surface.SetMaterial(matJoy)
                        surface.SetDrawColor(255, 255, 255)
                        surface.DrawTexturedRect(bozoX/2 - 20, -bozoY/2 + 40, 40, bozoY)
                        surface.DrawTexturedRect(bozoX/2 - 20 + 40, -bozoY/2 + 40, 40, bozoY)

                        dynAng.y = math.sin(c*2)*5 - 10
                        dynVec.y = math.sin(c*5)*0.1 + 1
                        dynVec.x = dynVec.y

                        local m = Matrix()
                        m:Translate( vec )
                        m:Rotate( dynAng )
                        m:Scale( dynVec )
                        m:Translate( transVec )
                        surface.SetTextPos(0, 0)
                        
                        cam.PushModelMatrix( m, true )
                            surface.DrawText('REST IN PISS YOU WON\'T BE MISSED XD')
                        cam.PopModelMatrix()
                    cam.End3D2D()
                end
            end)
        end

        sound.PlayURL('https://152.228.135.94/ashop/rip_bozo.mp3', '3d', function(station)
            if IsValid(station) then
                if !IsValid(ragdoll) then
                    station:Remove()
                    return
                end

                station:SetPos(ragdoll:GetPos())
                station:SetVolume(0.5)
                station:Play()

                table.insert(internalTable20, {ragdoll, station})
            else
                print('[AShop] Invalid URL for the finisher Rip Bozo')
            end
        end)
    end,

    clientEnd = function(ragdoll)
        table.RemoveByValue(internalTable20, ragdoll)

        if table.IsEmpty(internalTable20) then
            hook.Remove("PostDrawTranslucentRenderables", "ashop_finisher20")
        end
    end
}