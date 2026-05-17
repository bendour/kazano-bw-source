if not SERVER then return end

local entTable = {
    ["zwf_autopacker"] = true,
    ["zwf_ventilator"] = true,
    ["zwf_outlet"] = true,
    ["zwf_pot"] = true,
    ["zwf_pot_hydro"] = true,
    ["zwf_soil"] = true,
    ["zwf_watertank"] = true,
    ["zwf_drystation"] = true,
    ["zwf_fuel"] = true,
    ["zwf_generator"] = true,
    ["zwf_packingstation"] = true,
    ["zwf_splice_lab"] = true,
    ["zwf_seed_bank"] = true,
    ["zwf_palette"] = true,
    ["zwf_doobytable"] = true,
    ["zwf_mixer"] = true,
    ["zwf_backmix_muffin"] = true,
    ["zwf_backmix_brownie"] = true,
    ["zwf_oven"] = true,
}


hook.Add("playerBoughtCustomEntity", "a_zwf_SetOwnerOnEntBuy", function(ply, enttbl, ent, price)
    if entTable[ent:GetClass()] then
        zwf.f.SetOwner(ent, ply)
    end
end)


hook.Add("BaseWars_PlayerBuyEntity", "a_zwf_basewars_SetOwnerOnEntBuy", function(ply, ent)
    if entTable[ent:GetClass()] then
        zwf.f.SetOwner(ent, ply)
    end
end)
