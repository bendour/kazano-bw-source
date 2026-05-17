include("shared.lua")

local MENU_BG = Color(25, 6, 10, 230)
local MENU_BG_LIGHT = Color(45, 10, 16, 210)
local TEXT_COLOR = Color(235, 230, 230)
local BUTTON_HOVER = Color(90, 20, 26, 230)
local BUTTON_ACTIVE = Color(20, 5, 8, 240)
local BORDER_COLOR = Color(160, 30, 40, 110)
local SHADOW_COLOR = Color(0, 0, 0, 130)
local gradient_up = Material("vgui/gradient-u")
local gradient_down = Material("vgui/gradient-d")

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

function ENT:RenderOverride()
    self:DrawModel()
    if LocalPlayer():GetPos():DistToSqr(self:GetPos()) > 500 * 500 then return end
    local ang = LocalPlayer():EyeAngles()
    local pos = self:GetPos()
    local targethead = self:LookupBone("ValveBiped.Bip01_Head1")
    if targethead then
        local targetheadpos = self:GetBonePosition(targethead)
        pos = targetheadpos + Vector(0, 0, 15)
    else
        pos = self.ViewOffset
    end
    ang:RotateAroundAxis( ang:Forward(), 90 )
    ang:RotateAroundAxis( ang:Right(), 90 )
    cam.Start3D2D(pos, ang, 0.08)
        draw.SimpleTextOutlined(ashop.Config.NPCName or self.PrintName, "ashop_100_600", 0, -30, color_white, TEXT_ALIGN_CENTER, TEXT_ALIGN_TOP, 2, color_black)
    cam.End3D2D()
    
    -- Ajout du texte "Menu d'aide" au-dessus
    pos = self:GetPos() + Vector(0, 0, 80)
    ang = Angle(0, LocalPlayer():EyeAngles().y - 90, 90)
    
    cam.Start3D2D(pos, ang, 0.2)
        local boxColor = Color(100, 0, 0) -- Box très sombre
        local shadowColor = Color(15, 4, 6) -- Ombre rouge très foncée

        draw.RoundedBox(12, -95, -25, 190, 50, boxColor)
        draw.SimpleText("Help Menu", "NPCHeader", 0 + 2, 0 + 2, shadowColor, TEXT_ALIGN_CENTER, TEXT_ALIGN_CENTER)
        draw.SimpleText("Help Menu", "NPCHeader", 0, 0, TEXT_COLOR, TEXT_ALIGN_CENTER, TEXT_ALIGN_CENTER)
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
        Derma_DrawBackgroundBlur(self)
        draw.RoundedBox(16, 0, 0, w, h, MENU_BG)

        surface.SetMaterial(gradient_up)
        surface.SetDrawColor(255, 255, 255, 8)
        surface.DrawTexturedRect(2, 2, w - 4, math.floor(h * 0.50))

        surface.SetMaterial(gradient_down)
        surface.SetDrawColor(0, 0, 0, 70)
        surface.DrawTexturedRect(2, math.floor(h * 0.50), w - 4, math.floor(h * 0.50))

        surface.SetDrawColor(BORDER_COLOR)
        surface.DrawOutlinedRect(0, 0, w, h, 2)
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
        surface.SetDrawColor(MENU_BG_LIGHT)
        surface.DrawRect(0, 0, w, h)
    end
    function sbar.btnUp:Paint(w, h)
        surface.SetDrawColor(MENU_BG_LIGHT)
        surface.DrawRect(0, 0, w, h)
    end
    function sbar.btnDown:Paint(w, h)
        surface.SetDrawColor(MENU_BG_LIGHT)
        surface.DrawRect(0, 0, w, h)
    end
    function sbar.btnGrip:Paint(w, h)
        surface.SetDrawColor(BUTTON_HOVER)
        surface.DrawRect(0, 0, w, h)
    end

    local buttons = {
        {text = "Boutique | Shop", url = "https://kazano.fr/"},
        {text = "Discord", url = "https://discord.gg/kazano"},
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
            local col = MENU_BG_LIGHT
            if self:IsDown() then
                col = BUTTON_ACTIVE
            elseif self:IsHovered() then
                col = BUTTON_HOVER
            end

            draw.RoundedBox(12, 0, 0, w, h, col)

            surface.SetMaterial(gradient_up)
            surface.SetDrawColor(255, 255, 255, self:IsHovered() and 18 or 8)
            surface.DrawTexturedRect(1, 1, w - 2, h - 2)

            surface.SetMaterial(gradient_down)
            surface.SetDrawColor(0, 0, 0, 60)
            surface.DrawTexturedRect(1, 1, w - 2, h - 2)

            surface.SetDrawColor(BORDER_COLOR)
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
        local col = MENU_BG_LIGHT
        if self:IsDown() then
            col = BUTTON_ACTIVE
        elseif self:IsHovered() then
            col = BUTTON_HOVER
        end

        draw.RoundedBox(12, 0, 0, w, h, col)

        surface.SetMaterial(gradient_up)
        surface.SetDrawColor(255, 255, 255, self:IsHovered() and 18 or 8)
        surface.DrawTexturedRect(1, 1, w - 2, h - 2)

        surface.SetMaterial(gradient_down)
        surface.SetDrawColor(0, 0, 0, 60)
        surface.DrawTexturedRect(1, 1, w - 2, h - 2)

        surface.SetDrawColor(BORDER_COLOR)
        surface.DrawOutlinedRect(0, 0, w, h, 2)
    end
    
    closeButton.DoClick = function()
        surface.PlaySound("buttons/button15.wav") -- Son différent pour le bouton fermer
        frame:Close()
    end
end)