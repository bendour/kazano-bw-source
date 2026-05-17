/*
    Addon id: 5d8b797b-05d3-45b1-9efb-d4bfab61cce1
    Version: v3.4.5 (stable)
*/

if SERVER then return end

////////////////////////////////////////////
//////////// NPC SHOP INTERFACE ////////////
////////////////////////////////////////////

zpn = zpn or {}
zpn.vgui = zpn.vgui or {}
zpn.vgui.ShopInterface = zpn.vgui.ShopInterface or {}

LocalPlayer().zpn_NPC = nil
LocalPlayer().zpn_CandyPoints = nil

local zpn_Shop_SelectedItem = -1
local zpn_ShopItems = {}

// Called when the player opens the shop
net.Receive("zpn_Shop_Open_net", function(len, ply)
	zclib.Debug("zpn_Shop_Open_net Len: " .. len)

	local npc = net.ReadEntity()
	local candyPoints = net.ReadInt(16)
	local ownedItems = net.ReadTable()

	if IsValid(npc) then
		LocalPlayer().zpn_NPC = npc
		LocalPlayer().zpn_CandyPoints = candyPoints
		LocalPlayer().zpn_OwnedItems = ownedItems
		zpn.vgui.ShopInterface.Action_Open()
	end
end)

// Forces the shop to be closed
net.Receive("zpn_Shop_ForceClose_net", function(len, ply)
	zclib.Debug("zpn_Shop_ForceClose_net Len: " .. len)

	zpn.vgui.ShopInterface.Action_Close()
end)

function zpn.vgui.ShopInterface.Action_Open()
	if IsValid(zpn_vgui_panel) then
		zpn_vgui_panel:Remove()
	end

	zpn_vgui_panel = vgui.Create("zpn.vgui.ShopInterface")
end

function zpn.vgui.ShopInterface.Action_Close()
	if IsValid(zpn_vgui_panel) then
		zpn_vgui_panel:Remove()
	end

	LocalPlayer().zpn_NPC = nil
end

function zpn.vgui.ShopInterface.Action_SelectItem(itemid)
	zpn_Shop_SelectedItem = itemid
end

function zpn.vgui.ShopInterface.Action_BuyItem()
	if not zpn_Shop_SelectedItem then return end

	local ItemData = zpn.config.Shop[zpn_Shop_SelectedItem]
	if not ItemData then return end
	if not ItemData.type then return end

	local PurchaseType = zpn.PurchaseType[ItemData.type]
	if not PurchaseType then return end
	if PurchaseType(LocalPlayer(),zpn.config.Shop[zpn_Shop_SelectedItem]) ~= true then return end

	// CustomCheck
	if ItemData.check then
		local canbuy, reason = ItemData.check(LocalPlayer())

		if not canbuy then
			zclib.Notify(LocalPlayer(), reason, 1)
			return
		end
	end

	// Rank Check
	if ItemData.ranks and not zclib.Player.RankCheck(LocalPlayer(), ItemData.ranks) then
        zclib.Notify(LocalPlayer(), zclib.table.ToString(ItemData.ranks), 1)
        zclib.Notify(LocalPlayer(), zpn.language.General["PurchaseFail02"], 1)
        return
    end

	surface.PlaySound( "common/bugreporter_succeeded.wav" )

	net.Start("zpn_Shop_BuyItem_net")
	net.WriteEntity(LocalPlayer().zpn_NPC)
	net.WriteInt(zpn_Shop_SelectedItem, 16)
	net.SendToServer()

	zpn.vgui.ShopInterface.Action_Close()
end
                                                                                                                                                                                                                                                                                                                                                                                                                                                       -- 6af6efba71e4015ff987fc919ecacbe102ec0873079409ab2a0ed0bf25e3f3cd


