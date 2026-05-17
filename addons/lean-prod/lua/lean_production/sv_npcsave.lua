function lean_config.SpawnSavedNPCS()
	if file.Exists("lean_production/npcs.txt","DATA") then
		local npcs = util.JSONToTable(file.Read("lean_production/npcs.txt","DATA"))
		for k, v in pairs(npcs) do
			local npc = ents.Create("lean_buyer")
			npc:SetPos(v.pos)
			npc:SetAngles(v.ang)
			npc:Spawn()
		end
	end
end
hook.Add("InitPostEntity", "lean_initEnts", lean_config.SpawnSavedNPCS)
hook.Add("PostCleanupMap", "lean_cleanupRespawnEnts", lean_config.SpawnSavedNPCS)

function lean_config.SaveNPCS(ply)
	local lean_npcs = {}
	for k, v in pairs(ents.FindByClass("lean_buyer")) do
		table.insert(lean_npcs,{pos = v:GetPos(),ang = v:GetAngles()})
		v:Remove()
	end
	local npcs = util.TableToJSON(lean_npcs)
	file.Write("lean_production/npcs.txt", npcs)
	lean_config.SpawnSavedNPCS()
	net.Start("lean_msg")
	net.WriteString("All NPC's on the map were saved! ( No need to restart :D )")
	net.Send(ply)
end
hook.Add("PlayerSay", "lean_verifysavingnpc", function(ply, txt)
	if !ply:IsPlayer() then return end
	if !ply:IsSuperAdmin() then return end
	if string.lower(txt) == "!savelean" then
		lean_config.SaveNPCS(ply)
	elseif string.lower(txt) == "!leanbuyer" then
		local npc = ents.Create("lean_buyer")
		npc:SetPos(ply:GetPos())
		npc:SetAngles(ply:GetAngles())
		npc:Spawn()
		net.Start("lean_msg")
		net.WriteString("NPC spawned")
		net.Send(ply)
	end
end)