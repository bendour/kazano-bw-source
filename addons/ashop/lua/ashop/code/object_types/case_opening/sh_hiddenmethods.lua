// I don't want these functions to be global
// This would be bullshit, so I hide them in a file that I can include after

return {
    GetCaseLuck = function(itemList, count)
        local m = 0
        for k, v in ipairs(itemList) do
            m = m + v[2]
        end
    
        local resultTable = {}
        for i = 1, (count or 1) do
            local rand = math.Rand(0, m)
            local count = 0
    
            for k, v in ipairs(itemList) do
                if count <= rand and rand <= (count + v[2]) then
                    table.insert(resultTable, v[1])
                    break
                else
                    count = count + v[2]
                end
            end
        end
    
        return resultTable
    end
}