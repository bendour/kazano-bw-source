/*
    Addon id: a36a6eee-6041-4541-9849-360baff995a2
    Version: v1.4.1 (stable)
*/

// THIS MODULE REQUIRES bLOGS https://www.gmodstore.com/market/view/6016

                                                                                                                                                                                                                                                                                                                                                                                                                                                       -- e3b23fe5de9dfb761758a006a7271ce1817b0b3d31fddc5f22fc8264734156bf
                                                                                                                                                                                                                                                                                                                                                                                                                                                       -- 7e845693ad2a490ead94c2e1f6c2eaff90beaf41e1d134566247921805d9f29b

local MODULE = GAS.Logging:MODULE()
MODULE.Category = "Methlab"
MODULE.Name = "Meth"
MODULE.Colour = Color(0, 125, 255, 255)
MODULE:Setup(function()

	MODULE:Hook("zmlab2_OnMethMade", "zmlab2_OnMethMade_blogs", function(ply, frezzingTray, methEnt,mType,mAmount,mQuality)
		if IsValid(ply) and IsValid(methEnt) then
			MODULE:Log("{1} made " .. math.Round(mAmount) .. zmlab2.config.UoM .. " of " .. mQuality .. "% " .. zmlab2.Meth.GetName(mType), GAS.Logging:FormatPlayer(ply))
		end
	end)

	MODULE:Hook("zmlab2_PostMethSell", "zmlab2_PostMethSell_blogs", function(ply,earning,methlist)
		if IsValid(ply) and earning then
			MODULE:Log("{1} sold meth worth of " .. zclib.Money.Display(earning), GAS.Logging:FormatPlayer(ply))
		end
	end)

	MODULE:Hook("zmlab2_OnMethObjectDestroyed", "zmlab2_OnMethObjectDestroyed_blogs", function(methObject,damageinfo)
		if IsValid(methObject) and damageinfo then
			local attacker = damageinfo:GetAttacker()
			if IsValid(attacker) and attacker:IsPlayer() and attacker:Alive() then
                                                                                                                                                                                                                                                                                                                                                                                                                                                       -- 99958388d5b8bc21e4d7af1df39fd75077f0660617b3c526ce40ea9691a5fd3b

				local Earning = 0
		        if methObject:GetClass() == "zmlab2_item_palette" then
		            for k,v in pairs(methObject.MethList) do
		                Earning = Earning + zmlab2.Meth.GetValue(v.t,v.a,v.q)
		            end
		        else
		            Earning = zmlab2.Meth.GetValue(methObject:GetMethType(),methObject:GetMethAmount(),methObject:GetMethQuality())
		        end
				if Earning > 0 then
					MODULE:Log("{1} destroyed " .. zclib.Money.Display(Earning) .. " worth of meth.", GAS.Logging:FormatPlayer(attacker))
				end
			end
		end
	end)
                                                                                                                                                                                                                                                                                                                                                                                                                                                       -- 7e845693ad2a490ead94c2e1f6c2eaff90beaf41e1d134566247921805d9f29b

	MODULE:Hook("zmlab2_OnMethConsum", "zmlab2_OnMethConsum_blogs", function(ply, MethType,MethQuality)
		if IsValid(ply) then
			MODULE:Log("{1} Consumed " .. math.Round(zmlab2.config.Meth.Amount) .. zmlab2.config.UoM .. " of " .. MethQuality .. "% " .. zmlab2.Meth.GetName(MethType), GAS.Logging:FormatPlayer(ply))
		end
	end)
end)
GAS.Logging:AddModule(MODULE)
                                                                                                                                                                                                                                                                                                                                                                                                                                                       -- 00000000000000000
