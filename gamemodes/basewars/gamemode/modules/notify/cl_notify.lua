-- Police cohérente avec le menu F4
BaseWars:CreateFont("BaseWars.Notifications", BaseWars.ScreenScale * 20, 500)

local NotificationsData = {
	[NOTIFICATION_GENERIC] = {
		name = "Generic",
		icon = Material("basewars_materials/notification/generic.png", "smooth"),
		colorText = function() return GetBaseWarsTheme("bws_contentBackground") or GetBaseWarsTheme("bwm_contentBackground") or Color(24, 27, 34) end,
		colorIcon = function() return GetBaseWarsTheme("bws_contentBackground2") or GetBaseWarsTheme("bwm_contentBackground2") or Color(18, 18, 24) end
	},

	[NOTIFICATION_ERROR] = {
		name = "Error",
		icon = Material("basewars_materials/notification/error.png", "smooth"),
		colorText = function() return Color(136, 35, 35) end,
		colorIcon = function() return Color(100, 35, 35) end
	},

	[NOTIFICATION_UNDO] = {
		name = "Undo",
		icon = Material("basewars_materials/notification/hint.png", "smooth"),
		colorText = function() return GetBaseWarsTheme("bws_contentBackground") or GetBaseWarsTheme("bwm_contentBackground") or Color(24, 27, 34) end,
		colorIcon = function() return GetBaseWarsTheme("bws_contentBackground2") or GetBaseWarsTheme("bwm_contentBackground2") or Color(18, 18, 24) end
	},

	[NOTIFICATION_HINT] = {
		name = "Hint",
		icon = Material("basewars_materials/notification/undo.png", "smooth"),
		colorText = function() return GetBaseWarsTheme("bws_contentBackground") or GetBaseWarsTheme("bwm_contentBackground") or Color(24, 27, 34) end,
		colorIcon = function() return GetBaseWarsTheme("bws_contentBackground2") or GetBaseWarsTheme("bwm_contentBackground2") or Color(18, 18, 24) end
	},

	[NOTIFICATION_CLEANUP] = {
		name = "CleanUp",
		icon = Material("basewars_materials/notification/cleanup.png", "smooth"),
		colorText = function() return GetBaseWarsTheme("bws_contentBackground") or GetBaseWarsTheme("bwm_contentBackground") or Color(24, 27, 34) end,
		colorIcon = function() return GetBaseWarsTheme("bws_contentBackground2") or GetBaseWarsTheme("bwm_contentBackground2") or Color(18, 18, 24) end
	},

	[NOTIFICATION_WARNING] = {
		name = "Warning",
		icon = Material("basewars_materials/notification/warning.png", "smooth"),
		colorText = function() return Color(136, 35, 35) end,
		colorIcon = function() return Color(100, 35, 35) end
	},

	[NOTIFICATION_PURCHASE] = {
		name = "Purchase",
		icon = Material("models/magasin.png", "smooth"),

		colorText = function() return GetBaseWarsTheme("gen_accent") or Color(200, 60, 70) end,
		colorIcon = function() return GetBaseWarsTheme("bws_contentBackground2") or GetBaseWarsTheme("bwm_contentBackground2") or Color(18, 18, 24) end
	},

	[NOTIFICATION_RAID] = {
		name = "Raid",
		icon = Material("basewars_materials/notification/raid.png", "smooth"),
		colorText = function() return Color(212, 97, 9) end,
		colorIcon = function() return Color(173, 79, 7) end
	},

	[NOTIFICATION_SELL] = {
		name = "Sell",
		icon = Material("basewars_materials/notification/sell.png", "smooth"),
		colorText = function() return Color(46, 184, 46) end,
		colorIcon = function() return Color(50, 135, 50) end
	},

	[NOTIFICATION_PRESTIGE] = {
		name = "Prestige",
		icon = Material("basewars_materials/notification/prestige.png", "smooth"),
		colorText = function() return GetBaseWarsTheme("gen_accent") or Color(200, 60, 70) end,
		colorIcon = function() return GetBaseWarsTheme("bws_contentBackground2") or GetBaseWarsTheme("bwm_contentBackground2") or Color(18, 18, 24) end
	},

	[NOTIFICATION_DEATHNOTICE] = {
		name = "Death Notice",
		icon = Material("basewars_materials/notification/death_notice.png", "smooth"),
		colorText = function() return Color(114, 42, 165) end,
		colorIcon = function() return Color(88, 36, 126) end
	},
	[NOTIFICATION_FACTION] = {
		name = "Faction",
		icon = Material("basewars_materials/notification/faction.png", "smooth"),
		colorText = function() return Color(41, 151, 178) end,
		colorIcon = function() return Color(33, 110, 145) end
	},
	[NOTIFICATION_ADMIN] = {
		name = "Admin",
		icon = Material("basewars_materials/notification/admin.png", "smooth"),
		colorText = function() return Color(132, 178, 41) end,
		colorIcon = function() return Color(100, 145, 33) end
	},
}

