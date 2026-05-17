--[[-------------------------------------------

    Talk Modes - whisper/talk/yell 

    Licensed to 00000000000000000
	Version: 1.1.1

	By: SaturdaysHeroes & Djuk
	Special thanks to CupCakeR

--]]-------------------------------------------
util.AddNetworkString("TalkModes.Notify")
util.AddNetworkString("TalkModes.WelcomeMessage")
util.AddNetworkString("TalkModes.OpenAdminMenu")
util.AddNetworkString("TalkModes.InitMenu")
util.AddNetworkString("TalkModes.AttemptPreview")
util.AddNetworkString("TalkModes.TriggerPreview")
util.AddNetworkString("TalkModes.ChangeMode")
util.AddNetworkString("TalkModes.Config.Network")
util.AddNetworkString("TalkModes.Config.UpdateSetting")
util.AddNetworkString("TalkModes.Config.ResetSettings")

function TalkModes.Server:Notify(pPlayer, strText)
    net.Start("TalkModes.Notify")
        net.WriteString(strText)
    net.Send(pPlayer)
end

-- WriteTable is generally-speaking pretty bad, I know. 
-- This table is relatively small and due to it's structure this is very convenient. 
function TalkModes.Server:NetworkConfig(pPlayer)
    net.Start("TalkModes.Config.Network")
		net.WriteTable(TalkModes.Config.Server)
	net.Send(pPlayer)
end

function TalkModes.Server:InitMenu(pPlayer)
    net.Start("TalkModes.InitMenu")
    net.Send(pPlayer)
end

net.Receive("TalkModes.AttemptPreview", function(_, pPlayer)
    if !TalkModes.Config.AllowedRanks[pPlayer:GetUserGroup()] == true then return end

    local intDistance = net.ReadUInt(12) || 0

    net.Start("TalkModes.TriggerPreview")
        net.WriteUInt(intDistance, 12)
    net.Send(pPlayer)
end)

-- Solution to make my life easier and limit settings to one net. 
-- This also replaces net.WriteTable completely, pepehappy.
-- God, I love reflection. 
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

net.Receive("TalkModes.Config.UpdateSetting", function(_, pPlayer)
    if !TalkModes.Config.AllowedRanks[pPlayer:GetUserGroup()] then return end

    local tblNet = string.Split(net.ReadString(), ":")
    local strTable, strSetting = tblNet[1], tblNet[2]
    local Value = net["Read"..SETTING_TYPES[strSetting]](32)

    TalkModes.Server:UpdateSetting(strTable, strSetting, Value)

    -- Send the updated config to all players.
    for i, v in ipairs(player.GetAll()) do 
        TalkModes.Server:NetworkConfig(v)
    end

    -- If the position is updated then we have to re-create the menu. 
    if strSetting == "Selection Menu Position" then
        for i, v in ipairs(player.GetAll()) do 
            TalkModes.Server:NetworkConfig(v)
            TalkModes.Server:InitMenu(pPlayer)
        end
    end

    TalkModes.Server:Notify(pPlayer, string.format("Setting %s has been successfully saved!", strSetting))
end)

net.Receive("TalkModes.Config.ResetSettings", function(_, pPlayer)
    if !TalkModes.Config.AllowedRanks[pPlayer:GetUserGroup()] then return end

    TalkModes.Server:ResetSettings()
    
    -- Send the updated config to all players.
    for i, v in ipairs(player.GetAll()) do 
        TalkModes.Server:NetworkConfig(v)
    end
    TalkModes.Server:Notify(pPlayer, "All settings have been reset to default values.")
end)

net.Receive("TalkModes.ChangeMode", function(_, pPlayer)
    local strMode = net.ReadString()
    
    pPlayer.ModeCooldown = pPlayer.ModeCooldown || CurTime()
    if pPlayer:GetTalkMode() != strMode && pPlayer.ModeCooldown <= CurTime() && TalkModes:IsValidMode(strMode) then 
        pPlayer:SetTalkMode(strMode)
        if TalkModes.Config:GetSetting("General", "Mode Change Message") then
            TalkModes.Server:Notify(pPlayer, TalkModes.Languages:GetPhrase("Using Mode")..": "..TalkModes.Languages:GetPhrase(strMode))
        end
        pPlayer.ModeCooldown = CurTime() + 0.25
    end
end)