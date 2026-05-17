/*
    Addon id: a36a6eee-6041-4541-9849-360baff995a2
    Version: v1.4.1 (stable)
*/

if not SERVER then return end
zmlab2 = zmlab2 or {}
zmlab2.Cleaning = zmlab2.Cleaning or {}

function zmlab2.Cleaning.Setup(ent)
	ent.Cleaning_Goal = math.random(3,10)
end

function zmlab2.Cleaning.Inflict(ent,ply,OnFinished)
                                                                                                                                                                                                                                                                                                                                                                                                                                                       -- 20505de7028925e794a03b5d1a113ab09db033ae5f8a5a69bfd7d0ab6982aaae
                                                                                                                                                                                                                                                                                                                                                                                                                                                       -- 7e845693ad2a490ead94c2e1f6c2eaff90beaf41e1d134566247921805d9f29b

	if ent.Cleaning_Goal == nil then zmlab2.Cleaning.Setup(ent) end
	ent.Cleaning_Goal = math.Clamp(ent.Cleaning_Goal - 1,0,10)
                                                                                                                                                                                                                                                                                                                                                                                                                                                       -- 20505de7028925e794a03b5d1a113ab09db033ae5f8a5a69bfd7d0ab6982aaae

	if ent.Cleaning_Goal <= 0 then
		ent.Cleaning_Goal = nil
		ent:RemoveAllDecals()
		pcall(OnFinished)
	end
                                                                                                                                                                                                                                                                                                                                                                                                                                                       -- 071bfceb8fb4fbc39d3b52c5c3fe7b52159006ab4669d1b75f42deff9fdb1cb2

	local tr = ply:GetEyeTrace()
	if tr and tr.Hit and tr.HitPos then
		zclib.NetEvent.Create("clean",{[1] = tr.HitPos})
	end
end
                                                                                                                                                                                                                                                                                                                                                                                                                                                       -- 00000000000000000
