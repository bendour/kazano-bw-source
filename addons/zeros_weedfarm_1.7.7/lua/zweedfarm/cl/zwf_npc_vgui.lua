if not CLIENT then return end

zwf = zwf or {}
zwf.f = zwf.f or {}

local wMod = ScrW() / 1920
local hMod = ScrH() / 1080

local zwf_WeedBuyerMenu = {}
local zwf_WeedBuyerMain = {}

local SELECTED_BONG_ITEM = 1

/////////// General
local function zwf_OpenUI()
	if not IsValid(zwf_WeedBuyerMenu_panel) then

		zwf_WeedBuyerMenu_panel = vgui.Create("zwf_vgui_WeedBuyerMenu")
	end
end

local function zwf_CloseUI()

	if IsValid(zwf_WeedBuyerMenu_panel) then
		zwf_WeedBuyerMenu_panel:Remove()
	end
	LocalPlayer().zwf_WeedBuyer = nil
end
///////////


// This closes the shop interface
net.Receive("zwf_CloseNPC", function(len)
	zwf_CloseUI()
end)


// This opens the NPC interface
net.Receive("zwf_OpenNPC", function(len)

	LocalPlayer().zwf_WeedBuyer = net.ReadEntity()

	zwf_OpenUI()
end)

/////////// Init
function zwf_WeedBuyerMenu:Init()
	self:SetSize(900 * wMod, 300 * hMod)
	self:Center()
	self:MakePopup()
	self:SetTitle("")
	self:SetSizable(false)
	self:SetDraggable(true)
	self:ShowCloseButton(false)

	zwf_WeedBuyer_Main(self)
end

function zwf_WeedBuyerMenu:Paint(w, h)
	draw.RoundedBox(15, 0 , 0, w, h,  zwf.default_colors["gray01"])
end

