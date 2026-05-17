local OBJECT_TYPE = {}

OBJECT_TYPE.Name = ashop.L('TauntsClass')
OBJECT_TYPE.DefaultRender = "Accessories"

OBJECT_TYPE.ItemParameters = {
    [2] = {
        name = ashop.L('Taunts_2'),
        type = TYPE_STRING,
    },

    [3] = {
        name = ashop.L('Taunts_3'),
        type = TYPE_BOOL,
    },

    [4] = {
        name = ashop.L('Taunts_4'),
        type = TYPE_STRING
    },

    [5] = {
        name = ashop.L('Taunts_5'),
        type = "FLOAT"
    }
}

OBJECT_TYPE.SlotDefault = 10
OBJECT_TYPE.UniqueIdentifier = "Taunts"

ashop.RegisterObjectType(OBJECT_TYPE)

hook.Add("CalcMainActivity", "ashop_anims", function(ply, vel)
    if ply.ashop_anim then
        seq = ply:LookupSequence( ply.ashop_anim[1] )
        if seq < 1 then return end

        local c = ply:GetCycle()
        if c >= 1 then
            if ply.ashop_anim[3] then
                ply:SetCycle(0)
            else
                if SERVER then
                    net.Start('ashop_selectTaunt')
                        net.WriteEntity(ply)
                        net.WriteBool(false)
                    net.Broadcast()
                    ply.ashop_anim = nil
                end
            end
        else
            if ply.ashop_anim[2] then
                local fr = FrameTime()
                c = c - (fr*(1 - ply.ashop_anim[2]))/ply:SequenceDuration()
                ply:SetCycle(c)
            end
        end

        return -1, seq
    end
end)