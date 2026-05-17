local L = VoidFactions.Lang.GetPhrase
local sc = VoidUI.Scale

local PANEL = {}

function PANEL:Init()
	self:SetTitle(string.upper(L"profile"))
	self:SetOrigSize(1000, 600)

	local ply = LocalPlayer()
	self.member = VoidFactions.PlayerMember

	local member = self.member

	local leftContainer = self:Add("Panel")
	leftContainer:Dock(LEFT)

	self.leftContainer = leftContainer

	local baseXOffset = 0.05

	local playerCard = leftContainer:Add("VoidUI.BackgroundPanel")
	playerCard:Dock(TOP)

	playerCard.Paint = function (self, w, h)
		draw.RoundedBox(14, 0, 0, w, h, VoidUI.Colors.Primary)
		local x, y = self:LocalToScreen(0, 0)

		local baseX = w * 0.7763 + w * baseXOffset
		local verts = {
			{x = baseX + sc(15), y = 0},
			{x = baseX + sc(30), y = 0},
			{x = baseX + sc(15), y = h},
			{x = baseX, y = h}
		}
		baseX = baseX + sc(25)
		local verts2 = {
			{x = baseX + sc(15), y = 0},
			{x = baseX + sc(40), y = 0},
			{x = baseX + sc(25), y = h},
			{x = baseX, y = h}
		}

		local gradientMove = sc(200)

		VoidUI.StencilMaskStart()
			surface.SetDrawColor(VoidUI.Colors.White)
			draw.NoTexture()
			surface.DrawPoly(verts)
			surface.DrawPoly(verts2)
		VoidUI.StencilMaskApply()
			VoidUI.SimpleLinearGradient(x+0.7086*w, y-gradientMove, sc(200), h+gradientMove*5, VoidUI.Colors.BlueLineGradientEnd, VoidUI.Colors.BlueGradientStart)
		VoidUI.StencilMaskEnd()
	end

	playerCard.avatar = playerCard:Add("AvatarImage")
	playerCard.avatar:Dock(LEFT)
	playerCard.avatar:SetPlayer(ply, 128)
	
	playerCard.info = playerCard:Add("Panel")
	playerCard.info:Dock(LEFT)

	playerCard.info.nick = playerCard.info:Add("DLabel")
	playerCard.info.nick:Dock(TOP)
	playerCard.info.nick:SetText(ply:Nick())
	playerCard.info.nick:SetFont("VoidUI.R30")
	playerCard.info.nick:SetColor(VoidUI.Colors.White)
	playerCard.info.nick:MarginTop(5)
	playerCard.info.nick:SSetTall(32)

	playerCard.info.levelContainer = playerCard.info:Add("Panel")
	playerCard.info.levelContainer:Dock(TOP)
	playerCard.info.levelContainer:MarginTop(20)

	local requiredXP = VoidFactions.XP:GetRequiredXP(member.level)
	local fraction = (member.xp or 0) / requiredXP
	
	playerCard.info.levelContainer.Paint = function (self, w, h)
		draw.SimpleText(string.upper(L"level") .. " " .. member.level, "VoidUI.B24", 0, 0, VoidUI.Colors.White)
		draw.SimpleText((member.xp or 0) .. " / " .. requiredXP .. "  XP", "VoidUI.R24", 0, sc(40), VoidUI.Colors.Gray)
	end

	playerCard.info.levelContainer.progress = playerCard.info.levelContainer:Add("Panel")
	playerCard.info.levelContainer.progress:Dock(TOP)
	playerCard.info.levelContainer.progress:MarginTop(25)
	playerCard.info.levelContainer.progress:SSetTall(15)


	function playerCard.info.levelContainer.progress:Paint(w,h)

		-- If your game crashes, then you fucked up something with the gradient, most likely its color.
		-- (Getting a dynamic mesh without resolving the previous one)

		requiredXP = VoidFactions.XP:GetRequiredXP(member.level)
		fraction = (member.xp or 0) / requiredXP

		local x, y = self:LocalToScreen(0, 0)

		surface.SetMaterial(VoidUI.Icons.RoundedBox)
		surface.SetDrawColor(VoidUI.Colors.Background)
		surface.DrawTexturedRect(0, 0, w, h)

		VoidUI.StencilMaskStart()
			surface.SetMaterial(VoidUI.Icons.RoundedBox)
			surface.SetDrawColor(VoidUI.Colors.White)
			surface.DrawTexturedRect(0, 0, w, h)
		VoidUI.StencilMaskApply()
			VoidUI.SimpleLinearGradient(x, y, w*fraction, h, VoidUI.Colors.BlueGradientStart, VoidUI.Colors.BlueLineGradientEnd, true)
		VoidUI.StencilMaskEnd()
		
	end

	playerCard.info.levelContainer:SetVisible(!VoidFactions.Config.DisableXP)
	

	self.playerCard = playerCard

	local infoCard = leftContainer:Add("VoidUI.BackgroundPanel")
	infoCard:Dock(FILL)

	infoCard.Paint = function (self, w, h)
		draw.RoundedBox(14, 0, 0, w, h, VoidUI.Colors.Primary)

		local x, y = self:LocalToScreen(0, 0)

		local baseX = 0.7265 * w + w * baseXOffset
		local verts = {
			{x = baseX + sc(30), y = 0},
			{x = baseX + sc(45), y = 0},
			{x = baseX + sc(15), y = h},
			{x = baseX, y = h}
		}
		baseX = baseX + sc(25)
		local verts2 = {
			{x = baseX + sc(30), y = 0},
			{x = baseX + sc(55), y = 0},
			{x = baseX + sc(25), y = h},
			{x = baseX, y = h}
		}

		VoidUI.StencilMaskStart()
			surface.SetDrawColor(VoidUI.Colors.White)
			draw.NoTexture()
			surface.DrawPoly(verts)
			surface.DrawPoly(verts2)
		VoidUI.StencilMaskApply()
			VoidUI.SimpleLinearGradient(x+sc(460), y, sc(250), h, VoidUI.Colors.BlueGradientEnd, VoidUI.Colors.BlueGradientStart)
		VoidUI.StencilMaskEnd()
		
	end

	infoCard.textGrid = infoCard:Add("VoidUI.TextGrid")
	infoCard.textGrid:Dock(FILL)
	infoCard.textGrid:SetVerticalMargin(sc(30))
	

	self.factionEntry = infoCard.textGrid:AddEntry(L"faction", member.faction and member.faction.name or "No faction")
	self.joinedEntry = infoCard.textGrid:AddEntry(L"factionJoined", "X!")
	self.rankEntry = infoCard.textGrid:AddEntry(L"rank", member.rank and member.rank.name or "None")
	self.sessionEntry = infoCard.textGrid:AddEntry(L"sessionPlaytime", ply:GetSessionPlaytime())
	self.lastPromoteEntry = infoCard.textGrid:AddEntry(L"lastPromote", (member.lastPromotion != 0 and os.date("%d. %B %Y", member.lastPromotion)) or "Never")
	self.playtimeEntry = infoCard.textGrid:AddEntry(L"totalPlaytime", string.NiceTime(member.playtime * 60))
	self.autoPromoteEntry = infoCard.textGrid:AddEntry(L"nextAutoPromote", "N/A")
	self.autoPromoteEntry:SetVisible(false)


	self.infoCard = infoCard

	local jobPanel = self:Add("VoidUI.BackgroundPanel")
	jobPanel:Dock(RIGHT)
	jobPanel.Paint = function (self, w, h)
		draw.RoundedBox(14, 0, 0, w, h, VoidUI.Colors.Primary)

		local teamName = team.GetName(member.job)

		draw.SimpleText(string.upper(L"currentJob"), "VoidUI.B26", w/2, sc(15), VoidUI.Colors.Blue, TEXT_ALIGN_CENTER, TEXT_ALIGN_TOP)
		draw.SimpleText(string.upper(teamName), "VoidUI.R26", w/2, sc(40), VoidUI.Colors.Gray, TEXT_ALIGN_CENTER, TEXT_ALIGN_TOP)
	end

	jobPanel.model = jobPanel:Add("DModelPanel")
	jobPanel.model:Dock(FILL)
	jobPanel.model:SetFOV(35)
	jobPanel.model:SetModel(ply:GetModel())

	function jobPanel.model:LayoutEntity(ent)
		ent:SetAngles(Angle(0,45,0))
	end

	jobPanel.button = jobPanel:Add("VoidUI.Button")
	jobPanel.button:Dock(BOTTOM)
	jobPanel.button:SetText(L"changeJob")
	jobPanel.button:SetFont("VoidUI.R20")
	jobPanel.button:SetColor(VoidUI.Colors.Blue)
	jobPanel.button.DoClick = function ()
		local selector = vgui.Create("VoidUI.ItemSelect")
		selector:SetParent(self)
		
		local jobTbl = {}
		for _, job in pairs(member.rank.jobs) do
			local jobTeam = job
			if (jobTeam == ply:Team()) then continue end
			jobTbl[jobTeam] = team.GetName(jobTeam)
		end

		selector:InitItems(jobTbl, function (id, v)
			member:ChangeJob(id)
		end)

		local cx, cy = input.GetCursorPos()
		local x, y = jobPanel.button:LocalToScreen(0, 0)
    	selector:SetPos(x - sc(300), cy - sc(150))

		-- local panel = vgui.Create("VoidFactions.UI.JobSelection")


	end

	self.jobPanel = jobPanel

	self:InfoUpdated()

