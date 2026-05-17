--[[
	Open the menu
--]]
net.Receive( "CH_Advent_Net_ShowLeaderboard", function()
	local timeleft = net.ReadUInt( 32 )
	local day = net.ReadUInt( 5 )
	
	local history_len = net.ReadUInt( 32 )
	local leaderboard = {}
	
	for i = 1, history_len do
		table.insert( leaderboard, {
			Nick = net.ReadString(),
			Coal = net.ReadUInt( 5 ),
		} )
	end
	
	CH_Advent.LeaderboardMenu( timeleft, day, leaderboard )
end )

function CH_Advent.LeaderboardMenu( timeleft, day, leaderboard )
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
		draw.SimpleText( CH_Advent.LangString( "Coal Leaderboard" ), "CH_Advent_Font_Outfit_Size25", w * 0.05, h * 0.13, CH_Advent.Colors.DarkRed, TEXT_ALIGN_LEFT, TEXT_ALIGN_CENTER )
		
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
		draw.SimpleText( string.upper( CH_Advent.LangString( "Calendar" ) ), "CH_Advent_Font_Outfit_Size7", w / 2, h * 0.1, self:IsHovered() and color_white or CH_Advent.Colors.WhiteAlpha, TEXT_ALIGN_CENTER, TEXT_ALIGN_TOP )
	end
	GUI_CalendarButton.OnCursorEntered = function()
		surface.PlaySound( "craphead_scripts/ch_advent_calendar/hover.wav" )
	end
	GUI_CalendarButton.DoClick = function( self )
		CH_Advent.DashboardMenu( timeleft, day )
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
		draw.SimpleText( string.upper( CH_Advent.LangString( "Leaderboard" ) ), "CH_Advent_Font_Outfit_Size7", w / 2, h * 0.1, color_white, TEXT_ALIGN_CENTER, TEXT_ALIGN_TOP )

		draw.SimpleText( "•", "CH_Advent_Font_Outfit_Size6", w / 2, h * 0.5, CH_Advent.Colors.DarkRed, TEXT_ALIGN_CENTER, TEXT_ALIGN_TOP )
	end
	GUI_LeaderboardButton.OnCursorEntered = function()
		surface.PlaySound( "craphead_scripts/ch_advent_calendar/hover.wav" )
	end
	GUI_LeaderboardButton.DoClick = function( self )
		
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
	
	-- Top info panel
	local GUI_TopInfoPanel = vgui.Create( "DPanel", GUI_AdventCalendarFrame )
	GUI_TopInfoPanel:SetPos( CH_Advent.ScrW * 0.04, CH_Advent.ScrH * 0.13 )
	GUI_TopInfoPanel:SetSize( CH_Advent.ScrW * 0.725, CH_Advent.ScrH * 0.04 )
	GUI_TopInfoPanel.Paint = function( self, w, h )
		draw.RoundedBox( 8, 0, 0, w, h, CH_Advent.Colors.DarkRed )
		
		surface.SetDrawColor( color_white )
		surface.SetMaterial( CH_Advent.Materials.SparksWhite )
		surface.DrawTexturedRect( 0, 0, w, h )
		
		draw.SimpleText( CH_Advent.LangString( "Place" ), "CH_Advent_Font_Outfit_Size12", w * 0.02, h * 0.5, color_white, TEXT_ALIGN_LEFT, TEXT_ALIGN_CENTER )

		draw.SimpleText( CH_Advent.LangString( "Name" ), "CH_Advent_Font_Outfit_Size12", w * 0.5, h * 0.5, color_white, TEXT_ALIGN_CENTER, TEXT_ALIGN_CENTER )
		
		draw.SimpleText( CH_Advent.LangString( "Collected" ), "CH_Advent_Font_Outfit_Size12", w * 0.98, h * 0.5, color_white, TEXT_ALIGN_RIGHT, TEXT_ALIGN_CENTER )
	end
	
	-- TABLE OF REPAYMENTS
	-- Draw items in menu
	local GUI_HistoryList = vgui.Create( "DPanelList", GUI_AdventCalendarFrame )
	GUI_HistoryList:SetPos( CH_Advent.ScrW * 0.04, CH_Advent.ScrH * 0.18 )
	GUI_HistoryList:SetSize( CH_Advent.ScrW * 0.725, CH_Advent.ScrH * 0.47 )
	GUI_HistoryList:EnableVerticalScrollbar( true )
	GUI_HistoryList:EnableHorizontal( true )
	GUI_HistoryList:SetSpacing( 11 )
	GUI_HistoryList.Paint = function( self, w, h )
		--draw.RoundedBox( 0, 0, 0, w, h, Color( 255, 0, 0, 20 ) )
	end
	if ( GUI_HistoryList.VBar ) then
		GUI_HistoryList.VBar.Paint = function( self, w, h ) -- BG
			surface.SetDrawColor( ColorAlpha( CH_Advent.Colors.Lime, 50 ) )
			surface.DrawRect( 0, 12, w, h - 24 )
		end
		
		GUI_HistoryList.VBar.btnUp.Paint = function( self, w, h )
			draw.RoundedBoxEx( 8, 0, 0, w, h, CH_Advent.Colors.Lime, true, true, false, false )
		end
		
		GUI_HistoryList.VBar.btnGrip.Paint = function( self, w, h )
			surface.SetDrawColor( CH_Advent.Colors.DarkRed )
			surface.DrawRect( 0, 0, w, h )
		end
		
		GUI_HistoryList.VBar.btnDown.Paint = function( self, w, h )
			draw.RoundedBoxEx( 8, 0, 0, w, h, CH_Advent.Colors.Lime, false, false, true, true )
		end
	end
	
	-- Show leaderboard
	for k, v in SortedPairs( leaderboard, true ) do
		local name = v.Nick
		local coal = v.Coal
		
		local rand_bg = math.random( 1, 2 ) == 1 and CH_Advent.Materials.SparksWhite or CH_Advent.Materials.SparksRed

		local GUI_HistoryPanel = vgui.Create( "DPanelList" )
		GUI_HistoryPanel:SetSize( CH_Advent.ScrW * ( #leaderboard > 10 and 0.7125 or 0.725 ), CH_Advent.ScrH * 0.04 )
		GUI_HistoryPanel.Paint = function( self, w, h )
			draw.RoundedBox( 8, 0, 0, w, h, CH_Advent.Colors.Lime )
			
			surface.SetDrawColor( color_white )
			surface.SetMaterial( rand_bg )
			surface.DrawTexturedRect( 0, 0, w, h )
			
			draw.SimpleText( "#"..k, "CH_Advent_Font_Outfit_Size10", w * 0.02, h * 0.475, CH_Advent.Colors.BG, TEXT_ALIGN_LEFT, TEXT_ALIGN_CENTER )

			draw.SimpleText( name, "CH_Advent_Font_Outfit_Size10", w * 0.5, h * 0.475, CH_Advent.Colors.BG, TEXT_ALIGN_CENTER, TEXT_ALIGN_CENTER )
			
			draw.SimpleText( coal, "CH_Advent_Font_Outfit_Size10", w * 0.98, h * 0.475, CH_Advent.Colors.BG, TEXT_ALIGN_RIGHT, TEXT_ALIGN_CENTER )
		end

		GUI_HistoryList:AddItem( GUI_HistoryPanel )
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