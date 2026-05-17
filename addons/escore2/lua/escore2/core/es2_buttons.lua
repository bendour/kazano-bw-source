local function get_admin_mod()
    return (escore2.addon:GetVar("admin_mod") or {})[1]
end

local function rank_access_check()
    local ranks = escore2.addon:GetVar("rank_form")
    local user_group = LocalPlayer():GetUserGroup() or ""

    local rank = ranks[user_group] or {}
    if rank["rank_admin_cmds"] then
        return true --return any value here
    end
end

----------------------
--# BOTTOM BUTTONS #--
----------------------
-- You can see available methods in file 
-- escore2\lua\escore2\core\common\es2_button_meta.lua
local search_btn = escore2:NewBottomButton("search")
search_btn:SetIcon(escore2:GetMaterial("search.png"))
search_btn:SetIconColor(175, 232, 255)
search_btn:SetPosition(1)
search_btn:SetTranslatedName("button_search")
function search_btn:OnClick()
    escore2:ToggleSearch()
end

local settings_btn = escore2:NewBottomButton("settings")
settings_btn:SetIcon(escore2:GetMaterial("cog.png"))
settings_btn:SetIconColor(163, 175, 179)
settings_btn:SetPosition(2)
settings_btn:SetTranslatedName("button_settings")
function settings_btn:OnClick()
    RunConsoleCommand("esettings", "escore2")
    escore2:Close()
end



----------------------
--# ACTION BUTTONS #--
----------------------
-- You can see available methods in file 
-- escore2\lua\escore2\core\common\es2_button_meta.lua

--GENERAL CATEGORY
local category = escore2:NewActionButtonCategory("category_common")
category:SetColor(Color(63, 86, 107)) --Buttons inherit this

-- Open profile
category:AddButton("action_open_profile")
:SetIcon(escore2:GetMaterial("steam.png"))
:SetFunc(function(self, ply, button_panel)
    ply:ShowProfile()
end)

-- Copy profile link
category:AddButton("action_copy_profile")
:SetIcon(escore2:GetMaterial("link.png"))
:SetFunc(function(self, ply, button_panel)
    local steam_url = string.format("http://steamcommunity.com/profiles/%s", ply:SteamID64())
    SetClipboardText(steam_url)
end)

-- Mute / Unmute
local muted_icon = escore2:GetMaterial("muted.png")
local unmuted_icon = escore2:GetMaterial("unmuted.png")
category:AddButton("action_mute")
:SetNameTranslateKey(escore2.addon:Translate("action_mute"))
:SetIcon(unmuted_icon)
:SetInitFunc(function(self, ply, button_panel) --invokes multiple times! (on update and change size)
    self:SetIcon(ply:IsMuted() and muted_icon or unmuted_icon)
    self:SetNameTranslateKey(ply:IsMuted() and "action_unmute_cl" or "action_mute_cl")
end)
:SetFunc(function(self, ply, button_panel)
    ply:SetMuted(not ply:IsMuted()) --switch
    self:Update()
end)


-- Copy SteamID
category:AddButton("action_copy_steamid")
:SetIcon(escore2:GetMaterial("copy.png"))
:SetFunc(function(self, ply, button_panel)
    SetClipboardText(ply:SteamID())
end)
:SetCheckFunc(function(self, target, ply) 
    if target ~= "context" then return false end
end)

-- Copy SteamID64
category:AddButton("action_copy_steamid64")
:SetIcon(escore2:GetMaterial("copy.png"))
:SetFunc(function(self, ply, button_panel)
    SetClipboardText(ply:SteamID64())
end)
:SetCheckFunc(function(self, target, ply) 
    if target ~= "context" then return false end
end)



--ADMIN CATEGORY
local category = escore2:NewActionButtonCategory("category_admin")
category:SetPosition(2)
category:SetColor(Color(196, 187, 64)) --Buttons inherit this
category:SetCheckFunc(function(self, target, ply) --target: ["player", "context"]
    local count = 0
    local buttons = self:GetButtons()
    for _,button_info in ipairs(buttons) do
        if button_info:GetCheckFunc()(button_info, target, ply) == false then continue end
        count = count + 1
    end

    if count < 1 then return false end
end)


--Goto command
category:AddButton("action_goto")
:SetIcon(escore2:GetMaterial("goto.png"))
:SetFunc(function(self, target, button_panel)
    local admin_mod = get_admin_mod()

    if admin_mod == "sam" then
        RunConsoleCommand("sam", "goto", target:SteamID64())
    elseif admin_mod == "ulx" then
        RunConsoleCommand("ulx", "goto", target:Nick())
    elseif admin_mod == "fadmin" then
        RunConsoleCommand("fadmin", "goto", target:Nick())
    elseif admin_mod == "sadmin" then
        RunConsoleCommand("sa", "goto", target:SteamID64())
    end
end)
:SetCheckFunc(function(self, target, ply)--target: ["player", "context"]
    if ply == LocalPlayer() then return false end
    if rank_access_check() then return true end --allow
    return false --prevent to be visible
end)
    

--Bring command
category:AddButton("action_bring")
:SetIcon(escore2:GetMaterial("bring.png"))
:SetFunc(function(self, target, button_panel)
    local admin_mod = get_admin_mod()

    if admin_mod == "sam" then
        RunConsoleCommand("sam", "bring", target:SteamID64())
    elseif admin_mod == "ulx" then
        RunConsoleCommand("ulx", "bring", target:Nick())
    elseif admin_mod == "fadmin" then
        RunConsoleCommand("fadmin", "bring", target:Nick())
    elseif admin_mod == "sadmin" then
        RunConsoleCommand("sa", "bring", target:SteamID64())
    end
end)
:SetCheckFunc(function(self, target, ply)--target: ["player", "context"]
    if ply == LocalPlayer() then return false end
    if rank_access_check() then return true end --allow
    return false --prevent to be visible
end)


