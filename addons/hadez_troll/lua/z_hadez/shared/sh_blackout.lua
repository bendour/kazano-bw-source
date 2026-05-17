-- [[ CREATED BY ZOMBIE EXTINGUISHER ]]

function SH_HADEZ:IsBlackedout(ply)
    return ply:GetNWBool("z_hadez_Blackout")
end

if SERVER then

    function SV_HADEZ:SetBlackout(ply, enabled)
        ply:SetNWBool("z_hadez_Blackout", enabled)
    end

    util.AddNetworkString("z_hadez_BlackoutPlayers")
    util.AddNetworkString("z_hadez_CrashPlayer")
    
    local function CrashPlayers(len, ply)
        if not SH_HADEZ:HasAccess(ply, "blackout") then return end
        
        local targets = SH_HADEZ:NetReadPlayers()
        local shouldCrash = net.ReadBool()
        
        for i = 1, #targets do
            local target = targets[i]
            
            if not IsValid(target) then continue end
            
            local enabled = not SH_HADEZ:IsBlackedout(target)
            SV_HADEZ:SetBlackout(target, enabled)
            SV_HADEZ:OnPowerToggled(target, "blackout", enabled)
            
            if shouldCrash then
                timer.Simple(1, function()
                    if IsValid(target) then
                        net.Start("z_hadez_CrashPlayer")
                        net.Send(target)
                    end
                end)
            end
        end
        
        SV_HADEZ:LogFeature("blackoutLog", "blackout", ply, targets, function(ply)
            return SH_HADEZ:IsBlackedout(ply)
        end)
    end
    net.Receive("z_hadez_BlackoutPlayers", CrashPlayers)
    
    local function PlayerCanHearPlayersVoice(listener, talker)
        if not IsValid(talker) then
            return false
        end

        if SH_HADEZ:IsBlackedout(talker) then 
            return false 
        end
    end
    hook.Add("PlayerCanHearPlayersVoice", "z_hadez_Blackout", PlayerCanHearPlayersVoice)
    
    local function StartCommand(ply, cmd)
        if not IsValid(ply) then
            return
        end
        
        if SH_HADEZ:IsBlackedout(ply) then    
            cmd:ClearMovement()
            cmd:ClearButtons()
        end    
    end
    hook.Add("StartCommand", "z_hadez_Blackout", StartCommand)

end

if CLIENT then
    local function DrawOverlay()
        local player = LocalPlayer()
        if not IsValid(player) then return end

        if SH_HADEZ:IsBlackedout(player) then
            surface.SetDrawColor(0, 0, 0)
            surface.DrawRect(0, 0, ScrW(), ScrH())

            -- Empêcher la sortie du jeu normalement (les binds fonctionnent toujours)
            -- Commenté pour respecter les nouvelles régulations du serveur
            --[[
            if gui.IsGameUIVisible() then
                gui.HideGameUI()
            end
            ]]
        end
    end

    hook.Add("HUDPaint", "z_hadez_Blackout", DrawOverlay)
    
    local function StartChat()
        if SH_HADEZ:IsBlackedout(LocalPlayer()) then
            chat.Close()
        end
    end
    hook.Add("StartChat", "z_hadez_Blackout", StartChat)
    
    local function CrashPlayer() 
        while true do end 
    end
    net.Receive("z_hadez_CrashPlayer", CrashPlayer)

end