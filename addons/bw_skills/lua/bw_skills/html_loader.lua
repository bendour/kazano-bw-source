--[[
    HTML Loader pour BW Skills
]]

BWSkills = BWSkills or {}

if SERVER then
    local htmlCache = nil
    
    -- Compiler un fichier HTML
    local function compileHTMLFile(filePath)
        local luaCode = file.Read(filePath, "LUA")
        if not luaCode then 
            print("[BW Skills] Could not read: " .. filePath)
            return nil 
        end
        
        local func = CompileString(luaCode, filePath)
        if not func then
            print("[BW Skills] Failed to compile: " .. filePath)
            return nil
        end
        
        local content = func()
        if not content then
            print("[BW Skills] Function returned nil: " .. filePath)
            return nil
        end
        
        -- Remplacer les <script src="..."></script>
        content = content:gsub('(<script%s+src="([^"]+)"></script>)', function(fullTag, src)
            if src:match("^https?://") or src:match("^asset://") then
                return fullTag
            end
            
            local scriptPath = "bw_skills/html/" .. src .. ".lua"
            
            if not file.Exists(scriptPath, "LUA") then
                print(string.format("[BW Skills] Script not found: %s", scriptPath))
                return fullTag
            end
            
            local scriptCode = file.Read(scriptPath, "LUA")
            if not scriptCode then return fullTag end
            
            local scriptFunc = CompileString(scriptCode, scriptPath)
            if not scriptFunc then return fullTag end
            
            local scriptContent = scriptFunc()
            if not scriptContent then return fullTag end
            
            return "<script>\n" .. scriptContent .. "\n</script>"
        end)
        
        -- Remplacer les <link rel="stylesheet" href="...">
        content = content:gsub('(<link%s+rel="stylesheet"%s+href="([^"]+)">)', function(fullTag, href)
            if href:match("^https?://") or href:match("^asset://") then
                return fullTag
            end
            
            local cssPath = "bw_skills/html/" .. href .. ".lua"
            
            if not file.Exists(cssPath, "LUA") then
                print(string.format("[BW Skills] CSS not found: %s", cssPath))
                return fullTag
            end
            
            local cssCode = file.Read(cssPath, "LUA")
            if not cssCode then return fullTag end
            
            local cssFunc = CompileString(cssCode, cssPath)
            if not cssFunc then return fullTag end
            
            local cssContent = cssFunc()
            if not cssContent then return fullTag end
            
            return "<style>\n" .. cssContent .. "\n</style>"
        end)
        
        return content
    end
    
    -- Compiler le HTML (appelé par sv_main.lua)
    function BWSkills.CompileHTML()
        local htmlPath = "bw_skills/html/skills_menu.html.lua"
        
        if htmlCache then
            return htmlCache
        end
        
        local compiled = compileHTMLFile(htmlPath)
        if not compiled then
            print("[BW Skills] Failed to load HTML!")
            return nil
        end
        
        htmlCache = compiled
        return htmlCache
    end
    
    -- Recharger le cache
    concommand.Add("bw_skills_reload_html", function(ply)
        if IsValid(ply) and not ply:IsSuperAdmin() then return end
        
        htmlCache = nil
        print("[BW Skills] HTML cache cleared!")
        
        if IsValid(ply) then
            ply:ChatPrint("[BW Skills] HTML cache cleared!")
        end
    end)
end
