// Calculate the perfect bits size required
ashop.itemCounter = 0

if ashop.items then
    for k, v in pairs(ashop.items) do
        if k > ashop.itemCounter then
            ashop.itemCounter = k
        end
    end
end

ashop.BitsItem = math.ceil(math.log(ashop.itemCounter, 2))

function ashop.NewItemBitsCounter(n)
    if n > ashop.itemCounter then
        ashop.itemCounter = n
        ashop.BitsItem = math.ceil(math.log(ashop.itemCounter, 2))
    end
end