function zpn.vgui.ShopInterface:Init()
	self:SetSize(500 * zclib.wM, 1000 * zclib.hM)
	self:Center()
	self:MakePopup()
	self:SetDraggable(false)
	self:SetIsMenu(false)
	self:SetSizable(false)
	self:ShowCloseButton(false)
	self:SetTitle("")

                                                                                                                                                                                                                                                                                                                                                                                                                                                       -- ddf04c302d8fd9e30f6a5e9cc4e3787dc09a35f0034528f4b4c268245f97715d

	zpn.vgui.ShopInterface.Title = vgui.Create("DLabel",self)
	zpn.vgui.ShopInterface.Title:SetPos(100 * zclib.wM, 160 * zclib.hM)
	zpn.vgui.ShopInterface.Title:SetSize(300 * zclib.wM, 60 * zclib.hM)
	zpn.vgui.ShopInterface.Title:SetContentAlignment(5)
	zpn.vgui.ShopInterface.Title:SetFont( zclib.util.FontSwitch(zpn.language.General["CandyShop"],13,zclib.GetFont("zpn_interface_font03"),zclib.GetFont("zpn_interface_font03_small")) )
	zpn.vgui.ShopInterface.Title:SetText(zpn.language.General["CandyShop"])
	zpn.vgui.ShopInterface.Title:SetTextColor(color_white)

	zpn.vgui.ShopInterface.Button_Close = vgui.Create("DButton", self)
	zpn.vgui.ShopInterface.Button_Close:SetPos(420 * zclib.wM, 167 * zclib.hM)
	zpn.vgui.ShopInterface.Button_Close:SetSize(60 * zclib.wM, 60 * zclib.hM)
	zpn.vgui.ShopInterface.Button_Close:SetText("")
	zpn.vgui.ShopInterface.Button_Close.Paint = function(s, w, h)

		if s:IsHovered() then
                                                                                                                                                                                                                                                                                                                                                                                                                                                       -- da71c7e0bf5016ce33a9f318a3747fb53331bb70d9090f016fdcc745ceefa6b8

			surface.SetDrawColor(color_white)
			surface.SetMaterial(zpn.Theme.Shop.materials["close_hover"])
			surface.DrawTexturedRect(0, 0,w,h)
		else
			surface.SetDrawColor(color_white)
			surface.SetMaterial(zpn.Theme.Shop.materials["close"])
			surface.DrawTexturedRect(0, 0,w,h)
		end
	end
	zpn.vgui.ShopInterface.Button_Close.DoClick = function()
		zpn.vgui.ShopInterface.Action_Close()

		// Tells the server that the shop got closed
		net.Start("zpn_Shop_ClosedShop_net")
		net.SendToServer()
	end

	zpn.vgui.ShopInterface.Button_Help = vgui.Create("DButton", self)
	zpn.vgui.ShopInterface.Button_Help:SetPos(20 * zclib.wM, 167 * zclib.hM)
	zpn.vgui.ShopInterface.Button_Help:SetSize(60 * zclib.wM, 60 * zclib.hM)
	zpn.vgui.ShopInterface.Button_Help:SetText("")
	zpn.vgui.ShopInterface.Button_Help.Paint = function(s, w, h)
		if s:IsHovered() then
			surface.SetDrawColor(color_white)
			surface.SetMaterial(zpn.Theme.Scoreboard.materials["icon"])
			surface.DrawTexturedRect(0, 0, w, h)

			draw.SimpleText("?", zclib.GetFont("zpn_interface_font01"), w / 2, h * 0.6, color_white, TEXT_ALIGN_CENTER, TEXT_ALIGN_CENTER)
		else
			surface.SetDrawColor(zpn.default_colors["white04"])
			surface.SetMaterial(zpn.Theme.Scoreboard.materials["icon"])
			surface.DrawTexturedRect(0, 0, w, h)

			draw.SimpleText("?", zclib.GetFont("zpn_interface_font01"), w / 2, h * 0.6, zpn.default_colors["white04"], TEXT_ALIGN_CENTER, TEXT_ALIGN_CENTER)
		end
	end
	zpn.vgui.ShopInterface.Button_Help.DoClick = function()
		zpn.vgui.ShopInterface.HelpPage(self)
	end

	zpn.vgui.ShopInterface.ShopPage(self)
end

