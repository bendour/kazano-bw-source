esclib.draw = {}

local clr_white = Color(255,255,255)
local clr_shadow = Color(30,30,33,200)

local sin = math.sin
local cos = math.cos
local rad = math.rad
local min = math.min

------------
--# TEXT #--
------------
function esclib.draw:ShadowText(text,font,px,py,col,textax,textay,offset,clr)
	local textax = textax or TEXT_ALIGN_LEFT
	local textay = textay or TEXT_ALIGN_TOP
	local offset = offset or 2

	draw.SimpleText(text,font, px+offset, py+offset, clr or clr_shadow, textax, textay)
	draw.SimpleText(text,font, px, py, col, textax, textay)
end

--------------
--# CIRCLE #--
--------------
function esclib.draw:GenCircle(x,y,r,v)
	local circle = {}
	local v = v or 360 -- poly count
    local angle = -rad(0) -- start angle
    local esin, ecos = sin(angle), cos(angle)
    for i = 0, 360, 360 / v do
        local newang = rad(i)
        local newsin, newcos = sin(newang), cos(newang)

        local oldcos = newcos * r * ecos - newsin * r * esin + x
        newsin = newcos * r * esin + newsin * r * ecos + y
        newcos = oldcos

        circle[#circle + 1] = {x = newcos,y = newsin}
    end
    return circle
end

function esclib.draw:PolyCircle( x, y, r, col, v)
	local circle = self:GenCircle(x,y,r, v or 360)

	if circle and #circle > 0 then
		surface.SetDrawColor(col:Unpack())
		draw.NoTexture()
		surface.DrawPoly(circle)
	end
end

function esclib.draw:Circle(x,y,r,col)
	local clr = esclib.addon:GetColors()

	x = x - r
	y = y - r
	col = col or clr_white

	surface.SetDrawColor(col:Unpack())
	surface.SetMaterial(esclib:GetMaterial("circle.png"))
	surface.DrawTexturedRect(x, y, r*2, r*2)
end

-------------
--# OTHER #--
-------------
function esclib.draw:Mask(func, drawfunc, inverse, reference)
	if not reference then reference = 1 end

	render.ClearStencil()
	render.SetStencilEnable(true)

	render.SetStencilWriteMask(1)
	render.SetStencilTestMask(1)

	render.SetStencilFailOperation(STENCILOPERATION_REPLACE)
	render.SetStencilPassOperation(inverse and STENCILOPERATION_REPLACE or STENCILOPERATION_KEEP)
	render.SetStencilZFailOperation(STENCILOPERATION_KEEP)
	render.SetStencilCompareFunction(STENCILCOMPARISONFUNCTION_NEVER)
	render.SetStencilReferenceValue(reference)

	func()

	if inverse then reference = reference - 1 end
	render.SetStencilFailOperation(inverse and STENCILOPERATION_REPLACE or STENCILOPERATION_KEEP)
	render.SetStencilPassOperation(STENCILOPERATION_REPLACE)
	render.SetStencilZFailOperation(STENCILOPERATION_KEEP)
	render.SetStencilCompareFunction(STENCILCOMPARISONFUNCTION_EQUAL)
	render.SetStencilReferenceValue(reference)

	drawfunc()

	render.SetStencilEnable(false)
	render.ClearStencil()
end

-----------------
--# MATERIALS #--
-----------------
function esclib.draw:Material(x,y,w,h,col,mat)
	if not mat then return end
	col = col or color_white
	surface.SetDrawColor(col.r,col.g,col.b,col.a)
    surface.SetMaterial(mat)
    surface.DrawTexturedRect(x,y,w,h)
end

function esclib.draw:MaterialRotated(x,y,w,h,r,col,mat)
	if not mat then return end
	col = col or color_white
	surface.SetDrawColor(col.r,col.g,col.b,col.a)
    surface.SetMaterial(mat)
    surface.DrawTexturedRectRotated(x,y,w,h,r)
end

function esclib.draw:MaterialCentered(x,y,r,col,mat)
	self:Material(x-r, y-r, r*2, r*2, col, mat)
end

function esclib.draw:MaterialCenteredF(x,y,w,h,col,mat)
	self:Material(x-w*0.5, y-h*0.5, w, h, col, mat)
end

function esclib.draw:MaterialCenteredRotated(x,y,r,rot,col,mat)
	self:MaterialRotated(x, y, r*2, r*2, rot, col, mat)
end

function esclib.draw:MaterialCenteredShadowed(x,y,r,col,mat,offset, shadowcolor)
	local offset = offset or 1
	local shadowcolor = shadowcolor or clr_shadow
	self:Material(x-r+offset, y-r+offset, r*2+offset, r*2+offset, shadowcolor, mat)
	self:Material(x-r, y-r, r*2, r*2, col, mat)
end




-- https://dl.dropboxusercontent.com/u/104427432/Scripts/drawarc.lua
-- https://facepunch.com/showthread.php?t=1438016&p=46536353&viewfull=1#post46536353
function esclib.draw:SurfaceArc(arc,todraw)
	local todraw = min(#arc, (todraw or math.huge) )
	draw.NoTexture()
	for i=1,todraw do
		surface.DrawPoly(arc[i])
	end
end

function esclib.draw:Arc(cx,cy,radius,thickness,startang,endang,roughness,color,bClockwise)
	surface.SetDrawColor(color.r,color.g,color.b,color.a)
	local arc = esclib.util.PrecacheArc(cx,cy,radius,thickness,startang,endang,roughness,bClockwise) or {}
	esclib.draw:SurfaceArc(arc)
end

local blur = Material("pp/blurscreen")
function esclib.draw:Blur(pnl,amount)
	local x, y, w, h = pnl:GetBounds(0, 0)
    surface.SetDrawColor(color_white:Unpack())
    surface.SetMaterial(blur)
    for i = 1, amount do
        blur:SetFloat("$blur", 3)
        blur:Recompute()
        render.UpdateScreenEffectTexture()
        surface.DrawTexturedRect(x,y,w,h)
    end
end

function esclib.draw:BlurRect(x, y, w, h)
	surface.SetDrawColor(255,255,255)
	surface.SetMaterial(blur)
	for i = 1, 2 do
		blur:SetFloat("$blur", (i / 4) * (4))
		blur:Recompute()

		render.UpdateScreenEffectTexture()

		render.SetScissorRect(x, y, x+w, y+h, true)
			surface.DrawTexturedRect(0, 0, ScrW(), ScrH())
		render.SetScissorRect(0, 0, 0, 0, false)
	end
end

function esclib.draw:Border(x,y,w,h, thickness, color, draw_left, draw_top, draw_right, draw_bottom)
	surface.SetDrawColor(color.r,color.g,color.b,color.a)
	if draw_left ~= false then surface.DrawRect(x,y,thickness,h) end
	if draw_top ~= false then surface.DrawRect(x,y,w,thickness) end
	if draw_right ~= false then surface.DrawRect(w-thickness, y, thickness, h) end
	if draw_bottom ~= false then surface.DrawRect(x, h-thickness, w, thickness) end
end

--Generates structure for gradient text
function esclib.draw:GradientText(text, font, col1, col2)
	local result = {}
	result["info"] = {
		["full_text"] = text,
		["font"] = font,
	}
	result["grad"] = {}
	local text_len = #text
	for i=1, text_len do
		local lp = i/text_len
		local clr = Color(col1.r, col1.g, col1.b, col1.a)
		clr.r = Lerp(lp, clr.r, col2.r)
		clr.g = Lerp(lp, clr.g, col2.g)
		clr.b = Lerp(lp, clr.b, col2.b)
		clr.a = Lerp(lp, clr.a, col2.a)
		table.insert(result["grad"], {utf8.sub(text, i, i), clr})
	end

	surface.SetFont(font)
	local text_w, text_h = surface.GetTextSize(text)
	result["info"]["text_w"] = text_w
	result["info"]["text_h"] = text_h

	function result:Draw(x,y, align_x, align_y, draw_shadow)
		
		local font = result["info"]["font"]
		surface.SetFont( font )

		if draw_shadow then
			draw.SimpleText(text, font, x+1, y+1, color_black, align_x, align_y)
		end

		if align_x == TEXT_ALIGN_CENTER then
			x = x - text_w*0.5
		elseif align_x == TEXT_ALIGN_RIGHT then
			x = x - text_w
		end

		if align_y == TEXT_ALIGN_CENTER then
			y = y - text_h*0.5
		elseif align_y == TEXT_ALIGN_BOTTOM then
			y = y - text_h
		end
		surface.SetTextPos( x, y )
		for _,v in ipairs(result["grad"]) do
			surface.SetTextColor(v[2]:Unpack())
			surface.DrawText(v[1])
		end
	end

	return result
end