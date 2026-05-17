zwf = zwf or {}
zwf.f = zwf.f or {}

-- List of all the zwf Entities on the server
if zwf.EntList == nil then
	zwf.EntList = {}
end

function zwf.f.EntList_Add(ent)
	table.insert(zwf.EntList, ent)
end

if SERVER then
	concommand.Add("zwf_debug_EntList", function(ply, cmd, args)
		if zwf.f.IsAdmin(ply) then
			PrintTable(zwf.EntList)
		end
	end)
end
