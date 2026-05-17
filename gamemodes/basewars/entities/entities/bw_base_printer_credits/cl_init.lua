include("shared.lua")

BaseWars:CreateFont("BaseWars.Printer.Name", 30, 500)
BaseWars:CreateFont("BaseWars.Printer.Info", 18, 500)
BaseWars:CreateFont("BaseWars.Printer.Bottom", 20, 500)

function ENT:Initialize()
    self.upgrades = 0
    self.buyPaper = 0
    self.paperBar = 0
    self.moneyBar = 0
end

local icons = {
    ["paper"] = Material("basewars_materials/printer/paper.png", "smooth"),
    ["upgrade"] = Material("basewars_materials/printer/upgrade.png", "smooth"),
}

function ENT:Draw()
    self:DrawModel()

    local ply = LocalPlayer()
    local showPrinter = true

    local spec = FSpectate and FSpectate:GetSpecEnt()
    if IsValid(spec) and spec:IsPlayer() then
        ply = spec
    end

    local traceEntity = ply:GetEyeTrace().Entity

    if ply:GetPos():Distance(self:GetPos()) > BaseWars.Config.EntityRenderDistance then
        showPrinter = false
    end

    if self:CPPIGetOwner() == ply and not ply:GetBaseWarsConfig("seeYourPrinter") then
        showPrinter = traceEntity == self
    end

    if self:CPPIGetOwner() != ply and not ply:GetBaseWarsConfig("seeOtherPrinter") then
        showPrinter = traceEntity == self
    end

    if not showPrinter then
        return
    end

    local pos = self:GetPos()
    local angle = self:GetAngles()

    pos = pos + angle:Up() * 10.8
    pos = pos + angle:Forward() * -16.35
    pos = pos + angle:Right() * 15.16

    angle:RotateAroundAxis(angle:Up(), 90)

    cam.Start3D2D(pos, angle, .1)
        local w, h = 307, 307
        local textColor = (self.TextColor == "VIP" and HSVToColor(CurTime() % 6 * 60, 1, 1) or (self.TextColor == "PRESTIGE" and HSVToColor(CurTime() % 6 * 60, .35, 1)) or self.TextColor) or color_white
        local lerpFrac = FrameTime() * 15
        local half = (w - 15) * .5

        local paper = self:GetPaper()
        local maxPaper = self:GetMaxPaper()
        local printAmount = self:GetPrintAmount()
        local interval = self:GetPrintInterval()

        -- Lerp
        self.buyPaper = Lerp(lerpFrac, self.buyPaper, self:OnBuyPaper(ply) and 255 or 30)
        self.paperBar = Lerp(lerpFrac, self.paperBar, math.Clamp(paper / maxPaper, 0, 1))
        self.upgrades = Lerp(lerpFrac, self.upgrades, self:OnUpgrade(ply) and 255 or 30)

        -- Printer Name
        BaseWars:DrawRoundedBox(4, 5, 5, w - 5 * 2, 36, self.Color)
        draw.SimpleText(self.PrintName or "unknown", "BaseWars.Printer.Name", w * .5, 23, textColor, 1, 1)

        -- Paper
         BaseWars:DrawRoundedBox(3, 5, 46, w - 10, 30, self.Color)
         BaseWars:DrawMaterial(icons["paper"], 10, 51, 20, 20, textColor)
         BaseWars:DrawRoundedBox(3, 35, 51, w - 45, 20, self.SubColor)
         BaseWars:DrawRoundedBox(3, 35, 51, (w - 45) * self.paperBar, 20, textColor)

        -- Printer Infos
        BaseWars:DrawRoundedBox(3, 5, 81, w - 10, h - 60, self.Color)

        local money = self:GetMoney()
        local capacity = self:GetCapacity()
        local time = (capacity - money) / (printAmount / interval)

        -- Lerp
        self.moneyBar = Lerp(lerpFrac, self.moneyBar, math.Clamp(money / capacity, 0, 1))

        -- Printer Infos
        BaseWars:DrawRoundedBox(2, 10, 86, w - 20, 15, self.SubColor)
        BaseWars:DrawRoundedBox(2, 10, 86, (w - 20) * self.moneyBar, 15, textColor)
        draw.SimpleText(BaseWars:FormatCredit(money, true) .. " / " .. BaseWars:FormatCredit(capacity, true), "BaseWars.Printer.Info", w * .5, 101, textColor, 1)
        draw.SimpleText(time == 0 and ply:GetLang("printer_full") or ply:GetLang("printer_time"):format(BaseWars:FormatTime3(time, ply)), "BaseWars.Printer.Info", w * .5, 166, textColor, 1, TEXT_ALIGN_BOTTOM)
    cam.End3D2D()
end

-- net.Receive("BaseWars:Printer:OpenUpgradeMenu", function()
--     local printer = net.ReadEntity()

--     if IsValid(PrinterUpgradePanel) then
--         PrinterUpgradePanel:Remove()
--     end

--     PrinterUpgradePanel = vgui.Create("BaseWars.VGUI.PrinterUpgrade")
--     PrinterUpgradePanel:SetPrinter(printer)
-- end)