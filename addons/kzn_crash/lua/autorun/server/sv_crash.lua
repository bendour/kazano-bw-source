concommand.Add("nl_restart", function(ply, cmd, tbl, args)
	if (!IsValid(ply) or ply:IsSuperAdmin()) then
		for k , v in pairs(player.GetAll()) do
			local succ, err = pcall(function() v:Team() end)
            v:SendLua("NL_OpenCrashMenu()")
		end
	end
end)