local buttonTall = BaseWars.ScreenScale * 36
local bigMargin = BaseWars.ScreenScale * 10
local margin = BaseWars.ScreenScale * 5
local roundness = BaseWars.ScreenScale * 4

surface.CreateFont("CountdownFont", {
    font = "Trebuchet24",
    size = 128,
    weight = 700,
})

local PANEL = {}
function PANEL:Init()
    self.w, self.h = self:GetParent():GetSize()
    self.localPlayer = LocalPlayer()
    self.selectedPlayer = self.localPlayer
    self.colors = {
        text = GetBaseWarsTheme("bws_text") or GetBaseWarsTheme("bwm_text"),
        contentBackground = GetBaseWarsTheme("bws_contentBackground") or GetBaseWarsTheme("bwm_contentBackground"),
        disabled = GetBaseWarsTheme("button_disabled"),
        green = GetBaseWarsTheme("button_green")
    }

    local halfWide = (self.w - bigMargin * 3) * 0.5
    local halfTall = (self.h - bigMargin * 3) * 0.5

    -- Panneau du haut
    self.TopBar = self:Add("DPanel")
    self.TopBar:Dock(TOP)
    self.TopBar:DockMargin(bigMargin, bigMargin, 0, bigMargin)
    self.TopBar:SetTall(buttonTall + bigMargin * 2)
    self.TopBar:SetWide(halfWide)
    self.TopBar.Paint = function(s, w, h)
        BaseWars:DrawRoundedBox(roundness, 0, 0, w, h, self.colors.contentBackground)
        draw.SimpleText("DUEL 1 VS 1", "BaseWars.26", w * 0.5, h * 0.5, self.colors.text, TEXT_ALIGN_CENTER, TEXT_ALIGN_CENTER)
    end

    -- Panneau de gauche (Liste des joueurs)
    self.LeftContainer = self:Add("DPanel")
    self.LeftContainer:Dock(LEFT)
    self.LeftContainer:DockMargin(bigMargin, 0, bigMargin, bigMargin)
    self.LeftContainer:SetWide(halfWide)
    self.LeftContainer.Paint = function() end

    self.PlayerTitle = self.LeftContainer:Add("DPanel")
    self.PlayerTitle:Dock(TOP)
    self.PlayerTitle:SetTall(BaseWars.ScreenScale * 60)
    self.PlayerTitle.Paint = function(s, w, h)
        BaseWars:DrawRoundedBox(roundness, 0, 0, w, h, self.colors.contentBackground)
        draw.SimpleText("Joueurs", "BaseWars.24", w * 0.5, h * 0.5, self.colors.text, TEXT_ALIGN_CENTER, TEXT_ALIGN_CENTER)
    end

    self.Scroll = self.LeftContainer:Add("DScrollPanel")
    self.Scroll:Dock(FILL)
    self.Scroll:GetVBar():SetWide(0)
    self.Scroll:SetTall(halfTall)

    -- Ajouter les joueurs
    for _, ply in player.Iterator() do
        local playerPanel = self.Scroll:Add("BaseWars.Button")
        playerPanel:Dock(TOP)
        playerPanel:DockMargin(0, 0, 0, margin)
        playerPanel:SetColor(self.colors.contentBackground, true)
        playerPanel.Draw = function(s, w, h) draw.SimpleText(ply:Name(), "BaseWars.22", w * .5, h * .5, self.colors.text, 1, 1) end
        playerPanel.LerpFunc = function(s) return s:IsHovered() or self.selectedPlayer == ply end
        playerPanel.DoClick = function(s)
            if self.selectedPlayer == ply then return end
            s:ButtonSound()
            self.selectedPlayer = ply
        end
    end

    -- Panneau du bas (Bouton de duel)
    self.BottomBar = self.LeftContainer:Add("DPanel")
    self.BottomBar:Dock(BOTTOM)
    self.BottomBar:SetTall(buttonTall + bigMargin * 2)
    self.BottomBar:DockMargin(0, margin, 0, 0)
    self.BottomBar.Paint = function(s, w, h)
        BaseWars:DrawRoundedBox(roundness, 0, 0, w, h, self.colors.contentBackground)
    end

    self.BottomBar.StartDuel = self.BottomBar:Add("BaseWars.Button")
    self.BottomBar.StartDuel:Dock(FILL)
    self.BottomBar.StartDuel:SetColor(self.colors.contentBackground, true)
    self.BottomBar.StartDuel.Draw = function(s, w, h)
        draw.SimpleText("Proposer un duel", "BaseWars.20", w * 0.5, h * 0.5, self.colors.text, TEXT_ALIGN_CENTER, TEXT_ALIGN_CENTER)
    end

    self.BottomBar.StartDuel.DoClick = function(s)
        if not IsValid(self.selectedPlayer) then
            s:Disable(1.5, self.colors.disabled, s.Draw)
            return
        end
        s:ButtonSound()
        net.Start("SendDuelRequest")
        net.WriteEntity(self.selectedPlayer)
        net.SendToServer()
    end

    -- Panneau de droite (Leaderboard)
    self.RightContainer = self:Add("DPanel")
    self.RightContainer:Dock(RIGHT)
    self.RightContainer:DockMargin(bigMargin, 0, bigMargin, bigMargin)
    self.RightContainer:SetWide(halfWide)
    self.RightContainer.Paint = function() end

    self.LeaderboardTitle = self.RightContainer:Add("DPanel")
    self.LeaderboardTitle:Dock(TOP)
    self.LeaderboardTitle:SetTall(BaseWars.ScreenScale * 60)
    self.LeaderboardTitle.Paint = function(s, w, h)
        BaseWars:DrawRoundedBox(roundness, 0, 0, w, h, self.colors.contentBackground)
        draw.SimpleText("Leaderboard", "BaseWars.24", w * 0.5, h * 0.5, self.colors.text, TEXT_ALIGN_CENTER, TEXT_ALIGN_CENTER)
    end

    self.LeaderboardScroll = self.RightContainer:Add("DScrollPanel")
    self.LeaderboardScroll:Dock(FILL)
    self.LeaderboardScroll:GetVBar():SetWide(0)

    -- Chargement des données de leaderboard
    net.Start("RequestLeaderboard")
    net.SendToServer()

    net.Receive("UpdateLeaderboard", function()
        local leaderboard = net.ReadTable()
        for i, data in pairs(leaderboard) do
            local row = self.LeaderboardScroll:Add("DPanel")
            row:Dock(TOP)
            row:SetTall(BaseWars.ScreenScale * 30)
            row:DockMargin(0, 0, 0, margin)
            row.Paint = function(s, w, h)
                local rankColor = color_white

                -- Coloration des rangs #1, #2, #3
                if i == 1 then
                    rankColor = Color(255, 215, 0)  -- Or pour le premier
                elseif i == 2 then
                    rankColor = Color(192, 192, 192)  -- Argent pour le deuxième
                elseif i == 3 then
                    rankColor = Color(255, 140, 0)  -- Bronze pour le troisième
                end
                -- Affichage des données
                draw.SimpleText("#"..i, "BaseWars.20", h / 2, h / 2, rankColor, TEXT_ALIGN_CENTER, TEXT_ALIGN_CENTER)
                draw.SimpleText(data.pseudo, "BaseWars.20", w * 0.07, h * 0.5, rankColor, TEXT_ALIGN_LEFT, TEXT_ALIGN_CENTER)
                draw.SimpleText(data.wins .. " Victoires", "BaseWars.20", w * 0.9, h * 0.5, rankColor, TEXT_ALIGN_CENTER, TEXT_ALIGN_CENTER)
            end
        end
    end)
