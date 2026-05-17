local UPGRADE = VoidFactions.Upgrades:NewUpgrade()

UPGRADE:Name("upgr_memberdmgreduce")
UPGRADE:Icon("jMnT2ov")

UPGRADE:Description("upgr_desc_memberdmgreduce")
UPGRADE:ValueDescription("upgr_descval_memberdmgreduce")

UPGRADE:FormatValue(function (val)
    return "-" .. val .. "%"
end)

UPGRADE:OnLoad(function (val, id)
    hook.Add("EntityTakeDamage", "VoidFactions.MemberDmgReduce.TakeDamage", function (ply, dmginfo)
        if (!ply:IsPlayer()) then return end

        local member = ply:GetVFMember()
        if (!member) then return end
        local faction = member.faction
        if (!faction) then return end

        if (faction:HasUpgrade("upgr_memberdmgreduce")) then

            local attacker = dmginfo:GetAttacker()
            if (!attacker:IsValid()) then return end
            if (!attacker:IsPlayer()) then return end

            local attackerMember = attacker:GetVFMember()
            if (!attackerMember) then return end

            local attackerFaction = attackerMember.faction
            if (!attackerFaction) then return end

            if (attackerFaction.id != faction.id) then return end

            local totalDmgPercentReduce = faction:SumOfUpgradeValues("upgr_memberdmgreduce")
            totalDmgPercentReduce = math.min(totalDmgPercentReduce, 100)

            local dmgPercent = totalDmgPercentReduce / 100

            local origDmg = dmginfo:GetDamage()
            local finalDmg = origDmg - origDmg * dmgPercent
            dmginfo:SetDamage(finalDmg)
        end
    end)
end)


VoidFactions.Upgrades:AddUpgrade(UPGRADE)