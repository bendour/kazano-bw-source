// I'm a pretty autorun ! //
ashop = ashop or {
    LoadState = {
        AutorunTrigger = 0,
        CreatedSQLTables = 1,
        EverythingLoaded = 2
    }
}

local function include_dir(dir)
    local files, folders = file.Find(dir .. "*", "LUA")

    for k,v in ipairs(files) do
        local prefix = string.sub(v, 1, 3)
        local file_dir = dir .. v

        if prefix == "sh_" then
            if SERVER then
                AddCSLuaFile(file_dir)
            end
            include(file_dir)
        elseif prefix == "sv_" and SERVER then
            include(file_dir)
        elseif prefix == "cl_" then
            if SERVER then
                AddCSLuaFile(file_dir)
            else
                include(file_dir)
            end
        else
            print("[AShop] Can't include " .. v .. ", wrong prefix")
            continue
        end
    end

    for k, v in ipairs(folders) do
        include_dir(dir .. v .. "/")
    end
end

include_dir("ashop/config/")

if !ashop.Config.Language then
    print("------ AShop ------")
    print("You got a issue with installation, the config file can't be loaded")
    print("Follow these instructions to debug the config file")
    print("Check before this message in your console if there any errors OR paste your config in this file : https://fptje.github.io/glualint-web/")
    print("Most of the time, it's a missing comma or quotation marks")
    print("To prevent any issues, AShop will stop loading")
    print("--------------------")
    return
end

if SERVER then
    AddCSLuaFile("ashop/lang/sh_" .. ashop.Config.Language .. ".lua")
end

ashop.lang = ashop.lang or {}
ashop.lang.l = include("ashop/lang/sh_" .. ashop.Config.Language .. ".lua")
include_dir("ashop/code/")

hook.Run("ashop_load", ashop.LoadState.AutorunTrigger)

ashop.Loaded = true