local notifications = {}
local notificationsHistory = {}
local ScreenPos = 20 -- Position depuis le haut de l'écran

-- Fonction utilitaire pour calculer la taille d'icône optimale selon la résolution
local function GetOptimalIconSize(baseSize)
	-- Tailles réduites pour design compact et discret
	local minSize = BaseWars.ScreenScale * 18  -- Taille réduite pour compacité
	local maxSize = BaseWars.ScreenScale * 28  -- Taille maximale réduite pour discrétion
	return math.Clamp(baseSize, minSize, maxSize)
end

local function DrawNotification(x, y, w, h, text, icon, textColor, iconColor)
	local margin = BaseWars.ScreenScale * 8
	local iconSize = h - margin * 2
	local totalW = w + iconSize + margin * 3
	
	-- Fond principal avec design F3/F4 - fond sombre plus transparent et bordures plus fines
	local bgColor = GetBaseWarsTheme("bws_contentBackground") or GetBaseWarsTheme("bwm_contentBackground") or Color(24, 27, 34)
	BaseWars:DrawRoundedBox(4, x, y, totalW, h , ColorAlpha(bgColor, 180))
	
	-- Contour accent comme dans F3/F4 - plus subtil et fin
	local accentColor = GetBaseWarsTheme("bws_accent") or GetBaseWarsTheme("gen_accent") or Color(200, 60, 70)
	surface.SetDrawColor(accentColor.r, accentColor.g, accentColor.b, 35)
	surface.DrawOutlinedRect(x + 1, y + 1, totalW - 2, h - 2)
	
	-- Zone d'icône avec design élégant et cohérent avec le thème
	local iconAreaWidth = iconSize + margin * 2
	local iconBgColor = GetBaseWarsTheme("bws_contentBackground2") or GetBaseWarsTheme("bwm_contentBackground2") or Color(18, 18, 24)
	BaseWars:DrawRoundedBoxEx(4, x, y, iconAreaWidth, h, ColorAlpha(iconBgColor, 160), true, false, true, false)
	
	-- Bordure subtile pour la zone d'icône (cohérence avec le thème des menus)
	local iconBorderColor = GetBaseWarsTheme("bws_accent") or GetBaseWarsTheme("gen_accent") or Color(200, 60, 70)
	surface.SetDrawColor(iconBorderColor.r, iconBorderColor.g, iconBorderColor.b, 25)
	surface.DrawOutlinedRect(x + 1, y + 1, iconAreaWidth - 2, h - 2)
	
	-- Icône parfaitement centrée avec disposition élégante
	local actualIconSize = GetOptimalIconSize(iconSize * 0.9)  -- Taille optimisée pour élégance
	local iconX = x + (iconAreaWidth - actualIconSize)
	local iconY = y + (h - actualIconSize)
	
	-- Effet de lueur subtile pour l'icône (élégance)
	local glowColor = GetBaseWarsTheme("bws_accent") or Color(200, 60, 70)
	BaseWars:DrawMaterial(icon, iconX - 1, iconY - 1, actualIconSize + 2, actualIconSize + 2, ColorAlpha(glowColor, 15), 0)
	BaseWars:DrawMaterial(icon, iconX, iconY, actualIconSize, actualIconSize, color_white, 0)
	
	-- Texte avec couleur thématique et alignement précis
	local textCol = GetBaseWarsTheme("bws_text") or GetBaseWarsTheme("bwm_text") or color_white
	local textX = x + iconAreaWidth + margin * 0.5  -- Position X alignée avec la zone d'icône
	local textY = y + h / 2  -- Centré verticalement
	draw.SimpleText(text, "BaseWars.Notifications", textX, textY, textCol, TEXT_ALIGN_LEFT, TEXT_ALIGN_CENTER)