end


function PANEL:InfoUpdated()
	local member = self.member
	local ply = LocalPlayer()

	local faction = member.faction

	self.factionEntry.text = member.faction and member.faction.name or L"none"
	self.joinedEntry.text = (member.factionJoined != 0 and os.date("%d. %B %Y", member.factionJoined)) or L"never"
	self.rankEntry.text = member.rank and member.rank.name or L"none"
	self.lastPromoteEntry.text = (member.lastPromotion != 0 and os.date("%d. %B %Y", member.lastPromotion)) or L"never"
	self.playtimeEntry.text = string.NiceTime(member.playtime * 60)
	if (faction) then
		local nextRank = faction:GetNextRank(member.rank)
		if (nextRank and nextRank.autoPromoteLevel != 0) then
			self.autoPromoteEntry.text = L"level" .. " " .. nextRank.autoPromoteLevel
			self.autoPromoteEntry:SetVisible(true)
		end
	end

	self.jobPanel.model:SetModel(ply:GetModel())
	self.jobPanel.model.Entity:SetSkin(ply:GetSkin())
	for k, v in pairs(ply:GetBodyGroups()) do
		local id = v.id
		local bodygroup = ply:GetBodygroup(id)
		
		self.jobPanel.model.Entity:SetBodygroup(id, bodygroup)
	end

	function self.jobPanel.model.Entity:GetPlayerColor()
		local col = ply:GetPlayerColor()
		return Vector(col.r, col.g, col.b) 
	end


	local showButton = false
	local jobTbl = {}
	for _, job in pairs(member.rank and member.rank.jobs or {}) do
		if (job == ply:Team()) then continue end
		showButton = true
	end

	self.jobPanel.button:SetVisible(showButton)

