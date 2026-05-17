--[[-------------------------------------------

    Talk Modes - whisper/talk/yell 

    Licensed to 00000000000000000
	Version: 1.1.1

	By: SaturdaysHeroes & Djuk
	Special thanks to CupCakeR

--]]-------------------------------------------
TalkModes = TalkModes || {}
TalkModes.Client = TalkModes.Client || {}

function TalkModes.Client:CreateFont(name, size)
	surface.CreateFont(name, {
		font = "Montserrat Medium",
		size = size,
		weight = 500,
        extended = true,
        antialias = true
	})
end

local tblTalkModes = {
    [1] = {
        strMode = "Whisper",
        matImage = Material("talkmodes/whisper.png")
    },
    [2] = {
        strMode = "Talk",
        matImage = Material("talkmodes/normal.png")
    },  
    [3] = {
        strMode = "Yell",
        matImage = Material("talkmodes/yell.png")
    }
}

local tblPositions = {
    ["Top Left"] = {6, 6},
    ["Top Center"] = {ScrW()/2 - 120/2, 6},
    ["Top Right"] = {ScrW() - 120 - 6, 6},
    ["Center Left"] = {6, ScrH()/2 - 44/2},
    ["Center Right"] = {ScrW() - 120 - 6, ScrH()/2 - 44/2},
    ["Bottom Left"] = {6, ScrH() - 44 - 6},
    ["Bottom Center"] = {ScrW()/2 - 120/2, ScrH() - 44 - 6},
    ["Bottom Right"] = {ScrW() - 120 - 6, ScrH() - 44 - 6}
}

TalkModes.Client:CreateFont("TalkModes:Small", 20)
TalkModes.Client:CreateFont("TalkModes:Medium", 26)
TalkModes.Client:CreateFont("TalkModes:Big", 32)
TalkModes.Client:CreateFont("TalkModes:Huge", 48)

local selectionMenu
function TalkModes.Client.InitMenu()
    if (selectionMenu) then
        selectionMenu:Remove()
    end
    selectionMenu = vgui.Create("TalkModes.PlayerMenu")
    local intW, intH = tblPositions[TalkModes.Config:GetSetting("General", "Selection Menu Position")][1], tblPositions[TalkModes.Config:GetSetting("General", "Selection Menu Position")][2]
    selectionMenu:SetPos(intW, intH)
end
net.Receive("TalkModes.InitMenu", TalkModes.Client.InitMenu)


local intCurrentTalkMode = 2
local intCooldown = CurTime()
local intPanelTime = CurTime() + 3
local bFadingOut = false
local bPlayingPiano = false
function TalkModes.Client.MenuControl()
    local bCamera = (LocalPlayer():GetActiveWeapon():IsValid() && LocalPlayer():GetActiveWeapon():GetClass() == "gmod_camera") && true || false

    if (bCamera) then
        if (selectionMenu:IsVisible()) then
            selectionMenu:SetAlpha(0)
            selectionMenu:SetVisible(false)
            print(selectionMenu:IsVisible())
        end
    else
        if (!selectionMenu:IsVisible() && !TalkModes.Config:GetSetting("General", "Auto-Hide")) then
            selectionMenu:SetVisible(true)
            selectionMenu:SetAlpha(255)
        end
    end

    if (TalkModes.Config:GetSetting("General", "Auto-Hide")) then
        if (!input.IsKeyDown(TalkModes.Config:GetSetting("General", "Selection Key") || 18)) then
            if (CurTime() > intPanelTime && !bFadingOut && selectionMenu:IsVisible()) then
                bFadingOut = true
                selectionMenu:AlphaTo(0, 0.5, 0, function(_, self)
                    self:SetVisible(!(CurTime() > intPanelTime))
                    bFadingOut = false
                end)
            end
        end
    end

    if (input.IsKeyDown(TalkModes.Config:GetSetting("General", "Selection Key") || 18) && TM_ADMIN_PREVIEW.bActive) then 
        net.Start("TalkModes.AttemptPreview")
        net.SendToServer()
        return
    end

    bPianoPlaying = LocalPlayer().Instrument && LocalPlayer().Instrument:GetClass() == "gmt_instrument_piano" && true || false // Playable piano support
    
    if (!input.IsKeyDown(TalkModes.Config:GetSetting("General", "Selection Key") || 18) || vgui.CursorVisible() || intCooldown > CurTime() || bPianoPlaying) then return end

    if (TalkModes.Config:GetSetting("General", "Auto-Hide") && !bCamera) then
        selectionMenu:SetVisible(true)
        selectionMenu:AlphaTo(255, 0.25)
        intPanelTime = CurTime() + 3 + 0.75
    end

    for k, v in ipairs(tblTalkModes) do
        if (v.strMode == LocalPlayer():GetTalkMode()) then
            intCurrentTalkMode = k
            break
        end
    end
    
    intCurrentTalkMode = intCurrentTalkMode < 3 && intCurrentTalkMode + 1 || 1
    net.Start("TalkModes.ChangeMode")
        net.WriteString(tblTalkModes[intCurrentTalkMode].strMode)
    net.SendToServer()
    intCooldown = CurTime() + 0.5
end
hook.Add("Think", "TalkModes.Client.MenuControl", TalkModes.Client.MenuControl)