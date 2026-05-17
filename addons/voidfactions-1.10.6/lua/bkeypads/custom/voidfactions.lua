local function reloadIntegration()
    timer.Simple(0, function ()
	local addonFactions = bKeypads.CustomAccess:AddAddon("icon16/group.png", "VoidFactions - Factions")
    local addonRanks = bKeypads.CustomAccess:AddAddon("icon16/award_star_gold_1.png", "VoidFactions - Ranks")

    local tblLoop = SERVER and VoidFactions.Factions or VoidFactions.LoadedFactions
    for k, faction in pairs(tblLoop) do
        local factionCategory = addonRanks:AddCategory(faction.color, faction.name)
        
        addonFactions:AddMember("icon16/flag_blue.png", faction.name, function (keypad, ply)
               local plyMember = ply:GetVFMember()
               if (!plyMember or !plyMember.rank) then return end

               if (plyMember.faction.id == faction.id) then
                    return true
               end
        end)

        for k, rank in pairs(faction.ranks or {}) do
            factionCategory:AddMember("icon16/award_star_silver_1.png", rank.name .. " (" .. faction.tag .. ")", function(keypad, ply, keycard)
                local plyMember = ply:GetVFMember()
                if (!plyMember or !plyMember.rank) then return end

                if (plyMember.rank.id == rank.id) then
                    return true
                end
            end)
        end
    end
    end)
end

-- kinda ugly but wanna make sure it works

-- VoidFactions.Faction.StaticFactionsLoaded is actually for dynamic factions too
hook.Add(SERVER and "VoidFactions.SQL.StaticFactionsPreloaded" or "VoidFactions.Faction.StaticFactionsLoaded", "VoidFactions.bKeypads.SupportStatic", reloadIntegration)
hook.Add(SERVER and "VoidFactions.UpdateRankInfo" or "VoidFactions.Faction.DataUpdated", "VoidFactions.bKeypads.SupportStatic2", reloadIntegration)

if (SERVER) then
	hook.Add("VoidFactions.Faction.OnRanksLoaded", "VoidFactions.bKeypads.SupportDynamic", reloadIntegration)
    hook.Add("VoidFactions.Factions.FactionLoaded", "VoidFactions.bKeypads.SupportDynamic2", reloadIntegration)
end
