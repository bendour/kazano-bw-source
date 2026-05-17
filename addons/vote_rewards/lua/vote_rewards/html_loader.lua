-- HTML Loader pour Vote Rewards Wheelspin
VoteRewards = VoteRewards or {}

if SERVER then
	util.AddNetworkString("VoteRewards_LoadHTML")
	
	local htmlCache = {}
	
	-- Compiler un fichier HTML
	local function compileHTMLFile(filePath)
		-- Charger et exécuter le fichier Lua pour obtenir le contenu
		local luaCode = file.Read(filePath, "LUA")
		if not luaCode then return nil end
		
		-- Exécuter le code Lua pour obtenir le HTML
		local func = CompileString(luaCode, filePath)
		if not func then
			return nil
		end
		
		local content = func()
		if not content then
			return nil
		end
		
		-- Remplacer les <script src="..."></script>
		content = content:gsub('(<script%s+src="([^"]+)"></script>)', function(fullTag, src)
			if src:match("^https?://") or src:match("^asset://") then
				return fullTag
			end
			
			local scriptPath = "vote_rewards/html/" .. src .. ".lua"
			
			if not file.Exists(scriptPath, "LUA") then
				return fullTag
			end
			
			local scriptCode = file.Read(scriptPath, "LUA")
			if not scriptCode then
				return fullTag
			end
			
			-- Exécuter le code Lua pour obtenir le JavaScript
			local scriptFunc = CompileString(scriptCode, scriptPath)
			if not scriptFunc then
				return fullTag
			end
			
			local scriptContent = scriptFunc()
			if not scriptContent then
				return fullTag
			end
			
			return "<script>\n" .. scriptContent .. "\n</script>"
		end)
		
		-- Remplacer les <link rel="stylesheet" href="...">
		content = content:gsub('(<link%s+rel="stylesheet"%s+href="([^"]+)">)', function(fullTag, href)
			if href:match("^https?://") or href:match("^asset://") then
				return fullTag
			end
			
			local cssPath = "vote_rewards/html/" .. href .. ".lua"
			
			if not file.Exists(cssPath, "LUA") then
				return fullTag
			end
			
			local cssCode = file.Read(cssPath, "LUA")
			if not cssCode then
				return fullTag
			end
			
			-- Exécuter le code Lua pour obtenir le CSS
			local cssFunc = CompileString(cssCode, cssPath)
			if not cssFunc then
				return fullTag
			end
			
			local cssContent = cssFunc()
			if not cssContent then
				return fullTag
			end
			
			return "<style>\n" .. cssContent .. "\n</style>"
		end)
		
		return content
	end
	
	-- Charger et envoyer le HTML compilé
	function VoteRewards.LoadHTML(ply)
		local htmlPath = "vote_rewards/html/wheelspin.html.lua"
		
		if htmlCache[htmlPath] then
			net.Start("VoteRewards_LoadHTML")
				net.WriteString(htmlCache[htmlPath])
			net.Send(ply)
			return
		end
		
		local compiled = compileHTMLFile(htmlPath)
		if not compiled then
			return
		end
		
		htmlCache[htmlPath] = compiled
		
		net.Start("VoteRewards_LoadHTML")
			net.WriteString(compiled)
		net.Send(ply)
	end
	
	-- Recevoir les demandes de HTML
	net.Receive("VoteRewards_LoadHTML", function(len, ply)
		VoteRewards.LoadHTML(ply)
	end)
	
	-- Recharger le cache (pour le développement)
	concommand.Add("vote_reload_html", function(ply)
		if IsValid(ply) and not ply:IsSuperAdmin() then return end
		
		htmlCache = {}
		
		if IsValid(ply) then
			ply:ChatPrint("[Vote Rewards] HTML cache cleared!")
		end
	end)
end
