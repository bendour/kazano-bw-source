local UPGRADE = VoidFactions.Upgrades:NewUpgrade()

UPGRADE:Name("upgr_lockpickspeed")
UPGRADE:Icon("uHv8dsv")

UPGRADE:OneInstance()

UPGRADE:Description("upgr_desc_lockpickspeed")
UPGRADE:ValueDescription("upgr_descval_lockpickspeed")

UPGRADE:IsInstalledFunc(function ()
    return DarkRP and true or false
end)

UPGRADE:FormatValue(function (val)
    return val .. "%"
end)

UPGRADE:OnReset(function (ply)
    if (!SERVER) then return end
end)

UPGRADE:OnLoad(function (val, id)
    hook.Add("lockpickTime", "VoidFactions.LockpickSpeed.Hook" .. id , function (ply, ent)
        local wep = ply:GetActiveWeapon()
        local curTime = CurTime()
        timer.Simple(0, function ()
            local lockpickTime = wep:GetLockpickEndTime() - curTime
            
            local member = ply:GetVFMember()
            if (!member) then return end
            local faction = member.faction
            if (!faction) then return end

            if (faction:HasUpgrade("upgr_lockpickspeed")) then
                val = faction:GetUpgradeValue(id)
                if (!val) then return end

                wep:SetLockpickEndTime(curTime + (lockpickTime * (val / 100)))
            end
        end)
    end)
end)


VoidFactions.Upgrades:AddUpgrade(UPGRADE)