zwf = zwf or {}
zwf.f = zwf.f or {}

function zwf.f.SpliceLab_CalculateSpliceData(PerfData)

    local WeedIDs = {
        [1] = PerfData.WeedA_ID,
        [2] = PerfData.WeedB_ID
    }

    local p_Time = (PerfData.PerfA_Time + PerfData.PerfB_Time) / 2
    p_Time = math.Round(p_Time)

    local p_Amount = (PerfData.PerfA_Amount + PerfData.PerfB_Amount) / 2
    p_Amount = math.Round(p_Amount)

    local p_THC = (PerfData.PerfA_THC + PerfData.PerfB_THC) / 2
    p_THC = math.Round(p_THC)

    local SpliceData = {
        Weed_ID = WeedIDs[math.random(1, 2)],
        Perf_Time = p_Time,
        Perf_Amount = p_Amount,
        Perf_THC = p_THC
    }
    return SpliceData
end
