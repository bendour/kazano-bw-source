local addIcon, addSize = Material("basewars_materials/plus.png", "smooth"), BaseWars.ScreenScale * 50
local trashIcon = Material("basewars_materials/trash.png", "smooth")
local vipIcon = Material("basewars_materials/scoreboard/vip.png", "smooth")
local adventIcon = Material("basewars_materials/scoreboard/avent.png", "smooth")
local lockIcon = Material("icon16/lock.png", "smooth")
local unlockIcon = Material("icon16/lock_open.png", "smooth")
local thisPanel

local waitTime = 0
local skinsShop
local playerSkins
local activeSkinID = -1
local creditShop = {
    {
        type = "vip",
        price = 10000,
        name = "VIP"
    },
    {
        type = "advent_calendar",
        price = 10000,
        name = "Calendrier de l'Avent",
    },
    {
        type = "weapon",
        weaponClass = "weapon_vape_american",
        price = 1500,
        name = "Americain Vape",
        model = "models/swamponions/vape.mdl",
    },
    {
        type = "weapon",
        weaponClass = "weapon_vape_juicy",
        price = 1500,
        name = "Juice Vape",
        model = "models/swamponions/vape.mdl",
    },
    {
        type = "weapon",
        weaponClass = "weapon_fists",
        price = 500,
        name = "Fists",
        model = "models/weapons/v_punchy.mdl",
    },
    {
        type = "weapon",
        weaponClass = "weapon_nyangun",
        price = 1500,
        name = "Nyan Gun",
        model = "models/weapons/w_smg1.mdl"
    },
    {
        type = "weapon",
        weaponClass = "mac_lara",
        price = 2500,
        name = "Mac Lara",
        model = "models/weapons/w_smg_macla.mdl",
        SetPrestige = 5
    },
    {
        type = "weapon",
        weaponClass = "m9k_dbarrel",
        price = 3000,
        name = "DB Shotgun",
        model = "models/weapons/w_double_barrel_shotgun.mdl",
		SetPrestige = 7
    },
    {
        type = "weapon",
        weaponClass = "weapon_m4a1_beast",
        price = 3000,
        name = "M4A1 Beast",
        model = "models/cf/w_m4a1_beast.mdl",
		SetPrestige = 10
    },
    {
        type = "weapon",
        weaponClass = "weapon_ak47_beast",
        price = 3000,
        name = "AK47 Iron Beast",
        model = "models/cf/w_ak47_beast.mdl",
		SetPrestige = 10
    },
    {
        type = "weapon",
        weaponClass = "m9k_spas12",
        price = 2500,
        name = "SPAS-12",
        model = "models/weapons/w_spas_12.mdl",
		SetPrestige = 12
    },
    {
        type = "weapon",
        weaponClass = "awpgradient",
        price = 3000,
        name = "AWP",
        model = "models/weapons/w_snip_awp.mdl",
        SetPrestige = 15
    },
    {
        type = "weapon",
        weaponClass = "ryry_msr",
        price = 5000,
        name = "MSR",
        model = "models/weapons/w_ryry_mwmsr.mdl",
        SetPrestige = 25
    }
}

local cardH = BaseWars.ScreenScale * 350
local roundness = BaseWars.ScreenScale * 4
local buttonTall = BaseWars.ScreenScale * 36
local elementTall = BaseWars.ScreenScale * 40
local bigMargin = BaseWars.ScreenScale * 10
local margin = BaseWars.ScreenScale * 5
local thisPanel
local activeBorder = math.floor(BaseWars.ScreenScale * 3)

