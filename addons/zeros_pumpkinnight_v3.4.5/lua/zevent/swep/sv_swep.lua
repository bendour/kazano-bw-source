/*
    Addon id: 5d8b797b-05d3-45b1-9efb-d4bfab61cce1
    Version: v3.4.5 (stable)
*/

if CLIENT then return end
zpn = zpn or {}
zpn.Partypopper = zpn.Partypopper or {}

function zpn.Partypopper.ProjectileExplosion(pos, dist, ply)
    for k, v in pairs(ents.FindInSphere(pos, dist)) do
                                                                                                                                                                                                                                                                                                                                                                                                                                                       -- 00000000000000000
                                                                                                                                                                                                                                                                                                                                                                                                                                                       -- 00000000000000000

        if IsValid(v) and zpn.config.PartyPopper.Damage[v:GetClass()] then

            if v:GetClass() == "zpn_destructable" and v.Smashed == true then continue end
			// 1235078258
            local d = DamageInfo()
            d:SetDamage(zpn.config.PartyPopper.Damage[v:GetClass()])
            d:SetAttacker(ply)
            d:SetDamageType(DMG_SONIC)
            v:TakeDamageInfo(d)
        end
    end
end
                                                                                                                                                                                                                                                                                                                                                                                                                                                       -- da71c7e0bf5016ce33a9f318a3747fb53331bb70d9090f016fdcc745ceefa6b8
                                                                                                                                                                                                                                                                                                                                                                                                                                                       -- 6af6efba71e4015ff987fc919ecacbe102ec0873079409ab2a0ed0bf25e3f3cd

// If the player allready has a pumpkin popper then we stop
zclib.Hook.Add("PlayerCanPickupWeapon", "zpn_PartyPopper", function(ply, wep)
    if (wep:GetClass() == "zpn_partypopper" or wep:GetClass() == "zpn_partypopper01") and ply:HasWeapon(wep:GetClass()) then return false end
end)
                                                                                                                                                                                                                                                                                                                                                                                                                                                       -- 6af6efba71e4015ff987fc919ecacbe102ec0873079409ab2a0ed0bf25e3f3cd
