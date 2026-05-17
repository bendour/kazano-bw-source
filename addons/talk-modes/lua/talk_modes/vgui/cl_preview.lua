include("talk_modes/vgui/libs/cl_spheres.lua")

-- This is global which allows us to interact with it anywhere, cl_selection in particular. 
TM_ADMIN_PREVIEW = TM_ADMIN_PREVIEW || {bActive = false, intRange = 300}
local THEME = TalkModes.Client.ActiveTheme

function TalkModes.Client.HUDPaint()
    if TM_ADMIN_PREVIEW.bActive == false then return end
    if TM_ADMIN_PREVIEW.intRange == 0 then return end

    surface.SetFont("TalkModes:Medium")
    local intTextW, intTextH = surface.GetTextSize(string.format(TalkModes.Languages:GetPhrase("PreviewText"), TM_ADMIN_PREVIEW.intRange))
    draw.RoundedBox(6, ScrW()/2 - (intTextW + 24)/2, ScrH() - intTextH + 8 - 24 , intTextW + 24, intTextH + 8, Color(THEME["Hover"].r, THEME["Hover"].g, THEME["Hover"].b, 200))
    draw.SimpleText(string.format(TalkModes.Languages:GetPhrase("PreviewText"), TM_ADMIN_PREVIEW.intRange), "TalkModes:Medium", ScrW()/2, ScrH() - 24, THEME["White"], TEXT_ALIGN_CENTER, TEXT_ALIGN_CENTER)
    surface.SetFont("TalkModes:Small")
    local intTextWw, intTextHh = surface.GetTextSize(TalkModes.Languages:GetPhrase("PreviewHeader"))
    draw.RoundedBoxEx(6, ScrW()/2 - (intTextWw + 24)/2, ScrH() - intTextH + 8 - 24 - intTextHh, intTextWw + 24, intTextHh, Color(THEME["Hover"].r, THEME["Hover"].g, THEME["Hover"].b, 200), true, true, false, false )
    draw.SimpleText(string.format(TalkModes.Languages:GetPhrase("PreviewHeader"), string.upper(input.GetKeyName(TalkModes.Config:GetSetting("General", "Selection Key")))), "TalkModes:Small", ScrW()/2, ScrH() - intTextH + 8 - 24 - intTextHh/2, THEME["White"], TEXT_ALIGN_CENTER, TEXT_ALIGN_CENTER)
end
hook.Add("HUDPaint", "TalkModes.Client.HUDPaint", TalkModes.Client.HUDPaint)

function TalkModes.Client.PostDrawTranslucentRenderables()
    if TM_ADMIN_PREVIEW.bActive == false then return end
    if TM_ADMIN_PREVIEW.intRange == 0 then return end

    render.StartWorldRings()
        render.AddWorldRing(LocalPlayer():GetPos(), TM_ADMIN_PREVIEW.intRange, 10, 50)
    render.FinishWorldRings(THEME["Hover"])
end
hook.Add("PostDrawTranslucentRenderables", "TalkModes.Client.PostDrawTranslucentRenderables", TalkModes.Client.PostDrawTranslucentRenderables)

net.Receive("TalkModes.TriggerPreview", function(_)
    local intRange = net.ReadUInt(12)

    if TM_ADMIN_PREVIEW.bActive == true then 
        TM_ADMIN_PREVIEW.bActive = false
        TM_ADMIN_PREVIEW.intRange = 0
    else 
        TM_ADMIN_PREVIEW.bActive = true 
        TM_ADMIN_PREVIEW.intRange = intRange
    end
end)