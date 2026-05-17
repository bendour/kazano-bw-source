-- [[ CREATED BY ZOMBIE EXTINGUISHER ]]

function CL_HADEZ:DrawDoubleBlueTxt(txt, font, x, y, yOffset, xAllign, yAllign)

	draw.DrawText(txt, font, x, y, SH_HADEZ.VAR.COLOR.DARKBLUE, xAllign, yAllign)
	draw.DrawText(txt, font, x, y-yOffset, SH_HADEZ.VAR.COLOR.LIGHTBLUE, xAllign, yAllign)

end