end

-- Fonction pour dessiner une barre de délai esthétique
local function DrawProgressBar(x, y, w, h, progress, notification)
	local barHeight = 3
	local barY = y + h - barHeight - 2
	
	-- Utiliser les couleurs du thème BaseWars pour la cohérence visuelle
	local themeBackground = GetBaseWarsTheme("bwm_contentBackground2") or Color(18, 18, 24)
	local themeAccent = GetBaseWarsTheme("gen_accent") or Color(200, 60, 70)
	
	-- Fond de la barre avec couleur du thème
	surface.SetDrawColor(themeBackground.r, themeBackground.g, themeBackground.b, 150)
	surface.DrawRect(x + 2, barY, w - 4, barHeight)
	
	-- Barre de progression avec dégradé thématique
	local barWidth = (w - 4) * progress
	if barWidth > 0 then
		-- Utiliser la couleur d'accent du thème pour la cohérence
		local r, g, b = themeAccent.r, themeAccent.g, themeAccent.b
		
		-- Effet de pulsation quand la barre devient critique (< 20%)
		local pulseIntensity = 1
		if progress < 0.2 then
			pulseIntensity = 1 + math.sin(CurTime() * 8) * 0.3 -- Pulsation subtile
		end
		
		-- Créer un dégradé subtil avec les couleurs du thème
		for i = 0, barWidth do
			local alpha = (180 + math.sin((i / barWidth) * math.pi) * 40) * pulseIntensity
			surface.SetDrawColor(r, g, b, math.min(255, alpha))
			surface.DrawRect(x + 2 + i, barY, 1, barHeight)
		end
		
		-- Effet de lueur subtile avec couleur thématique et pulsation
		local glowAlpha = 60 * pulseIntensity
		surface.SetDrawColor(r, g, b, math.min(255, glowAlpha))
		surface.DrawRect(x + 1, barY - 1, barWidth + 2, barHeight + 2)
	end
end

function BaseWars:GetNotificationsHistory()
	return notificationsHistory
end

