local floor, clamp, ceil, round, max = math.floor, math.Clamp, math.ceil, math.Round, math.max
local GetLang = LANG and LANG.GetUnsafeLanguageTable or nil

------------------------
--# SHARED FUNCTIONS #--
------------------------
function round_decimals(num, num_decimal_places)
    local mult = 10^(num_decimal_places or 0)
    return floor(num * mult + 0.5) / mult
end

--Get lighter color by amount
local function lighter(clr, amount)
    amount = amount or 50
    clr.r = clamp(clr.r+amount, 0, 255)
    clr.g = clamp(clr.g+amount, 0, 255)
    clr.b = clamp(clr.b+amount, 0, 255)
end

local function default_sort(v1, v2, inverse)
    if inverse then
        return v1 > v2
    else
        return v1 < v2
    end
end

local function default_custom_check(self)
    return true
end

local function darkrp_custom_check(self)
    return DarkRP ~= nil
end

local function basewars_custom_check(self)
    return BaseWars ~= nil
end

local function shared_topbar_func(self, pnl)
    local clr = escore2.addon:GetColors()
    local font = pnl:GetFont()
    local text = self.column_name and escore2.addon:Translate(self.column_name) or ""

    local function getArrow()
        if escore2.sort_column == self.name then
            if self.inversed_sort then
                return escore2.sort_order == "ascending" and " [↑]" or " [↓]"
            else
                return escore2.sort_order == "ascending" and " [↓]" or " [↑]"
            end
        end
        return ""
    end

    if text == "" then
        local hint_pnl = pnl:eAddHint(escore2.addon:Translate(pnl.name))
        hint_pnl:SetTextColor(clr.main.text)
        hint_pnl:SetColor(color_transparent)
        hint_pnl:SetAccentColor(color_transparent)
    end


    local shadow_clr = Color(0,0,0, 100)
    local icon = self.icon
    pnl.Paint = function(self,w,h)
        local hovered = self:IsHovered()
        local arrow = getArrow()
        local hw = w*0.5
        local hh = h*0.5
        
        local full_text = text .. arrow
        if text ~= "" then
            esclib.draw:ShadowText(full_text, font, hw, hh, hovered and clr.main.text_hover or clr.main.text, TEXT_ALIGN_CENTER, TEXT_ALIGN_CENTER, 1)
        end

        if icon then
            local icon_size = h*0.25
            if text ~= "" then
                local tw, th = esclib.util:TextSize(full_text, font)
                esclib.draw:MaterialCenteredShadowed(hw - tw*0.5 - icon_size - 7, hh+1, icon_size, hovered and clr.main.text_hover or clr.main.icon, icon, 1, shadow_clr)
            else
                esclib.draw:MaterialCenteredShadowed(hw, hh+1, icon_size, hovered and clr.main.text_hover or clr.main.icon, icon, 1, shadow_clr)
                esclib.draw:ShadowText(arrow, font, hw + icon_size*2 + 5, hh, hovered and clr.main.text_hover or clr.main.text, TEXT_ALIGN_CENTER, TEXT_ALIGN_CENTER, 1)
            end
        end
    end
end

local function UpdateIf(self, condition)
    if escore2.sort_column == self.name and condition then
        escore2:SortPanels(self.name)
    end
end







----------------
--# NICKNAME #--
----------------
local column = escore2:NewColumn("col_nickname")
column:SetFixedWide(0.28)
column:SetInitTopbarFunc(shared_topbar_func)
column:SetCustomCheckFunc(default_custom_check)
column:SetIcon(escore2:GetMaterial("user.png"))