end

function PANEL:Paint(w, h)
end

local duelRequestPanel
local autoDeclineTimer = "AutoDeclineDuelRequest"

net.Receive("DuelRequest", function()
    local requester = net.ReadEntity()

    if not IsValid(requester) then return end

    if IsValid(duelRequestPanel) then
        duelRequestPanel:Remove()  -- Supprime le panneau précédent s'il existe déjà
    end

    -- Création du panneau de demande de duel
    duelRequestPanel = vgui.Create("DFrame")
    duelRequestPanel:SetSize(300, 120)
    duelRequestPanel:SetTitle("")
    duelRequestPanel:ShowCloseButton(false)
    duelRequestPanel:SetDraggable(false)
    duelRequestPanel:SetPos(ScrW() - 310, ScrH() / 2 - 60)  -- Positionné à droite de l'écran
    duelRequestPanel.Paint = function(self, w, h)
        BaseWars:DrawRoundedBox(8, 0, 0, w, h, GetBaseWarsTheme("bws_contentBackground") or GetBaseWarsTheme("bwm_contentBackground"))
    end

    -- Texte avec le nom du demandeur
    local label = vgui.Create("DLabel", duelRequestPanel)
    label:SetText(requester:Nick() .. " vous défie en duel.")
    label:SetFont("Trebuchet24")
    label:SetTextColor(GetBaseWarsTheme("bws_text") or GetBaseWarsTheme("bwm_text"))
    label:SizeToContents()
    label:SetPos(duelRequestPanel:GetWide() / 2 - label:GetWide() / 2, 30)

    -- Bouton accepter (désactivé pour ne pas interagir avec la souris)
    local acceptButton = vgui.Create("DButton", duelRequestPanel)
    acceptButton:SetText("Accepter (O)")
    acceptButton:SetSize(120, 30)
    acceptButton:SetFont("Trebuchet24")
    acceptButton:SetPos(20, 70)
    acceptButton:SetEnabled(false)  -- Désactiver l'interaction de la souris
    acceptButton.Paint = function(self, w, h)
        BaseWars:DrawRoundedBox(8, 0, 0, w, h, GetBaseWarsTheme("button_green"))
        self:SetTextColor(GetBaseWarsTheme("bws_text") or GetBaseWarsTheme("bwm_text"))
    end

    -- Bouton refuser (désactivé pour ne pas interagir avec la souris)
    local refuseButton = vgui.Create("DButton", duelRequestPanel)
    refuseButton:SetText("Refuser (P)")
    refuseButton:SetSize(120, 30)
    refuseButton:SetFont("Trebuchet24")
    refuseButton:SetPos(160, 70)
    refuseButton:SetEnabled(false)  -- Désactiver l'interaction de la souris
    refuseButton.Paint = function(self, w, h)
        BaseWars:DrawRoundedBox(8, 0, 0, w, h, GetBaseWarsTheme("button_disabled"))
        self:SetTextColor(GetBaseWarsTheme("bws_text") or GetBaseWarsTheme("bwm_text"))
    end

    -- Fermeture automatique après 30 secondes si aucune action n'est prise
    timer.Create(autoDeclineTimer, 30, 1, function()
        if IsValid(duelRequestPanel) then
            net.Start("DuelResponse")
            net.WriteBool(false)  -- Refuser automatiquement après 30 secondes
            net.SendToServer()

            duelRequestPanel:Remove()  -- Fermer le menu
        end
    end)

    -- Permet au joueur de garder ses mouvements et sa caméra
    duelRequestPanel:SetKeyboardInputEnabled(false)
    duelRequestPanel:SetMouseInputEnabled(false)
end)

