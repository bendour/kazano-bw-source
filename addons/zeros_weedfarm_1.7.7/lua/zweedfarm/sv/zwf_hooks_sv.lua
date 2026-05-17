if not SERVER then return end
zwf = zwf or {}
zwf.f = zwf.f or {}

// Here are some Hooks you can use for Custom Code

// Called before the player sells weed, can be used to modify the final earning
// Gets used in this case to also sell any weedblocks which are inside the players Xenin Inventory if XeninInventory is installed and SellMode == 2
hook.Add("zwf_PreWeedSold", "zwf_PreWeedSold_Xenin", function(ply, npc,earning,weedblock_count)
    if IsValid(ply) and zwf.config.NPC.SellMode == 2 and XeninInventory then

        local inv = ply:XeninInventory()
        if inv then

            local extra_cash = 0

            for k,v in pairs(inv.inventory) do
                if v and v.ent == "zwf_weedblock" and v.data.WeedID and v.data.WeedAmount and v.data.THC then

                    // Add Cash
                    extra_cash = extra_cash + zwf.f.NPC_GetSellValue(v.data.WeedID,v.data.WeedAmount,v.data.THC)
                    weedblock_count = weedblock_count + 1

                    // Remove from Inventory
                    local slot = inv:Get(v.id)
                    if not slot then continue end
                    inv:Set(v.id, nil)
                    inv:DeleteSlot(v.id)
                end
            end

            if extra_cash > 0 then
                net.Start("XeninInventory.RequestSync")
                    net.WriteTable(ply:XeninInventory():GetInventory())
                net.Send(ply)

                earning = earning + extra_cash
            end
        end
    end

    return earning,weedblock_count
end)

// Called when the player sells weed
hook.Add("zwf_OnWeedSold", "zwf_OnWeedSold_Vrondakis", function(ply, npc, earning, weedblock_count)
    if IsValid(ply) and zwf.config.VrondakisLevelSystem.Enabled then
        ply:addXP(zwf.config.VrondakisLevelSystem.XP["Selling"] * weedblock_count, " ", true)
    end
end)

// Called when a player gets wanted by the police for selling weed
hook.Add("zwf_OnWanted", "zwf_OnWanted_Test", function(ply)
end)



// Called when a generator needs maintance
hook.Add("zwf_OnGeneratorBroken", "zwf_OnGeneratorBroken_Test", function(generator)
end)

// Called when a generator gets repaired
hook.Add("zwf_OnGeneratorRepaired", "zwf_OnGeneratorRepaired_Test", function(generator,ply)
end)

// Called when a generator explodes
hook.Add("zwf_OnGeneratorExplode", "zwf_OnGeneratorExplode_Test", function(generator)
end)



// Called when a plant dies
hook.Add("zwf_OnPlantDeath", "zwf_OnPlantDeath_Test", function(flowerpot)
end)

// Called when a plant gets harvested
hook.Add("zwf_OnPlantHarvest", "zwf_OnPlantHarvest_Test", function(flowerpot,ply)
    
end)

// Called when a plant gets harvest ready
hook.Add("zwf_OnPlantHarvestReady", "zwf_OnPlantHarvestReady_Test", function(flowerpot)
end)


// Called when a plant gets infected
hook.Add("zwf_OnPlantInfect", "zwf_OnPlantInfect_Test", function(flowerpot)
end)

// Called when a plant gets healed
hook.Add("zwf_OnPlantHeal", "zwf_OnPlantHeal_Test", function(flowerpot,ply)
end)

// Called when a plant gets healed
hook.Add("zwf_OnWeedSmoked", "zwf_OnWeedSmoked_Test", function(ply,weedID,weedTHC)
end)
