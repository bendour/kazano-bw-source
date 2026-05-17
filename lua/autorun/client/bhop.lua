hook.Add("CreateMove", "AutoBunnyHop", function(cmd)
    local player = LocalPlayer()
    
    if player:Alive() and cmd:KeyDown(IN_JUMP) then
        if player:GetMoveType() == MOVETYPE_NOCLIP then
            return
        end
        if not player:IsOnGround() then
            cmd:RemoveKey(IN_JUMP)
        end
    end
end)