-- Fonction pour gérer la pression des touches Y (refuser) et O (accepter)
hook.Add("Think", "CheckDuelRequestKeyPress", function()
    if IsValid(duelRequestPanel) then
        if input.IsKeyDown(KEY_P) then  -- Touche Y pour refuser
            net.Start("DuelResponse")
            net.WriteBool(false)  -- Refuser le duel
            net.SendToServer()

            timer.Remove(autoDeclineTimer)  -- Annuler le refus automatique
            duelRequestPanel:Remove()  -- Fermer le menu
        elseif input.IsKeyDown(KEY_O) then  -- Touche O pour accepter
            net.Start("DuelResponse")
            net.WriteBool(true)  -- Accepter le duel
            net.SendToServer()

            timer.Remove(autoDeclineTimer)  -- Annuler le refus automatique
            duelRequestPanel:Remove()  -- Fermer le menu
        end
    end
end)

-- Fermer le panneau si le duel est annulé avant la fin du temps
net.Receive("CloseDuelRequest", function()
    if IsValid(duelRequestPanel) then
        timer.Remove(autoDeclineTimer)  -- Annuler le timer si le duel est annulé
        duelRequestPanel:Remove()
    end
end)

local countdown = nil
local showGoMessage = false

-- Fonction pour afficher le compte à rebours au centre de l'écran
hook.Add("HUDPaint", "DrawDuelCountdown", function()
    if countdown then
        draw.SimpleText(countdown, "CountdownFont", ScrW() / 2, ScrH() / 2.5, Color(255, 255, 255, 255), TEXT_ALIGN_CENTER, TEXT_ALIGN_CENTER)
    end

    if showGoMessage then
        draw.SimpleText("GO", "CountdownFont", ScrW() / 2, ScrH() / 2.5, Color(255, 255, 255, 255), TEXT_ALIGN_CENTER, TEXT_ALIGN_CENTER)
    end
end)

-- Réception du compte à rebours depuis le serveur
net.Receive("StartDuelCountdown", function()
    local time = net.ReadInt(32)
    countdown = time
    showGoMessage = false  -- Réinitialiser le message GO

    -- Créer un timer pour mettre à jour le compte à rebours toutes les secondes
    timer.Create("DuelCountdownTimer", 1, time, function()
        countdown = countdown - 1
        if countdown <= 0 then
            timer.Remove("DuelCountdownTimer")
            countdown = nil
            showGoMessage = true  -- Afficher "GO" à la fin du compte à rebours
            timer.Simple(1, function()
                showGoMessage = false  -- Retirer "GO" après 1 seconde
            end)
        end
    end)
end)

-- Réinitialiser l'affichage du compte à rebours lorsqu'un duel se termine
hook.Add("DuelEnd", "ResetDuelUI", function()
    countdown = nil
    showGoMessage = false
end)

net.Receive("DuelEndMessage", function()
    local winnerName = net.ReadString()
    local loserName = net.ReadString()

    -- Afficher le message dans le chat global
     chat.AddText(GetBaseWarsTheme("adverts_prefix"), "<clr:white>:duel1::duel2::duel3::duel4::duel5:<clr:white>", color_white, " » ", winnerName .. " a gagné le duel contre " .. loserName .. " !")
end)



vgui.Register("BaseWars.F3Menu.Duel", PANEL, "DPanel")