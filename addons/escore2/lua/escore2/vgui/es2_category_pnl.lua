local PANEL = {}

AccessorFunc(PANEL, "text", "Text")
AccessorFunc(PANEL, "font", "Font")
AccessorFunc(PANEL, "icon", "Icon")
AccessorFunc(PANEL, "color", "Color")
AccessorFunc(PANEL, "icon_color", "IconColor")
AccessorFunc(PANEL, "player", "Player")

function PANEL:Init()
    self.shadow_color = Color(0,0,0, 150)
end


function PANEL:Paint(w,h)
    -- draw.RoundedBox(8, 0,0,w,h,clr.main.bg2)
    -- draw.RoundedBox(0,text_w+35, h*0.5, w-text_w-40, 6, clr.main.bg)
    -- draw.RoundedBox(0,0, h*0.5, 15, 6, clr.main.bg)
    esclib.draw:MaterialCenteredShadowed(h*0.5, h*0.5+2, h*0.25, self.icon_color, self.icon, 1, self.shadow_color)
    esclib.draw:ShadowText(self.text, self.font, h+2, h*0.5, self.color, TEXT_ALIGN_LEFT, TEXT_ALIGN_CENTER, 2)
end

vgui.Register( "escore2.category_pnl", PANEL, "DPanel" );
