if CLIENT then return end

// Here are some Hooks you can use for Custom Code
// If you need any more hooks just open a ticket or write me on steam

// Called when a player sells firework
hook.Add("zcm_OnFireworkSold", "zcm_OnFireworkSold_Vrondakis", function(ply, earning, fireworkcount)
    //ply:addXP(25 * fireworkcount, " ", true)
end)

// Called when a player produces one firework cracker
hook.Add("zcm_OnFireworkProduced", "zcm_OnFireworkProduced_Vrondakis", function(ply)
    //owner:addXP(25, " ", true)
end)

// Called when a firework gets destroyed
// This can be either a zcm_transport_pallet , zcm_transport_box or zcm_firecracker
hook.Add("zcm_OnFireworkDestroyed", "zcm_OnFireworkDestroyed_Test", function(firework,dmg)
    /*
    print(tostring(firework))
    print(tostring(dmg:GetAttacker()))
    */
end)
