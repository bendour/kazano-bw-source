zwf = zwf or {}
zwf.f = zwf.f or {}

function zwf.f.Flowerpot_GetWaterLevels(Flowerpot)

    local grow_Data = zwf.config.Plants[Flowerpot:GetSeed()].Grow

    -- Calculates the minimum water level we need to have in order to increase the YieldAmount
    local MaxWaterLevel = 0.9 - ((0.35 / 10) * grow_Data.Difficulty)
    MaxWaterLevel = math.Clamp(MaxWaterLevel, 0.6, 0.9)
    MaxWaterLevel = MaxWaterLevel * zwf.config.Flowerpot.Water_Capacity

    -- Calculate the maximal water level allowed
    local MinWaterLevel = 0.1 + (0.35 / 10) * grow_Data.Difficulty

    MinWaterLevel = math.Clamp(MinWaterLevel, 0.1, 0.4)
    MinWaterLevel = MinWaterLevel * zwf.config.Flowerpot.Water_Capacity

    return MinWaterLevel, MaxWaterLevel
end

function zwf.f.Flowerpot_GetMinGrowDuration(Flowerpot)
    local grow_Data = zwf.config.Plants[Flowerpot:GetSeed()]
    if grow_Data == nil then return zwf.config.Growing.min_duration end
    if grow_Data.Grow == nil then return zwf.config.Growing.min_duration end
    if grow_Data.Grow.Min_Duration == nil then return zwf.config.Growing.min_duration end

    return grow_Data.Grow.Min_Duration
end
