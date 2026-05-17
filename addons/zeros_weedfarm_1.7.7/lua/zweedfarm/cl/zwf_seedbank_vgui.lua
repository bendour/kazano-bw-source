if not CLIENT then return end

local wMod = ScrW() / 1920
local hMod = ScrH() / 1080

local zwf_SeedBankMenu = {}
local zwf_SeedBankMain = {}

/////////// General
local function zwf_OpenUI()
	if not IsValid(zwf_SeedBankMenu_panel) then

		zwf_SeedBankMenu_panel = vgui.Create("zwf_vgui_SeedBankMenu")
	end
end

local function zwf_CloseUI()

	if IsValid(zwf_SeedBankMenu_panel) then
		zwf_SeedBankMenu_panel:Remove()
	end
end
///////////

// This closes the shop interface
net.Receive("zwf_CloseSeedBank", function(len)
	zwf_CloseUI()
end)

// This opens the shop interface
net.Receive("zwf_OpenSeedBank", function(len)
	local dataLength = net.ReadUInt(16)
	local boardDecompressed = util.Decompress(net.ReadData(dataLength))
	local seedData = util.JSONToTable(boardDecompressed)

	LocalPlayer().zwf_SeedBank = net.ReadEntity()
	LocalPlayer().zwf_SeedBankData = seedData
	LocalPlayer().zwf_SelectedSeed = nil

	zwf_OpenUI()
end)

/////////// Init
function zwf_SeedBankMenu:Init()
	self:SetSize(1000 * wMod, 600 * hMod)
	self:Center()
	self:MakePopup()

	zwf_SeedBankMain.Title = vgui.Create("DLabel", self)
	zwf_SeedBankMain.Title:SetPos(15 * wMod, -30 * hMod)
	zwf_SeedBankMain.Title:SetSize(600 * wMod, 125 * hMod)
	zwf_SeedBankMain.Title:SetFont(zwf.f.GetFont("zwf_vgui_font03"))
	zwf_SeedBankMain.Title:SetText(zwf.language.VGUI["seedbank_title"])
	zwf_SeedBankMain.Title:SetColor(zwf.default_colors["white01"])

	zwf_SeedBankMain.close = vgui.Create("DButton", self)
	zwf_SeedBankMain.close:SetText("")
	zwf_SeedBankMain.close:SetPos(940 * wMod, 10 * hMod)
	zwf_SeedBankMain.close:SetSize(50 * wMod, 50 * hMod)
	zwf_SeedBankMain.close.DoClick = function()
		zwf_CloseUI()
	end
	zwf_SeedBankMain.close.Paint = function(s,w, h)

		if zwf_SeedBankMain.close:IsHovered() then
			draw.RoundedBox(10, 0 , 0, w, h, zwf.default_colors["red03"])
		else
			draw.RoundedBox(10, 0 , 0, w, h, zwf.default_colors["black06"])
		end

		if zwf_SeedBankMain.close:IsHovered() then
			draw.DrawText("X", zwf.f.GetFont("zwf_vgui_font03"), 25 * wMod, 4 * hMod, zwf.default_colors["white01"], TEXT_ALIGN_CENTER)
		else
			draw.DrawText("X", zwf.f.GetFont("zwf_vgui_font03"), 25 * wMod, 4 * hMod, zwf.default_colors["black06"], TEXT_ALIGN_CENTER)
		end
	end

	zwf_SeedList(self)

	zwf_SeedInfoPanel(self)
end

function zwf_SeedBankMenu:Paint(w, h)
	draw.RoundedBox(15, 0 , 0, w, h,  zwf.default_colors["gray01"])
end

