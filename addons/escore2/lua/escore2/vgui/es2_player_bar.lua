local ceil = math.ceil
local PANEL = {}

AccessorFunc(PANEL, "font", "Font")
AccessorFunc(PANEL, "rounding", "Rounding", FORCE_NUMBER)

local empty_fn = function() end

function PANEL:Init()
    self.clr = escore2.addon:GetColors()

    self:SetText("")
    self:SetRounding(escore2.addon:GetVar("rounding"))

    self.player = nil
    self.opened = false
    self.action_keys = table.GetKeys(escore2:GetActionCategories() or {})
    self.wanted_tall = esclib:AdaptiveSize(210)

    self.animate = escore2.addon:GetVar("animate")
    self.anim = empty_fn

    self.topbar = self:Add("DButton")
    self.topbar:Dock(TOP)
    self.topbar:SetText("")
    self.topbar.DoClick = function(pnl)
        if self.opened then 
            self:Close()
        else
            self:Open()
        end
        escore2:Update()
    end
    self.topbar.DoRightClick = function(pnl)
        local bg = escore2.bg
        local ply = self:GetPlayer()
        if not IsValid(bg) then return end

        local context = vgui.Create("esclib.contextmenu", bg)
        context:SetColor(self.clr.player.bg)
        context:SetBorderColor(self.clr.player.bg_hover)
        context.Think = function(pnl)
            if (not escore2:IsOpened()) or (not IsValid(self:GetPlayer())) then 
                pnl:Close()
            end
        end

        local actions = self.action_keys
        table.sort(actions, function(a,b)
            local acat = escore2:GetActionCategory(a)
            local bcat = escore2:GetActionCategory(b)
            return acat:GetPosition() < bcat:GetPosition()
        end)

        local action_count = #actions
        for k,action_cat_name in ipairs(actions) do
            local action_category = escore2:GetActionCategory(action_cat_name)
            if not action_category then continue end

            --skip category if returned false
            if action_category:GetCheckFunc()(action_category, "context", ply) == false then continue end
            local cat_color = action_category:GetColor() or color_white

            local header = context:AddHeader(escore2.addon:Translate(action_category:GetNameTranslateKey()))
            header:SetTextColor(cat_color)
            context:AddSeparator()

            local category_color = action_category:GetColor()
            local buttons = action_category:GetButtons() or {}
            table.sort(buttons, function(a,b)
                return a:GetPosition() < b:GetPosition()
            end)
            
            for _, button_info in ipairs(buttons) do
                if button_info:GetCheckFunc()(button_info, "context", ply) == false then continue end

                local name = escore2.addon:Translate(button_info:GetNameTranslateKey())
                local btn = context:AddButton(name, function()
                    button_info:GetFunc()(button_info, ply, btn)
                end, button_info:GetIcon())

                btn.Update = function(btn)
                    button_info:GetInitFunc()(button_info, ply, btn)
                    btn:SetTextColor(self.clr.player.text_gray)
                    btn:SetTextHoverColor(self.clr.player.text_hover)
                    btn:SetColorHover(self.clr.player.bg_hover)
                    btn:SetText(escore2.addon:Translate(button_info:GetNameTranslateKey()))
                end

                btn:Update()

                button_info.Update = function()
                    if IsValid(btn) then 
                        btn:Update()
                        self:RefreshBottomPanel()
                    end
                end

            end

            if action_count ~= k then
                context:AddSeparator()
            end
        end

        context:SetPosClamped(gui.MouseX()+5,gui.MouseY()+5)
    end
    self.topbar.Paint = function(pnl, w,h)
        local hovered = pnl:IsHovered() or self.opened
        draw.RoundedBoxEx(self.rounding,0,0,w,h,hovered and self.clr.player.bg_hover or self.clr.player.bg, true, true, not self.opened, not self.opened)
    end
    timer.Simple(0, function()
        if not IsValid(self) or not IsValid(self.topbar) then return end
        self.topbar:SetSize(self:GetWide(), self:GetTall())
    end)

    self.botbar = self:Add("DPanel")
    self.botbar:Dock(FILL)
    self.botbar:Hide()
    self.botbar.Paint = function(pnl, w,h)
        draw.RoundedBoxEx(8,0,0,w,h,self.clr.player.bg_hover, false, false, true, true)
        draw.RoundedBoxEx(8,2,0,w-4,h-2,self.clr.player.bg2, false, false, true, true)
    end
    self.botbar:InvalidateParent(true)
    
