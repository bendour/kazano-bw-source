local circles = include("talk_modes/vgui/libs/cl_circles.lua")
local THEME = TalkModes.Client.ActiveTheme
local SETTING_TYPES = {
    ["Language"] = "String",
    ["Selection Key"] = "UInt",
	["3D Voice"] = "Bool",
	["Talking Dead"] = "Bool",
    ["Selection Menu Position"] = "String",
    ["Auto-Hide"] = "Bool",
    ["Whisper"] = "UInt",
    ["Talk"] = "UInt",
    ["Yell"] = "UInt",
    ["White"] = "Color",
    ["Gray"] = "Color",
    ["Background"] = "Color",
    ["Foreground"] = "Color",
    ["Hover"] = "Color",
    ["Mode Change Message"] = "Bool"
}

local PANEL = {}
AccessorFunc(PANEL, "page_name", "PageName")
function PANEL:Init()
    self.tblSettings = {}
    self.docker = self:GetParent()
    self.base = self.docker:GetParent()

    self.scroll = self:Add("DScrollPanel")
    self.scroll:Dock(FILL)
    self.scroll:DockMargin(6, 6, 6, 0)
    self.scroll.Paint = function(this, intW, intH)
        draw.RoundedBox(2, 0, 0, intW, intH, THEME["Background"])
    end

    self.scroll.bar = self.scroll:GetVBar()
    self.scroll.bar:SetWidth(4)
    self.scroll.bar.Paint = function(this, intW, intH)
        draw.RoundedBox(2, 0, 0, intW, intH, THEME["Background"])
    end
    self.scroll.bar.btnGrip:SetCursor("Hand")
    self.scroll.bar.btnGrip.Paint = function(this, intW, intH)
        draw.RoundedBox(2, 0, 0, intW, intH, THEME["Hover"])
    end
    self.scroll.bar.btnUp.Paint = nil
    self.scroll.bar.btnDown.Paint = nil

    self.footer = self:Add("DPanel")
    self.footer:Dock(BOTTOM)
    self.footer:SetHeight(36)
    self.footer.Paint = function(self, intW, intH)
        draw.RoundedBoxEx(6, 0, 0, intW, intH, THEME["Background"], false, false, false, true)
    end

    self.save = self.footer:Add("DButton")
    self.save:SetSize(150, 28)
    self.save:SetText("")
    self.save.Alpha = 90
    self.save.Paint = function(self, intW, intH)
        self.Alpha = Lerp(FrameTime() * 8, self.Alpha, self:IsHovered() && 255 || 90)
        draw.RoundedBox(6, 0, 0, intW, intH, Color(39, 174, 96, self.Alpha))
        draw.SimpleText(string.upper(TalkModes.Languages:GetPhrase("Save")), "TalkModes:Small", intW/2, intH/2, THEME["White"], TEXT_ALIGN_CENTER, TEXT_ALIGN_CENTER)
    end
    self.save.DoClick = function()
        self.tblUpdatedSettings = {}
        self.tblUpdatedSettings[self:GetPageName()] = {}
        for k, v in SortedPairs(self.tblSettings) do 
            local child = v:GetChildren()[1]
            self.tblUpdatedSettings[self:GetPageName()][v.strSetting] = child:GetValue()
        end
        
        for i, v in SortedPairs(self.tblUpdatedSettings[self:GetPageName()]) do 
            net.Start("TalkModes.Config.UpdateSetting")
                net.WriteString(self:GetPageName()..":"..i)
                net["Write"..SETTING_TYPES[i]](v, 32)
            net.SendToServer()
        end
    end

    self.reset = self.footer:Add("DButton")
    self.reset:SetSize(150, 28)
    self.reset:SetText("")
    self.reset.Alpha = 90
    self.reset.Paint = function(self, intW, intH)
        self.Alpha = Lerp(FrameTime() * 8, self.Alpha, self:IsHovered() && 255 || 90)
        draw.RoundedBox(6, 0, 0, intW, intH, Color(243, 156, 18, self.Alpha))
        draw.SimpleText(string.upper(TalkModes.Languages:GetPhrase("Reset")), "TalkModes:Small", intW/2, intH/2, THEME["White"], TEXT_ALIGN_CENTER, TEXT_ALIGN_CENTER)
    end
    self.reset.DoClick = function()
        net.Start("TalkModes.Config.ResetSettings")
        net.SendToServer()
        self.base:Close()
    end
    
    self.footer.PerformLayout = function(this, intW, intH)
        self.reset:SetPos(intW/2 - self.reset:GetWide() - 2, 4)
        self.save:SetPos(intW/2 + 2, 4)
    end
