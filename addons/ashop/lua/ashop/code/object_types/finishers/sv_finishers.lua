local OBJECT_TYPE = {}

OBJECT_TYPE.Name = ashop.L('FinishersClass')
OBJECT_TYPE.UniqueIdentifier = "Finishers"

util.AddNetworkString('ashop_Finisher')

local ragdollsList = {}

hook.Add("OnEntityCreated", "ashop_FixBadTTTCode", function(ent)
    if ent:GetClass() == "prop_ragdoll" and CORPSE and CORPSE.GetPlayer then
        timer.Simple(0.2, function()
            if IsValid(ent) and IsValid(CORPSE.GetPlayer(ent)) then
                ragdollsList[CORPSE.GetPlayer(ent)] = ent
                print("add into list:", ent, CORPSE.GetPlayer(ent), ragdollsList[CORPSE.GetPlayer(ent)])
            end
        end)
    end
end)

hook.Add("TTTEndRound", "ashop_FixBadTTTCode", function()
    ragdollsList = {}
end)

function OBJECT_TYPE.OnKill(ply, plyItem, item, _, __, victim, inflictor)
    if ply == victim then return end

    local md = item.metadata
    local timerID = 'ashop_finisher_findragdoll_' .. victim:EntIndex()

    // Since timer.Create doesn't fire instantly on first execution
    // I make a manual execution, and I don't want to C/C, so I make a local function

    local function c()
        local ragdoll = ragdollsList[victim] or victim.Flux_DeathRagdoll or victim:GetRagdollEntity()

        if !IsValid(ragdoll) then return end
        
        if !ragdoll:IsRagdoll() and ragdoll:GetClass() != "hl2mp_ragdoll" then return end

        if !md[2] or md[2] == "" then
            local id = tonumber(md[1])
            if !ashop.FinisherList[id] then return true end

            if ashop.FinisherList[id].server then
                local l = ashop.FinisherList[id].server(ragdoll, ply)

                if l then
                    ragdoll:CallOnRemove('AshopCleanFinisher', function()
                        for k, v in ipairs(l) do
                            if IsValid(v) then
                                v:Remove()
                            end
                        end

                        if ashop.FinisherList[id].serverEnd then
                            ashop.FinisherList[id].serverEnd(ragdoll, attacker, victim)
                        end
                    end)
                end
            end

            if ashop.FinisherList[id].client then
                net.Start('ashop_Finisher')
                    net.WriteEntity(ply)
                    net.WriteUInt(plyItem.id, ashop.Config.BitsPlyItemID)
                    net.WriteEntity(victim)
                    net.WriteUInt(ragdoll:EntIndex(), 13)
                net.SendPVS(victim:GetPos())
            end
        else
            net.Start('ashop_Finisher')
                net.WriteEntity(ply)
                net.WriteUInt(plyItem.id, ashop.Config.BitsPlyItemID)
                net.WriteEntity(victim)
                net.WriteUInt(ragdoll:EntIndex(), 13)
            net.SendPVS(victim:GetPos())
        end

        return true
    end

    if !c() then
        timer.Create(timerID, 0.33, 15, function()
            if !IsValid(victim) or c() then
                timer.Remove(timerID)
            end
        end)
    end
end

ashop.RegisterObjectType(OBJECT_TYPE)