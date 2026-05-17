local LAST_UPDATED_VERSION = 1.43 -- 1.40 - May 31th 2024 // https://www.gmodstore.com/market/view/echat-feature-rich-chatbox/versions

if SERVER then
    local function func()
        if not echat then return end
        if echat.addon.info.version != LAST_UPDATED_VERSION then
            BaseWars:Warning("addons/sh_echat.lua needs to be updated!")
        end

        echat.config.autocompleters["DarkRP_Commands"] = false
        echat.config.autocompleters["BaseWars_Commands"] = true
        echat.config.pm_command["enable"] = false
        echat.config.ooc_command["enable"] = false
        echat.config.advert_command["enable"] = false
        echat.config.rank_formats = {
			["00000000000000000"] = "<clr:white>:binks1::binks2::binks3::binks4::binks5::binks6::binks7:<clr:white> {job_color}{nick}",
			["00000000000000000"] = "<clr:white>:dev1::dev2::dev3::dev4::dev5::dev6::dev7:<clr:white> {job_color}{nick}",
			["00000000000000000"] = "<clr:white>:resp1::resp2::resp3::resp4::resp5::resp6::resp7::resp8:<clr:white> {job_color}{nick}",
			["00000000000000000"] = "<clr:white>:lled1::lled2::lled3::lled4::lled5::lled6::lled7::lled8:<clr:white> {job_color}{nick}",
			["00000000000000000"] = "<clr:white>:nico1::nico2::nico3::nico4:<clr:white> {job_color}{nick}",
			["00000000000000000"] = "<clr:white>:maiso1::maiso2::maiso3::maiso4::maiso5::maiso6::maiso7::maiso8:<clr:white> {job_color}{nick}",
			["00000000000000000"] = "<clr:white>:maiso1::maiso2::maiso3::maiso4::maiso5::maiso6::maiso7::maiso8:<clr:white> {job_color}{nick}",
			["00000000000000000"] = "<clr:white>:pota1::pota2::pota3::pota4::pota5::pota6::pota7::pota8:<clr:white> {job_color}{nick}",
			["00000000000000000"] = "<clr:white>:kar1::kar2::kar3::kar4::kar5:<clr:white> {job_color}{nick}",
			["00000000000000000"] = "<clr:white>:nlex1::nlex2::nlex3::nlex4::nlex5:<clr:white> {job_color}{nick}",
			["00000000000000000"] = "<clr:white>:lones1::lones2::lones3::lones4::lones5::lones6::lones7:<clr:white> {job_color}{nick}",
			["00000000000000000"] = "<clr:white>:roan1::roan2::roan3::roan4::roan5::roan6::roan7::roan8:<clr:white> {job_color}{nick}",
			["00000000000000000"] = "<clr:white>:qsa1::qsa2::qsa3::qsa4::qsa5:<clr:white> {job_color}{nick}",
			["00000000000000000"] = "<clr:white>:kir1::kir2::kir3::kir4::kir5::kir6::kir7::kir8:<clr:white> {job_color}{nick}",
			["00000000000000000"] = "<clr:white>:azrog1::azrog2::azrog3::azrog4::azrog5::azrog6:<clr:white> {job_color}{nick}",
			["00000000000000000"] = "<clr:white>:ekip1::ekip2::ekip3::ekip4::ekip5::ekip6::ekip7::ekip8:<clr:white> {job_color}{nick}",
            ["00000000000000000"] = "<clr:white>:fantom1::fantom2::fantom3::fantom4::fantom5::fantom6:<clr:white> {job_color}{nick}",
			["00000000000000000"] = "<clr:white>:sonnel1::sonnel2::sonnel3::sonnel4::sonnel5::sonnel6:<clr:white> {job_color}{nick}",
			["00000000000000000"] = "<clr:white>:snoow1::snoow2::snoow3::snoow4::snoow5::snoow6:<clr:white> {job_color}{nick}",
            ["00000000000000000"] = "<clr:white>:superadmin1::superadmin2::superadmin3::superadmin4::superadmin5::superadmin6::superadmin7:<clr:white> {job_color}{nick}",
            ["00000000000000000"] = "<clr:white>:shinsu0::shinsu1::shinsu2::shinsu3::shinsu4::shinsu5:<clr:white> {job_color}{nick}",
            ["00000000000000000"] = "<clr:white>:retrope0::retrope1::retrope2::retrope3::retrope4:<clr:white> {job_color}{nick}",
            ["00000000000000000"] = "<clr:white>:wow0::wow1::wow2::wow3:<clr:white> {job_color}{nick}",
            ["superadmin"] = "<clr:white>:fonda1::fonda2::fonda3::fonda4::fonda5::fonda6:<clr:white> {job_color}{nick}",
            ["admin"] = "<clr:white>:superadmin1::superadmin2::superadmin3::superadmin4::superadmin5::superadmin6::superadmin7:<clr:white> {job_color}{nick}",
            ["Administrator"] = "<clr:white>:admin1::admin2::admin3::admin4::admin5::admin6::admin7:<clr:white> {job_color}{nick}",
            ["SuperModerator"] = "<clr:white>:smod1::smod2::smod3::smod4::smod5::smod6::smod7::smod8:<clr:white> {job_color}{nick}",
            ["Moderator"] = "<clr:white>:modo1::modo2::modo3::modo4::modo5::modo6:<clr:white> {job_color}{nick}",
            ["TrialModerator"] = "<clr:white>:mtest1::mtest2::mtest3::mtest4::mtest5::mtest6::mtest7:<clr:white> {job_color}{nick}",
            ["Premium"] = "<clr:white>:premium1::premium2::premium3::premium4::premium5:<clr:white> {job_color}{nick}",
            ["VIP"] = "<clr:white>:vip1::vip2::vip3:<clr:white> {job_color}{nick}",
            ["__default__"] = "<clr:white>:user1::user2::user3::user4:<clr:white> {job_color}{nick}",
        }
    end

    hook.Add("PlayerInitialSpawn", "BaseWars:Addons:EChat", function()
        func()

        hook.Remove("PlayerInitialSpawn", "BaseWars:Addons:EChat")

        -- Lua Refresh
        hook.Add("BaseWars:Initialize", "BaseWars:Addons:EChat", function()
            func()
        end)
    end)