column:SetInitPlayerbarFunc(function(self, pnl, main_pnl)
    local clr = escore2.addon:GetColors()
    local l_ply = LocalPlayer()
    local ply = main_pnl:GetPlayer()
    local dock_margin = floor(pnl:GetTall()*0.12)

    local is_me = l_ply == ply
    local is_friend = ply:GetFriendStatus() == "friend"

    local avatar = pnl:Add("esclib.circle_avatar")
    avatar:SetSize(main_pnl:GetTall()-dock_margin*2, main_pnl:GetTall()-dock_margin*2)
    avatar:SetPlayer(ply, 128)
    avatar:DockMargin(dock_margin,dock_margin,dock_margin,dock_margin)
    avatar:Dock(LEFT)

    local nickname_pnl = pnl:Add("DPanel")
    nickname_pnl:Dock(FILL)

    local next_draw = 0
    local val = ""
    local you_format = escore2.addon:Translate("you_format") or "%s"
    local friend_format = escore2.addon:Translate("friend_format") or "%s"
    nickname_pnl.Paint = function(_, w,h)

        if next_draw < RealTime() then
            val = ply:Nick()
            next_draw = RealTime()+1
        end
        
        -- grad_text:Draw(5,h*0.5-1, TEXT_ALIGN_LEFT, TEXT_ALIGN_CENTER)
        local text_clr = clr.player.text
        local text = val
        if is_me then
            text_clr = clr.player.me
            text = string.format(you_format, text)
        elseif is_friend then
            text_clr = clr.player.friend
            text = string.format(friend_format, text)
        end
        draw.SimpleText(text, pnl:GetFont(), 5 ,h*0.5-1, text_clr, TEXT_ALIGN_LEFT, TEXT_ALIGN_CENTER)
    end
end)

column:SetInversedSort(true)
column:SetSortFunc(function(ply1, ply2, inverse)
    if escore2.search_text ~= "" then
        --levenshtein distance
        local d1 = esclib.text.distance(escore2.search_text, ply1:Nick())
        local d2 = esclib.text.distance(escore2.search_text, ply2:Nick())
        if d1 ~= d2 then
            return default_sort(d1, d2, true)
        end
    end
    if esclib:IsTTT() then
        local category1 = GetJobValue(ply1) or ""
        local category2 = GetJobValue(ply2) or ""
        if category1 ~= category2 then
            return default_sort(category1, category2, not inverse)
        end
        local category1 = is_founded_dead_or_spec(ply1) and 1 or 2
        local category2 = is_founded_dead_or_spec(ply2) and 1 or 2
        if category1 ~= category2 then
            return default_sort(category1, category2, not inverse)
        end
    elseif BaseWars then -- toujours trier par faction si BaseWars
        local faction1 = GetFactionValue(ply1)
        local faction2 = GetFactionValue(ply2)
        if faction1 ~= faction2 then
            return default_sort(faction1, faction2, not inverse)
        end
    elseif DarkRP then
        local category1 = "1"
        local category2 = "2"
        if DarkRP ~= nil then
            category1 = ply1:getJobTable()["category"]
            category2 = ply2:getJobTable()["category"]
        end
        if category1 ~= category2 then
            return default_sort(category1, category2, not inverse)
        end
        local job1 = GetJobValue(ply1) or "1"
        local job2 = GetJobValue(ply2) or "2"
        if job1 ~= job2 then
            return default_sort(job1, job2, not inverse)
        end
    end
    local nick1 = ply1:Nick() or "1"
    local nick2 = ply2:Nick() or "2"
    if nick1 ~= nick2 then
        return default_sort(nick1, nick2, not inverse)
    end
    return default_sort(ply1:SteamID64(), ply2:SteamID64(), not inverse)
end)

--------------------------
--# FACTIONS COLUMN #--
--------------------------
local column = escore2:NewColumn("col_job")
if CLIENT and esclib:IsTTT() then column:SetName("col_role") end
column:SetInitTopbarFunc(shared_topbar_func)
column:SetCustomCheckFunc(default_custom_check)
column:SetIcon(escore2:GetMaterial("job.png"))

local function ttt_isbody_found(ply)
    return ply:GetNWBool("body_found", false)
end

--if player dead and body is found or player not dead and he is spectator
local function is_founded_dead_or_spec(ply)
    return (ply:IsDeadTerror() and ttt_isbody_found(ply)) or (not ply:IsDeadTerror() and ply:IsSpec())
end

-- Add the missing GetFactionValue function
function GetFactionValue(ply)
    if not BaseWars or not ply.GetFaction then return "" end
    local faction = ply:GetFaction()
    if not faction then return "" end
    if isstring(faction) then return faction end
    if faction.name then return faction.name end
    if faction.Name then return faction.Name end
    if faction.GetName then return faction:GetName() end
    if ply.GetFactionName then return ply:GetFactionName() end
    return ""
end

