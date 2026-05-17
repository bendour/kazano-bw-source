local MODULE = GAS.Logging:MODULE()

MODULE.Category = "Advent Calendar"
MODULE.Name = "Squares Opened"
MODULE.Colour = Color( 245, 238, 215, 255 )

MODULE:Setup( function()
	MODULE:Hook( "CH_Advent_OpenSquare", "advent_calendar_open", function( ply, num, reward )
		MODULE:Log( "{1} has opened square {2} and won {3}.", GAS.Logging:FormatPlayer( ply ), GAS.Logging:Highlight( num ), GAS.Logging:Highlight( reward ) )
	end )
end )

GAS.Logging:AddModule( MODULE )