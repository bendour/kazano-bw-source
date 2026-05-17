if CLIENT then return end
zwf = zwf or {}
zwf.f = zwf.f or {}

function zwf.f.RemoveWindEntity()
    local old_Winds = ents.FindByClass("env_wind")

    if old_Winds and table.Count(old_Winds) > 0 then

        print("[    Zeros GrowOP - Wind:    ] Wind Entity found on Map!")

        for k, v in pairs(old_Winds) do
            if IsValid(v) then
                v:Remove()
            end
        end

        print("[    Zeros GrowOP - Wind:    ] Wind Entity removed from Map!")
    else
        print("[    Zeros GrowOP - Wind:    ] No Wind Entity on Map found!")
    end
end

function zwf.f.SpawnWindEntity()

    local wind = ents.Create( "env_wind" )
    wind:SetKeyValue( "targetname", "wind" )
    wind:SetKeyValue( "gustdirchange", zwf.config.Wind.gustdirchange )
    wind:SetKeyValue( "gustduration", zwf.config.Wind.gustduration )
    wind:SetKeyValue( "maxgust", zwf.config.Wind.maxgust )
    wind:SetKeyValue( "mingust", zwf.config.Wind.mingust )
    wind:SetKeyValue( "maxgustdelay", zwf.config.Wind.maxgustdelay )
    wind:SetKeyValue( "mingustdelay", zwf.config.Wind.mingustdelay )
    wind:SetKeyValue( "maxwind", zwf.config.Wind.maxwind )
    wind:SetKeyValue( "minwind", zwf.config.Wind.minwind )

    print("[    Zeros GrowOP - Wind:    ] Created Wind Entity on Map!")
end


concommand.Add("zwf_create_wind", function(ply, cmd, args)
    if zwf.f.IsAdmin(ply) then
        zwf.f.SpawnWindEntity()
    end
end)

concommand.Add("zwf_remove_wind", function(ply, cmd, args)
    if zwf.f.IsAdmin(ply) then
        zwf.f.RemoveWindEntity()
    end
end)

timer.Simple(0,function()
    if zwf.config.Wind.Enabled == true then
        zwf.f.RemoveWindEntity()
        zwf.f.SpawnWindEntity()
    end
end)
