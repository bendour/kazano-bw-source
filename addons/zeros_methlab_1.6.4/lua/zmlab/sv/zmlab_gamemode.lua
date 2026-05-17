if (not SERVER) then return end

local entTable = {
    ["zmlab_combiner"] = true,
    ["zmlab_collectcrate"] = true,
    ["zmlab_filter"] = true,
    ["zmlab_frezzer"] = true,
    ["zmlab_frezzingtray"] = true,
    ["zmlab_methylamin"] = true,
    ["zmlab_aluminium"] = true,
    ["zmlab_palette"] = true
}

hook.Add("playerBoughtCustomEntity", "a_zmlab_SetOwnerOnEntBuy", function(ply, enttbl, ent, price)
    if entTable[ent:GetClass()] then
        zmlab.f.SetOwner(ent, ply)
    end
end)

hook.Add("BaseWars_PlayerBuyEntity", "a_zmlab_BaseWars_PlayerBuyEntity", function(ply, ent)
    if entTable[ent:GetClass()] then
        zmlab.f.SetOwner(ent, ply)
    end
end)
