hook.Add( "OnEntityCreated", "EntDrawDistance", function(ent)
	if (type(ent) == "Entity") and !(type(ent) == "Vehicle") then  
		ent:SetSaveValue("fademindist", 1500) 
		ent:SetSaveValue("fademaxdist", 1650)
	elseif (type(ent) == "NPC") then
		ent:SetSaveValue("fademindist", 1000) 
		ent:SetSaveValue("fademaxdist", 1050)
	else
		ent:SetSaveValue("fademindist", 2500) 
		ent:SetSaveValue("fademaxdist", 2500)
	end
end)
 
hook.Add( "PlayerSpawn", "plyDrawDistance", function(ply)
	if !(type(ply) == "Player") then return end
	ply:SetSaveValue("fademindist", 2500) 
	ply:SetSaveValue("fademaxdist", 2500)
end)