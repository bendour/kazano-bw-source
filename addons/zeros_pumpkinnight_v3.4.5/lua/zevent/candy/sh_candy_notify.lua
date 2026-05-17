/*
    Addon id: 5d8b797b-05d3-45b1-9efb-d4bfab61cce1
    Version: v3.4.5 (stable)
*/

zpn = zpn or {}
zpn.Candy = zpn.Candy or {}

if SERVER then
	util.AddNetworkString("zpn_candy_notify")
	function zpn.Candy.Notify(ply,candy)
		net.Start("zpn_candy_notify")
		net.WriteInt(candy,16)
		net.WriteUInt(zpn.Candy.ReturnPoints(ply),16)
		net.Send(ply)
	end
end

if CLIENT then
	net.Receive("zpn_candy_notify", function(len)
		local candy_gain = net.ReadInt(16)
		local candy = net.ReadUInt(16)
		zclib.Debug("zpn_candy_notify Length: " .. len)
                                                                                                                                                                                                                                                                                                                                                                                                                                                       -- da71c7e0bf5016ce33a9f318a3747fb53331bb70d9090f016fdcc745ceefa6b8

		if candy_gain and candy then
			zpn.Candy.Notify(candy_gain,candy)
		end
	end)
                                                                                                                                                                                                                                                                                                                                                                                                                                                       -- 69811ac079f3e93f705541d1ed39dfac3a9e2460011697a76c02cf9afa26f9c3

	local function SetupNotify()
		if zpn.CandyNotify and IsValid(zpn.CandyNotify.main) then
			zpn.CandyNotify.main:Remove()
		end

		if zpn.CandyNotify and IsValid(zpn.CandyNotify.thunder_panel) then
			zpn.CandyNotify.thunder_panel:Remove()
		end

		zpn.CandyNotify = {}


		zpn.CandyNotify.thunder_panel = vgui.Create("DPanel")
		zpn.CandyNotify.thunder_panel:SetPos(810 * zclib.wM, 390 * zclib.hM)
		zpn.CandyNotify.thunder_panel:SetSize(300 * zclib.wM, 300 * zclib.hM)
		zpn.CandyNotify.thunder_panel:SizeToContentsX(3)
		zpn.CandyNotify.thunder_panel:SizeToContentsY(3)
		zpn.CandyNotify.thunder_panel:SetAlpha( 0 )
		zpn.CandyNotify.thunder_panel:ParentToHUD()
		zpn.CandyNotify.thunder_panel:SetPaintBackground( false )

		zpn.CandyNotify.thunder_img = vgui.Create("DImage",zpn.CandyNotify.thunder_panel)
		zpn.CandyNotify.thunder_img:Dock(FILL)
		zpn.CandyNotify.thunder_img:SetImage("zerochain/zpn/ui/zpn_thunder.png")
		zpn.CandyNotify.thunder_img:SetImageColor(color_white)
                                                                                                                                                                                                                                                                                                                                                                                                                                                       -- 00000000000000000

		zpn.CandyNotify.main = vgui.Create("DPanel")
		zpn.CandyNotify.main:SetPos(zclib.wM * 810, zclib.hM * 390)
		zpn.CandyNotify.main:SetSize(300 * zclib.wM, 300 * zclib.hM)
		zpn.CandyNotify.main:SizeToContentsX(3)
		zpn.CandyNotify.main:SizeToContentsY(3)
		zpn.CandyNotify.main:SetAlpha( 0 )
		zpn.CandyNotify.main:SetPaintBackground( false )

		zpn.CandyNotify.bg = vgui.Create("DPanel", zpn.CandyNotify.main)
		zpn.CandyNotify.bg:Dock(FILL)
		zpn.CandyNotify.bg:SetPaintBackground( false )

		zpn.CandyNotify.candy_img = vgui.Create("DImage", zpn.CandyNotify.bg)
		zpn.CandyNotify.candy_img:SetPos(50 * zclib.wM, 100 * zclib.hM)
		zpn.CandyNotify.candy_img:SetSize(100 * zclib.wM, 100 * zclib.hM)
		zpn.CandyNotify.candy_img:SetImage("zerochain/zpn/ui/zpn_candy.png")

		zpn.CandyNotify.lbl_gain = vgui.Create("DLabel", zpn.CandyNotify.bg)
		zpn.CandyNotify.lbl_gain:SetPos(150 * zclib.wM, 115 * zclib.hM)
		zpn.CandyNotify.lbl_gain:SetSize(150 * zclib.wM, 100 * zclib.hM)
		zpn.CandyNotify.lbl_gain:SetTextColor(zpn.default_colors["violett02"])
		zpn.CandyNotify.lbl_gain:SetFont(zclib.GetFont("zpn_notify_font01"))
		zpn.CandyNotify.lbl_gain:SetContentAlignment(7)
	end

	local LastCandyGain = -1
	local LastGainAmount = -1

	function zpn.Candy.Notify(candy_gain,candy)
                                                                                                                                                                                                                                                                                                                                                                                                                                                       -- ddf04c302d8fd9e30f6a5e9cc4e3787dc09a35f0034528f4b4c268245f97715d

		if zpn.CandyNotify == nil then
			SetupNotify()
		end

		if CurTime() < (LastCandyGain + 0.6) then
			candy_gain = candy_gain + LastGainAmount
		end
                                                                                                                                                                                                                                                                                                                                                                                                                                                       -- 00000000000000000


		zpn.CandyNotify.thunder_panel:Stop()
		zpn.CandyNotify.thunder_panel:SetPos(810 * zclib.wM, 390 * zclib.hM)
		zpn.CandyNotify.thunder_panel:SetSize(300 * zclib.wM, 300 * zclib.hM)
		zpn.CandyNotify.thunder_panel:SetAlpha( 150 )

		zpn.CandyNotify.thunder_panel:AlphaTo( 0, 0.5, 0)
		zpn.CandyNotify.thunder_panel:MoveTo(660 * zclib.wM, 240 * zclib.hM,0.5, 0, -1)
		zpn.CandyNotify.thunder_panel:SizeTo(600 * zclib.wM, 600 * zclib.hM,0.5, 0,-1 )

		zpn.CandyNotify.main:Stop()
		zpn.CandyNotify.main:SetPos(zclib.wM * 810, zclib.hM * 390)
		zpn.CandyNotify.main:SetAlpha( 255 )
		zpn.CandyNotify.main:MoveTo( ScrW() / 2 - zpn.CandyNotify.main:GetWide() / 2, ScrH() / 3 - zpn.CandyNotify.main:GetTall() / 2,1, 0, -1)
		zpn.CandyNotify.main:AlphaTo( 0, 0.6, 0.25)

		if candy_gain > 0 then
			zpn.CandyNotify.candy_img:SetImage("zerochain/zpn/ui/" .. zpn.CandyIcon(candy_gain,50) .. ".png")
			zpn.CandyNotify.thunder_img:SetImageColor(color_white)
			zpn.CandyNotify.lbl_gain:SetText("+" .. candy_gain)
			zpn.CandyNotify.lbl_gain:SetTextColor(zpn.default_colors["green01"])
		else
			zpn.CandyNotify.candy_img:SetImage("zerochain/zpn/ui/" .. zpn.CandyIcon(candy_gain,50) .. ".png")
			zpn.CandyNotify.thunder_img:SetImageColor(zpn.default_colors["red01"])
			zpn.CandyNotify.lbl_gain:SetText(candy_gain)
			zpn.CandyNotify.lbl_gain:SetTextColor(zpn.default_colors["red01"])
		end

		LastCandyGain = CurTime()
		LastGainAmount = candy_gain

		local timerid = "zpn_scorelist_updater"
		zclib.Timer.Remove(timerid)
		zclib.Timer.Create(timerid, 1, 0, function()

			if zpn.CandyNotify and IsValid(zpn.CandyNotify.main) then
				zpn.CandyNotify.main:Remove()
			end

			if zpn.CandyNotify and IsValid(zpn.CandyNotify.thunder_panel) then
				zpn.CandyNotify.thunder_panel:Remove()
			end

			zpn.CandyNotify = nil

			zclib.Timer.Remove(timerid)
		end)
	end
end