local PANEL = {}
function PANEL:Init()
    thisPanel = self
    self.w, self.h = self:GetParent():GetSize()

    self.localPlayer = LocalPlayer()
    self.isSuperAdmin = BaseWars:IsSuperAdmin(self.localPlayer)
    self.isVIP = BaseWars:IsVIP(self.localPlayer)
    self.tab = ""
    self.colors = {
        text = GetBaseWarsTheme("bws_text") or GetBaseWarsTheme("bwm_text"),
        darkText = GetBaseWarsTheme("bws_darkText") or GetBaseWarsTheme("bwm_darkText"),
        contentBackground = GetBaseWarsTheme("bws_contentBackground") or GetBaseWarsTheme("bwm_contentBackground"),
        accent = GetBaseWarsTheme("bws_accent") or GetBaseWarsTheme("gen_accent")
    }

    function PANEL:Update()
    self:Build("creditShop")
    end

    thisPanel = self

    self.Topbar = self:Add("DPanel")
    self.Topbar:Dock(TOP)
    self.Topbar:DockMargin(bigMargin, bigMargin, bigMargin, bigMargin)
    self.Topbar:SetTall(buttonTall + bigMargin * 2)
    self.Topbar.Paint = function(s,w,h)
        BaseWars:DrawRoundedBox(roundness, 0, 0, w, h, self.colors.contentBackground)
    end

    local buttonWide = (self.w - bigMargin * 6) / 3
    self.Topbar.PlayerSkins = self.Topbar:Add("BaseWars.Button")
    self.Topbar.PlayerSkins:Dock(LEFT)
    self.Topbar.PlayerSkins:DockMargin(bigMargin, bigMargin, 0, bigMargin)
    self.Topbar.PlayerSkins:SetWide(buttonWide)
    self.Topbar.PlayerSkins:SetColor(self.colors.contentBackground, true)
    self.Topbar.PlayerSkins:SetAccentColor(self.colors.accent)
    self.Topbar.PlayerSkins.Draw = function(s,w,h)
        draw.SimpleText(self.localPlayer:GetLang("pointshop_tabPlayer"), "BaseWars.24", w * .5, h * .5, self.colors.text, 1, 1)
    end
    self.Topbar.PlayerSkins.LerpFunc = function(s)
        return s:IsHovered() or self.tab == "player"
    end
    self.Topbar.PlayerSkins.DoClick = function(s)
        if self.tab == "player" then return end

        s:ButtonSound()

        self:Build("player")
    end

    self.Topbar.SkinShop = self.Topbar:Add("BaseWars.Button")
    self.Topbar.SkinShop:Dock(LEFT)
    self.Topbar.SkinShop:DockMargin(bigMargin, bigMargin, 0, bigMargin)
    self.Topbar.SkinShop:SetWide(buttonWide)
    self.Topbar.SkinShop:SetColor(self.colors.contentBackground, true)
    self.Topbar.SkinShop:SetAccentColor(self.colors.accent)
    self.Topbar.SkinShop.Draw = function(s,w,h)
        draw.SimpleText(self.localPlayer:GetLang("pointshop_tabShop"), "BaseWars.24", w * .5, h * .5, self.colors.text, 1, 1)
    end
    self.Topbar.SkinShop.LerpFunc = function(s)
        return s:IsHovered() or self.tab == "shop"
    end
    self.Topbar.SkinShop.DoClick = function(s)
        if self.tab == "shop" then return end

        s:ButtonSound()

        self:Build("shop")
    end

    self.Topbar.CreditShop = self.Topbar:Add("BaseWars.Button")
    self.Topbar.CreditShop:Dock(LEFT)
    self.Topbar.CreditShop:DockMargin(bigMargin, bigMargin, 0, bigMargin)
    self.Topbar.CreditShop:SetWide(buttonWide)
    self.Topbar.CreditShop:SetColor(self.colors.contentBackground, true)
    self.Topbar.CreditShop:SetAccentColor(self.colors.accent)
    self.Topbar.CreditShop.Draw = function(s,w,h)
        draw.SimpleText(self.localPlayer:GetLang("pointshop_tabCreditShop"), "BaseWars.24", w * .5, h * .5, self.colors.text, 1, 1)
    end
    self.Topbar.CreditShop.LerpFunc = function(s)
        return s:IsHovered() or self.tab == "creditShop"
    end
    self.Topbar.CreditShop.DoClick = function(s)
        if self.tab == "creditShop" then return end

        s:ButtonSound()

        self:Build("creditShop")
    end

    self.Content = self:Add("DPanel")
    self.Content:Dock(FILL)
    self.Content:DockMargin(bigMargin, 0, bigMargin, bigMargin)
    self.Content.Paint = nil

    if skinsShop == nil or playerSkins == nil then
        net.Start("BaseWars:Pointshop:PlayerRequestData")
        net.SendToServer()
    end

    self:Build("player")
