local L = VoidFactions.Lang.GetPhrase
local sc = VoidUI.Scale

local PANEL = {}

function PANEL:Init()
	self:SetOrigSize(1000, 556)
	self:SetTitle(string.upper(L"faction"))

	self.requestedPages = {}
	self.totalFactions = 0

	local container = self:Add("Panel")
	container:Dock(FILL)
	container.Paint = function (s, w, h)
		draw.RoundedBox(8, 0, 0, w, h, VoidUI.Colors.Primary)

		draw.SimpleText(string.upper(L("factionCount", self.totalFactions)), "VoidUI.B22", sc(20), sc(15), VoidUI.Colors.Gray)
		draw.RoundedBox(8, sc(30), sc(55), w-sc(60), sc(30), VoidUI.Colors.BackgroundTransparent)
		local textY = sc(55) + sc(15)

		local baseX = sc(30)
		local textX = sc(45)
		draw.SimpleText(string.upper(L"name"), "VoidUI.B22", textX, textY, VoidUI.Colors.Gray, TEXT_ALIGN_LEFT, TEXT_ALIGN_CENTER)
		
		textX = baseX + sc(320)
		draw.SimpleText(string.upper(L"level"), "VoidUI.B22", textX, textY, VoidUI.Colors.Gray, TEXT_ALIGN_CENTER, TEXT_ALIGN_CENTER)

		textX = baseX + sc(500)
		draw.SimpleText(string.upper(L"members"), "VoidUI.B22", textX, textY, VoidUI.Colors.Gray, TEXT_ALIGN_CENTER, TEXT_ALIGN_CENTER)

		textX = w - baseX - sc(100)
		draw.SimpleText(string.upper(L"actions"), "VoidUI.B22", textX, textY, VoidUI.Colors.Gray, TEXT_ALIGN_CENTER, TEXT_ALIGN_CENTER)
	end

	local rowPanel = container:Add("Panel")
	rowPanel:Dock(FILL)
	rowPanel.Paint = function (s, w, h)
		draw.RoundedBox(8, 0, 0, w, h, VoidUI.Colors.BackgroundTransparent)
	end

	local rowContent = rowPanel:Add("VoidUI.RowPanel")
	rowContent:Dock(FILL)

	local pagination = container:Add("VoidUI.PaginationPanel")
    pagination:Dock(BOTTOM)
    pagination:SetTranslations(L"showingPagination", L"page", L"from")

    pagination:PageChange(function (page)
        self:RequestPage(page)
    end)

	self.container = container
	self.pagination = pagination
	self.rowContent = rowContent
	self.rowPanel = rowPanel

	self:AddHooks()
	self:RequestPage(1)
end

function PANEL:AddHooks()
	hook.Add("VoidFactions.Factions.ReceivedFactionPage", "VoidFactions.UI.FactionSettings.PageReceived", function (page, factions, totalFactions)
		if (!IsValid(self)) then return end
		self.requestedPages[page] = factions
		self:DisplayPage(page)

		if (totalFactions) then
			self.totalFactions = totalFactions
			self.pagination:TotalPages(math.ceil(totalFactions / 8))
		end
	end)
end

function PANEL:OnRemove()
	hook.Remove("VoidFactions.Factions.ReceivedRankingPage", "VoidFactions.UI.FactionSettings.PageReceived")
end

function PANEL:RequestPage(page)
	VoidFactions.Faction:RequestRankingPage(page, 8)
end

function PANEL:DisplayPage(page)
	self.rowContent:Clear()
	self.pagination:CurrentPage(page)
    self.pagination:SetFromTo(page*8-8+1, page*8)

	local member = VoidFactions.PlayerMember
    local memberFaction = member.faction

    local factions = self.requestedPages[page]
    for rank, faction in pairs(factions) do
        local row = self.rowContent:Add("Panel")
        row:Dock(TOP)
        row.Paint = function (self, w, h)
            draw.SimpleText(faction.name, "VoidUI.R22", sc(20), h/2, VoidUI.Colors.Gray, TEXT_ALIGN_LEFT, TEXT_ALIGN_CENTER)
            draw.SimpleText(faction.level, "VoidUI.R22", sc(320), h/2, VoidUI.Colors.Gray, TEXT_ALIGN_CENTER, TEXT_ALIGN_CENTER)
            draw.SimpleText(faction.count .. "/" .. faction:GetMaxMembers(), "VoidUI.R22", sc(500), h/2, VoidUI.Colors.Gray, TEXT_ALIGN_CENTER, TEXT_ALIGN_CENTER)
        end

        local manageButton = row:Add("VoidUI.Button")
        manageButton:SetText(L"manage")

        manageButton:Dock(RIGHT)
        manageButton:SSetWide(100)
        manageButton:SetMedium()
        manageButton:MarginRight(50)
        manageButton.rounding = 14
        
        manageButton.font = "VoidUI.R20"

        manageButton.DoClick = function ()
			local frame = vgui.Create("VoidFactions.UI.FactionCreate")
			frame:EditMode(faction)

			frame:OnSave(function (name)
				faction.name = name
			end)

			frame:OnDelete(function ()
				faction = nil
				row:Remove()
			end)
        end


        self.rowContent:AddRow(row, 23)
    end
end

function PANEL:PerformLayout(w, h)
	self.container:SDockPadding(10, 10, 10, 15, self)

	self.container:MarginSides(45, self)
	self.container:MarginTop(15, self)
	self.container:MarginBottom(35, self)

	self.rowPanel:MarginSides(20, self)
	self.rowPanel:MarginTop(80, self)
	self.rowPanel:MarginBottom(15, self)
	
	self.rowContent:MarginTop(10, self)

	self.pagination:SSetTall(30, self)
	self.pagination:MarginSides(20, self)
end


vgui.Register("VoidFactions.UI.DynamicFactionSettings", PANEL, "VoidUI.PanelContent")