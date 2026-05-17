if not SERVER then return end
zmlab = zmlab or {}
zmlab.f = zmlab.f or {}

// Here are some Hooks you can use for Custom Code

hook.Add("zmlab_OnMethSell", "zmlab_OnMethSell_test", function(ply, methAmount)
    if not IsValid(ply) then return end
    //print(ply:Nick() .. " sold " .. methAmount .. "g Meth at DropOffPoint[" .. dropoffpoint:EntIndex() .. "]")

    //Vrondakis
    if zmlab.config.Vrondakis.Enabled then
        ply:addXP(zmlab.config.Vrondakis.Data["Selling"].XP * methAmount, " ", true)
    end
end)


// Called when the player sells meth to a NPC
hook.Add("zmlab_OnMethSell_NPC", "zmlab_methsellnpc_test", function(ply, methAmount, npc)
    if (IsValid(ply)) then
        //print(ply:Nick() .. " sold " .. methAmount .. "g Meth to NPC " .. npc:EntIndex())
    end
end)

// Called when the player drops the Meth Entity to a DropOff Point
hook.Add("zmlab_OnMethSell_DropOff", "zmlab_methselldropoff_test", function(ply, methEnt, dropoffpoint)
    if (IsValid(ply)) then
        //print(ply:Nick() .. " sold " .. methEnt:GetMethAmount() .. "g Meth at DropOffPoint[" .. dropoffpoint:EntIndex() .. "]")
    end
end)


// Called when the player sells the Meth by Pressing E on the DropOff Point
hook.Add("zmlab_OnMethSell_DropOff_Use", "zmlab_methselldropoffuse_test", function(ply, methAmount, dropoffpoint)
    if (IsValid(ply)) then
        //print(ply:Nick() .. " sold " .. methAmount .. "g Meth at DropOffPoint[" .. dropoffpoint:EntIndex() .. "]")
    end
end)


// Called when the player creates the Final Meth by Pressing E on the frezzing Tray
hook.Add("zmlab_OnMethMade", "zmlab_OnMethMade_test", function(ply, frezzingTray, methEnt)
    if not IsValid(ply) then return end
    //print(ply:Nick() .. " made meth entity" .. methEnt:EntIndex() .. " on Frezzing Tray [" .. frezzingTray:EntIndex() .. "]")

    //Vrondakis
    if zmlab.config.Vrondakis.Enabled then
        ply:addXP(zmlab.config.Vrondakis.Data["BreakingIce"].XP * methEnt:GetMethAmount(), " ", true)
    end
end)



// Called when a player gets wanted for selling meth
hook.Add("zmlab_OnWanted", "zmlab_OnWanted_test", function(ply)
    if (IsValid(ply)) then
        //print(ply:Nick() .. " is now wanted for Selling Meth!")
    end
end)


// Gets called when a Player destorys Methbag, Methcrate or Palette with Meth
hook.Add("zmlab_OnMethObjectDestroyed", "zmlab_OnMethObjectDestroyed_test", function(methObject,damageinfo)

    if IsValid(methObject) then
        local m_amount = methObject:GetMethAmount()

        if m_amount <= 0 then return end

        local ply = damageinfo:GetAttacker()

        // If the attacker is a player with a police job then we reward that player
        if IsValid(ply) and ply:IsPlayer() and ply:Alive() and zmlab.config.Police.Jobs[team.GetName(ply:Team())] then
            local Earning = m_amount * (zmlab.config.MethBuyer.SellRanks[ply:GetNWString("usergroup", "")] or zmlab.config.MethBuyer.SellRanks["default"])
            Earning = Earning * zmlab.config.Police.PoliceCut
            zmlab.f.GiveMoney(ply, Earning)
            zmlab.f.Notify(ply, zmlab.config.Currency .. BaseWars:FormatMoney(Earning), 0)
        end
    end
end)


// Here you can return which sellmode this player should have for selling meth
// Return 1,2, 3, 4 or return nothing if you want to use the default sellmode defind in the config
hook.Add("zmlab_GetSellMode", "zmlab_GetSellMode_test", function(ply)

    // 1 = Methcrates can be absorbed by Players and sold by the MethBuyer on use
    // 2 = Methcrates cant be absorbed and the MethBuyer tells you a dropoff point instead (Palette Entity gets used here for easier transport)
    // 3 = Methcrates can be absorbed and the MethBuyer tells you a dropoff point
    // 4 = Methcrates need to be moved to the MethBuyer and sold directly by him

    if IsValid(ply) and ply:IsSuperAdmin() then
        //return 3
    end
end)

// Gets called when a dropoff point gets assinged to a player
hook.Add("zmlab_OnDropOffPoint_Assigned", "zmlab_OnDropOffPoint_Assigned_test", function(dropoffpoint,ply)
    /*
    if IsValid(dropoffpoint) and IsValid(ply) then
        print("Player: " .. ply:Nick() .. " just got assigned DropOffPoint: " .. tostring(dropoffpoint) .. ".")
    end
    */
end)
