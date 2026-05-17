local tbl = dtj.weaponHud
local theme = {} -- MAKE SURE THIS IS LOCAL

-- called when the theme is being ran for the first time
-- this is called only once
function theme.begin( self )
end

tbl.themes.add( "default", theme );