local function GetJobValue(ply)
    if esclib:IsTTT() then
        local L = GetLang()
        if (ply:IsDeadTerror() and ttt_isbody_found(ply)) then
            local role = ply:GetRoleStringRaw()
            return role and L[role]
        elseif (not ply:IsDeadTerror() and ply:IsSpec()) then
            return L["spectators"] or "n/a"
        else
            local role = ply:GetRoleStringRaw()
            return role and L[role]
        end
    elseif BaseWars then
        -- Affiche la faction si elle existe, sinon le job
        local faction = GetFactionValue(ply)
        if faction and faction ~= "" then
            return faction
        end
    end
    if DarkRP ~= nil then
        return ply:getDarkRPVar("job")
    else
        return "?"
    end
end

local role_colors = {
    traitor = Color(255, 45, 45, 255),
    innocent = Color(45, 255, 45, 255),
    detective = Color(93, 93, 255),
    dead = Color(100,100,100)
};

column:SetInitPlayerbarFunc(function(self, pnl, main_pnl)
    local ply = main_pnl:GetPlayer()

    local next_draw = 0
    local job = GetJobValue(ply)
    local jobcolor = team.GetColor(ply:Team()) or main_pnl.clr.player.text
    pnl.Paint = function(pnl, w,h)

        if next_draw < RealTime() then
            local newjob = GetJobValue(ply)
            UpdateIf(self, job ~= newjob)
            job = newjob

            if esclib:IsTTT() then
                jobcolor = role_colors.innocent
                --if player dead and body is found or player not dead and he is spectator
                if (is_founded_dead_or_spec(ply)) then
                    jobcolor = role_colors.dead
                elseif ply:GetTraitor() then
                    jobcolor = role_colors.traitor
                elseif ply:GetDetective() then
                    jobcolor = role_colors.detective
                end
            else
                jobcolor = team.GetColor(ply:Team()) or main_pnl.clr.player.text
                lighter(jobcolor)
            end

            next_draw = RealTime()+1
        end

        if job then
            local display_text = job
            -- Add leader marker for BaseWars
            if BaseWars and ply.IsFactionLeader and ply:IsFactionLeader() then
                display_text = job .. " (Leader)"
            end
            esclib.draw:ShadowText(display_text, main_pnl.font, w*0.5, h*0.5, jobcolor, TEXT_ALIGN_CENTER, TEXT_ALIGN_CENTER)
        end
    end
end)

column:SetInversedSort(true)
column:SetSortFunc(function(ply1,ply2, inverse)
    if escore2.search_text ~= "" then
        --levenshtein distance
        local d1 = esclib.text.distance(escore2.search_text, ply1:Nick())
        local d2 = esclib.text.distance(escore2.search_text, ply2:Nick())

        if d1 ~= d2 then
            return default_sort(d1, d2, true)
        end
    end

    if esclib:IsTTT() then
        local category1 = GetJobValue(ply1) or ""
        local category2 = GetJobValue(ply2) or ""
        if category1 ~= category2 then
            return default_sort(category1, category2, not inverse)
        end

        --alive sort
        local category1 = is_founded_dead_or_spec(ply1) and 1 or 2
        local category2 = is_founded_dead_or_spec(ply2) and 1 or 2

        if category1 ~= category2 then
            return default_sort(category1, category2, not inverse)
        end
    elseif BaseWars and escore2.addon:GetVar("merge_jobs") then
        -- Sort by faction for BaseWars
        local faction1 = GetFactionValue(ply1)
        local faction2 = GetFactionValue(ply2)
        
        if faction1 ~= faction2 then
            return default_sort(faction1, faction2, not inverse)
        end
    elseif DarkRP then
        local category1 = "1"
        local category2 = "2"
        if DarkRP ~= nil then
            category1 = ply1:getJobTable()["category"]
            category2 = ply2:getJobTable()["category"]
        end

        if category1 ~= category2 then
            return default_sort(category1, category2, not inverse)
        end

        local job1 = GetJobValue(ply1) or "1"
        local job2 = GetJobValue(ply2) or "2"

        if job1 ~= job2 then
            return default_sort(job1, job2, not inverse)
        end
    end

    local nick1 = ply1:Nick() or "1"
    local nick2 = ply2:Nick() or "2"

    if nick1 ~= nick2 then
        return default_sort(nick1, nick2, not inverse)
    end

    return default_sort(ply1:SteamID64(), ply2:SteamID64(), not inverse) --we need to be stable there 
end)