function zpn.vgui.ShopInterface.ShopPage(parent)

	if IsValid(zpn.vgui.ShopInterface.MainPage) then zpn.vgui.ShopInterface.MainPage:Remove() end
	local main = vgui.Create("DPanel", parent)
	main:Dock(FILL)
	main:DockMargin(43 * zclib.wM, 250 * zclib.hM,40 * zclib.wM,50 * zclib.hM)
	main.Paint = function(s, w, h)
		//draw.RoundedBox(0, 0,0,w,h, zpn.default_colors["violett02"])
	end
	zpn.vgui.ShopInterface.MainPage = main


	zpn.vgui.ShopInterface.Text_CandyPoints = vgui.Create("DLabel",main)
	zpn.vgui.ShopInterface.Text_CandyPoints:SetPos(105 * zclib.wM, 597 * zclib.hM)
	zpn.vgui.ShopInterface.Text_CandyPoints:SetSize(890 * zclib.wM, 40 * zclib.hM)
	zpn.vgui.ShopInterface.Text_CandyPoints:SetContentAlignment(4)
	zpn.vgui.ShopInterface.Text_CandyPoints:SetFont( zclib.GetFont("zpn_interface_font02") )
	zpn.vgui.ShopInterface.Text_CandyPoints:SetTextColor(color_white)
	zpn.vgui.ShopInterface.Text_CandyPoints:SetText(LocalPlayer().zpn_CandyPoints)

	zpn.vgui.ShopInterface.Button_Buy = vgui.Create("DButton", main)
	zpn.vgui.ShopInterface.Button_Buy:SetPos(280 * zclib.wM, 593 * zclib.hM)
	zpn.vgui.ShopInterface.Button_Buy:SetSize(100 * zclib.wM, 50 * zclib.hM)
	zpn.vgui.ShopInterface.Button_Buy:SetText("")
	zpn.vgui.ShopInterface.Button_Buy.Paint = function(s, w, h)

		if s:IsHovered() then
			surface.SetDrawColor(color_white)
			surface.SetMaterial(zpn.Theme.Shop.materials["pay_hover"])
			surface.DrawTexturedRect(0, 0,w,h)
		else
			surface.SetDrawColor(color_white)
			surface.SetMaterial(zpn.Theme.Shop.materials["pay"])
			surface.DrawTexturedRect(0, 0,w,h)
		end

		draw.SimpleText(zpn.language.General["Buy"], zclib.util.FontSwitch(zpn.language.General["Buy"],5,zclib.GetFont("zpn_interface_font01"),zclib.GetFont("zpn_interface_font01_small")), w / 2, h / 2, color_white, TEXT_ALIGN_CENTER, TEXT_ALIGN_CENTER)
	end
	zpn.vgui.ShopInterface.Button_Buy.DoClick = function()
		zpn.vgui.ShopInterface.Action_BuyItem()
	end

	zpn.vgui.ShopInterface.ShopList(main)
	zpn.vgui.ShopInterface.Action_SelectItem(1)
end

