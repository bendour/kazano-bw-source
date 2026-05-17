-- HTML Loader pour Casino Addon
-- Inspiré de gm_html_loader par Periapsises

Casino = Casino or {}

if SERVER then
	util.AddNetworkString("Casino_LoadHTML")
	
	local htmlCache = {}
	
	-- Compiler un fichier HTML en remplaçant les liens CSS et scripts JS
	local function compileHTMLFile(filePath, gameName)
		local content = file.Read(filePath, "LUA")
		if not content then return nil end
		
		-- Remplacer les <script src="..."></script>
		content = content:gsub('(<script%s+src="([^"]+)"></script>)', function(fullTag, src)
			-- Ignorer les URLs externes
			if src:match("^https?://") or src:match("^asset://") then
				return fullTag
			end
			
			-- Construire le chemin du script (relatif à html/includes/)
			local scriptPath = "html/includes/" .. src .. ".lua"
			
			if not file.Exists(scriptPath, "LUA") then
				print(string.format("[Casino HTML Loader] Script not found: %s", scriptPath))
				return fullTag
			end
			
			local scriptContent = file.Read(scriptPath, "LUA")
			if not scriptContent then
				print(string.format("[Casino HTML Loader] Could not read script: %s", scriptPath))
				return fullTag
			end
			
			return "<script>\n" .. scriptContent .. "\n</script>"
		end)
		
		-- Remplacer les <link rel="stylesheet" href="...">
		content = content:gsub('(<link%s+rel="stylesheet"%s+href="([^"]+)">)', function(fullTag, href)
			-- Ignorer les URLs externes
			if href:match("^https?://") or href:match("^asset://") then
				return fullTag
			end
			
			-- Construire le chemin du CSS (relatif à html/includes/)
			local cssPath = "html/includes/" .. href .. ".lua"
			
			if not file.Exists(cssPath, "LUA") then
				print(string.format("[Casino HTML Loader] CSS not found: %s", cssPath))
				return fullTag
			end
			
			local cssContent = file.Read(cssPath, "LUA")
			if not cssContent then
				print(string.format("[Casino HTML Loader] Could not read CSS: %s", cssPath))
				return fullTag
			end
			
			return "<style>\n" .. cssContent .. "\n</style>"
		end)
		
		return content
	end
	
	-- Recevoir une demande de chargement HTML
	net.Receive("Casino_LoadHTML", function(len, ply)
		local fileName = net.ReadString()
		
		if not fileName or fileName == "" then
			-- print("[Casino HTML Loader] Player " .. ply:Nick() .. " requested empty file!")
			return
		end
		
		-- SÉCURITÉ: Valider le nom de fichier pour éviter path traversal
		if fileName:find("%.%.") then
			print(string.format("[Casino HTML Loader] SECURITY: %s tried path traversal: %s", ply:Nick(), fileName))
			return
		end
		
		-- SÉCURITÉ: Whitelist des fichiers autorisés
		local allowedFiles = {
			["main"] = true,
			["main/main.html"] = true,
			["blackjack"] = true,
			["blackjack/blackjack.html"] = true,
			["slots"] = true,
			["slots/slots.html"] = true,
			["roulette"] = true,
			["roulette/roulette.html"] = true,
			["mines"] = true,
			["mines/mines.html"] = true,
			["chicken"] = true,
			["chicken/chicken.html"] = true,
			["crash"] = true,
			["crash/crash.html"] = true
		}
		
		if not allowedFiles[fileName] then
			print(string.format("[Casino HTML Loader] SECURITY: %s tried to access unauthorized file: %s", ply:Nick(), fileName))
			return
		end
		
		-- Vérifier le cache
		if htmlCache[fileName] then
			net.Start("Casino_LoadHTML")
			net.WriteString(fileName)
			net.WriteString(htmlCache[fileName])
			net.Send(ply)
			return
		end
		
		-- Charger et compiler le fichier
		-- Support pour "main" ou "main/main.html"
		local filePath
		local gameName
		
		if fileName:find("/") then
			-- Format complet : "main/main.html"
			gameName = fileName:match("^([^/]+)/")
			filePath = "html/includes/" .. fileName .. ".lua"
		else
			-- Format court : "main"
			gameName = fileName
			filePath = "html/includes/" .. fileName .. "/" .. fileName .. ".html.lua"
		end
		
		if not file.Exists(filePath, "LUA") then
			print(string.format("[Casino HTML Loader] File not found: %s", filePath))
			net.Start("Casino_LoadHTML")
			net.WriteString(fileName)
			net.WriteString("")
			net.Send(ply)
			return
		end
		
		local compiled = compileHTMLFile(filePath, gameName)
		
		if not compiled then
			print(string.format("[Casino HTML Loader] Could not compile: %s", fileName))
			net.Start("Casino_LoadHTML")
			net.WriteString(fileName)
			net.WriteString("")
			net.Send(ply)
			return
		end
		
		-- Mettre en cache
		htmlCache[fileName] = compiled
		
		-- Envoyer au client
		net.Start("Casino_LoadHTML")
		net.WriteString(fileName)
		net.WriteString(compiled)
		net.Send(ply)
	end)
	
	-- Nettoyer le cache
	concommand.Add("casino_clearcache", function(ply, cmd, args)
		if IsValid(ply) and not ply:IsSuperAdmin() then return end
		
		htmlCache = {}
		
		if IsValid(ply) then
			ply:ChatPrint("[Casino] Cache HTML vidé!")
		end
	end)
