local sc = VoidUI.Scale
local L = VoidFactions.Lang.GetPhrase

local PANEL = {}

function PANEL:Init()
    self:SSetSize(670, 520)
    self:SetTitle(L"newFaction")
    self:Center()

    self.tabs = self:Add("VoidUI.Tabs")
    self.tabs:Dock(TOP)
    self.tabs:SetTall(self:GetTall() * 0.9)

    if (VoidFactions.Settings:IsDynamicFactions()) then
        self.tabs:SetAccentColor(VoidUI.Colors.Green)
    end

    local generalPanel = self:CreateGeneral()
    local visualPanel = self:CreateVisual()

    self.tabs:AddTab(string.upper(L"general"), generalPanel)
    self.tabs:AddTab(string.upper(L"visual"), visualPanel)

    local preferencesPanel = nil
    if (VoidFactions.Settings:IsStaticFactions()) then
        preferencesPanel = self:CreatePreferences()
        self.tabs:AddTab(string.upper(L"preferences"), preferencesPanel)
    end

    local buttonContainer = self:Add("Panel")
    buttonContainer:Dock(BOTTOM)
    buttonContainer:SSetTall(100)
    buttonContainer:SDockPadding(80,30,80,30)

    local saveButton = buttonContainer:Add("VoidUI.Button")
    saveButton:Dock(LEFT)
    saveButton:SSetWide(230)
    saveButton:SetText(L"create")
    saveButton:SetColor(VoidUI.Colors.Green, VoidUI.Colors.Background)

    saveButton.DoClick = function ()
        -- yikes
        local b = false
        if (VoidFactions.Settings:IsStaticFactions()) then
            b = VoidFactions.Faction:UpdateStaticFaction(nil, self:GetValues())
        else
            local name, factionTag, _, factionColor, _, logo, inviteRequired = self:GetValues()
            b = VoidFactions.Faction:UpdateDynamicFaction(nil, name, factionTag, factionColor, logo, inviteRequired)

            VoidFactions.Menu.ReopenRequested = true
        end
        if (b) then
            self:Remove()
        end
    end

    self.generalPanel = generalPanel
    self.visualPanel = visualPanel
    self.preferencesPanel = preferencesPanel

    self.buttonContainer = buttonContainer
    self.saveButton = saveButton

end

function PANEL:GetValues()
    local generalPanel = self.generalPanel
    local visualPanel = self.visualPanel
    local preferencesPanel = self.preferencesPanel

    local name = generalPanel.name.entry:GetValue()
    local description = generalPanel.description and generalPanel.description.entry:GetValue()
    local factionTag = generalPanel.factionTag.entry:GetValue()
    local subfactionOf = generalPanel.subfaction and generalPanel.subfaction.value
    if (subfactionOf == 0) then subfactionOf = nil end

    local factionColor = visualPanel.factionColor.colorMixer:GetColor()
    local maxMembers = generalPanel.maxMembers and generalPanel.maxMembers.entry:GetValue() != "" and generalPanel.maxMembers.entry:GetInt() or 0
    local logo = visualPanel.logo.textInput.entry:GetValue()

    if (!factionColor) then
        factionColor = VoidUI.Colors.White -- fallback
    end

    preferencesPanel = preferencesPanel or {}

    local isDefaultFaction = preferencesPanel.isDefaultFaction and preferencesPanel.isDefaultFaction.value
    local inviteRequired = preferencesPanel.inviteRequired and preferencesPanel.inviteRequired.value or (generalPanel.inviteRequired and generalPanel.inviteRequired.value)
    local canCaptureTerritory = preferencesPanel.canCaptureTerritory and preferencesPanel.canCaptureTerritory.value
    local showOnBoard = preferencesPanel.showOnBoard and preferencesPanel.showOnBoard.value

    local usergroups = generalPanel.usergroups and generalPanel.usergroups.value or {}

    return name, factionTag, subfactionOf, factionColor, maxMembers, logo, inviteRequired, canCaptureTerritory, showOnBoard, isDefaultFaction, description, usergroups
    
end