function zpn.vgui.ShopInterface.HelpPage(parent)
	if IsValid(zpn.vgui.ShopInterface.MainPage) then zpn.vgui.ShopInterface.MainPage:Remove() end
	local main = vgui.Create("DPanel", parent)
	main:Dock(FILL)
	main:DockMargin(43 * zclib.wM, 250 * zclib.hM,40 * zclib.wM,50 * zclib.hM)
	main.Paint = function(s, w, h)
		//draw.RoundedBox(16, 0,0,w,h, zpn.default_colors["violett04"])
	end
	zpn.vgui.ShopInterface.MainPage = main


	zpn.vgui.ShopInterface.Text_CandyPoints = vgui.Create("DLabel",main)
	zpn.vgui.ShopInterface.Text_CandyPoints:SetPos(105 * zclib.wM, 597 * zclib.hM)
	zpn.vgui.ShopInterface.Text_CandyPoints:SetSize(890 * zclib.wM, 40 * zclib.hM)
	zpn.vgui.ShopInterface.Text_CandyPoints:SetContentAlignment(4)
	zpn.vgui.ShopInterface.Text_CandyPoints:SetFont( zclib.GetFont("zpn_interface_font02") )
	zpn.vgui.ShopInterface.Text_CandyPoints:SetTextColor(color_white)
	zpn.vgui.ShopInterface.Text_CandyPoints:SetText(LocalPlayer().zpn_CandyPoints)

	local txtarea = vgui.Create("DPanel", main)
	txtarea:Dock(FILL)
	txtarea:DockMargin(0 * zclib.wM, 10 * zclib.hM,0 * zclib.wM,400 * zclib.hM)
	txtarea.Paint = function(s, w, h)
		//draw.RoundedBox(16, 0,0,w,h, zpn.default_colors["green01"])
	end

	local cmd_title = vgui.Create("DLabel",txtarea)
	cmd_title:Dock(TOP)
	cmd_title:DockMargin(10 * zclib.wM, 5 * zclib.hM,10 * zclib.wM,10 * zclib.hM)
	cmd_title:SetContentAlignment(5)
	cmd_title:SetFont( zclib.GetFont("zpn_interface_font02") )
	cmd_title:SetTextColor(color_white)
	cmd_title:SetText("Chat Commands")

	local function AddTextField(cmd,desc)
		local a = vgui.Create("DPanel", txtarea)
		a:Dock(TOP)
		a:SetTall(65 * zclib.hM)
		a:DockMargin(10 * zclib.wM, 0 * zclib.hM,10 * zclib.wM,10 * zclib.hM)
		a.Paint = function(s, w, h)
			draw.RoundedBox(0, 0,0,w,h, zpn.Theme.Shop.itm_cmd_bg)
		end

		local cmd_pnl = vgui.Create("DLabel",a)
		cmd_pnl:Dock(TOP)
		cmd_pnl:DockMargin(10 * zclib.wM, 10 * zclib.hM,0 * zclib.wM,0 * zclib.hM)
		cmd_pnl:SetContentAlignment(4)
		cmd_pnl:SetFont( zclib.GetFont("zpn_interface_cmd") )
		cmd_pnl:SetTextColor(color_white)
		cmd_pnl:SetText(cmd)

		local desc_pnl = vgui.Create("DLabel",a)
		desc_pnl:Dock(TOP)
		desc_pnl:DockMargin(10 * zclib.wM, 0 * zclib.hM,0 * zclib.wM,5 * zclib.hM)
		desc_pnl:SetContentAlignment(4)
		desc_pnl:SetFont( zclib.GetFont("zpn_interface_item_desc") )
		desc_pnl:SetTextColor(color_white)
		desc_pnl:SetText(desc)
	end

	AddTextField("!candy",zpn.language.General["cmd_candy"])
	AddTextField("!dropcandy NUMBER",zpn.language.General["cmd_dropcandy"])
	if zpn.config.Candy.SellValue and zpn.config.Candy.SellValue > 0 then
		AddTextField("!sellcandy NUMBER", string.Replace(zpn.language.General["cmd_sellcandy"],"$SellValue",zclib.Money.Display(zpn.config.Candy.SellValue)))
	end


	local btn_back = vgui.Create("DButton", main)
	btn_back:SetPos(150 * zclib.wM, 300 * zclib.hM)
	btn_back:SetSize(100 * zclib.wM, 50 * zclib.hM)
	btn_back:SetText("")
	btn_back.Paint = function(s, w, h)

		if s:IsHovered() then
			surface.SetDrawColor(color_white)
			surface.SetMaterial(zpn.Theme.Shop.materials["pay_hover"])
			surface.DrawTexturedRect(0, 0,w,h)
		else
			surface.SetDrawColor(color_white)
			surface.SetMaterial(zpn.Theme.Shop.materials["pay"])
			surface.DrawTexturedRect(0, 0,w,h)
		end

		draw.SimpleText("Back",zclib.GetFont("zpn_interface_font01"), w / 2, h / 2, color_white, TEXT_ALIGN_CENTER, TEXT_ALIGN_CENTER)
	end
	btn_back.DoClick = function()
		zpn.vgui.ShopInterface.ShopPage(zpn_vgui_panel)
	end
