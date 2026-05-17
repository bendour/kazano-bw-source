if not CLIENT then return end

zwf = zwf or {}
zwf.vgui = zwf.vgui or {}

local wMod = ScrW() / 1920
local hMod = ScrH() / 1080

local zwf_ShopMenu = {}
local zwf_ShopMain = {}


local SELECTED_ITEM = 1
local SELECTED_CATERGORY = 1
local SELECTED_TIME = 1

/////////// General
local function zwf_OpenUI()
	if not IsValid(zwf_ShopMenu_panel) then

		zwf_ShopMenu_panel = vgui.Create("zwf_vgui_ShopMenu")
	end
end

local function zwf_CloseUI()

	if IsValid(zwf_ShopMenu_panel) then
		zwf_ShopMenu_panel:Remove()
	end
end
///////////



// This closes the shop interface
net.Receive("zwf_Shop_Close_net", function(len)
	zwf_CloseUI()
end)

// This opens the shop interface
net.Receive("zwf_Shop_Open_net", function(len)
	zwf_OpenUI()
end)


//////////// Util
function zwf.vgui.CreateModelPanel(data)
	local model_pnl = vgui.Create("DModelPanel")
	model_pnl:SetPos(0 * wMod, 0 * hMod)
	model_pnl:SetSize(50 * wMod, 50 * hMod)
	model_pnl:SetVisible(false)
	model_pnl:SetAutoDelete(true)
	model_pnl.LayoutEntity = function(self) end
	model_pnl:SetAmbientLight(Color(125, 125,125, 255))

	if data and data.model then

		model_pnl:SetModel(data.model)

		local min, max = model_pnl.Entity:GetRenderBounds()
		local size = 0
		size = math.max(size, math.abs(min.x) + math.abs(max.x))
		size = math.max(size, math.abs(min.y) + math.abs(max.y))
		size = math.max(size, math.abs(min.z) + math.abs(max.z))


		local rData = data.render

		local FOV = 35
		local x = 0
		local y = 0
		local z = 0
		local ang = Angle(0, 25, 0)
		local pos = Vector(0, 0, 0)

		if rData then
			FOV = rData.FOV or 35
			x = rData.X or 0
			y = rData.Y or 0
			z = rData.Z or 0
			ang = rData.Angles or Angle(0, 0, 0)
			pos = rData.Pos or Vector(0, 0, 0)
		end

		model_pnl:SetFOV(FOV)
		model_pnl:SetCamPos(Vector(size + x, size + 30 + y, size + 5 + z))
		model_pnl:SetLookAt((min + max) * 0.5)

		if ang then
			model_pnl.Entity:SetAngles(ang)
		end

		if pos then
			model_pnl.Entity:SetPos(pos)
		end

		if data.color then
			model_pnl:SetColor(data.color)
		end

		if data.skin then
			model_pnl.Entity:SetSkin(data.skin)
		end

		if data.material then
			model_pnl.Entity:SetMaterial(data.material)
		end

		model_pnl:SetVisible(true)
	end

	return model_pnl
end


/////////// Init
function zwf_ShopMenu:Init()
	self:SetSize(1384 * wMod, 830 * hMod)
	self:Center()

	self:MakePopup(false)

	self:SetKeyboardInputEnabled()
	self:SetMouseInputEnabled(true)

	/*
	self:SetDraggable(true)
	self:SetSizable(false)
	self:ShowCloseButton(false)
	self:SetTitle("")
	*/

	zwf_ShopMain.Title = vgui.Create("DLabel", self)
	zwf_ShopMain.Title:SetPos(195 * wMod, 80 * hMod)
	zwf_ShopMain.Title:SetSize(600 * wMod, 125 * hMod)
	zwf_ShopMain.Title:SetFont(zwf.f.GetFont("zwf_vgui_font03"))
	zwf_ShopMain.Title:SetText(zwf.language.Shop["title"])
	zwf_ShopMain.Title:SetColor(zwf.default_colors["white01"])

	zwf_ShopMain.close = vgui.Create("DButton", self)
	zwf_ShopMain.close:SetText("")
	zwf_ShopMain.close:SetPos(1140 * wMod, 115 * hMod)
	zwf_ShopMain.close:SetSize(50 * wMod, 50 * hMod)
	zwf_ShopMain.close.DoClick = function()
		zwf_CloseUI()
	end
	zwf_ShopMain.close.Paint = function(s,w, h)


		if zwf_ShopMain.close:IsHovered() then
			draw.RoundedBox(10, 0 , 0, w, h,  zwf.default_colors["black03"])
		else
			draw.RoundedBox(10, 0 , 0, w, h,  zwf.default_colors["black06"])
		end



		if zwf_ShopMain.close:IsHovered() then
			draw.DrawText("X", zwf.f.GetFont("zwf_vgui_font03"), 25 * wMod, 4 * hMod, zwf.default_colors["white01"], TEXT_ALIGN_CENTER)
		else
			draw.DrawText("X", zwf.f.GetFont("zwf_vgui_font03"), 25 * wMod, 4 * hMod, zwf.default_colors["black06"], TEXT_ALIGN_CENTER)
		end
	end



	zwf_ProductCategoryButtons(self)

	zwf_ProductList(self)

	zwf_ProductPanel(self)
