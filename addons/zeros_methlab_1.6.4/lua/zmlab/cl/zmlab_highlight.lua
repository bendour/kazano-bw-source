if (not CLIENT) then return end
local zmlab_Halotable = {}
local trace
local traceEnt
local lastTrace

hook.Add("PreDrawHalos", "a_zmlab_AddHalos", function()
	if zmlab.config.Meth.Consumable then
		if (CurTime() > (lastTrace or 1)) then
			zmlab_Halotable = {}
			lastTrace = CurTime() + 0.3
			trace = LocalPlayer():GetEyeTrace()
			traceEnt = trace.Entity

			-- Adds Halo
			if (IsValid(traceEnt) and traceEnt:GetClass() == "zmlab_meth_baggy") then
				table.insert(zmlab_Halotable, traceEnt)
			end
		end

		halo.Add(zmlab_Halotable, zmlab.default_colors["white01"], 3, 3, 2, true, true)
	end
end)
