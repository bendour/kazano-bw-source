local UPGRADE = VoidFactions.Upgrades:NewUpgrade()

UPGRADE:Name("upgr_memberhalo")
UPGRADE:Icon("rDFcEq6")

UPGRADE:Description("upgr_desc_memberhalo")
UPGRADE:ValueDescription("upgr_descval_memberhalo")

UPGRADE:FormatValue(function (val)
    return "+" .. val .. "m"
end)

if (CLIENT) then
    local ply = LocalPlayer()
    local factionHasUpgrade = false
    local factionSum = 0
    local listOfMembers = {}
    hook.Add("InitPostEntity", "VoidFactions.MemberHalo.SetupPly", function ()
        timer.Simple(1, function ()
            local lP = LocalPlayer()
            if (IsValid(lP)) then
                ply = lP
            end
        end)
    end)

    -- Check every 1 sec
    timer.Create("VoidFactions.MemberHalo.CheckUpgrade", 1, 0, function ()
        if (!IsValid(ply)) then return end
        local member = ply:GetVFMember()
        if (!member) then return end
        if (!member.faction) then return end

        local faction = member.faction

        local hUpgrade = faction:HasUpgrade("upgr_memberhalo")
        if (hUpgrade) then
            factionHasUpgrade = true
            factionSum = faction:SumOfUpgradeValues("upgr_memberhalo")

            local plys = {}
            local plyPos = ply:GetPos()
            local sqrDist = math.pow(factionSum * 53, 2)
            local facMembers = faction.members
            for k, v in ipairs(facMembers) do
                if (!IsValid(v.ply)) then continue end
                if (v.ply != ply and plyPos:DistToSqr(v.ply:GetPos()) < sqrDist) then
                    plys[#plys + 1] = v.ply
                end
            end

            listOfMembers = plys

        else
            factionHasUpgrade = false
        end
    end)

    hook.Add("PreDrawHalos", "VoidFactions.MemberHalo.Draw", function ()
        if (!IsValid(ply)) then return end
        local member = ply:GetVFMember()
        if (!member) then return end
        if (!member.faction) then return end

        local faction = member.faction
        local haloColor = faction.color

        if (factionHasUpgrade) then
            halo.Add(listOfMembers, haloColor, 2, 2, 1, true, true)
        end
    end)
end

VoidFactions.Upgrades:AddUpgrade(UPGRADE)