end

function PANEL:Think()
	if (self.nextThink and self.nextThink > CurTime()) then return end
	self.nextThink = CurTime() + 30

	self.sessionEntry.text = LocalPlayer():GetSessionPlaytime()
end

function PANEL:PerformLayout(w, h)
	self.leftContainer:SSetWide(635, self)
	self.leftContainer:MarginLeft(45, self)
	self.leftContainer:MarginTop(8, self)

	self.playerCard:SSetTall(155, self)
	self.playerCard.avatar:SSetWide(120, self)
	self.playerCard.info:SSetWide(460, self)
	self.playerCard.info.levelContainer:SSetTall(80, self)
	self.playerCard.info.levelContainer:MarginRight(160, self)

	self.infoCard:MarginTop(15, self)
	self.infoCard:MarginBottom(20, self)
	self.infoCard.textGrid:SDockMargin(5, 0, 10, 0, self)

	self.jobPanel:SSetWide(260, self)
	self.jobPanel:MarginTop(10, self)
	self.jobPanel:MarginRight(45, self)
	self.jobPanel:MarginBottom(20, self)

	self.playerCard.info:MarginLeft(20, self)

	self.jobPanel:SDockPadding(20, 40, 20, 20, self)
	self.jobPanel.model:MarginBottom(10, self)

	self.jobPanel.button:SSetTall(35, self)
	self.jobPanel.button:MarginSides(20, self)
	
end


vgui.Register("VoidFactions.UI.ProfilePanel", PANEL, "VoidUI.PanelContent")