column:SetCategoryNameFunc(function(ply)
    if not IsValid(ply) then return end
    
    if esclib:IsTTT() then
        return GetJobValue(ply) or "n/a"
    elseif BaseWars and escore2.addon:GetVar("merge_jobs") then
        return GetFactionValue(ply)
    elseif DarkRP ~= nil then
        if escore2.addon:GetVar("merge_jobs") then
            local job_table = (ply.getJobTable and ply:getJobTable()) or {}
            return job_table["category"] or ""
        else
            return GetJobValue(ply) or ""
        end
    end
end)

local category_colors = {}
if DarkRP then
    for k,v in ipairs(DarkRP.getCategories().jobs) do
        local clr = v["color"]
        if clr then
            clr = table.Copy(clr)
            lighter(clr, 120)
            category_colors[v["name"]] = clr
        end
    end
end

column:SetInitCategoryFunc(function(self, panel)
    local ply = panel:GetPlayer()
    local skin_clr = escore2.addon:GetColors()
    if escore2.addon:GetVar("merge_jobs") then
        local clr = category_colors[panel:GetText()]

        if esclib:IsTTT() then
            clr = role_colors.innocent
            if is_founded_dead_or_spec(ply) then
                clr = role_colors.dead
            elseif ply:GetTraitor() then
                clr = role_colors.traitor
            elseif ply:GetDetective() then
                clr = role_colors.detective
            end
        end

        if clr then 
            panel:SetColor(clr)
            panel:SetIconColor(clr)
        end
    else
        if not IsValid(ply) then return end

        local clr = skin_clr.player.text
        if esclib:IsTTT() then
            clr = role_colors.innocent
            if is_founded_dead_or_spec(ply) then
                clr = role_colors.dead
            elseif ply:GetTraitor() then
                clr = role_colors.traitor
            elseif ply:GetDetective() then
                clr = role_colors.detective
            end
        else
            clr = team.GetColor(ply:Team()) or skin_clr.player.text
            lighter(clr, 120)
        end

        panel:SetColor(clr)
        panel:SetIconColor(clr)
    end
    panel:SetIcon(self.icon)
end)

------------------------
--# USERGROUP COLUMN #--
------------------------
local column = escore2:NewColumn("col_rank")
column:SetInitTopbarFunc(shared_topbar_func)
column:SetCustomCheckFunc(default_custom_check)
column:SetIcon(escore2:GetMaterial("star.png"))

column:SetInitPlayerbarFunc(function(self, pnl, main_pnl)
    local ply = main_pnl:GetPlayer()
    local clr = main_pnl.clr.player.text

    local ug_settings = escore2.addon:GetVar("rank_form")
    local tags_by_sid64 = escore2.tags_sid64 or {}

    local next_draw = 0
    local group = ""
    local font = main_pnl.font

    local group_gradient = esclib.draw:GradientText(group, font, color_white, color_white)
    local radial_mat = esclib:GetMaterial("radial_gradient.png")
    local radial_color = false
    pnl.Paint = function(pnl, w,h)

        if next_draw < RealTime() then
            local new_group = ply:GetUserGroup()
            UpdateIf(self, group ~= new_group)
            group = new_group

            local steam64 = ply:SteamID64()
            local group_set = ug_settings[group]
            local tag_set = tags_by_sid64[steam64]
            if tag_set then
                group_set = tag_set
            end
            if group_set then

                if group_set["rank_draw"] == false then return end

                local col1 = group_set["rank_color1"] or color_white
                local col2 = group_set["rank_color2"] or color_white

                group_gradient = esclib.draw:GradientText(
                    group_set["rank_name"] or group,
                    font, 
                    col1, 
                    col2
                )

                if group_set["rank_glow"] then
                    radial_color = esclib.util:ColorMean(col1, col2)
                    radial_color.a = 20
                end
            else
                group_gradient = esclib.draw:GradientText(
                    group,
                    font, 
                    color_white, 
                    color_white
                )
            end

            next_draw = RealTime()+3 --every 3 seconds
        end
        
        group_gradient:Draw(w*0.5, h*0.5, TEXT_ALIGN_CENTER, TEXT_ALIGN_CENTER)

        if radial_color then
            local tw = group_gradient.info.text_w
            esclib.draw:Material(w*0.5 - tw,-4,tw*2,h+10,radial_color,radial_mat)
        end
    end
end)

