ashop.UIOptions = ashop.UIOptions or {}
ashop.UIUserOptions = ashop.UIUserOptions or {}

local stateOn = ashop.GetColor('StateOn')
local stateOnR, stateOnG, stateOnB = ashop.GetColor('StateOn'):Unpack()
local stateOffR, stateOffG, stateOffB = ashop.GetColor('StateOff'):Unpack()
local Grad2_0 = ashop.GetColor('Grad2_0')
local white50 = ashop.GetColor('White50')
local white25 = ashop.GetColor('White25')
local white = ashop.GetColor('White')

local PANEL = {}

function ashop.registerParameter(name, getOptionsFunc, interior, createButton, afterCreation)
    ashop.UIOptions[name] = {getOptionsFunc, interior, createButton, afterCreation}
end

function ashop.registerUserParameter(name, getOptionsFunc, interior, createButton, afterCreation, shouldBeDrawn)
    ashop.UIUserOptions[name] = {getOptionsFunc, interior, createButton, afterCreation}
end

function PANEL:Init()
end

function PANEL:TableFill(tableFill)
    self:SetPaintBackground(false)
    local horizontalMargin = ashop.GetSize(64)
    local marginVertical = ashop.GetSize(20)

    self:SetMouseInputEnabled(true)
    self:SetKeyboardInputEnabled(true)
    
    // setting Init
    local setting = vgui.Create("DPanel", self)
    setting:Dock(LEFT)
    setting:SetWide(ashop.GetSize(220))
    setting:DockMargin(0, 0, 0, 0)
    setting:SetPaintBackground(false)

    local settingContainer = vgui.Create("DScrollPanel", setting)
    settingContainer:Dock(FILL)
    ashop.ui.SkinScrollPanel(settingContainer, stateOn)

    function settingContainer:Paint(w, h)
        surface.SetDrawColor(Grad2_0)
        surface.DrawRect(w-2, 0, 2, h)
    end

    local settingSingle = vgui.Create("EditablePanel", self)
    settingSingle:Dock(FILL)
    settingSingle:DockMargin(horizontalMargin, 0, horizontalMargin, 0)

    local holder = {}

    local but

    local function initChilds(childContainer, name, lbl, p, oldID, refresh)
        childContainer:SetTall(0)
        local v = tableFill[name]
        if v[2] then
            for i, j in SortedPairs(v[2]()) do
                local settingTitle = vgui.Create("DButton", childContainer)
                settingTitle:Dock(TOP)
                settingTitle:SetText(j[1])
                settingTitle:SetFont("ashop_14_600")
                settingTitle:SetTall(select(2, settingTitle:GetContentSize())*1.75)
                settingTitle:SetTextColor(white50)
                settingTitle:DockMargin(0, i != 1 and 0 or marginVertical, 0, 0)
                settingTitle:SetContentAlignment(4)
                settingTitle:SetPaintBackground(false)
                settingTitle:SetTextInset(16, 0)
                settingTitle.id = i
                settingTitle.settingName = name

                function settingTitle:Paint(w, h)
                    if but == self then
                        surface.SetDrawColor(stateOnR, stateOnG, stateOnB)
                    else
                        surface.SetDrawColor(stateOffR, stateOffG, stateOffB)
                    end

                    surface.DrawRect(8, 0, 2, h)
                end
                
                function settingTitle:DoClick()
                    settingSingle:Clear()
                    v[1](settingSingle, j[2], j[3], settingTitle)
                    if IsValid(but) then
                        but:SetTextColor(white50)
                    end
                    settingTitle:SetTextColor(stateOn)
                    but = settingTitle
                end

                if oldID and i == oldID then
                    timer.Simple(0, function()
                        settingTitle:DoClick()
                    end)
                end

                childContainer:SetTall(settingTitle:GetTall() + childContainer:GetTall() + (i != 1 and 0 or marginVertical))

                if v[4] then
                    v[4](settingTitle, tableFill[name], j[3], j)
                end
            end
        end

        if !refresh and v[3] then
            local add = vgui.Create('DButton', p)
            add:Dock(RIGHT)
            add:SetText('+')
            add:SetFont('ashop_20_600')
            add:SetTextColor(white25)
            add:DockMargin(0, 0, marginVertical, 0)
            add:SetPaintBackground(false)
            add:SetMouseInputEnabled(true)

            // Not doing OnEnterd/exited since there also childs
            function add:Think()
                local b = (lbl:IsChildHovered() or lbl:IsHovered())
                add:SetTextColor(b and white25 or color_transparent)
            end

            function add:DoClick()
                v[3]()
            end
        end
    end

    for k, v in SortedPairs(tableFill) do
        local function cb()
            local lbl = vgui.Create("DLabel", settingContainer)
            lbl:SetFont('ashop_20_600')
            lbl:SetText(k)
            lbl:SetContentAlignment(4)
            lbl:Dock(TOP)
            lbl:SetTall(select(2, lbl:GetContentSize()))
            lbl:SetTextColor(white50)
            lbl:SetPaintBackground(false)
            lbl:DockMargin(0, marginVertical/2, 0, 0)
            lbl:SetContentAlignment(7)
            lbl:SetMouseInputEnabled(true)

            local realTall = select(2, lbl:GetContentSize())

            local p = vgui.Create('DButton', lbl)
            p:Dock(TOP)
            p:SetTall(realTall)
            p:SetText('')
            p:SetPaintBackground(false)
            lbl.p = p
        
            function p:DoClick()
                if lbl:GetTall() == realTall then
                    lbl:SizeTo(-1, select(2, lbl:ChildrenSize()) + realTall, 0.5, 0, 0.5)
                    lbl:SetTextColor(white)
                    lbl.deployed = true
                else
                    lbl:SetTextColor(white50)
                    lbl:SizeTo(-1, realTall, 0.5, 0, 0.5)
                    lbl.deployed = false
                end
            end

            // Ghetto trick for below
            function lbl:DoClick()
                p:DoClick()
            end

            if v[2] then
                local childContainer = vgui.Create("EditablePanel", lbl)
                childContainer:Dock(TOP)
                childContainer:SetTall(0)
                holder[k] = childContainer

                initChilds(childContainer, k, lbl, p)
            else
                function p:DoClick()
                    settingSingle:SetMouseInputEnabled(true)
                    settingSingle:Clear()
                    v[1](settingSingle)
                    if IsValid(but) then
                        but:SetTextColor(white50)
                    end
                    lbl:SetTextColor(stateOn)
                    but = lbl
                end
            end

            lbl.realtall = realTall
        end

        // This is a weird pattern, should think about that before
        if k == 'Logs' then
            CAMI.PlayerHasAccess(LocalPlayer(), 'ashop_logs', function(b, str)
                if b then
                    cb()
                end
            end)
        else
            cb()
        end
    end

    hook.Add("ashop_refreshSettingsUI", "ACoolUI", function(name)
        if !IsValid(self) then return end

        local lbl = holder[name]:GetParent()
        local id

        if (IsValid(but) and but.settingName == name) then
            id = but.id
        end

        holder[name]:Clear()

        initChilds(holder[name], name, lbl, lbl.p, id, true)

        if lbl.deployed then
            lbl:SetTall(select(2, lbl:ChildrenSize()) + lbl.realtall)
        end
    end)
end

derma.DefineControl( "AShop_ConfigDisplay", "", PANEL, "DPanel" )