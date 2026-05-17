local PANEL={}
AccessorFunc(PANEL, "color", "Color", FORCE_COLOR)
AccessorFunc(PANEL, "border_color", "BorderColor", FORCE_COLOR)

function PANEL:Init()

	self.clr = esclib.addon:GetColors()

	self:SetColor(self.clr.button.main)
	self:SetBorderColor(self.clr.button.hover)

	local parent = self:GetParent()
	local outpnl = vgui.Create("DButton",parent)
	outpnl:SetSize(parent:GetWide(),parent:GetTall())
	outpnl:SetText("")
	outpnl:SetZPos(10)
	outpnl.Paint = nil
	outpnl:SetCursor("arrow")
	self.contextbackground = outpnl
	function outpnl:Close()
		self:SizeTo(1,1,esclib.addon:GetVar("animtime")*1.1,0,-1,function()
			self:Remove()
		end)
	end
	function outpnl.DoClick()
		outpnl:Close()
		if IsValid(self) then self:Close(true) end
	end
	function outpnl.DoRightClick()
		outpnl:Close()
		if IsValid(self) then self:Close(true) end
	end
	parent.contextbg = outpnl

	self.headerfont = esclib:AdaptiveFont("esclib", 18, 500)
	self.buttonfont = esclib:AdaptiveFont("esclib", 18, 500)

	self.border = 5
	self.buttonheight = math.max(draw.GetFontHeight(self.headerfont),draw.GetFontHeight(self.buttonfont)) + 10
	self.sepheight = 2
	self.spacey = 0

	self.player = LocalPlayer()
	self:SetParent(outpnl)

	self:SetSize(100,self.buttonheight)
	self.list = vgui.Create("DIconLayout", self)
	self.list:SetBorder(self.border)
	self.list:SetSpaceY(self.spacey)
	self.list:SetSize(self:GetWide()+self.list:GetBorder()*2,self:GetSize())
end

function PANEL:SetWide(wide)
	self:SetSize(wide+self.list:GetBorder()*2,self:GetTall())
	self.list:SetSize(wide+self.list:GetBorder()*2,self:GetTall())
end

function PANEL:Close(anim)
	if anim then
		self:SizeTo(1,1,esclib.addon:GetVar("animtime"),0,-1,function()
			self:Remove()
			if IsValid(self.contextbackground) then self.contextbackground:Remove() end
		end)
	else
		self:Remove()
		if IsValid(self.contextbackground) then self.contextbackground:Remove() end
	end
end

function PANEL:SetPly(ply)
	self.player = ply
end

function PANEL:GetPly(ply)
	return self.player
end

function PANEL:SetPosClamped(posx,posy)
	local x = math.Clamp( posx, 0, ScrW() - self:GetWide() )
	local y = math.Clamp( posy, 0, ScrH() - self:GetTall() )
	self:SetPos(x,y)
end

function PANEL:E_InvalidateLayout()
	local sizex = 1
	local sizey = 0
	for _,v in ipairs(self.list:GetChildren()) do
		local textsize = {w = 200, h = 100}
		if v.text then
			textsize = esclib.util.GetTextSize(v.text,self.buttonfont)
		end
		if v.icon then
			textsize.w = textsize.w + v:GetTall()*0.35 + 10
		end
		sizex = math.max(sizex,textsize.w+40)
		sizey = sizey + v:GetTall() + self.spacey
	end

	self:SetSize(sizex+self.list:GetBorder()*2, sizey+self.list:GetBorder()*2 )
	self.list:SetSize(self:GetWide(),self:GetSize())
	self.contextbackground:SetZPos(10)

	for _,v in ipairs(self.list:GetChildren()) do
		v:SetWide(sizex)
		if IsValid(v.lbl) then
			v.lbl:Center()
		end
	end
end

