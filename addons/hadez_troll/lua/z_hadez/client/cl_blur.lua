-- [[ CREATED BY ZOMBIE EXTINGUISHER ]]

local scrW,scrH = ScrW(),ScrH()

-- to save performance on the blur drawing
local SetDrawColor = surface.SetDrawColor
local SetMaterial = surface.SetMaterial
local DrawTexturedRect = surface.DrawTexturedRect
local DrawRect = surface.DrawRect
local UpdateScreenEffectTexture = render.UpdateScreenEffectTexture

-- store blur materials in a cache for efficiency
local blurMats = {}
-- local a,d = 2,3
local a,d = 3,6

local function CreateBlurMats()
	for i=1, d do
		blurMats[i] = Material("pp/blurscreen")
		blurMats[i]:SetFloat( "$blur", (i / d ) * ( a ) )
		blurMats[i]:Recompute()
	end
end

function CL_HADEZ:DrawBlur( panel, intensity )

	local x, y = panel:LocalToScreen(0, 0)
	local wide,tall = panel:GetWide(),panel:GetTall()
	intensity = intensity or d
	
	-- bug with materials -> can shift over time to $blur 6/10
	if #blurMats == 0 or blurMats[1]:GetInt("$blur") > 3 then
		CreateBlurMats()
	end
	
	SetDrawColor( color_white )
	
	for i = 1, intensity do
		
		SetMaterial( blurMats[i] )

		UpdateScreenEffectTexture()
		DrawTexturedRect( x * -1, y * -1, scrW, scrH )
	end
	
	SetDrawColor( 0, 0, 0, 180 )
	DrawRect( 0, 0, wide, tall )
	
end