end

function PANEL:Build(tab)
    tab = tab or self.tab
    self.tab = tab

    self.Content:Clear()

    if tab == "player" then
        if not playerSkins then return end

        local cardW = (self.w - bigMargin * 2 - margin * 4 - (table.Count(playerSkins) > 5 and bigMargin + margin or 0)) * .2

        self.Content.Scroll = self.Content:Add("DScrollPanel")
        self.Content.Scroll:Dock(FILL)
        self.Content.Scroll:PaintScrollBar("bws")

        self.Content.Scroll.Layout = self.Content.Scroll:Add("DIconLayout")
        self.Content.Scroll.Layout:Dock(TOP)
        self.Content.Scroll.Layout:SetTall(self.h)
        self.Content.Scroll.Layout:SetSpaceX(margin)
        self.Content.Scroll.Layout:SetSpaceY(margin)

        for _, skinID in ipairs(playerSkins) do
            local skinData = skinsShop[skinID]

            if not skinData then
                continue
            end

            local skinPanel = self.Content.Scroll.Layout:Add("DButton")
            skinPanel:SetText("")
            skinPanel:SetSize(cardW, cardH)
            skinPanel.color = self.colors.contentBackground
            skinPanel.Paint = function(s,w,h)
                s.color = BaseWars:LerpColor(self.lerpFrac, s.color, self.colors[activeSkinID == skinID and "accent" or "contentBackground"])

                BaseWars:DrawRoundedBox(4, 0, 0, w, h, s.color)
                BaseWars:DrawRoundedBox(roundness, activeBorder, activeBorder, w - activeBorder * 2, h - activeBorder * 2, self.colors.contentBackground)

                if skinData.is_vip then
                    local pos = activeSkinID == skinID and margin + activeBorder or margin
                    BaseWars:DrawMaterial(vipIcon, pos, pos, bigMargin * 1.8, bigMargin * 1.8, self.colors.text)
                end
            end
            skinPanel.DoClick = function(s)
                if waitTime >= CurTime() then
                    BaseWars:Notify("#pointshop_slowdown", NOTIFICATION_ERROR, 5)

                    return
                end

                if activeSkinID == skinID then
                    activeSkinID = -1
                else
                    activeSkinID = skinID
                end

                waitTime = CurTime() + .5

                net.Start("BaseWars:Pointshop:ChangeActiveSkin")
                    net.WriteInt(activeSkinID, 32)
                net.SendToServer()

                surface.PlaySound("bw_button.wav")
            end

            skinPanel.Model = skinPanel:Add("DModelPanel")
            skinPanel.Model:Dock(FILL)
            skinPanel.Model:SetModel(skinData.model)
            skinPanel.Model:SetMouseInputEnabled(false)
        end
    end

    if tab == "shop" then
        self.Content.PlayerPointshop = self.Content:Add("DPanel")
        self.Content.PlayerPointshop:Dock(TOP)
        self.Content.PlayerPointshop:SetTall(elementTall)
        self.Content.PlayerPointshop:DockMargin(0, 0, 0, bigMargin)
        self.Content.PlayerPointshop.Paint = function(s,w,h)
            BaseWars:DrawRoundedBox(roundness, 0, 0, w, h, self.colors.contentBackground)
            draw.SimpleText(Format(self.localPlayer:GetLang("pointshop_playerPointshop"), BaseWars:FormatNumber(self.localPlayer:GetPointshop())), "BaseWars.20", w * .5, h * .5, self.colors.text, 1, 1)
        end

        if not skinsShop then return end

        local cardW = (self.w - bigMargin * 2 - margin * 4 - (table.Count(skinsShop) + 1 > 5 and bigMargin + margin or 0)) * .2

        self.Content.Scroll = self.Content:Add("DScrollPanel")
        self.Content.Scroll:Dock(FILL)
        self.Content.Scroll:PaintScrollBar("bws")

        self.Content.Scroll.Layout = self.Content.Scroll:Add("DIconLayout")
        self.Content.Scroll.Layout:Dock(TOP)
        self.Content.Scroll.Layout:SetTall(self.h)
        self.Content.Scroll.Layout:SetSpaceX(margin)
        self.Content.Scroll.Layout:SetSpaceY(margin)

        -- Always create the admin button
        self.Content.Scroll.Layout.AdminAddSkin = self.Content.Scroll.Layout:Add("DButton")
        self.Content.Scroll.Layout.AdminAddSkin:SetText("")
        self.Content.Scroll.Layout.AdminAddSkin:SetSize(cardW, cardH)
        self.Content.Scroll.Layout.AdminAddSkin.color = self.colors.darkText
        self.Content.Scroll.Layout.AdminAddSkin.Paint = function(s,w,h)
            s.color = BaseWars:LerpColor(self.lerpFrac, s.color, self.colors[s:IsHovered() and "text" or "darkText"])

            BaseWars:DrawRoundedBox(roundness, 0, 0, w, h, self.colors.contentBackground)
            BaseWars:DrawMaterial(addIcon, w * .5, h * .5, addSize, addSize, s.color, 0)
        end
        self.Content.Scroll.Layout.AdminAddSkin.DoClick = function(s)
            surface.PlaySound("bw_button.wav")

            self.AddSkin = vgui.Create("BaseWars.Pointshop.AddSkin")
            self.AddSkin.Think = function(thinkSelf)
                if not IsValid(self) then
                    thinkSelf:Remove()
                end
            end
        end
        self.Content.Scroll.Layout.AdminAddSkin.Think = function(s)
            s:SetVisible(BaseWars:IsSuperAdmin(self.localPlayer))
        end

        for skinID, skinData in SortedPairsByMemberValue(skinsShop, "price") do
            local hasSkin = false
            for k, v in ipairs(playerSkins) do
                if v == skinID then
                    hasSkin = true

                    break
                end
            end

            local skinPanel = self.Content.Scroll.Layout:Add("DButton")
            skinPanel:SetText("")
            skinPanel:SetSize(cardW, cardH)
            skinPanel.Paint = function(s,w,h)
                s:SetCursor((hasSkin or not skinData.purchasable or (skinData.is_vip and not self.isVIP)) and "arrow" or "hand")
            end
            skinPanel.DoClick = function(s)
                if hasSkin then
                    return
                end

                if not skinData.purchasable then
                    BaseWars:Notify("Ce skin n'est pas achetable (événement/récompense uniquement)", NOTIFICATION_ERROR, 5)
                    return
                end

                if skinData.is_vip and not self.isVIP then
                    BaseWars:Notify("#pointshop_vipSkin", NOTIFICATION_ERROR, 5)

                    return
                end

                if self.localPlayer:GetPointshop() < skinData.price then
                    BaseWars:Notify("#pointshop_tooExpensive", NOTIFICATION_ERROR, 5)

                    return
                end

                surface.PlaySound("bw_button.wav")

                skinPanel.BuySkin = vgui.Create("BaseWars.Pointshop.BuySkin")
                skinPanel.BuySkin:SetSkinPanelParent(skinPanel)
                skinPanel.BuySkin:SetData(skinID, skinData)
                skinPanel.BuySkin.Think = function(thinkSelf)
                    if not IsValid(skinPanel) then
                        thinkSelf:Remove()
                    end
                end
            end
            skinPanel.DoRightClick = function(s)
                SetClipboardText(skinID)
                BaseWars:Notify("#pointshop_idCopied", NOTIFICATION_GENERIC, 5)
            end

            skinPanel.Model = skinPanel:Add("DModelPanel")
            skinPanel.Model:Dock(FILL)
            skinPanel.Model:SetModel(skinData.model)
            skinPanel.Model:SetMouseInputEnabled(false)
            skinPanel.Model.oldPaint = skinPanel.Model.Paint
            skinPanel.Model.Paint = function(s,w,h)
                BaseWars:DrawRoundedBox(roundness, 0, 0, w, h, self.colors.contentBackground)
                s.oldPaint(s,w,h)
            end

            skinPanel.PriceTag = skinPanel:Add("DPanel")
            skinPanel.PriceTag:Dock(BOTTOM)
            skinPanel.PriceTag:DockMargin(0, margin, 0, 0)
            skinPanel.PriceTag:SetTall(elementTall)
            skinPanel.PriceTag:SetMouseInputEnabled(false)
            skinPanel.PriceTag.Paint = function(s,w,h)
                BaseWars:DrawRoundedBox(roundness, 0, 0, w, h, self.colors.contentBackground)

                local text = "pointshop_pricePointshop"
                local textColor = self.colors.text
                
                if not skinData.purchasable then
                    text = "Événement/Perso"
                    textColor = self.colors.darkText
                elseif skinData.is_vip and not self.isVIP then
                    text = "pointshop_vipOnly"
                    textColor = self.colors.darkText
                elseif hasSkin then
                    text = "pointshop_owned"
                    textColor = self.colors.darkText
                elseif self.localPlayer:GetPointshop() < skinData.price then
                    textColor = self.colors.darkText
                end

                local displayText = text == "pointshop_pricePointshop" and Format(self.localPlayer:GetLang(text), BaseWars:FormatNumber(skinData.price)) or (text == "pointshop_vipOnly" and self.localPlayer:GetLang(text) or text)
                if hasSkin then
                    displayText = self.localPlayer:GetLang(text)
                end
                
                draw.SimpleText(displayText, "BaseWars.20", w * .5, h * .5, textColor, 1, 1)
            end

            if self.isSuperAdmin then
                skinPanel.DeleteSkin = skinPanel:Add("DButton")
                skinPanel.DeleteSkin:SetText("")
                skinPanel.DeleteSkin:SetSize(bigMargin * 3, bigMargin * 3)
                skinPanel.DeleteSkin:SetPos(cardW - bigMargin * 3 - margin, margin)
                skinPanel.DeleteSkin.color = self.colors.darkText
                skinPanel.DeleteSkin.Paint = function(s,w,h)
                    s.color = BaseWars:LerpColor(self.lerpFrac, s.color, self.colors[s:IsHovered() and "text" or "darkText"])

                    BaseWars:DrawMaterial(trashIcon, h * .5, h * .5, h * .6, h * .6, s.color, 0)
                end
                skinPanel.DeleteSkin.DoClick = function(s)
                    surface.PlaySound("bw_button.wav")

                    net.Start("BaseWars:Pointshop:RemoveSkin")
                        net.WriteUInt(skinID, 31)
                    net.SendToServer()

                    s:Remove()
                end
                skinPanel.DeleteSkin.Think = function(s)
                    if not self.isSuperAdmin then
                        s:Remove()
                    end
                end
                
                -- Toggle purchase button
                skinPanel.TogglePurchase = skinPanel:Add("DButton")
                skinPanel.TogglePurchase:SetText("")
                skinPanel.TogglePurchase:SetSize(bigMargin * 3, bigMargin * 3)
                skinPanel.TogglePurchase:SetPos(cardW - bigMargin * 6 - margin * 2, margin)
                skinPanel.TogglePurchase.color = self.colors.darkText
                skinPanel.TogglePurchase.Paint = function(s,w,h)
                    s.color = BaseWars:LerpColor(self.lerpFrac, s.color, self.colors[s:IsHovered() and "text" or "darkText"])
                    
                    local icon = skinData.purchasable and unlockIcon or lockIcon
                    BaseWars:DrawMaterial(icon, 0, 0, w, h, s.color, 0)
                end
                skinPanel.TogglePurchase.DoClick = function(s)
                    surface.PlaySound("bw_button.wav")
                    
                    RunConsoleCommand("bw_toggleskinpurchase", tostring(skinID))
                end
                skinPanel.TogglePurchase.Think = function(s)
                    if not self.isSuperAdmin then
                        s:Remove()
                    end
                end
            end

            if skinData.is_vip then
                skinPanel.VIPSkin = skinPanel:Add("DButton")
                skinPanel.VIPSkin:SetText("")
                skinPanel.VIPSkin:SetSize(bigMargin * 3, bigMargin * 3)
                skinPanel.VIPSkin:SetPos(margin, margin)
                skinPanel.VIPSkin.Paint = function(s,w,h)
                    BaseWars:DrawMaterial(vipIcon, h * .5, h * .5, h * .65, h * .65, self.colors.text, 0)
                end
                skinPanel.VIPSkin.DoClick = function(s)
                    surface.PlaySound("bw_button.wav")

                    net.Start("BaseWars:Pointshop:RemoveSkin")
                        net.WriteUInt(skinID, 31)
                    net.SendToServer()

                    s:Remove()
                end
                skinPanel.VIPSkin.Think = function(s)
                    if not self.isSuperAdmin then
                        s:Remove()
                    end
                end
            end
        end
    end

    if tab == "creditShop" then
        self.Content.PlayerPointshop = self.Content:Add("DPanel")
        self.Content.PlayerPointshop:Dock(TOP)
        self.Content.PlayerPointshop:SetTall(elementTall)
        self.Content.PlayerPointshop:DockMargin(0, 0, 0, bigMargin)
        self.Content.PlayerPointshop.Paint = function(s,w,h)
            BaseWars:DrawRoundedBox(roundness, 0, 0, w, h, self.colors.contentBackground)
            draw.SimpleText(Format(self.localPlayer:GetLang("pointshop_playerCredit"), BaseWars:FormatNumber(self.localPlayer:GetCredit())), "BaseWars.20", w * .5, h * .5, self.colors.text, 1, 1)
        end

        local cardW = (self.w - bigMargin * 2 - margin * 4 - (table.Count(creditShop) > 5 and bigMargin + margin or 0)) * .2
        local creditCardH = cardW + elementTall * 2 + bigMargin

        self.Content.Scroll = self.Content:Add("DScrollPanel")
        self.Content.Scroll:Dock(FILL)
        self.Content.Scroll:PaintScrollBar("bwm")

        self.Content.Scroll.Layout = self.Content.Scroll:Add("DIconLayout")
        self.Content.Scroll.Layout:Dock(TOP)
        self.Content.Scroll.Layout:SetTall(self.h)
        self.Content.Scroll.Layout:SetSpaceX(margin)
        self.Content.Scroll.Layout:SetSpaceY(margin)

        for id, data in ipairs(creditShop) do
            local hasItem = ((data.type == "vip" and self.isVIP) or (data.type == "weapon" and BaseWars.PW:HasWeapon(data.weaponClass)))

            local item = self.Content.Scroll.Layout:Add("DButton")
            item:SetText("")
            item:SetSize(cardW, creditCardH)
            item.Paint = function(s,w,h)
                s:SetCursor(hasItem and "arrow" or "hand")
            end
           item.DoClick = function(s)
            local buyed = (data.type == "weapon" and BaseWars.PW:HasWeapon(data.weaponClass))
            if hasItem or buyed then return end

            surface.PlaySound("bw_button.wav")

            if self.localPlayer:GetCredit() < data.price then
            BaseWars:Notify("#pointshop_tooExpensive", NOTIFICATION_ERROR, 5)
            return
            end

    -- Vérification du niveau de prestige
            if data.SetPrestige and self.localPlayer:GetPrestige() < data.SetPrestige then
                BaseWars:Notify("You need prestige level " .. data.SetPrestige .. " to buy this item.")
                    return
            end
        
                    local itemPanel = s:GetParent()
            local itemID = id
                     local itemData = data
        
            if not itemID then
                error("itemID is nil")
    end

    itemPanel.BuyItem = vgui.Create("BaseWars.Pointshop.BuyItem")
    itemPanel.BuyItem:SetItemPanelParent(itemPanel)
    itemPanel.BuyItem:SetData(itemID, itemData)
    itemPanel.BuyItem.Think = function(thinkSelf)
        if not IsValid(itemPanel) then
            thinkSelf:Remove()
        end
    end
