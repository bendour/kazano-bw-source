if not CLIENT then return end

local wMod = ScrW() / 1920
local hMod = ScrH() / 1080

local zwf_SpliceLabMenu = {}
local zwf_SpliceLabMain = {}


/////////// General
local function zwf_OpenUI()
	if not IsValid(zwf_SpliceLabMenu_panel) then

		zwf_SpliceLabMenu_panel = vgui.Create("zwf_vgui_SpliceLabMenu")
	end
end

local function zwf_CloseUI()

	if IsValid(zwf_SpliceLabMenu_panel) then
		zwf_SpliceLabMenu_panel:Remove()
	end
end
///////////


// This closes the shop interface
net.Receive("zwf_CloseSpliceLab", function(len)
	zwf_CloseUI()
end)

local function DrawBlur(p, a, d)
	local x, y = p:LocalToScreen(0, 0)
	surface.SetDrawColor(zwf.default_colors["white01"])
	surface.SetMaterial(zwf.default_materials["blur"])

	for i = 1, d do
		zwf.default_materials["blur"]:SetFloat("$blur", (i / d) * a)
		zwf.default_materials["blur"]:Recompute()
		render.UpdateScreenEffectTexture()
		surface.DrawTexturedRect(x * -1, y * -1, ScrW(), ScrH())
	end
end


// This opens the shop interface
net.Receive("zwf_OpenSpliceLab", function(len)
	LocalPlayer().zwf_SpliceLab = net.ReadEntity()
	zwf_OpenUI()
end)

local function zwf_SendWeedName()
	local name = zwf_SpliceLabMain.TextEntryPanel:GetValue()

	if name == nil then return end
	if name == "" then return end
	if name == " " then return end

	if zwf.f.String_ValidCharacter(name) == false then
		notification.AddLegacy(zwf.language.General["invalid_character"], NOTIFY_ERROR, 2)
		surface.PlaySound("buttons/button15.wav")

		return
	end

	if zwf.f.String_TooShort(name, 4) then
		notification.AddLegacy(zwf.language.General["name_too_short"], NOTIFY_ERROR, 2)
		surface.PlaySound("buttons/button15.wav")

		return
	end

	if zwf.f.String_TooLong(name, 12) then
		notification.AddLegacy(zwf.language.General["name_too_long"], NOTIFY_ERROR, 2)
		surface.PlaySound("buttons/button15.wav")

		return
	end

	net.Start("zwf_SpliceWeed")
	net.WriteEntity(LocalPlayer().zwf_SpliceLab)
	net.WriteString(name)
	net.SendToServer()

	zwf_CloseUI()

	surface.PlaySound("UI/buttonclick.wav")
end

/////////// Init
function zwf_SpliceLabMenu:Init()
	self:SetSize(400 * wMod, 150 * hMod)
	//self:SetBackgroundBlur( true )
	self:SetSizable(false)
	self:SetTitle("")
	self:ShowCloseButton(false)
	self:SetPaintShadow(true)
	self:SetScreenLock(true)
	self:SetDraggable(false)
	self:Center()
	self:MakePopup()

	zwf_SpliceLabMain.Title = vgui.Create("DLabel", self)
	zwf_SpliceLabMain.Title:SetPos(15 * wMod, 15 * hMod)
	zwf_SpliceLabMain.Title:SetSize(300 * wMod, 125 * hMod)
	zwf_SpliceLabMain.Title:SetFont(zwf.f.GetFont("zwf_vgui_font01"))
	zwf_SpliceLabMain.Title:SetText(zwf.language.VGUI["SeedName"])
	zwf_SpliceLabMain.Title:SetColor(zwf.default_colors["white01"])
	zwf_SpliceLabMain.Title:SetContentAlignment(7)

	zwf_SpliceLabMain.Cancel = vgui.Create("DButton", self)
	zwf_SpliceLabMain.Cancel:SetText("")
	zwf_SpliceLabMain.Cancel:SetPos(220 * wMod, 100 * hMod)
	zwf_SpliceLabMain.Cancel:SetSize(140 * wMod, 40 * hMod)
	zwf_SpliceLabMain.Cancel.DoClick = function()
		zwf_CloseUI()
	end
	zwf_SpliceLabMain.Cancel.Paint = function(s,w, h)
		if zwf_SpliceLabMain.Cancel:IsHovered() then
			surface.SetDrawColor(255, 160, 160, 255)
		else
			surface.SetDrawColor(zwf.default_colors["red03"])
		end


		surface.SetMaterial(zwf.default_materials["button_wide"])
		surface.DrawTexturedRect(0, 0, w, h)

		if zwf_SpliceLabMain.Cancel:IsHovered() then
			draw.DrawText(zwf.language.General["Cancel"], zwf.f.GetFont("zwf_vgui_font10"), 68 * wMod, 7 * hMod, zwf.default_colors["white01"], TEXT_ALIGN_CENTER)
		else
			draw.DrawText(zwf.language.General["Cancel"], zwf.f.GetFont("zwf_vgui_font10"), 68 * wMod, 7 * hMod, zwf.default_colors["black06"], TEXT_ALIGN_CENTER)
		end
	end

	zwf_SpliceLabMain.Enter = vgui.Create("DButton", self)
	zwf_SpliceLabMain.Enter:SetText("")
	zwf_SpliceLabMain.Enter:SetPos(35 * wMod, 100 * hMod)
	zwf_SpliceLabMain.Enter:SetSize(140 * wMod, 40 * hMod)
	zwf_SpliceLabMain.Enter:SetVisible(true)
	zwf_SpliceLabMain.Enter.DoClick = function()

		zwf_SendWeedName()
	end
	zwf_SpliceLabMain.Enter.Paint = function(s,w, h)
		if zwf_SpliceLabMain.Enter:IsHovered() then
			surface.SetDrawColor(zwf.default_colors["green06"])
		else
			surface.SetDrawColor(zwf.default_colors["green02"])
		end

		surface.SetMaterial(zwf.default_materials["button_wide"])
		surface.DrawTexturedRect(0, 0, w, h)

		if zwf_SpliceLabMain.Enter:IsHovered() then
			draw.DrawText(zwf.language.General["Enter"], zwf.f.GetFont("zwf_vgui_font10"), 68 * wMod, 7 * hMod, zwf.default_colors["white01"], TEXT_ALIGN_CENTER)
		else
			draw.DrawText(zwf.language.General["Enter"], zwf.f.GetFont("zwf_vgui_font10"), 68 * wMod, 7 * hMod, zwf.default_colors["black06"], TEXT_ALIGN_CENTER)
		end

	end


	zwf_SpliceLabMain.TextEntryPanel = vgui.Create("DTextEntry", self)
	zwf_SpliceLabMain.TextEntryPanel:SetPos(15 * wMod, 55 * hMod)
	zwf_SpliceLabMain.TextEntryPanel:SetSize(370 * wMod, 35 * hMod)
	zwf_SpliceLabMain.TextEntryPanel:SetText(zwf.language.General["seedlab_help"])
end


function zwf_SpliceLabMenu:Paint(w, h)
	DrawBlur( self, 3, 6 )

	draw.RoundedBox(10, 0 , 0, w, h,  zwf.default_colors["black03"])

end


vgui.Register("zwf_vgui_SpliceLabMenu", zwf_SpliceLabMenu, "DFrame")