--Return command
category:AddButton("action_return")
:SetIcon(escore2:GetMaterial("return.png"))
:SetFunc(function(self, target, button_panel)
    local admin_mod = get_admin_mod()

    if admin_mod == "sam" then
        RunConsoleCommand("sam", "return", target:SteamID64())
    elseif admin_mod == "ulx" then
        RunConsoleCommand("ulx", "return", target:Nick())
    elseif admin_mod == "sadmin" then
        RunConsoleCommand("sa", "return", target:SteamID64())
    end
end)
:SetCheckFunc(function(self, target, ply)--target: ["player", "context"]
    local forbidden_admin_mods = {
        ["fadmin"] = true --no return command for fadmin
    }

    if rank_access_check() and not forbidden_admin_mods[get_admin_mod()] then return true end --allow
    return false --prevent to be visible
end)


--Freeze command
category:AddButton("action_freeze")
:SetIcon(escore2:GetMaterial("freeze.png"))
:SetFunc(function(self, target, button_panel)
    local admin_mod = get_admin_mod()

    if admin_mod == "sam" then
        RunConsoleCommand("sam", "freeze", target:SteamID64())
    elseif admin_mod == "ulx" then
        RunConsoleCommand("ulx", "freeze", target:Nick())
    elseif admin_mod == "fadmin" then
        RunConsoleCommand("fadmin", "freeze", target:Nick())
    elseif admin_mod == "sadmin" then
        RunConsoleCommand("sa", "freeze", target:SteamID64())
    end
end)
:SetCheckFunc(function(self, target, ply)--target: ["player", "context"]
    if rank_access_check() then return true end --allow
    return false --prevent to be visible
end)


--Unfreeze command
category:AddButton("action_unfreeze")
:SetIcon(escore2:GetMaterial("unfreeze.png"))
:SetFunc(function(self, target, button_panel)
    local admin_mod = get_admin_mod()

    if admin_mod == "sam" then
        RunConsoleCommand("sam", "unfreeze", target:SteamID64())
    elseif admin_mod == "ulx" then
        RunConsoleCommand("ulx", "unfreeze", target:Nick())
    elseif admin_mod == "fadmin" then
        RunConsoleCommand("fadmin", "unfreeze", target:Nick())
    elseif admin_mod == "sadmin" then
        RunConsoleCommand("sa", "unfreeze", target:SteamID64())
    end
end)
:SetCheckFunc(function(self, target, ply)--target: ["player", "context"]
    if rank_access_check() then return true end --allow
    return false --prevent to be visible
end)
    

--Kick button
category:AddButton("action_kick")
:SetIcon(escore2:GetMaterial("kick.png"))
:SetFunc(function(self, target, button_panel)
    local admin_mod = get_admin_mod()

    esclib:TextInputWindow(escore2.addon:Translate("enter_reason"), "", false, false, function(reason)
        if admin_mod == "sam" then
            RunConsoleCommand("sam", "kick", target:SteamID64(), reason)
        elseif admin_mod == "ulx" then
            RunConsoleCommand("ulx", "kick", target:Nick(), reason)
        elseif admin_mod == "fadmin" then
            RunConsoleCommand("fadmin", "kick", target:Nick(), reason)
        elseif admin_mod == "sadmin" then
            RunConsoleCommand("sa", "kick", target:SteamID64(), reason)
        end
    end, nil, escore2.addon:GetLanguage())
end)
:SetCheckFunc(function(self, target, ply)--target: ["player", "context"]
    if rank_access_check() then return true end --allow
    return false --prevent to be visible
end)


--Ban button
category:AddButton("action_ban")
:SetIcon(escore2:GetMaterial("ban.png"))
:SetFunc(function(self, target, button_panel)
    local admin_mod = get_admin_mod()

    esclib:TextInputWindow(escore2.addon:Translate("enter_duration"), "", false, false, function(duration)
        if not duration or duration == "" then return end

        esclib:TextInputWindow(escore2.addon:Translate("enter_reason"), "", false, false, function(reason)
            if not reason or reason == "" then return end

            if admin_mod == "sam" then
                RunConsoleCommand("sam", "ban", target:SteamID64(), duration, reason)
            elseif admin_mod == "ulx" then
                RunConsoleCommand("ulx", "ban", target:Nick(), duration, reason)
            elseif admin_mod == "fadmin" then
                RunConsoleCommand("fadmin", "ban", target:Nick(), duration, reason)
            elseif admin_mod == "sadmin" then
                RunConsoleCommand("sa", "ban", target:SteamID64(), duration, reason)
            end
        end, nil, escore2.addon:GetLanguage())

    end, nil, escore2.addon:GetLanguage())
end)
:SetCheckFunc(function(self, target, ply)--target: ["player", "context"]
    if rank_access_check() then return true end --allow
    return false --prevent to be visible
end)


--FSpectate
category:AddButton("action_spectate")
:SetIcon(escore2:GetMaterial("ghost.png"))
:SetFunc(function(self, target, button_panel)
    RunConsoleCommand("FSpectate", target:Nick())
end)   
:SetCheckFunc(function(self, target, ply)--target: ["player", "context"]
    if rank_access_check() and FSpectate ~= nil then return true end --allow
    return false --prevent to be visible
end)
    








if IsValid(escore2.bg) then --lua refresh
    escore2:Build()
end