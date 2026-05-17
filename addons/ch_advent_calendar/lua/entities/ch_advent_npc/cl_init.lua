include( "shared.lua" )

function ENT:DrawTranslucent()
	self:DrawModel()
	
	local ply = LocalPlayer()
	
	if ply:GetPos():DistToSqr( self:GetPos() ) >= CH_Advent.Config.DistanceTo3D2D then
		return
	end
	
	local Ang = self:GetAngles()
	local AngEyes = ply:EyeAngles()

	Ang:RotateAroundAxis( Ang:Forward(), 90 )
	Ang:RotateAroundAxis( Ang:Right(), -90 )
	
	cam.Start3D2D( self:GetPos() + self:GetUp() * 85, Angle( 0, AngEyes.y - 90, 90 ), 0.05 )
		if CH_Advent.Config.DrawDetailed3D2D then
			draw.RoundedBox( 8, -300, 20, 600, 160, CH_Advent.Colors.Beige )

			-- Icon
			surface.SetDrawColor( color_white )
			surface.SetMaterial( CH_Advent.Materials.SquareIcons[ 6 ] )
			surface.DrawTexturedRect( -300, 20, 600, 160 )
			
			local ply_name = CH_Advent.LangString( "Hey" ) .." ".. ply:Nick() ..","
			if string.len( ply_name ) > 17 then
				ply_name = string.Left( ply_name, 17 ) ..".."
			end
			
			draw.SimpleTextOutlined( CH_Advent.LangString( "Advent Calendar" ), "CH_Advent_Font_NPC", -130, 55, CH_Advent.Colors.Red, TEXT_ALIGN_LEFT, TEXT_ALIGN_CENTER, 2, color_black )
			draw.SimpleTextOutlined( ply_name, "CH_Advent_Font_NPC_Small", -270, 115, CH_Advent.Colors.Red, TEXT_ALIGN_LEFT, TEXT_ALIGN_CENTER, 2, color_black )
			draw.SimpleTextOutlined( CH_Advent.LangString( "Open the advent calendar here" ), "CH_Advent_Font_NPC_Smaller", -270, 150, CH_Advent.Colors.Red, TEXT_ALIGN_LEFT, TEXT_ALIGN_CENTER, 2, color_black )
		elseif CH_Advent.Config.DrawSimplistc3D2D then
			draw.SimpleTextOutlined( CH_Advent.LangString( "Advent Calendar" ), "CH_Advent_Font_NPC", 0, 140, CH_Advent.Colors.Red, TEXT_ALIGN_CENTER, TEXT_ALIGN_CENTER, 2, color_black )
			draw.SimpleTextOutlined( CH_Advent.LangString( "Open the advent calendar here" ), "CH_Advent_Font_NPC_Small", 0, 190, CH_Advent.Colors.Red, TEXT_ALIGN_CENTER, TEXT_ALIGN_CENTER, 2, color_black )
		end
	cam.End3D2D()
end