echat.addon = esclib:Addon("echat")
echat.addon:SetName("echat")
echat.addon:SetBranch("release")
echat.addon:SetVersion("1.46.9")
echat.addon:SetDescription("Chat for Gmod")
echat.addon:SetColor(Color(198,53,255))

if CLIENT then
	echat.addon:SetThumbnail(echat:GetMaterial("echat_icon.png"))
end