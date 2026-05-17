/*
    Addon id: 5d8b797b-05d3-45b1-9efb-d4bfab61cce1
    Version: v3.4.5 (stable)
*/

zpn = zpn or {}
                                                                                                                                                                                                                                                                                                                                                                                                                                                       -- 69811ac079f3e93f705541d1ed39dfac3a9e2460011697a76c02cf9afa26f9c3

function zpn.Print(msg)
	MsgC(Color(226, 147, 45), "[Zero´s PumpkinNight] -> ", Color(255, 255, 255), msg .. "\n")
end
                                                                                                                                                                                                                                                                                                                                                                                                                                                       -- 00000000000000000
                                                                                                                                                                                                                                                                                                                                                                                                                                                       -- da71c7e0bf5016ce33a9f318a3747fb53331bb70d9090f016fdcc745ceefa6b8
                                                                                                                                                                                                                                                                                                                                                                                                                                                       -- 00000000000000000
                                                                                                                                                                                                                                                                                                                                                                                                                                                       -- 6af6efba71e4015ff987fc919ecacbe102ec0873079409ab2a0ed0bf25e3f3cd

if (CLIENT) then
	// Returns the correct Icon depending on Candy Amount
	function zpn.CandyIcon(candy,max)
		if candy >= max then
			return "zpn_candy_large"
		elseif candy >= max / 2 then
			return "zpn_candy_medium"
		else
			return "zpn_candy_small"
		end
	end
end
