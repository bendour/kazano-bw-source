include("shared.lua")
--[[-------------------------------------------------------------------------
Useful functions for nice looks :)
---------------------------------------------------------------------------]]
local function DrawFade(self,w,h,speed,color)
	self.fade = (self.fade or 0)
	if self:IsHovered() then
		self.fade = Lerp(speed,self.fade,255)
	else
		self.fade = Lerp(speed,self.fade,0)
	end
	color.a = self.fade
	draw.RoundedBox(0,2,2,w-4,h-4,color)
end
local function DrawSmallMeme(self,w,h,speed,color)
	self.meme = (self.meme or 0)
	self.meme1 = (self.meme1 or 0)
	if self:IsHovered() then
		self.meme = Lerp(speed,self.meme,w*0.04)
		self.meme1 = Lerp(speed,self.meme1,255)
		if input.IsMouseDown(107) then
			self.meme = Lerp(speed,self.meme,w*0.1)
		end
	else
		self.meme = Lerp(speed,self.meme,0)
		self.meme1 = Lerp(speed,self.meme1,0)
	end
	color.a = self.meme1
	draw.RoundedBox(0,0,0,self.meme,h,color)
	surface.SetDrawColor(color.r,color.g,color.b,color.a)
	surface.DrawOutlinedRect(0,0,w,h)
end

--[[-------------------------------------------------------------------------
Drawing overhead UI etc
---------------------------------------------------------------------------]]
function ENT:Draw()
	self:DrawModel()
	local mypos = self:GetPos()
	if (LocalPlayer():GetPos():Distance(mypos) >= 1000) then return end
	local offset = Vector(0, 0, 50)
	local pos = mypos + offset
	local ang = (LocalPlayer():EyePos() - pos):Angle()
	ang.p = 0
	ang:RotateAroundAxis(ang:Right(), 90)
	ang:RotateAroundAxis(ang:Up(), 90)
	ang:RotateAroundAxis(ang:Forward(), 180)
	cam.Start3D2D(pos,ang,0.04)
		if !self:Getfull() then
			draw.RoundedBoxEx(2^5,-300,0,600,500,Color(0,0,0,150),true,true,false,false)
			draw.RoundedBoxEx(2^5,-300,0,600,100,Color(0,0,0,200),true,true,false,false)
			draw.SimpleText("Lean Ingredients","lean_top",0,50,Color(255,255,255),1,1)
			draw.SimpleText("Sprite: " .. self:Getsprite_num() .. " / " .. lean_updated.requiredsprite.val,"lean_ingredients",0,150,Color(255,255,255),1,1)
			draw.SimpleText("Codeine: " .. self:Getcodeine_num() .. " / " .. lean_updated.requiredcodeine.val,"lean_ingredients",0,250,Color(255,255,255),1,1)
			draw.SimpleText("Ranchers: " .. self:Getranchers_num() .. " / " .. lean_updated.requiredranchers.val,"lean_ingredients",0,350,Color(255,255,255),1,1)
			draw.SimpleText("Ice: " .. self:Getice_num() .. " / " .. lean_updated.requiredice.val,"lean_ingredients",0,450,Color(255,255,255),1,1)
		elseif self:Getfull() && !self:Getextract() && lean_updated.manualshake.val then
			draw.RoundedBoxEx(2^5,-300,0,600,275,Color(0,0,0,150),true,true,false,false)
			draw.RoundedBoxEx(2^5,-300,0,600,100,Color(0,0,0,200),true,true,false,false)
			draw.SimpleText("Lean","lean_top",0,50,Color(255,255,255),1,1)
			draw.SimpleText("Shake!","lean_ingredients",0,150,Color(255,255,255),1,1)
			draw.SimpleText(self:Getshook() .. " / " .. lean_updated.shakeamount.val,"lean_ingredients",0,225,Color(255,255,255),1,1)
		elseif self:Getfull() && !self:Getextract() && !self:Getmixing() && !lean_updated.manualshake.val then
			draw.RoundedBoxEx(2^5,-300,0,600,200,Color(0,0,0,150),true,true,false,false)
			draw.RoundedBoxEx(2^5,-300,0,600,100,Color(0,0,0,200),true,true,false,false)
			draw.SimpleText("Lean","lean_top",0,50,Color(255,255,255),1,1)
			draw.SimpleText("Press E To Mix","lean_ingredients",0,150,Color(255,255,255),1,1)
		elseif self:Getfull() && !self:Getextract() && self:Getmixing() && !lean_updated.manualshake.val then
			draw.RoundedBoxEx(2^5,-300,0,600,200,Color(0,0,0,150),true,true,false,false)
			draw.RoundedBoxEx(2^5,-300,0,600,100,Color(0,0,0,200),true,true,false,false)
			draw.SimpleText("Lean","lean_top",0,50,Color(255,255,255),1,1)
			draw.SimpleText("Mixing","lean_ingredients",0,150,Color(255,255,255),1,1)
		elseif self:Getextract() then
			draw.RoundedBoxEx(2^5,-300,0,600,200,Color(0,0,0,150),true,true,false,false)
			draw.RoundedBoxEx(2^5,-300,0,600,100,Color(0,0,0,200),true,true,false,false)
			draw.SimpleText("Cup Refills","lean_top",0,50,Color(255,255,255),1,1)
			draw.SimpleText(self:Getholding() .. " left","lean_ingredients",0,150,Color(255,255,255),1,1)
		end
	cam.End3D2D()
end

