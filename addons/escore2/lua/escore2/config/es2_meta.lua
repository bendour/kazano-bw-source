escore2.addon = esclib:Addon("escore2")
escore2.addon:SetName("escoreboard2")
escore2.addon:SetBranch("release")
escore2.addon:SetVersion("1.1.4")
escore2.addon:SetDescription("Reimagined scoreboard for Gmod")
escore2.addon:SetColor(Color(255,0,200))

if CLIENT then
	escore2.addon:SetThumbnail(escore2:GetMaterial("escore2_logo.png"))
end