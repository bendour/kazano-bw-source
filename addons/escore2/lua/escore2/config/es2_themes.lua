local skin = {}
skin.name = "Dark"
skin.color = Color(13,13,13)
skin.colors = {}
skin.colors.main = {
	bg = Color(26, 27, 30, 200),
	bg2 = Color(26, 27, 30, 200),
	text = Color(255,255,255),
	icon = Color(210,170,220),
	text_hover = Color(206, 169, 255),
	sub_title = Color(233,233,233),
}
skin.colors.player = {
	bg = Color(26, 27, 30, 230),
	bg_hover = Color(43, 40, 47),
	bg2 = Color(26, 27, 30),
	text = Color(220,220,220),
	text_hover = Color(255,255,255),
	text_gray = Color(150, 150, 152),
	money = Color(80, 255, 140),
	me = Color(255, 240, 105),
	friend = Color(172, 255, 214),
	time = Color(80, 220, 255),
}
skin.colors.ping = {
	bg = Color(100,100,100),
	text = Color(120,120,120),
	good = Color(80, 255, 140),
	medium = Color(255,255,0),
	bad = Color(255,30,0)
}
skin.colors.search = {
	bg = Color(26, 27, 30, 230),
	text = Color(255,255,255),
	text_gray = Color(150,150,150),
	highlight = Color(80, 255, 140),
}

escore2.addon:RegisterSkin("dark", skin)
escore2.addon:SetDefaultSkin("dark")