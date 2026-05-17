include("shared.lua")

local MENU_BG = Color(13, 19, 47)
local TEXT_COLOR = Color(255, 255, 255)
local BUTTON_HOVER = Color(20, 30, 70)
local BUTTON_ACTIVE = Color(25, 35, 80)

surface.CreateFont("NPCHeader", {
    font = "Roboto",
    size = 40,
    weight = 700,
    antialias = true
})

surface.CreateFont("MenuTitle", {
    font = "Roboto",
    size = 32,
    weight = 700,
    antialias = true
})

surface.CreateFont("ButtonText", {
    font = "Roboto",
    size = 24,
    weight = 500,
    antialias = true
})

function ENT:Draw()
    self:DrawModel()
    
    local pos = self:GetPos() + Vector(0, 0, 85)
    local ang = Angle(0, LocalPlayer():EyeAngles().y - 90, 90)
    
    cam.Start3D2D(pos, ang, 0.2)
        -- Contour arrondi plus fin
        draw.RoundedBox(8, -120, -25, 240, 50, MENU_BG)
        -- Texte centré
        draw.SimpleTextOutlined("Helper Menu", "NPCHeader", 0, 0, TEXT_COLOR, TEXT_ALIGN_CENTER, TEXT_ALIGN_CENTER, 3, Color(0, 0, 0))
    cam.End3D2D()
end

net.Receive("OpenHelperMenu", function()
    local frame = vgui.Create("DFrame")
    frame:SetSize(600, 400)
    frame:Center()
    frame:SetTitle("")
    frame:SetDraggable(false)
    frame:ShowCloseButton(false)
    frame:MakePopup()
    
    -- Animation d'ouverture
    frame:SetAlpha(0)
    frame:SetSize(0, 0)
    
    local targetW, targetH = 600, 400
    local animTime = 0.3
    local startTime = SysTime()
    
    frame.Think = function(self)
        local fraction = math.Clamp((SysTime() - startTime) / animTime, 0, 1)
        fraction = math.ease.InOutQuad(fraction)
        
        local w = Lerp(fraction, 0, targetW)
        local h = Lerp(fraction, 0, targetH)
        local alpha = Lerp(fraction, 0, 255)
        
        frame:SetSize(w, h)
        frame:SetAlpha(alpha)
        frame:Center()
        
        if fraction == 1 then
            frame.Think = nil
        end
    end
    
    frame.Paint = function(self, w, h)
        surface.SetDrawColor(MENU_BG)
        surface.DrawRect(0, 0, w, h)
    end

    local title = vgui.Create("DLabel", frame)
    title:SetText("Menu d'aide")
    title:SetFont("MenuTitle")
    title:SetTextColor(TEXT_COLOR)
    title:SetPos(20, 10)
    title:SizeToContents()

    local buttonList = vgui.Create("DScrollPanel", frame)
    buttonList:Dock(FILL)
    buttonList:DockMargin(15, 50, 15, 60)

    local sbar = buttonList:GetVBar()
    sbar:SetWide(8)
    function sbar:Paint(w, h)
        surface.SetDrawColor(BUTTON_HOVER)
        surface.DrawRect(0, 0, w, h)
    end
    function sbar.btnUp:Paint(w, h)
        surface.SetDrawColor(BUTTON_HOVER)
        surface.DrawRect(0, 0, w, h)
    end
    function sbar.btnDown:Paint(w, h)
        surface.SetDrawColor(BUTTON_HOVER)
        surface.DrawRect(0, 0, w, h)
    end
    function sbar.btnGrip:Paint(w, h)
        surface.SetDrawColor(BUTTON_ACTIVE)
        surface.DrawRect(0, 0, w, h)
    end

    local buttons = {
        {text = "Boutique | Shop", url = "https://kazano.fr/"},
        {text = "Addons", url = "https://steamcommunity.com/sharedfiles/filedetails/?id=3355620511"},
        {text = "Règlement (FR)", url = "https://kazano.fr/regles"},
        {text = "Rules (EN)", url = "https://kazano.fr/rules"},
    }

    for i, btnData in ipairs(buttons) do
        local btn = vgui.Create("DButton", buttonList)
        btn:SetText(btnData.text)
        btn:SetTall(40)
        btn:DockMargin(0, 0, 0, 10)
        btn:Dock(TOP)
        btn:SetFont("ButtonText")
        btn:SetTextColor(TEXT_COLOR)
        
        local btnColor = MENU_BG
        btn.Paint = function(self, w, h)
            if self:IsDown() then
                btnColor = BUTTON_ACTIVE
            elseif self:IsHovered() then
                btnColor = BUTTON_HOVER
            else
                btnColor = MENU_BG
            end
            
            surface.SetDrawColor(btnColor)
            surface.DrawRect(0, 0, w, h)
            surface.SetDrawColor(BUTTON_HOVER)
            surface.DrawOutlinedRect(0, 0, w, h, 2)
        end

        btn.DoClick = function()
            surface.PlaySound("buttons/button14.wav") -- Son classique pour les boutons
            gui.OpenURL(btnData.url)
        end
    end

    -- Bouton Fermer stylisé
    local closeButton = vgui.Create("DButton", frame)
    closeButton:SetText("Fermer")
    closeButton:SetSize(150, 40)
    closeButton:SetPos(225, 340)
    closeButton:SetTextColor(Color(255, 255, 255))
    closeButton:SetFont("ButtonText")
    
    closeButton.Paint = function(self, w, h)
        -- Même style que les autres boutons
        local btnColor = self:IsHovered() and BUTTON_HOVER or MENU_BG
        if self:IsDown() then
            btnColor = BUTTON_ACTIVE
        end
        
        surface.SetDrawColor(btnColor)
        surface.DrawRect(0, 0, w, h)
        surface.SetDrawColor(BUTTON_HOVER)
        surface.DrawOutlinedRect(0, 0, w, h, 2)
    end
    
    closeButton.DoClick = function()
        surface.PlaySound("buttons/button15.wav") -- Son différent pour le bouton fermer
        frame:Close()
    end
end)