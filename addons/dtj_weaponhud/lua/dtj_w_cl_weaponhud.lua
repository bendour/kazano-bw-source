if( SERVER ) then return end

-- shorthand
local tbl = dtj.weaponHud;
local themeCall = tbl.themes.call

local math = math
local type = type
local surface = surface
local draw = draw
local string = string

-- autorefresh hack
if( IsValid( tbl.panel ) ) then
	tbl.panel:Remove();
	tbl.panel = nil
end

--[[
	Used to draw the SWEP information/tool tip next to the selected weapon
--]]
local infoIcon 		= Material( "icon16/information.png" );
local shieldIcon 	= Material( "icon16/shield.png" );
local tE		 	= tbl.config.showTooltip

hook.Add( "HUDPaint", "dtjWeaponsTooltip", function()
	if( tE == false or tbl.enabled() < 1 ) then
		return
	end
	
	if( IsValid( tbl.panel ) and tbl.panel.toolTip ) then
		if( tbl.panel.closing and tbl.panel.closing == true ) then
			return 
		end
		
		local t = tbl.panel.toolTip
		if( not t.parsed ) then
			local author, purpose, instructions = t.weapon.Author, t.weapon.Purpose, t.weapon.Instructions
			
			if( author:len() < 1 ) then author = "N/A" end
			if( purpose:len() < 1 ) then purpose = "N/A" end
			if( instructions:len() < 1 ) then instructions = "N/A" end
			
			-- make room for more text
			--instructions = string.Replace( instructions, "\n", " " );
			purpose = string.Replace( purpose, "\n", " " );
			
			t.parsed = markup.Parse( "<colour=255, 255, 255, 255><font=dtjWeaponInfoBold>Author: </font><font=dtjWeaponInfo>" .. author ..
				"</font>\n\n<font=dtjWeaponInfoBold>Purpose: </font><font=dtjWeaponInfo>" .. purpose .. "</font>\n\n<font=dtjWeaponInfoBold>Instructions: </font><font=dtjWeaponInfo>" ..
					instructions .. "</font></colour>", t.w - 5 );
			
			-- adjust height to fit all of our information
			t.h = math.max( t.minH, t.parsed:GetHeight() + 10 );
		end
		
		if( t.parsed ) then
			-- !THEME!
			if( not themeCall( "tooltip" ) ) then
				draw.RoundedBox( 4, t.x, t.y, t.w, t.h, THEME.color or tbl.config.mainColor );
				t.parsed:Draw( t.x + 5, t.y + 5, TEXT_ALIGN_LEFT );
			
				surface.SetDrawColor( 255, 255, 255, 255 );
				surface.SetMaterial( infoIcon );
				surface.DrawTexturedRect( ( t.x + t.w ) - 18, t.y + 4, 16, 16 );
				
				if( t.weapon.AdminOnly and t.weapon.AdminOnly == true ) then
					surface.SetMaterial( shieldIcon );
					surface.DrawTexturedRect( ( t.x + t.w ) - 36, t.y + 4, 16, 16 );
				end
			end
		end
	end
end );

local stockIcon = Material( "weapons/swep" );

