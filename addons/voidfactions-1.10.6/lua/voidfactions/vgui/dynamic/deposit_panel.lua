local L = VoidFactions.Lang.GetPhrase
local sc = VoidUI.Scale

local PANEL = {}

function PANEL:Init()
    local currency = VoidFactions.Currencies.List[VoidFactions.Config.DepositCurrency]
    if (!currency) then
        VoidLib.Notify("ERROR", "Deposit currency does not exist. Please set it up in the settings.", VoidUI.Colors.Red, 5)
        return
    end

	self.currency = currency

	local inventory = VoidFactions.Inventories.List[VoidFactions.Config.DepositInventory]

    local member = VoidFactions.PlayerMember
    local faction = member.faction

	local canDepositItems = member:Can("DepositItems", faction) and inventory
	local canWithdrawItems = member:Can("WithdrawItems", faction) and inventory

	local canDepositMoney = member:Can("DepositMoney", faction)
	local canWithdrawMoney = member:Can("WithdrawMoney", faction)

	self.canDepositItems = canDepositItems
	self.canWithdrawItems = canWithdrawItems

    self:SetTitle(string.upper(L"deposit"))
    self:SetOrigSize(1000, 600)

	self.selectedItem = nil

	self.itemCount = table.Count(faction.deposits or {})

    local container = self:Add("Panel")
    container:Dock(FILL)

	local inventoryPanel = container:Add("Panel")
	inventoryPanel:Dock(FILL)
	inventoryPanel.Paint = function (s, w, h)
		draw.RoundedBox(8, 0, 0, w, h, VoidUI.Colors.Primary)

		local totalItems = self.itemCount or 0
		draw.SimpleText(string.upper(VoidLib.StringFormat(L"itemCount", {
			x = totalItems,
			max = faction:GetMaxItems()
		})), "VoidUI.B24", sc(20), sc(20), VoidUI.Colors.Gray, TEXT_ALIGN_LEFT, TEXT_ALIGN_TOP)
	end


	local inventoryItems = inventoryPanel:Add("VoidUI.Grid")
	inventoryItems:Dock(FILL)
	inventoryItems:SetHorizontalMargin(10)
	inventoryItems:SetVerticalMargin(10)
	inventoryItems:SetColumns(5)

    

    local transactionPanel = container:Add("Panel")
    transactionPanel:Dock(RIGHT)
    transactionPanel.Paint = function (self, w, h)
        draw.RoundedBox(8, 0, 0, w, h, VoidUI.Colors.Primary)

		local formattedMoney = currency:FormatMoney(faction.money)

        draw.SimpleText(string.upper(L"balance"), "VoidUI.B22", w/2, sc(50), VoidUI.Colors.Green, TEXT_ALIGN_CENTER, TEXT_ALIGN_BOTTOM)
        draw.SimpleText(formattedMoney, "VoidUI.B36", w/2, sc(80), VoidUI.Colors.Gray, TEXT_ALIGN_CENTER, TEXT_ALIGN_BOTTOM)
    end

	local transactionHistory = transactionPanel:Add("Panel")
	transactionHistory:Dock(FILL)
	transactionHistory.Paint = function (self, w, h)
		draw.SimpleText(string.upper(L"transactionHistory"), "VoidUI.B20", w/2, 0, VoidUI.Colors.Gray, TEXT_ALIGN_CENTER, TEXT_ALIGN_TOP)
	end

	local transactionContent = transactionHistory:Add("VoidUI.RowPanel")
	transactionContent:Dock(FILL)
	transactionContent.Paint = function (self, w, h)
		draw.RoundedBox(8, 0, 0, w, h, VoidUI.Colors.Background)
	end

	local transactionButtons = transactionPanel:Add("Panel")
	transactionButtons:Dock(BOTTOM)

	local moneyDepositButton = transactionButtons:Add("VoidUI.Button")
	moneyDepositButton:Dock(TOP)
	moneyDepositButton:SetMedium()
	moneyDepositButton:SetText(L"deposit")

	moneyDepositButton.DoClick = function ()
		local popup = vgui.Create("VoidUI.ValuePopup")
		popup:SetText(L"depositMoney", L"depositMoneyText")
		popup:SetNumeric()
		popup:Continue(L"deposit", function (val)
			local valNumber = tonumber(val)
			if (!valNumber) then return end

			if (!currency:CanAfford(LocalPlayer(), valNumber)) then
				VoidLib.Notify(L"error", L"cantAfford", VoidUI.Colors.Red, 5)
				return
			end

			VoidFactions.Deposit:DepositMoney(valNumber)
		end)
		popup:Cancel(L"cancel")
	end

	moneyDepositButton:SetEnabled(canDepositMoney)

	local moneyWithdrawButton = transactionButtons:Add("VoidUI.Button")
	moneyWithdrawButton:Dock(BOTTOM)
	moneyWithdrawButton:SetMedium()
	moneyWithdrawButton:SetText(L"withdraw")
	moneyWithdrawButton:SetColor(VoidUI.Colors.Red)

	moneyWithdrawButton:SetEnabled(canWithdrawMoney)

	moneyWithdrawButton.DoClick = function ()
		local popup = vgui.Create("VoidUI.ValuePopup")
		popup:SetText(L"withdrawMoney", L"withdrawMoneyText")
		popup:SetNumeric()
		popup:Continue(L"withdraw", function (val)
			local valNumber = tonumber(val)
			if (!valNumber) then return end

			VoidFactions.Deposit:WithdrawMoney(valNumber)
		end)
		popup:Cancel(L"cancel")
	end

	local buttonPanel = inventoryPanel:Add("Panel")
	buttonPanel:Dock(BOTTOM)
	
	local depositButton = buttonPanel:Add("VoidUI.Button")
	depositButton:Dock(LEFT)
	depositButton:SetMedium()
	depositButton:SetText(L"deposit")

	depositButton:SetEnabled(canDepositItems)

	depositButton.DoClick = function ()
		if not inventory then return end
		
		local ply = LocalPlayer()
		local items = inventory:GetItems(ply)

		local selector = vgui.Create("VoidUI.ItemSelect")
		selector:SetParent(self)
	
		local itemTbl = {}
		for itemClass, _ in pairs(items) do
			local printName = inventory:GetPrintName(itemClass)
			itemTbl[itemClass] = printName
		end

		selector:InitItems(itemTbl, function (class, v)
			VoidFactions.Deposit:DepositItem(class, v)
		end)

		local x, y = input.GetCursorPos()
		selector:SetPos(x-135, y-330)
	end

	local withdrawButton = buttonPanel:Add("VoidUI.Button")
	withdrawButton:Dock(RIGHT)
	withdrawButton:SetMedium()
	withdrawButton:SetText(L"withdraw")
	withdrawButton:SetColor(VoidUI.Colors.Red)

	withdrawButton.DoClick = function ()
		VoidFactions.Deposit:WithdrawItem(self.selectedItem.id, inventory:GetPrintName(self.selectedItem.class))
	end

	withdrawButton:SetEnabled(false)


    self.transactionPanel = transactionPanel
	self.inventoryPanel = inventoryPanel

	self.transactionHistory = transactionHistory
	self.transactionButtons = transactionButtons

	self.transactionContent = transactionContent

	self.moneyDepositButton = moneyDepositButton
	self.moneyWithdrawButton = moneyWithdrawButton

	self.inventoryItems = inventoryItems
	self.buttonPanel = buttonPanel

	self.depositButton = depositButton
	self.withdrawButton = withdrawButton

    self.container = container

	self.inventory = inventory

	hook.Add("VoidFactions.Faction.DataUpdated", "VoidFactions.UI.DepositPanel.ItemsReceived", function ()
		self:LoadItems()
	end)

	self:LoadItems()