function zwf_WeedBuyer_Main(parent)

	if (zwf_WeedBuyerMain and IsValid(zwf_WeedBuyerMain.BongShopPanel)) then
		zwf_WeedBuyerMain.BongShopPanel:Remove()
	end


	if (zwf_BongShopList and IsValid(zwf_BongShopList.ProductPanel)) then
		zwf_BongShopList.ProductPanel:Remove()
	end

	if (zwf_WeedBuyerMain and IsValid(zwf_WeedBuyerMain.QuestionPanel)) then
		zwf_WeedBuyerMain.QuestionPanel:Remove()
	end

	zwf_WeedBuyerMain.QuestionPanel = vgui.Create("Panel", parent)
	zwf_WeedBuyerMain.QuestionPanel:SetPos(0 * wMod, 0 * hMod)
	zwf_WeedBuyerMain.QuestionPanel:SetSize(900 * wMod, 300 * hMod)
	zwf_WeedBuyerMain.QuestionPanel.Paint = function(s, w, h)
		//draw.RoundedBox(15, 0 , 0, w, h,  zwf.default_colors["black05"])
	end


	zwf_WeedBuyerMain.Question = vgui.Create("DLabel", zwf_WeedBuyerMain.QuestionPanel)
	zwf_WeedBuyerMain.Question:SetPos(300 * wMod, 25 * hMod)
	zwf_WeedBuyerMain.Question:SetSize(600 * wMod, 50 * hMod)
	zwf_WeedBuyerMain.Question:SetFont(zwf.f.GetFont("zwf_vgui_font12"))
	zwf_WeedBuyerMain.Question:SetText(zwf.language.NPC["question_01"])
	zwf_WeedBuyerMain.Question:SetContentAlignment(7)
	zwf_WeedBuyerMain.Question:SetColor(zwf.default_colors["white01"])

	zwf_WeedBuyerMain.OpenBongShop = vgui.Create("DButton", zwf_WeedBuyerMain.QuestionPanel)
	zwf_WeedBuyerMain.OpenBongShop:SetText("")
	zwf_WeedBuyerMain.OpenBongShop:SetPos(150 * wMod, 162 * hMod)
	zwf_WeedBuyerMain.OpenBongShop:SetSize(850 * wMod, 50 * hMod)
	zwf_WeedBuyerMain.OpenBongShop.DoClick = function()
		surface.PlaySound("UI/buttonclick.wav")
		zwf_WeedBuyer_BongShop(parent)
	end
	zwf_WeedBuyerMain.OpenBongShop.Paint = function(s,w, h)

		draw.RoundedBox(1, 0 , 0, w, h,  zwf.default_colors["black06"])

		if zwf_WeedBuyerMain.OpenBongShop:IsHovered() then
			draw.SimpleTextOutlined(zwf.language.NPC["question_01_answer01"], zwf.f.GetFont("zwf_vgui_font13"), 210 * wMod, 5 * hMod, zwf.default_colors["orange06"], TEXT_ALIGN_LEFT, TEXT_ALIGN_TOP, 2, zwf.default_colors["black02"])
			surface.SetDrawColor(zwf.default_colors["orange06"])
		else
			draw.DrawText(zwf.language.NPC["question_01_answer01"], zwf.f.GetFont("zwf_vgui_font13"), 210 * wMod, 5 * hMod, zwf.default_colors["orange05"], TEXT_ALIGN_LEFT)
			surface.SetDrawColor(zwf.default_colors["orange05"])
		end

		surface.SetMaterial(zwf.default_materials["symbol_bong"])
		surface.DrawTexturedRect(150 * wMod, 1 * hMod, 50 * wMod, 50 * hMod)
	end

	if zwf.f.IsWeedSeller(LocalPlayer()) then
		zwf_WeedBuyerMain.SellWeed = vgui.Create("DButton", zwf_WeedBuyerMain.QuestionPanel)
		zwf_WeedBuyerMain.SellWeed:SetText("")
		zwf_WeedBuyerMain.SellWeed:SetPos(150 * wMod, 100 * hMod)
		zwf_WeedBuyerMain.SellWeed:SetSize(850 * wMod, 50 * hMod)
		zwf_WeedBuyerMain.SellWeed.DoClick = function()
			net.Start("zwf_SellWeed")
			net.WriteEntity(LocalPlayer().zwf_WeedBuyer)
			net.SendToServer()

			surface.PlaySound("UI/buttonclick.wav")
			zwf_CloseUI()
		end
		zwf_WeedBuyerMain.SellWeed.Paint = function(s,w, h)

			draw.RoundedBox(1, 0 , 0, w, h,  zwf.default_colors["black06"])

			if zwf_WeedBuyerMain.SellWeed:IsHovered() then

				draw.SimpleTextOutlined(zwf.language.NPC["question_01_answer02"], zwf.f.GetFont("zwf_vgui_font13"), 210 * wMod, 5 * hMod, zwf.default_colors["green10"], TEXT_ALIGN_LEFT, TEXT_ALIGN_TOP, 2, zwf.default_colors["black02"])
				surface.SetDrawColor(zwf.default_colors["green10"])
			else
				draw.DrawText(zwf.language.NPC["question_01_answer02"], zwf.f.GetFont("zwf_vgui_font13"), 210 * wMod, 5 * hMod, zwf.default_colors["green09"], TEXT_ALIGN_LEFT)
				surface.SetDrawColor(zwf.default_colors["green09"])
			end

			surface.SetMaterial(zwf.default_materials["symbol_weed"])
			surface.DrawTexturedRect(150 * wMod, 1 * hMod, 50 * wMod, 50 * hMod)
		end
	end

	zwf_WeedBuyerMain.close = vgui.Create("DButton", zwf_WeedBuyerMain.QuestionPanel)
	zwf_WeedBuyerMain.close:SetText("")
	zwf_WeedBuyerMain.close:SetPos(150 * wMod, 225 * hMod)
	zwf_WeedBuyerMain.close:SetSize(850 * wMod, 50 * hMod)
	zwf_WeedBuyerMain.close.DoClick = function()
		zwf_CloseUI()
		surface.PlaySound("UI/buttonclick.wav")
	end
	zwf_WeedBuyerMain.close.Paint = function(s,w, h)

		draw.RoundedBox(1, 0 , 0, w, h,  zwf.default_colors["black06"])

		if zwf_WeedBuyerMain.close:IsHovered() then
			draw.SimpleTextOutlined(zwf.language.NPC["question_01_answer03"], zwf.f.GetFont("zwf_vgui_font13"), 210 * wMod, 5 * hMod, zwf.default_colors["red01"], TEXT_ALIGN_LEFT, TEXT_ALIGN_TOP, 2, zwf.default_colors["black02"])
			surface.SetDrawColor(zwf.default_colors["red01"])
		else
			draw.DrawText(zwf.language.NPC["question_01_answer03"], zwf.f.GetFont("zwf_vgui_font13"), 210 * wMod, 5 * hMod, zwf.default_colors["red02"], TEXT_ALIGN_LEFT)
			surface.SetDrawColor(zwf.default_colors["red02"])
		end

		surface.SetMaterial(zwf.default_materials["symbol_cancel"])
		surface.DrawTexturedRect(150 * wMod, 1 * hMod, 50 * wMod, 50 * hMod)
	end

	zwf_WeedBuyerMain.QuestionImg01 = vgui.Create("Panel", zwf_WeedBuyerMain.QuestionPanel)
	zwf_WeedBuyerMain.QuestionImg01:SetPos(0 * wMod, 0 * hMod)
	zwf_WeedBuyerMain.QuestionImg01:SetSize(300 * wMod, 300 * hMod)
	zwf_WeedBuyerMain.QuestionImg01.Paint = function(s, w, h)
		surface.SetDrawColor(zwf.default_colors["white01"])
		surface.SetMaterial(zwf.default_materials["weedbuyer"])
		surface.DrawTexturedRect(0 * wMod, 1 * hMod, w, h)
	end
