local PANEL = {}

function PANEL:Init()

	local ply = LocalPlayer()
	local member = VoidFactions.PlayerMember

	local titleAppend = ""
	if (string.find(VoidFactions.CurrentVersion, "beta") or string.find(VoidFactions.CurrentVersion, "alpha")) then
        titleAppend = " (" .. VoidFactions.CurrentVersion .. ")"
    end
	if (VoidFactions.CurrentVersion:sub(1,1) == "{") then
		titleAppend = " (Development Version)"
	end

	self:SSetSize(1100, 650)
	self:MakePopup()
	self:Center()

	self:SetTitle("Kazano - BaseWars" .. titleAppend)


	self.sidebar = self:Add("VoidUI.Sidebar")
	self.sidebar:SetAccentColor(VoidFactions.UI.Accent)

	if (VoidFactions.Settings:IsStaticFactions()) then
		self:CreateStaticFactionTabs()
	elseif (VoidFactions.Settings:IsDynamicFactions()) then
		self:CreateDynamicFactionsTabs()
	end

	-- If VoidFactions isn't set up, then disable the sidebar and jump to a special setup tab
	local isSetup = VoidFactions.Config.FactionType != 0
	if (!isSetup) then
		self.sidebar:SetActive(false)
		local tab = self.sidebar:AddTab("SETUP", VoidUI.Icons.Settings, "VoidFactions.UI.IntroPanel", true)
		self.setupTab = tab
		self.sidebar:SelectTab(tab)
	end

	if ( (CAMI.PlayerHasAccess(ply, "VoidFactions_EditSettings") or CAMI.PlayerHasAccess(ply, "VoidFactions_ManageFactions")) and isSetup) then
		self.sidebar:AddTab("SETTINGS", VoidUI.Icons.Settings, "VoidFactions.UI.SettingsPanel", true)
	end
end

function PANEL:CreateDynamicFactionsTabs()
	local member = VoidFactions.PlayerMember
	local faction = member.faction

	if (faction) then
		self.factionTab = self.sidebar:AddTab("FACTION", VoidUI.Icons.Faction, "VoidFactions.UI.DynamicFactionPanel")

		if (VoidFactions.Config.DepositEnabled) then
			self.depositTab = self.sidebar:AddTab("DEPOSIT", VoidUI.Icons.Deposit, "VoidFactions.UI.DepositPanel")
		end

		self.upgradesTab = self.sidebar:AddTab("UPGRADES", VoidUI.Icons.Upgrades, "VoidFactions.UI.UpgradesPanel")
		self.rewardsTab = self.sidebar:AddTab("REWARDS", VoidUI.Icons.Rewards, "VoidFactions.UI.RewardsPanel")
	else
		self.factionCreateTab = self.sidebar:AddTab("FACTION", VoidUI.Icons.Faction, "VoidFactions.UI.NoFactionPanel")
	end

	self.rankingTab = self.sidebar:AddTab("RANKING", VoidUI.Icons.Stats, "VoidFactions.UI.RankingPanel")
end

function PANEL:CreateStaticFactionTabs()
	local member = VoidFactions.PlayerMember

	self.profileTab = self.sidebar:AddTab("PROFILE", VoidUI.Icons.User, "VoidFactions.UI.ProfilePanel")

	if (member.faction) then
		self.factionTab = self.sidebar:AddTab("FACTION", VoidUI.Icons.Faction, "VoidFactions.UI.FactionPanel")

		if (VoidFactions.Config.UpgradesEnabled) then
			self.upgradesTab = self.sidebar:AddTab("UPGRADES", VoidUI.Icons.Upgrades, "VoidFactions.UI.UpgradesPanel")
		end

		if (VoidFactions.Config.DepositEnabled) then
			self.depositTab = self.sidebar:AddTab("DEPOSIT", VoidUI.Icons.Deposit, "VoidFactions.UI.DepositPanel")
		end
	end

	self.sidebar:AddTab("BOARD", VoidUI.Icons.Board, "VoidFactions.UI.BoardMain")
end

function PANEL:OnKeyCodeReleased(key)
	local keyStr = VoidFactions.Config.MenuBind
	local _key = keyStr and input.GetKeyCode(keyStr) or nil

	if (keyStr and key == _key) then
		self:Remove()
	end
end

vgui.Register("VoidFactions.UI.MainPanel", PANEL, "VoidUI.Frame")