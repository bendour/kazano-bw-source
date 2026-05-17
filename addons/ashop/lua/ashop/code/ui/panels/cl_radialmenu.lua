local PANEL = {}

function PANEL:Init()
	self:MakePopup()
    self:SetSize(ScrW()/2, ScrH()/2)
    self:Center()

	self.c2 = CurTime()
end

function PANEL:CallbackItem(data)
end

function PANEL:DrawItem(data)
end

function PANEL:SetContents(count, tbl)
	assert(count > 0, "Count must be greater than 0")
	local diff = 360 / count
	self.CachedCircle = {}
	self.CachedPos = {}

	local acc = -180 + diff
	local w, h = self:GetSize()
	local externRadius = h/3*1.33

	for i = 0, count-1 do
		table.insert(self.CachedCircle, ashop.ui.CachedCircle(w/2, h/2, externRadius, diff/2, acc, acc + diff))

		local rad = math.rad(acc + diff/2)
		local diffRad = (h/3*1.33 - h/4)/2 + h/4

		// 220
		if tbl[i+1] then
			table.insert(self.CachedPos, { x = -math.sin(rad) * diffRad + w/2, y = math.cos(rad) * diffRad + h/2})
		end
		acc = acc + diff
	end

	self.tbl = tbl
	self.diff = diff
end

function PANEL:OnMousePressed(key)
	if key == MOUSE_LEFT and self.lastHover and self.tbl[self.lastHover] then
		self:CallbackItem(self.tbl[self.lastHover].data)
	end
end

function PANEL:Think()
	//if t then
	//	t(self)
	//end

	if input.IsMouseDown(107) and !self.lastHover and CurTime() - self.c2 > 1 then
		self:Remove()
	end
end

local clrHover = ashop.GetColor('StateOn')
local clrBg = ashop.GetColor('Grad1_1', 220)
local clrOutline = ashop.GetColor('StateOff', 100)
local clrCircle = ashop.GetColor('Grad1_12')

function PANEL:Paint(w, h)
	if !self.CachedCircle then return end

	local innerRadius, externRadius = h / 4, h / 3 * 1.33
	local diff = self.diff
	local centerX, centerY = ScrW() / 2, ScrH() / 2
	local mouseX, mouseY = input.GetCursorPos()
	local ang = math.deg(math.atan2(centerY - mouseY, mouseX - centerX))
	local d = math.Distance( mouseX, mouseY, centerX, centerY )
	local inRadius = d > innerRadius && d < externRadius
	local correctedAngle = -ang + 30 + 180
	local boxSize = ashop.GetSize(32)

	if !self.innerCircle then
		self.innerCircle = ashop.ui.CachedCircle(w / 2, h / 2, innerRadius, 30)
		self.innerCircle2 = ashop.ui.CachedCircle(w / 2, h / 2, externRadius - 4, diff)
	end

	draw.NoTexture()
	for k, v in ipairs(self.CachedCircle) do
		local currentCheckedAng = k * -diff
		surface.SetDrawColor(clrOutline)
		surface.DrawLine(w/2, h/2, externRadius * math.sin(math.rad(currentCheckedAng)) + w/2, externRadius * math.cos(math.rad(currentCheckedAng)) + h/2)
	end

	local lastHover

	for k, v in ipairs(self.CachedCircle) do
		local ang = (-ang + 90) % 360
		local currentCheckedAng = (diff * k) % 360
		local maxCurrentCheckedAng = (currentCheckedAng + diff)
		if inRadius and currentCheckedAng < ang and maxCurrentCheckedAng > ang then
			surface.SetDrawColor(clrHover)
			lastHover = k
		else
			surface.SetDrawColor(clrBg)
		end

		surface.DrawPoly(v)

		if self.tbl[k] and self.CachedPos[k] then
			local cachedPos = self.CachedPos[k]
			self:DrawItem(self.tbl[k].data, cachedPos.x - boxSize, cachedPos.y - boxSize, boxSize*2, boxSize*2, k)
		end
	end

	self.lastHover = lastHover

	surface.SetDrawColor(clrCircle)
	surface.DrawPoly(self.innerCircle)

	if lastHover and self.tbl[lastHover] then
		local _, tH = draw.SimpleText(self.tbl[self.lastHover].name, "ashop_24_600", w/2, h/2, color_white, 1, 1)
		draw.SimpleText(self.desc or "", "ashop_16", w/2, h/2 + tH, color_white, 1, 1)
	end

	ashop.StartStencil()
		surface.SetDrawColor(1, 1, 1, 1)
		surface.DrawPoly(self.innerCircle2)
	ashop.ReplaceStencil(0)
		surface.SetDrawColor(255, 255, 255)
		ashop.ui.DrawCircle(w/2, h/2, externRadius, 30, correctedAngle+40, correctedAngle + 80)
	ashop.EndStencil()
end

derma.DefineControl( "AShop_RadialMenu", "", PANEL, "EditablePanel" )