end

function zwf_ShopMenu:Paint(w, h)
	//draw.RoundedBox(15, 0 , 0, w, h,  zwf.default_colors["gray01"])

	surface.SetDrawColor(255,255,255,255)
	surface.SetMaterial(zwf.default_materials["tablet_interface"])
	surface.DrawTexturedRect(0, 0, w, h)
end

function zwf_ProductCategoryButtons(parent)
	zwf_ShopMain.ButtonPanel = vgui.Create("Panel", parent)
	zwf_ShopMain.ButtonPanel:SetPos(187 * wMod, 170 * hMod)
	zwf_ShopMain.ButtonPanel:SetSize(1010 * wMod, 50 * hMod)
	zwf_ShopMain.ButtonPanel.Paint = function(s, w, h)
		surface.SetDrawColor(0,0,0, 125)
		surface.SetMaterial(zwf.default_materials["square"])
		surface.DrawTexturedRect(0, 0, w, h)
	end

	zwf_ShopMain.ButtonList = vgui.Create("DIconLayout", zwf_ShopMain.ButtonPanel)
	zwf_ShopMain.ButtonList:SetSize(1000 * wMod, 50 * hMod)
	zwf_ShopMain.ButtonList:SetPos(15 * wMod, 0 * hMod)
	zwf_ShopMain.ButtonList:SetSpaceX(10)
	zwf_ShopMain.ButtonList:SetAutoDelete(true)
	zwf_ShopMain.ButtonList.Paint = function(self, w, h)
	end


	zwf_ProductCategory = {}
	local shopData = zwf.config.Shop
	for i = 1, table.Count(shopData) do
		zwf_ProductCategory[i] = zwf_ShopMain.ButtonList:Add("DButton")
		zwf_ProductCategory[i]:SetText("")
		zwf_ProductCategory[i]:SetSize(200 * wMod,zwf_ShopMain.ButtonList:GetTall())
		zwf_ProductCategory[i]:SetVisible(true)
		zwf_ProductCategory[i].DoClick = function()
			SELECTED_CATERGORY = i
			SELECTED_ITEM = 1

			zwf_ProductList(parent)
			zwf_ProductPanel(parent)
			surface.PlaySound("UI/buttonclick.wav")
		end

		zwf_ProductCategory[i].Paint = function(s, w, h)
			if i == SELECTED_CATERGORY then
				draw.RoundedBox(5, 0 , 0, w, h,  zwf.default_colors["red06"])
			else
				if zwf_ProductCategory[i]:IsHovered() then
					draw.RoundedBox(5, 0 , 0, w, h,  zwf.default_colors["black06"])
				else
					draw.RoundedBox(5, 0 , 0, w, h,  zwf.default_colors["black03"])

				end
			end

			surface.SetFont(zwf.f.GetFont("zwf_vgui_font01"))

			local text = shopData[i].title
			local tw, th = surface.GetTextSize(text)
			surface.SetTextPos(100 * wMod - (tw / 2), 26 * hMod - (th / 2))
			surface.SetTextColor(255, 255, 255, 255)
			surface.DrawText(text)
		end
	end
end