end

if CLIENT then
	local htmlCache = {}
	local loadCallbacks = {}
	
	-- Charger un fichier HTML
	function Casino.LoadHTML(fileName, callback)
		-- Vérifier le cache
		if htmlCache[fileName] then
			if callback then
				callback(htmlCache[fileName])
			end
			return htmlCache[fileName]
		end
		
		-- Ajouter le callback
		if callback then
			loadCallbacks[fileName] = loadCallbacks[fileName] or {}
			table.insert(loadCallbacks[fileName], callback)
		end
		
		-- Demander au serveur
		net.Start("Casino_LoadHTML")
		net.WriteString(fileName)
		net.SendToServer()
		
		return nil
	end
	
	-- Recevoir le HTML compilé
	net.Receive("Casino_LoadHTML", function()
		local fileName = net.ReadString()
		local content = net.ReadString()
		
		if content == "" then
			-- print("[Casino HTML Loader] Failed to load: " .. fileName)
			return
		end
		
		-- Mettre en cache
		htmlCache[fileName] = content
		
		-- Exécuter les callbacks
		if loadCallbacks[fileName] then
			for _, callback in ipairs(loadCallbacks[fileName]) do
				callback(content)
			end
			loadCallbacks[fileName] = nil
		end
	end)
	
	-- print("[Casino HTML Loader] Client loaded")
end

-- Extension de DHTML pour LoadFile (doit être après la partie CLIENT)
if CLIENT then
	-- Ajouter immédiatement la fonction à DHTML
	local DHTML = vgui.GetControlTable("DHTML")
	
	if DHTML then
		function DHTML:LoadCasinoFile(fileName)
			Casino.LoadHTML(fileName, function(content)
				if IsValid(self) then
					self:SetHTML(content)
				end
			end)
		end
	else
		-- Si DHTML n'est pas encore disponible, attendre
		timer.Simple(0, function()
			local DHTML = vgui.GetControlTable("DHTML")
			
			if not DHTML then
				ErrorNoHalt("[Casino HTML Loader] ERREUR: Impossible de récupérer la table DHTML!\n")
				return
			end
			
			function DHTML:LoadCasinoFile(fileName)
				Casino.LoadHTML(fileName, function(content)
					if IsValid(self) then
						self:SetHTML(content)
					end
				end)
			end
		end)
	end
end