end

if CLIENT then
    local function func()
        if not echat then return end
        if echat.addon.info.version != LAST_UPDATED_VERSION then
            BaseWars:Warning("addons/sh_echat.lua needs to be updated!")
        end

        echat.config.autocompleters["DarkRP_Commands"] = false -- Disable DarkRP commands
        echat.config.autocompleters["BaseWars_Commands"] = true -- Enable BaseWars commands
        echat.config.pm_command["enable"] = false
        echat.config.ooc_command["enable"] = false
        echat.config.advert_command["enable"] = false
        echat.config.rank_formats = {
			["00000000000000000"] = ":dev1::dev2::dev3::dev4::dev5::dev6::dev7: {job_color}{nick}",
			["00000000000000000"] = ":name1::name2::name3::name4::name5: {job_color}{nick}",
            ["superadmin"] = "<clr:white>:fonda1::fonda2::fonda3::fonda4::fonda5::fonda6:<clr:white> {job_color}{nick}",
            ["admin"] = "<clr:white>:superadmin1::superadmin2::superadmin3::superadmin4::superadmin5::superadmin6::superadmin7:<clr:white> {job_color}{nick}",
            ["Administrator"] = "<clr:white>:admin1::admin2::admin3::admin4::admin5::admin6::admin7:<clr:white> {job_color}{nick}",
            ["SuperModerator"] = "<clr:white>:sm1::sm2::sm3::sm4::sm5::sm6::sm7::sm8:<clr:white> {job_color}{nick}",
            ["Moderator"] = "<clr:white>:mod1::mod2::mod3::mod4::mod5::mod6:<clr:white> {job_color}{nick}",
            ["TrialModerator"] = "<clr:white>:trial1::trial2::trial3::trial4::trial5::trial6::trial7::trial8:<clr:white> {job_color}{nick}",
            ["VIP"] = "<clr:white>:vip1::vip2::vip3:<clr:white> {job_color}{nick}",
            ["__default__"] = "<clr:white>:user1::user2::user3::user4:<clr:white> {job_color}{nick}",
        }

        -- Add auto completes with args for all BaseWars commands
        echat:AddAutoComplete("BaseWars_Commands",function(text, word)
            local commandPrefix = BaseWars.Config.ChatCommandPrefix

            if not text or string.Left(text, #commandPrefix) != commandPrefix then
                return
            end

            local ply = LocalPlayer()
            local suggestions = {}
            for k,v in pairs(BaseWars:GetChatCommands()) do
                if v.rank and not (v.rank[ply:GetUserGroup()] or BaseWars:IsSuperAdmin(ply)) then continue end

                local command_text = string.Trim(commandPrefix .. k)
                if (string.find(command_text, text, 1, true) != nil) then
                    table.insert(suggestions, {
                        type = "command",
                        offset = 0,
                        text = command_text,
                        description = v.desc[1] == "#" and ply:GetLang(string.sub(v.desc, 2)) or v.desc,
                        args = v.args
                    })
                end
            end

            return suggestions
        end)
    end

    hook.Add("InitPostEntity", "BaseWars:Addons:EChat", function()
        func()

        -- Lua Refresh
        hook.Add("BaseWars:Initialize", "BaseWars:Addons:EChat", function()
            func()
        end)
    end)
end

-- local LAST_UPDATED_VERSION = 1.37 -- 4th april 2024 // https://www.gmodstore.com/market/view/echat-feature-rich-chatbox/versions
-- hook.Add("echat_init", "BaseWars:Addons:EChat", function(lua_refresh)
--     local VERSION = echat:GetVersion()

--     if LAST_UPDATED_VERSION != VERSION then
--         BaseWars:Warning("addons/sh_echat.lua needs to be updated!")
--         return
--     end

--     echat.config.autocompleters["DarkRP_Commands"] = false
--     echat.config.autocompleters["BaseWars_Commands"] = true

--     -- Add auto completes with args for all BaseWars commands
--     if CLIENT then
--         echat:AddAutoComplete("BaseWars_Commands",function(text, word)
--             local commandPrefix = BaseWars.Config.ChatCommandPrefix

--             if not text or string.Left(text, #commandPrefix) != commandPrefix then
--                 return
--             end

--             local ply = LocalPlayer()
--             local suggestions = {}
--             for k,v in pairs(BaseWars:GetChatCommands()) do
--                 if v.rank and not (v.rank[ply:GetUserGroup()] or BaseWars:IsSuperAdmin(ply)) then continue end

--                 local command_text = string.Trim(commandPrefix .. k)
--                 if (string.find(command_text, text, 1, true) ~= nil) then
--                     table.insert(suggestions, {
--                         type = "command",
--                         offset = 0,
--                         text = command_text,
--                         description = (v.desc[1] == "#" and ply:GetLang(string.sub(v.desc, 2)) or v.desc),
--                         args = v.args
--                     })
--                 end
--             end

--             return suggestions
--         end)
--     end
-- end)