end

function PANEL:OnOpen() end --for override
function PANEL:OnClose() end --for override
function PANEL:OnRemove() end --for override

function PANEL:AnimTick(frac) end --for override

function PANEL:Open()
    self.old_tall = self:GetTall()

    local wanted_tall = self.wanted_tall
    -- local botbar_tall = wanted_tall - self.topbar:GetTall()
    if self.animate then
        self.anim()
        self.anim = esclib:NewAnimation(0.2, 0, -1,
            function()
                if not IsValid(self) then return end
                self.anim = empty_fn
                self:SetTall(wanted_tall)
                self:RefreshBottomPanel()
            end, 
            function(frac)
                if not IsValid(self) then return end
                self:AnimTick(frac)
                self:SetTall(Lerp(frac, self:GetTall(), wanted_tall))
                self:RefreshBottomPanel()
            end
        )
    else
        self:SetTall(wanted_tall)
        timer.Simple(0, function() --render on next frame
            if not IsValid(self) then return end
            self:RefreshBottomPanel()
        end)
    end

    self.botbar:Show()
    self.opened = true
    self:OnOpen()
end

function PANEL:OnClose() end --for override
function PANEL:Close()

    if self.animate then
        self.anim()
        local wanted_tall = self.old_tall
        self.anim = esclib:NewAnimation(0.2, 0, -1,
            function()
                if not IsValid(self) then return end
                self.anim = empty_fn
                self:SetTall(wanted_tall)
                self.botbar:Hide()
            end, 
            function(frac)
                if not IsValid(self) then return end
                self:AnimTick(frac)
                self:SetTall(Lerp(frac, self:GetTall(), wanted_tall))
            end
        )
    else
        self.botbar:Hide()
        self:SetTall(self.old_tall)
    end
    self.opened = false
    self:OnClose()
end

function PANEL:GenerateColumns(columns)
    if not IsValid(self.player) then return end
	local column_count = #columns

	local text = escore2.addon:Translate("col_nickname")
	
	---------------------
	--# OTHER COLUMNS #--
	---------------------
	for _, col_name in ipairs(columns) do
		local col_value = escore2:GetColumn(col_name)
		if not col_value then continue end
		local middle_topbar = self.topbar:Add("DButton")
		middle_topbar:Dock(LEFT)
		middle_topbar:SetWide(self:GetWide() * col_value:GetWide())
		middle_topbar:SetText("")
		middle_topbar:SetFont(self.font)
        middle_topbar:SetMouseInputEnabled(false)
        middle_topbar:InvalidateParent(true)
		middle_topbar.name = col_name
        middle_topbar.Paint = nil
        col_value.init_playerbar(col_value, middle_topbar, self)
	end
end

