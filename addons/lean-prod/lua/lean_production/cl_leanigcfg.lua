if !CLIENT then return end
local OpenPnl = (OpenPnl or nil)
local function DrawSmall(self,w,h,speed,color)
	self.small = (self.small or 0)
	self.small1 = (self.small1 or 0)
	if self:IsHovered() && OpenPnl ~= self then
		self.small = Lerp(speed,self.small,w*0.1)
		self.small1 = Lerp(speed,self.small1,255)
	elseif OpenPnl == self then
		self.small = Lerp(speed,self.small,w)
	else
		self.small = Lerp(speed,self.small,0)
		self.small1 = Lerp(speed,self.small1,0)
	end
	color.a = self.small1
	draw.RoundedBox(0,0,0,self.small,h,color)
	surface.SetDrawColor(color.r,color.g,color.b,color.a)
	surface.DrawOutlinedRect(0,0,w,h)
end
--[[-------------------------------------------------------------------------
Our function for the in-game config
---------------------------------------------------------------------------]]
local pnl = (pnl or nil)
function LeanMenu()
	local sw = ScrW()
	local sh = ScrH()
	local main = vgui.Create("DFrame")
	main:SetSize(sw*0.5,sh*0.3)
	main:Center()
	main:SetTitle("")
	main:MakePopup()
	main:ShowCloseButton(false)
	main.Paint = function(self,w,h)
		draw.RoundedBox(0,w*0.1,0,w,h,Color(0,0,0,200))
		draw.RoundedBox(0,w*0.1,0,w,h*0.1,Color(0,0,0,250))
		draw.SimpleText("Lean Config","Trebuchet18",w/2,h*0.05,Color(255,255,255),1,1)
		if OpenPnl == nil then
			draw.SimpleText("Select a category on the left.","DermaLarge",w/2,h/2,Color(255,255,255),1,1)
		end
	end
	local scroll = vgui.Create("DScrollPanel",main)
	scroll:SetSize(main:GetWide()*0.1,main:GetTall())
	scroll:GetVBar().Paint = function(self,w,h)
		draw.RoundedBox(0,0,0,w,h,Color(0,0,0,250))
	end
	scroll:GetVBar().btnUp.Paint = function() return end
	scroll:GetVBar().btnDown.Paint = function() return end
	scroll:GetVBar().btnGrip.Paint = function() return end
	scroll.OnScrollbarAppear = function() return end
	local container = vgui.Create("DListLayout",scroll)
	container:SetSize(scroll:GetWide()-scroll:GetWide()*0.15,scroll:GetTall())
	container.Paint = function(self,w,h)
		surface.SetDrawColor(Color(0,0,0))
		surface.DrawOutlinedRect(0, 0, w, h)
	end
	for k, v in ipairs(lean_config.categories) do
		local btn = vgui.Create("DButton",container)
		btn:SetSize(container:GetWide(),main:GetTall()*0.146)
		btn:SetText("")
		btn.Paint = function(self,w,h)
			draw.RoundedBox(0,0,0,w,h,Color(0,0,0,200))
			DrawSmall(self,w,h,0.05,Color(15,15,15))
			draw.SimpleText(v,"Trebuchet18",w/2,h/2,Color(255,255,255),1,1)
		end
		btn.DoClick = function(self)
			if OpenPnl ~= nil then
				pnl:Remove()
			end
			OpenPnl = self
			pnl = vgui.Create("DPanel",main)
			pnl:SetSize(main:GetWide()*0.9,main:GetTall()*0.9)
			pnl:SetPos(main:GetWide()*0.1,main:GetTall()*0.1)
			pnl.Paint = function(self,w,h)
				draw.RoundedBox(0,0,0,w,h,Color(0,0,0,150))
			end
			local inscroll = vgui.Create("DScrollPanel",pnl)
			inscroll:StretchToParent(0,0,0,0)
			local inlist = vgui.Create("DListLayout",inscroll)
			inlist:SetSize(inscroll:GetWide(),inscroll:GetTall())
			for u, i in pairs(lean_updated) do
				if i.category == v then
					local inner = vgui.Create("DPanel",inlist)
					inner:SetSize(0,pnl:GetTall()*0.15)
					inner.Paint = function(self,w,h)
						draw.RoundedBox(0,0,0,w,h,Color(0,0,0,200))
						draw.SimpleText(i.name,"Trebuchet18",5,h/2,Color(255,255,255),0,1)
					end
					local spacing = vgui.Create("DPanel",inlist)
					spacing:SetSize(0,pnl:GetWide()*0.01)
					spacing.Paint = function(self,w,h)
						return
					end
					local desc = vgui.Create("DButton", inner)
					desc:SetSize(pnl:GetWide()*0.3,pnl:GetTall()*0.1)
					desc:SetPos(inlist:GetWide()*0.25,inner:GetTall()*0.15)
					desc:SetText("")
					desc:SetTooltip(i.desc)
					desc.Paint = function(self,w,h)
						draw.RoundedBox(0,0,0,w,h,Color(75,75,75,100))
						draw.SimpleText("Description","Trebuchet18",w/2,h/2,Color(255,255,255),1,1)
					end
					local submit = vgui.Create("DButton", inner)
					submit:SetSize(pnl:GetWide()*0.15,pnl:GetTall()*0.07)
					submit:SetPos(inlist:GetWide()*0.7,inner:GetTall()*0.3)
					submit:SetText("")
					submit.Paint = function(self,w,h)
						draw.RoundedBox(0,0,0,w,h,Color(75,75,75,100))
						draw.SimpleText("Submit","Trebuchet18",w/2,h/2,Color(255,255,255),1,1)
					end
					if isnumber(i.val) then
						local update = vgui.Create("DNumberWang", inner)
						update:SetSize(pnl:GetWide()*0.1,pnl:GetTall()*0.07)
						update:SetPos(inlist:GetWide()/1.15,inner:GetTall()*0.3)
						update:SetMax(9e9)
						update:SetValue(i.val)
						submit.DoClick = function()
							net.Start("lean_updatecfg")
							net.WriteString(u)
							net.WriteString("int")
							net.WriteInt(update:GetValue(),32)
							net.SendToServer()
						end
					end
					if istable(i.val) and table.IsSequential(i.val) then
						local update = vgui.Create("DTextEntry", inner)
						update:SetSize(pnl:GetWide()*0.1,pnl:GetTall()*0.07)
						update:SetPos(inlist:GetWide()/1.15,inner:GetTall()*0.3)
						update:SetTooltip("Seperate values using a comma (,)")
						update:SetText(table.concat(i.val,","))
						submit.DoClick = function()
							net.Start("lean_updatecfg")
							net.WriteString(u)
							net.WriteString("tbl")
							net.WriteTable(string.Explode(",",update:GetValue()))
							net.SendToServer()
						end
					end
					if istable(i.val) and not table.IsSequential(i.val) then
						local update = (update or nil)
						local keys = table.GetKeys(i.val)
						for _, o in ipairs(keys) do
							if o == ("r" or "g" or "b" or "a") then
								update = vgui.Create("DTextEntry", inner)
								update:SetSize(pnl:GetWide()*0.1,pnl:GetTall()*0.07)
								update:SetPos(inlist:GetWide()/1.15,inner:GetTall()*0.3)
								update:SetTooltip("Seperate colour values with a space ( )")
								update:SetText(i.val.r .. " " .. i.val.g .. " " .. i.val.b .. " " .. i.val.a)
								break
							end
						end
						submit.DoClick = function()
							net.Start("lean_updatecfg")
							net.WriteString(u)
							net.WriteString("col")
							net.WriteColor(string.ToColor(update:GetValue()))
							net.SendToServer()
						end
					end
					if isbool(i.val) then
						local update = vgui.Create("DCheckBox", inner)
						update:SetSize(pnl:GetWide()*0.03,pnl:GetWide()*0.03)
						update:SetPos(inlist:GetWide()/1.1,inner:GetTall()*0.3)
						update:SetTooltip("Tick for true, untick for false")
						update:SetChecked(i.val)
						submit.DoClick = function()
							local ticked = (ticked or nil)
							if update:GetChecked() then
								ticked = true
							else
								ticked = false
							end
							net.Start("lean_updatecfg")
							net.WriteString(u)
							net.WriteString("bool")
							net.WriteBool(ticked)
							net.SendToServer()
						end
					end
					if isstring(i.val) then
						local update = vgui.Create("DTextEntry", inner)
						update:SetSize(pnl:GetWide()*0.1,pnl:GetTall()*0.07)
						update:SetPos(inlist:GetWide()/1.15,inner:GetTall()*0.3)
						update:SetText(i.val)
						submit.DoClick = function()
							net.Start("lean_updatecfg")
							net.WriteString(u)
							net.WriteString("str")
							net.WriteString(update:GetValue())
							net.SendToServer()
							
						end
					end
				end
			end
		end
	end
	local close = vgui.Create("DButton",main)
	close:SetSize(20,20)
	close:SetPos(main:GetWide()-close:GetWide()-5,5)
	close:SetText("")
	close.Paint = function(self,w,h)
		draw.RoundedBox(0,0,0,w,h,Color(255,0,0))
		draw.SimpleText("X","Trebuchet18",w/2,h/2,Color(255,255,255),1,1)
	end
	close.DoClick = function()
		main:Close()
		OpenPnl = nil
	end
end
--[[-------------------------------------------------------------------------
Receiving the net messages and providing the menu / updated values
---------------------------------------------------------------------------]]
net.Receive("LeanigConfig", LeanMenu)
net.Receive("lean_initialupdate", function()
	local new = net.ReadTable()
	lean_updated = new
end)