function PANEL:CreateGeneral()
    local panel = self.tabs:Add("Panel")
    panel:Dock(FILL)

    local container = panel:Add("Panel")
    container:Dock(FILL)
    container:SDockMargin(30, 20, 30, 20)

    local grid = container:Add("VoidUI.ElementGrid")
    grid:Dock(FILL)
    grid:MarginBottom(60)

    panel.name = grid:AddElement(L"name", "VoidUI.TextInput")
    local factionTag, thisPanel = grid:AddElement(L"factionTag", "VoidUI.TextInput")
    panel.factionTag = factionTag
    thisPanel:SetVisible(!VoidFactions.Config.NametagsDisabled)

    if (VoidFactions.Settings:IsDynamicFactions()) then
        panel.inviteRequired = grid:AddElement(L"inviteRequired", "VoidUI.Dropdown")
        panel.inviteRequired:SetupChoice(L"yes", L"no", true)
    end

    if (VoidFactions.Settings:IsStaticFactions()) then
        panel.subfaction = grid:AddElement(L"subfactionOf", "VoidUI.SelectorButton")
        panel.subfaction.text = L"clickToAdd"
        panel.subfaction.DoClick = function ()
            local selector = vgui.Create("VoidUI.ItemSelect")
            selector:SetParent(self)

            local factionTbl = {}

            -- Autoincrement starts from 1 so we are safe to use this
            factionTbl[0] = "None"

            for id, faction in pairs(VoidFactions.LoadedFactions) do
                local isRoot = !faction.parentFaction
                local isFaction = !isRoot and !faction.parentFaction.parentFaction or false 
                local isSubfaction = !isFaction and !isRoot

                -- Don't show the same faction 
                if (self.isEditing and self.editedFaction.id == faction.id) then continue end
                if (self.isEditing and faction.parentFaction and faction.parentFaction.id == self.editedFaction.id) then continue end

                -- Subfaction is the last level
                if (!isSubfaction) then
                    factionTbl[id] = faction.name
                end
            end

            selector:InitItems(factionTbl, function (id, v)
                panel.subfaction:Select(id, v)
            end)
        end

        panel.maxMembers = grid:AddElement(L"maxMembers", "VoidUI.TextInput")
        panel.maxMembers:SetNumeric(true)

        panel.description = grid:AddElement(L"description", "VoidUI.TextInput", 100)
        panel.description:SetMultiline(true)
        panel.description:SetFont("VoidUI.R20")

        panel.usergroups = grid:AddElement(L"usergroups", "VoidUI.SelectorButton")
        panel.usergroups.text = L"clickToAdd"
        panel.usergroups.DoClick = function ()
            local selector = vgui.Create("VoidUI.ItemSelect")
			selector:SetParent(self)
            selector:SetMultipleChoice(true)
            
            if (panel.usergroups.multiSelection) then
				selector.choices = panel.usergroups.multiSelection
			end

            local uTbl = {}
            for usergroup, tb in pairs(CAMI.GetUsergroups()) do
				uTbl[usergroup] = tb.Name
            end

			selector:InitItems(uTbl, function (tbl, selTbl)
				panel.usergroups:Select(tbl, selTbl)
			end)
        end
    end
    

    return panel
end

function PANEL:CreateVisual()
    local panel = self.tabs:Add("Panel")
    panel:Dock(FILL)

    local container = panel:Add("Panel")
    container:Dock(FILL)
    container:SDockMargin(30, 20, 30, 20)

    local grid = container:Add("VoidUI.ElementGrid")
    grid:Dock(FILL)
    grid:MarginBottom(60)

    panel.factionColor = grid:AddElement(L"factionColor", "VoidUI.ColorMixer", sc(145))
    panel.logo = grid:AddElement(L"factionIcon", "VoidUI.IconSelector", sc(200))
    

    return panel
end

function PANEL:CreatePreferences()
    local panel = self.tabs:Add("Panel")
    panel:Dock(FILL)

    local container = panel:Add("Panel")
    container:Dock(FILL)
    container:SDockMargin(30, 20, 30, 20)

    local grid = container:Add("VoidUI.ElementGrid")
    grid:Dock(FILL)
    grid:MarginBottom(60)

    panel.inviteRequired = grid:AddElement(L"inviteRequired", "VoidUI.Dropdown")
    panel.inviteRequired:SetupChoice(L"yes", L"no", true)

    panel.canCaptureTerritory = grid:AddElement(L"canCaptureTerritory", "VoidUI.Dropdown")
    panel.canCaptureTerritory:SetupChoice(L"yes", L"no", true)

    panel.showOnBoard = grid:AddElement(L"showOnBoard", "VoidUI.Dropdown")
    panel.showOnBoard:SetupChoice(L"yes", L"no", true)

    panel.isDefaultFaction = grid:AddElement(L"isDefaultFaction", "VoidUI.Dropdown")

    local defaultChoice = table.Count(VoidFactions.LoadedFactions) == 0
    panel.isDefaultFaction:SetupChoice(L"yes", L"no", defaultChoice)
    
    return panel