end

function PANEL:Paint(intW, intH)
    draw.RoundedBoxEx(6, 0, 0, intW, intH, THEME["Foreground"], false, false, false, true)
end

function PANEL:RefreshSettings()
    if (self.tblSettings) then
        for _,v in SortedPairs(self.tblSettings) do
            v:Remove()
        end
    end
    self.tblSettings = {}

    self.tblServerSettings = {}
    for k, v in SortedPairs(TalkModes.Config:GetTable(self:GetPageName())) do
        self.tblServerSettings[k] = v
    end

    for a, b in SortedPairs(self.tblDefaultSettings) do
        for c, d in SortedPairs(self.tblServerSettings) do
            if (a == c) then
                self.tblDefaultSettings[a].uValue = d
            end
        end
    end
    for k, v in SortedPairs(self.tblDefaultSettings) do
        self:AddSetting(v.strType, k, v.strDesc, v.uValue, v.tblData)
    end
end

function PANEL:AddSetting(strType, strTitle, strDesc, uValue, tblData)
    self.settingsPanel = self.scroll:Add("EditablePanel")
    self.settingsPanel:Dock(TOP)
    self.settingsPanel:DockMargin(6, 6, 6, 0)
    self.settingsPanel:SetKeyboardInputEnabled(true)
    self.settingsPanel.strSetting = strTitle
    this = self.settingsPanel
    this.Paint = function(this, intW, intH)
        draw.RoundedBox(6, 0, 0, intW, intH, THEME["Foreground"])
        draw.SimpleText(TalkModes.Languages:GetPhrase(strTitle), "TalkModes:Medium", 6, 6, THEME["White"])
        local _, intH = surface.GetTextSize(TalkModes.Languages:GetPhrase(strTitle))
        draw.SimpleText(TalkModes.Languages:GetPhrase(strDesc), "TalkModes:Small", 6, 6 + intH, THEME["Gray"])
    end

    if (strType == "tText") then
        this:SetHeight(100)
        this.textEntry = this:Add("TalkModes.TextEntry")
        this.textEntry:SetPos(8, 100 - 32 - 6)
        this.textEntry:SetSize(128, 32)
        this.textEntry:SetValue(uValue)
    end

    if (strType == "tSwitch") then
        this:SetHeight(100)
        this.switch = this:Add("TalkModes.Switch")
        this.switch:SetPos(12, 100 - 6 - 32)
        this.switch:SetValue(uValue)
    end

    if (strType == "tColor") then
        this:SetHeight(125)
        this.colorPicker = this:Add("TalkModes.ColorPicker")
        this.colorPicker:Dock(FILL)
        this.colorPicker:SetValue(uValue)
        this.colorPicker:UpdateColors()
    end

    if (strType == "tDropdown") then
        this:SetHeight(100)
        this.dropdown = this:Add("TalkModes.Dropdown")
        this.dropdown:SetPos(8, 100 - 6 - 32)
        this.dropdown:SetValue(uValue)
        this.dropdown.intW, this.dropdown.intH = this.dropdown:GetContentSize()
        this.dropdown:SetSize(this.dropdown.intW + 24, this.dropdown.intH + 4)
        for k, _ in pairs(tblData) do
            this.dropdown:AddChoice(k, v)
        end
    end

    if (strType == "tBinder") then
        this:SetHeight(100)
        this.binder = this:Add("TalkModes.Binder")
        this.binder:SetSize(64, 24)
        this.binder:SetPos(8, 100 - 6 - 32)
        this.binder:SetValue(uValue)
    end
    
    if (strType == "tSlider") then
        this:SetHeight(100)
        this.slider = this:Add("TalkModes.PreviewSlider")
        this.slider:Dock(FILL)
        this.slider.slider:SetMinMax(0, 2000)
        this.slider:SetValue(uValue)
        this.slider:RefreshValue()
    end

    self.tblSettings[#self.tblSettings + 1] = this
end
vgui.Register("TalkModes.SettingsBase", PANEL, "EditablePanel")


