/*
    Addon id: 5d8b797b-05d3-45b1-9efb-d4bfab61cce1
    Version: v3.4.5 (stable)
*/

ITEM.Name = "Slapper - Candy"
ITEM.Description = "Its a Trap!"
ITEM.Model = "models/zerochain/props_pumpkinnight/zpn_slapper.mdl"
ITEM.Base = "base_darkrp"
ITEM.Stackable = false
ITEM.DropStack = false
ITEM.Skin = 1
                                                                                                                                                                                                                                                                                                                                                                                                                                                       -- ddf04c302d8fd9e30f6a5e9cc4e3787dc09a35f0034528f4b4c268245f97715d

function ITEM:GetSkin()
	return 1
end
                                                                                                                                                                                                                                                                                                                                                                                                                                                       -- 00000000000000000
                                                                                                                                                                                                                                                                                                                                                                                                                                                       -- 69811ac079f3e93f705541d1ed39dfac3a9e2460011697a76c02cf9afa26f9c3

function ITEM:CanPickup(pl, ent)
	if ent.GotPlaced then
		return false
	else
		return true
	end
end
                                                                                                                                                                                                                                                                                                                                                                                                                                                       -- 00000000000000000
                                                                                                                                                                                                                                                                                                                                                                                                                                                       -- da71c7e0bf5016ce33a9f318a3747fb53331bb70d9090f016fdcc745ceefa6b8
