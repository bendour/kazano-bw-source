local MODULE = VoidFactions.XP:Module()
MODULE:SetID("Playtime") -- Translation -> string.lower -> prepend xp_ (xp_playtime)
MODULE:SetTimeBased()

--MODULE:SetMember() -- static factions

MODULE:Setup(function ()

    hook.Add("VoidFactions.Playtime.XPIncremented", "VoidFactions.XP.Playtime", function (member)
        MODULE:AddXP(member)
    end)

end)

VoidFactions.XP:AddModule(MODULE)