function zwf_SeedList(parent)

	if (zwf_MainShopList and IsValid(zwf_MainShopList.ProductPanel)) then
		zwf_MainShopList.ProductPanel:Remove()
	end

	zwf_MainShopList = {}

	zwf_MainShopList.ProductPanel = vgui.Create("Panel", parent)
	zwf_MainShopList.ProductPanel:SetPos(0 * wMod, 100 * hMod)
	zwf_MainShopList.ProductPanel:SetSize(600 * wMod, 500 * hMod)
	zwf_MainShopList.ProductPanel.Paint = function(s, w, h)
		surface.SetDrawColor(0, 0, 0, 55)
		surface.SetMaterial(zwf.default_materials["square"])
		surface.DrawTexturedRect(0, 0, w, h)
	end

	zwf_MainShopList.scrollpanel = vgui.Create("DScrollPanel", zwf_MainShopList.ProductPanel)
	zwf_MainShopList.scrollpanel:DockMargin(0 * wMod, 0 * hMod, 15 * wMod, 0 * hMod)
	zwf_MainShopList.scrollpanel:Dock(FILL)
	zwf_MainShopList.scrollpanel:GetVBar().Paint = function() return true end
	zwf_MainShopList.scrollpanel:GetVBar().btnUp.Paint = function() return true end
	zwf_MainShopList.scrollpanel:GetVBar().btnDown.Paint = function() return true end
	zwf_MainShopList.scrollpanel.Paint = function(self, w, h)
	end



	// Here we create the product items
	if (zwf_SeedItems and IsValid(zwf_SeedItems.list)) then
		zwf_SeedItems.list:Remove()
	end

	zwf_SeedItems = {}
	zwf_SeedItems.list = vgui.Create("DIconLayout", zwf_MainShopList.scrollpanel)
	zwf_SeedItems.list:SetSize(575 * wMod, 475 * hMod)
	zwf_SeedItems.list:SetPos(15 * wMod, 15 * hMod)
	zwf_SeedItems.list:SetSpaceY(10)
	zwf_SeedItems.list:SetSpaceX(10)
	zwf_SeedItems.list:SetAutoDelete(true)

	for i = 1, zwf.config.SeedBank.Limit do

		zwf_SeedItems[i] = zwf_SeedItems.list:Add("DPanel")
		zwf_SeedItems[i]:SetSize(100 * wMod, 100 * hMod)
		zwf_SeedItems[i]:SetAutoDelete(true)
		zwf_SeedItems[i].Paint = function(self, w, h)
			if i == LocalPlayer().zwf_SelectedSeed then

				surface.SetDrawColor(40, 255, 40, 15)
			else
				surface.SetDrawColor(40, 40, 40, 55)
			end
			surface.SetMaterial(zwf.default_materials["button_base"])
			surface.DrawTexturedRect(0, 0, w, h)
		end

		local seedData = LocalPlayer().zwf_SeedBankData[i]



		if seedData then
			zwf_SeedItems[i].seed_Model = vgui.Create("DModelPanel", zwf_SeedItems[i])
			zwf_SeedItems[i].seed_Model:SetSize(zwf_SeedItems[i]:GetWide(), zwf_SeedItems[i]:GetTall())
			zwf_SeedItems[i].seed_Model:SetPos(0 * wMod, 0 * hMod)
			zwf_SeedItems[i].seed_Model:SetModel("models/zerochain/props_weedfarm/zwf_weedseed.mdl")
			zwf_SeedItems[i].seed_Model:SetAutoDelete(true)
			zwf_SeedItems[i].seed_Model:SetColor(zwf.default_colors["white01"])
			zwf_SeedItems[i].seed_Model.PlantSkin = zwf.config.Plants[seedData.Weed_ID].skin
			zwf_SeedItems[i].seed_Model.LayoutEntity = function(self)
				local offset = 1
				local ang = Angle(180, 45 * RealTime(), 90)

				self.Entity:SetSkin(self.PlantSkin)
				self.Entity:SetAngles(ang)
				local size1, size2 = self.Entity:GetRenderBounds()
				local size = (-size1 + size2):Length()
				self:SetFOV(35 * offset)
				self:SetCamPos(Vector(size * 1, size * 1, size * 1))
				self:SetLookAt(self.Entity:GetPos() + Vector(0, 0, 0.1 * size))
			end

			zwf_SeedItems[i].button = vgui.Create("DButton", zwf_SeedItems[i])
			zwf_SeedItems[i].button:SetPos(0 * wMod, 0 * hMod)
			zwf_SeedItems[i].button:SetSize(100 * wMod, 100 * hMod)
			zwf_SeedItems[i].button:SetText("")
			zwf_SeedItems[i].button:SetAutoDelete(true)
			zwf_SeedItems[i].button.Paint = function(self, w, h)
				surface.SetDrawColor(255, 255, 255, 7)
				surface.SetMaterial(zwf.default_materials["button_shine"])
				surface.DrawTexturedRect(0, 0, w, h)

				if i == LocalPlayer().zwf_SelectedSeed then
					surface.SetDrawColor(40, 255, 40, 55)
					surface.SetMaterial(zwf.default_materials["button_select"])
					surface.DrawTexturedRect(0, 0, w, h)
				end
			end
			zwf_SeedItems[i].button.DoClick = function()
				LocalPlayer().zwf_SelectedSeed = i

				surface.PlaySound("UI/buttonclick.wav")

				zwf_SeedInfoPanel(parent)
			end

			zwf_SeedItems[i].ItemName = vgui.Create("DLabel", zwf_SeedItems[i].button)
			zwf_SeedItems[i].ItemName:SetPos(10 * wMod, 10 * hMod)
			zwf_SeedItems[i].ItemName:SetSize(80 * wMod, 25 * hMod)
			zwf_SeedItems[i].ItemName:SetFont(zwf.f.GetFont("zwf_seedbank_vgui_font01"))
			zwf_SeedItems[i].ItemName:SetText(seedData.Weed_Name)
			zwf_SeedItems[i].ItemName:SetColor(zwf.default_colors["white01"])
			zwf_SeedItems[i].ItemName:SetAutoDelete(true)
			zwf_SeedItems[i].ItemName:SetContentAlignment(7)

			zwf_SeedItems[i].ItemCount = vgui.Create("DLabel", zwf_SeedItems[i].button)
			zwf_SeedItems[i].ItemCount:SetPos(0 * wMod, 50 * hMod)
			zwf_SeedItems[i].ItemCount:SetSize(90 * wMod, 50 * hMod)
			zwf_SeedItems[i].ItemCount:SetFont(zwf.f.GetFont("zwf_vgui_font01"))
			zwf_SeedItems[i].ItemCount:SetText("x" .. seedData.SeedCount)
			zwf_SeedItems[i].ItemCount:SetColor(zwf.default_colors["white01"])
			zwf_SeedItems[i].ItemCount:SetAutoDelete(true)
			zwf_SeedItems[i].ItemCount:SetContentAlignment(3)
		end
	end
