local tbl = dtj.weaponHud
local theme = {}

function theme.begin( self )
	local c = Material( "dtj/weaponhud/carbon.png", "noclamp 1" );
	
	-- re-create fonts
	surface.CreateFont( "dtjWeaponNameCARBON", {
		font = "Roboto Bk",
		size = 24,
		weight = 500,
		antialias = true,
		additive = true,
		outline = true,
		scanlines = 2
	} )
	
	self.weaponName = function()
		THEME.font = "dtjWeaponNameCARBON"
	end
	
	self.selectedPaint = function( panel, x, y, w, h )
		surface.SetDrawColor( 255, 255, 255, 125 );
		surface.SetMaterial( c );
		surface.DrawTexturedRect( x, y, w, h );
	end
end

tbl.themes.add( "carbon", theme );