column:SetSortFunc(function(ply1,ply2, inverse)
    local v1 = ply1:GetUserGroup() or ""
    local v2 = ply2:GetUserGroup() or ""

    if v1 == v2 then
        return default_sort(ply1:SteamID64(), ply2:SteamID64(), inverse) --we need to be stable there 
    else
        return default_sort(v1, v2, inverse)
    end
end)

column:SetCategoryNameFunc(function(ply)
    return ply:GetUserGroup() or "user"
end)

column:SetInitCategoryFunc(function(self, panel)
    panel:SetIcon(self.icon)
end)


--------------------
--# DARKRP MONEY #--
--------------------
local column = escore2:NewColumn("col_darkrpmoney")
column:SetInitTopbarFunc(shared_topbar_func)
column:SetCustomCheckFunc(darkrp_custom_check)
column:SetIcon(escore2:GetMaterial("money.png"))

column:SetInitPlayerbarFunc(function(self, pnl, main_pnl)
    local ply = main_pnl:GetPlayer()
    local clr = main_pnl.clr.player.text
    local next_draw = 0
    local val = 0
    pnl.Paint = function(pnl, w,h)
        if next_draw < RealTime() then
            local new_val = ply:getDarkRPVar("money") or 0
            UpdateIf(self, val ~= new_val)
            val = new_val
            next_draw = RealTime()+1
        end

        local text = val
        if val >= 1000000000 then
            text = string.format(escore2.addon:Translate("money_format_b"), round_decimals(val/1000000000, 1))
        elseif val >= 1000000 then
            text = string.format(escore2.addon:Translate("money_format_m"), round_decimals(val/1000000, 1))
        elseif val >= 10000 then
            text = string.format(escore2.addon:Translate("money_format_k"), round_decimals(val/1000, 1))
        end

        draw.SimpleText(text, main_pnl.font, w*0.5, h*0.5, clr, TEXT_ALIGN_CENTER, TEXT_ALIGN_CENTER)
    end
end)
column:SetSortFunc(function(ply1,ply2, inverse)
    local v1 = ply1:getDarkRPVar("money") or 0
    local v2 = ply2:getDarkRPVar("money") or 0
    return default_sort(v1, v2, inverse)
end)

-----------------
--# PRESTIGE #--
-----------------
local column = escore2:NewColumn("col_prestige")
column:SetInitTopbarFunc(shared_topbar_func)
column:SetCustomCheckFunc(basewars_custom_check)
column:SetIcon(escore2:GetMaterial("star.png"))

column:SetInitPlayerbarFunc(function(self, pnl, main_pnl)
    local ply = main_pnl:GetPlayer()
    local clr = main_pnl.clr.player.text
    local next_draw = 0
    local val = 0
    pnl.Paint = function(pnl, w,h)
        if next_draw < RealTime() then
            local new_val = 0
            if ply.GetPrestige then
                new_val = ply:GetPrestige() or 0
            end
            UpdateIf(self, val ~= new_val)
            val = new_val
            next_draw = RealTime()+1
        end
        draw.SimpleText(val, main_pnl.font, w*0.5, h*0.5, clr, TEXT_ALIGN_CENTER, TEXT_ALIGN_CENTER)
    end
end)

column:SetSortFunc(function(ply1,ply2, inverse)
    local v1 = 0
    local v2 = 0
    if ply1.GetPrestige then v1 = ply1:GetPrestige() or 0 end
    if ply2.GetPrestige then v2 = ply2:GetPrestige() or 0 end
    return default_sort(v1, v2, inverse)
end)

---------------
--# FRAGS #--
---------------
local column = escore2:NewColumn("col_frags")
column:SetInitTopbarFunc(shared_topbar_func)
column:SetCustomCheckFunc(default_custom_check)
column:SetIcon(escore2:GetMaterial("kill.png"))

