ashop.FinisherList = ashop.FinisherList or {}

util.AddNetworkString("ashop_finisherslowmotion")
ashop.FinisherList[1] = {
    server = function(ragdoll, attacker)
        attacker:SetLaggedMovementValue( 0.1 )
        local c = CurTime()

        local name_hook = "attackerslowmotion"..attacker:GetName()
        net.Start('ashop_finisherslowmotion')
        net.Send(attacker)
    
        hook.Add("Tick", name_hook, function()
            if !IsValid(attacker) then
                hook.Remove("Tick", name_hook)
            else
                local diff = (CurTime() - c)
                if diff > 1 then
                    attacker:SetLaggedMovementValue( 0.1 + d*0.9 )
                else
                    attacker:SetLaggedMovementValue( 1 )
                    hook.Remove("Tick", name_hook)
                end
            end
        end)
    end
}

local function ragdollAttackerDissolver(dissolveType, ragdoll, attacker)
    local Dissolver = ents.Create( "env_entity_dissolver" )
    timer.Simple(5, function()
        if IsValid(Dissolver) then
            Dissolver:Remove() -- backup edict save on error
        end
    end)

    Dissolver.Target = "dissolve"..ragdoll:EntIndex()
    Dissolver:SetKeyValue( "dissolvetype", dissolveType )
    Dissolver:SetKeyValue( "magnitude", 0 )
    Dissolver:SetPos( ragdoll:GetPos() )
    Dissolver:SetPhysicsAttacker( attacker )
    Dissolver:Spawn()

    ragdoll:SetName( Dissolver.Target )

    Dissolver:Fire( "Dissolve", Dissolver.Target, 0 )
    Dissolver:Fire( "Kill", "", 0.1 )
end

ashop.FinisherList[2] = {
    server = function(ragdoll, attacker)
        ragdollAttackerDissolver(0, ragdoll, attacker)
    end
}

ashop.FinisherList[3] = {
    server = function(ragdoll, attacker)
        ragdoll:Ignite(30)
    end
}

ashop.FinisherList[4] = {
    server = function(ragdoll, attacker)
        ragdollAttackerDissolver(2, ragdoll, attacker)
    end
}

ashop.FinisherList[5] = {
    server = function(ragdoll, attacker)
        ragdollAttackerDissolver(1, ragdoll, attacker)
    end
}

ashop.FinisherList[6] = {
    server = function(ragdoll, attacker)
        ragdollAttackerDissolver(3, ragdoll, attacker)
    end
}