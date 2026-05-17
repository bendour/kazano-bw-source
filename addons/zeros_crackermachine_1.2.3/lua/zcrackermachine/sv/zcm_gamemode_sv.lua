if not SERVER then return end

local entTable = {
    ["zcm_crackermachine"] = true,
    ["zcm_box"] = true,
    ["zcm_blackpowder"] = true,
    ["zcm_paperroll"] = true,
    ["zcm_palette"] = true
}

hook.Add("playerBoughtCustomEntity", "a_zcm_darkrp_SetOwnerOnEntBuy", function(ply, enttbl, ent, price)
    if entTable[ent:GetClass()] then
        zcm.f.SetOwner(ent, ply)
    end
end)

hook.Add("BaseWars_PlayerBuyEntity", "a_zcm_basewars_SetOwnerOnEntBuy", function(ply, ent)
    if entTable[ent:GetClass()] then
        zcm.f.SetOwner(ent, ply)
    end
end)