--[[-------------------------------------------------------------------------
Opening the barrel's menu
---------------------------------------------------------------------------]]
net.Receive("LeanMenu", function()
	local ent = net.ReadEntity()
	local main = vgui.Create("DFrame")
	main:SetSize(ScrW()*0.2,ScrH()*0.4)
	main:Center()
	main:MakePopup()
	main:SetAlpha(0)
	main:AlphaTo(255,0.5)
	main:ShowCloseButton(false)
	main:SetTitle("")
	main.Paint = function(self,w,h)
		draw.RoundedBox(0,0,0,w,h,Color(0,0,0,150))
		local poly = {
			{x = 0,y = 0},
			{x = w*0.05,y = h*0.1},
			{x = w*0.95,y = h*0.1},
			{x = w,y = 0}
		}
		surface.SetDrawColor(0,0,0,200)
		surface.DrawPoly(poly)
		draw.SimpleText("Lean Ingredients","Trebuchet24",w/2,h*0.05,Color(255,255,255),1,1)
	end
	local close = vgui.Create("DButton",main)
	close:SetSize(main:GetWide()*0.9,20)
	close:SetPos(main:GetSize()/2 - close:GetWide()/2,main:GetTall()*0.94)
	close:SetText("")
	close.Paint = function(self,w,h)
		draw.RoundedBox(0,0,0,w,h,Color(50,50,50))
		draw.RoundedBox(0,2,2,w-4,h-4,Color(0,0,0))
		draw.SimpleText("Close","Trebuchet18",w/2,h/2,Color(255,255,255),1,1)
	end
	close.DoClick = function()
		main:Close()
	end
	local scroll = vgui.Create("DScrollPanel",main)
	scroll:StretchToParent(20,60,20,25)
	local container = vgui.Create("DListLayout",scroll)
	container:SetSize(scroll:GetWide(),scroll:GetTall())
	-- Sprite
	local sprite = vgui.Create("DButton",container)
	sprite:SetSize(container:GetWide(),main:GetTall()*0.2)
	sprite:SetText("")
	sprite:SetTooltip(lean_updated.currency.val .. string.Comma(lean_updated.sprite_price.val))
	sprite.Paint = function(self,w,h)
		draw.RoundedBox(0,0,0,w,h,Color(50,50,50))
		draw.RoundedBox(0,4,4,w-8,h-8,Color(0,0,0))
		DrawSmallMeme(self,w,h,0.05,Color(255,255,255))
		draw.SimpleText("Sprite: " .. ent:Getsprite_num() .. " / " .. lean_updated.requiredsprite.val,"Trebuchet24",w/2,h/2,Color(255,255,255),1,1)
	end
	sprite.DoClick = function()
		if ent:Getfull() then
			main:Close()
			return
		end
		net.Start("lean_buyingredient")
		net.WriteString("sprite")
		net.WriteEntity(ent)
		net.SendToServer()
	end
	-- Codeine
	local codeine = vgui.Create("DButton",container)
	codeine:SetSize(container:GetWide(),main:GetTall()*0.2)
	codeine:SetText("")
	codeine:SetTooltip((lean_updated.currency.val .. string.Comma(lean_updated.codeine_price.val)))
	codeine.Paint = function(self,w,h)
		draw.RoundedBox(0,0,0,w,h,Color(50,50,50))
		draw.RoundedBox(0,4,4,w-8,h-8,Color(0,0,0))
		DrawSmallMeme(self,w,h,0.05,Color(255,255,255))
		draw.SimpleText("Codeine: " .. ent:Getcodeine_num() .. " / " .. lean_updated.requiredcodeine.val,"Trebuchet24",w/2,h/2,Color(255,255,255),1,1)
	end
	codeine.DoClick = function()
		if ent:Getfull() then
			main:Close()
			return
		end
		net.Start("lean_buyingredient")
		net.WriteString("codeine")
		net.WriteEntity(ent)
		net.SendToServer()
	end
	-- Ranchers
	local ranchers = vgui.Create("DButton",container)
	ranchers:SetSize(container:GetWide(),main:GetTall()*0.2)
	ranchers:SetText("")
	ranchers:SetTooltip((lean_updated.currency.val .. string.Comma(lean_updated.ranchers_price.val)))
	ranchers.Paint = function(self,w,h)
		draw.RoundedBox(0,0,0,w,h,Color(50,50,50))
		draw.RoundedBox(0,4,4,w-8,h-8,Color(0,0,0))
		DrawSmallMeme(self,w,h,0.05,Color(255,255,255))
		draw.SimpleText("Jolly-Ranchers: " .. ent:Getranchers_num() .. " / " .. lean_updated.requiredranchers.val,"Trebuchet24",w/2,h/2,Color(255,255,255),1,1)
	end
	ranchers.DoClick = function()
		if ent:Getfull() then
			main:Close()
			return
		end
		net.Start("lean_buyingredient")
		net.WriteString("ranchers")
		net.WriteEntity(ent)
		net.SendToServer()
	end
	-- Ice Cubes
	local ice = vgui.Create("DButton",container)
	ice:SetSize(container:GetWide(),main:GetTall()*0.2)
	ice:SetText("")
	ice:SetTooltip((lean_updated.currency.val .. string.Comma(lean_updated.ice_price.val)))
	ice.Paint = function(self,w,h)
		draw.RoundedBox(0,0,0,w,h,Color(50,50,50))
		draw.RoundedBox(0,4,4,w-8,h-8,Color(0,0,0))
		DrawSmallMeme(self,w,h,0.05,Color(255,255,255))
		draw.SimpleText("Ice Cubes: " .. ent:Getice_num() .. " / " .. lean_updated.requiredice.val,"Trebuchet24",w/2,h/2,Color(255,255,255),1,1)
	end
	ice.DoClick = function()
		/* 00000000000000000 */
		if ent:Getfull() then
			main:Close()
			return
		end
		net.Start("lean_buyingredient")
		net.WriteString("ice")
		net.WriteEntity(ent)
		net.SendToServer()
	end
end)