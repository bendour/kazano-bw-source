zmlab = zmlab or {}
zmlab.f = zmlab.f or {}


-- List of all the zmlab Entities on the server
if zmlab.EntList == nil then
	zmlab.EntList = {}
end

function zmlab.f.EntList_Add(ent)
	table.insert(zmlab.EntList, ent)
end