end

function zwf_SeedInfoPanel(parent)

	if zwf_SeedBankMain and IsValid(zwf_SeedBankMain.SeedInfoPanel) then
		zwf_SeedBankMain.SeedInfoPanel:Remove()
	end

	zwf_SeedBankMain.SeedInfoPanel = vgui.Create("Panel", parent)
	zwf_SeedBankMain.SeedInfoPanel:SetPos(625 * wMod, 100 * hMod)
	zwf_SeedBankMain.SeedInfoPanel:SetSize(375 * wMod, 500 * hMod)
	zwf_SeedBankMain.SeedInfoPanel.Paint = function(s, w, h)
		surface.SetDrawColor(0, 0, 0, 55)
		surface.SetMaterial(zwf.default_materials["square"])
		surface.DrawTexturedRect(0, 0, w, h)
	end

	if LocalPlayer().zwf_SelectedSeed == nil then return end

	zwf_SeedBankMain.DropButton = vgui.Create("DButton", zwf_SeedBankMain.SeedInfoPanel)
	zwf_SeedBankMain.DropButton:SetText("")
	zwf_SeedBankMain.DropButton:SetPos(200 * wMod, 445 * hMod)
	zwf_SeedBankMain.DropButton:SetSize(150 * wMod, 40 * hMod)
	zwf_SeedBankMain.DropButton:SetVisible(true)
	zwf_SeedBankMain.DropButton.DoClick = function()

		if (LocalPlayer().zwf_SelectedSeed) then

			net.Start("zwf_DropSeed")
			net.WriteEntity(LocalPlayer().zwf_SeedBank)
			net.WriteInt(LocalPlayer().zwf_SelectedSeed, 16)
			net.SendToServer()

			zwf_CloseUI()
		end
	end
	zwf_SeedBankMain.DropButton.Paint = function(s,w, h)
		if zwf_SeedBankMain.DropButton:IsHovered() then
			surface.SetDrawColor(zwf.default_colors["green06"])
		else
			surface.SetDrawColor(zwf.default_colors["green02"])
		end

		surface.SetMaterial(zwf.default_materials["button_wide"])
		surface.DrawTexturedRect(0, 0, w, h)

		if zwf_SeedBankMain.DropButton:IsHovered() then
			draw.DrawText(zwf.language.VGUI["Drop"], zwf.f.GetFont("zwf_vgui_font10"), 75 * wMod, 7 * hMod, zwf.default_colors["white01"], TEXT_ALIGN_CENTER)
		else
			draw.DrawText(zwf.language.VGUI["Drop"], zwf.f.GetFont("zwf_vgui_font10"), 75 * wMod, 7 * hMod, zwf.default_colors["black06"], TEXT_ALIGN_CENTER)
		end
	end

	// 167257878
	zwf_SeedBankMain.DeleteButton = vgui.Create("DButton", zwf_SeedBankMain.SeedInfoPanel)
	zwf_SeedBankMain.DeleteButton:SetText("")
	zwf_SeedBankMain.DeleteButton:SetPos(25 * wMod, 445 * hMod)
	zwf_SeedBankMain.DeleteButton:SetSize(150 * wMod, 40 * hMod)
	zwf_SeedBankMain.DeleteButton:SetVisible(true)
	zwf_SeedBankMain.DeleteButton.DoClick = function()

		if (LocalPlayer().zwf_SelectedSeed) then

			net.Start("zwf_DeleteSeed")
			net.WriteEntity(LocalPlayer().zwf_SeedBank)
			net.WriteInt(LocalPlayer().zwf_SelectedSeed, 16)
			net.SendToServer()

			zwf_CloseUI()
		end
	end
	zwf_SeedBankMain.DeleteButton.Paint = function(s,w, h)
		if zwf_SeedBankMain.DeleteButton:IsHovered() then
			surface.SetDrawColor(zwf.default_colors["red03"])
		else
			surface.SetDrawColor(zwf.default_colors["red01"])
		end

		surface.SetMaterial(zwf.default_materials["button_wide"])
		surface.DrawTexturedRect(0, 0, w, h)

		if zwf_SeedBankMain.DeleteButton:IsHovered() then
			draw.DrawText(zwf.language.VGUI["Delete"], zwf.f.GetFont("zwf_vgui_font10"), 75 * wMod, 7 * hMod, zwf.default_colors["white01"], TEXT_ALIGN_CENTER)
		else
			draw.DrawText(zwf.language.VGUI["Delete"], zwf.f.GetFont("zwf_vgui_font10"), 75 * wMod, 7 * hMod, zwf.default_colors["black06"], TEXT_ALIGN_CENTER)
		end
	end



	local SeedBaseData = LocalPlayer().zwf_SeedBankData[LocalPlayer().zwf_SelectedSeed]
	local SeedData = zwf.config.Plants[SeedBaseData.Weed_ID]
	local seedData_name = SeedBaseData.Weed_Name

	zwf_SeedBankMain.seedData_Name = vgui.Create("DLabel", zwf_SeedBankMain.SeedInfoPanel)
	zwf_SeedBankMain.seedData_Name:SetPos(15 * wMod, 15 * hMod)
	zwf_SeedBankMain.seedData_Name:SetSize(300 * wMod, 125 * hMod)
	zwf_SeedBankMain.seedData_Name:SetFont(zwf.f.GetFont("zwf_vgui_font01"))
	zwf_SeedBankMain.seedData_Name:SetText(seedData_name)
	zwf_SeedBankMain.seedData_Name:SetColor(zwf.default_colors["white01"])
	zwf_SeedBankMain.seedData_Name:SetAutoDelete(true)
	zwf_SeedBankMain.seedData_Name:SetContentAlignment(7)



	zwf_SeedBankMain.seedData_DataPanel = vgui.Create("Panel", zwf_SeedBankMain.SeedInfoPanel)
	zwf_SeedBankMain.seedData_DataPanel:SetPos(25 * wMod, 75 * hMod)
	zwf_SeedBankMain.seedData_DataPanel:SetSize(300 * wMod, 250 * hMod)
	zwf_SeedBankMain.seedData_DataPanel.Paint = function(s, w, h)
	end


	zwf_SeedDataItems = {}

	zwf_SeedBankMain.seeddata_list = vgui.Create("DIconLayout", zwf_SeedBankMain.seedData_DataPanel)
	zwf_SeedBankMain.seeddata_list:SetSize(300 * wMod, 200 * hMod)
	zwf_SeedBankMain.seeddata_list:SetPos(0 * wMod, 0 * hMod)
	zwf_SeedBankMain.seeddata_list:SetSpaceY(1)
	zwf_SeedBankMain.seeddata_list:SetAutoDelete(true)





	local Perf_Time = SeedBaseData.Perf_Time
	local Perf_Amount = SeedBaseData.Perf_Amount
	local Perf_THC = SeedBaseData.Perf_THC


	Perf_Time = 100 - (Perf_Time - 100)
	Perf_Time = Perf_Time * 0.01
	local def_time = SeedData.Grow.Duration
	Perf_Time = def_time * Perf_Time
	Perf_Time =  math.Round(Perf_Time) .. "s"

	Perf_Amount = Perf_Amount * 0.01
	local def_amount = SeedData.Grow.MaxYieldAmount
	Perf_Amount = def_amount * Perf_Amount
	Perf_Amount =  math.Round(Perf_Amount) .. zwf.config.UoW

	Perf_THC = Perf_THC * 0.01
	local def_thc = SeedData.thc_level
	Perf_THC = def_thc * Perf_THC
	Perf_THC =  math.Round(Perf_THC) .. "%"


	local seedDataInfo = {
		[1] = {
			name = zwf.language.VGUI["Strain"] .. ":",
			val = SeedData.name
		},
		[2] = {
			name = zwf.language.VGUI["Difficulty"] .. ":",
			val = SeedData.Grow.Difficulty
		},
		[3] = {
			name = zwf.language.VGUI["SeedCount"] .. ":",
			val = SeedBaseData.SeedCount
		},
		[4] = {
			name = zwf.language.VGUI["Duration"] .. ":",
			val = Perf_Time
		},
		[5] = {
			name = zwf.language.VGUI["HarvestAmount"] .. ":",
			val = Perf_Amount
		},
		[6] = {
			name = zwf.language.General["THC"] .. ":",
			val = Perf_THC
		}

	}

	for i = 1, table.Count(seedDataInfo) do
		zwf_SeedDataItems[i] = zwf_SeedBankMain.seeddata_list:Add("DPanel")
		zwf_SeedDataItems[i]:SetSize(zwf_SeedBankMain.seeddata_list:GetWide(), 35 * hMod)
		zwf_SeedDataItems[i]:SetAutoDelete(true)
		zwf_SeedDataItems[i].Paint = function(self, w, h)
		end

		zwf_SeedDataItems[i].ItemName = vgui.Create("DLabel", zwf_SeedDataItems[i])
		zwf_SeedDataItems[i].ItemName:SetPos(0 * wMod, 0 * hMod)
		zwf_SeedDataItems[i].ItemName:SetSize(300 * wMod, 50 * hMod)
		zwf_SeedDataItems[i].ItemName:SetFont(zwf.f.GetFont("zwf_vgui_font02"))
		zwf_SeedDataItems[i].ItemName:SetText(seedDataInfo[i].name)
		zwf_SeedDataItems[i].ItemName:SetColor(zwf.default_colors["white01"])
		zwf_SeedDataItems[i].ItemName:SetAutoDelete(true)
		zwf_SeedDataItems[i].ItemName:SetContentAlignment(7)

		zwf_SeedDataItems[i].ItemValue = vgui.Create("DLabel", zwf_SeedDataItems[i])
		zwf_SeedDataItems[i].ItemValue:SetPos(0 * wMod, 0 * hMod)
		zwf_SeedDataItems[i].ItemValue:SetSize(300 * wMod, 50 * hMod)
		zwf_SeedDataItems[i].ItemValue:SetFont(zwf.f.GetFont("zwf_vgui_font02"))
		zwf_SeedDataItems[i].ItemValue:SetText(seedDataInfo[i].val)
		zwf_SeedDataItems[i].ItemValue:SetColor(zwf.default_colors["white01"])
		zwf_SeedDataItems[i].ItemValue:SetAutoDelete(true)
		zwf_SeedDataItems[i].ItemValue:SetContentAlignment(9)
	end
end


vgui.Register("zwf_vgui_SeedBankMenu", zwf_SeedBankMenu, "Panel")