function BaseWars:Notify(text, type, time, ...)
	text = tostring(text)
	type = type or 0

	if text[1] == "#" then
		text = Format(LocalPlayer():GetLang(string.sub(text, 2)), unpack({...}))
	end

	if #notificationsHistory >= 300 then
		notificationsHistory[#notificationsHistory] = nil
	end

	table.insert(notificationsHistory, 1, {
		text = text,
		col1 = NotificationsData[type].colorText(),
		col2 = NotificationsData[type].colorIcon(),
		icon = NotificationsData[type].icon
	})

	local margin = BaseWars.ScreenScale * 5
	local h = BaseWars.ScreenScale * 50 -- Hauteur réduite pour un design plus compact et discret
	local w = BaseWars:GetTextSize(text, "BaseWars.Notifications") + margin * 2
	local iconSize = h - margin * 2
	local iconAreaWidth = iconSize + margin * 2  -- Zone d'icône cohérente avec DrawNotification
	local totalW = w + iconAreaWidth + margin * 1.5  -- Largeur totale optimisée
	local x = ScrW() + totalW -- Commence hors écran à droite
	local y = ScreenPos

	local duration = time or 5
	table.insert(notifications, {
		x = x,
		y = y,
		w = w,
		h = h,
		totalW = totalW,

		text = text,
		col1 = NotificationsData[type].colorText(),
		col2 = NotificationsData[type].colorIcon(),
		icon = NotificationsData[type].icon,
		time = CurTime() + duration,
		duration = duration, -- Stocker la durée pour la barre de délai
		startTime = CurTime(), -- Temps de début pour calcul précis
	})

	MsgC(NotificationsData[type].colorText, text, "\n")

	surface.PlaySound("bw_notification.wav")
end

local chatNotificationColor = Color(255, 0, 0)
function BaseWars:ChatNotify(text, args)
	text = tostring(text)

	if text[1] == "#" then
		text = Format(LocalPlayer():GetLang(string.sub(text, 2)), unpack(args))
	end

	chat.AddText(chatNotificationColor, "<clr:white>:basewars0::basewars1::basewars2::basewars3::basewars4::basewars5:<clr:white>", color_white, " » ", text)
end

function notification.Kill() end
function notification.AddProgress() end
function notification.AddLegacy(text, type, lenght)
	BaseWars:Notify(text, type, lenght)
end

function DrawBaseWarsNotifications()
	for k, v in ipairs(notifications) do
		-- Initialiser l'alpha si pas défini
		if not v.alpha then v.alpha = 0 end
		
		-- Animation d'apparition/disparition avec alpha et easing élégant
		local targetAlpha = (v.time > CurTime()) and 255 or 0
		local alphaSpeed = targetAlpha > v.alpha and 10 or 6 -- Apparition plus rapide, disparition plus douce
		v.alpha = Lerp(FrameTime() * alphaSpeed, v.alpha, targetAlpha)
		
		-- Appliquer l'alpha aux couleurs
		local col1 = ColorAlpha(v.col1, v.alpha)
		local col2 = ColorAlpha(v.col2, v.alpha)
		
		-- Animation de position pour haut à droite avec easing élégant
		local lerpFrac = FrameTime() * 14 -- Légèrement plus rapide pour plus de réactivité
		local margin = BaseWars.ScreenScale * 12 -- Marge encore plus réduite pour design compact
		local spacing = BaseWars.ScreenScale * 5 -- Espacement minimal entre notifications pour compacité
		
		-- Position cible : bien dans le coin supérieur droit
		local targetX = v.time > CurTime() and ScrW() - v.totalW - margin or ScrW() + 50
		local targetY = ScreenPos + (k - 1) * (v.h + spacing)
		
		-- Easing out pour un mouvement plus naturel
		v.x = Lerp(lerpFrac, v.x, targetX)
		v.y = Lerp(lerpFrac, v.y, targetY)
		
		-- Dessiner seulement si visible
		if v.alpha > 5 then
			DrawNotification(math.floor(v.x), math.floor(v.y), v.w, v.h, v.text, v.icon, col1, col2)
			
			-- Calculer et dessiner la barre de délai esthétique
			local timeRemaining = math.max(0, v.time - CurTime())
			local progress = timeRemaining / v.duration
			
			-- Dessiner la barre de délai avec l'alpha de la notification
			if progress > 0 and progress <= 1 then
				-- Créer une copie de la notification avec l'alpha appliqué pour la barre
				local notificationForBar = {
					col2 = ColorAlpha(v.col2, v.alpha * 0.8) -- Légèrement plus transparent
				}
				DrawProgressBar(math.floor(v.x), math.floor(v.y), v.totalW, v.h, progress, notificationForBar)
			end
		end
	end

	-- Nettoyer les notifications invisibles
	for k = #notifications, 1, -1 do
		local v = notifications[k]
		if v.alpha <= 5 and v.time < CurTime() then
			table.remove(notifications, k)
		end
	end
end

net.Receive("BaseWars:Notifications", function(len)
	local data = util.JSONToTable(util.Decompress(net.ReadData(len / 8)), false, false)

	local text = data.text
	if text[1] == "#" then
		text = Format(LocalPlayer():GetLang(string.sub(text, 2)), unpack(data.args))
	end

	BaseWars:Notify(text, data.type, data.lenght)
end)

net.Receive("BaseWars:Notifications:Chat", function(len)
	local data = util.JSONToTable(util.Decompress(net.ReadData(len / 8)), false, false)

	BaseWars:ChatNotify(data.text, data.args)
end)

concommand.Add("bw_testnotif", function(ply)
	if not BaseWars:IsSuperAdmin(ply) then return end

	for k, v in ipairs(NotificationsData) do
		timer.Simple(k * .25, function()
			BaseWars:Notify(v.name, k, 10)
		end)
	end
end)

net.Receive("BaseWars:Notif:ClearNotifs", function()
	notifications = {}
	BaseWars:Notify("#command_clearNotifs", NOTIFICATION_GENERIC, 5)
end)

-- Hook pour afficher les notifications
hook.Add("HUDPaint", "BaseWars:DrawNotifications", DrawBaseWarsNotifications)