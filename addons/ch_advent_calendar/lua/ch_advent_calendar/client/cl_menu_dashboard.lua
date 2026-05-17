--[[
	Open the menu
--]]
function CH_Advent.DashboardMenu( timeleft, day )
	local ply = LocalPlayer()
	
	-- Remove it if open
	if IsValid( GUI_AdventCalendarFrame ) then
		GUI_AdventCalendarFrame:Close()
	end
	
	-- Decrease it
	timer.Create( "CH_Advent_Timer_CalculateTimeleft", 1, 0, function()
		timeleft = timeleft - 1
	end )
	
	GUI_AdventCalendarFrame = vgui.Create( "DFrame" )
	GUI_AdventCalendarFrame:SetTitle( "" )
	GUI_AdventCalendarFrame:SetSize( CH_Advent.ScrW * 0.805, CH_Advent.ScrH * 0.7 )
	GUI_AdventCalendarFrame:Center()
	GUI_AdventCalendarFrame.Paint = function( self, w, h )
		local tomorrow = string.FormattedTime( timeleft )

		-- BG
		surface.SetDrawColor( color_white )
		surface.SetMaterial( CH_Advent.Materials.Background )
		surface.DrawTexturedRect( 0, 0, w, h * 0.95 )
		
		-- Bottom
		draw.RoundedBoxEx( 8, 0, h * 0.95, w, h * 0.05, CH_Advent.Colors.DarkGray, false, false, true, true )
		
		draw.SimpleText( CH_Advent.Config.BottomMenuText, "CH_Advent_Font_Outfit_Size6", w * 0.01, h * 0.975, CH_Advent.Colors.WhiteAlpha, TEXT_ALIGN_LEFT, TEXT_ALIGN_CENTER )
		
		-- Draw the top title.
		draw.SimpleText( CH_Advent.LangString( "Advent Calendar" ), "CH_Advent_Font_Outfit_Size25", w * 0.05, h * 0.13, CH_Advent.Colors.DarkRed, TEXT_ALIGN_LEFT, TEXT_ALIGN_CENTER )
		
		-- Hours
		draw.RoundedBox( 8, w * 0.795, h * 0.09, w * 0.045, h * 0.08, CH_Advent.Colors.LightGray )
		
		draw.SimpleText( tomorrow.h, "CH_Advent_Font_Outfit_Size10", w * 0.8175, h * 0.12, color_white, TEXT_ALIGN_CENTER, TEXT_ALIGN_CENTER )
		draw.SimpleText( CH_Advent.LangString( "Hours" ), "CH_Advent_Font_Outfit_Size6", w * 0.8175, h * 0.145, CH_Advent.Colors.WhiteAlpha, TEXT_ALIGN_CENTER, TEXT_ALIGN_CENTER )
		
		-- Min
		draw.RoundedBox( 8, w * 0.85, h * 0.09, w * 0.045, w * 0.04, CH_Advent.Colors.LightGray )
		
		draw.SimpleText( tomorrow.m, "CH_Advent_Font_Outfit_Size10", w * 0.8725, h * 0.12, color_white, TEXT_ALIGN_CENTER, TEXT_ALIGN_CENTER )
		draw.SimpleText( CH_Advent.LangString( "Minutes" ), "CH_Advent_Font_Outfit_Size6", w * 0.8725, h * 0.145, CH_Advent.Colors.WhiteAlpha, TEXT_ALIGN_CENTER, TEXT_ALIGN_CENTER )

		-- Sec
		draw.RoundedBox( 8, w * 0.905, h * 0.09, w * 0.045, w * 0.04, CH_Advent.Colors.LightGray )
		
		draw.SimpleText( tomorrow.s, "CH_Advent_Font_Outfit_Size10", w * 0.9275, h * 0.12, color_white, TEXT_ALIGN_CENTER, TEXT_ALIGN_CENTER )
		draw.SimpleText( CH_Advent.LangString( "Seconds" ), "CH_Advent_Font_Outfit_Size6", w * 0.9275, h * 0.145, CH_Advent.Colors.WhiteAlpha, TEXT_ALIGN_CENTER, TEXT_ALIGN_CENTER )

		-- Text
		draw.SimpleText( CH_Advent.LangString( "Next" ), "CH_Advent_Font_Outfit_Size10", w * 0.73, h * 0.11, color_white, TEXT_ALIGN_LEFT, TEXT_ALIGN_CENTER )
		draw.SimpleText( CH_Advent.LangString( "Square" ), "CH_Advent_Font_Outfit_Size10", w * 0.73, h * 0.145, color_white, TEXT_ALIGN_LEFT, TEXT_ALIGN_CENTER )
	end
	GUI_AdventCalendarFrame:MakePopup()
	GUI_AdventCalendarFrame:SetDraggable( false )
	GUI_AdventCalendarFrame:ShowCloseButton( false )
	GUI_AdventCalendarFrame.OnClose = function( self )
		if timer.Exists( "CH_Advent_Timer_CalculateTimeleft" ) then
			timer.Destroy( "CH_Advent_Timer_CalculateTimeleft" )
		end
	end
	
	local GUI_CloseMenu = vgui.Create( "DButton", GUI_AdventCalendarFrame )
	GUI_CloseMenu:SetPos( CH_Advent.ScrW * 0.784, CH_Advent.ScrH * 0.015 )
	GUI_CloseMenu:SetSize( CH_Advent.ScrW * 0.0125, CH_Advent.ScrH * 0.02223 )
	GUI_CloseMenu:SetText( "" )
	GUI_CloseMenu.Paint = function( self, w, h )
		surface.SetDrawColor( self:IsHovered() and CH_Advent.Colors.DarkRed or color_white )
		surface.SetMaterial( CH_Advent.Materials.CloseIcon )
		surface.DrawTexturedRect( 0, 0, CH_Advent.ScrW * 0.0125, CH_Advent.ScrH * 0.02223 )
	end
	GUI_CloseMenu.DoClick = function()
		GUI_AdventCalendarFrame:Close()
	end
	
	-- Header
	local GUI_CalendarButton = vgui.Create( "DButton", GUI_AdventCalendarFrame )
	GUI_CalendarButton:SetPos( CH_Advent.ScrW * 0.2, CH_Advent.ScrH * 0.02 )
	GUI_CalendarButton:SetSize( CH_Advent.ScrW * 0.1, CH_Advent.ScrW * 0.02 )
	GUI_CalendarButton:SetText( "" )
	GUI_CalendarButton.Paint = function( self, w, h )
		draw.SimpleText( string.upper( CH_Advent.LangString( "Calendar" ) ), "CH_Advent_Font_Outfit_Size7", w / 2, h * 0.1, color_white, TEXT_ALIGN_CENTER, TEXT_ALIGN_TOP )
		
		draw.SimpleText( "•", "CH_Advent_Font_Outfit_Size6", w / 2, h * 0.5, CH_Advent.Colors.DarkRed, TEXT_ALIGN_CENTER, TEXT_ALIGN_TOP )
	end
	GUI_CalendarButton.OnCursorEntered = function()
		surface.PlaySound( "craphead_scripts/ch_advent_calendar/hover.wav" )
	end
	GUI_CalendarButton.DoClick = function( self )
		
	end
	
	local GUI_HistoryButton = vgui.Create( "DButton", GUI_AdventCalendarFrame )
	GUI_HistoryButton:SetPos( CH_Advent.ScrW * 0.3, CH_Advent.ScrH * 0.02 )
	GUI_HistoryButton:SetSize( CH_Advent.ScrW * 0.1, CH_Advent.ScrW * 0.02 )
	GUI_HistoryButton:SetText( "" )
	GUI_HistoryButton.Paint = function( self, w, h )
		draw.SimpleText( string.upper( CH_Advent.LangString( "History" ) ), "CH_Advent_Font_Outfit_Size7", w / 2, h * 0.1, self:IsHovered() and color_white or CH_Advent.Colors.WhiteAlpha, TEXT_ALIGN_CENTER, TEXT_ALIGN_TOP )
	end
	GUI_HistoryButton.OnCursorEntered = function()
		surface.PlaySound( "craphead_scripts/ch_advent_calendar/hover.wav" )
	end
	GUI_HistoryButton.DoClick = function( self )
		net.Start( "CH_Advent_Net_RetrieveHistory" )
			net.WriteUInt( timeleft, 32 )
			net.WriteUInt( day, 5 )
		net.SendToServer()
	end
	
	local GUI_LeaderboardButton = vgui.Create( "DButton", GUI_AdventCalendarFrame )
	GUI_LeaderboardButton:SetPos( CH_Advent.ScrW * 0.4, CH_Advent.ScrH * 0.02 )
	GUI_LeaderboardButton:SetSize( CH_Advent.ScrW * 0.1, CH_Advent.ScrW * 0.02 )
	GUI_LeaderboardButton:SetText( "" )
	GUI_LeaderboardButton.Paint = function( self, w, h )
		draw.SimpleText( string.upper( CH_Advent.LangString( "Leaderboard" ) ), "CH_Advent_Font_Outfit_Size7", w / 2, h * 0.1, self:IsHovered() and color_white or CH_Advent.Colors.WhiteAlpha, TEXT_ALIGN_CENTER, TEXT_ALIGN_TOP )
	end
	GUI_LeaderboardButton.OnCursorEntered = function()
		surface.PlaySound( "craphead_scripts/ch_advent_calendar/hover.wav" )
	end
	GUI_LeaderboardButton.DoClick = function( self )
		net.Start( "CH_Advent_Net_RetrieveLeaderboard" )
			net.WriteUInt( timeleft, 32 )
			net.WriteUInt( day, 5 )
		net.SendToServer()
	end
	
	local GUI_InfoButton = vgui.Create( "DButton", GUI_AdventCalendarFrame )
	GUI_InfoButton:SetPos( CH_Advent.ScrW * 0.5, CH_Advent.ScrH * 0.02 )
	GUI_InfoButton:SetSize( CH_Advent.ScrW * 0.1, CH_Advent.ScrW * 0.02 )
	GUI_InfoButton:SetText( "" )
	GUI_InfoButton.Paint = function( self, w, h )
		draw.SimpleText( string.upper( CH_Advent.LangString( "Information" ) ), "CH_Advent_Font_Outfit_Size7", w / 2, h * 0.1, self:IsHovered() and color_white or CH_Advent.Colors.WhiteAlpha, TEXT_ALIGN_CENTER, TEXT_ALIGN_TOP )
	end
	GUI_InfoButton.OnCursorEntered = function()
		surface.PlaySound( "craphead_scripts/ch_advent_calendar/hover.wav" )
	end
	GUI_InfoButton.DoClick = function( self )
		CH_Advent.InformationMenu( timeleft, day )
	end
	
	
	-- SQUARES
	
	-- 1
	local GUI_SquareButton = vgui.Create( "DButton", GUI_AdventCalendarFrame )
	GUI_SquareButton:SetPos( CH_Advent.ScrW * 0.04, CH_Advent.ScrH * 0.13 )
	GUI_SquareButton:SetSize( CH_Advent.ScrW * 0.07, CH_Advent.ScrW * 0.07 )
	GUI_SquareButton:SetText( "" )
	GUI_SquareButton.Square = 1
	if CH_Advent.Config.ShowRewardTooltip and ply.CH_Advent_Squares[ GUI_SquareButton.Square ] and CH_Advent.Rewards[ tonumber( ply.CH_Advent_Squares[ GUI_SquareButton.Square ] ) ] then
		GUI_SquareButton:SetToolTip( CH_Advent.LangString( "You've won" ) .." ".. CH_Advent.Rewards[ tonumber( ply.CH_Advent_Squares[ GUI_SquareButton.Square ] ) ].Name )
	end
	GUI_SquareButton.Paint = function( self, w, h )
		-- Opened or not drawing
		if ply.CH_Advent_Squares[ self.Square ] then
			surface.SetDrawColor( color_white )
			surface.SetMaterial( ply.CH_Advent_Squares[ self.Square ] == "1" and CH_Advent.Materials.CoalIcons[ "Square" ] or CH_Advent.Materials.RewardIcons[ "Square" ] )
			surface.DrawTexturedRect( 0, 0, w, h )
			
			draw.SimpleText( self.Square, "CH_Advent_Font_Caveat_Size18", w * 0.02, h * 0.175, CH_Advent.Colors.Green, TEXT_ALIGN_LEFT, TEXT_ALIGN_CENTER )
		else
			draw.RoundedBox( 8, 0, 0, w, h, CH_Advent.Config.SquareColors[ self.Square ] )
			
			surface.SetDrawColor( color_white )
			surface.SetMaterial( CH_Advent.Materials.SquareIcons[ self.Square ] )
			surface.DrawTexturedRect( 0, 0, w, h )
			
			draw.SimpleText( self.Square, "CH_Advent_Font_Caveat_Size18", w * 0.5, h * 0.5, day > self.Square and CH_Advent.Colors.Red or ( day == self.Square ) and CH_Advent.Colors.Gold or color_white, TEXT_ALIGN_CENTER, TEXT_ALIGN_CENTER )
		end
	end
	GUI_SquareButton.OnCursorEntered = function()
		surface.PlaySound( "craphead_scripts/ch_advent_calendar/hover.wav" )
	end
	GUI_SquareButton.DoClick = function( self )
		if ( not CH_Advent.Config.CanOpenMissedSquares and day != self.Square ) or ( CH_Advent.Config.CanOpenMissedSquares and self.Square > day ) then
			surface.PlaySound( "common/wpn_denyselect.wav" )
			return
		end
		
		-- Call net
		net.Start( "CH_Advent_Net_OpenSquare" )
			net.WriteUInt( self.Square, 5 )
		net.SendToServer()
		
		-- Close it
		GUI_AdventCalendarFrame:Close()
	end
	
	-- 2
	local GUI_SquareButton = vgui.Create( "DButton", GUI_AdventCalendarFrame )
	GUI_SquareButton:SetPos( CH_Advent.ScrW * 0.115, CH_Advent.ScrH * 0.13 )
	GUI_SquareButton:SetSize( CH_Advent.ScrW * 0.1725, CH_Advent.ScrW * 0.07 )
	GUI_SquareButton:SetText( "" )
	GUI_SquareButton.Square = 2
	if CH_Advent.Config.ShowRewardTooltip and ply.CH_Advent_Squares[ GUI_SquareButton.Square ] and CH_Advent.Rewards[ tonumber( ply.CH_Advent_Squares[ GUI_SquareButton.Square ] ) ] then
		GUI_SquareButton:SetToolTip( CH_Advent.LangString( "You've won" ) .." ".. CH_Advent.Rewards[ tonumber( ply.CH_Advent_Squares[ GUI_SquareButton.Square ] ) ].Name )
	end
	GUI_SquareButton.Paint = function( self, w, h )
		-- Opened or not drawing
		if ply.CH_Advent_Squares[ self.Square ] then
			surface.SetDrawColor( color_white )
			surface.SetMaterial( ply.CH_Advent_Squares[ self.Square ] == "1" and CH_Advent.Materials.CoalIcons[ "Wide" ] or CH_Advent.Materials.RewardIcons[ "Wide" ] )
			surface.DrawTexturedRect( 0, 0, w, h )
			
			draw.SimpleText( self.Square, "CH_Advent_Font_Caveat_Size18", w * 0.02, h * 0.175, CH_Advent.Colors.Green, TEXT_ALIGN_LEFT, TEXT_ALIGN_CENTER )
		else
			draw.RoundedBox( 8, 0, 0, w, h, CH_Advent.Config.SquareColors[ self.Square ] )
			
			surface.SetDrawColor( color_white )
			surface.SetMaterial( CH_Advent.Materials.SquareIcons[ self.Square ] )
			surface.DrawTexturedRect( 0, 0, w, h )
			
			draw.SimpleText( self.Square, "CH_Advent_Font_Caveat_Size35", w * 0.5, h * 0.5, day > self.Square and CH_Advent.Colors.Red or ( day == self.Square ) and CH_Advent.Colors.Gold or color_white, TEXT_ALIGN_CENTER, TEXT_ALIGN_CENTER )
		end
	end
	GUI_SquareButton.OnCursorEntered = function()
		surface.PlaySound( "craphead_scripts/ch_advent_calendar/hover.wav" )
	end
	GUI_SquareButton.DoClick = function( self )
		if ( not CH_Advent.Config.CanOpenMissedSquares and day != self.Square ) or ( CH_Advent.Config.CanOpenMissedSquares and self.Square > day ) then
			surface.PlaySound( "common/wpn_denyselect.wav" )
			return
		end
		
		-- Call net
		net.Start( "CH_Advent_Net_OpenSquare" )
			net.WriteUInt( self.Square, 5 )
		net.SendToServer()
		
		-- Close it
		GUI_AdventCalendarFrame:Close()
	end
	
	-- 3
	local GUI_SquareButton = vgui.Create( "DButton", GUI_AdventCalendarFrame )
	GUI_SquareButton:SetPos( CH_Advent.ScrW * 0.2925, CH_Advent.ScrH * 0.13 )
	GUI_SquareButton:SetSize( CH_Advent.ScrW * 0.07, CH_Advent.ScrW * 0.07 )
	GUI_SquareButton:SetText( "" )
	GUI_SquareButton.Square = 3
	if CH_Advent.Config.ShowRewardTooltip and ply.CH_Advent_Squares[ GUI_SquareButton.Square ] and CH_Advent.Rewards[ tonumber( ply.CH_Advent_Squares[ GUI_SquareButton.Square ] ) ] then
		GUI_SquareButton:SetToolTip( CH_Advent.LangString( "You've won" ) .." ".. CH_Advent.Rewards[ tonumber( ply.CH_Advent_Squares[ GUI_SquareButton.Square ] ) ].Name )
	end
	GUI_SquareButton.Paint = function( self, w, h )
		-- Opened or not drawing
		if ply.CH_Advent_Squares[ self.Square ] then
			surface.SetDrawColor( color_white )
			surface.SetMaterial( ply.CH_Advent_Squares[ self.Square ] == "1" and CH_Advent.Materials.CoalIcons[ "Square" ] or CH_Advent.Materials.RewardIcons[ "Square" ] )
			surface.DrawTexturedRect( 0, 0, w, h )
			
			draw.SimpleText( self.Square, "CH_Advent_Font_Caveat_Size18", w * 0.02, h * 0.175, CH_Advent.Colors.Green, TEXT_ALIGN_LEFT, TEXT_ALIGN_CENTER )
		else
			draw.RoundedBox( 8, 0, 0, w, h, CH_Advent.Config.SquareColors[ self.Square ] )
			
			surface.SetDrawColor( color_white )
			surface.SetMaterial( CH_Advent.Materials.SquareIcons[ self.Square ] )
			surface.DrawTexturedRect( 0, 0, w, h )
			
			draw.SimpleText( self.Square, "CH_Advent_Font_Caveat_Size18", w * 0.02, h * 0.175, day > self.Square and CH_Advent.Colors.Red or ( day == self.Square ) and CH_Advent.Colors.Gold or color_white, TEXT_ALIGN_LEFT, TEXT_ALIGN_CENTER )
		end
	end
	GUI_SquareButton.OnCursorEntered = function()
		surface.PlaySound( "craphead_scripts/ch_advent_calendar/hover.wav" )
	end
	GUI_SquareButton.DoClick = function( self )
		if ( not CH_Advent.Config.CanOpenMissedSquares and day != self.Square ) or ( CH_Advent.Config.CanOpenMissedSquares and self.Square > day ) then
			surface.PlaySound( "common/wpn_denyselect.wav" )
			return
		end
		
		-- Call net
		net.Start( "CH_Advent_Net_OpenSquare" )
			net.WriteUInt( self.Square, 5 )
		net.SendToServer()
		
		-- Close it
		GUI_AdventCalendarFrame:Close()
	end
	
	-- 4
	local GUI_SquareButton = vgui.Create( "DButton", GUI_AdventCalendarFrame )
	GUI_SquareButton:SetPos( CH_Advent.ScrW * 0.3675, CH_Advent.ScrH * 0.13 )
	GUI_SquareButton:SetSize( CH_Advent.ScrW * 0.07, CH_Advent.ScrW * 0.145 )
	GUI_SquareButton:SetText( "" )
	GUI_SquareButton.Square = 4
	if CH_Advent.Config.ShowRewardTooltip and ply.CH_Advent_Squares[ GUI_SquareButton.Square ] and CH_Advent.Rewards[ tonumber( ply.CH_Advent_Squares[ GUI_SquareButton.Square ] ) ] then
		GUI_SquareButton:SetToolTip( CH_Advent.LangString( "You've won" ) .." ".. CH_Advent.Rewards[ tonumber( ply.CH_Advent_Squares[ GUI_SquareButton.Square ] ) ].Name )
	end
	GUI_SquareButton.Paint = function( self, w, h )
		-- Opened or not drawing
		if ply.CH_Advent_Squares[ self.Square ] then
			surface.SetDrawColor( color_white )
			surface.SetMaterial( ply.CH_Advent_Squares[ self.Square ] == "1" and CH_Advent.Materials.CoalIcons[ "Tall" ] or CH_Advent.Materials.RewardIcons[ "Tall" ] )
			surface.DrawTexturedRect( 0, 0, w, h )
			
			draw.SimpleText( self.Square, "CH_Advent_Font_Caveat_Size18", w * 0.04, h * 0.08, CH_Advent.Colors.Green, TEXT_ALIGN_LEFT, TEXT_ALIGN_CENTER )
		else
			draw.RoundedBox( 8, 0, 0, w, h, CH_Advent.Config.SquareColors[ self.Square ] )
			
			surface.SetDrawColor( color_white )
			surface.SetMaterial( CH_Advent.Materials.SquareIcons[ self.Square ] )
			surface.DrawTexturedRect( 0, 0, w, h )
			
			draw.SimpleText( self.Square, "CH_Advent_Font_Caveat_Size45", w * 0.5, h * 0.5, day > self.Square and CH_Advent.Colors.Red or ( day == self.Square ) and CH_Advent.Colors.Gold or color_white, TEXT_ALIGN_CENTER, TEXT_ALIGN_CENTER )
		end
	end
	GUI_SquareButton.OnCursorEntered = function()
		surface.PlaySound( "craphead_scripts/ch_advent_calendar/hover.wav" )
	end
	GUI_SquareButton.DoClick = function( self )
		if ( not CH_Advent.Config.CanOpenMissedSquares and day != self.Square ) or ( CH_Advent.Config.CanOpenMissedSquares and self.Square > day ) then
			surface.PlaySound( "common/wpn_denyselect.wav" )
			return
		end
		
		-- Call net
		net.Start( "CH_Advent_Net_OpenSquare" )
			net.WriteUInt( self.Square, 5 )
		net.SendToServer()
		
		-- Close it
		GUI_AdventCalendarFrame:Close()
	end
	
	-- 5
	local GUI_SquareButton = vgui.Create( "DButton", GUI_AdventCalendarFrame )
	GUI_SquareButton:SetPos( CH_Advent.ScrW * 0.4425, CH_Advent.ScrH * 0.13 )
	GUI_SquareButton:SetSize( CH_Advent.ScrW * 0.07, CH_Advent.ScrW * 0.07 )
	GUI_SquareButton:SetText( "" )
	GUI_SquareButton.Square = 5
	if CH_Advent.Config.ShowRewardTooltip and ply.CH_Advent_Squares[ GUI_SquareButton.Square ] and CH_Advent.Rewards[ tonumber( ply.CH_Advent_Squares[ GUI_SquareButton.Square ] ) ] then
		GUI_SquareButton:SetToolTip( CH_Advent.LangString( "You've won" ) .." ".. CH_Advent.Rewards[ tonumber( ply.CH_Advent_Squares[ GUI_SquareButton.Square ] ) ].Name )
	end
	GUI_SquareButton.Paint = function( self, w, h )
		-- Opened or not drawing
		if ply.CH_Advent_Squares[ self.Square ] then
			surface.SetDrawColor( color_white )
			surface.SetMaterial( ply.CH_Advent_Squares[ self.Square ] == "1" and CH_Advent.Materials.CoalIcons[ "Square" ] or CH_Advent.Materials.RewardIcons[ "Square" ] )
			surface.DrawTexturedRect( 0, 0, w, h )
			
			draw.SimpleText( self.Square, "CH_Advent_Font_Caveat_Size18", w * 0.02, h * 0.175, CH_Advent.Colors.Green, TEXT_ALIGN_LEFT, TEXT_ALIGN_CENTER )
		else
			draw.RoundedBox( 8, 0, 0, w, h, CH_Advent.Config.SquareColors[ self.Square ] )
			
			surface.SetDrawColor( color_white )
			surface.SetMaterial( CH_Advent.Materials.SquareIcons[ self.Square ] )
			surface.DrawTexturedRect( 0, 0, w, h )
			
			draw.SimpleText( self.Square, "CH_Advent_Font_Caveat_Size45", w * 0.5, h * 0.5, day > self.Square and CH_Advent.Colors.Red or ( day == self.Square ) and CH_Advent.Colors.Gold or color_white, TEXT_ALIGN_CENTER, TEXT_ALIGN_CENTER )
		end
	end
	GUI_SquareButton.OnCursorEntered = function()
		surface.PlaySound( "craphead_scripts/ch_advent_calendar/hover.wav" )
	end
	GUI_SquareButton.DoClick = function( self )
		if ( not CH_Advent.Config.CanOpenMissedSquares and day != self.Square ) or ( CH_Advent.Config.CanOpenMissedSquares and self.Square > day ) then
			surface.PlaySound( "common/wpn_denyselect.wav" )
			return
		end
		
		-- Call net
		net.Start( "CH_Advent_Net_OpenSquare" )
			net.WriteUInt( self.Square, 5 )
		net.SendToServer()
		
		-- Close it
		GUI_AdventCalendarFrame:Close()
	end
	
	-- 6
	local GUI_SquareButton = vgui.Create( "DButton", GUI_AdventCalendarFrame )
	GUI_SquareButton:SetPos( CH_Advent.ScrW * 0.5175, CH_Advent.ScrH * 0.13 )
	GUI_SquareButton:SetSize( CH_Advent.ScrW * 0.1725, CH_Advent.ScrW * 0.07 )
	GUI_SquareButton:SetText( "" )
	GUI_SquareButton.Square = 6
	if CH_Advent.Config.ShowRewardTooltip and ply.CH_Advent_Squares[ GUI_SquareButton.Square ] and CH_Advent.Rewards[ tonumber( ply.CH_Advent_Squares[ GUI_SquareButton.Square ] ) ] then
		GUI_SquareButton:SetToolTip( CH_Advent.LangString( "You've won" ) .." ".. CH_Advent.Rewards[ tonumber( ply.CH_Advent_Squares[ GUI_SquareButton.Square ] ) ].Name )
	end
	GUI_SquareButton.Paint = function( self, w, h )
		-- Opened or not drawing
		if ply.CH_Advent_Squares[ self.Square ] then
			surface.SetDrawColor( color_white )
			surface.SetMaterial( ply.CH_Advent_Squares[ self.Square ] == "1" and CH_Advent.Materials.CoalIcons[ "Wide" ] or CH_Advent.Materials.RewardIcons[ "Wide" ] )
			surface.DrawTexturedRect( 0, 0, w, h )
			
			draw.SimpleText( self.Square, "CH_Advent_Font_Caveat_Size18", w * 0.02, h * 0.175, CH_Advent.Colors.Green, TEXT_ALIGN_LEFT, TEXT_ALIGN_CENTER )
		else
			draw.RoundedBox( 8, 0, 0, w, h, CH_Advent.Config.SquareColors[ self.Square ] )
			
			surface.SetDrawColor( color_white )
			surface.SetMaterial( CH_Advent.Materials.SquareIcons[ self.Square ] )
			surface.DrawTexturedRect( 0, 0, w, h )
			
			draw.SimpleText( self.Square, "CH_Advent_Font_Caveat_Size45", w * 0.5, h * 0.5, day > self.Square and CH_Advent.Colors.Red or ( day == self.Square ) and CH_Advent.Colors.Gold or color_white, TEXT_ALIGN_CENTER, TEXT_ALIGN_CENTER )
		end
	end
	GUI_SquareButton.OnCursorEntered = function()
		surface.PlaySound( "craphead_scripts/ch_advent_calendar/hover.wav" )
	end
	GUI_SquareButton.DoClick = function( self )
		if ( not CH_Advent.Config.CanOpenMissedSquares and day != self.Square ) or ( CH_Advent.Config.CanOpenMissedSquares and self.Square > day ) then
			surface.PlaySound( "common/wpn_denyselect.wav" )
			return
		end
		
		-- Call net
		net.Start( "CH_Advent_Net_OpenSquare" )
			net.WriteUInt( self.Square, 5 )
		net.SendToServer()
		
		-- Close it
		GUI_AdventCalendarFrame:Close()
	end
	
	-- 7
	local GUI_SquareButton = vgui.Create( "DButton", GUI_AdventCalendarFrame )
	GUI_SquareButton:SetPos( CH_Advent.ScrW * 0.695, CH_Advent.ScrH * 0.13 )
	GUI_SquareButton:SetSize( CH_Advent.ScrW * 0.07, CH_Advent.ScrW * 0.07 )
	GUI_SquareButton:SetText( "" )
	GUI_SquareButton.Square = 7
	if CH_Advent.Config.ShowRewardTooltip and ply.CH_Advent_Squares[ GUI_SquareButton.Square ] and CH_Advent.Rewards[ tonumber( ply.CH_Advent_Squares[ GUI_SquareButton.Square ] ) ] then
		GUI_SquareButton:SetToolTip( CH_Advent.LangString( "You've won" ) .." ".. CH_Advent.Rewards[ tonumber( ply.CH_Advent_Squares[ GUI_SquareButton.Square ] ) ].Name )
	end
	GUI_SquareButton.Paint = function( self, w, h )
		-- Opened or not drawing
		if ply.CH_Advent_Squares[ self.Square ] then
			surface.SetDrawColor( color_white )
			surface.SetMaterial( ply.CH_Advent_Squares[ self.Square ] == "1" and CH_Advent.Materials.CoalIcons[ "Square" ] or CH_Advent.Materials.RewardIcons[ "Square" ] )
			surface.DrawTexturedRect( 0, 0, w, h )
			
			draw.SimpleText( self.Square, "CH_Advent_Font_Caveat_Size18", w * 0.02, h * 0.175, CH_Advent.Colors.Green, TEXT_ALIGN_LEFT, TEXT_ALIGN_CENTER )
		else
			draw.RoundedBox( 8, 0, 0, w, h, CH_Advent.Config.SquareColors[ self.Square ] )
			
			surface.SetDrawColor( color_white )
			surface.SetMaterial( CH_Advent.Materials.SquareIcons[ self.Square ] )
			surface.DrawTexturedRect( 0, 0, w, h )
			
			draw.SimpleText( self.Square, "CH_Advent_Font_Caveat_Size18", w * 0.02, h * 0.175, day > self.Square and CH_Advent.Colors.Red or ( day == self.Square ) and CH_Advent.Colors.Gold or color_white, TEXT_ALIGN_LEFT, TEXT_ALIGN_CENTER )
		end
	end
	GUI_SquareButton.OnCursorEntered = function()
		surface.PlaySound( "craphead_scripts/ch_advent_calendar/hover.wav" )
	end
	GUI_SquareButton.DoClick = function( self )
		if ( not CH_Advent.Config.CanOpenMissedSquares and day != self.Square ) or ( CH_Advent.Config.CanOpenMissedSquares and self.Square > day ) then
			surface.PlaySound( "common/wpn_denyselect.wav" )
			return
		end
		
		-- Call net
		net.Start( "CH_Advent_Net_OpenSquare" )
			net.WriteUInt( self.Square, 5 )
		net.SendToServer()
		
		-- Close it
		GUI_AdventCalendarFrame:Close()
	end
	
	-- 8
	local GUI_SquareButton = vgui.Create( "DButton", GUI_AdventCalendarFrame )
	GUI_SquareButton:SetPos( CH_Advent.ScrW * 0.04, CH_Advent.ScrH * 0.2625 )
	GUI_SquareButton:SetSize( CH_Advent.ScrW * 0.07, CH_Advent.ScrW * 0.145 )
	GUI_SquareButton:SetText( "" )
	GUI_SquareButton.Square = 8
	if CH_Advent.Config.ShowRewardTooltip and ply.CH_Advent_Squares[ GUI_SquareButton.Square ] and CH_Advent.Rewards[ tonumber( ply.CH_Advent_Squares[ GUI_SquareButton.Square ] ) ] then
		GUI_SquareButton:SetToolTip( CH_Advent.LangString( "You've won" ) .." ".. CH_Advent.Rewards[ tonumber( ply.CH_Advent_Squares[ GUI_SquareButton.Square ] ) ].Name )
	end
	GUI_SquareButton.Paint = function( self, w, h )
		-- Opened or not drawing
		if ply.CH_Advent_Squares[ self.Square ] then
			surface.SetDrawColor( color_white )
			surface.SetMaterial( ply.CH_Advent_Squares[ self.Square ] == "1" and CH_Advent.Materials.CoalIcons[ "Tall" ] or CH_Advent.Materials.RewardIcons[ "Tall" ] )
			surface.DrawTexturedRect( 0, 0, w, h )
			
			draw.SimpleText( self.Square, "CH_Advent_Font_Caveat_Size18", w * 0.04, h * 0.08, CH_Advent.Colors.Green, TEXT_ALIGN_LEFT, TEXT_ALIGN_CENTER )
		else
			draw.RoundedBox( 8, 0, 0, w, h, CH_Advent.Config.SquareColors[ self.Square ] )
			
			surface.SetDrawColor( color_white )
			surface.SetMaterial( CH_Advent.Materials.SquareIcons[ self.Square ] )
			surface.DrawTexturedRect( 0, 0, w, h )
			
			draw.SimpleText( self.Square, "CH_Advent_Font_Caveat_Size35", w * 0.5, h * 0.5, day > self.Square and CH_Advent.Colors.Red or ( day == self.Square ) and CH_Advent.Colors.Gold or color_white, TEXT_ALIGN_CENTER, TEXT_ALIGN_CENTER )
		end
	end
	GUI_SquareButton.OnCursorEntered = function()
		surface.PlaySound( "craphead_scripts/ch_advent_calendar/hover.wav" )
	end
	GUI_SquareButton.DoClick = function( self )
		if ( not CH_Advent.Config.CanOpenMissedSquares and day != self.Square ) or ( CH_Advent.Config.CanOpenMissedSquares and self.Square > day ) then
			surface.PlaySound( "common/wpn_denyselect.wav" )
			return
		end
		
		-- Call net
		net.Start( "CH_Advent_Net_OpenSquare" )
			net.WriteUInt( self.Square, 5 )
		net.SendToServer()
		
		-- Close it
		GUI_AdventCalendarFrame:Close()
	end
	
	-- 9
	local GUI_SquareButton = vgui.Create( "DButton", GUI_AdventCalendarFrame )
	GUI_SquareButton:SetPos( CH_Advent.ScrW * 0.115, CH_Advent.ScrH * 0.2625 )
	GUI_SquareButton:SetSize( CH_Advent.ScrW * 0.07, CH_Advent.ScrW * 0.07 )
	GUI_SquareButton:SetText( "" )
	GUI_SquareButton.Square = 9
	if CH_Advent.Config.ShowRewardTooltip and ply.CH_Advent_Squares[ GUI_SquareButton.Square ] and CH_Advent.Rewards[ tonumber( ply.CH_Advent_Squares[ GUI_SquareButton.Square ] ) ] then
		GUI_SquareButton:SetToolTip( CH_Advent.LangString( "You've won" ) .." ".. CH_Advent.Rewards[ tonumber( ply.CH_Advent_Squares[ GUI_SquareButton.Square ] ) ].Name )
	end
	GUI_SquareButton.Paint = function( self, w, h )
		-- Opened or not drawing
		if ply.CH_Advent_Squares[ self.Square ] then
			surface.SetDrawColor( color_white )
			surface.SetMaterial( ply.CH_Advent_Squares[ self.Square ] == "1" and CH_Advent.Materials.CoalIcons[ "Square" ] or CH_Advent.Materials.RewardIcons[ "Square" ] )
			surface.DrawTexturedRect( 0, 0, w, h )
			
			draw.SimpleText( self.Square, "CH_Advent_Font_Caveat_Size18", w * 0.92, h * 0.175, CH_Advent.Colors.Green, TEXT_ALIGN_RIGHT, TEXT_ALIGN_CENTER )
		else
			draw.RoundedBox( 8, 0, 0, w, h, CH_Advent.Config.SquareColors[ self.Square ] )
			
			surface.SetDrawColor( color_white )
			surface.SetMaterial( CH_Advent.Materials.SquareIcons[ self.Square ] )
			surface.DrawTexturedRect( 0, 0, w, h )
			
			draw.SimpleText( self.Square, "CH_Advent_Font_Caveat_Size18", w * 0.92, h * 0.175, day > self.Square and CH_Advent.Colors.Red or ( day == self.Square ) and CH_Advent.Colors.Gold or color_white, TEXT_ALIGN_RIGHT, TEXT_ALIGN_CENTER )
		end
	end
	GUI_SquareButton.OnCursorEntered = function()
		surface.PlaySound( "craphead_scripts/ch_advent_calendar/hover.wav" )
	end
	GUI_SquareButton.DoClick = function( self )
		if ( not CH_Advent.Config.CanOpenMissedSquares and day != self.Square ) or ( CH_Advent.Config.CanOpenMissedSquares and self.Square > day ) then
			surface.PlaySound( "common/wpn_denyselect.wav" )
			return
		end
		
		-- Call net
		net.Start( "CH_Advent_Net_OpenSquare" )
			net.WriteUInt( self.Square, 5 )
		net.SendToServer()
		
		-- Close it
		GUI_AdventCalendarFrame:Close()
	end
	
	-- 10
	local GUI_SquareButton = vgui.Create( "DButton", GUI_AdventCalendarFrame )
	GUI_SquareButton:SetPos( CH_Advent.ScrW * 0.19, CH_Advent.ScrH * 0.2625 )
	GUI_SquareButton:SetSize( CH_Advent.ScrW * 0.1725, CH_Advent.ScrW * 0.07 )
	GUI_SquareButton:SetText( "" )
	GUI_SquareButton.Square = 10
	if CH_Advent.Config.ShowRewardTooltip and ply.CH_Advent_Squares[ GUI_SquareButton.Square ] and CH_Advent.Rewards[ tonumber( ply.CH_Advent_Squares[ GUI_SquareButton.Square ] ) ] then
		GUI_SquareButton:SetToolTip( CH_Advent.LangString( "You've won" ) .." ".. CH_Advent.Rewards[ tonumber( ply.CH_Advent_Squares[ GUI_SquareButton.Square ] ) ].Name )
	end
	GUI_SquareButton.Paint = function( self, w, h )
		-- Opened or not drawing
		if ply.CH_Advent_Squares[ self.Square ] then
			surface.SetDrawColor( color_white )
			surface.SetMaterial( ply.CH_Advent_Squares[ self.Square ] == "1" and CH_Advent.Materials.CoalIcons[ "Wide" ] or CH_Advent.Materials.RewardIcons[ "Wide" ] )
			surface.DrawTexturedRect( 0, 0, w, h )
			
			draw.SimpleText( self.Square, "CH_Advent_Font_Caveat_Size18", w * 0.02, h * 0.175, CH_Advent.Colors.Green, TEXT_ALIGN_LEFT, TEXT_ALIGN_CENTER )
		else
			draw.RoundedBox( 8, 0, 0, w, h, CH_Advent.Config.SquareColors[ self.Square ] )
			
			surface.SetDrawColor( color_white )
			surface.SetMaterial( CH_Advent.Materials.SquareIcons[ self.Square ] )
			surface.DrawTexturedRect( 0, 0, w, h )
			
			draw.SimpleText( self.Square, "CH_Advent_Font_Caveat_Size35", w * 0.5, h * 0.5, day > self.Square and CH_Advent.Colors.Red or ( day == self.Square ) and CH_Advent.Colors.Gold or color_white, TEXT_ALIGN_CENTER, TEXT_ALIGN_CENTER )
		end
	end
	GUI_SquareButton.OnCursorEntered = function()
		surface.PlaySound( "craphead_scripts/ch_advent_calendar/hover.wav" )
	end
	GUI_SquareButton.DoClick = function( self )
		if ( not CH_Advent.Config.CanOpenMissedSquares and day != self.Square ) or ( CH_Advent.Config.CanOpenMissedSquares and self.Square > day ) then
			surface.PlaySound( "common/wpn_denyselect.wav" )
			return
		end
		
		-- Call net
		net.Start( "CH_Advent_Net_OpenSquare" )
			net.WriteUInt( self.Square, 5 )
		net.SendToServer()
		
		-- Close it
		GUI_AdventCalendarFrame:Close()
	end
	
	-- 11
	local GUI_SquareButton = vgui.Create( "DButton", GUI_AdventCalendarFrame )
	GUI_SquareButton:SetPos( CH_Advent.ScrW * 0.4425, CH_Advent.ScrH * 0.2625 )
	GUI_SquareButton:SetSize( CH_Advent.ScrW * 0.1725, CH_Advent.ScrW * 0.07 )
	GUI_SquareButton:SetText( "" )
	GUI_SquareButton.Square = 11
	if CH_Advent.Config.ShowRewardTooltip and ply.CH_Advent_Squares[ GUI_SquareButton.Square ] and CH_Advent.Rewards[ tonumber( ply.CH_Advent_Squares[ GUI_SquareButton.Square ] ) ] then
		GUI_SquareButton:SetToolTip( CH_Advent.LangString( "You've won" ) .." ".. CH_Advent.Rewards[ tonumber( ply.CH_Advent_Squares[ GUI_SquareButton.Square ] ) ].Name )
	end
	GUI_SquareButton.Paint = function( self, w, h )
		-- Opened or not drawing
		if ply.CH_Advent_Squares[ self.Square ] then
			surface.SetDrawColor( color_white )
			surface.SetMaterial( ply.CH_Advent_Squares[ self.Square ] == "1" and CH_Advent.Materials.CoalIcons[ "Wide" ] or CH_Advent.Materials.RewardIcons[ "Wide" ] )
			surface.DrawTexturedRect( 0, 0, w, h )
			
			draw.SimpleText( self.Square, "CH_Advent_Font_Caveat_Size18", w * 0.02, h * 0.175, CH_Advent.Colors.Green, TEXT_ALIGN_LEFT, TEXT_ALIGN_CENTER )
		else
			draw.RoundedBox( 8, 0, 0, w, h, CH_Advent.Config.SquareColors[ self.Square ] )
			
			surface.SetDrawColor( color_white )
			surface.SetMaterial( CH_Advent.Materials.SquareIcons[ self.Square ] )
			surface.DrawTexturedRect( 0, 0, w, h )
			
			draw.SimpleText( self.Square, "CH_Advent_Font_Caveat_Size35", w * 0.5, h * 0.5, day > self.Square and CH_Advent.Colors.Red or ( day == self.Square ) and CH_Advent.Colors.Gold or color_white, TEXT_ALIGN_CENTER, TEXT_ALIGN_CENTER )
		end
	end
	GUI_SquareButton.OnCursorEntered = function()
		surface.PlaySound( "craphead_scripts/ch_advent_calendar/hover.wav" )
	end
	GUI_SquareButton.DoClick = function( self )
		if ( not CH_Advent.Config.CanOpenMissedSquares and day != self.Square ) or ( CH_Advent.Config.CanOpenMissedSquares and self.Square > day ) then
			surface.PlaySound( "common/wpn_denyselect.wav" )
			return
		end
		
		-- Call net
		net.Start( "CH_Advent_Net_OpenSquare" )
			net.WriteUInt( self.Square, 5 )
		net.SendToServer()
		
		-- Close it
		GUI_AdventCalendarFrame:Close()
	end
	
	-- 12
	local GUI_SquareButton = vgui.Create( "DButton", GUI_AdventCalendarFrame )
	GUI_SquareButton:SetPos( CH_Advent.ScrW * 0.62, CH_Advent.ScrH * 0.2625 )
	GUI_SquareButton:SetSize( CH_Advent.ScrW * 0.07, CH_Advent.ScrW * 0.07 )
	GUI_SquareButton:SetText( "" )
	GUI_SquareButton.Square = 12
	if CH_Advent.Config.ShowRewardTooltip and ply.CH_Advent_Squares[ GUI_SquareButton.Square ] and CH_Advent.Rewards[ tonumber( ply.CH_Advent_Squares[ GUI_SquareButton.Square ] ) ] then
		GUI_SquareButton:SetToolTip( CH_Advent.LangString( "You've won" ) .." ".. CH_Advent.Rewards[ tonumber( ply.CH_Advent_Squares[ GUI_SquareButton.Square ] ) ].Name )
	end
	GUI_SquareButton.Paint = function( self, w, h )
		-- Opened or not drawing
		if ply.CH_Advent_Squares[ self.Square ] then
			surface.SetDrawColor( color_white )
			surface.SetMaterial( ply.CH_Advent_Squares[ self.Square ] == "1" and CH_Advent.Materials.CoalIcons[ "Square" ] or CH_Advent.Materials.RewardIcons[ "Square" ] )
			surface.DrawTexturedRect( 0, 0, w, h )
			
			draw.SimpleText( self.Square, "CH_Advent_Font_Caveat_Size18", w * 0.02, h * 0.175, CH_Advent.Colors.Green, TEXT_ALIGN_LEFT, TEXT_ALIGN_CENTER )
		else
			draw.RoundedBox( 8, 0, 0, w, h, CH_Advent.Config.SquareColors[ self.Square ] )
			
			surface.SetDrawColor( color_white )
			surface.SetMaterial( CH_Advent.Materials.SquareIcons[ self.Square ] )
			surface.DrawTexturedRect( 0, 0, w, h )
			
			draw.SimpleText( self.Square, "CH_Advent_Font_Caveat_Size25", w * 0.5, h * 0.5, day > self.Square and CH_Advent.Colors.Red or ( day == self.Square ) and CH_Advent.Colors.Gold or color_white, TEXT_ALIGN_CENTER, TEXT_ALIGN_CENTER )
		end
	end
	GUI_SquareButton.OnCursorEntered = function()
		surface.PlaySound( "craphead_scripts/ch_advent_calendar/hover.wav" )
	end
	GUI_SquareButton.DoClick = function( self )
		if ( not CH_Advent.Config.CanOpenMissedSquares and day != self.Square ) or ( CH_Advent.Config.CanOpenMissedSquares and self.Square > day ) then
			surface.PlaySound( "common/wpn_denyselect.wav" )
			return
		end
		
		-- Call net
		net.Start( "CH_Advent_Net_OpenSquare" )
			net.WriteUInt( self.Square, 5 )
		net.SendToServer()
		
		-- Close it
		GUI_AdventCalendarFrame:Close()
	end
	
	-- 13
	local GUI_SquareButton = vgui.Create( "DButton", GUI_AdventCalendarFrame )
	GUI_SquareButton:SetPos( CH_Advent.ScrW * 0.695, CH_Advent.ScrH * 0.2625 )
	GUI_SquareButton:SetSize( CH_Advent.ScrW * 0.07, CH_Advent.ScrW * 0.07 )
	GUI_SquareButton:SetText( "" )
	GUI_SquareButton.Square = 13
	if CH_Advent.Config.ShowRewardTooltip and ply.CH_Advent_Squares[ GUI_SquareButton.Square ] and CH_Advent.Rewards[ tonumber( ply.CH_Advent_Squares[ GUI_SquareButton.Square ] ) ] then
		GUI_SquareButton:SetToolTip( CH_Advent.LangString( "You've won" ) .." ".. CH_Advent.Rewards[ tonumber( ply.CH_Advent_Squares[ GUI_SquareButton.Square ] ) ].Name )
	end
	GUI_SquareButton.Paint = function( self, w, h )
		-- Opened or not drawing
		if ply.CH_Advent_Squares[ self.Square ] then
			surface.SetDrawColor( color_white )
			surface.SetMaterial( ply.CH_Advent_Squares[ self.Square ] == "1" and CH_Advent.Materials.CoalIcons[ "Square" ] or CH_Advent.Materials.RewardIcons[ "Square" ] )
			surface.DrawTexturedRect( 0, 0, w, h )
			
			draw.SimpleText( self.Square, "CH_Advent_Font_Caveat_Size18", w * 0.02, h * 0.175, CH_Advent.Colors.Green, TEXT_ALIGN_LEFT, TEXT_ALIGN_CENTER )
		else
			draw.RoundedBox( 8, 0, 0, w, h, CH_Advent.Config.SquareColors[ self.Square ] )
			
			surface.SetDrawColor( color_white )
			surface.SetMaterial( CH_Advent.Materials.SquareIcons[ self.Square ] )
			surface.DrawTexturedRect( 0, 0, w, h )
			
			draw.SimpleText( self.Square, "CH_Advent_Font_Caveat_Size25", w * 0.5, h * 0.5, day > self.Square and CH_Advent.Colors.Red or ( day == self.Square ) and CH_Advent.Colors.Gold or color_white, TEXT_ALIGN_CENTER, TEXT_ALIGN_CENTER )
		end
	end
	GUI_SquareButton.OnCursorEntered = function()
		surface.PlaySound( "craphead_scripts/ch_advent_calendar/hover.wav" )
	end
	GUI_SquareButton.DoClick = function( self )
		if ( not CH_Advent.Config.CanOpenMissedSquares and day != self.Square ) or ( CH_Advent.Config.CanOpenMissedSquares and self.Square > day ) then
			surface.PlaySound( "common/wpn_denyselect.wav" )
			return
		end
		
		-- Call net
		net.Start( "CH_Advent_Net_OpenSquare" )
			net.WriteUInt( self.Square, 5 )
		net.SendToServer()
		
		-- Close it
		GUI_AdventCalendarFrame:Close()
	end
	
	-- 14
	local GUI_SquareButton = vgui.Create( "DButton", GUI_AdventCalendarFrame )
	GUI_SquareButton:SetPos( CH_Advent.ScrW * 0.115, CH_Advent.ScrH * 0.395 )
	GUI_SquareButton:SetSize( CH_Advent.ScrW * 0.1725, CH_Advent.ScrW * 0.07 )
	GUI_SquareButton:SetText( "" )
	GUI_SquareButton.Square = 14
	if CH_Advent.Config.ShowRewardTooltip and ply.CH_Advent_Squares[ GUI_SquareButton.Square ] and CH_Advent.Rewards[ tonumber( ply.CH_Advent_Squares[ GUI_SquareButton.Square ] ) ] then
		GUI_SquareButton:SetToolTip( CH_Advent.LangString( "You've won" ) .." ".. CH_Advent.Rewards[ tonumber( ply.CH_Advent_Squares[ GUI_SquareButton.Square ] ) ].Name )
	end
	GUI_SquareButton.Paint = function( self, w, h )
		-- Opened or not drawing
		if ply.CH_Advent_Squares[ self.Square ] then
			surface.SetDrawColor( color_white )
			surface.SetMaterial( ply.CH_Advent_Squares[ self.Square ] == "1" and CH_Advent.Materials.CoalIcons[ "Wide" ] or CH_Advent.Materials.RewardIcons[ "Wide" ] )
			surface.DrawTexturedRect( 0, 0, w, h )
			
			draw.SimpleText( self.Square, "CH_Advent_Font_Caveat_Size18", w * 0.02, h * 0.175, CH_Advent.Colors.Green, TEXT_ALIGN_LEFT, TEXT_ALIGN_CENTER )
		else
			draw.RoundedBox( 8, 0, 0, w, h, CH_Advent.Config.SquareColors[ self.Square ] )
			
			surface.SetDrawColor( color_white )
			surface.SetMaterial( CH_Advent.Materials.SquareIcons[ self.Square ] )
			surface.DrawTexturedRect( 0, 0, w, h )
			
			draw.SimpleText( self.Square, "CH_Advent_Font_Caveat_Size45", w * 0.5, h * 0.5, day > self.Square and CH_Advent.Colors.Red or ( day == self.Square ) and CH_Advent.Colors.Gold or color_white, TEXT_ALIGN_CENTER, TEXT_ALIGN_CENTER )
		end
	end
	GUI_SquareButton.OnCursorEntered = function()
		surface.PlaySound( "craphead_scripts/ch_advent_calendar/hover.wav" )
	end
	GUI_SquareButton.DoClick = function( self )
		if ( not CH_Advent.Config.CanOpenMissedSquares and day != self.Square ) or ( CH_Advent.Config.CanOpenMissedSquares and self.Square > day ) then
			surface.PlaySound( "common/wpn_denyselect.wav" )
			return
		end
		
		-- Call net
		net.Start( "CH_Advent_Net_OpenSquare" )
			net.WriteUInt( self.Square, 5 )
		net.SendToServer()
		
		-- Close it
		GUI_AdventCalendarFrame:Close()
	end
	
	-- 15
	local GUI_SquareButton = vgui.Create( "DButton", GUI_AdventCalendarFrame )
	GUI_SquareButton:SetPos( CH_Advent.ScrW * 0.2925, CH_Advent.ScrH * 0.395 )
	GUI_SquareButton:SetSize( CH_Advent.ScrW * 0.07, CH_Advent.ScrW * 0.07 )
	GUI_SquareButton:SetText( "" )
	GUI_SquareButton.Square = 15
	if CH_Advent.Config.ShowRewardTooltip and ply.CH_Advent_Squares[ GUI_SquareButton.Square ] and CH_Advent.Rewards[ tonumber( ply.CH_Advent_Squares[ GUI_SquareButton.Square ] ) ] then
		GUI_SquareButton:SetToolTip( CH_Advent.LangString( "You've won" ) .." ".. CH_Advent.Rewards[ tonumber( ply.CH_Advent_Squares[ GUI_SquareButton.Square ] ) ].Name )
	end
	GUI_SquareButton.Paint = function( self, w, h )
		-- Opened or not drawing
		if ply.CH_Advent_Squares[ self.Square ] then
			surface.SetDrawColor( color_white )
			surface.SetMaterial( ply.CH_Advent_Squares[ self.Square ] == "1" and CH_Advent.Materials.CoalIcons[ "Square" ] or CH_Advent.Materials.RewardIcons[ "Square" ] )
			surface.DrawTexturedRect( 0, 0, w, h )
			
			draw.SimpleText( self.Square, "CH_Advent_Font_Caveat_Size18", w * 0.92, h * 0.175, CH_Advent.Colors.Green, TEXT_ALIGN_RIGHT, TEXT_ALIGN_CENTER )
		else
			draw.RoundedBox( 8, 0, 0, w, h, CH_Advent.Config.SquareColors[ self.Square ] )
			
			surface.SetDrawColor( color_white )
			surface.SetMaterial( CH_Advent.Materials.SquareIcons[ self.Square ] )
			surface.DrawTexturedRect( 0, 0, w, h )
			
			draw.SimpleText( self.Square, "CH_Advent_Font_Caveat_Size18", w * 0.92, h * 0.175, day > self.Square and CH_Advent.Colors.Red or ( day == self.Square ) and CH_Advent.Colors.Gold or color_white, TEXT_ALIGN_RIGHT, TEXT_ALIGN_CENTER )
		end
	end
	GUI_SquareButton.OnCursorEntered = function()
		surface.PlaySound( "craphead_scripts/ch_advent_calendar/hover.wav" )
	end
	GUI_SquareButton.DoClick = function( self )
		if ( not CH_Advent.Config.CanOpenMissedSquares and day != self.Square ) or ( CH_Advent.Config.CanOpenMissedSquares and self.Square > day ) then
			surface.PlaySound( "common/wpn_denyselect.wav" )
			return
		end
		
		-- Call net
		net.Start( "CH_Advent_Net_OpenSquare" )
			net.WriteUInt( self.Square, 5 )
		net.SendToServer()
		
		-- Close it
		GUI_AdventCalendarFrame:Close()
	end

	-- 16
	local GUI_SquareButton = vgui.Create( "DButton", GUI_AdventCalendarFrame )
	GUI_SquareButton:SetPos( CH_Advent.ScrW * 0.3675, CH_Advent.ScrH * 0.395 )
	GUI_SquareButton:SetSize( CH_Advent.ScrW * 0.07, CH_Advent.ScrW * 0.145 )
	GUI_SquareButton:SetText( "" )
	GUI_SquareButton.Square = 16
	if CH_Advent.Config.ShowRewardTooltip and ply.CH_Advent_Squares[ GUI_SquareButton.Square ] and CH_Advent.Rewards[ tonumber( ply.CH_Advent_Squares[ GUI_SquareButton.Square ] ) ] then
		GUI_SquareButton:SetToolTip( CH_Advent.LangString( "You've won" ) .." ".. CH_Advent.Rewards[ tonumber( ply.CH_Advent_Squares[ GUI_SquareButton.Square ] ) ].Name )
	end
	GUI_SquareButton.Paint = function( self, w, h )
		-- Opened or not drawing
		if ply.CH_Advent_Squares[ self.Square ] then
			surface.SetDrawColor( color_white )
			surface.SetMaterial( ply.CH_Advent_Squares[ self.Square ] == "1" and CH_Advent.Materials.CoalIcons[ "Tall" ] or CH_Advent.Materials.RewardIcons[ "Tall" ] )
			surface.DrawTexturedRect( 0, 0, w, h )
			
			draw.SimpleText( self.Square, "CH_Advent_Font_Caveat_Size25", w * 0.02, h * 0.1, CH_Advent.Colors.Green, TEXT_ALIGN_LEFT, TEXT_ALIGN_CENTER )
		else
			draw.RoundedBox( 8, 0, 0, w, h, CH_Advent.Config.SquareColors[ self.Square ] )
			
			surface.SetDrawColor( color_white )
			surface.SetMaterial( CH_Advent.Materials.SquareIcons[ self.Square ] )
			surface.DrawTexturedRect( 0, 0, w, h )
			
			draw.SimpleText( self.Square, "CH_Advent_Font_Caveat_Size25", w * 0.02, h * 0.1, day > self.Square and CH_Advent.Colors.Red or ( day == self.Square ) and CH_Advent.Colors.Gold or color_white, TEXT_ALIGN_LEFT, TEXT_ALIGN_CENTER )
		end
	end
	GUI_SquareButton.OnCursorEntered = function()
		surface.PlaySound( "craphead_scripts/ch_advent_calendar/hover.wav" )
	end
	GUI_SquareButton.DoClick = function( self )
		if ( not CH_Advent.Config.CanOpenMissedSquares and day != self.Square ) or ( CH_Advent.Config.CanOpenMissedSquares and self.Square > day ) then
			surface.PlaySound( "common/wpn_denyselect.wav" )
			return
		end
		
		-- Call net
		net.Start( "CH_Advent_Net_OpenSquare" )
			net.WriteUInt( self.Square, 5 )
		net.SendToServer()
		
		-- Close it
		GUI_AdventCalendarFrame:Close()
	end
	
	-- 17
	local GUI_SquareButton = vgui.Create( "DButton", GUI_AdventCalendarFrame )
	GUI_SquareButton:SetPos( CH_Advent.ScrW * 0.4425, CH_Advent.ScrH * 0.395 )
	GUI_SquareButton:SetSize( CH_Advent.ScrW * 0.07, CH_Advent.ScrW * 0.07 )
	GUI_SquareButton:SetText( "" )
	GUI_SquareButton.Square = 17
	if CH_Advent.Config.ShowRewardTooltip and ply.CH_Advent_Squares[ GUI_SquareButton.Square ] and CH_Advent.Rewards[ tonumber( ply.CH_Advent_Squares[ GUI_SquareButton.Square ] ) ] then
		GUI_SquareButton:SetToolTip( CH_Advent.LangString( "You've won" ) .." ".. CH_Advent.Rewards[ tonumber( ply.CH_Advent_Squares[ GUI_SquareButton.Square ] ) ].Name )
	end
	GUI_SquareButton.Paint = function( self, w, h )
		-- Opened or not drawing
		if ply.CH_Advent_Squares[ self.Square ] then
			surface.SetDrawColor( color_white )
			surface.SetMaterial( ply.CH_Advent_Squares[ self.Square ] == "1" and CH_Advent.Materials.CoalIcons[ "Square" ] or CH_Advent.Materials.RewardIcons[ "Square" ] )
			surface.DrawTexturedRect( 0, 0, w, h )
			
			draw.SimpleText( self.Square, "CH_Advent_Font_Caveat_Size18", w * 0.02, h * 0.175, CH_Advent.Colors.Green, TEXT_ALIGN_LEFT, TEXT_ALIGN_CENTER )
		else
			draw.RoundedBox( 8, 0, 0, w, h, CH_Advent.Config.SquareColors[ self.Square ] )
			
			surface.SetDrawColor( color_white )
			surface.SetMaterial( CH_Advent.Materials.SquareIcons[ self.Square ] )
			surface.DrawTexturedRect( 0, 0, w, h )
			
			draw.SimpleText( self.Square, "CH_Advent_Font_Caveat_Size18", w * 0.02, h * 0.175, day > self.Square and CH_Advent.Colors.Red or ( day == self.Square ) and CH_Advent.Colors.Gold or color_white, TEXT_ALIGN_LEFT, TEXT_ALIGN_CENTER )
		end
	end
	GUI_SquareButton.OnCursorEntered = function()
		surface.PlaySound( "craphead_scripts/ch_advent_calendar/hover.wav" )
	end
	GUI_SquareButton.DoClick = function( self )
		if ( not CH_Advent.Config.CanOpenMissedSquares and day != self.Square ) or ( CH_Advent.Config.CanOpenMissedSquares and self.Square > day ) then
			surface.PlaySound( "common/wpn_denyselect.wav" )
			return
		end
		
		-- Call net
		net.Start( "CH_Advent_Net_OpenSquare" )
			net.WriteUInt( self.Square, 5 )
		net.SendToServer()
		
		-- Close it
		GUI_AdventCalendarFrame:Close()
	end
	
	-- 18
	local GUI_SquareButton = vgui.Create( "DButton", GUI_AdventCalendarFrame )
	GUI_SquareButton:SetPos( CH_Advent.ScrW * 0.5175, CH_Advent.ScrH * 0.395 )
	GUI_SquareButton:SetSize( CH_Advent.ScrW * 0.1725, CH_Advent.ScrW * 0.07 )
	GUI_SquareButton:SetText( "" )
	GUI_SquareButton.Square = 18
	if CH_Advent.Config.ShowRewardTooltip and ply.CH_Advent_Squares[ GUI_SquareButton.Square ] and CH_Advent.Rewards[ tonumber( ply.CH_Advent_Squares[ GUI_SquareButton.Square ] ) ] then
		GUI_SquareButton:SetToolTip( CH_Advent.LangString( "You've won" ) .." ".. CH_Advent.Rewards[ tonumber( ply.CH_Advent_Squares[ GUI_SquareButton.Square ] ) ].Name )
	end
	GUI_SquareButton.Paint = function( self, w, h )
		-- Opened or not drawing
		if ply.CH_Advent_Squares[ self.Square ] then
			surface.SetDrawColor( color_white )
			surface.SetMaterial( ply.CH_Advent_Squares[ self.Square ] == "1" and CH_Advent.Materials.CoalIcons[ "Wide" ] or CH_Advent.Materials.RewardIcons[ "Wide" ] )
			surface.DrawTexturedRect( 0, 0, w, h )
			
			draw.SimpleText( self.Square, "CH_Advent_Font_Caveat_Size18", w * 0.02, h * 0.175, CH_Advent.Colors.Green, TEXT_ALIGN_LEFT, TEXT_ALIGN_CENTER )
		else
			draw.RoundedBox( 8, 0, 0, w, h, CH_Advent.Config.SquareColors[ self.Square ] )
			
			surface.SetDrawColor( color_white )
			surface.SetMaterial( CH_Advent.Materials.SquareIcons[ self.Square ] )
			surface.DrawTexturedRect( 0, 0, w, h )
			
			draw.SimpleText( self.Square, "CH_Advent_Font_Caveat_Size35", w * 0.5, h * 0.5, day > self.Square and CH_Advent.Colors.Red or ( day == self.Square ) and CH_Advent.Colors.Gold or color_white, TEXT_ALIGN_CENTER, TEXT_ALIGN_CENTER )
		end
	end
	GUI_SquareButton.OnCursorEntered = function()
		surface.PlaySound( "craphead_scripts/ch_advent_calendar/hover.wav" )
	end
	GUI_SquareButton.DoClick = function( self )
		if ( not CH_Advent.Config.CanOpenMissedSquares and day != self.Square ) or ( CH_Advent.Config.CanOpenMissedSquares and self.Square > day ) then
			surface.PlaySound( "common/wpn_denyselect.wav" )
			return
		end
		
		-- Call net
		net.Start( "CH_Advent_Net_OpenSquare" )
			net.WriteUInt( self.Square, 5 )
		net.SendToServer()
		
		-- Close it
		GUI_AdventCalendarFrame:Close()
	end
	
	-- 19
	local GUI_SquareButton = vgui.Create( "DButton", GUI_AdventCalendarFrame )
	GUI_SquareButton:SetPos( CH_Advent.ScrW * 0.695, CH_Advent.ScrH * 0.395 )
	GUI_SquareButton:SetSize( CH_Advent.ScrW * 0.07, CH_Advent.ScrW * 0.145 )
	GUI_SquareButton:SetText( "" )
	GUI_SquareButton.Square = 19
	if CH_Advent.Config.ShowRewardTooltip and ply.CH_Advent_Squares[ GUI_SquareButton.Square ] and CH_Advent.Rewards[ tonumber( ply.CH_Advent_Squares[ GUI_SquareButton.Square ] ) ] then
		GUI_SquareButton:SetToolTip( CH_Advent.LangString( "You've won" ) .." ".. CH_Advent.Rewards[ tonumber( ply.CH_Advent_Squares[ GUI_SquareButton.Square ] ) ].Name )
	end
	GUI_SquareButton.Paint = function( self, w, h )
		-- Opened or not drawing
		if ply.CH_Advent_Squares[ self.Square ] then
			surface.SetDrawColor( color_white )
			surface.SetMaterial( ply.CH_Advent_Squares[ self.Square ] == "1" and CH_Advent.Materials.CoalIcons[ "Tall" ] or CH_Advent.Materials.RewardIcons[ "Tall" ] )
			surface.DrawTexturedRect( 0, 0, w, h )
			
			draw.SimpleText( self.Square, "CH_Advent_Font_Caveat_Size18", w * 0.02, h * 0.1, CH_Advent.Colors.Green, TEXT_ALIGN_LEFT, TEXT_ALIGN_CENTER )
		else
			draw.RoundedBox( 8, 0, 0, w, h, CH_Advent.Config.SquareColors[ self.Square ] )
			
			surface.SetDrawColor( color_white )
			surface.SetMaterial( CH_Advent.Materials.SquareIcons[ self.Square ] )
			surface.DrawTexturedRect( 0, 0, w, h )
			
			draw.SimpleText( self.Square, "CH_Advent_Font_Caveat_Size45", w * 0.5, h * 0.5, day > self.Square and CH_Advent.Colors.Red or ( day == self.Square ) and CH_Advent.Colors.Gold or color_white, TEXT_ALIGN_CENTER, TEXT_ALIGN_CENTER )
		end
	end
	GUI_SquareButton.OnCursorEntered = function()
		surface.PlaySound( "craphead_scripts/ch_advent_calendar/hover.wav" )
	end
	GUI_SquareButton.DoClick = function( self )
		if ( not CH_Advent.Config.CanOpenMissedSquares and day != self.Square ) or ( CH_Advent.Config.CanOpenMissedSquares and self.Square > day ) then
			surface.PlaySound( "common/wpn_denyselect.wav" )
			return
		end
		
		-- Call net
		net.Start( "CH_Advent_Net_OpenSquare" )
			net.WriteUInt( self.Square, 5 )
		net.SendToServer()
		
		-- Close it
		GUI_AdventCalendarFrame:Close()
	end
	
	-- 20
	local GUI_SquareButton = vgui.Create( "DButton", GUI_AdventCalendarFrame )
	GUI_SquareButton:SetPos( CH_Advent.ScrW * 0.04, CH_Advent.ScrH * 0.5275 )
	GUI_SquareButton:SetSize( CH_Advent.ScrW * 0.07, CH_Advent.ScrW * 0.07 )
	GUI_SquareButton:SetText( "" )
	GUI_SquareButton.Square = 20
	if CH_Advent.Config.ShowRewardTooltip and ply.CH_Advent_Squares[ GUI_SquareButton.Square ] and CH_Advent.Rewards[ tonumber( ply.CH_Advent_Squares[ GUI_SquareButton.Square ] ) ] then
		GUI_SquareButton:SetToolTip( CH_Advent.LangString( "You've won" ) .." ".. CH_Advent.Rewards[ tonumber( ply.CH_Advent_Squares[ GUI_SquareButton.Square ] ) ].Name )
	end
	GUI_SquareButton.Paint = function( self, w, h )
		-- Opened or not drawing
		if ply.CH_Advent_Squares[ self.Square ] then
			surface.SetDrawColor( color_white )
			surface.SetMaterial( ply.CH_Advent_Squares[ self.Square ] == "1" and CH_Advent.Materials.CoalIcons[ "Square" ] or CH_Advent.Materials.RewardIcons[ "Square" ] )
			surface.DrawTexturedRect( 0, 0, w, h )
			
			draw.SimpleText( self.Square, "CH_Advent_Font_Caveat_Size18", w * 0.02, h * 0.175, CH_Advent.Colors.Green, TEXT_ALIGN_LEFT, TEXT_ALIGN_CENTER )
		else
			draw.RoundedBox( 8, 0, 0, w, h, CH_Advent.Config.SquareColors[ self.Square ] )
			
			surface.SetDrawColor( color_white )
			surface.SetMaterial( CH_Advent.Materials.SquareIcons[ self.Square ] )
			surface.DrawTexturedRect( 0, 0, w, h )
			
			draw.SimpleText( self.Square, "CH_Advent_Font_Caveat_Size18", w * 0.5, h * 0.5, day > self.Square and CH_Advent.Colors.Red or ( day == self.Square ) and CH_Advent.Colors.Gold or color_white, TEXT_ALIGN_CENTER, TEXT_ALIGN_CENTER )
		end
	end
	GUI_SquareButton.OnCursorEntered = function()
		surface.PlaySound( "craphead_scripts/ch_advent_calendar/hover.wav" )
	end
	GUI_SquareButton.DoClick = function( self )
		if ( not CH_Advent.Config.CanOpenMissedSquares and day != self.Square ) or ( CH_Advent.Config.CanOpenMissedSquares and self.Square > day ) then
			surface.PlaySound( "common/wpn_denyselect.wav" )
			return
		end
		
		-- Call net
		net.Start( "CH_Advent_Net_OpenSquare" )
			net.WriteUInt( self.Square, 5 )
		net.SendToServer()
		
		-- Close it
		GUI_AdventCalendarFrame:Close()
	end
	
	-- 21
	local GUI_SquareButton = vgui.Create( "DButton", GUI_AdventCalendarFrame )
	GUI_SquareButton:SetPos( CH_Advent.ScrW * 0.115, CH_Advent.ScrH * 0.5275 )
	GUI_SquareButton:SetSize( CH_Advent.ScrW * 0.07, CH_Advent.ScrW * 0.07 )
	GUI_SquareButton:SetText( "" )
	GUI_SquareButton.Square = 21
	if CH_Advent.Config.ShowRewardTooltip and ply.CH_Advent_Squares[ GUI_SquareButton.Square ] and CH_Advent.Rewards[ tonumber( ply.CH_Advent_Squares[ GUI_SquareButton.Square ] ) ] then
		GUI_SquareButton:SetToolTip( CH_Advent.LangString( "You've won" ) .." ".. CH_Advent.Rewards[ tonumber( ply.CH_Advent_Squares[ GUI_SquareButton.Square ] ) ].Name )
	end
	GUI_SquareButton.Paint = function( self, w, h )
		-- Opened or not drawing
		if ply.CH_Advent_Squares[ self.Square ] then
			surface.SetDrawColor( color_white )
			surface.SetMaterial( ply.CH_Advent_Squares[ self.Square ] == "1" and CH_Advent.Materials.CoalIcons[ "Square" ] or CH_Advent.Materials.RewardIcons[ "Square" ] )
			surface.DrawTexturedRect( 0, 0, w, h )
			
			draw.SimpleText( self.Square, "CH_Advent_Font_Caveat_Size18", w * 0.92, h * 0.175, CH_Advent.Colors.Green, TEXT_ALIGN_RIGHT, TEXT_ALIGN_CENTER )
		else
			draw.RoundedBox( 8, 0, 0, w, h, CH_Advent.Config.SquareColors[ self.Square ] )
			
			surface.SetDrawColor( color_white )
			surface.SetMaterial( CH_Advent.Materials.SquareIcons[ self.Square ] )
			surface.DrawTexturedRect( 0, 0, w, h )
			
			draw.SimpleText( self.Square, "CH_Advent_Font_Caveat_Size18", w * 0.92, h * 0.175, day > self.Square and CH_Advent.Colors.Red or ( day == self.Square ) and CH_Advent.Colors.Gold or color_white, TEXT_ALIGN_RIGHT, TEXT_ALIGN_CENTER )
		end
	end
	GUI_SquareButton.OnCursorEntered = function()
		surface.PlaySound( "craphead_scripts/ch_advent_calendar/hover.wav" )
	end
	GUI_SquareButton.DoClick = function( self )
		if ( not CH_Advent.Config.CanOpenMissedSquares and day != self.Square ) or ( CH_Advent.Config.CanOpenMissedSquares and self.Square > day ) then
			surface.PlaySound( "common/wpn_denyselect.wav" )
			return
		end
		
		-- Call net
		net.Start( "CH_Advent_Net_OpenSquare" )
			net.WriteUInt( self.Square, 5 )
		net.SendToServer()
		
		-- Close it
		GUI_AdventCalendarFrame:Close()
	end
	
	-- 22
	local GUI_SquareButton = vgui.Create( "DButton", GUI_AdventCalendarFrame )
	GUI_SquareButton:SetPos( CH_Advent.ScrW * 0.19, CH_Advent.ScrH * 0.5275 )
	GUI_SquareButton:SetSize( CH_Advent.ScrW * 0.1725, CH_Advent.ScrW * 0.07 )
	GUI_SquareButton:SetText( "" )
	GUI_SquareButton.Square = 22
	if CH_Advent.Config.ShowRewardTooltip and ply.CH_Advent_Squares[ GUI_SquareButton.Square ] and CH_Advent.Rewards[ tonumber( ply.CH_Advent_Squares[ GUI_SquareButton.Square ] ) ] then
		GUI_SquareButton:SetToolTip( CH_Advent.LangString( "You've won" ) .." ".. CH_Advent.Rewards[ tonumber( ply.CH_Advent_Squares[ GUI_SquareButton.Square ] ) ].Name )
	end
	GUI_SquareButton.Paint = function( self, w, h )
		-- Opened or not drawing
		if ply.CH_Advent_Squares[ self.Square ] then
			surface.SetDrawColor( color_white )
			surface.SetMaterial( ply.CH_Advent_Squares[ self.Square ] == "1" and CH_Advent.Materials.CoalIcons[ "Wide" ] or CH_Advent.Materials.RewardIcons[ "Wide" ] )
			surface.DrawTexturedRect( 0, 0, w, h )
			
			draw.SimpleText( self.Square, "CH_Advent_Font_Caveat_Size18", w * 0.02, h * 0.175, CH_Advent.Colors.Green, TEXT_ALIGN_LEFT, TEXT_ALIGN_CENTER )
		else
			draw.RoundedBox( 8, 0, 0, w, h, CH_Advent.Config.SquareColors[ self.Square ] )
			
			surface.SetDrawColor( color_white )
			surface.SetMaterial( CH_Advent.Materials.SquareIcons[ self.Square ] )
			surface.DrawTexturedRect( 0, 0, w, h )
			
			draw.SimpleText( self.Square, "CH_Advent_Font_Caveat_Size45", w * 0.5, h * 0.5, day > self.Square and CH_Advent.Colors.Red or ( day == self.Square ) and CH_Advent.Colors.Gold or color_white, TEXT_ALIGN_CENTER, TEXT_ALIGN_CENTER )
		end
	end
	GUI_SquareButton.OnCursorEntered = function()
		surface.PlaySound( "craphead_scripts/ch_advent_calendar/hover.wav" )
	end
	GUI_SquareButton.DoClick = function( self )
		if ( not CH_Advent.Config.CanOpenMissedSquares and day != self.Square ) or ( CH_Advent.Config.CanOpenMissedSquares and self.Square > day ) then
			surface.PlaySound( "common/wpn_denyselect.wav" )
			return
		end
		
		-- Call net
		net.Start( "CH_Advent_Net_OpenSquare" )
			net.WriteUInt( self.Square, 5 )
		net.SendToServer()
		
		-- Close it
		GUI_AdventCalendarFrame:Close()
	end
	
	-- 23
	local GUI_SquareButton = vgui.Create( "DButton", GUI_AdventCalendarFrame )
	GUI_SquareButton:SetPos( CH_Advent.ScrW * 0.4425, CH_Advent.ScrH * 0.5275 )
	GUI_SquareButton:SetSize( CH_Advent.ScrW * 0.1725, CH_Advent.ScrW * 0.07 )
	GUI_SquareButton:SetText( "" )
	GUI_SquareButton.Square = 23
	if CH_Advent.Config.ShowRewardTooltip and ply.CH_Advent_Squares[ GUI_SquareButton.Square ] and CH_Advent.Rewards[ tonumber( ply.CH_Advent_Squares[ GUI_SquareButton.Square ] ) ] then
		GUI_SquareButton:SetToolTip( CH_Advent.LangString( "You've won" ) .." ".. CH_Advent.Rewards[ tonumber( ply.CH_Advent_Squares[ GUI_SquareButton.Square ] ) ].Name )
	end
	GUI_SquareButton.Paint = function( self, w, h )
		-- Opened or not drawing
		if ply.CH_Advent_Squares[ self.Square ] then
			surface.SetDrawColor( color_white )
			surface.SetMaterial( ply.CH_Advent_Squares[ self.Square ] == "1" and CH_Advent.Materials.CoalIcons[ "Wide" ] or CH_Advent.Materials.RewardIcons[ "Wide" ] )
			surface.DrawTexturedRect( 0, 0, w, h )
			
			draw.SimpleText( self.Square, "CH_Advent_Font_Caveat_Size18", w * 0.02, h * 0.175, CH_Advent.Colors.Green, TEXT_ALIGN_LEFT, TEXT_ALIGN_CENTER )
		else
			draw.RoundedBox( 8, 0, 0, w, h, CH_Advent.Config.SquareColors[ self.Square ] )
			
			surface.SetDrawColor( color_white )
			surface.SetMaterial( CH_Advent.Materials.SquareIcons[ self.Square ] )
			surface.DrawTexturedRect( 0, 0, w, h )
			
			draw.SimpleText( self.Square, "CH_Advent_Font_Caveat_Size45", w * 0.5, h * 0.5, day > self.Square and CH_Advent.Colors.Red or ( day == self.Square ) and CH_Advent.Colors.Gold or color_white, TEXT_ALIGN_CENTER, TEXT_ALIGN_CENTER )
		end
	end
	GUI_SquareButton.OnCursorEntered = function()
		surface.PlaySound( "craphead_scripts/ch_advent_calendar/hover.wav" )
	end
	GUI_SquareButton.DoClick = function( self )
		if ( not CH_Advent.Config.CanOpenMissedSquares and day != self.Square ) or ( CH_Advent.Config.CanOpenMissedSquares and self.Square > day ) then
			surface.PlaySound( "common/wpn_denyselect.wav" )
			return
		end
		
		-- Call net
		net.Start( "CH_Advent_Net_OpenSquare" )
			net.WriteUInt( self.Square, 5 )
		net.SendToServer()
		
		-- Close it
		GUI_AdventCalendarFrame:Close()
	end
	
	-- 24
	local GUI_SquareButton = vgui.Create( "DButton", GUI_AdventCalendarFrame )
	GUI_SquareButton:SetPos( CH_Advent.ScrW * 0.62, CH_Advent.ScrH * 0.5275 )
	GUI_SquareButton:SetSize( CH_Advent.ScrW * 0.07, CH_Advent.ScrW * 0.07 )
	GUI_SquareButton:SetText( "" )
	GUI_SquareButton.Square = 24
	if CH_Advent.Config.ShowRewardTooltip and ply.CH_Advent_Squares[ GUI_SquareButton.Square ] and CH_Advent.Rewards[ tonumber( ply.CH_Advent_Squares[ GUI_SquareButton.Square ] ) ] then
		GUI_SquareButton:SetToolTip( CH_Advent.LangString( "You've won" ) .." ".. CH_Advent.Rewards[ tonumber( ply.CH_Advent_Squares[ GUI_SquareButton.Square ] ) ].Name )
	end
	GUI_SquareButton.Paint = function( self, w, h )
		-- Opened or not drawing
		if ply.CH_Advent_Squares[ self.Square ] then
			surface.SetDrawColor( color_white )
			surface.SetMaterial( ply.CH_Advent_Squares[ self.Square ] == "1" and CH_Advent.Materials.CoalIcons[ "Square" ] or CH_Advent.Materials.RewardIcons[ "Square" ] )
			surface.DrawTexturedRect( 0, 0, w, h )
			
			draw.SimpleText( self.Square, "CH_Advent_Font_Caveat_Size18", w * 0.02, h * 0.175, CH_Advent.Colors.Green, TEXT_ALIGN_LEFT, TEXT_ALIGN_CENTER )
		else
			draw.RoundedBox( 8, 0, 0, w, h, CH_Advent.Config.SquareColors[ self.Square ] )
			
			surface.SetDrawColor( color_white )
			surface.SetMaterial( CH_Advent.Materials.SquareIcons[ self.Square ] )
			surface.DrawTexturedRect( 0, 0, w, h )
			
			draw.SimpleText( self.Square, "CH_Advent_Font_Caveat_Size18", w * 0.02, h * 0.175, day > self.Square and CH_Advent.Colors.Red or ( day == self.Square ) and CH_Advent.Colors.Gold or color_white, TEXT_ALIGN_LEFT, TEXT_ALIGN_CENTER )
		end
	end
	GUI_SquareButton.OnCursorEntered = function()
		surface.PlaySound( "craphead_scripts/ch_advent_calendar/hover.wav" )
	end
	GUI_SquareButton.DoClick = function( self )
		if ( not CH_Advent.Config.CanOpenMissedSquares and day != self.Square ) or ( CH_Advent.Config.CanOpenMissedSquares and self.Square > day ) then
			surface.PlaySound( "common/wpn_denyselect.wav" )
			return
		end
		
		-- Call net
		net.Start( "CH_Advent_Net_OpenSquare" )
			net.WriteUInt( self.Square, 5 )
		net.SendToServer()
		
		-- Close it
		GUI_AdventCalendarFrame:Close()
	end
	
	-- LINK BUTTONS
	local link_btn_pos = 0.62
	
	if CH_Advent.Config.MenuLinks[ "YouTube" ] != "" then
		local GUI_LinkButton = vgui.Create( "DButton", GUI_AdventCalendarFrame )
		GUI_LinkButton:SetPos( CH_Advent.ScrW * 0.7775, CH_Advent.ScrH * link_btn_pos )
		GUI_LinkButton:SetSize( CH_Advent.ScrW * 0.015, CH_Advent.ScrW * 0.015 )
		GUI_LinkButton:SetText( "" )
		GUI_LinkButton.Paint = function( self, w, h )
			surface.SetDrawColor( color_white )
			surface.SetMaterial( CH_Advent.Materials.LinkIcons[ "YouTube" ] )
			surface.DrawTexturedRect( 0, 0, w, h )
		end
		GUI_LinkButton.OnCursorEntered = function()
			surface.PlaySound( "craphead_scripts/ch_advent_calendar/hover.wav" )
		end
		GUI_LinkButton.DoClick = function( self )
			gui.OpenURL( CH_Advent.Config.MenuLinks[ "YouTube" ] )
		end
	end
	
	if CH_Advent.Config.MenuLinks[ "Discord" ] != "" then
		link_btn_pos = link_btn_pos - 0.045
		
		local GUI_LinkButton = vgui.Create( "DButton", GUI_AdventCalendarFrame )
		GUI_LinkButton:SetPos( CH_Advent.ScrW * 0.7775, CH_Advent.ScrH * link_btn_pos )
		GUI_LinkButton:SetSize( CH_Advent.ScrW * 0.015, CH_Advent.ScrW * 0.015 )
		GUI_LinkButton:SetText( "" )
		GUI_LinkButton.Paint = function( self, w, h )
			surface.SetDrawColor( color_white )
			surface.SetMaterial( CH_Advent.Materials.LinkIcons[ "Discord" ] )
			surface.DrawTexturedRect( 0, 0, w, h )
		end
		GUI_LinkButton.OnCursorEntered = function()
			surface.PlaySound( "craphead_scripts/ch_advent_calendar/hover.wav" )
		end
		GUI_LinkButton.DoClick = function( self )
			gui.OpenURL( CH_Advent.Config.MenuLinks[ "Discord" ] )
		end
	end
	
	if CH_Advent.Config.MenuLinks[ "Steam" ] != "" then
		link_btn_pos = link_btn_pos - 0.045
		
		local GUI_LinkButton = vgui.Create( "DButton", GUI_AdventCalendarFrame )
		GUI_LinkButton:SetPos( CH_Advent.ScrW * 0.7775, CH_Advent.ScrH * link_btn_pos )
		GUI_LinkButton:SetSize( CH_Advent.ScrW * 0.015, CH_Advent.ScrW * 0.015 )
		GUI_LinkButton:SetText( "" )
		GUI_LinkButton.Paint = function( self, w, h )
			surface.SetDrawColor( color_white )
			surface.SetMaterial( CH_Advent.Materials.LinkIcons[ "Steam" ] )
			surface.DrawTexturedRect( 0, 0, w, h )
		end
		GUI_LinkButton.OnCursorEntered = function()
			surface.PlaySound( "craphead_scripts/ch_advent_calendar/hover.wav" )
		end
		GUI_LinkButton.DoClick = function( self )
			gui.OpenURL( CH_Advent.Config.MenuLinks[ "Steam" ] )
		end
	end
	
	if CH_Advent.Config.MenuLinks[ "Website" ] != "" then
		link_btn_pos = link_btn_pos - 0.045
		
		local GUI_LinkButton = vgui.Create( "DButton", GUI_AdventCalendarFrame )
		GUI_LinkButton:SetPos( CH_Advent.ScrW * 0.7775, CH_Advent.ScrH * link_btn_pos )
		GUI_LinkButton:SetSize( CH_Advent.ScrW * 0.015, CH_Advent.ScrW * 0.015 )
		GUI_LinkButton:SetText( "" )
		GUI_LinkButton.Paint = function( self, w, h )
			surface.SetDrawColor( color_white )
			surface.SetMaterial( CH_Advent.Materials.LinkIcons[ "Website" ] )
			surface.DrawTexturedRect( 0, 0, w, h )
		end
		GUI_LinkButton.OnCursorEntered = function()
			surface.PlaySound( "craphead_scripts/ch_advent_calendar/hover.wav" )
		end
		GUI_LinkButton.DoClick = function( self )
			gui.OpenURL( CH_Advent.Config.MenuLinks[ "Website" ] )
		end
	end
end