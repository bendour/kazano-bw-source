if not SERVER then return end
zmlab = zmlab or {}
zmlab.f = zmlab.f or {}

hook.Add( "EntityTakeDamage", "zmlab_EntityDamage_NPCFix", function( target, dmginfo )
	if IsValid(target) and target:GetClass() == "zmlab_methbuyer" then
		return true
	end
end )

// Return
function zmlab.f.GetSellMode(ply)
    local custom_sellmode = hook.Run("zmlab_GetSellMode", ply)

    if custom_sellmode == nil then
        custom_sellmode = zmlab.config.MethBuyer.SellMode
    end

    return custom_sellmode
end

// Is the player allowed do get another droppoff point or is there still a cooldown to wait
function zmlab.f.Player_DropOffRequest(ply)
    if (ply.NextDropoffRequest == nil or ply.NextDropoffRequest < CurTime()) then
        return true
    else
        local _string = string.Replace(zmlab.language.methbuyer_requestfail_cooldown, "$DropRequestCoolDown", math.Round(ply.NextDropoffRequest - CurTime()))
        zmlab.f.Notify(ply, _string, 1)

        return false
    end
end

// Does the player have allready a DropOffPoint?
function zmlab.f.HasPlayerDropOffPoint(ply)
    if (not ply.DropOffPoint or not IsValid(ply.DropOffPoint)) then
        return true
    else
        zmlab.f.Notify(ply, zmlab.language.methbuyer_requestfail, 1)

        return false
    end
end

