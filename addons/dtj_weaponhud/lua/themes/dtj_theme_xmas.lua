local tbl = dtj.weaponHud
local theme = {}

function theme.begin( self )
	local c = Material( "dtj/weaponhud/stars.png", "noclamp 1" );
	local l = Material( "dtj/weaponhud/holiday_lights.png", "mips" );
	
	local titleColor = Color( 62, 255, 40, 255 );
	local altTitleColor = Color( 255, 0, 0, 255 );
	
	local selectedColor = Color( 168, 48, 48, 100 );
	
	self.selectedPaint = function( panel, x, y, w, h )
		draw.RoundedBox( 4, x, y, w, h, selectedColor );
		
		surface.SetDrawColor( 255, 255, 255, 255 );
		surface.SetMaterial( c );
		surface.DrawTexturedRect( x, y, w, h );
		
		return true
	end
	
	self.drawTitles = function( panel, slotId )
		if( ( slotId % 2 ) == 0 ) then
			THEME.color = titleColor
		else
			THEME.color = altTitleColor
		end
	end
	
	self.masterPaint = function( panel, w, h, slotStartingX )
		surface.SetDrawColor( 255, 255, 255, 150 );
		surface.SetMaterial( l );
		surface.DrawTexturedRect( slotStartingX, -15, w, 193);
	end
end

tbl.themes.add( "xmas", theme );