function zwf_ProductList(parent)

	local ItemsData = zwf.config.Shop[SELECTED_CATERGORY]

	if (zwf_MainShopList and IsValid(zwf_MainShopList.ProductPanel)) then
		zwf_MainShopList.ProductPanel:Remove()
	end

	zwf_MainShopList = {}

	zwf_MainShopList.ProductPanel = vgui.Create("Panel", parent)
	zwf_MainShopList.ProductPanel:SetPos(187 * wMod, 241 * hMod)
	zwf_MainShopList.ProductPanel:SetSize(300 * wMod, 478 * hMod)
	zwf_MainShopList.ProductPanel.Paint = function(s, w, h)
		surface.SetDrawColor(0, 0 ,0, 125)
		surface.SetMaterial(zwf.default_materials["square"])
		surface.DrawTexturedRect(0, 0, w, h)
	end

	zwf_MainShopList.scrollpanel = vgui.Create("DScrollPanel", zwf_MainShopList.ProductPanel)
	zwf_MainShopList.scrollpanel:DockMargin(0 * wMod, 0 * hMod, 15 * wMod, 0 * hMod)
	zwf_MainShopList.scrollpanel:Dock(FILL)
	local sbar01 = zwf_MainShopList.scrollpanel:GetVBar()
	function sbar01:Paint( w, h )
		draw.RoundedBox( 0, 0, 0, w, h, zwf.default_colors["black06"] )
	end
	function sbar01.btnUp:Paint( w, h )
		draw.RoundedBox( 5, 0, 0, w, h, zwf.default_colors["black01"] )
	end
	function sbar01.btnDown:Paint( w, h )
		draw.RoundedBox( 5, 0, 0, w, h, zwf.default_colors["black01"] )
	end
	function sbar01.btnGrip:Paint( w, h )
		draw.RoundedBox( 5, 0, 0, w, h, zwf.default_colors["white05"] )
	end
	zwf_MainShopList.scrollpanel.Paint = function(self, w, h)
	end


	// Here we create the product items
	if (zwf_ShopItems and IsValid(zwf_ShopItems.list)) then
		zwf_ShopItems.list:Remove()
	end

	zwf_ShopItems = {}
	zwf_ShopItems.list = vgui.Create("DIconLayout", zwf_MainShopList.scrollpanel)
	zwf_ShopItems.list:SetSize(240 * wMod, 200 * hMod)
	zwf_ShopItems.list:SetPos(15 * wMod, 15 * hMod)
	zwf_ShopItems.list:SetSpaceY(10)
	zwf_ShopItems.list:SetAutoDelete(true)

	for i = 1, table.Count(ItemsData.items) do

		local itemData = ItemsData.items[i]

		if itemData.class == "zwf_palette" and zwf.config.NPC.SellMode == 2 then return end

		zwf_ShopItems[i] = zwf_ShopItems.list:Add("DPanel")
		zwf_ShopItems[i]:SetSize(zwf_ShopItems.list:GetWide(), 50 * hMod)
		zwf_ShopItems[i]:SetAutoDelete(true)
		zwf_ShopItems[i].Paint = function(self, w, h)
		end


		zwf_ShopItems[i].button = vgui.Create("DButton", zwf_ShopItems[i])
		zwf_ShopItems[i].button:SetPos(0 * wMod, 0 * hMod)
		zwf_ShopItems[i].button:SetSize(zwf_ShopItems.list:GetWide(), 50 * hMod)
		zwf_ShopItems[i].button:SetText("")
		zwf_ShopItems[i].button:SetAutoDelete(true)
		zwf_ShopItems[i].button.Paint = function(self, w, h)

			if i == SELECTED_ITEM then
				draw.RoundedBox(5, 0, 0, w, h, zwf.default_colors["orange04"])
			else
				if zwf_ShopItems[i].button:IsHovered() then
					draw.RoundedBox(5, 0, 0, w, h, zwf.default_colors["black08"])
				else
					draw.RoundedBox(5, 0, 0, w, h, zwf.default_colors["black09"])
				end
			end
		end
		zwf_ShopItems[i].button.DoClick = function()
			SELECTED_ITEM = i

			if zwf_ShopMain and IsValid(zwf_ShopMain.Buy) then
				zwf_ShopMain.Buy:SetVisible(true)
			end

			if SELECTED_ITEM then
				// Call function that recreates the zwf_ShopMain.ProductInfoPanel panel and fill it with product data

				zwf_ProductPanel(parent)
			end

			surface.PlaySound("UI/buttonclick.wav")
		end

		local name

		local mdl_data = {}


		if SELECTED_CATERGORY == 3 then

			local nutDat = zwf.config.Nutrition[itemData.nutid]
			name = nutDat.name

			mdl_data.model = "models/zerochain/props_weedfarm/zwf_nutritionbottle.mdl"
			mdl_data.skin = nutDat.skin
			mdl_data.render = {
				FOV = 20,
				X = 0,
				Y = 0,
				Z = 0,
				Angles = Angle(0, 45, 0),
				Pos = Vector(0, 0, 0)
			}
		elseif SELECTED_CATERGORY == 2 then

			local plantDat = zwf.config.Plants[itemData.seedid]
			mdl_data.model = "models/zerochain/props_weedfarm/zwf_weedseed.mdl"
			mdl_data.skin = plantDat.skin
			mdl_data.render = {
				FOV = 20,
				X = 0,
				Y = 0,
				Z = 0,
				Angles = Angle(0, 0, -90),
				Pos = Vector(0, 0, 0)
			}

			name = plantDat.name
		else

			mdl_data.model = itemData.model
			mdl_data.render = {
				FOV = 35,
				X = 0,
				Y = 0,
				Z = 15,
				Angles = Angle(0, 0, 0),
				Pos = Vector(0, 0, 0)
			}
			if itemData.class == "zwf_lamp" then

				name = zwf.config.Lamps[itemData.lampid].name
			else

				name = itemData.name
			end
		end

		zwf_ShopItems[i].Icon = zwf.vgui.CreateModelPanel(mdl_data)
		zwf_ShopItems[i].Icon:SetParent(zwf_ShopItems[i])
		zwf_ShopItems[i].Icon:SetPos(0 * wMod, 0 * hMod)
		zwf_ShopItems[i].Icon:SetSize(50 * wMod, 50 * hMod)
		zwf_ShopItems[i].Icon:SetAutoDelete(true)

		zwf_ShopItems[i].ItemName = vgui.Create("DLabel", zwf_ShopItems[i].button)
		zwf_ShopItems[i].ItemName:SetPos(60 * wMod, 0 * hMod)
		zwf_ShopItems[i].ItemName:SetSize(200 * wMod, 50 * hMod)
		zwf_ShopItems[i].ItemName:SetFont(zwf.f.GetFont("zwf_vgui_font02"))
		zwf_ShopItems[i].ItemName:SetText(name)
		zwf_ShopItems[i].ItemName:SetColor(zwf.default_colors["white01"])
		zwf_ShopItems[i].ItemName:SetAutoDelete(true)
		zwf_ShopItems[i].ItemName:SetContentAlignment(4)
	end