function PANEL:RefreshBottomPanel()
    local w, h = self.botbar:GetWide()
    local h = self.wanted_tall - self.topbar:GetTall()

    local ply = self:GetPlayer()
    local clr = self.clr
    if not IsValid(ply) then return end

    local border = esclib:AdaptiveSize(10)
    local actions_border = esclib:AdaptiveSize(20)
    local spacing = esclib:AdaptiveSize(5)
    local avatar_border = border
    local radial_grad = esclib:GetMaterial("radial_gradient.png")
    
    local avatar = self.botbar.avatar
    if not avatar then
        avatar = self.botbar:Add("esclib.circle_avatar")
        avatar:SetPlayer(ply, 184)
        self.botbar.avatar = avatar
    end
    avatar:Dock(LEFT)
    avatar:DockMargin(avatar_border,avatar_border,avatar_border,avatar_border)
    avatar:SetWide(h-avatar_border*2)

    local poly = nil
    function avatar:DrawMask(w,h)
        if not poly then
            poly = esclib.util:PrecacheRoundedPoly(0, 0, w, h, 6, 3)
        end
        draw.NoTexture();
        surface.SetDrawColor( color_white )
        surface.DrawPoly( poly )
    end
    
    local tags_pnl = self.botbar.tags_pnl
    if not tags_pnl then
        tags_pnl = self.botbar:Add("DPanel")
        self.botbar.tags_pnl = tags_pnl
    end
    tags_pnl:Dock(LEFT)
    tags_pnl:SetWide(self.botbar:GetWide()*0.2)
    tags_pnl.Paint = nil

    local font = esclib:AdaptiveFont("escore2", 22, 500)
    local hint_font = esclib:AdaptiveFont("escore2", 18, 500)

    local layout = tags_pnl.layout
    if not layout then
        layout = tags_pnl:Add("DIconLayout")
        tags_pnl.layout = layout

        layout:SetWide(self.botbar:GetWide()*0.15)
        layout:Dock(FILL)
        layout:DockMargin(0,border,border,border)
        layout:SetSpaceX(spacing)
        layout:SetSpaceY(spacing)
    else
        layout:Clear()
    end

    --local copy_phrase = escore2.addon:Translate("copy_phrase").." "
    local info_buttons = {
        {
            ["icon"] = escore2:GetMaterial("user.png"),
            ["text"] = ply:Nick(),
            -- ["hint"] = copy_phrase..escore2.addon:Translate("col_nickname"),
        },
        {
            ["icon"] = escore2:GetMaterial("star.png"),
            ["text"] = ply:GetUserGroup(),
            -- ["hint"] = copy_phrase..escore2.addon:Translate("col_rank"),
        },
        {
            ["icon"] = escore2:GetMaterial("steam.png"),
            ["text"] = ply:SteamID(),
            -- ["hint"] = copy_phrase.."SteamID",
        },
        {
            ["icon"] = escore2:GetMaterial("steam.png"),
            ["text"] = ply:SteamID64(),
            -- ["hint"] = copy_phrase.."SteamID64",
        },
    }

    local default_hover_icon = escore2:GetMaterial("copy.png")

    for _,v in ipairs(info_buttons) do
        local text = v.text
        local icon = v.icon
        local hint = v.hint

        local tw, th = esclib.util:TextSize(text, font)
        local icon_size = th * 0.8
        local total_wide = tw + 14 + icon_size*2--self.botbar:GetWide()*0.15 - 5--tw + 14 + icon_size*2
        local total_height = ceil(h / 4 - spacing*2) --th + 10
        local infobtn = layout:Add("DButton")
        infobtn:SetText("")
        infobtn:SetSize(total_wide, total_height)
        AccessorFunc(infobtn, "color", "Color")
        infobtn:SetColor(clr.player.text_gray)
        infobtn:NoClipping(true)

        if hint then
            infobtn:eAddHint(hint, hint_font)
        end
        function infobtn:Paint(w,h)
            local hovered = self:IsHovered()
            local clicked = self.clicked

            local frame_clr = hovered and self.color or clr.player.bg_hover
            local text_clr = hovered and clr.player.text_hover or clr.player.text
            if clicked then 
                frame_clr = self.color 
                -- text_clr = self.color
            end
            
            if hovered then
                surface.SetDrawColor(frame_clr)
                surface.SetMaterial(radial_grad)
                local offset_x = w*0.4
                local offset_y = h*0.8
                surface.DrawTexturedRect(-offset_x, -offset_y, w + offset_x*2, h + offset_y*2)
            end
            
            draw.RoundedBox(8, 0,0,w,h, frame_clr)
            draw.RoundedBox(6, 2,2,w-4,h-4,hovered and clr.player.bg_hover or clr.player.bg2)

            draw.SimpleText(text, font, icon_size*2, h*0.5-1, text_clr, TEXT_ALIGN_LEFT, TEXT_ALIGN_CENTER)

            if icon then
                esclib.draw:MaterialCentered(icon_size+2, h*0.5+1, icon_size*0.5, clr.player.text_gray, hovered and default_hover_icon or icon)
            end
        end

        function infobtn:DoClick()
            if self.clicked then return end

            self.clicked = true
            self:SetColor(clr.main.text_hover)
            self:ColorTo(clr.player.text_gray, 0.3, 0, function()
                self.clicked = false
            end)

            SetClipboardText(text)
        end

        function infobtn:OnCursorEntered()
            self:SetZPos(2)
        end
        function infobtn:OnCursorExited()
            self:SetZPos(0)
        end
    end

    local actions_panel = self.botbar.actions_panel
    if not actions_panel then
        actions_panel = self.botbar:Add("DPanel")
        self.botbar.actions_panel = actions_panel
    end
    actions_panel:Dock(FILL)
    actions_panel:DockMargin(actions_border,actions_border,actions_border,actions_border)
    actions_panel:InvalidateParent(true)
    function actions_panel:Paint(w,h)
    end

    --to properly update
    actions_panel:Clear()

    local actions = self.action_keys
    table.sort(actions, function(a,b)
        local acat = escore2:GetActionCategory(a)
        local bcat = escore2:GetActionCategory(b)
        return acat:GetPosition() < bcat:GetPosition()
    end)

    local num_buttons_x = 5
    local num_buttons_y = 3 
    local button_wide = (actions_panel:GetWide() - spacing * (num_buttons_x - 1)) / num_buttons_x
    local button_tall = (actions_panel:GetTall() - spacing * (num_buttons_y - 1)) / num_buttons_y
    local bx = actions_panel:GetWide() - button_wide
    local by = 0
    for _,action_cat_name in ipairs(actions) do
        local action_category = escore2:GetActionCategory(action_cat_name)
        if not action_category then continue end

        --skip category if returned false
        if action_category:GetCheckFunc()(action_category, "player", ply) == false then continue end

        local category_color = action_category:GetColor()
        local buttons = action_category:GetButtons() or {}
        table.sort(buttons, function(a,b)
            return a:GetPosition() < b:GetPosition()
        end)
        
        for _, button_info in ipairs(buttons) do
            --skip button if returned false
            if button_info:GetCheckFunc()(button_info, "player", ply) == false then continue end

            local btn = actions_panel:Add("esclib.button")
            btn:SetPos(bx, by)
            btn:SetSize(button_wide, button_tall)
            btn:NoClipping(true)

            by = by + button_tall + spacing
            
            btn.Update = function(btn)
                button_info:GetInitFunc()(button_info, ply, btn)
                btn:SetFont(font)
                btn:SetIconSize(1.2)
                btn:SetTextColor(clr.player.text)
                btn:SetTextHoverColor(clr.player.text_hover)
                btn:SetText(escore2.addon:Translate(button_info:GetNameTranslateKey()))
                btn:SetIcon(button_info:GetIcon())
                btn:SetBackgroundColor(button_info:GetColor() or category_color)
                btn:SetIconColor(btn:GetBackgroundColor())
            end
            
            function btn:PaintBackground(w, h)
                local hovered = self:IsHovered()

                local border_color = hovered and self:GetBackgroundColor() or clr.player.bg_hover
                if hovered then
                    surface.SetDrawColor(border_color)
                    surface.SetMaterial(radial_grad)
                    local offset_x = w*0.4
                    local offset_y = h*0.8
                    surface.DrawTexturedRect(-offset_x, -offset_y, w + offset_x*2, h + offset_y*2)
                end

                draw.RoundedBox(8, 0, 0, w, h, border_color)
                draw.RoundedBox(6, 2, 2, w - 4, h - 4, clr.player.bg2)
            end
            function btn:OnCursorEntered()
                self:SetZPos(2)
            end
            function btn:OnCursorExited()
                self:SetZPos(0)
            end
            function btn:DoClick()
                button_info:GetFunc()(button_info, ply, btn)
            end
            function button_info:Update()
                if IsValid(btn) then btn:Update() end
            end

            btn:Update()
            
            --to new line
            if by >= h-actions_border*2 then
                by = 0
                bx = bx - button_wide - spacing
            end
        end

    end

end


function PANEL:SetPlayer(ply)
    self.player = ply
    self.Think = function(self)
        if IsValid(self.player) then return end

        self:OnRemove()
        self:Remove()
        escore2:Update()
    end
end

function PANEL:GetPlayer()
    return self.player
end


function PANEL:Paint(w,h)

end

vgui.Register( "escore2.player_bar", PANEL, "DPanel" )

if IsValid(escore2.bg) then --lua refresh
    escore2:Build()
end