column:SetInitPlayerbarFunc(function(self, pnl, main_pnl)
    local ply = main_pnl:GetPlayer()
    local clr = main_pnl.clr.player.text
    local next_draw = 0
    local val = 0
    pnl.Paint = function(pnl, w,h)
        if next_draw < RealTime() then
            local new_val = ply:Frags()
            UpdateIf(self, val ~= new_val)
            val = new_val
            next_draw = RealTime()+1
        end
        draw.SimpleText(val, main_pnl.font, w*0.5, h*0.5, clr, TEXT_ALIGN_CENTER, TEXT_ALIGN_CENTER)
    end
end)
column:SetSortFunc(function(ply1,ply2, inverse)
    local v1 = ply1:Frags()
    local v2 = ply2:Frags()
    return default_sort(v1, v2, inverse)
end)

----------------
--# DEATHS #--
----------------
local column = escore2:NewColumn("col_deaths")
column:SetInitTopbarFunc(shared_topbar_func)
column:SetCustomCheckFunc(default_custom_check)
column:SetIcon(escore2:GetMaterial("skull.png"))

column:SetInitPlayerbarFunc(function(self, pnl, main_pnl)
    local ply = main_pnl:GetPlayer()
    local clr = main_pnl.clr.player.text
    local next_draw = 0
    local val = 0
    pnl.Paint = function(pnl, w,h)
        if next_draw < RealTime() then
            local new_val = ply:Deaths()
            UpdateIf(self, val ~= new_val)
            val = new_val
            next_draw = RealTime()+1
        end
        draw.SimpleText(val, main_pnl.font, w*0.5, h*0.5, clr, TEXT_ALIGN_CENTER, TEXT_ALIGN_CENTER)
    end
end)
column:SetSortFunc(function(ply1,ply2, inverse)
    local v1 = ply1:Deaths()
    local v2 = ply2:Deaths()
    return default_sort(v1, v2, inverse)
end)

--------------
--# TIME #--
--------------
local column = escore2:NewColumn("col_time")
column:SetInitTopbarFunc(shared_topbar_func)
column:SetCustomCheckFunc(default_custom_check)
column:SetIcon(escore2:GetMaterial("time.png"))

local function GetTimeValue(ply)
    if UTime then
        return UTime.GetTime(ply:SteamID()) or 0
    elseif sam and sam.player and sam.player.get_player_data then
        local data = sam.player.get_player_data(ply:SteamID(), "playtime")
        return data or 0
    else
        return 0
    end
end

column:SetInitPlayerbarFunc(function(self, pnl, main_pnl)
    local ply = main_pnl:GetPlayer()
    local clr = main_pnl.clr.player.time
    local next_draw = 0
    local val = 0
    pnl.Paint = function(pnl, w,h)
        if next_draw < RealTime() then
            local new_val = GetTimeValue(ply)
            UpdateIf(self, val ~= new_val)
            val = new_val
            next_draw = RealTime()+5
        end
        
        local text = string.FormattedTime(val, "%02i:%02i:%02i")
        draw.SimpleText(text, main_pnl.font, w*0.5, h*0.5, clr, TEXT_ALIGN_CENTER, TEXT_ALIGN_CENTER)
    end
end)
column:SetSortFunc(function(ply1,ply2, inverse)
    local v1 = GetTimeValue(ply1)
    local v2 = GetTimeValue(ply2)
    return default_sort(v1, v2, inverse)
end)

---------------
--# LEVEL #--
---------------
local column = escore2:NewColumn("col_level")
column:SetInitTopbarFunc(shared_topbar_func)
column:SetCustomCheckFunc(basewars_custom_check)
column:SetIcon(escore2:GetMaterial("level.png"))

column:SetInitPlayerbarFunc(function(self, pnl, main_pnl)
    local ply = main_pnl:GetPlayer()
    local clr = main_pnl.clr.player.text
    local next_draw = 0
    local val = 0
    pnl.Paint = function(pnl, w,h)
        if next_draw < RealTime() then
            local new_val = 0
            if ply.GetLevel then
                new_val = ply:GetLevel() or 0
            end
            UpdateIf(self, val ~= new_val)
            val = new_val
            next_draw = RealTime()+1
        end
        draw.SimpleText(val, main_pnl.font, w*0.5, h*0.5, clr, TEXT_ALIGN_CENTER, TEXT_ALIGN_CENTER)
    end
end)
column:SetSortFunc(function(ply1,ply2, inverse)
    local v1 = 0
    local v2 = 0
    if ply1.GetLevel then v1 = ply1:GetLevel() or 0 end
    if ply2.GetLevel then v2 = ply2:GetLevel() or 0 end
    return default_sort(v1, v2, inverse)
end)

