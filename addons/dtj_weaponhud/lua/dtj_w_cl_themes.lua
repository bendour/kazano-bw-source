if( SERVER ) then return end

-- shorthand
local tbl = dtj.weaponHud

-- lua autorefresh
-- re-create the table, as each theme will add itself again
tbl.themes = {}
tbl.themes.selected = "default";

local defaultTheme = nil;

local unpack = unpack
local table = table

THEME = {}

--[[
	Adds a theme to the available list of themes
	Please read the README inside "themes" directory for more information
--]]
function tbl.themes.add( name, data )
	assert( name, "missing theme name" );
	assert( data, "missing theme data");
	
	name = string.lower( name );
	
	if( tbl.themes[name] ) then
		return
	end
	
	if( not data.begin ) then
		error( "theme (" .. name ..") is missing begin() entry point" );
		return
	end
	
	tbl.themes[ name ] = data
	tbl.themes[ name ].loaded = false
	
	-- always load default theme
	if( name == "default" ) then
		tbl.themes[ name ]:begin();
		tbl.themes[ name ].loaded = true
		defaultTheme = _G.dtj.weaponHud.themes["default"]
	end
	
	tbl.print( "Theme (" .. name .. ") registered" );
end

--[[
	Returns the currently selected theme name (string)
--]]
function tbl.themes.getSelected()
	return tbl.themes.selected or "default"
end

--[[
	Returns the theme table
--]]
function tbl.themes.getTheme( themeName )
	return tbl.themes[ tbl.themes[themeName] or tbl.themes.getSelected() ]
end

--[[
	Does this theme name exist
--]]
function tbl.themes.isValid( themeName )
	assert( themeName, "missing theme name" );
	
	if( tbl.themes[ themeName ] and tbl.themes[ themeName ].begin ) then
		return true
	end
	
	return false
end

--[[
	Select this theme
	Will verify it's valid, error if not
--]]
function tbl.themes.select( themeName )
	assert( themeName, "missing theme name" );
	themeName = string.lower( themeName );
	
	if( not tbl.themes.isValid( themeName ) ) then
		error( "failed to find theme (" .. themeName .. ") double check the spelling" );
		return
	end
	
	if( tbl.themes.getSelected() == themeName ) then
		return
	end
	
	-- unload our current theme
	tbl.themes[ tbl.themes.getSelected() ].loaded = false
	tbl.themes.selected = themeName
	
	tbl.print("theme '" .. themeName .. "' selected" );
	hook.Call( "dtjThemeSelected" );
end

--[[
	Calls a theme function
	If the selected theme does not contain the hook, it will attempt to call it from the default theme
--]]
function tbl.themes.call( fn, data )
	if( tbl.config.useThemes == false ) then return end
	
	THEME = {}
	
	local sel = tbl.themes.selected or "default"
	if( not tbl.themes[sel] ) then return end
	
	-- we don't populate the table until we need it
	if( not tbl.themes[sel].loaded ) then
		tbl.themes[sel]:begin();
		tbl.themes[sel].loaded = true
	end
	
	local gfn = _G.dtj.weaponHud.themes[sel][fn];

	if( not gfn ) then
		-- this theme did not include this function
		-- check if our default (master) theme has it
		if( defaultTheme[fn] ) then
			gfn = defaultTheme[fn]
		else
			return
		end
	end
	
	if( data ) then
		return gfn( unpack( data ) );
	else
		return gfn();
	end
end