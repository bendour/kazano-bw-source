local waitTime = 0
local thisPanel

local tileHeight = BaseWars.ScreenScale * 200
local elementTall = BaseWars.ScreenScale * 50
local bigMargin = BaseWars.ScreenScale * 10
local margin = BaseWars.ScreenScale * 5
local roundness = BaseWars.ScreenScale * 4

local PANEL = {}
function PANEL:Init()
    self.w, self.h = self:GetParent():GetSize()
    self.localPlayer = LocalPlayer()
    self.colors = {
        text = GetBaseWarsTheme("bwm_text"),
        darkText = GetBaseWarsTheme("bwm_darkText"),
        background = GetBaseWarsTheme("bwm_background"),
        contentBackground = GetBaseWarsTheme("bwm_contentBackground"),
        contentBackground2 = GetBaseWarsTheme("bwm_contentBackground2")
    }

    thisPanel = self

    self.Scroll = self:Add("DScrollPanel")
    self.Scroll:Dock(FILL)
    self.Scroll:DockMargin(bigMargin, bigMargin, bigMargin, bigMargin)
    self.Scroll:GetVBar():SetWide(0)
    self.Scroll.Paint = function(s,w,h)
        local layout = s.Layout

        if IsValid(layout) and layout:ChildCount() <= 0 then
            draw.SimpleText(self.localPlayer:GetLang("permanentWeapon_playerNoWeapons"), "BaseWars.40", w * .5, h * .5, self.colors.text, 1, 1)
        end
    end

    self.Scroll.Layout = self.Scroll:Add("DIconLayout")
    self.Scroll.Layout:Dock(TOP)
    self.Scroll.Layout:SetTall(self.h)
    self.Scroll.Layout:SetSpaceX(margin)
    self.Scroll.Layout:SetSpaceY(margin)

    self:Build()
end

function PANEL:Build(data)
    data = data or BaseWars.PW:GetWeapons()

    local weaponCount = table.Count(data)

    if weaponCount > 9 then
        self.Scroll:GetVBar():SetWide(bigMargin)
        self.Scroll:PaintScrollBar("bwm")
    end

    self.Scroll.Layout:Clear()

    local tileWide = math.floor((self.w - bigMargin * 2 - margin * 2 - (weaponCount > 9 and bigMargin + margin or 0)) / 3)
    for weaponClass, weaponData in SortedPairsByMemberValue(data, "weapon_id") do
        local when = os.date("%d - %b - %Y", weaponData.date)
        local weaponName = BaseWars.PW:GetWeaponName(weaponClass)

        BaseWars:RequestSteamName(weaponData.admin_id64)

        local weaponPanel = self.Scroll.Layout:Add("DPanel")
        weaponPanel:SetSize(tileWide, tileHeight)
        weaponPanel.Paint = function(s,w,h)
            BaseWars:DrawRoundedBox(roundness, 0, 0, w, h, self.colors.contentBackground)
        end

        weaponPanel.Icon = weaponPanel:Add("SpawnIcon")
        weaponPanel.Icon:Dock(FILL)
        weaponPanel.Icon:DockMargin(bigMargin, bigMargin, bigMargin, bigMargin)
        weaponPanel.Icon:SetMouseInputEnabled(false)
        weaponPanel.Icon:SetModel(BaseWars.PW:GetWeaponModel(weaponClass))

        weaponPanel.Bottom = weaponPanel:Add("DPanel")
        weaponPanel.Bottom:Dock(BOTTOM)
        weaponPanel.Bottom:SetTall(elementTall)
        weaponPanel.Bottom.Paint = function(s,w,h)
            BaseWars:DrawRoundedBox(roundness, 0, 0, w, h, self.colors.contentBackground2)

            draw.SimpleText(weaponName, "BaseWars.20", bigMargin, h * .5, self.colors.text, 0, 4)
            draw.SimpleText(Format(self.localPlayer:GetLang("permanentWeapon_addedByAndDate"), BaseWars:GetSteamName(weaponData.admin_id64), when), "BaseWars.16", bigMargin, h * .5, self.colors.darkText)
        end

        weaponPanel.Bottom.Toggle = weaponPanel.Bottom:Add("BaseWars.CheckBox")
        weaponPanel.Bottom.Toggle:Dock(RIGHT)
        weaponPanel.Bottom.Toggle:DockMargin(0, bigMargin, bigMargin, bigMargin)
        weaponPanel.Bottom.Toggle:SetWide(BaseWars.ScreenScale * 80)
        weaponPanel.Bottom.Toggle:SetBackgroundColor(self.colors.background)
        weaponPanel.Bottom.Toggle:SetState(weaponData.active, true)
        weaponPanel.Bottom.Toggle.Toggle = function(s)
            if waitTime >= CurTime() then
                return
            end

            waitTime = CurTime() + .5

            local newState = not s:GetState()

            surface.PlaySound("bw_button.wav")
            s:SetState(newState)

            BaseWars.PW:SetWeaponActive(weaponClass, newState)

            net.Start("BaseWars:PermanentWeapons:PlayerToggleWeapon")
                net.WriteString(weaponClass)
                net.WriteBool(newState)
            net.SendToServer()
        end
    end
end

function PANEL:Paint()
end

vgui.Register("BaseWars.F3Menu.PermanentWeapons", PANEL, "DPanel")

net.Receive("BaseWars:PermanentWeapons:SendDataToClient", function(len)
    local bytes = net.ReadUInt(16)
    local data = util.JSONToTable(util.Decompress(net.ReadData(bytes)))
    local rebuild = net.ReadBool()

    LocalPlayer().basewarsPermanentWeapons = data

    if IsValid(thisPanel) and rebuild then
        thisPanel:Build(data)
    end
end)