end

function zwf_WeedBuyer_BongShop(parent)



	if (zwf_WeedBuyerMain and IsValid(zwf_WeedBuyerMain.QuestionPanel)) then
		zwf_WeedBuyerMain.QuestionPanel:Remove()
	end

	if (zwf_WeedBuyerMain and IsValid(zwf_WeedBuyerMain.BongShopPanel)) then
		zwf_WeedBuyerMain.BongShopPanel:Remove()
	end

	zwf_WeedBuyerMain.BongShopPanel = vgui.Create("Panel", parent)
	zwf_WeedBuyerMain.BongShopPanel:SetPos(0 * wMod, 0 * hMod)
	zwf_WeedBuyerMain.BongShopPanel:SetSize(900 * wMod, 300 * hMod)
	zwf_WeedBuyerMain.BongShopPanel.Paint = function(s, w, h)
		//draw.RoundedBox(15, 0 , 0, w, h,  zwf.default_colors["black05"])
	end


	zwf_WeedBuyerMain.BongQuestion = vgui.Create("DLabel", zwf_WeedBuyerMain.BongShopPanel)
	zwf_WeedBuyerMain.BongQuestion:SetPos(300 * wMod, 25 * hMod)
	zwf_WeedBuyerMain.BongQuestion:SetSize(600 * wMod, 50 * hMod)
	zwf_WeedBuyerMain.BongQuestion:SetFont(zwf.f.GetFont("zwf_vgui_font12"))
	zwf_WeedBuyerMain.BongQuestion:SetText(zwf.language.NPC["question_02"])
	zwf_WeedBuyerMain.BongQuestion:SetContentAlignment(7)
	zwf_WeedBuyerMain.BongQuestion:SetColor(zwf.default_colors["white01"])




	zwf_WeedBuyerMain.GoBack = vgui.Create("DButton", zwf_WeedBuyerMain.BongShopPanel)
	zwf_WeedBuyerMain.GoBack:SetText("")
	zwf_WeedBuyerMain.GoBack:SetPos(300 * wMod, 225 * hMod)
	zwf_WeedBuyerMain.GoBack:SetSize(275 * wMod, 50 * hMod)
	zwf_WeedBuyerMain.GoBack.DoClick = function()
		zwf_WeedBuyer_Main(zwf_WeedBuyerMenu_panel)
		surface.PlaySound("UI/buttonclick.wav")
	end
	zwf_WeedBuyerMain.GoBack.Paint = function(s,w, h)

		draw.RoundedBox(5, 0 , 0, w, h,  zwf.default_colors["black06"])

		if zwf_WeedBuyerMain.GoBack:IsHovered() then
			draw.SimpleTextOutlined(zwf.language.NPC["question_02_answer01"], zwf.f.GetFont("zwf_vgui_font13"), 137 * wMod, 5 * hMod, zwf.default_colors["red01"], TEXT_ALIGN_CENTER, TEXT_ALIGN_TOP, 2, zwf.default_colors["black02"])
		else
			draw.DrawText(zwf.language.NPC["question_02_answer01"], zwf.f.GetFont("zwf_vgui_font13"), 137 * wMod, 5 * hMod, zwf.default_colors["red02"], TEXT_ALIGN_CENTER)
		end
	end


	zwf_WeedBuyerMain.BuyBong = vgui.Create("DButton", zwf_WeedBuyerMain.BongShopPanel)
	zwf_WeedBuyerMain.BuyBong:SetText("")
	zwf_WeedBuyerMain.BuyBong:SetPos(600 * wMod, 225 * hMod)
	zwf_WeedBuyerMain.BuyBong:SetSize(275 * wMod, 50 * hMod)
	zwf_WeedBuyerMain.BuyBong.DoClick = function()
		if SELECTED_BONG_ITEM and SELECTED_BONG_ITEM > 0 then

			net.Start("zwf_BuyBong")
			net.WriteInt(SELECTED_BONG_ITEM, 16)
			net.WriteEntity(LocalPlayer().zwf_WeedBuyer)
			net.SendToServer()
			surface.PlaySound("UI/buttonclick.wav")
			zwf_CloseUI()
		end
	end
	zwf_WeedBuyerMain.BuyBong.Paint = function(s,w, h)

		draw.RoundedBox(5, 0 , 0, w, h,  zwf.default_colors["black06"])

		if zwf_WeedBuyerMain.BuyBong:IsHovered() then
			draw.SimpleTextOutlined(zwf.language.VGUI["Purchase"], zwf.f.GetFont("zwf_vgui_font13"), 137 * wMod, 5 * hMod, zwf.default_colors["green10"], TEXT_ALIGN_CENTER, TEXT_ALIGN_TOP, 2, zwf.default_colors["black02"])
		else
			draw.DrawText(zwf.language.VGUI["Purchase"], zwf.f.GetFont("zwf_vgui_font13"), 137 * wMod, 5 * hMod, zwf.default_colors["green09"], TEXT_ALIGN_CENTER)
		end
	end

	zwf_WeedBuyerMain.QuestionImg02 = vgui.Create("Panel", zwf_WeedBuyerMain.BongShopPanel)
	zwf_WeedBuyerMain.QuestionImg02:SetPos(0 * wMod, 0 * hMod)
	zwf_WeedBuyerMain.QuestionImg02:SetSize(300 * wMod, 300 * hMod)
	zwf_WeedBuyerMain.QuestionImg02.Paint = function(s, w, h)
		surface.SetDrawColor(zwf.default_colors["white01"])
		surface.SetMaterial(zwf.default_materials["weedbuyer"])
		surface.DrawTexturedRect(0 * wMod, 1 * hMod, w, h)
	end
	zwf_BongList(zwf_WeedBuyerMain.BongShopPanel)
