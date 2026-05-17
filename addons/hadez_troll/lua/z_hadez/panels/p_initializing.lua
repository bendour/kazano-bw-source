-- [[ CREATED BY ZOMBIE EXTINGUISHER ]]

local PANEL = {}
local scrW,scrH = ScrW(),ScrH()

local menuBG = Material("z_hadez/raw/bg_small.png")
local blueFlame = surface.GetTextureID("z_hadez/menu/flame_blue.vmt")

local menuW, menuH = 400,200
local menuAnimSpeed = 0.2
local menuTitle = "HAD3Z"

local flameH = 100
local flameW = flameH*0.54
local maxFlames = 13
local flameAnimSpeed = 1.5

function PANEL:Init()
	
	local flames = 1
	local letters = 0
	local lastThink = 0
	
	self:SetTitle("")
	self:ShowCloseButton(false)
	self:SetDraggable(true)
	self:SetSize(menuW,menuH)
	self:Center()
	self.Think = function(_, w, h)

		if lastThink < CurTime() then
		
			if flames < maxFlames then
				flames = flames+1
			else
				letters = math.min(letters+1,#menuTitle)
			end
			
			if letters == #menuTitle then
			
				timer.Simple(1,function()
				
					if IsValid(self) then
					
						CL_HADEZ.menuInitialized = true
						CL_HADEZ.menu = vgui.Create("p_hadez_menu")
						self:Remove()
						
					end
					
				end)
				
				return
			end
			
			lastThink = CurTime() + 0.08
			
		end
	
	end
	
	local topFlameY, bottomFlameY, nextAnimate = 45, menuH-flameH+5, 0
	
	self.Paint = function(self, w, h) 
		
		-- BG
		surface.SetDrawColor(color_white)
		surface.SetMaterial(menuBG)
		surface.DrawTexturedRect(0, 0, w, h)
		
		CL_HADEZ:DrawBlur(self)
		
		surface.SetDrawColor(color_white)
		surface.SetTexture(blueFlame)
		
		-- Flames dissapear animation
		if nextAnimate < CurTime() and flames == maxFlames then
			topFlameY = math.Approach( topFlameY, 0, flameAnimSpeed )
			bottomFlameY = math.Approach( bottomFlameY, h-50, flameAnimSpeed )
			nextAnimate = CurTime() + 0.033
		end
		
		for i=1, flames do
			-- Top flames
			surface.DrawTexturedRectRotated( 20+(30*(i-1)), topFlameY, flameW, flameH, 180 )
			
			-- Bottom flames
			surface.DrawTexturedRect( w-flameW+5-(30*(i-1)), bottomFlameY, flameW, flameH )
		end
		
		-- Title
		local txt = string.sub(menuTitle,0,letters)
		CL_HADEZ:DrawDoubleBlueTxt(txt, "z_hadez_initializeTitle", w/2, 60, 5, TEXT_ALIGN_CENTER, TEXT_ALIGN_CENTER)
	
	end
	
	-- Animate alpha
	self:SetAlpha(0)
	self:AlphaTo(255, menuAnimSpeed)
	
	self:MoveToFront()
	self:MakePopup()
	
end
vgui.Register("p_hadez_initializing",PANEL,"DFrame")