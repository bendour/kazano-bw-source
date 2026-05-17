local t = {
    requireWorkshop = "",
    objectTypes = {{"TitleColor"}},
    items = {}
}

for k, v in pairs(ashop.titles.colors) do
    table.insert(t.items, {
        name = v.name,
        rendering = 1,
        metadata = {color_black, k}
    })
end

ashop.RegisterPremade("Uranium Colors", t)