end

function PANEL:OnSave(func)
    self.onSaveFunc = func
end

function PANEL:OnDelete(func)
    self.onDeleteFunc = func
end

function PANEL:EditMode(faction)

    local member = VoidFactions.PlayerMember

    self.isEditing = true
    self.editedFaction = faction

    self.saveButton:SetText(L"save")

    self:SetTitle(L("editFaction", faction.name))

    local delText = L"delete"
    if (member.faction == faction and VoidFactions.Settings:IsDynamicFactions()) then
        delText = L"disband"
    end

    local deleteButton = self.buttonContainer:Add("VoidUI.Button")
    deleteButton:Dock(RIGHT)
    deleteButton:SSetWide(230)
    deleteButton:SetText(delText)
    deleteButton:SetColor(VoidUI.Colors.Red, VoidUI.Colors.Background)

    deleteButton.DoClick = function ()
        -- Open a popup
        local popup = vgui.Create("VoidUI.Popup")
        popup:SetText(L"disbandFaction", L("disbandFactionPrompt", faction.name))
        popup:SetDanger()
        popup:Continue(L"disband", function ()
            -- Delete the faction
            VoidFactions.Faction:DeleteFaction(faction)
            self:Remove()

            if (self.onDeleteFunc) then
                self.onDeleteFunc()
            end

            if (member.faction == faction and VoidFactions.Settings:IsDynamicFactions()) then
                VoidFactions.Menu.ReopenRequested = true
            end
        end)
        popup:Cancel(L"cancel")
    end

    local panel = self.generalPanel

    panel.name.entry:SetValue(faction.name)
    panel.factionTag.entry:SetValue(faction.tag or "")

    if (VoidFactions.Settings:IsStaticFactions()) then
        panel.description.entry:SetValue(faction.description or "")
        panel.maxMembers.entry:SetValue(faction.maxMembers)
        if (faction.parentFaction) then
            panel.subfaction:Select(faction.parentFaction.id, faction.parentFaction.name)
        end

        local tbl = {}
        local tbl1 = {}
        for k, v in pairs(faction.requiredUsergroups) do
            tbl[v] = CAMI.GetUsergroups()[v].Name
            tbl1[k] = tbl[v]
        end

        panel.usergroups.multiSelection = tbl
        panel.usergroups:Select(table.GetKeys(tbl), tbl1)
    else
        panel.inviteRequired:ChooseOptionID(faction.inviteRequired and 1 or 2)
    end

    local panel = self.visualPanel
    panel.factionColor.colorMixer:SetColor(faction.color)
    if (faction.logo) then
        panel.logo.textInput:SetValue(faction.logo)
    end

    if (VoidFactions.Settings:IsStaticFactions()) then
        local panel = self.preferencesPanel
        panel.inviteRequired:ChooseOptionID(faction.inviteRequired and 1 or 2)
        panel.canCaptureTerritory:ChooseOptionID(faction.canCaptureTerritory and 1 or 2)
        panel.showOnBoard:ChooseOptionID(faction.showBoard and 1 or 2)
        panel.isDefaultFaction:ChooseOptionID(faction.isDefaultFaction and 1 or 2)
    end

    self.saveButton.DoClick = function ()
        local b = false
        if (VoidFactions.Settings:IsStaticFactions()) then
            b = VoidFactions.Faction:UpdateStaticFaction(faction, self:GetValues())
        else
            local name, factionTag, _, factionColor, _, logo, inviteRequired = self:GetValues()
            b = VoidFactions.Faction:UpdateDynamicFaction(faction, name, factionTag, factionColor, logo, inviteRequired)

            VoidFactions.Menu.ReopenRequested = true
        end
        if (b) then
            if (self.onSaveFunc) then
                self.onSaveFunc(self:GetValues())
            end
            self:Remove()
        end
    end
end

vgui.Register("VoidFactions.UI.FactionCreate", PANEL, "VoidUI.ModalFrame")