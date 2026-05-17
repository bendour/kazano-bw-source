local MODULE = VoidFactions.XP:Module()
MODULE:SetID("NPCKilled") -- Translation -> string.lower -> prepend xp_, description -> append _desc (if no translation found, it will fallback to the ID name)

MODULE:SetMember() -- apply only to members

-- MODULE:NoTranslate() -- if you want no translations, just uncomment this line of code, and the ID will be used as the name

MODULE:Setup(function ()

    hook.Add("OnNPCKilled", "VoidFactions.XP.NPCKilled", function (npc, ply)
        if (!IsValid(ply)) then return end
        if (!ply:IsPlayer()) then return end
        local member = ply:GetVFMember()
        if (member) then
            MODULE:AddXP(member)
        end
    end)

end)

VoidFactions.XP:AddModule(MODULE)