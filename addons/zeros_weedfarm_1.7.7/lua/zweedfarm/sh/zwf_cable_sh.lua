if CLIENT then return end
zwf = zwf or {}
zwf.f = zwf.f or {}

function zwf.f.MultiConnection_GetFreePosID(outlet)
    local id

    if not IsValid(outlet:GetOutput01()) then
        id = 1
    elseif not IsValid(outlet:GetOutput02()) then
        id = 2
    elseif not IsValid(outlet:GetOutput03()) then
        id = 3
    end

    return id
end
