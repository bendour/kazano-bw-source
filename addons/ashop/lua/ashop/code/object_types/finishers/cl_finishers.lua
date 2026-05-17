local OBJECT_TYPE = {}

OBJECT_TYPE.Name = ashop.L('FinishersClass')
OBJECT_TYPE.UniqueIdentifier = "Finishers"

local alreadyLoadedFile, alreadyLoadedParticle = {}, {}

function OBJECT_TYPE.UI_FILL(plyItem, item, pnl, parent, w, h, noCircle)
    local md = item.metadata

    local m = vgui.Create( "DModelPanel" , parent )
    m:SetSize(parent:GetSize())
    m:SetModel( LocalPlayer():GetModel() )
    m:SetMouseInputEnabled(false)
    m:SetPaintedManually(true)
    m.FarZ = 4096*10

    local mn, mx = m.Entity:GetRenderBounds()
    local size = 0
    size = math.max( size, math.abs(mn.x) + math.abs(mx.x) )
    size = math.max( size, math.abs(mn.y) + math.abs(mx.y) )
    size = math.max( size, math.abs(mn.z) + math.abs(mx.z) )
    
    m:SetFOV( 45 )
    m:SetCamPos( Vector( size, size, size ) * (md[9] or 1.5))

    function m:LayoutEntity() end

    if !md[2] then
        local id = tonumber(md[1])
        local finisher = ashop.FinisherList[id]

        if finisher and finisher.client then
            local l = finisher.client(m.Entity)

            for k, v in ipairs(l or {}) do
                v:SetNoDraw(true)
            end

            function m:OnRemove()
                for k, v in ipairs(l or {}) do
                    if IsValid(v) then
                        v:Remove()
                    end
                end

                if finisher.clientEnd then
                    finisher.clientEnd(m:GetEntity())
                end
            end

            if finisher.hidePM and !table.IsEmpty(l) then
                local mn, mx = l[1]:GetRenderBounds()
                local size = 0
                size = math.max( size, math.abs(mn.x) + math.abs(mx.x) )
                size = math.max( size, math.abs(mn.y) + math.abs(mx.y) )
                size = math.max( size, math.abs(mn.z) + math.abs(mx.z) )
                
                m:SetFOV( 45 )
                m:SetCamPos( Vector( size, size, size ) * (md[9] or 1.5))
            end

            function m:PreDrawModel(ent)
                if finisher.hidePM then
                    if finisher.overrideModelDraw then
                        finisher.overrideModelDraw(ent)
                    end

                    if l and !table.IsEmpty(l) then
                        for k, mdl in ipairs(l) do
                            if !IsValid(mdl) then return end

                            mdl:DrawModel()
                        end
                    end
                    
                    return false
                end
            end

            if finisher.overrideModelDraw then
                function m:PostDrawModel(ent)
                    finisher.overrideModelDraw(ent)

                    if l and !table.IsEmpty(l) then
                        for k, mdl in ipairs(l) do
                            if !IsValid(mdl) then return end
                            mdl:DrawModel()
                        end
                    end
                end
            end
        end
    else
        if !alreadyLoadedFile[md[2]] then
            alreadyLoadedFile[md[2]] = true
            game.AddParticles( md[2] )
        end

        if !alreadyLoadedParticle[md[1]] then
            alreadyLoadedParticle[md[1]] = true
            PrecacheParticleSystem( md[1] )
        end

        local part = CreateParticleSystem(m:GetEntity(), md[1], md[8] and PATTACH_POINT_FOLLOW or PATTACH_ABSORIGIN, md[5] or 0, md[4])

        if part and part:IsValid() then
            part:SetShouldDraw(false)

            function m:PreDrawModel(ent)
                if part:IsValid() then
                    if part:IsFinished() != false then
                        // Don't ask me why, the particles are not valid after the execution
                        part:StopEmissionAndDestroyImmediately()
                        part = CreateParticleSystem(m:GetEntity(), md[1], md[8] and PATTACH_POINT_FOLLOW or PATTACH_ABSORIGIN, md[5] or 0, md[4])
                        part:SetShouldDraw(false)
                    end

                    part:Render()
                end

                return false
            end
        end
    end

    return true, {m}
end

net.Receive('ashop_Finisher', function()
    local attacker = net.ReadEntity()
    local plyItemID = net.ReadUInt(ashop.Config.BitsPlyItemID)
    local victim = net.ReadEntity()
    local ragdoll = net.ReadUInt(13)

    if !IsValid(attacker) then return end

    local timerID = 'ashop_finisher_findragdoll_' .. victim:EntIndex()
    
    timer.Create(timerID, 0.33, 15, function()
        local ragdoll = Entity(ragdoll)

        if !IsValid(ragdoll) or !ragdoll:IsRagdoll() then
            return
        end

        local plyItem = attacker.ashop_data.items[plyItemID]

        if !plyItem then return end

        local item = ashop.items[plyItem.item_id]
        if !item then return end
    
        local md = item.metadata

        if !md[2] or md[2] == "" then
            local id = tonumber(md[1])
    
            if ashop.FinisherList[id].client then
                local l = ashop.FinisherList[id].client(ragdoll, attacker, victim)

                ragdoll:CallOnRemove('AshopCleanFinisher', function()
                    for k, v in ipairs(l or {}) do
                        if IsValid(v) then
                            v:Remove()
                        end
                    end

                    if ashop.FinisherList[id].clientEnd then
                        ashop.FinisherList[id].clientEnd(ragdoll, attacker, victim)
                    end
                end)
            end
        else
            if !alreadyLoadedFile[md[2]] then
                alreadyLoadedFile[md[2]] = true
                game.AddParticles( md[2] )
            end
    
            if !alreadyLoadedParticle[md[1]] then
                alreadyLoadedParticle[md[1]] = true
                PrecacheParticleSystem( md[1] )
            end
    
            if md[3] then
                ragdoll:SetNoDraw(true)
            end
    
            local l = {}
            timer.Create('ashop_ragdolleffect_' .. victim:EntIndex(), md[7] or 0, md[6] or 1, function()
                table.insert(l, CreateParticleSystem(ragdoll, md[1], md[8] and PATTACH_POINT_FOLLOW or PATTACH_ABSORIGIN, md[5] or 0, md[4]))
            end)

            ragdoll:CallOnRemove('AshopCleanFinisher', function()
                for k, v in ipairs(l) do
                    if IsValid(v) and v:IsValid() then
                        if v.StopEmissionAndDestroyImmediately then
                            v:StopEmissionAndDestroyImmediately()
                        else
                            v:Remove()
                        end
                    end
                end
            end)
        end

        timer.Remove(timerID)
    end)
end)

ashop.RegisterObjectType(OBJECT_TYPE)