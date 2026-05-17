BaseWars.Themes = {}

BaseWars.Themes["default"] = {
	-- Name of the theme
	themeName = "Default",

	-- General
	gen_accent = Color(200, 60, 70),
	gen_background = Color(0, 0, 0),
	gen_close = Color(167, 26, 50),
	gen_closeText = color_white,
	button_disabled = Color(175, 30, 55),
	button_green = Color(30, 175, 55),

	-- Printer Upgrade Menu
	printer_text = color_white,
	printer_darkText = Color(120, 120, 120),
	printer_background = Color(37, 40, 47),
	printer_contentBackground = Color(24, 27, 34),
	printer_bypass = Color(26, 167, 50),

	-- Profile Selector
	profileSelector_text = color_white,
	profileSelector_darkText = Color(120, 120, 120),
	profileSelector_background = Color(37, 40, 47),
	profileSelector_contentBackground = Color(24, 27, 34),












	-- General
	ban_chatMessage = Color(255, 154, 13),

	-- Adverts
	adverts_prefix = Color(208, 255, 0),

	-- Boardcast
	broadcast_prefix = Color(0, 230, 255),
	broadcast_text = color_white,

	-- Logs Coloring
	logs_accent = Color(90, 130, 230),
	logs_prefix = Color(180, 30, 30),
	logs_quotes = Color(43, 180, 30),
	logs_extra = Color(0, 255, 234),
	logs_module = Color(255, 123, 0),
	logs_money = Color(208, 255, 0),
	logs_noColor = color_white,

	-- Warnings
	warnings_prefix = Color(210, 25, 25),
	warnings_info = Color(210, 25, 25),
	warnings_text = color_white,

	-- Admin Chat
	adminChat_prefix = Color(80, 210, 30),
	adminChat_text = color_white,

	-- Dashboard
	leaderboard_top1 = Color(255, 215, 0),
	leaderboard_top2 = Color(192, 192, 192),
	leaderboard_top3 = Color(205, 127, 50),

	-- BaseWars Shop
	bws_text = color_white,
	bws_accent = Color(200, 60, 70),
	bws_darkText = Color(120, 120, 120),
	bws_background = Color(30, 26, 28),
	bws_contentBackground = Color(22, 20, 22),
	bws_contentBackground2 = Color(18, 16, 18),
	bws_titleBar = Color(24, 22, 24),
	bws_scroll = Color(26, 24, 26),
	bws_scrollbar = Color(20, 18, 20),
	bws_cantBuy = Color(16, 14, 16),

	-- BaseWars Menu
	bwm_text = Color(255, 255, 255),
	bwm_darkText = Color(120, 120, 120),
	bwm_background = Color(37, 40, 47),
	bwm_contentBackground = Color(24, 27, 34),
	bwm_contentBackground2 = Color(18, 18, 24),
	bwm_titleBar = Color(28, 28, 36),
	bwm_scroll = Color(32, 35, 43),
	bwm_scrollbar = Color(23, 23, 29),

	-- Context Menu
	contextmenu_text = color_white,
	contextmenu_darkText = Color(120, 120, 120),
	contextmenu_background = Color(37, 40, 47),
	contextmenu_contentBackground = Color(24, 27, 34),
	contextmenu_contentBackground2 = Color(18, 18, 24),
	contextmenu_scroll = Color(32, 35, 43),
	contextmenu_scrollbar = Color(23, 23, 29),

	-- Admin Menu
	am_text = color_white,
	am_darkText = Color(120, 120, 120),
	am_background = Color(37, 40, 47),
	am_contentBackground = Color(24, 27, 34),
	am_contentBackground2 = Color(18, 18, 24),
	am_titleBar = Color(28, 28, 36),
	am_scroll = Color(32, 35, 43),
	am_scrollbar = Color(23, 23, 29),

	-- Bounty Menu
	bounty_background = Color(37, 40, 47),
	bounty_contentBackground = Color(24, 27, 34),
	bounty_titleBar = Color(28, 28, 36),
	bounty_text = color_white,text = color_white,
	bounty_darkText = Color(120, 120, 120),

	-- Pay Menu
	pay_background = Color(37, 40, 47),
	pay_contentBackground = Color(24, 27, 34),
	pay_titleBar = Color(28, 28, 36),
	pay_text = color_white,
	pay_darkText = Color(120, 120, 120),

	-- ComboBox
	combobox_background = Color(18, 18, 24),
	combobox_text = color_white,

	-- CheckBox
	checkbox = Color(18, 18, 24),
	checkbox_on = Color(26, 167, 50),
	checkbox_off = Color(167, 26, 50),
	checkbox_text = color_white,
	checkbox_darkText = Color(120, 120, 120),

	-- SpawnPoint
	spawnpoint_spawn = Color(26, 167, 50),
	spawnpoint_titleBar = Color(28, 28, 36),
	spawnpoint_background = Color(37, 40, 47),
	spawnpoint_contentBackground = Color(24, 27, 34),
	spawnpoint_text = color_white,
	spawnpoint_darkText = Color(120, 120, 120),

	-- HUD
	hud_white = color_white,
	hud_black = color_black,
	hud_barBackground = Color(0, 0, 0, 200),
	hud_xpBar2 = Color(255, 255, 255, 200),
	hud_xpText = color_white,
	hud_minimap = Color(50, 50, 50),
	hud_barArmor1 = Color(90, 170, 200),
	hud_barArmor2 = Color(60, 80, 170),
	hud_barHP1 = Color(255, 75, 75),
	hud_barHP2 = Color(150, 0, 0),
	hud_barAmmo1 = Color(180, 120, 0),
	hud_barAmmo2 = Color(200, 180, 30),
	hud_barProps1 = Color(12, 143, 0),
	hud_barProps2 = Color(67, 200, 30),
	hud_minimapAll = Color(5, 240, 255),
	hud_minimapAlly = Color(0, 255, 0),
	hud_minimapEnemy = Color(255, 0, 0),
	hud_minimapYou = color_white,
	hud_minimapSpawnProtection = Color(184, 5, 255),
	hud_armed = Color(178, 23, 23),
	hud_unArmed = Color(22, 188, 27),
	hud_armedPerma = Color(206, 136, 15),
	hud_barEnergy1 = Color(90, 170, 200),
	hud_barEnergy2 = Color(60, 80, 170),

	-- Scoreboard
	scoreboard_text = color_white,
	scoreboard_darkText = Color(120, 120, 120),
	scoreboard_background = Color(37, 40, 47),
	scoreboard_contentBackground = Color(24, 27, 34),
	scoreboard_contentBackground2 = Color(18, 18, 24),
	scoreboard_titleBar = Color(28, 28, 36),
	scoreboard_scroll = Color(32, 35, 43),
	scoreboard_scrollbar = Color(23, 23, 29),
	scoreboard_noPing = Color(185, 0, 0),
	scoreboard_categoryBar = Color(28, 28, 36),

	-- Raid HUD
	raid_background = Color(50, 52, 61),
	raid_time = Color(24, 27, 34),
	raid_text = color_white,

	-- Explosive (When defusing)
	explosive_background = Color(50, 52, 61),
	explosive_bar = Color(24, 27, 34),
	explosive_text = color_white,

	-- Popup
	popup_contentBackgroud =  Color(24, 27, 34),
	popup_text = color_white,
	popup_background = Color(37, 40, 47),
	popup_titleBar = Color(28, 28, 36),

	-- ColorPicker TextEntry Text
	colorpicker_r = Color(200, 20, 20),
	colorpicker_g = Color(30, 200, 30),
	colorpicker_b = Color(0, 120, 255),
}

--[[-------------------------------------------------------------------------
DO NOT TOUCH
---------------------------------------------------------------------------]]
BaseWars.ThemeList = {}
BaseWars.DefaultTheme = {}
for k, v in pairs(BaseWars.Themes) do
	BaseWars.ThemeList[k] = v.themeName
	BaseWars.DefaultTheme[k] = true
end
--[[-------------------------------------------------------------------------
DO NOT TOUCH
---------------------------------------------------------------------------]]