end

function zwf_ProductPanel(parent)

	if zwf_ShopMain and IsValid(zwf_ShopMain.ProductInfoPanel) then
		zwf_ShopMain.ProductInfoPanel:Remove()
	end

	zwf_ShopMain.ProductInfoPanel = vgui.Create("Panel", parent)
	zwf_ShopMain.ProductInfoPanel:SetPos(508 * wMod, 241 * hMod)
	zwf_ShopMain.ProductInfoPanel:SetSize(685 * wMod, 480 * hMod)
	zwf_ShopMain.ProductInfoPanel.Paint = function(s, w, h)
		surface.SetDrawColor(0, 0, 0, 125)
		surface.SetMaterial(zwf.default_materials["square"])
		surface.DrawTexturedRect(0, 0, w, h)
	end

	zwf_ShopMain.Buy = vgui.Create("DButton", zwf_ShopMain.ProductInfoPanel)
	zwf_ShopMain.Buy:SetText("")
	zwf_ShopMain.Buy:SetPos(15 * wMod, 370 * hMod)
	zwf_ShopMain.Buy:SetSize(350 * wMod, 100 * hMod)
	zwf_ShopMain.Buy:SetVisible(true)
	zwf_ShopMain.Buy.DoClick = function()

		if SELECTED_ITEM and SELECTED_TIME < CurTime() then

			net.Start("zwf_Shop_Buy_net")
			net.WriteInt(SELECTED_ITEM, 16)
			net.WriteUInt( SELECTED_CATERGORY , 4 )
			net.SendToServer()

			SELECTED_TIME = CurTime() + 0.5
		end
	end
	zwf_ShopMain.Buy.Paint = function(s,w, h)
		if zwf_ShopMain.Buy:IsHovered() then
			surface.SetDrawColor(zwf.default_colors["green06"])
		else
			surface.SetDrawColor(zwf.default_colors["green02"])
		end

		surface.SetMaterial(zwf.default_materials["button_wide"])
		surface.DrawTexturedRect(0, 0, w, h)


		if zwf_ShopMain.Buy:IsHovered() then
			draw.DrawText(zwf.language.VGUI["Purchase"], zwf.f.GetFont("zwf_vgui_font07"), 175 * wMod, 20 * hMod, zwf.default_colors["white01"], TEXT_ALIGN_CENTER)
		else
			draw.DrawText(zwf.language.VGUI["Purchase"], zwf.f.GetFont("zwf_vgui_font07"), 175 * wMod, 20 * hMod, zwf.default_colors["black06"], TEXT_ALIGN_CENTER)
		end
	end

	local productData = zwf.config.Shop[SELECTED_CATERGORY].items[SELECTED_ITEM]
	local EntData
	local product_name
	local product_model

	if SELECTED_CATERGORY == 2 then
		EntData = zwf.config.Plants[productData.seedid]
		product_name = EntData.name
		product_model = "models/zerochain/props_weedfarm/zwf_weedseed.mdl"
	elseif SELECTED_CATERGORY == 3 then
		EntData = zwf.config.Nutrition[productData.nutid]
		product_name = EntData.name
		product_model = productData.model
	else
		if productData.class == "zwf_lamp" then
			product_name = zwf.config.Lamps[productData.lampid].name
			product_model = zwf.config.Lamps[productData.lampid].model
		else
			product_name = productData.name
			product_model = productData.model
		end
	end

	zwf_ShopMain.product_ModelPanel = vgui.Create("Panel", zwf_ShopMain.ProductInfoPanel)
	zwf_ShopMain.product_ModelPanel:SetPos(15 * wMod, 15 * hMod)
	zwf_ShopMain.product_ModelPanel:SetSize(350 * wMod, 350 * hMod)
	zwf_ShopMain.product_ModelPanel.Paint = function(s, w, h)
		surface.SetDrawColor(0, 0, 0, 55)
		surface.SetMaterial(zwf.default_materials["square"])
		surface.DrawTexturedRect(0, 0, w, h)

		surface.SetDrawColor(0, 0, 0, 255)
		surface.SetMaterial(zwf.default_materials["shadow_square"])
		surface.DrawTexturedRect(0, 0, w, h)
	end

	zwf_ShopMain.product_Model = vgui.Create("DModelPanel", zwf_ShopMain.product_ModelPanel)
	zwf_ShopMain.product_Model:SetSize(zwf_ShopMain.product_ModelPanel:GetWide(), zwf_ShopMain.product_ModelPanel:GetTall())
	zwf_ShopMain.product_Model:SetPos(0 * wMod, 0 * hMod)
	zwf_ShopMain.product_Model:SetModel(product_model)
	zwf_ShopMain.product_Model:SetAutoDelete(true)
	zwf_ShopMain.product_Model:SetColor(zwf.default_colors["white01"])
	zwf_ShopMain.product_Model.LayoutEntity = function(self)
		local offset = 1
		local PosZ = 0
		local ang
		if SELECTED_CATERGORY == 3 then
			PosZ = 3
			self.Entity:SetSkin(EntData.skin)
			ang = Angle(0, 45 - 45 * math.cos(RealTime()), 0)
		elseif SELECTED_CATERGORY == 2 then
			self.Entity:SetSkin(EntData.skin)
			ang = Angle(180, 45 * RealTime(), 90)
			offset = 0.8
			PosZ = -1
		elseif SELECTED_CATERGORY == 1 and productData.class == "zwf_lamp" then

			ang = Angle(90, 45 * RealTime(), 180)
			offset = 0.8
			PosZ = -3

		elseif SELECTED_CATERGORY == 1 and productData.class == "zwf_ventilator" then

			ang = Angle(0, 45 * RealTime(), 0)
			offset = 1
			PosZ = 30

		elseif productData.class == "zwf_splice_lab" then

			ang = Angle(0, 45 * RealTime(), 0)
			offset = 1
			PosZ = 25
		else
			ang = Angle(0, 45 * RealTime(), 0)
		end



		self.Entity:SetAngles(ang)
		local size1, size2 = self.Entity:GetRenderBounds()
		local size = (-size1 + size2):Length()
		self:SetFOV(35 * offset)
		self:SetCamPos(Vector(size * 1, size * 1, size * 1))
		self:SetLookAt(self.Entity:GetPos() + Vector(0, 0, 0.1 * size + PosZ))
	end



	zwf_ShopMain.product_ModelInfoPanel = vgui.Create("Panel", zwf_ShopMain.ProductInfoPanel)
	zwf_ShopMain.product_ModelInfoPanel:SetPos(15 * wMod, 15 * hMod)
	zwf_ShopMain.product_ModelInfoPanel:SetSize(350 * wMod, 50 * hMod)
	zwf_ShopMain.product_ModelInfoPanel.Paint = function(s, w, h)
		surface.SetDrawColor(0, 0, 0, 100)
		surface.SetMaterial(zwf.default_materials["square"])
		surface.DrawTexturedRect(0, 0, w, h)
	end

	zwf_ShopMain.product_Name = vgui.Create("DLabel", zwf_ShopMain.product_ModelInfoPanel)
	zwf_ShopMain.product_Name:SetPos(10 * wMod, 10 * hMod)
	zwf_ShopMain.product_Name:SetSize(300 * wMod, 50 * hMod)
	zwf_ShopMain.product_Name:SetFont(zwf.f.GetFont("zwf_vgui_font05"))
	zwf_ShopMain.product_Name:SetText(product_name)
	zwf_ShopMain.product_Name:SetColor(zwf.default_colors["white01"])
	zwf_ShopMain.product_Name:SetAutoDelete(true)
	zwf_ShopMain.product_Name:SetContentAlignment(7)

	zwf_ShopMain.product_Price = vgui.Create("DLabel", zwf_ShopMain.product_ModelPanel)
	zwf_ShopMain.product_Price:SetPos(-10 * wMod, 310 * hMod)
	zwf_ShopMain.product_Price:SetSize(350 * wMod, 60 * hMod)
	zwf_ShopMain.product_Price:SetFont(zwf.f.GetFont("zwf_vgui_font06"))
	zwf_ShopMain.product_Price:SetText(BaseWars:FormatMoney(productData.price))
	zwf_ShopMain.product_Price:SetColor(zwf.default_colors["green06"])
	zwf_ShopMain.product_Price:SetAutoDelete(true)
	zwf_ShopMain.product_Price:SetContentAlignment(9)




	zwf_ShopMain.product_InfoPanel = vgui.Create("Panel", zwf_ShopMain.ProductInfoPanel)
	zwf_ShopMain.product_InfoPanel:SetPos(375 * wMod, 15 * hMod)
	zwf_ShopMain.product_InfoPanel:SetSize(300 * wMod, 452 * hMod)
	zwf_ShopMain.product_InfoPanel:DockPadding( 10 * wMod,10 * hMod, 10 * wMod, 10 * hMod )
	zwf_ShopMain.product_InfoPanel.Paint = function(s, w, h)
		draw.RoundedBox(5, 0 , 0, w, h,  zwf.default_colors["black05"])
	end


	zwf_ShopMain.product_Desc = vgui.Create("DLabel", zwf_ShopMain.product_InfoPanel)
	zwf_ShopMain.product_Desc:SetPos(10 * wMod, 10 * hMod)
	zwf_ShopMain.product_Desc:SetSize(280 * wMod, 125 * hMod)
	zwf_ShopMain.product_Desc:Dock(TOP)
	zwf_ShopMain.product_Desc:SetFont(zwf.f.GetFont("zwf_vgui_font02"))
	zwf_ShopMain.product_Desc:SetText(productData.desc)
	zwf_ShopMain.product_Desc:SetColor(zwf.default_colors["white01"])
	zwf_ShopMain.product_Desc:SetAutoDelete(true)
	zwf_ShopMain.product_Desc:SetWrap(true)
	zwf_ShopMain.product_Desc:SetContentAlignment(7)
	zwf_ShopMain.product_Desc.Paint = function(s, w, h)
		//draw.RoundedBox(8, 0 , 0, w, h,  zwf.default_colors["black05"])
	end


	zwf_ProductDataItems = {}

	local productDataInfo = {}
	if SELECTED_CATERGORY == 2 then

		local seedData = zwf.config.Plants[productData.seedid]

		productDataInfo = {
			[1] = zwf.language.VGUI["Duration"] .. ": " .. seedData.Grow.Duration .. "s",
			[2] = zwf.language.VGUI["Difficulty"] .. ": " .. seedData.Grow.Difficulty,
			[3] = zwf.language.VGUI["HarvestAmount"] .. ": " .. seedData.Grow.MaxYieldAmount .. zwf.config.UoW,
			[4] = zwf.language.General["THC"] .. ": " .. seedData.thc_level .. "%"
		}
	elseif SELECTED_CATERGORY == 3 then

		local nutData = zwf.config.Nutrition[productData.nutid]

		for k, v in pairs(nutData.boost) do
			local boost = "nil"

			if v.b_type == 1 then
				boost = zwf.language.General["Speed"] .. ": +" .. v.b_amount .. "%"
			elseif v.b_type == 2 then
				boost = zwf.language.General["Productivity"] .. ": +" .. v.b_amount .. "%"
			elseif v.b_type == 3 then
				boost = zwf.language.General["AntiPlague"] .. ": +" .. v.b_amount .. "%"
			end

			table.insert(productDataInfo,boost)
		end
	elseif SELECTED_CATERGORY == 1 and productData.class == "zwf_lamp"  then

		local lampData = zwf.config.Lamps[productData.lampid]

		productDataInfo = {
			[1] = zwf.language.VGUI["PowerUsage"] .. ": " .. lampData.Power_usage,
			[2] = zwf.language.VGUI["HeatProduction"] .. ": " .. lampData.Heat
		}
	end

	if table.Count(productDataInfo) > 0 then
		zwf_ShopMain.product_DataPanel = vgui.Create("Panel", zwf_ShopMain.product_InfoPanel)
		zwf_ShopMain.product_DataPanel:SetSize(280 * wMod, 100 * hMod)
		zwf_ShopMain.product_DataPanel:DockMargin(0 * wMod,10 * hMod, 0 * wMod, 0 * hMod )
		zwf_ShopMain.product_DataPanel:Dock(TOP)
		zwf_ShopMain.product_DataPanel.Paint = function(s, w, h)
			//draw.RoundedBox(8, 0 , 0, w, h,  zwf.default_colors["black05"])
		end

		zwf_ShopMain.productdata_list = vgui.Create("DIconLayout", zwf_ShopMain.product_DataPanel)
		zwf_ShopMain.productdata_list:SetSize(280 * wMod, 200 * hMod)
		zwf_ShopMain.productdata_list:SetPos(0 * wMod, 0 * hMod)
		zwf_ShopMain.productdata_list:SetSpaceY(1)
		zwf_ShopMain.productdata_list:SetAutoDelete(true)

		for i = 1, table.Count(productDataInfo) do

			zwf_ProductDataItems[i] = zwf_ShopMain.productdata_list:Add("DPanel")
			zwf_ProductDataItems[i]:SetSize(zwf_ShopMain.productdata_list:GetWide(), 25 * hMod)
			zwf_ProductDataItems[i]:SetAutoDelete(true)
			zwf_ProductDataItems[i].Paint = function(self, w, h)
			end

			zwf_ProductDataItems[i].ItemName = vgui.Create("DLabel", zwf_ProductDataItems[i])
			zwf_ProductDataItems[i].ItemName:SetPos(0 * wMod, 0 * hMod)
			zwf_ProductDataItems[i].ItemName:SetSize(300 * wMod, 50 * hMod)
			zwf_ProductDataItems[i].ItemName:SetFont(zwf.f.GetFont("zwf_vgui_font04"))
			zwf_ProductDataItems[i].ItemName:SetText(productDataInfo[i])
			zwf_ProductDataItems[i].ItemName:SetColor(zwf.default_colors["white01"])
			zwf_ProductDataItems[i].ItemName:SetAutoDelete(true)
			zwf_ProductDataItems[i].ItemName:SetContentAlignment(7)
		end

		zwf_ShopMain.productdata_list:SizeToChildren(false,true)
		zwf_ShopMain.productdata_list:InvalidateLayout(true)

		zwf_ShopMain.product_DataPanel:SizeToChildren(false,true)
		zwf_ShopMain.product_DataPanel:InvalidateLayout(true)
	end

	if productData.ranks and table.Count(productData.ranks) > 0 then
		zwf_ShopMain.product_ranks_title = vgui.Create("DLabel", zwf_ShopMain.product_InfoPanel)
		zwf_ShopMain.product_ranks_title:SetPos(10 * wMod, 225 * hMod)
		zwf_ShopMain.product_ranks_title:SetSize(280 * wMod, 25 * hMod)
		zwf_ShopMain.product_ranks_title:Dock(TOP)
		zwf_ShopMain.product_ranks_title:DockMargin(0 * wMod,10 * hMod, 0 * wMod, 0 * hMod )
		zwf_ShopMain.product_ranks_title:SetFont(zwf.f.GetFont("zwf_vgui_font04"))
		zwf_ShopMain.product_ranks_title:SetText(zwf.language.VGUI["Ranks"] .. ":")
		zwf_ShopMain.product_ranks_title:SetColor(zwf.default_colors["yellow02"])
		zwf_ShopMain.product_ranks_title:SetAutoDelete(true)
		zwf_ShopMain.product_ranks_title:SetContentAlignment(7)
		zwf_ShopMain.product_ranks_title.Paint = function(s, w, h)
			//draw.RoundedBox(8, 0 , 0, w, h,  zwf.default_colors["black05"])
		end

		zwf_ShopMain.product_ranks = vgui.Create("DLabel", zwf_ShopMain.product_InfoPanel)
		zwf_ShopMain.product_ranks:SetPos(10 * wMod, 250 * hMod)
		zwf_ShopMain.product_ranks:SetSize(280 * wMod, 100 * hMod)
		zwf_ShopMain.product_ranks:Dock(TOP)
		zwf_ShopMain.product_ranks:SetFont(zwf.f.GetFont("zwf_vgui_font08"))
		zwf_ShopMain.product_ranks:SetText(zwf.f.TableKeyToString(productData.ranks))
		zwf_ShopMain.product_ranks:SetColor(zwf.default_colors["white01"])
		zwf_ShopMain.product_ranks:SetAutoDelete(true)
		zwf_ShopMain.product_ranks:SetWrap(true)
		zwf_ShopMain.product_ranks:SetContentAlignment(7)
		zwf_ShopMain.product_ranks.Paint = function(s, w, h)
			//draw.RoundedBox(8, 0 , 0, w, h,  zwf.default_colors["black05"])
		end
	end

	if productData.jobs and table.Count(productData.jobs) > 0 then
		zwf_ShopMain.product_jobs_title = vgui.Create("DLabel", zwf_ShopMain.product_InfoPanel)
		zwf_ShopMain.product_jobs_title:SetPos(10 * wMod, 300 * hMod)
		zwf_ShopMain.product_jobs_title:SetSize(280 * wMod, 25 * hMod)
		zwf_ShopMain.product_jobs_title:Dock(TOP)
		zwf_ShopMain.product_jobs_title:DockMargin(0 * wMod,10 * hMod, 0 * wMod, 0 * hMod )
		zwf_ShopMain.product_jobs_title:SetFont(zwf.f.GetFont("zwf_vgui_font04"))
		zwf_ShopMain.product_jobs_title:SetText(zwf.language.VGUI["Jobs"] .. ":")
		zwf_ShopMain.product_jobs_title:SetColor(zwf.default_colors["blue01"])
		zwf_ShopMain.product_jobs_title:SetAutoDelete(true)
		zwf_ShopMain.product_jobs_title:SetContentAlignment(7)
		zwf_ShopMain.product_jobs_title.Paint = function(s, w, h)
			//draw.RoundedBox(8, 0 , 0, w, h,  zwf.default_colors["black05"])
		end

		zwf_ShopMain.product_jobs = vgui.Create("DLabel", zwf_ShopMain.product_InfoPanel)
		zwf_ShopMain.product_jobs:SetPos(10 * wMod, 250 * hMod)
		zwf_ShopMain.product_jobs:SetSize(280 * wMod, 100 * hMod)
		zwf_ShopMain.product_jobs:Dock(TOP)
		zwf_ShopMain.product_jobs:SetFont(zwf.f.GetFont("zwf_vgui_font08"))
		zwf_ShopMain.product_jobs:SetText(zwf.f.GetTeamNameList(productData.jobs))
		zwf_ShopMain.product_jobs:SetColor(zwf.default_colors["white01"])
		zwf_ShopMain.product_jobs:SetAutoDelete(true)
		zwf_ShopMain.product_jobs:SetWrap(true)
		zwf_ShopMain.product_jobs:SetContentAlignment(7)
		zwf_ShopMain.product_jobs.Paint = function(s, w, h)
			//draw.RoundedBox(8, 0 , 0, w, h,  zwf.default_colors["black05"])
		end
	end
end

vgui.Register("zwf_vgui_ShopMenu", zwf_ShopMenu, "Panel")
