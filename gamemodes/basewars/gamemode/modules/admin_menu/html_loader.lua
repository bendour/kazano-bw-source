-- HTML Loader for Admin Menu
-- Compiles HTML, CSS, and JS into a single string

local AdminMenuHTML = {}

-- Cache for compiled HTML
local cachedHTML = nil
local isCompiling = false
local CACHE_FILE = "basewars_admin_menu_cache.txt"
local CACHE_VERSION = "1.2" -- Increment when making changes to force reload

-- Load from file cache
local function LoadFromFileCache()
    if file.Exists(CACHE_FILE, "DATA") then
        local data = file.Read(CACHE_FILE, "DATA")
        if data then
            local version, html = data:match("^V:([%d%.]+)\n(.+)$")
            if version == CACHE_VERSION and html then
                return html
            end
        end
    end
    return nil
end

-- Save to file cache
local function SaveToFileCache(html)
    file.Write(CACHE_FILE, "V:" .. CACHE_VERSION .. "\n" .. html)
end

-- Compile all HTML components
function AdminMenuHTML.Compile()
    if cachedHTML then
        return cachedHTML
    end
    
    -- Try to load from file cache first
    local fileCache = LoadFromFileCache()
    if fileCache then
        cachedHTML = fileCache
        return cachedHTML
    end
    
    if isCompiling then return "" end
    isCompiling = true
    
    -- Load components from lua files (use gamemode-relative paths)
    local html = include("basewars/gamemode/modules/admin_menu/html/admin_menu.html.lua") or ""
    local css = include("basewars/gamemode/modules/admin_menu/html/admin_menu.css.lua") or ""
    local js = include("basewars/gamemode/modules/admin_menu/html/admin_menu.js.lua") or ""
    
    -- Inject CSS and JS into HTML
    local compiledHTML = html
    compiledHTML = string.Replace(compiledHTML, "/* CSS_PLACEHOLDER */", css)
    compiledHTML = string.Replace(compiledHTML, "/* JS_PLACEHOLDER */", js)
    
    cachedHTML = compiledHTML
    isCompiling = false
    
    -- Save to file cache for faster loading next time
    SaveToFileCache(compiledHTML)
    
    return cachedHTML
end

-- Clear cache (useful for development)
function AdminMenuHTML.ClearCache()
    cachedHTML = nil
    if file.Exists(CACHE_FILE, "DATA") then
        file.Delete(CACHE_FILE)
    end
end

-- Get compiled HTML
function AdminMenuHTML.Get()
    return AdminMenuHTML.Compile()
end

-- Pre-compile on load to avoid freeze on first open
hook.Add("InitPostEntity", "BaseWars:AdminMenu:PreCompileHTML", function()
    timer.Simple(5, function()
        AdminMenuHTML.Compile()
    end)
end)

-- Console command to clear cache (for development)
concommand.Add("bw_admin_clearcache", function()
    AdminMenuHTML.ClearCache()
    print("[BaseWars] Admin menu cache cleared")
end)

return AdminMenuHTML