end

function PANEL:OnRemove()
	hook.Remove("VoidFactions.Faction.DataUpdated", "VoidFactions.UI.DepositPanel.ItemsReceived")
end

function PANEL:LoadItems()
	local member = VoidFactions.PlayerMember
    local faction = member.faction
	
	if (faction.deposits) then
		self:DisplayItems(faction.deposits, faction.transactions)
	else
		VoidFactions.Faction:RequestFactionDeposits(faction.id)
	end
end

function PANEL:DisplayItems(deposits, transactions)

	local inventory = self.inventory
	local currency = self.currency

	self.inventoryItems:Clear()
	self.transactionContent:Clear()

	local member = VoidFactions.PlayerMember
    local faction = member.faction

	local depositCount = table.Count(faction.deposits)

	self.canDepositItems = depositCount + 1 <= faction:GetMaxItems()
	self.itemCount = depositCount

	self.depositButton:SetEnabled(self.canDepositItems)

	local inventory = self.inventory

	for k, transaction in SortedPairsByMemberValue(transactions, "time", true) do

		local plyNick = nil
		steamworks.RequestPlayerInfo(transaction.sid, function (nick)
			plyNick = nick
		end)

		local printName = transaction.isMoney and currency:FormatMoney(math.abs(transaction.difference)) or inventory:GetPrintName(transaction.itemClass)

		local panel = self.transactionContent:Add("Panel")
		panel:Dock(TOP)
		panel:SSetTall(25)

		panel.Paint = function (self, w, h)
			local color = transaction.difference > 0 and VoidUI.Colors.Green or VoidUI.Colors.Red
			local symbol = transaction.difference > 0 and "+" or "-"
			local name = symbol .. " " .. printName

			draw.SimpleText(plyNick or L"loading", "VoidUI.R18", sc(10), h/2+1, VoidUI.Colors.Gray, TEXT_ALIGN_LEFT, TEXT_ALIGN_CENTER)
			draw.SimpleText(name, "VoidUI.R18", w-sc(10), h/2+1, color, TEXT_ALIGN_RIGHT, TEXT_ALIGN_CENTER)
		end
		
	end

	for k, item in pairs(deposits) do
	
		local printName = inventory:GetPrintName(item.class)
		local rarityColor = inventory:GetRarityColor(item.class)

		local itemPanel = self.inventoryItems:Add("DButton")
		itemPanel:SSetSize(100, 100)
		itemPanel:SetText("")

		local selectedColor = Color(rarityColor.r, rarityColor.g, rarityColor.b, 60)

		itemPanel.Paint = function (s, w, h)
			local bgColor = self.selectedItem == item and selectedColor or VoidUI.Colors.InputLight

			draw.RoundedBox(6, 0, 0, w, h, rarityColor)
			draw.RoundedBox(6, 1, 1, w-2, h-2, VoidUI.Colors.InputLight)
			draw.RoundedBox(6, 1, 1, w-2, h-2, bgColor)
		end


		local model = itemPanel:Add("DModelPanel")
		model:Dock(FILL)
		model:SDockMargin(5, 5, 5, 5)
		model:SetModel(item.model != "" and item.model or "models/error.mdl")

		function model:LayoutEntity() end

		local mn, mx = model.Entity:GetRenderBounds()
		local size = 0
		size = math.max( size, math.abs(mn.x) + math.abs(mx.x) )
		size = math.max( size, math.abs(mn.y) + math.abs(mx.y) )
		size = math.max( size, math.abs(mn.z) + math.abs(mx.z) )

		model:SetFOV( 45 )
		model:SetCamPos( Vector( size, size, size ) )
		model:SetLookAt( (mn + mx) * 0.5 )

		local textSizeWidth = surface.GetTextSize(printName) * 1.2

		

		local modelButton = itemPanel:Add("DButton")
		modelButton:SetText("")
		modelButton:Dock(FILL)
		modelButton.Paint = function (s, w, h)
			local height = h * 0.17
			local y = h-height

			draw.RoundedBox(4, 0, y, w, height, rarityColor)
			local font = #printName > 12 and "VoidUI.R14" or "VoidUI.R18"
			draw.SimpleText(printName, font, w/2, y+height/2-1, VoidUI.Colors.Gray, TEXT_ALIGN_CENTER, TEXT_ALIGN_CENTER)
		end

		modelButton.DoClick = function ()
			local canWithdraw = self.canWithdrawItems
			self.selectedItem = item
			self.withdrawButton:SetEnabled(canWithdraw)
		end

		self.inventoryItems:AddCell(itemPanel, true)
	end
end

function PANEL:PerformLayout(w, h)
    self.container:MarginSides(45, self)
    self.container:MarginTop(10, self)
    self.container:MarginBottom(25, self)

    self.transactionPanel:SSetWide(300, self)

	self.inventoryPanel:MarginRight(10, self)
	self.inventoryPanel:SDockPadding(20, 20, 20, 20, self)

	self.inventoryItems:MarginTop(40, self)
	self.inventoryItems:MarginBottom(20, self)

	self.buttonPanel:SSetTall(30, self)
	self.buttonPanel:MarginSides(60, self)

	self.depositButton:SSetWide(205, self)
	self.withdrawButton:SSetWide(205, self)

	self.transactionHistory:MarginTop(110, self)
	self.transactionHistory:MarginSides(15, self)

	self.transactionButtons:SSetTall(70, self)
	self.transactionButtons:MarginTops(20, self)
	self.transactionButtons:MarginSides(60, self)

	self.transactionContent:MarginTop(30, self)
	
	self.moneyDepositButton:SSetTall(30, self)
	self.moneyWithdrawButton:SSetTall(30, self)
end

vgui.Register("VoidFactions.UI.DepositPanel", PANEL, "VoidUI.PanelContent")
