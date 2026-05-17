local c = ashop.GetColor('entryColor')
local r = ashop.Config.round

local stateOn2 = ashop.GetColor('StateOn')
local stateOn2R, stateOn2G, stateOn2B = stateOn2:Unpack()

local stateOn = ashop.GetColor('StateOff')
local stateOnR, stateOnG, stateOnB = stateOn:Unpack()

local stateOff = ashop.GetColor('Grad1_0')
local stateOffR, stateOffG, stateOffB = stateOff:Unpack()

local invalidClr = ashop.GetColor('badInput')
local invalidClrBg = ashop.GetColor('badInputBg')

local PANEL = {}

function PANEL:Init()
end

function PANEL:IsRequired(b)
    self.isRequired = b

    self.options = self.options or {}
    self.options.required = b
    return self
end

function PANEL:GetRequired()
    return self.isRequired
end

function PANEL:ValidInput()
    local good, msg = ashop.VerifyInput(self.currentValue, self.type,
        self.options)

    self.invalidAlert = msg

    if msg then
        self.errDisplayer:SetText(msg)
        self.errDisplayer:SetWide(self.errDisplayer:GetContentSize() + ashop.GetSize(20))
    else
        self.errDisplayer:SetWide(0)
    end

    return good
end

local function getDaysInMonth(month, year)
    local isLeapYear = !((year % 4) or ((year % 100 == 0) and (year % 400 != 0))) and 1 or 0
    return 31 - ((month == 2) and (3 - isLeapYear) or ((month - 1) % 7 % 2))
end