end


function zwf_AddBongShopItem(i)

	local itemData = zwf.config.Bongs.items[i]

	zwf_BongItems[i] = zwf_BongItems.list:Add("DPanel")
	zwf_BongItems[i]:SetSize(115 * wMod, 115 * hMod)
	zwf_BongItems[i]:SetAutoDelete(true)
	zwf_BongItems[i].Paint = function(self, w, h)

		if i == SELECTED_BONG_ITEM then
			draw.RoundedBox(1, 0, 0, w, h, zwf.default_colors["green08"])
		else
			draw.RoundedBox(1, 0, 0, w, h, zwf.default_colors["black05"])
		end

		surface.SetDrawColor(255, 255, 255, 7)
		surface.SetMaterial(zwf.default_materials["button_shine"])
		surface.DrawTexturedRect(-5 * wMod, -5 * hMod, w, h)
	end


	zwf_BongItems[i].ItemModel = vgui.Create("DModelPanel", zwf_BongItems[i])
	zwf_BongItems[i].ItemModel:SetSize(zwf_BongItems[i]:GetWide(), zwf_BongItems[i]:GetTall())
	zwf_BongItems[i].ItemModel:SetPos(0 * wMod, 0 * hMod)
	zwf_BongItems[i].ItemModel:SetModel(itemData.model)
	zwf_BongItems[i].ItemModel:SetAutoDelete(true)
	zwf_BongItems[i].ItemModel:SetColor(zwf.default_colors["white01"])
	zwf_BongItems[i].ItemModel.LayoutEntity = function(self)

		local ang = Angle(0, 45 * RealTime(), 0)

		self.Entity:SetAngles(ang)
		local size1, size2 = self.Entity:GetRenderBounds()
		local size = (-size1 + size2):Length()
		self:SetFOV(40)
		self:SetCamPos(Vector(size * 1, size * 1, size * 1))
		self:SetLookAt(self.Entity:GetPos() + Vector(0, 0, 0.43 * size))
	end

	zwf_BongItems[i].ItemNamePanel = vgui.Create("DPanel", zwf_BongItems[i])
	zwf_BongItems[i].ItemNamePanel:SetPos(0 * wMod, 0 * hMod)
	zwf_BongItems[i].ItemNamePanel:SetSize(zwf_BongItems[i]:GetWide(), 30 * hMod)
	zwf_BongItems[i].ItemNamePanel.Paint = function(s, w, h)
		surface.SetDrawColor(zwf.default_colors["black03"])
		surface.SetMaterial(zwf.default_materials["shadow_gradient"])
		surface.DrawTexturedRect(0, 0, w, h)
	end

	zwf_BongItems[i].ItemName = vgui.Create("DLabel", zwf_BongItems[i].ItemNamePanel)
	zwf_BongItems[i].ItemName:SetPos(10 * wMod, 5 * hMod)
	zwf_BongItems[i].ItemName:SetSize(300 * wMod, 125 * hMod)
	zwf_BongItems[i].ItemName:SetFont(zwf.f.GetFont("zwf_vgui_font08"))
	zwf_BongItems[i].ItemName:SetText(itemData.name)
	zwf_BongItems[i].ItemName:SetColor(zwf.default_colors["white01"])
	zwf_BongItems[i].ItemName:SetAutoDelete(true)
	zwf_BongItems[i].ItemName:SetContentAlignment(7)

	zwf_BongItems[i].ItemPrice = vgui.Create("DLabel", zwf_BongItems[i])
	zwf_BongItems[i].ItemPrice:SetPos( 5 * wMod, 90 * hMod)
	zwf_BongItems[i].ItemPrice:SetSize(300 * wMod, 125 * hMod)
	zwf_BongItems[i].ItemPrice:SetFont(zwf.f.GetFont("zwf_vgui_font09"))
	zwf_BongItems[i].ItemPrice:SetText(zwf.config.Currency .. itemData.price)
	zwf_BongItems[i].ItemPrice:SetColor(zwf.default_colors["white01"])
	zwf_BongItems[i].ItemPrice:SetAutoDelete(true)
	zwf_BongItems[i].ItemPrice:SetContentAlignment(7)

	zwf_BongItems[i].button = vgui.Create("DButton", zwf_BongItems[i])
	zwf_BongItems[i].button:SetPos(0 * wMod, 0 * hMod)
	zwf_BongItems[i].button:SetSize(zwf_BongItems[i]:GetWide(), zwf_BongItems[i]:GetTall())
	zwf_BongItems[i].button:SetText("")
	zwf_BongItems[i].button:SetAutoDelete(true)
	zwf_BongItems[i].button.Paint = function(self, w, h)
		if zwf_BongItems[i].button:IsHovered() then
			draw.RoundedBox(5, 0, 0, w, h, zwf.default_colors["white03"])
		end
	end
	zwf_BongItems[i].button.DoClick = function()
		SELECTED_BONG_ITEM = i
		surface.PlaySound("UI/buttonclick.wav")
	end
