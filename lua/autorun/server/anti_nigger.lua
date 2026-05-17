local CheckTime = 1
local PropLimit = 2
local function Not10Times()
    local props = ents.FindByClass("prop_physics")
    local info = {}

    for k , v in pairs(props) do
        local thevec = Vector(math.Round(v:GetPos().x,0),math.Round(v:GetPos().y,0),math.Round(v:GetPos().z,0))
        info[#info+1] = {thevec,v}
    end

    local tables = {}
    for k , v in pairs(info) do
        local vec = tostring(v[1])
        local ent = v[2]
        if tables[vec] then
            table.insert(tables[vec], #tables[vec]+1, ent)
        else
            tables[vec] = {ent}
        end
    end

    for k , v in pairs(tables) do
        if #v > PropLimit then
            for i = PropLimit+1 , #v do
                local ent = v[i]
                ent:SetColor(Color(255,0,0))
                ent:SetMaterial("models/wireframe")
                timer.Simple(1, function()
                    if IsValid(ent) then
                        if ent:CPPIGetOwner() then
                            local owner , _ = ent:CPPIGetOwner()
                            owner:SendLua([[notification.AddLegacy( "Vous ne pouvez pas poser de props ici", NOTIFY_ERROR, 10 )]])
                        end
                        ent:Remove()
                    end
                end)
            end
        end
    end
end
timer.Create("Not10Times", CheckTime, 0, Not10Times)