local function createWpnPanel( slotId, collapsedWidth, maxHeight )
	local p = vgui.Create( "EditablePanel" );
	p:SetSize( collapsedWidth, maxHeight );
	
	p.selection = 1;	-- what "selected" weapon we are currently on, inside this slot
	p.collapsed = true 	-- are we currently "opened/viewing" ?
	
	local baseExpandedHeight, baseCollapsedHeight = ( tbl.config.expandedHeight * tbl.uiScale ) + 15, tbl.config.collapsedHeight
	local padding = tbl.config.padding
	local slotString = tostring( slotId );
	
	local lp = LocalPlayer();
	local drawSlotNumber = function( x, y, slot )
		surface.SetFont( "dtjWeaponSlotID" );
		surface.SetTextColor( 255, 255, 255, 255 );
		surface.SetTextPos( x, y );
		surface.DrawText( slot );
	end
	
	p.Paint = function( self, w, h )
		local themeData = { self, slotId }
		local weapons = tbl.plWeapons[slotId] or nil
		local yPosition = baseCollapsedHeight + 10
		local qView = tbl.panel.quickview
		local titles = tbl.config.showTitles
		
		-- no titles, shift weapons up
		if( not titles ) then
			--yPosition = 0
		end
		
		-- cheap
		-- but always update where our first slot is positioned, useful for themes
		if( slotId == 1 ) then tbl.beginSlotPos = self:GetPos() end
		
		-- !THEME!
		if( not themeCall( "slotHeader", themeData ) ) then --and ( not titles and self.collapsed == true ) ) then
			draw.RoundedBox( 4, 0, 0, w, baseCollapsedHeight, THEME.color or tbl.config.slotColor );
		end
		
		-- we are currently not opened
		if( self.collapsed == true ) then
			if( titles == true and ( not weapons.title and ( not weapons or #weapons < 1 ) ) ) then
				draw.SimpleText( "EMPTY", "dtjWeaponError", ( w / 2 ), ( baseCollapsedHeight /  2 ), tbl.config.errorColor, TEXT_ALIGN_CENTER, TEXT_ALIGN_CENTER );
			end
		end
		
		-- draw the title of this slot
		if( titles == true and weapons.title and not themeCall( "drawTitles", themeData ) ) then
			draw.SimpleText( weapons.title, "dtjWeaponSlotName", ( w / 2 ), ( baseCollapsedHeight / 2 ), THEME.color or tbl.config.titleColor, TEXT_ALIGN_CENTER, TEXT_ALIGN_CENTER );
		end
		drawSlotNumber( 4, 2, slotString );
		
		--[[
		-- draw slot number
		if( not titles and self.collapsed == true ) then 
			drawSlotNumber( 4, 2, slotString );
		elseif( titles ) then
			drawSlotNumber( 4, 2, slotString );
		end
		--]]
		
		if( ( self.collapsed == true and qView == false ) or #weapons < 1 ) then
			return 
		end
		
		local showIcons = ( tbl.config.showIcons == true ) and ( not themeCall( "drawIcons" ) )
		
		for i = 1, #weapons do
			local wep = weapons[i]
			local textX, textY = 8, 0
			local height = 0
			
			if( not IsValid( wep ) ) then table.remove( tbl.plWeapons[ slotId ], i ); break end;
			
			local wepName = tbl.fixupWeaponName( wep );
			local m = nil
			
			if( not themeCall( "weaponName" ) ) then
				if( qView == true ) then
					m = tbl.nameMarkup( wep, wepName, collapsedWidth - 12, true );
				else
					m = tbl.nameMarkup( wep, wepName, tbl.totalSlotWidth - 12, _, THEME.font );
				end
			end
			
			-- how tall is this weapon text?
			local tH = m:GetHeight();
			
			-- grab weapon ammo data
			local wepHasAmmo = wep:HasAmmo();
			local clip1, clip2 = 0, 0
			local ammo1 = 0
			
			if( wepHasAmmo == true ) then
				clip1, clip2 = wep:Clip1(), wep:Clip2();
				ammo1 = lp:GetAmmoCount( wep:GetPrimaryAmmoType() );
			end
			
			local usesAmmo = ( ( ( clip1 > 0 or ammo1 > 0 ) or ( wepHasAmmo == false ) ) and tbl.config.showAmmo == true )
			
			if( self.selection == i and qView == false ) then
				-- if we're not showing icons, make this "expanded" height, the same as the "collapsed" height
				if( showIcons == false ) then
					height = baseCollapsedHeight
				else
					height = baseExpandedHeight
				end
				
				if( usesAmmo == true or wep:HasAmmo() == false ) then
					if( tH + tbl.ammoHeight > height ) then
						height = height + tH + tbl.ammoHeight
					end
				else
					if( tH + ( self.iconHeight or 0 ) > height ) then
						height = ( self.iconHeight or 0 ) + tH + 5
					end
				end
				
				-- !THEME!
				themeData = { self, 0, yPosition, w, height, slotId }
				if( not themeCall( "selectedPaint", themeData ) ) then
					draw.RoundedBox( 4, 0, yPosition, w, height, THEME.color or tbl.config.selectColor );
				end
		
				if( showIcons == true ) then
					local wpnClass = wep:GetClass();
					local hasCustomIcon = tbl.icons[ wpnClass ] or nil
					
					local letterIcon = wep.IconLetter
					local letterByte = 0
					
					-- some SWEPS provide a letter icon when they shouldn't...
					-- check if we're within the default CSS ASCII codes
					if( tbl.cstrike == true and letterIcon ) then 
						letterByte = string.byte( letterIcon );
						if( not letterByte or not ( letterByte >= 97 and letterByte <= 127 or letterByte >= 79 and letterByte <= 80 ) ) then letterIcon = nil end
					end
					
					-- hl2 weapons/graphics
					if( dtj.weaponHud.hl2Icons[ wpnClass ] and not hasCustomIcon ) then
						local c = dtj.weaponHud.hl2Icons[ wpnClass ]
						draw.SimpleText( c, "dtjHL2", ( w / 2 ), ( yPosition + ( height / 2 ) ) - 15, tbl.config.hl2WeaponColor, TEXT_ALIGN_CENTER, TEXT_ALIGN_CENTER );
					elseif( tbl.cstrike == true and letterIcon and letterByte ) then
						draw.SimpleText( wep.IconLetter, "dtjCStrike", ( w / 2 ), ( yPosition + ( height / 2 ) + 10), tbl.config.hl2WeaponColor, TEXT_ALIGN_CENTER, TEXT_ALIGN_CENTER );
					else
						surface.SetDrawColor( 255, 255, 255, 255 );
						
						if( hasCustomIcon ) then
							local icon = tbl.getIconMat( hasCustomIcon );
							local iW, iH = icon:Width(), icon:Height();
							
							newW, newH = tbl.resizeImage( iW, iH, w - 100, height - 50 );
							self.iconHeight = newH
						
							surface.SetMaterial( icon );
							surface.DrawTexturedRect( ( w / 2 ) - ( newW / 2 ), yPosition + 5, newW, newH );
						else
							-- this swep provides an icon
							if( wep.WepSelectIcon or wep.Icon or wep.SelectIcon ) then
								local icon = nil
								local iW, iH, y = 0, 0, yPosition
								
								if( wep.SelectIcon ) then
									icon = wep.SelectIcon 		-- typically CW Weapons (and MK)
								elseif( wep.Icon ) then
									icon = wep.Icon 			-- other gamemodes/SWEP (TTT)
								else
									icon = wep.WepSelectIcon 	-- default SWEP icon
								end
								
								-- this swep points to a material (it should point to a texture id...)
								if( type( icon ) == "IMaterial" ) then
									surface.SetMaterial( icon );
									iW, iH = icon:Width(), icon:Height();
								elseif( type( icon ) == "number" ) then
									surface.SetTexture( icon );
									iW, iH = surface.GetTextureSize( icon );
								elseif( type( icon ) == "string" ) then
									local mat = tbl.getIconMat( icon );
									surface.SetMaterial( tbl.getIconMat( icon ) );
									iW, iH = mat:Width(), mat:Height();
								else
									-- should never get here. somehow this swep icon is null, or configured different than typical
								end
								
								if( iW > 0 and iH > 0 ) then
									local newW, newH = tbl.resizeImage( iW, iH, w - 25, baseExpandedHeight - 50 );
									
									-- CW icons
									if( wep.SelectIcon and wep.Attachments ) then
										surface.SetDrawColor(255, 210, 0, 255)
										newW = newW * 1.2
										newH = newH * 1.2
										y = y - 25
									end
									
									self.iconHeight = newH
									surface.DrawTexturedRect( ( w / 2 ) - ( newW / 2 ), y + 5, newW, newH );
								end
							else
								local iW, iH = stockIcon:Width(), stockIcon:Height();
								local newW, newH = tbl.resizeImage( iW, iH, w - 100, height - 50 );
								
								self.iconHeight = newH
								
								surface.SetMaterial( stockIcon );
								surface.DrawTexturedRect( ( w / 2 ) - ( newW / 2 ), y, newW, newH )
							end
						end
					end
				end
				
				-- we switched weapons, clear out the tooltip
				if( tbl.panel.toolTip and tbl.panel.toolTip.weapon ~= wep ) then
					tbl.panel.toolTip = nil
				end
				
				-- custom weapon, show information about it
				if( tbl.config.showTooltip == true and wep.DrawWeaponInfoBox == true ) then
					if( wep.Purpose ~= "" or wep.Instructions ~= "" ) then
						local t = tbl.panel.toolTip or {}
						local pX, pY = self:GetPos();
						
						t.x 		= ( pX + w + 15 )
						t.y 		= ( yPosition + tbl.config.offset )
						t.w 		= w * 0.95
						t.minH 		= height
						
						t.weapon 	= wep
						t.panel 	= self
						
						tbl.panel.toolTip = t
					end
				end
				
				--[[
				-- weapon name text position
				if( tbl.config.showIcons == true or usesAmmo == true ) then
					textY = ( ( yPosition + height ) - tH ) - tbl.ammoHeight
				else
					textY = ( ( yPosition + height ) - tH ) - tbl.ammoHeight
				end
				]]--
				
				if( usesAmmo == true or wep:HasAmmo() == false ) then
					textY = ( ( yPosition + height ) - tH ) - tbl.ammoHeight
				else
					if( showIcons == false ) then
						textY = ( ( yPosition + height ) - tH) - tbl.ammoHeight
					else
						textY = ( ( yPosition + height ) - tH )
					end
				end
				
				yPosition = yPosition + height + padding
			else
				-- none selected item drawing
				height = baseCollapsedHeight
				
				-- strectch to fit our text + padding
				if( usesAmmo == true ) then
					if( tH + tbl.ammoHeight > height ) then
						height = height + tbl.ammoHeight + 5
					end
				else
					if( tH > height ) then
						height = height + tbl.ammoHeight + 5
					end
				end
				
				-- !THEME!
				themeData = { self, 0, yPosition, w, height, slotId }
				if( not themeCall( "notSelectedPaint", themeData ) ) then
					draw.RoundedBox( 4, 0, yPosition, w, height, tbl.config.mainColor );
				end
				
				if( qView == true ) then
					textY = yPosition + 8
				else
					textY = ( ( yPosition + height ) - tH) - tbl.ammoHeight
				end
				
				yPosition = yPosition + height + padding
			end

			if( m ) then
				m:Draw( textX, textY, TEXT_ALIGN_LEFT, TEXT_ALIGN_LEFT );
			end
			
			if( tbl.config.showAmmo == true ) then
				if( wepHasAmmo == false ) then
					local s = "NO AMMO"
					surface.SetFont( "dtjWeaponErrorSmall" );
					
					local tW, tH = surface.GetTextSize( s );
					surface.SetTextPos( 8, yPosition - ( tH + 10 ) )
					
					surface.SetTextColor( tbl.config.errorColor.r, tbl.config.errorColor.g, tbl.config.errorColor.b, tbl.config.errorColor.a );
					surface.DrawText( s );
				else
					local s = ""
					if( clip1 == -1 ) then
						s = string.format( "%i", ammo1 );
					else
						s = string.format( "%i / %i", clip1, ammo1 );
					end
					
					if( usesAmmo == true ) then
						surface.SetFont( "dtjWeaponNameSmall" );
						
						local tW, tH = surface.GetTextSize( s );
						surface.SetTextPos( 8, yPosition - ( tH + 10 ) )
						
						surface.SetTextColor( tbl.config.ammoColor.r, tbl.config.ammoColor.g, tbl.config.ammoColor.b, tbl.config.ammoColor.a );
						surface.DrawText( s );
					end
				end
			end
		end
	end
	
	return p
end

function tbl.hideMenu( noAnim )
	if( not IsValid( tbl.panel ) or tbl.panel.closing ) then
		return
	end
	
	-- !THEME!
	themeCall( "closing" );
	
	tbl.panel.closing = true;
	if( noAnim ) then tbl.panel:Remove() return end
	
	tbl.panel:AlphaTo( 0, tbl.config.fadeOutTime, 0, function() 
		if( tbl.panel.closing == true ) then 
			tbl.panel:Remove();
		else
			tbl.panel:SetAlpha( 255 );
		end 
	end );
end

--[[
--]]
function tbl.showMenu( quickView )
	-- we want to open while we're currently closing...
	-- don't let the animation delete us
	if( tbl.panel and ( tbl.panel.closing and tbl.panel.closing == true ) ) then
		tbl.panel.closing = false
	end
	
	local lp = LocalPlayer();
	if( IsValid( tbl.panel ) or not lp:Alive() or ( tbl.config.inVehicle == false and lp:InVehicle() ) ) then
		return
	end
	
	tbl.loadSettings(); 			-- dtj_w_cl_settings.lua
	tbl.updateWeaponTbl( true );	-- make sure we have the latest weapons cached
	
	-- !THEME!
	-- open( masterPanel )
	if( themeCall( "open", mP ) == false ) then return end
	
	local scrW, scrH = ScrW(), ScrH();
	local mP = vgui.Create( "EditablePanel" );
	
	-- !HACK!
	-- If we are running a pretty small resolution, disables titles. It's not going to look good...
	if( scrW < 900 ) then 
		tbl.config.showTitles = false
		tbl.config.showTooltip = false
		tbl.print( "Your resolution is too small. Some items (such as titles) will not appear for aesthetics.. " );
	end
	
	tbl.panel = mP;
	
	mP.actionTime = CurTime();
	
	local padding = tbl.config.padding or 10;
	local numberOfColumns = tbl.config.maxSlots or 6;
	local maxColumnWidth = (scrW / numberOfColumns) -- how many can we fit on our resolution?
	local animTime = tbl.config.fadeInTime or 0.25
	
	-- take up entire size of screen
	mP:SetSize( scrW, scrH );
	
	-- each slot gets it's own panel
	mP.slotPanels = {}
	mP.opening = true;
	
	-- we opened the wepaon drawer, but without selecting a slot to open
	-- this draws in the "quickview" mode
	mP.quickview = true;
	
	local maxSize = 130 -- the largest width a slot can be
	local minSize = tbl.getSlotNameWidth(); -- the smallest width a slot can be. getSlotNameWidth() returns the font width of the largest slot name (so it always fits)
	
	local collapseSize	= math.min(math.max( ( ( maxColumnWidth / 2 ) * tbl.uiScale ), minSize ), maxSize );
	
	local totalSize 	= ( collapseSize * 2 ) + padding -- total (width) of the expanded icon
	local totalWidth 	= ( collapseSize * numberOfColumns ) + padding * (numberOfColumns - 1) -- total width of all icons + padding
	local extraSpace 	= (scrW - ( totalWidth + (totalSize/2)) ) -- how much width is left on our screen
	local fnFinished 	= function() mP.opening = false; --[[ !THEME ! --]] themeCall( "opened", mP ); end
	
	-- cache how large our calculated slot width is
	tbl.totalSlotWidth = totalSize
	
	local beginX = ( extraSpace / 2 )
	if( quickView ) then beginX = beginX + ( (totalSize/2) / 2 ) end
	
	mP.Paint = function( self, w, h )
		--!THEME!
		themeCall( "masterPaint", { self, totalWidth + (totalSize * 0.5), h, tbl.beginSlotPos or 0 } );
	end
	
	mP.PaintOver = function( self, w, h )
		--!THEME!
		themeCall( "masterPaintOver", { self, totalWidth + (totalSize * 0.5), h, tbl.beginSlotPos or 0 } );
	end
	
	for i = 1, numberOfColumns do
		local w = createWpnPanel( i, collapseSize, scrH );
		w:SetAlpha( 0 );
		w:SetParent( mP );
		
		local x = beginX + ( collapseSize * (i - 1) + ( padding * (i - 1) ) )
		w:SetPos( x, tbl.config.offset );
		
		if( i == numberOfColumns ) then
			w:AlphaTo( 255, animTime, 0, fnFinished );
		else
			w:AlphaTo( 255, animTime );
		end
		
		mP.slotPanels[ #mP.slotPanels + 1 ] = w;
	end
	
	-- check if we should close
	local lp = LocalPlayer();
	mP.Think = function( self )
		if( IsValid( lp ) and lp:Alive() == false ) then
			if( not self.closing ) then self:Remove(); end -- don't remove if the animation is closing
		end
		
		if( tbl.config.inVehicle == false and lp:InVehicle() == true ) then
			tbl.hideMenu();
		end
		
		local cTime = tbl.config.showTime
		if( not self.quickview and cTime and cTime > 0.0 ) then
			local t = CurTime();
			if( t - self.actionTime >= cTime ) then
				tbl.hideMenu();
			end
		end
	end
	
	mP.selectSlot = function( self, slotNumber, slotSelection )
		if( not self.slotPanels[ slotNumber ] ) then
			error("Slot number out of range (" .. slotNumber .. ") .. max slots (" .. tbl.config.maxSlots .. ")" );
		end
		
		local p = self.slotPanels[ slotNumber ]
		
		mP.quickview = false;
		p.selection = slotSelection or p.selection
		
		if( not IsValid( p ) ) then
			error( "Master panel exists, but failed to obtain slot panel: (" .. slotNumber .. ") out of (" .. tbl.config.maxSlots .. ")" );
		end
		
		-- no weapons in this slot!!
		if( not tbl.plWeapons[ slotNumber ] or #tbl.plWeapons[ slotNumber ] < 1 ) then
			tbl.playSound( "common/wpn_denyselect.wav" );
			return
		end
		
		-- just select the weapon, and stop (fast switch)
		if( tbl.fastSwitch() == true and slotNumber and slotSelection ) then
			mP.wpn = tbl.plWeapons[slotNumber][p.selection]
			tbl.switchWeapon( mP.wpn );
			return
		end
		
		-- showTime() timer
		self.actionTime = CurTime();
		
		local arrange = false
		if( p.collapsed == true ) then
			p:SetWidth( totalSize - ( padding * 0.5 ) );
			p.collapsed = false
			arrange = true
		else
			p.selection = slotSelection or ( p.selection % ( #tbl.plWeapons[slotNumber] ) ) + 1 -- allow selection up to the amount of weapons in this slot
		end
		
		if( arrange == true ) then
			for i = 1, tbl.config.maxSlots do
				local sp = self.slotPanels[i]
				
				-- make sure we're collapsed (closed)
				if( sp.collapsed == false and slotNumber ~= i ) then
					sp:SetWidth( collapseSize );
					sp.collapsed = true
				end
				
				local x, y = sp:GetPos();
				
				-- we just opened, slide everything to our right over
				if( not mP.openedSlot and i > slotNumber ) then
					sp:SetPos( x+(totalSize/2), y )
				end

				if( mP.openedSlot ) then
					if( i > mP.openedSlot and i <= slotNumber ) then
						sp:SetPos( x-(totalSize/2), y );
					end
					
					if( i > slotNumber and i <= mP.openedSlot ) then
						sp:SetPos( x+(totalSize/2), y )
					end
				end
			end
		end

		if( tbl.config.navSound ) then
			tbl.playSound( tbl.config.navSound );
		end
		
		mP.wpn = tbl.plWeapons[slotNumber][p.selection]
		mP.openedSlot = slotNumber
		
	end
end

--[[
	Show/create the weapon drawer
		then attempt to open to the given slot number, and slot position (selection)
--]]
function tbl.showMenuAndSlot( slotNumber, selection )
	tbl.showMenu();
	
	if( IsValid( tbl.panel ) ) then
		tbl.panel:selectSlot( slotNumber, selection );
	end
end