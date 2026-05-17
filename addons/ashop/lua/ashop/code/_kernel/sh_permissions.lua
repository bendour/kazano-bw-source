function ashop.PermissionCreate(name, minAccess, desc)
    CAMI.RegisterPrivilege({
        Name = name,
        MinAccess = minAccess,
        Description = desc
    })
end