end

function zwf_BongList(parent)

	if (zwf_BongShopList and IsValid(zwf_BongShopList.ProductPanel)) then
		zwf_BongShopList.ProductPanel:Remove()
	end

	zwf_BongShopList = {}

	zwf_BongShopList.ProductPanel = vgui.Create("Panel", parent)
	zwf_BongShopList.ProductPanel:SetPos(300 * wMod, 85 * hMod)
	zwf_BongShopList.ProductPanel:SetSize(700 * wMod, 115 * hMod)
	zwf_BongShopList.ProductPanel.Paint = function(s, w, h)
		draw.RoundedBox(1, 0 , 0, w, h,  zwf.default_colors["black07"])
	end

	zwf_BongShopList.scrollpanel = vgui.Create("DScrollPanel", zwf_BongShopList.ProductPanel)
	zwf_BongShopList.scrollpanel:DockMargin(-15 * wMod, -15 * hMod, 0 * wMod, 0 * hMod)
	zwf_BongShopList.scrollpanel:Dock(FILL)
	local sbar01 = zwf_BongShopList.scrollpanel:GetVBar()
	function sbar01:Paint( w, h )
		//draw.RoundedBox( 0, 0, 0, w, h, zwf.default_colors["black06"] )
	end
	function sbar01.btnUp:Paint( w, h )
		//draw.RoundedBox( 5, 0, 0, w, h, zwf.default_colors["black01"] )
	end
	function sbar01.btnDown:Paint( w, h )
		//draw.RoundedBox( 5, 0, 0, w, h, zwf.default_colors["black01"] )
	end
	function sbar01.btnGrip:Paint( w, h )
		//draw.RoundedBox( 5, 0, 0, w, h, zwf.default_colors["white05"] )
	end
	zwf_BongShopList.scrollpanel.Paint = function(self, w, h)
	end


	// Here we create the product items
	if (zwf_BongItems and IsValid(zwf_BongItems.list)) then
		zwf_BongItems.list:Remove()
	end

	zwf_BongItems = {}
	zwf_BongItems.list = vgui.Create("DIconLayout", zwf_BongShopList.scrollpanel)
	zwf_BongItems.list:SetSize(800 * wMod, 200 * hMod)
	zwf_BongItems.list:SetPos(15 * wMod, 15 * hMod)
	zwf_BongItems.list:SetSpaceX(10)
	zwf_BongItems.list:SetAutoDelete(true)

	for i = 1,table.Count(zwf.config.Bongs.items) do
		zwf_AddBongShopItem(i)
	end
end


vgui.Register("zwf_vgui_WeedBuyerMenu", zwf_WeedBuyerMenu, "DFrame")
