// Font
surface.CreateFont("NL_CrashMenu_Font", {font = "BFHUD", size = 30})
//

local function ResponsiveX(x)
    return x / 1920 * ScrW() 
end
local function ResponsiveY(y)
    return y / 1080 * ScrH()
end

-- Fonts modernes (Bahnschrift)
surface.CreateFont("NL_CrashMenu_Title", {font = "Bahnschrift", size = math.Round(ResponsiveY(48)), weight = 800, antialias = true})
surface.CreateFont("NL_CrashMenu_Subtitle", {font = "Bahnschrift", size = math.Round(ResponsiveY(32)), weight = 700, antialias = true})
surface.CreateFont("NL_CrashMenu_ButtonMain", {font = "Bahnschrift", size = math.Round(ResponsiveY(54)), weight = 800, antialias = true})
surface.CreateFont("NL_CrashMenu_ButtonSub", {font = "Bahnschrift", size = math.Round(ResponsiveY(40)), weight = 800, antialias = true})


local NL_CrashMenu_Logo = Material("nl_crashmenu/kazano_logo.png");
local NL_CrashTime = 60;
local NL_CrashMenu;

local IOS_RED = Color(255, 59, 48, 160)
local matGradient = Material("vgui/gradient-u")
-- supprimé: pas de panneau central
-- supprimé: pas de panneau central
local matGradientL = Material("vgui/gradient-l")

function NL_OpenCrashMenu()
	local NextCount = CurTime() + 60
	local NextCount2 = CurTime() + 1
	hook.Add("Think", "NL_RetryAuto", function() 
		if (NextCount2 - CurTime() <= 0) then
            NextCount2 = CurTime() + 1
			NL_CrashTime = NL_CrashTime - 1
		end
		if (NextCount - CurTime() <= 0) then 
			RunConsoleCommand("retry") 
		end 
	end)

	NL_CrashMenu = vgui.Create("DFrame")
	NL_CrashMenu:SetSize(ScrW(), ScrH())
	NL_CrashMenu:Center()
	NL_CrashMenu:SetTitle("")
	NL_CrashMenu:ShowCloseButton(false)
	NL_CrashMenu:MakePopup()
	NL_CrashMenu.Paint = function(self, w, h)
		Derma_DrawBackgroundBlur(self, 1)
	end

	-- pas de panneau central: on garde l’arrière-plan flou seulement

	local logoSize = math.min(ResponsiveX(520), ResponsiveY(520))
	local btnW, btnH = ResponsiveX(460), ResponsiveY(140)
	local spacing = ResponsiveY(24)
	local blockH = logoSize + spacing + btnH
	local topY = math.max(ResponsiveY(20), (ScrH() - blockH) / 2 - ResponsiveY(40))

	local NL_CrashMenu_Image = vgui.Create("DButton", NL_CrashMenu)
	NL_CrashMenu_Image:SetSize(logoSize, logoSize)
	NL_CrashMenu_Image:SetPos((ScrW() - logoSize) / 2, topY)
	NL_CrashMenu_Image:SetText("")
	NL_CrashMenu_Image.Paint = function(self, w, h)
		surface.SetMaterial(NL_CrashMenu_Logo)
		surface.SetDrawColor(255, 255, 255, 255)
		surface.DrawTexturedRect(0, 0, w, h)
	end

	-- pas de labels: uniquement logo et bouton en dessous

	-- bouton "Reconnexion" centré sous le logo, design glass avec bord rouge
	local NL_CrashMenu_RetryNow = vgui.Create("DButton", NL_CrashMenu)
	NL_CrashMenu_RetryNow:SetSize(btnW, btnH)
	NL_CrashMenu_RetryNow:SetPos((ScrW() - btnW) / 2, topY + logoSize + spacing)
	NL_CrashMenu_RetryNow:SetText("")
	-- Texte custom dessiné dans Paint (titre + décompte)
	NL_CrashMenu_RetryNow.Paint = function(self, w, h)
		local hover = self:IsHovered()
		local down = self.Depressed

		-- remplissage glass foncé quasi opaque (~80%), teinté rouge
		local base = Color(170, 25, 25, down and 220 or (hover and 210 or 204))
		draw.RoundedBox(34, 0, 0, w, h, base)

		-- éclaircissement doux en haut (effet glossy)
		surface.SetMaterial(matGradient)
		surface.SetDrawColor(255, 255, 255, down and 32 or (hover and 26 or 22))
		surface.DrawTexturedRect(0, 0, w, math.floor(h * 0.6))

		-- léger tint rouge pour la profondeur
		surface.SetMaterial(matGradientL)
		surface.SetDrawColor(255, 80, 80, down and 36 or (hover and 30 or 24))
		surface.DrawTexturedRect(0, 0, w, h)

		-- pas de cadre: épuré sans outline

		-- texte du bouton (titre + décompte en dessous)
		local mainText = "Reconnexion"
		local subText = tostring(NL_CrashTime) .. " s"
		draw.SimpleText(mainText, "NL_CrashMenu_ButtonMain", w / 2, h * 0.40, Color(255, 255, 255), TEXT_ALIGN_CENTER, TEXT_ALIGN_CENTER)
		draw.SimpleText(subText, "NL_CrashMenu_ButtonSub", w / 2, h * 0.75, Color(255, 255, 255), TEXT_ALIGN_CENTER, TEXT_ALIGN_CENTER)
	end
	NL_CrashMenu_RetryNow.DoClick = function()
		RunConsoleCommand("retry")
	end


end

hook.Add("Think","NL_CrashDetect",function()
    local TimeOut , _ = GetTimeoutInfo()
    if TimeOut && not IsValid(NL_CrashMenu) then
		NL_OpenCrashMenu()
    elseif not TimeOut && IsValid(NL_CrashMenu) then
		NL_CrashMenu:Close()
        hook.Remove("Think", "NL_RetryAuto")
    end
end)