function PANEL:AddButton(text,func,icon)
	local button = vgui.Create("DButton",self.list)
	button:SetSize(self.list:GetWide(), self.buttonheight)
	button:SetText("")

	AccessorFunc(button, "text", "Text")
	AccessorFunc(button, "TextColor", "TextColor", FORCE_COLOR)
	AccessorFunc(button, "TextHoverColor", "TextHoverColor", FORCE_COLOR)
	AccessorFunc(button, "IconColor", "IconColor", FORCE_COLOR)
	AccessorFunc(button, "IconHoverColor", "IconHoverColor", FORCE_COLOR)
	AccessorFunc(button, "Color_Hover", "ColorHover", FORCE_COLOR)
	AccessorFunc(button, "icon", "Icon")
	AccessorFunc(button, "font", "Font")
	AccessorFunc(button, "func", "Func")

	button:SetTextColor(self.clr.button.text)
	button:SetTextHoverColor(self.clr.button.text_hover)
	button:SetIconColor(self.clr.button.text)
	button:SetIconHoverColor(self.clr.button.text_hover)
	button:SetColorHover(self.clr.button.hover)
	button:SetFont(self.buttonfont)

	button:SetText(text)
	button:SetIcon(icon)
	button:SetFunc(func)

	function button:Paint(w,h)
		local hover = self:IsHovered()

		if hover then
			draw.RoundedBox(8,0,0,w,h,self.Color_Hover)
		end

		draw.SimpleText(self.text,self.font,self.icon and h*0.3*2+15 or 10,h*0.5,hover and self.TextHoverColor or self.TextColor,TEXT_ALIGN_LEFT,TEXT_ALIGN_CENTER)

		if self.icon then
			esclib.draw:MaterialCentered(h*0.35+5, h*0.5, h*0.3, hover and self.TextHoverColor or self.TextColor, self.icon)
		end
	end

	function button.DoClick()
		self:Close()
		button.func(self.player)
	end

	function button:SetTextColor(col)
		if IsColor(col) then self.TextColor = col end
	end

	function button:SetTextHoverColor(col)
		if IsColor(col) then self.TextHoverColor = col end
	end

	function button:SetIconColor(col)
		if IsColor(col) then self.IconColor = col end
	end

	function button:SetIconHoverColor(col)
		if IsColor(col) then self.IconHoverColor = col end
	end

	self:E_InvalidateLayout()
	return button
end

function PANEL:IsMouseInside()
    local mouseX, mouseY = gui.MousePos()
    local panelX, panelY = self:GetPos()
    local panelWide, panelTall = self:GetSize()

    return mouseX >= panelX and mouseX <= panelX + panelWide and mouseY >= panelY and mouseY <= panelY + panelTall
end

function PANEL:OnClick()
end

function PANEL:AddHeader(text,col)
	local pnl = vgui.Create("DPanel",self.list)

	AccessorFunc(pnl, "TextColor", "TextColor", FORCE_COLOR)
	AccessorFunc(pnl, "font", "Font")

	pnl:SetTextColor(col or self.clr.frame.text)
	pnl:SetFont(self.headerfont)
	pnl:SetSize(self.list:GetWide(), self.buttonheight)
	pnl.text = text
	function pnl.Paint(pnl,w,h)
		-- draw.RoundedBox(8,0,0,w,h,self.clr.frame.accent)
		draw.SimpleText(text, pnl.font, w*0.5, h*0.5, pnl.TextColor, TEXT_ALIGN_CENTER, TEXT_ALIGN_CENTER)
	end

	function pnl:SetTextColor(col)
		if IsColor(col) then self.TextColor = col end
	end

	self:E_InvalidateLayout()
	return pnl
end

function PANEL:AddSeparator()
	local pnl = vgui.Create("DPanel",self.list)
	pnl.text = ""
	local sepheight = self.sepheight
	AccessorFunc(pnl, "Color", "Color", FORCE_COLOR)
	pnl:SetSize(self.list:GetWide(), sepheight+self.border)
	pnl:SetColor(self.border_color)
	pnl.Paint = function(pnl, w,h)
		surface.SetDrawColor(pnl.Color)
		surface.DrawRect(0,(h-sepheight)*0.5,w,sepheight)
	end
	self:E_InvalidateLayout()
	return pnl
end

function PANEL:AddSubMenu(text, icon)
	local parent = self
    local subMenu = vgui.Create("esclib.contextmenu", self:GetParent())
    subMenu:SetParent(self:GetParent())
	subMenu:SetZPos(self:GetZPos()+1)
	subMenu:SetColor(self:GetColor())
	subMenu:SetBorderColor(self:GetBorderColor())
	subMenu.contextbackground:Remove()
	subMenu.contextbackground = self.contextbackground
	subMenu:SetMouseInputEnabled(true)

    local button = self:AddButton(text, function() end, icon)
	function button:PaintOver(w,h)
		draw.SimpleText(">", self.font, w-10, h*0.5, self.TextColor, TEXT_ALIGN_RIGHT, TEXT_ALIGN_CENTER)
	end
	local x,y = button:LocalToScreen(0,0)

	local next_check = 0
    function button:Think()
		if not IsValid(subMenu) then 
			self:Remove() 
			return 
		end

		if self:IsHovered() or (subMenu:IsMouseInside() and subMenu:IsVisible()) then
			next_check = CurTime() + 0.2
		end

		if CurTime() <= next_check then
			subMenu:Show()
			local x,y = button:LocalToScreen(0,0)
			subMenu:SetPosClamped(x+self:GetWide()+parent.border*2, y)
		elseif subMenu:IsVisible() then
			subMenu:Hide()
		end
    end

    return button, subMenu
end



function PANEL:Paint(w,h)
	draw.RoundedBox(8,0,0,w,h,self.border_color)
	draw.RoundedBox(6,2,2,w-4,h-4,self.color)
end


vgui.Register( "esclib.contextmenu", PANEL )