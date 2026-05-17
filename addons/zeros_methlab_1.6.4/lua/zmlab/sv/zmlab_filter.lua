if (not SERVER) then return end
zmlab = zmlab or {}
zmlab.f = zmlab.f or {}


function zmlab.f.Filter_Initialize(Filter)
    zmlab.f.Debug("zmlab.f.Filter_Initialize")

    zmlab.f.EntList_Add(Filter)


    Filter.PhysgunDisable = true
    Filter:SetFilterHealth(zmlab.config.Filter.Health)
end

function zmlab.f.Filter_USE(Filter, ply)
    zmlab.f.Debug("zmlab.f.Filter_USE")
    if not zmlab.f.IsOwner(ply, Filter) then return end

    if IsValid(Filter:GetCombinerEnt()) then
        zmlab.f.Combiner_DeattachFilter(Filter:GetCombinerEnt(),Filter,ply)
    end
end


function zmlab.f.Filter_OnRemove(Filter)
    zmlab.f.Debug("zmlab.f.Filter_OnRemove")
    if IsValid(Filter:GetCombinerEnt()) then
        zmlab.f.Combiner_DeattachFilter(Filter:GetCombinerEnt(), Filter, nil)
    end
end

// Gets called when the filter is used
function zmlab.f.Filter_CheckHealth(Filter)
    if (zmlab.config.Filter.Health <= 0) then return end
    zmlab.f.Debug("zmlab.f.Filter_CheckHealth: " .. Filter:GetFilterHealth())

    Filter:SetFilterHealth(Filter:GetFilterHealth() - 1)

    if Filter:GetFilterHealth() <= 0 then
        Filter:Remove()
    end
end
