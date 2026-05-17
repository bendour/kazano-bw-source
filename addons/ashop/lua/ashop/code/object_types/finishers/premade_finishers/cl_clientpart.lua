net.Receive('ashop_finisherslowmotion', function()
    local c = CurTime()

    hook.Add( "RenderScreenspaceEffects", "ashop_finisherslowmotion", function()
        local diff = (CurTime() - c)
        if diff > 1 then
            hook.Remove( "RenderScreenspaceEffects", "ashop_finisherslowmotion")
            return
        end

        DrawColorModify({
            [ "$pp_colour_brightness" ] = 0,
            [ "$pp_colour_contrast" ] = 1.2,
            [ "$pp_colour_colour" ] = 1.2,
            [ "$pp_colour_mulb" ] = 5 * (1 - diff),
            [ "$pp_colour_addr" ] = -0.05,
            [ "$pp_colour_addg" ] = -0.05,
            [ "$pp_colour_addb" ] = 1 * (1 - diff),
        })
    end)
end)