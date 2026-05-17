local defaultAvatarMat = Material("vgui/avatar_default")

local function drawInterior(editor, key, value, parent)
    local marginVertical = ashop.GetSize(20)
    local tH = draw.GetFontHeight('ashop_16')
    local stateOn = ashop.GetColor('stateOn')
    local clrSeparator = ashop.GetColor('Separator')
    local sep = ashop.GetColor('Separator', 125)
    local round = ashop.Config.round
    local m = ashop.GetSize(16)
    local logHeaderBg = ashop.GetColor('StateOff')
    local logContainerBgR, logContainerBgG, logContainerBgB = ashop.GetColor('Grad2_0'):Unpack()
    local logRowBgR, logRowBgG, logRowBgB = ashop.GetColor('Grad1_1'):Unpack()
    local currentPage, pageCount = 0
    local white = ashop.GetColor('White')

    local txtEntryContainer = vgui.Create('DPanel', editor)
    txtEntryContainer:Dock(TOP)
    txtEntryContainer:SetTall(tH * 2)
    txtEntryContainer:DockPadding(0, tH*0.25, m, tH*0.25)

    function txtEntryContainer:Paint(w, h)  end

    local search = vgui.Create('DButton', txtEntryContainer)
    search:Dock(RIGHT)
    search:SetText(ashop.L('Search'))
    search:SetFont('ashop_16')
    search:SetWide(search:GetContentSize() + marginVertical)
    search:SetTextColor(white)
    search:DockMargin(tH*0.25, 0, 0, 0)

    function search:Paint(w, h)
        draw.RoundedBox(round/2, 0, h/4, w, h/4*2, self:IsHovered() and stateOn or clrSeparator)
    end

    local p = vgui.Create('EditablePanel', editor)
    p:Dock(TOP)
    p:SetTall(1)

    local sepR, sepG, sepB = sep:Unpack()
    function p:Paint(w, h)
        surface.SetDrawColor(sepR, sepG, sepB)
        surface.DrawLine(m/2, 0, w - m/2, 0)
    end

    local idContainer = vgui.Create('AShop_Entry', txtEntryContainer)
    idContainer:Dock(TOP)
    idContainer:SetTall(0)

    idContainer:SetInput('SteamID64', TYPE_STRING, '00000000000000000', {
        hideSave = true
    })

    local typeSearch = vgui.Create('AShop_Entry', editor)
    typeSearch:Dock(TOP)
    typeSearch:SetTall(0)

    function idContainer:Paint() end

    local a = {
        {"Nothing", 0}
    }

    for k, v in pairs(ashop.Logs.IDs) do
        table.insert(a, {ashop.L('Log_' .. v), v})
    end

    typeSearch:SetInput('Type', 'SELECT', nil, {
        selects = a,
        hideSave = true,
        default = 0
    })

    txtEntryContainer:SizeToChildren(false, true)
    function typeSearch:Paint() end

    function search:DoClick()
        currentPage = 0

        net.Start('ashop_logs')
            net.WriteUInt(currentPage, 16)

            net.WriteBool(idContainer.currentValue)
            if idContainer.currentValue then
                net.WriteString(idContainer.currentValue)
            end

            local val = typeSearch.currentValue != 0 and typeSearch.currentValue or nil
            net.WriteBool(val)
            if val then
                net.WriteUInt(val, 7)
            end
        net.SendToServer()
    end

    local logContainer = vgui.Create('EditablePanel', editor)
    logContainer:Dock(FILL)
    logContainer:DockMargin(m/2 + tH*0.25, 0, m/2, 0)

    // Header
    local logHeader = vgui.Create('EditablePanel', logContainer)
    logHeader:Dock(TOP)
    logHeader:SetTall(tH * 2)
    logHeader:DockPadding(m, 0, m, 0)

    function logHeader:Paint(w, h)
        draw.RoundedBoxEx(ashop.Config.round, 0, 0, w, h, logHeaderBg, true, true, false, false)
    end

    surface.SetFont('ashop_16')

    local logHeaderDate = vgui.Create('DLabel', logHeader)
    logHeaderDate:SetText(ashop.L('Date'))
    logHeaderDate:Dock(RIGHT)
    logHeaderDate:SetFont('ashop_16')
    logHeaderDate:SetWide(surface.GetTextSize("99:99:99 - 99/99/9999"))
    logHeaderDate:SetTextColor(color_white)

    local logHeaderDataLog = vgui.Create('DLabel', logHeader)
    logHeaderDataLog:SetText(ashop.L('Logs'))
    logHeaderDataLog:Dock(FILL)
    logHeaderDataLog:SetFont('ashop_16')
    logHeaderDataLog:SetTextColor(color_white)

    local logPages = vgui.Create('EditablePanel', logContainer)
    logPages:Dock(BOTTOM)
    logPages:SetTall(logHeader:GetTall())

    function logPages:Paint(w, h)
        draw.RoundedBoxEx(ashop.Config.round, 0, 0, w, h, logHeaderBg, false, false, true, true)
    end

    function logPages:Refresh(n)
        logPages:Clear()
        local nbOfPages = math.floor(n / ashop.Logs.CountPerPage)

        local p = vgui.Create('EditablePanel', logPages)
        p:SetWide(0)

        local function subSearch()
            net.Start('ashop_logs')
                net.WriteUInt(currentPage, 16)

                net.WriteBool(idContainer.currentValue)
                if idContainer.currentValue then
                    net.WriteString(idContainer.currentValue)
                end

                local val = typeSearch.currentValue != 0 and typeSearch.currentValue or nil
                net.WriteBool(val)
                if val then
                    net.WriteUInt(val, 7)
                end
            net.SendToServer()
        end

        if (currentPage - 2) > 0 then
            local but = vgui.Create('DButton', p)
            but:Dock(LEFT)
            but:SetText("0")
            but:SetFont('ashop_16')
            but:SetWide(logPages:GetTall())
            but:SetTextColor(color_white)
            but:SetPaintBackground(false)
            p:SetWide(but:GetWide() + p:GetWide())

            function but:DoClick()
                currentPage = 0
                subSearch()
            end

            if (currentPage - 3) > 0 then
                local sep = vgui.Create('DButton', p)
                sep:SetTextColor(color_white)
                sep:Dock(LEFT)
                sep:SetText("...")
                sep:SetFont("ashop_16")
                sep:SetWide(sep:GetContentSize())
                sep:SetPaintBackground(false)
                p:SetWide(sep:GetWide() + p:GetWide())

                function sep:DoClick()
                    currentPage = math.floor(currentPage / 2)
                    subSearch()
                end
            end
        end

        for i=-2 + currentPage, 2 + currentPage do
            if i < 0 or i > nbOfPages then continue end

            local but = vgui.Create('DButton', p)
            but:Dock(LEFT)
            but:SetText(i)
            but:SetFont('ashop_16')
            but:SetWide(logPages:GetTall())
            but:SetTextColor(color_white)
            but:SetPaintBackground(false)
            p:SetWide(but:GetWide() + p:GetWide())

            function but:DoClick()
                currentPage = i
                subSearch()
            end
        end

        if 2 + currentPage < nbOfPages then
            if 3 + currentPage < nbOfPages then
                local sep = vgui.Create('DButton', p)
                sep:SetTextColor(color_white)
                sep:Dock(LEFT)
                sep:SetText("...")
                sep:SetFont("ashop_16")
                sep:SetWide(sep:GetContentSize())
                sep:SetPaintBackground(false)
                p:SetWide(sep:GetWide() + p:GetWide())

                function sep:DoClick()
                    currentPage = math.floor((nbOfPages - currentPage) / 2) + currentPage
                    subSearch()
                end
            end

            local but = vgui.Create('DButton', p)
            but:Dock(LEFT)
            but:SetText(nbOfPages)
            but:SetFont('ashop_16')
            but:SetWide(logPages:GetTall())
            but:SetTextColor(color_white)
            but:SetPaintBackground(false)
            p:SetWide(but:GetWide() + p:GetWide())

            function but:DoClick()
                currentPage = nbOfPages
                subSearch()
            end
        end

        p:Center()
    end

    local logChild = vgui.Create('EditablePanel', logContainer)
    logChild:Dock(FILL)

    function logChild:Paint(w, h)
        surface.SetDrawColor(logContainerBgR, logContainerBgG, logContainerBgB)
        surface.DrawRect(0, 0, w, h)
    end

    net.Receive('ashop_logs', function()
        logChild:Clear()

        if net.ReadBool() then
            // Page is 0
            currentPage = 0
            pageCount = net.ReadUInt(32)
        end
        logPages:Refresh(pageCount)

        local pageLoop = net.ReadUInt(5)

        for i = 1, pageLoop do
            local t2 = {
                date = net.ReadUInt(32),
                log_id = net.ReadUInt(7),
                textdata = {}
            }
    
            for j = 1, net.ReadUInt(4) do
                if net.ReadBool() then
                    t2.textdata[j] = {
                        steamid = net.ReadString(),
                        rank = net.ReadString(),
                        oldname = net.ReadString()
                    }
                elseif net.ReadBool() then
                    t2.textdata[j] = net.ReadInt(32)
                else
                    t2.textdata[j] = net.ReadString()
                end
            end
    
            local p = vgui.Create('DPanel', logChild)
            p:Dock(TOP)
            p:SetTall(logHeader:GetTall())
            p:DockPadding(logHeader:GetDockPadding())

            function p:Paint(w, h)
                if i % 2 == 1 then
                    surface.SetDrawColor(logRowBgR, logRowBgG, logRowBgB)
                    surface.DrawRect(0, 0, w, h)
                end
            end

            local lineSize = 500 - m * 2 - 4
            local spaceLeft = 0

            local date = vgui.Create('DLabel', p)
            date:Dock(RIGHT)
            date:SetWide(logHeaderDate:GetWide())
            date:SetFont('ashop_16')
            date:SetTextColor(color_white)
            date:SetText(os.date("%H:%M:%S - %d/%m/%Y", t2.date))

            local firstAdd = true
            function p:addElement(elem)
                local line = self.line
                
                if elem:GetWide() > spaceLeft then
                    line = vgui.Create("DPanel", self)
                    line:Dock(TOP)
                    line:SetTall(tH)
                    line:DockMargin(tH/2, firstAdd and tH/2 or 0, tH/2, 0)
                    line:SetPaintBackground(false)

                    self.line = line
                    spaceLeft = lineSize
                    firstAdd = false
                end

                line.spaceleft = lineSize - elem:GetWide()
                elem:SetParent(self.line)
                elem:Dock(LEFT)

                elem:SetWide(elem:GetContentSize())
            end

            local formattedText = string.Explode( "{%d}", ashop.L('Log_' .. t2.log_id), true )
            surface.SetFont("ashop_16")

            for k, params in pairs(formattedText) do
                formattedText[k] = formattedText[k]

                local text = formattedText[k]

                local willRemain = spaceLeft
                local stack = ""

                text:gsub("(%s?[%S]+)", function(word)
                    local txtSize = surface.GetTextSize(word)

                    if willRemain - txtSize > 0 then
                        stack = stack .. word
                        return
                    end

                    for _, z in pairs({stack, word}) do
                        local lbl = vgui.Create("DLabel")
                        lbl:SetFont("ashop_16")
                        lbl:SetText(z)
                        lbl:SetTextColor(ColorAlpha(color_white, 100))

                        p:addElement(lbl)
                    end

                    stack = ""
                    willRemain = spaceLeft
                end)

                if t2.textdata[k] and !istable(t2.textdata[k]) then
                    stack = stack .. " " .. t2.textdata[k]
                end

                if stack != "" then
                    local lbl = vgui.Create("DLabel")
                    lbl:SetFont("ashop_16")
                    lbl:SetText(stack)
                    lbl:SetTextColor(ColorAlpha(color_white, 100))

                    p:addElement(lbl)
                end

                if t2.textdata[k] and istable(t2.textdata[k]) then
                    local lbl = vgui.Create("DButton")
                    lbl:SetFont("ashop_16")
                    lbl:SetText(stack == "" and t2.textdata[k].oldname or ( " " .. t2.textdata[k].oldname))
                    lbl:SetTextColor(color_white)
                    lbl:SetPaintBackground(false)
                    lbl.avatar = t2.textdata[k].steamid

                    function lbl:DoClick()
                        SetClipboardText(lbl.avatar)
                        ashop.DermaNotify(ashop.L('SteamIDInClipboard'), NOTIFY_HINT, 3)
                    end

                    surface.SetFont("ashop_16")
                    local wtxt, htxt = surface.GetTextSize(lbl.avatar)
                    local wtxt2 = surface.GetTextSize(lbl:GetText())

                    local tooltip = vgui.Create("DPanel")
                    tooltip:SetSize(math.max(wtxt, wtxt2) + htxt*2 + 8 + 2, htxt * 2 + 4)
                    tooltip:DockPadding(2, 2, 2, 2)

                    function tooltip:Paint(w, h) end

                    local avatarMat = defaultAvatarMat

                    ashop.getAvatarMaterial(lbl.avatar, function(mat)
                        avatarMat = mat
                    end)

                    local avatar = vgui.Create("EditablePanel", tooltip)
                    avatar:Dock(LEFT)
                    avatar:SetWide(htxt*2)
                    avatar:DockMargin(0, 0, 4, 0)

                    local r1

                    function avatar:Paint(w, h)
                        if !r1 then
                            r1 = ashop.ui.RoundedBox(4, 0, 0, w, h)
                        end

                        ashop.StartStencil()
                            surface.SetDrawColor(1, 1, 1, 1)
                            draw.NoTexture()
                            surface.DrawPoly(r1)
                        ashop.ReplaceStencil(1)
                            surface.SetDrawColor(255, 255, 255)
                            surface.SetMaterial(avatarMat)
                            surface.DrawTexturedRect(0, 0, w, h)
                        ashop.EndStencil()
                    end

                    local title = vgui.Create("DLabel", tooltip)
                    title:Dock(TOP)
                    title:SetText(t2.textdata[k].oldname)
                    title:SetFont("ashop_16")
                    title:SetTextColor(color_white)
                    title:SetTall(htxt)

                    local desc = vgui.Create("DLabel", tooltip)
                    desc:Dock(TOP)
                    desc:SetText(t2.textdata[k].steamid)
                    desc:SetFont("ashop_16")
                    desc:SetTextColor(ColorAlpha(color_white, 220))
                    desc:SetTall(htxt)

                    lbl:SetTooltipPanel(tooltip)
                    lbl:SetTooltipPanelOverride("ashop_TooltipAvatar")

                    function lbl:OnRemove()
                        tooltip:Remove()
                    end

                    p:addElement(lbl)
                end
            end
        end
    end)
end

ashop.registerUserParameter(ashop.L('Logs'), drawInterior)

ashop.PermissionCreate("ashop_logs", "admin", "Who can see the logs")