end

function zpn.vgui.ShopInterface.ShopList(parent)
	zpn.vgui.ShopInterface.Panel_ShopList = vgui.Create("DPanel", parent)
	zpn.vgui.ShopInterface.Panel_ShopList:SetPos(0 * zclib.wM, 0 * zclib.hM)
	zpn.vgui.ShopInterface.Panel_ShopList:SetSize(420 * zclib.wM, 580 * zclib.hM)
	zpn.vgui.ShopInterface.Panel_ShopList.Paint = function(s, w, h)
	end


	zpn.vgui.ShopInterface.ScrollPanel_ShopList = vgui.Create("DScrollPanel", zpn.vgui.ShopInterface.Panel_ShopList)
	zpn.vgui.ShopInterface.ScrollPanel_ShopList:DockMargin(0 * zclib.wM, 0 * zclib.hM, 0 * zclib.wM, 0 * zclib.hM)
	zpn.vgui.ShopInterface.ScrollPanel_ShopList:Dock(FILL)
	local sbar01 = zpn.vgui.ShopInterface.ScrollPanel_ShopList:GetVBar()
	function sbar01:Paint( w, h )
	end
	function sbar01.btnUp:Paint( w, h )
	end
	function sbar01.btnDown:Paint( w, h )
	end
	function sbar01.btnGrip:Paint( w, h )
	end
	zpn.vgui.ShopInterface.ScrollPanel_ShopList.Paint = function(self, w, h)
	end


	// Here we create the product items
	if (zpn_ShopItems and IsValid(zpn_ShopItems.list)) then
		zpn_ShopItems.list:Remove()
	end

	zpn_ShopItems = {}
	zpn_ShopItems.list = vgui.Create("DIconLayout", zpn.vgui.ShopInterface.ScrollPanel_ShopList)
	zpn_ShopItems.list:SetSize(495 * zclib.wM, 200 * zclib.hM)
	zpn_ShopItems.list:SetPos(15 * zclib.wM, 15 * zclib.hM)
	zpn_ShopItems.list:SetSpaceY(10)
	zpn_ShopItems.list:SetAutoDelete(true)


	for i = 1, table.Count(zpn.config.Shop) do

		local itemData = zpn.config.Shop[i]
		if itemData == nil then continue end

		// If its a onetime purchase item and he already bought it once then skip it
		if itemData.ontime and LocalPlayer().zpn_OwnedItems[i] then continue end

		local ItemColor = zpn.config.Shop[i].color or zpn.Theme.Shop.itm_bg_color

		zpn_ShopItems[i] = zpn_ShopItems.list:Add("DPanel")
		zpn_ShopItems[i]:SetSize(375 * zclib.wM, 100 * zclib.hM)
		zpn_ShopItems[i]:SetAutoDelete(true)
		zpn_ShopItems[i].Paint = function(s, w, h)
			surface.SetDrawColor(ItemColor)
			surface.SetMaterial(zpn.Theme.Shop.materials["item"])
			surface.DrawTexturedRect(0, 0,w,h)
		end

		zpn_ShopItems[i].ItemName = vgui.Create("DLabel", zpn_ShopItems[i])
		zpn_ShopItems[i].ItemName:SetPos(100 * zclib.wM, 7 * zclib.hM)
		zpn_ShopItems[i].ItemName:SetSize(350 * zclib.wM, 125 * zclib.hM)
		zpn_ShopItems[i].ItemName:SetFont(zclib.GetFont("zpn_interface_item_title"))
		zpn_ShopItems[i].ItemName:SetText(zpn.Shop.GetItemName(i))
		zpn_ShopItems[i].ItemName:SetColor(color_white)
		zpn_ShopItems[i].ItemName:SetAutoDelete(true)
		zpn_ShopItems[i].ItemName:SetContentAlignment(7)

		zpn_ShopItems[i].ItemDesc = vgui.Create("DLabel", zpn_ShopItems[i])
		zpn_ShopItems[i].ItemDesc:SetPos(100 * zclib.wM, 45 * zclib.hM)
		zpn_ShopItems[i].ItemDesc:SetSize(150 * zclib.wM, 125 * zclib.hM)
		zpn_ShopItems[i].ItemDesc:SetFont(zclib.GetFont("zpn_interface_item_desc"))
		zpn_ShopItems[i].ItemDesc:SetText(zpn.Shop.GetItemDescription(i))
		zpn_ShopItems[i].ItemDesc:SetColor(color_white)
		zpn_ShopItems[i].ItemDesc:SetAutoDelete(true)
		zpn_ShopItems[i].ItemDesc:SetWrap(true)
		zpn_ShopItems[i].ItemDesc:SetContentAlignment(7)
                                                                                                                                                                                                                                                                                                                                                                                                                                                       -- 00000000000000000

		zpn_ShopItems[i].ItemPrice_Panel = vgui.Create("DPanel", zpn_ShopItems[i])
		zpn_ShopItems[i].ItemPrice_Panel:SetPos(275 * zclib.wM, 25 * zclib.hM)
		zpn_ShopItems[i].ItemPrice_Panel:SetSize(80 * zclib.wM, 55 * zclib.hM)
		zpn_ShopItems[i].ItemPrice_Panel:SetAutoDelete(true)
		zpn_ShopItems[i].ItemPrice_Panel.Paint = function(s, w, h)
			surface.SetDrawColor(color_white)
			surface.SetMaterial(zpn.Theme.Shop.materials["candy"])
			surface.DrawTexturedRect(0, 0,w,h)

			//Does the Player allready own the item?
			if LocalPlayer().zpn_OwnedItems[i] == nil then
				surface.SetDrawColor(color_white)
				surface.SetMaterial(zpn.default_materials[zpn.CandyIcon(itemData.price,100)])
				surface.DrawTexturedRect(5 * zclib.wM, 12 * zclib.hM,30 * zclib.wM, 30 * zclib.hM)
			end
		end

		// 1235078258
		//Does the Player allready own the item?
		if LocalPlayer().zpn_OwnedItems[i] == nil then
			zpn_ShopItems[i].ItemPrice = vgui.Create("DLabel", zpn_ShopItems[i].ItemPrice_Panel)
			zpn_ShopItems[i].ItemPrice:SetPos(40 * zclib.wM, 3 * zclib.hM)
			zpn_ShopItems[i].ItemPrice:SetSize(64 * zclib.wM, 50 * zclib.hM)
			zpn_ShopItems[i].ItemPrice:SetFont(zclib.GetFont("zpn_interface_shopitem_candy"))
			zpn_ShopItems[i].ItemPrice:SetText(itemData.price)
			zpn_ShopItems[i].ItemPrice:SetColor(color_white)
			zpn_ShopItems[i].ItemPrice:SetAutoDelete(true)
			zpn_ShopItems[i].ItemPrice:SetContentAlignment(4)
		else
			zpn_ShopItems[i].ItemPrice = vgui.Create("DLabel", zpn_ShopItems[i].ItemPrice_Panel)
			zpn_ShopItems[i].ItemPrice:SetPos(8 * zclib.wM, 3 * zclib.hM)
			zpn_ShopItems[i].ItemPrice:SetSize(64 * zclib.wM, 50 * zclib.hM)
			zpn_ShopItems[i].ItemPrice:SetFont(zclib.GetFont("zpn_interface_shopitem_owned"))
			zpn_ShopItems[i].ItemPrice:SetText(zpn.language.General["Owned"])
			zpn_ShopItems[i].ItemPrice:SetColor(color_white)
			zpn_ShopItems[i].ItemPrice:SetAutoDelete(true)
			zpn_ShopItems[i].ItemPrice:SetContentAlignment(5)
		end

		zpn_ShopItems[i].ModelPanel = vgui.Create("Panel", zpn_ShopItems[i])
		zpn_ShopItems[i].ModelPanel:SetPos(8 * zclib.wM, 8 * zclib.hM)
		zpn_ShopItems[i].ModelPanel:SetSize(84 * zclib.wM, 84 * zclib.hM)
		zpn_ShopItems[i].ModelPanel.Paint = function(s, w, h)
			draw.RoundedBox(14, 0, 0, w, h, zpn.Theme.Shop.itm_mdl_bg_color)
			if zpn.config.Shop[i].icon then
				// 1235078258
				surface.SetDrawColor(color_white)
				surface.SetMaterial(zpn.config.Shop[i].icon)
				surface.DrawTexturedRect(0, 0, w, h)
			end
		end
                                                                                                                                                                                                                                                                                                                                                                                                                                                       -- 00000000000000000

		zpn_ShopItems[i].ModelContent = zpn.Shop.DrawItemImage(i,zpn_ShopItems[i].ModelPanel)

		if (itemData.ranks and table.Count(itemData.ranks) > 0) or itemData.check then
			zpn_ShopItems[i].RankIcon = vgui.Create("Panel", zpn_ShopItems[i])
			zpn_ShopItems[i].RankIcon:SetPos(4 * zclib.wM, 4 * zclib.hM)
			zpn_ShopItems[i].RankIcon:SetSize(30 * zclib.wM, 30 * zclib.hM)
			zpn_ShopItems[i].RankIcon.Paint = function(s, w, h)
				surface.SetDrawColor(color_white)
				surface.SetMaterial(zpn.Theme.Shop.materials["vip"])
				surface.DrawTexturedRect(0, 0, w, h)
			end
		end

		if itemData.permanent then
			zpn_ShopItems[i].PermLabel = vgui.Create("DLabel", zpn_ShopItems[i].ModelPanel)
			zpn_ShopItems[i].PermLabel:SetPos(0 * zclib.wM, 54 * zclib.hM)
			zpn_ShopItems[i].PermLabel:SetSize(84 * zclib.wM, 30 * zclib.hM)
			zpn_ShopItems[i].PermLabel:SetContentAlignment(5)
			zpn_ShopItems[i].PermLabel:SetFont( zclib.GetFont("zpn_interface_item_desc") )
			zpn_ShopItems[i].PermLabel:SetText(zpn.language.General["Permanent"])
			zpn_ShopItems[i].PermLabel:SetTextColor(zpn.default_colors["green02"])
		end

		zpn_ShopItems[i].button = vgui.Create("DButton", zpn_ShopItems[i])
		zpn_ShopItems[i].button:SetPos(0 * zclib.wM, 0 * zclib.hM)
		zpn_ShopItems[i].button:SetSize(375 * zclib.wM, 100 * zclib.hM)
		zpn_ShopItems[i].button:SetText("")
		zpn_ShopItems[i].button:SetAutoDelete(true)
		zpn_ShopItems[i].button.Paint = function(s, w, h)

			if i == zpn_Shop_SelectedItem then
				surface.SetDrawColor(color_white)
				surface.SetMaterial(zpn.default_materials["zcb_shopinterface_item_selection"])
				surface.DrawTexturedRect(0, 0,w,h)
			end

			if s:IsHovered() then
				surface.SetDrawColor(zpn.default_colors["white05"])
				surface.SetMaterial(zpn.Theme.Shop.materials["item"])
				surface.DrawTexturedRect(0, 0,w,h)
			end
		end
		zpn_ShopItems[i].button.DoClick = function()

			zpn.vgui.ShopInterface.Action_SelectItem(i)

			surface.PlaySound("UI/buttonclick.wav")
		end
	end
end

function zpn.vgui.ShopInterface:Paint(w, h)
	surface.SetDrawColor(color_white)
	surface.SetMaterial(zpn.Theme.Shop.materials["bg"])
	surface.DrawTexturedRect(0, 0,w,h)

	if input.IsKeyDown(KEY_ESCAPE) then
		zpn.vgui.ShopInterface.Action_Close()
	end
end

vgui.Register("zpn.vgui.ShopInterface", zpn.vgui.ShopInterface, "DFrame")
////////////////////////////////////////////
////////////////////////////////////////////
