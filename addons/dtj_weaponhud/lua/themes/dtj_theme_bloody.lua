local tbl = dtj.weaponHud
local theme = {}

function theme.begin( self )
	local b1 = Material( "dtj/weaponhud/blood1.png", "mips" );
	local b1_w, b1_h = 257, 238
	
	local titleColor = Color( 62, 255, 40, 255 );
	local altTitleColor = Color( 255, 0, 0, 255 );
	local selectedColor = Color( 168, 48, 48, 100 );
	
	self.slotTitle = function( panel, slotId )
	end
	
	-- disable icons
	self.drawIcons = function() return true end
	
	-- disable titles
	self.drawTitles = function() return true end
	
	self.masterPaint = function( panel, w, h, slotStartingX )
		surface.SetDrawColor( 255, 255, 255, 225 );
		surface.SetMaterial( b1 );
		
		surface.DrawTexturedRect( slotStartingX, -b1_h+100, b1_w, b1_h );
		surface.DrawTexturedRect( w+50, -b1_h+35, b1_w, b1_h, 2 );
	end
end

tbl.themes.add( "bloody", theme );