function PANEL:SetInput(name, type, currentInput, options)
    self:InvalidateLayout(true)
    self:InvalidateParent(true)

    options = options or {}
    local m = ashop.GetSize(16)
    self:DockPadding(m, m, m, m)
    self.type = type

    self.options = options

    local bonusPanelName = vgui.Create("DLabel", self)
    bonusPanelName:Dock(TOP)
    bonusPanelName:DockMargin(0, 0, 0, m/2)
    bonusPanelName:SetText(name .. (self.isRequired and "*" or ""))
    bonusPanelName:SetFont("ashop_14_600")
    bonusPanelName:SetMouseInputEnabled(true)
    bonusPanelName:SetKeyboardInputEnabled(true)
    bonusPanelName:SetTall(select(2, bonusPanelName:GetContentSize()) * 1.5)
    bonusPanelName:SetContentAlignment(4)
    bonusPanelName:SetTextColor(color_white)

    local inputContainer = vgui.Create('EditablePanel', self)
    inputContainer:Dock(TOP)
    inputContainer:SetTall(0)

    local buttonsContainer = vgui.Create("EditablePanel", bonusPanelName)
    buttonsContainer:Dock(TOP)
    buttonsContainer:SetTall(bonusPanelName:GetTall())
    local saveButton, nullButton

    if !options.locked and !options.hideSave then
        saveButton = vgui.Create('DButton', buttonsContainer)
        saveButton:Dock(RIGHT)
        saveButton:SetText(ashop.L('Save'))
        saveButton:SetFont('ashop_14')
        saveButton:SetPaintBackground(false)
        saveButton:SetWide(saveButton:GetContentSize() + ashop.GetSize(20))
        saveButton:SetTextColor(color_white)
        //ashop.ui.WhiteHover(saveButton, 40)
        
        saveButton.DoClick = function()
            if !self.OnSave then return end
            if IsValid(nullButton) and !nullButton.toggled then
                self:OnSave()
            else
                self:OnSave(self.currentValue)
            end
        end
        
        function saveButton:Paint(w, h)
            draw.RoundedBox(4, 0, 0, w, h, self:IsHovered() and stateOn2 or stateOn)
        end
    end

    if (!options or !options.required) and !self:GetRequired() then
        nullButton = vgui.Create('DButton', buttonsContainer)
        nullButton:Dock(RIGHT)
        nullButton:SetText('')
        nullButton:SetFont('ashop_14')
        nullButton:SetPaintBackground(false)
        nullButton:SetWide(buttonsContainer:GetTall())
        nullButton:SetTextColor(color_white)
        nullButton:DockMargin(0, 0, m/2, 0)
        nullButton.toggled = tobool(currentInput)
        nullButton.oldHeight = 0

        nullButton.DoClick = function(s)
            local curHeight = inputContainer:GetTall()
            inputContainer:SetTall(s.oldHeight)
            s.oldHeight = curHeight
            s.toggled = !s.toggled

            if !s.toggled then
                self:OnValueChanged()
            else
                if istable(self.currentValue) then
                    self:OnValueChanged(unpack(self.currentValue))
                else
                    self:OnValueChanged(self.currentValue)
                end
            end
            self:SetTall(self:GetTall() + (inputContainer:GetTall() - s.oldHeight))
        end

        function nullButton:Paint(w, h)
            draw.RoundedBox(4, 0, 0, w, h, self.toggled and stateOn2 or stateOn)
        end

        self.nullButton = nullButton
    end

    local errDisplayer = vgui.Create('DButton', buttonsContainer)
    errDisplayer:Dock(RIGHT)
    errDisplayer:DockMargin(0, 0, m/2, 0)
    errDisplayer:SetWide(0)
    errDisplayer:SetFont("ashop_14")
    errDisplayer:SetTextColor(color_white)
    self.errDisplayer = errDisplayer

    function errDisplayer:Paint(w, h)
        draw.RoundedBox(4, 0, 0, w, h, invalidClr)
    end

    // Hard one
    self.typeAct = type

    if type == 'DATE' then
        self.currentValue = currentInput

        inputContainer:SetTall(ashop.GetFontHeight('ashop_14') * 1.5)

        // Date
        local empty = vgui.Create("DButton", inputContainer)
        empty:SetText(ashop.L('Reset'))
        empty:SetFont('ashop_14')
        empty:SetWide(empty:GetContentSize() + ashop.GetSize(20))
        empty:SetTextColor(color_white)
        empty:Dock(RIGHT)
        empty:DockMargin(0, 0, 0, 0)

        function empty:Paint(w, h)
            draw.RoundedBox(4, 0, 0, w, h, self:IsHovered() and stateOn2 or stateOn)
        end

        local year = vgui.Create('AShop_DComboBox', inputContainer)
        year:Dock(RIGHT)
        year:SetSortItems(false)
        year:DockMargin(0, 0, m/2, 0)
        for i=0, 2 do year:AddChoice(2023 + i) end
        year:ChooseOptionID(1)

        local month = vgui.Create('AShop_DComboBox', inputContainer)
        month:Dock(RIGHT)
        month:SetSortItems(false)
        month:DockMargin(0, 0, m/2, 0)
        for i=1, 12 do month:AddChoice(i) end
        month:ChooseOptionID(1)

        local day = vgui.Create('AShop_DComboBox', inputContainer)
        day:Dock(RIGHT)
        day:SetSortItems(false)
        day:DockMargin(0, 0, m/2, 0)
        for i=1, getDaysInMonth(1, 2023) do day:AddChoice(i) end
        day:ChooseOptionID(1)

        // Hour
        local hour = vgui.Create('AShop_DComboBox', inputContainer)
        hour:Dock(RIGHT)
        hour:DockMargin(0, 0, m*2, 0)
        hour:SetSortItems(false)
        for i=0, 23 do hour:AddChoice(i) end

        local function refreshCurrentValue()
            self.currentValue = os.time({
                day = tonumber(day:GetValue()) or 1,
                hour = tonumber(hour:GetValue()) or 0,
                month = tonumber(month:GetValue()) or 1,
                year = tonumber(year:GetValue()) or 2023,
            })
        end

        function month:OnSelect()
            local days = getDaysInMonth(tonumber(month:GetValue()), tonumber(year:GetValue()))
            local daySelected = tonumber(day:GetValue())

            // Refresh it, anyway, since numbers would change
            if daySelected and daySelected > days then
                daySelected = days
            end

            day:Clear()

            for i = 1, days do
                day:AddChoice(i)
            end

            if daySelected then
                day:ChooseOptionID(daySelected)
            end

            refreshCurrentValue()
        end
        year.OnSelect = month.OnSelect

        function hour:OnSelect() refreshCurrentValue() end
        function day:OnSelect() refreshCurrentValue() end

        function empty:DoClick()
            day:SetValue('1')
            month:SetValue('1')
            year:SetValue('2023')
            hour:SetValue('1')
            self.currentValue = nil
        end

        if self.currentValue then
            local t = os.date("*t", self.currentValue)
            year:ChooseOptionID(t.year - 2023 + 1)
            month:ChooseOptionID(t.month)
            day:ChooseOptionID(t.day)

            hour:ChooseOptionID(t.hour + 1)
        end
    elseif type == 'LIST' then
        self.currentValue = currentInput or {}

        assert(options.listObjects, 'No listObjects for a LIST entry type')
        local l = vgui.Create("DListView", inputContainer)
        l:SetTall(draw.GetFontHeight('ashop_16_600') * 10)
        l:DockMargin(0, m/2, 0, 0)
        l:Dock(FILL)

        inputContainer:SetTall(inputContainer:GetTall() + l:GetTall())

        function l:Paint(w, h)
            surface.SetDrawColor(stateOffR, stateOffG, stateOffB)
            surface.DrawRect(0, 0, w, h)

            surface.SetDrawColor(stateOnR, stateOnG, stateOnB)
            surface.DrawOutlinedRect(0, 0, w, h)
        end

        local vbar = l.VBar
        ashop.ui.SkinScrollPanel(l)
        l.VBar.Enabled = false

        // This is so dumb
        function l:PerformLayout()
            local Wide = self:GetWide()
            local YPos = 0
        
            if ( IsValid( self.VBar ) ) then
                self.VBar:SetPos( self:GetWide() - 16, self:GetHeaderHeight() )
                self.VBar:SetSize( 4, self:GetTall() - self:GetHeaderHeight() )
                self.VBar:SetUp( self.VBar:GetTall() - self:GetHeaderHeight()*2, self.pnlCanvas:GetTall() - self:GetHeaderHeight() )
                YPos = self.VBar:GetOffset()
            end
        
            if ( self.m_bHideHeaders ) then
                self.pnlCanvas:SetPos( 0, YPos )
            else
                self.pnlCanvas:SetPos( 0, YPos + self:GetHeaderHeight() )
            end

            self.pnlCanvas:SetSize( Wide, self.pnlCanvas:GetTall() )

            self:FixColumnsLayout()

            if ( self:GetDirty() ) then
                self:SetDirty( false )
                local y = self:DataLayout()
                self.pnlCanvas:SetTall( y )
                self:InvalidateLayout( true )
            end
        end

        local clrw = ColorAlpha(color_white, 40)
        function vbar:Paint(w, h)
            draw.RoundedBox(2, w - 2, 8, 2, h-16, clrw)
        end

        local addButton = vgui.Create('DButton', buttonsContainer)
        addButton:Dock(RIGHT)
        addButton:SetText(ashop.L('AddNewValue'))
        addButton:SetFont('ashop_14')
        addButton:SetPaintBackground(false)
        addButton:SetWide(addButton:GetContentSize() + ashop.GetSize(20))
        addButton:DockMargin(m/2, 0, 0, 0)
        addButton:SetTextColor(color_white)
        //ashop.ui.WhiteHover(saveButton, 40)

        for k, v in pairs(options.listObjects) do
            local c = l:AddColumn(v[2])
            c.Header:SetPaintBackground(false)
            c.Header:SetTextColor(color_white)
            c.Header:SetFont('ashop_14')

            function c:Paint(w, h)
                surface.SetDrawColor(stateOnR, stateOnG, stateOnB)
                surface.DrawRect(0, 0, w, h)
            end
        end

        local s = self
        function l:OnRowRightClick(id, pnl)
            local menu = vgui.Create( "AShop_DMenu", pnl )

            menu:AddOption( ashop.L('RemoveThisValue'), function()
                //table.RemoveByValue(s.currentValue, realData)
                l:RemoveLine(id)
                table.remove(s.currentValue, id)
            end)

            menu:Open()
        end

        local function addToDListView(data)
            local postTreatment = {}

            for k, v in pairs(options.listObjects) do
                if !data[k] then
                    table.insert(postTreatment, "")
                else
                    if v[1] == "ITEMID" then
                        table.insert(postTreatment, ashop.items[data[k]].name)
                    else
                        table.insert(postTreatment, data[k])
                    end
                end
            end

            local p = l:AddLine(unpack(postTreatment))
            
            for k, v in ipairs(p.Columns) do
                v:SetTextColor(color_white)
            end
            p.realData = data
        end
        
        addButton.DoClick = function()
            local a = vgui.Create('AShop_Form', ashop.menu)
            a:SetTitle(ashop.L('AddNewValue'))
            a:Center()
            for k, v in ipairs(options.listObjects) do
                a:CreateEntry(v[3] == nil and true or v[3], v[2], v[1], v[4])
            end

            a.OnSend = function(_, ...)
                table.insert(self.currentValue, {...})
                addToDListView({...})
            end
        end
        
        function addButton:Paint(w, h)
            draw.RoundedBox(4, 0, 0, w, h, self:IsHovered() and stateOn2 or stateOn)
        end

        for k, v in pairs(self.currentValue) do
            addToDListView(v)
        end
    elseif type == TYPE_VECTOR or type == TYPE_ANGLE then
        if type == TYPE_VECTOR then
            assert(options.maxVar, "Missing maxVar for Vector input: " .. name)
        end

        local copyCurrentValue = (type == TYPE_ANGLE) and Angle(currentInput) or Vector(currentInput)
        self.currentValue = copyCurrentValue

        for i = 1, 3 do
            local container = vgui.Create("EditablePanel", inputContainer)
            container:Dock(TOP)
            container:DockMargin(0, 0, 0, i == 3 and 0 or m/4)

            local currentNumber = vgui.Create("DLabel", container)
            currentNumber:Dock(RIGHT)
            currentNumber:SetText("-00.000")
            currentNumber:SetFont('ashop_14')
            currentNumber:SetContentAlignment(6)
            currentNumber:SetWide(currentNumber:GetContentSize())
            currentNumber:DockMargin(m, 0, 0, 0)
            currentNumber:SetTextColor(color_white)

            local text = vgui.Create("DLabel", container)
            text:Dock(LEFT)
            text:SetFont('ashop_14')
            text:DockMargin(0, 0, m, 0)
            text:SetTextColor(color_white)

            if i == 1 then
                text:SetText('Axe X')
            elseif i == 2 then
                text:SetText('Axe Y')
            elseif i == 3 then
                text:SetText('Axe Z')
            end

            text:SetWide(text:GetContentSize())

            local slider = vgui.Create("AShop_DSlider", container)
            slider:Dock(FILL)

            local diff = options.maxVar - (options.minVar or -options.maxVar)

            currentNumber:SetText(math.Round(self.currentValue[i], 3))
            slider:SetSlideX((self.currentValue[i] - (options.minVar or -options.maxVar)) / diff)

            container:SetTall(select(2, text:GetContentSize()))
            inputContainer:SetTall(inputContainer:GetTall() + container:GetTall() + m/4)

            slider.OnValueChanged = function(_, x, y)
                local amt = (diff * x) + (options.minVar or -options.maxVar)
                self.currentValue = self.currentValue or self.currentValue
                self.currentValue[i] = amt

                currentNumber:SetText(math.Round(amt, (type == TYPE_VECTOR and 3 or 0)))
                self.wasEdited = true
                self:OnValueChanged(self.currentValue)
            end
        end
    elseif type == TYPE_COLOR then
        local copyCurrentValue = ColorAlpha((currentInput and Color(currentInput:Unpack()) or color_white), 255)

        self.currentValue = copyCurrentValue
        self:InvalidateParent(true)
        self:InvalidateLayout(true)
        inputContainer:InvalidateLayout(true)
        inputContainer:InvalidateParent(true)
        inputContainer:SetTall(inputContainer:GetTall() + ashop.GetFontHeight('ashop_14')*1.5)

        local sliderSize = self:GetWide()/6
        local holder = vgui.Create("EditablePanel", inputContainer)
        holder:Dock(RIGHT)
        holder:SetWide(sliderSize*3 + m*4)

        for k, v in ipairs({"r", "g", "b"}) do
            local container = vgui.Create("EditablePanel", holder)
            container:Dock(LEFT)
            container:SetWide(sliderSize)
            container:DockMargin(0, 0, m*2, 0)

            local text = vgui.Create("DLabel", container)
            text:Dock(LEFT)
            text:SetFont('ashop_14')
            text:DockMargin(0, 0, m/2, 0)
            text:SetText(string.upper(v))
            text:SetWide(text:GetContentSize())
            text:SetTextColor(color_white)

            local slider = vgui.Create("AShop_DSlider", container)
            slider:Dock(FILL)
            slider:SetSlideX(self.currentValue[v] / 255)

            slider.OnValueChanged = function(_, x, y)
                self.currentValue = self.currentValue
                self.currentValue[v] = 255 * x
                self.wasEdited = true
                self:OnValueChanged(self.currentValue)
            end

            slider.Paint = function(_, w, h)
                draw.RoundedBox(2, 0, h/2-2, w, 4, self.currentValue)
            end
        end
    elseif type == TYPE_STRING or string.find(type, 'UInt') or type == "FLOAT" then
        self.currentValue = TYPE_STRING != type and tonumber(currentInput) or currentInput

        inputContainer:SetTall(ashop.GetFontHeight('ashop_14') * 1.5)

        local t = vgui.Create('AShop_DTextEntry', inputContainer)
        t:Dock(((options.lineMultiplySize and options.lineMultiplySize > 1) or self.SmallVersion) and TOP or RIGHT)
        t:SetFont('ashop_14')
        t:SetTextColor(ashop.GetColor('White'))
        t:SetText(self.currentValue or "")
        t.boxcolor = stateOff
        t.outlineColor = stateOn
        t:SetNumeric(type != TYPE_STRING)
        t:SetMultiline(options.lineMultiplySize and options.lineMultiplySize > 1)
        t:SetContentAlignment(6)

        if options.locked then
            t:SetDisabled(true)
            t.boxcolor = ashop.GetColor('Grad1_1')
            t:SetEditable(false)
        end

        t.OnChange = function()
            local text = t:GetText() or ""

            if options.maxLength and string.len(text) > options.maxLength then
                t:SetText(self.currentValue or "")
                return
            end

            self.wasEdited = true
            self.currentValue = TYPE_STRING != type and (tonumber(text) or 0) or text
            self:OnValueChanged(self.currentValue)

            if !self:ValidInput() then
                t.normalOutline = invalidClr
                t.normalColor = invalidClrBg
                t.focusOutline = invalidClr
                t.focusColor = invalidClrBg
            else
                t.normalOutline = nil
                t.normalColor = nil
                t.focusOutline = nil
                t.focusColor = nil
            end
        end

        if options.lineMultiplySize then
            t:Dock(TOP)
            t:SetTall((options.lineMultiplySize + 1) * ashop.GetFontHeight('ashop_14'))
            inputContainer:SetTall(t:GetTall())
        else
            t:SetWide(ashop.GetSize(300))
        end
    elseif type == TYPE_BOOL then
        self.currentValue = currentInput or false

        local t

        if IsValid(nullButton) then
            t = nullButton
        else
            t = vgui.Create("DButton", buttonsContainer)
        end

        t.toggled = true

        t:Dock(RIGHT)
        t:SetWide(bonusPanelName:GetTall())
        t:SetText('')

        local stateOn = ashop.GetColor('StateOn')
        local stateOff = ashop.GetColor('StateOff')

        t.DoClick = function()
            self.currentValue = !self.currentValue
            self.wasEdited = true
            self:OnValueChanged(self.currentValue)
        end

        if options.locked then
            t:SetDisabled(true)
            stateOn = ashop.GetColor('premiumMoneyLogo')
            stateOff = ashop.GetColor('pink')
        end

        t.Paint = function (_, w, h)
            draw.RoundedBox(r/2, 0, 0, w, h, self.currentValue and stateOn or stateOff)
        end
    elseif type == "SELECT" or type == "ITEMID" then
        if type == "ITEMID" then
            options.selects = {}
            for k, v in pairs(ashop.items) do
                table.insert(options.selects, {v.name, k})
            end
        end

        assert(options and options.selects, "Missing select for Select Type entry: " .. name)
        self.currentValue = options.default or currentInput or (options.selects[1] and options.selects[1][2] or nil)
        inputContainer:SetTall(ashop.GetFontHeight('ashop_14') * 1.5)
        local t = vgui.Create("DComboBox", inputContainer)
        t:Dock(RIGHT)
        t:SetFont('ashop_14')
        t:SetTextColor(ashop.GetColor('White'))

        for k, v in pairs(options.selects) do
            if isnumber(k) and isnumber(currentInput) then
                t:AddChoice(v[1], v[2], options.default and v[2] == options.default or (!options.default and (k == 1 or k == currentInput)))
            else
                t:AddChoice(v[1], v[2], options.default and v[2] == options.default or (!options.default and (k == 1 or v[1] == currentInput)))
            end
        end

        t.OnSelect = function(_, index, value, data)
            self.currentValue = data
            self.wasEdited = true
            self:OnValueChanged(data, value)
        end

        if options.locked then
            t:SetDisabled(true)
            stateOn = ashop.GetColor('premiumMoneyLogo')
            stateOff = ashop.GetColor('pink')
        end

        t:SetWide(ashop.GetSize(200))

        t.Paint = function (_, w, h)
            draw.RoundedBox(r/2, 0, 0, w, h, self.currentValue and stateOn or stateOff)
        end
    end

    if self.SmallVersion then
        buttonsContainer:SetParent()
        buttonsContainer:SetParent(self)
    end

    self:InvalidateLayout(true)
    self:SizeToChildren(false, true)

    if IsValid(nullButton) and !nullButton.toggled then
        nullButton.oldHeight = inputContainer:GetTall()
        inputContainer:SetTall(0)
        self:SetTall(self:GetTall() + (inputContainer:GetTall() - nullButton.oldHeight))
    end

    return bonusPanel
end

function PANEL:Paint(w, h)
    if self:IsHovered() or self:IsChildHovered() then
        surface.SetDrawColor(stateOn2R, stateOn2G, stateOn2B)
        surface.DrawRect(0, 0, w, h)

        surface.SetDrawColor(self.boxcolor or c)
        surface.DrawRect(1, 1, w-2, h-2)
    end
end

function PANEL:GetValue()
    return self.currentValue
end

function PANEL:OnValueChanged()
end

local sepR, sepG, sepB = ashop.GetColor('Separator', 125):Unpack()
function PANEL:AddSeparator()
    local p = vgui.Create('EditablePanel', self:GetParent())
    p:Dock(TOP)
    p:SetTall(1)

    local m = ashop.GetSize(16)

    function p:Paint(w, h)
        surface.SetDrawColor(sepR, sepG, sepB)
        surface.DrawLine(m/2, 0, w - m/2, 0)
    end
end

derma.DefineControl( "AShop_Entry", "", PANEL, "EditablePanel" )