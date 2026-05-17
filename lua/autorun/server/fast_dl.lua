for i,addon in pairs(engine.GetAddons()) do
    if addon.mounted then
        resource.AddWorkshop( addon.wsid )
    end
end