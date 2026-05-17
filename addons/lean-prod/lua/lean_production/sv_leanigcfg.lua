/* 00000000000000000 */
if !SERVER then return end
hook.Add("PlayerSay", "leancfgmenu", function(ply,text)
	if IsValid(ply) && table.HasValue(lean_config.maxpermitted,ply:GetUserGroup()) && text == lean_config.igconfigcmd then
		net.Start("LeanigConfig")
		net.Send(ply)
	end
end)
hook.Add("PlayerInitialSpawn", "lean_loadCFG", function(ply)
	net.Start("lean_initialupdate")
	net.WriteTable(lean_updated)
	net.Send(ply)
end)
net.Receive("lean_updatecfg", function(_,ply)
	if not table.HasValue(lean_config.maxpermitted,ply:GetUserGroup()) then return end
	local key = net.ReadString()
	local id = net.ReadString()
	local value = (value or nil)
	if id == "int" then
		value = net.ReadInt(32)
	elseif id == "tbl" then
		value = net.ReadTable()
	elseif id == "col" then
		value = net.ReadColor()
	elseif id == "bool" then
		value = net.ReadBool()
	elseif id == "str" then
		value = net.ReadString()
	end
	lean_updated[key].val = value
	file.Write("lean_production/config.txt",util.TableToJSON(lean_updated))
	lean_updated = util.JSONToTable(file.Read("lean_production/config.txt","DATA"))
	net.Start("lean_initialupdate")
	net.WriteTable(lean_updated)
	net.Broadcast()
	net.Start("lean_msg")
	net.WriteString("Successfully updated " .. key)
	net.Send(ply)
end)