-----------------
--# TTT KARMA #--
-----------------
local column = escore2:NewColumn("col_ttt_karma")
column:SetInitTopbarFunc(shared_topbar_func)
column:SetCustomCheckFunc(function() return esclib:IsTTT() end)
column:SetIcon(escore2:GetMaterial("karma.png"))

column:SetInitPlayerbarFunc(function(self, pnl, main_pnl)
    local ply = main_pnl:GetPlayer()
    local clr = main_pnl.clr.player.text
    local next_draw = 0
    local val = 0
    pnl.Paint = function(pnl, w,h)
        if next_draw < RealTime() then
            local new_val = ply:GetBaseKarma() or 0
            UpdateIf(self, val ~= new_val)
            val = new_val
            next_draw = RealTime()+1
        end
        draw.SimpleText(floor(val), main_pnl.font, w*0.5, h*0.5, clr, TEXT_ALIGN_CENTER, TEXT_ALIGN_CENTER)
    end
end)
column:SetSortFunc(function(ply1,ply2, inverse)
    local v1 = ply1:GetBaseKarma() or 0
    local v2 = ply2:GetBaseKarma() or 0
    return default_sort(v1, v2, inverse)
end)

------------
--# PING #--
------------
local column = escore2:NewColumn("col_buttons")
column:SetFixedWide(0.08)
column:SetCustomCheckFunc(default_custom_check)

column:SetInitTopbarFunc(function(self, pnl)
    local clr = escore2.addon:GetColors()
    pnl:SetMouseInputEnabled(false)
    pnl.Paint = nil
end)

column:SetInitPlayerbarFunc(function(self, pnl, main_pnl)
    local ply = main_pnl:GetPlayer()
    local clr = escore2.addon:GetColors()
    local font = esclib:AdaptiveFont("escore2", 20, 500)

    local next_draw = 0
    local ping = 0
    local postfix = escore2.addon:Translate("ping_postfix")
    local tw, th = 0, 0

    local bar_w = pnl:GetTall()*0.1
    local bar_h = ceil(pnl:GetTall()*0.3)
    local bar_gap = ceil(pnl:GetTall()*0.03)

    local bar_bg = clr.ping.bg
    local ping_ok = clr.ping.good
    local ping_medium = clr.ping.medium
    local ping_bad = clr.ping.bad
    local text_col = clr.ping.text

    local get_ping_col = function()
        local clr = ping_ok
        if ping <= 50 then
            clr = ping_ok
        elseif ping <= 100 then
            clr = ping_medium
        else
            clr = ping_bad
        end
        return clr
    end

    pnl.Paint = function(s, w,h)
        if next_draw < RealTime() then
            local new_ping = ply:Ping()
            UpdateIf(self, ping ~= new_ping)
            ping = new_ping

            tw, th = esclib.util:TextSize(ping..postfix, font)
            next_draw = RealTime()+1
        end

        local clr = get_ping_col()

        draw.SimpleText(ping..postfix, font, w-5, h*0.5, text_col, TEXT_ALIGN_RIGHT, TEXT_ALIGN_CENTER)


        local x = w - tw - 10 - bar_w-bar_gap
        local y = h-(h-bar_h)*0.5+2

        local clr = get_ping_col()
        
        draw.RoundedBox(0,x,y-bar_h, bar_w, bar_h, ping <= 50 and clr or bar_bg)
        x = ceil(x-bar_w-bar_gap)

        draw.RoundedBox(0,x,y-ceil(bar_h*0.6), bar_w, ceil(bar_h*0.6), ping <= 100 and clr or bar_bg)
        x = ceil(x-bar_w-bar_gap)

        draw.RoundedBox(0,x,y-ceil(bar_h*0.3), bar_w, ceil(bar_h*0.3), ping <= 1000 and clr or bar_bg)
        x = ceil(x-bar_w-bar_gap)
    end
end)


if IsValid(escore2.bg) then --lua refresh
    escore2:Build()
end