end

item.Bottom = item:Add("DPanel")
item.Bottom:Dock(TOP)
item.Bottom:DockMargin(0, 0, 0, margin)
item.Bottom:SetTall(elementTall)
item.Bottom:SetMouseInputEnabled(false)
item.Bottom.Paint = function(s,w,h)
    BaseWars:DrawRoundedBox(roundness, 0, 0, w, h, self.colors.contentBackground)
    draw.SimpleText(data.name, "BaseWars.20", w * .5, h * .5, self.colors.text, 1, 1)
end

item.Middle = item:Add("DPanel")
item.Middle:Dock(FILL)
                item.Middle:SetMouseInputEnabled(false)

            if data.type == "vip" then
                item.Middle.Paint = function(s,w,h)
                    BaseWars:DrawRoundedBox(roundness, 0, 0, w, h, self.colors.contentBackground)
                    BaseWars:DrawMaterial(vipIcon, bigMargin * 3, bigMargin * 3, w - bigMargin * 6, h - bigMargin * 6, self.colors.text)
                end
            elseif data.type == "advent_calendar" then
                item.Middle.Paint = function(s,w,h)
                    BaseWars:DrawRoundedBox(roundness, 0, 0, w, h, self.colors.contentBackground)
                    BaseWars:DrawMaterial(adventIcon, bigMargin * 3, bigMargin * 3, w - bigMargin * 6, h - bigMargin * 6, self.colors.text)
                end
            else
                item.Middle.Paint = function(s,w,h)
                    BaseWars:DrawRoundedBox(roundness, 0, 0, w, h, self.colors.contentBackground)
                end

                item.Middle.Model = item.Middle:Add("SpawnIcon")
                item.Middle.Model:Dock(FILL)
                item.Middle.Model:DockMargin(bigMargin, bigMargin, bigMargin, bigMargin)
                item.Middle.Model:SetMouseInputEnabled(false)
                item.Middle.Model:SetModel(data.model)
            end

            item.Bottom = item:Add("DPanel")
            item.Bottom:Dock(BOTTOM)
            item.Bottom:DockMargin(0, margin, 0, 0)
            item.Bottom:SetTall(elementTall)
            item.Bottom:SetMouseInputEnabled(false)
            item.Bottom.Paint = function(s,w,h)
                BaseWars:DrawRoundedBox(roundness, 0, 0, w, h, self.colors.contentBackground)
                draw.SimpleText(Format(self.localPlayer:GetLang(hasItem and "pointshop_owned" or "pointshop_priceCredit"), BaseWars:FormatNumber(data.price)), "BaseWars.20", w * .5, h * .5, self.colors[(self.localPlayer:GetCredit() < data.price or hasItem) and "darkText" or "text"], 1, 1)
            end
        end
    end
end

function PANEL:Think()
    self.isSuperAdmin = BaseWars:IsSuperAdmin(self.localPlayer)
    self.isVIP = BaseWars:IsVIP(self.localPlayer)
end

function PANEL:Paint()
    self.lerpFrac = FrameTime() * 20
end

vgui.Register("BaseWars.F3Menu.Pointshop", PANEL, "DPanel")

net.Receive("BaseWars:Pointshop:PlayerRequestData", function(len)
    local data = util.JSONToTable(util.Decompress(net.ReadData(len / 8)), false, false)

    if data.skinsShop then
        skinsShop = data.skinsShop
    end

    if data.playerSkins then
        playerSkins = data.playerSkins
    end

    if data.activeSkinID then
        activeSkinID = data.activeSkinID
    end

    if IsValid(thisPanel) then
        thisPanel:Build()
    end
end)