// This searches and returns a valid dropoffpoint
function zmlab.f.SearchUnusedDropOffPoint(ply)
    local unUsedDropOffs = {}

    for k, v in pairs(ents.FindByClass("zmlab_methdropoff")) do
        if IsValid(v) and not IsValid(v.Deliver_Player) then
            table.insert(unUsedDropOffs, v)
        end
    end

    if (table.Count(unUsedDropOffs) > 0) then
        local ent = unUsedDropOffs[math.random(#unUsedDropOffs)]

        return ent
    else
        return false
    end
end

// This assigns a DropOffPoint
function zmlab.f.AssignDropOffPoint(ply, dropoffpoint)
    if IsValid(dropoffpoint) then

        zmlab.f.Dropoffpoint_Open(dropoffpoint, ply)

        ply.DropOffPoint = dropoffpoint
        zmlab.f.Notify(ply, zmlab.language.methbuyer_dropoff_assigned, 0)

        hook.Run("zmlab_OnDropOffPoint_Assigned", dropoffpoint,ply)
    else
        zmlab.f.Notify(ply, zmlab.language.methbuyer_requestfail_nonfound, 1)
    end
end

// This handles the main sell action
function zmlab.f.SellMeth(ply,meth)

    // Give the player the Cash
    local Earning = meth * ( zmlab.config.MethBuyer.SellRanks[ply:GetNWString("usergroup", "")] or zmlab.config.MethBuyer.SellRanks["default"])
    zmlab.f.GiveMoney(ply, Earning)
    local xp = math.floor(BaseWars:CalculatePlayerXP(ply, BaseWars:CalculateXPFromMultiplier(Earning) * .01))
	ply:AddXP(xp)

    //Vrondakis
    hook.Run("zmlab_OnMethSell", ply, meth, Earning)

    // Create VFX
    if zmlab.config.MethBuyer.ShowEffect then
        if meth > 200 then
            zmlab.f.CreateNetEffect("zmlab_sell_big",ply:GetPos())
        else
            zmlab.f.CreateNetEffect("zmlab_sell_small",ply:GetPos())
        end
    end

    // Notify the player
    local _string = string.Replace(zmlab.language.methbuyer_soldMeth, "$methAmount", BaseWars:FormatNumber(meth))
    _string = string.Replace(_string, "$earning", BaseWars:FormatMoney(Earning))
    _string = string.Replace(_string, "$currency", zmlab.config.Currency)
    zmlab.f.Notify(ply, _string, 0)

    // Informs the police
    zmlab.f.AlarmPolice(ply)
end

// Called when Meth gets sold by a npc
function zmlab.f.SellMeth_NPC(ply, buyer)

    hook.Run("zmlab_OnMethSell_NPC", ply, ply.zmlab_meth,buyer)

    zmlab.f.SellMeth(ply,ply.zmlab_meth)

    // Resets Players Meth amount
    ply.zmlab_meth = 0
end

// Called when meth gets sold via gravgun drop
function zmlab.f.SellMeth_DropOffPoint(ply, droppoint,methEnt)

    if (ply ~= droppoint.Deliver_Player) then
        local _string = string.Replace(zmlab.language.methbuyer_dropoff_wrongguy, "$deliverguy", tostring(droppoint.Deliver_Player:Nick()))
        zmlab.f.Notify(ply, _string, 0)
    end

    hook.Run("zmlab_OnMethSell_DropOff", ply, methEnt,droppoint)

    zmlab.f.SellMeth(droppoint.Deliver_Player,methEnt:GetMethAmount())

    if zmlab.config.DropOffPoint.OnTimeUse then
        zmlab.f.Dropoffpoint_Close(droppoint)
    end

    if IsValid(methEnt) then
        SafeRemoveEntity(methEnt)
    end
end

// Called when meth gets sold via use
function zmlab.f.SellMeth_DropOffPoint_USE(ply, droppoint)
    if not IsValid(droppoint) then return end
    zmlab.f.SellMeth(ply,ply.zmlab_meth)

    hook.Run("zmlab_OnMethSell_DropOff_Use", ply, ply.zmlab_meth,droppoint)


    if zmlab.config.DropOffPoint.OnTimeUse then
        zmlab.f.Dropoffpoint_Close(droppoint)
    end

    // Resets Players Meth amount
    ply.zmlab_meth = 0
end

// This performs the Core Logic of the Meth Selling
function zmlab.f.SellSystem(ply, buyer)
    -- if (not zmlab.f.Player_CheckJob(ply)) then
    --     zmlab.f.Notify(ply, zmlab.language.methbuyer_wrongjob, 1)
    --     buyer:EmitSound("zmlab_npc_wrongjob")
    --     return
    -- end

    local sellmode = zmlab.f.GetSellMode(ply)

    //1 = Methcrates can be absorbed by Players and sold by the MethBuyer on use
    if (sellmode == 1) then
        if (zmlab.f.HasPlayerMeth(ply)) then
            zmlab.f.SellMeth_NPC(ply, buyer)
            buyer:EmitSound("zmlab_npc_sell")
        end

    // 2 = Methcrates cant be absorbed and the MethBuyer tells you a dropoff point instead
    elseif (sellmode == 2 and zmlab.f.HasPlayerDropOffPoint(ply) and zmlab.f.Player_DropOffRequest(ply)) then
        local dropoffpoint = zmlab.f.SearchUnusedDropOffPoint(ply)

        if dropoffpoint then
            ply.NextDropoffRequest = CurTime() + zmlab.config.DropOffPoint.DeliverRequest_CoolDown

            buyer:EmitSound("zmlab_npc_sell")
        end

        zmlab.f.AssignDropOffPoint(ply, dropoffpoint)


    // 3 = Methcrates can be absorbed and the MethBuyer tells you a dropoff point
    elseif (sellmode == 3 and zmlab.f.Player_DropOffRequest(ply) and zmlab.f.HasPlayerDropOffPoint(ply) and zmlab.f.HasPlayerMeth(ply)) then

        local dropoffpoint = zmlab.f.SearchUnusedDropOffPoint(ply)

        if (dropoffpoint) then
            ply.NextDropoffRequest = CurTime() + zmlab.config.DropOffPoint.DeliverRequest_CoolDown

            buyer:EmitSound("zmlab_npc_sell")
        end

        zmlab.f.AssignDropOffPoint(ply, dropoffpoint)
    elseif sellmode == 4 then

        local meth = 0

        for k, v in pairs(zmlab.EntList) do

            if IsValid(v) and zmlab.f.InDistance(ply:GetPos(), v:GetPos(), 250) then

                if v:GetClass() == "zmlab_palette"  and v:GetCrateCount() > 0 then
                    meth = meth + v:GetMethAmount()
                    SafeRemoveEntity(v)
                elseif v:GetClass() == "zmlab_collectcrate" and v:GetMethAmount() > 0 then
                    meth = meth + v:GetMethAmount()
                    SafeRemoveEntity(v)
                end
            end
        end

        if meth <= 0 then
            zmlab.f.Notify(ply, zmlab.language.methbuyer_nometh, 1)

            return
        end

        hook.Run("zmlab_OnMethSell_NPC", ply, meth,buyer)
        zmlab.f.SellMeth(ply,meth)
    end
end

// Informs the police that the player just sold meth
function zmlab.f.AlarmPolice(ply)
    if zmlab.config.Police.WantedOnMethSell == false then return end

    local police = {}

    for k, v in pairs(zmlab_PlayerList) do
        if IsValid(v) and v:IsPlayer() and v:Alive() and zmlab.config.Police.Jobs[team.GetName(v:Team())] then
            table.insert(police,v)
        end
    end

    if police and table.Count(police) > 0 and IsValid(police[1]) then

        hook.Run("zmlab_OnWanted", ply)

        ply:wanted(police[1], zmlab.language.General_WantedNotify, 120)
    end
end
