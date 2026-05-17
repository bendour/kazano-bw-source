local buyIcon = Material("basewars_materials/notification/purchase.png", "smooth")

local buttonSize = BaseWars.ScreenScale * 36
local bigMargin = BaseWars.ScreenScale * 10
local margin = BaseWars.ScreenScale * 5

local PANEL = {}
function PANEL:Init()
	self.w, self.h = self:GetParent():GetSize()
	local ply = LocalPlayer()

	self.SidePanel = self:Add("DPanel")
	self.SidePanel:Dock(RIGHT)
	self.SidePanel:DockMargin(0, bigMargin, bigMargin, bigMargin)
	self.SidePanel:SetWide(BaseWars.ScreenScale * 300)
	self.SidePanel.Paint = nil

	self.SidePanel.Infos = self.SidePanel:Add("DPanel")
	self.SidePanel.Infos:Dock(TOP)
	self.SidePanel.Infos:SetTall(BaseWars.ScreenScale * 300)
	self.SidePanel.Infos:InvalidateParent(true)
	self.SidePanel.Infos.plyLevel = 0
	self.SidePanel.Infos.Paint = function(s,w,h)
		local percent = 0
		local levelForPrestige = BaseWars.Config.Prestige.BaseLevel + (ply:GetPrestige() * BaseWars.Config.Prestige.MoreLevel)

		s.plyLevel = Lerp(FrameTime() * 15, s.plyLevel, ply:GetLevel())
		percent = s.plyLevel / levelForPrestige

		--BaseWars:DrawRoundedBox(4, 0, 0, w, h, GetBaseWarsTheme("bws_contentBackground") or GetBaseWarsTheme("bwm_contentBackground"))

		local x, y = w * .5, w * .5
		BaseWars:DrawCircle(x, y, w * .35, 360, 0, 360, GetBaseWarsTheme("bws_contentBackground2") or GetBaseWarsTheme("bwm_contentBackground2")) -- Fond du cercle supprimé
		BaseWars:DrawCircle(x, y, w * .35, 360, 0, 360 * math.Clamp(percent, 0, 1), GetBaseWarsTheme("gen_accent"))
		BaseWars:DrawCircle(x, y, w * .32, 360, 0, 360, GetBaseWarsTheme("bws_contentBackground") or GetBaseWarsTheme("bwm_contentBackground"))

		draw.SimpleText(string.Comma(math.Round(percent * 100, 2)) .. "%", "BaseWars.30", w * .5, y, GetBaseWarsTheme("bws_text") or GetBaseWarsTheme("bwm_text"), 1, TEXT_ALIGN_BOTTOM)
		draw.SimpleText(BaseWars:FormatNumber(s.plyLevel, true) .. "/" .. BaseWars:FormatNumber(levelForPrestige, true), "BaseWars.20", w * .5, y, GetBaseWarsTheme("bws_darkText") or GetBaseWarsTheme("bwm_darkText"), 1, TEXT_ALIGN_TOP)
	end

	self.SidePanel.DoPrestige = self.SidePanel:Add("DPanel")
	self.SidePanel.DoPrestige:Dock(BOTTOM)
	self.SidePanel.DoPrestige:SetTall(buttonSize + bigMargin * 2)
	self.SidePanel.DoPrestige.Paint = function(s,w,h)
		BaseWars:DrawRoundedBox(4, 0, 0, w, h, GetBaseWarsTheme("bws_contentBackground") or GetBaseWarsTheme("bwm_contentBackground"))
	end

    self.SidePanel.DoPrestige.Button = self.SidePanel.DoPrestige:Add("BaseWars.Button")
    self.SidePanel.DoPrestige.Button:Dock(FILL)
    self.SidePanel.DoPrestige.Button:DockMargin(bigMargin, bigMargin, bigMargin, bigMargin)
    self.SidePanel.DoPrestige.Button:SetColor(GetBaseWarsTheme("bws_contentBackground") or GetBaseWarsTheme("bwm_contentBackground"), true)
    self.SidePanel.DoPrestige.Button:SetAccentColor(GetBaseWarsTheme("gen_accent"))
    self.SidePanel.DoPrestige.Button.LerpFunc = function(s)
        return s:IsHovered()
    end
    self.SidePanel.DoPrestige.Button.Draw = function(s,w,h)
        draw.SimpleText(ply:GetLang("prestige_doPrestige"):format(BaseWars:FormatNumber(ply:GetPrestige() + 1)), "BaseWars.20", w * .5, h * .5, GetBaseWarsTheme("bws_text") or GetBaseWarsTheme("bwm_text"), 1, 1)
    end
    self.SidePanel.DoPrestige.Button.DoClick = function(s)
        if not ply:CanPrestige() then
            s:Disable(1.5, GetBaseWarsTheme("button_disabled"), s.Draw)
            return
        end
        s:ButtonSound()

		net.Start("BaseWars:Prestige")
		net.SendToServer()
    end

	self.SidePanel.ResetPrestigePoint = self.SidePanel:Add("Panel")
	self.SidePanel.ResetPrestigePoint:Dock(BOTTOM)
	self.SidePanel.ResetPrestigePoint:DockMargin(0, 0, 0, bigMargin)
	self.SidePanel.ResetPrestigePoint:SetTall(buttonSize + bigMargin * 2)
	self.SidePanel.ResetPrestigePoint.Paint = function(s,w,h)
		BaseWars:DrawRoundedBox(4, 0, 0, w, h, GetBaseWarsTheme("bws_contentBackground") or GetBaseWarsTheme("bwm_contentBackground"))
	end

    self.SidePanel.ResetPrestigePoint.Button = self.SidePanel.ResetPrestigePoint:Add("BaseWars.Button")
    self.SidePanel.ResetPrestigePoint.Button:Dock(FILL)
    self.SidePanel.ResetPrestigePoint.Button:DockMargin(bigMargin, bigMargin, bigMargin, bigMargin)
    self.SidePanel.ResetPrestigePoint.Button:SetColor(GetBaseWarsTheme("bws_contentBackground") or GetBaseWarsTheme("bwm_contentBackground"), true)
    self.SidePanel.ResetPrestigePoint.Button:SetAccentColor(GetBaseWarsTheme("gen_accent"))
    self.SidePanel.ResetPrestigePoint.Button.Draw = function(s,w,h)
        draw.SimpleText(ply:GetLang("prestige_resetPoint"):format(BaseWars:FormatMoney(BaseWars.Config.Prestige.ResetPrice * ply:GetPrestigePointSpent(), true)), "BaseWars.20", w * .5, h * .5, GetBaseWarsTheme("bws_text") or GetBaseWarsTheme("bwm_text"), 1, 1)
    end
    self.SidePanel.ResetPrestigePoint.Button.DoClick = function(s)
        if ply:GetPrestigePointSpent() <= 0 then return end

		s:ButtonSound()

		net.Start("BaseWars:Prestige.ResetPoint")
		net.SendToServer()
	end

	self.SidePanel.PrestigePoint = self.SidePanel:Add("DPanel")
	self.SidePanel.PrestigePoint:Dock(BOTTOM)
	self.SidePanel.PrestigePoint:DockMargin(0, 0, 0, bigMargin)
	self.SidePanel.PrestigePoint:SetTall(BaseWars.ScreenScale * 40)
	self.SidePanel.PrestigePoint.Paint = function(s,w,h)
		BaseWars:DrawRoundedBox(4, 0, 0, w, h, GetBaseWarsTheme("bws_contentBackground") or GetBaseWarsTheme("bwm_contentBackground"))
		draw.SimpleText(ply:GetLang("prestige_prestigePoint"):format(BaseWars:FormatNumber(ply:GetPrestigePoint())), "BaseWars.18", w * .5, h * .5, GetBaseWarsTheme("bws_text") or GetBaseWarsTheme("bwm_text"), 1, 1)
	end

	self.Scroll = self:Add("DScrollPanel")
	self.Scroll:Dock(FILL)
	self.Scroll:DockMargin(bigMargin, bigMargin, bigMargin, bigMargin)
	self.Scroll:PaintScrollBar("bwm")

	for k, v in SortedPairsByMemberValue(BaseWars:GetPrestigePerk(), "cost") do
		local perk = self.Scroll:Add("DPanel")
		perk:Dock(TOP)
		perk:DockMargin(0, 0, margin, margin)
		perk:SetTall(BaseWars.ScreenScale * 56)
        -- Initialiser les données du tooltip une seule fois
        perk.fullDescription = ply:GetLang("prestige_perks", k .. "Desc")
        
        perk.Paint = function(s,w,h)
            BaseWars:DrawRoundedBox(4, 0, 0, w, h, GetBaseWarsTheme("bws_contentBackground") or GetBaseWarsTheme("bwm_contentBackground"))

            -- Texte gauche (nom et description)
            draw.SimpleText(ply:GetLang("prestige_perks", k .. "Name"), "BaseWars.22", bigMargin, h * .5, GetBaseWarsTheme("bws_text") or GetBaseWarsTheme("bwm_text"), 0, TEXT_ALIGN_BOTTOM)
            
            -- Description avec gestion du débordement
            local rightPad = (IsValid(s.Buy) and s.Buy:GetWide() or 0) + bigMargin * 2
            local availableWidth = w - bigMargin - rightPad - BaseWars.ScreenScale * 100 -- Espace disponible pour la description
            
            -- Fonction pour tronquer le texte si nécessaire
            local function truncateText(text, font, maxWidth)
                surface.SetFont(font)
                local textWidth = surface.GetTextSize(text)
                
                if textWidth <= maxWidth then
                    return text, false -- Pas de troncature nécessaire
                end
                
                local truncated = text
                local ellipsis = "..."
                
                while surface.GetTextSize(truncated .. ellipsis) > maxWidth and #truncated > 0 do
                    truncated = string.sub(truncated, 1, #truncated - 1)
                end
                
                return truncated .. ellipsis, true -- Texte tronqué
            end
            
            local displayDesc, isTruncated = truncateText(s.fullDescription, "BaseWars.18", availableWidth)
            draw.SimpleText(displayDesc, "BaseWars.18", bigMargin, h * .5, GetBaseWarsTheme("bws_darkText") or GetBaseWarsTheme("bwm_darkText"), 0, TEXT_ALIGN_TOP)
            
            -- Mettre à jour l'état de troncature
            s.isTruncated = isTruncated

            -- Décaler les infos à droite en fonction du bouton d'achat
            local rightPad = (IsValid(s.Buy) and s.Buy:GetWide() or 0) + bigMargin * 2
            local rightX = w - rightPad

            draw.SimpleText(ply:GetLang("prestige_price"), "BaseWars.18", rightX - BaseWars.ScreenScale * 50, h * .5, GetBaseWarsTheme("bws_text") or GetBaseWarsTheme("bwm_text"), TEXT_ALIGN_RIGHT, TEXT_ALIGN_BOTTOM)
            draw.SimpleText(v.cost, "BaseWars.18", rightX - BaseWars.ScreenScale * 45, h * .5, GetBaseWarsTheme("bws_darkText") or GetBaseWarsTheme("bwm_darkText"), 0, TEXT_ALIGN_BOTTOM)

            draw.SimpleText(ply:GetLang("prestige_level"), "BaseWars.18", rightX - BaseWars.ScreenScale * 50, h * .5, GetBaseWarsTheme("bws_text") or GetBaseWarsTheme("bwm_text"), TEXT_ALIGN_RIGHT, TEXT_ALIGN_TOP)
            draw.SimpleText(ply:GetPrestigePerk(k) .. "/" .. v.max, "BaseWars.18", rightX - BaseWars.ScreenScale * 45, h * .5, GetBaseWarsTheme("bws_darkText") or GetBaseWarsTheme("bwm_darkText"), 0, TEXT_ALIGN_TOP)
        end

        perk.Buy = perk:Add("BaseWars.Button")
        perk.Buy:SetText("")
        perk.Buy:Dock(RIGHT)
        perk.Buy:DockMargin(bigMargin, bigMargin, bigMargin, bigMargin)
        perk.Buy:SetWide(BaseWars.ScreenScale * 180)
        perk.Buy:SetColor(GetBaseWarsTheme("bws_contentBackground") or GetBaseWarsTheme("bwm_contentBackground"), true)
        perk.Buy:SetAccentColor(GetBaseWarsTheme("gen_accent"))
        perk.Buy.Draw = function(s,w,h)
            draw.SimpleText(ply:GetLang("prestige_buyPerk"):format(v.cost), "BaseWars.20", w * .5, h * .5, GetBaseWarsTheme("bws_text") or GetBaseWarsTheme("bwm_text"), 1, 1)
        end
        perk.Buy.DoClick = function(s)
            local text
            if ply:GetPrestigePerk(k) >= v.max then
                text = ply:GetLang("prestige_maxPerk")
            elseif v.cost > ply:GetPrestigePoint() then
                text = ply:GetLang("prestige_notEnoughPoint"):format(v.cost)
            end

            if text then
                BaseWars:Notify(text, NOTIFICATION_ERROR, 5)
                return
            end

            s:ButtonSound()

            net.Start("BaseWars:Prestige.BuyPerk")
                net.WriteString(k)
            net.SendToServer()
        end
        
        -- Système de tooltip amélioré
        perk.showTooltip = false
        perk.tooltipStartTime = 0
        
        perk.Think = function(s)
            -- Vérifier si la souris survole le panneau
            local mx, my = gui.MousePos()
            local x, y = s:GetPos()
            local w, h = s:GetSize()
            local px, py = s:GetParent():LocalToScreen(x, y)
            
            local isHovered = mx >= px and mx <= px + w and my >= py and my <= py + h
            
            if isHovered and s.isTruncated and not s.showTooltip then
                s.showTooltip = true
                s.tooltipStartTime = CurTime()
            elseif not isHovered then
                s.showTooltip = false
            end
        end
        
        perk.PaintOver = function(s, w, h)
            -- Afficher le tooltip si la description est tronquée et que la souris survole
            if s.showTooltip and s.isTruncated and CurTime() - s.tooltipStartTime > 0.5 then
                local mx, my = gui.MousePos()
                
                -- Préparer le texte du tooltip avec retour à la ligne
                local lines = {}
                local words = string.Explode(" ", s.fullDescription)
                local currentLine = ""
                local maxLineWidth = BaseWars.ScreenScale * 300
                
                surface.SetFont("BaseWars.16")
                for i, word in ipairs(words) do
                    local testLine = currentLine == "" and word or currentLine .. " " .. word
                    local testW = surface.GetTextSize(testLine)
                    
                    if testW > maxLineWidth and currentLine ~= "" then
                        table.insert(lines, currentLine)
                        currentLine = word
                    else
                        currentLine = testLine
                    end
                end
                if currentLine ~= "" then
                    table.insert(lines, currentLine)
                end
                
                -- Calculer la taille du tooltip
                local tooltipW = 0
                for _, line in ipairs(lines) do
                    local lineW = surface.GetTextSize(line)
                    tooltipW = math.max(tooltipW, lineW)
                end
                tooltipW = tooltipW + 20
                local tooltipH = #lines * 18 + 16
                
                -- Positionner le tooltip
                local tooltipX = mx + 15
                local tooltipY = my - tooltipH - 10
                
                -- Éviter les bords de l'écran
                if tooltipX + tooltipW > ScrW() then
                    tooltipX = mx - tooltipW - 15
                end
                if tooltipY < 0 then
                    tooltipY = my + 25
                end
                
                -- Dessiner le fond du tooltip
                local bgColor = GetBaseWarsTheme("bws_contentBackground") or GetBaseWarsTheme("bwm_contentBackground")
                local borderColor = GetBaseWarsTheme("bws_contentBackground2") or GetBaseWarsTheme("bwm_contentBackground2")
                
                BaseWars:DrawRoundedBox(6, tooltipX - 2, tooltipY - 2, tooltipW + 4, tooltipH + 4, Color(0, 0, 0, 150))
                BaseWars:DrawRoundedBox(4, tooltipX, tooltipY, tooltipW, tooltipH, ColorAlpha(bgColor, 240))
                
                -- Afficher chaque ligne
                local textColor = GetBaseWarsTheme("bws_text") or GetBaseWarsTheme("bwm_text")
                for i, line in ipairs(lines) do
                    draw.SimpleText(line, "BaseWars.16", tooltipX + 10, tooltipY + 8 + (i - 1) * 18, textColor, 0, 0)
                end
            end
        end
	end
end

function PANEL:Paint(w,h)
	-- Effet de transparence comme sur les menus F3 et F4
	local bg = GetBaseWarsTheme("bws_background") or Color(10,10,12)
	BaseWars:DrawRoundedBox(12, 0, 0, w, h, ColorAlpha(bg, 75))
	
	if LocalPlayer():GetBaseWarsConfig("bluredBackground") then
		BaseWars:DrawBlur(self, 4)
	end
end

vgui.Register("BaseWars.F3Menu.Prestige", PANEL, "DPanel")