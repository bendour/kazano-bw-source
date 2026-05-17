local cfg = escore2.config
local default_columns = {} --layout

local function AddColumn(default_value)
    table.insert(default_columns, default_value)
end

-------------------------
--# GATHERING COLUMNS #--
-------------------------
local columns = {} -- all available columns
local forbid_columns = {
    ["col_buttons"] = true,
}
for _,tbl in ipairs(table.GetKeys(escore2.columns.list)) do
    if not forbid_columns[tbl] then
        table.insert(columns, tbl)
    end
end

---------------------------------------
--# DEFINING DEFAULT COLUMN LAYOUTS #--
---------------------------------------
AddColumn("col_nickname") --who dont need nicknames by default?
local default_sort = "col_nickname" --also this is sort by default

if DarkRP ~= nil then
    AddColumn("col_job")
    AddColumn("col_rank")
    AddColumn("col_darkrpmoney")
    AddColumn("col_frags")
    AddColumn("col_deaths")

    --empty slots
    AddColumn("col_none")
    AddColumn("col_none")
    AddColumn("col_none")

    default_sort = "col_job"
elseif esclib:IsTTT() then --layout by default for TTT
    AddColumn("col_job")
    AddColumn("col_rank")
    AddColumn("col_ttt_karma")
    AddColumn("col_frags")
    AddColumn("col_deaths")

    --empty slots
    AddColumn("col_none")
    AddColumn("col_none")
    AddColumn("col_none")

    default_sort = "col_job"

else --layout by default
    AddColumn("col_rank")
    AddColumn("col_frags")
    AddColumn("col_deaths")

    --empty slots
    AddColumn("col_none")
    AddColumn("col_none")
    AddColumn("col_none")
    AddColumn("col_none")
    AddColumn("col_none")

    default_sort = "col_nickname"
end

escore2.column_count = #default_columns




local client_settings = esclib:InitSettings("escore2", "client")

local cl_tab = client_settings:AddTab("general") --uid
cl_tab:SetNameTranslateKey("s_tab_general") --key in language file
cl_tab:SetPosition(1) --position

--TIME FORMAT [24h, 12h]
cl_tab:AddVar("timeformat", "choicelist")
:SetNameTranslateKey("s_timeformat_name")
:SetValues({"s_24h_format", "s_12h_format"})
:SetValue({"s_24h_format"})
:SetSelectableCount(1)
:SetTranslateValues(true)
:SetSearchEnabled(false)
:SetPosition(1)

--DEFAULT SORT DIRECTION [sort_ascending, sort_descending]
cl_tab:AddVar("default_sort_direction", "choicelist")
:SetNameTranslateKey("s_sort_direction_name")
:SetValues({"sort_ascending", "sort_descending"})
:SetValue({"sort_descending"})
:SetSelectableCount(1)
:SetTranslateValues(true)
:SetSearchEnabled(false)
:SetPosition(2)

--ROUNDING SIZE
cl_tab:AddVar("rounding", "numslider")
:SetNameTranslateKey("s_rounding_name")
:SetValue(cfg.rounding)
:SetMin(0)
:SetMax(16)
:SetDecimals(0)
:SetStep(2)
:SetPosition(4)

--WIDTH [0,1]
cl_tab:AddVar("size_w", "numslider")
:SetNameTranslateKey("s_sizew_name")
:SetValue(cfg.size_width)
:SetMin(0.5)
:SetMax(1)
:SetDecimals(2)
:SetPosition(5)

--INTERVAL
cl_tab:AddVar("interval", "float")
:SetNameTranslateKey("s_interval_name")
:SetValue(cfg.interval)
:SetMin(0)
:SetMax(100)
:SetPosition(6)

cl_tab:AddVar("enable_effect", "bool")
:SetNameTranslateKey("s_effect_name")
:SetValue(cfg.enable_effect)
:SetPosition(7)

--OPEN MULTIPLE PLAYER PANELS
cl_tab:AddVar("multi_open", "bool")
:SetNameTranslateKey("s_multiopen_name")
:SetDescTranslateKey("s_multiopen_desc")
:SetValue(cfg.multiopen)
:SetPosition(8)

--MOUSE INTERACTION WITH PARTICLES
cl_tab:AddVar("mouse_interaction", "bool")
:SetNameTranslateKey("s_mouseinteraction_name")
:SetDescTranslateKey("s_mouseinteraction_desc")
:SetValue(cfg.mouse_interaction)
:SetPosition(9)

--MERGE JOBS INTO CATEGORIES
cl_tab:AddVar("merge_jobs", "bool")
:SetNameTranslateKey("s_merge_jobs_name")
:SetDescTranslateKey("s_merge_jobs_desc")
:SetValue(cfg.merge_jobs)
:SetPosition(10)

--TOGGLE MODE
cl_tab:AddVar("toggle_mode", "bool")
:SetNameTranslateKey("s_togglemode_name")
:SetDescTranslateKey("s_togglemode_desc")
:SetValue(cfg.toggle_mode)
:SetPosition(11)

--ANIMATION
cl_tab:AddVar("animate", "bool")
:SetNameTranslateKey("s_animate_name")
:SetValue(cfg.animate)
:SetPosition(12)

--DRAW BLUR?
cl_tab:AddVar("blur", "bool")
:SetNameTranslateKey("s_draw_blur_name")
:SetValue(cfg.blur)
:SetPosition(13)

--DEFAULT SORT BY
local all_columns = table.Copy(columns)
table.RemoveByValue(all_columns, "col_none") --Remove prohibited column
cl_tab:AddVar("default_sort", "choicelist")
:SetNameTranslateKey("s_default_sort_name")
:SetValues(all_columns)
:SetValue({default_sort})
:SetSelectableCount(1)
:SetTranslateValues(true)
:SetSearchEnabled(false)
:SetPosition(3)

--end client settings and apply it
client_settings:End()


-----------------------
--# SERVER SETTINGS #--
-----------------------
local server_settings = esclib:InitSettings("escore2", "server")

local sv_tab = server_settings:AddTab("general") --uid
sv_tab:SetNameTranslateKey("s_tab_general") --key in language file
sv_tab:SetPosition(1) --position

--LOGO URL
sv_tab:AddVar("logo_url", "str")
:SetNameTranslateKey("s_logo_url_name")
:SetHintTranslateKey("s_logo_url_hint")
:SetValue(cfg.default_logo_url)
:SetMinimumCharCount(1)
:SetMaximumCharCount(1024)
:SetPosition(1)
:SetShared(true) --make it accessible on client

--LOGO WIDTH
sv_tab:AddVar("logo_w", "float")
:SetNameTranslateKey("s_logo_w_name")
:SetValue(cfg.logo_w)
:SetPosition(2)
:SetShared(true) --make it accessible on client

--LOGO HEIGHT
sv_tab:AddVar("logo_h", "float")
:SetNameTranslateKey("s_logo_h_name")
:SetValue(cfg.logo_h)
:SetPosition(3)
:SetShared(true) --make it accessible on client

--SUBTITLE
sv_tab:AddVar("subtitle", "str")
:SetNameTranslateKey("s_subtitle_name")
:SetValue(cfg.default_subtitle)
:SetMinimumCharCount(1)
:SetMaximumCharCount(255)
:SetHintTranslateKey("s_subtitle_hint")
:SetShared(true) --make it accessible on client

--ADMIN MOD
local allowed_mods = {
    ["fadmin"] = true,
    ["ulx"] = true,
    ["sam"] = true,
    ["sadmin"] = true,
}
local admin_mod = string.lower(cfg.admin_mod)
if not allowed_mods[admin_mod] then --throw error
    error("Admin mod ["..tostring(admin_mod).."] not supported!") 
end
sv_tab:AddVar("admin_mod", "choicelist")
:SetNameTranslateKey("s_admin_mod_name")
:SetDescTranslateKey("s_admin_mod_desc")
:SetValues(table.GetKeys(allowed_mods))
:SetValue({admin_mod})
:SetSelectableCount(1)
:SetSearchEnabled(false)
:SetShared(true)


--BACKGROUND EFFECT
local allowed_effects = {
    ["snow"] = true,
    ["dots"] = true,
    ["none"] = true,
}
local effect = string.lower(cfg.effect)
if not allowed_effects[effect] then --throw error
    error("Effect mod ["..tostring(effect).."] not supported!") 
end
sv_tab:AddVar("effect", "choicelist")
:SetNameTranslateKey("s_effect_name")
:SetTranslateValues(true)
:SetValues(table.GetKeys(allowed_effects))
:SetValue({effect})
:SetSelectableCount(1)
:SetSearchEnabled(false)
:SetShared(true)


-- New tab (ranks)
sv_tab = server_settings:AddTab("ranks") --uid
sv_tab:SetNameTranslateKey("s_tab_ranks") --key in language file
sv_tab:SetPosition(2) --postion

--RANK CUSTOMIZATION
sv_tab:AddVar("rank_form", "form")
:SetNameTranslateKey("s_rank_name")
:SetDescTranslateKey("s_rank_desc")
:SetHintTranslateKey("s_rank_hint")
:SetShared(true)
:SetValue({
    ["superadmin"] = {
        ["rank_draw"] = true,
        ["rank_name"] = "superadmin",
        ["rank_color1"] = Color(220,27,255),
        ["rank_color2"] = Color(255,0,150),
        ["rank_glow"] = true,
        ["rank_admin_cmds"] = true,
    },
    ["user"] = {
        ["rank_draw"] = false,
        ["rank_name"] = "user",
        ["rank_color1"] = Color(255,255,255),
        ["rank_color2"] = Color(255,255,255),
        ["rank_glow"] = false,
        ["rank_admin_cmds"] = false,
    },
}) -- by default
:SetFormFields({
    {
        ["uid"] = "rank_draw",
        ["type"] = "bool",
        ["name_tr"] = "form_rank_draw",
        ["value"] = true,
        ["form_display"] = true,
    },
    {
        ["uid"] = "rank_name",
        ["type"] = "str",
        ["name_tr"] = "form_rank_name",
        ["MinimumCharCount"] = 1,
        ["MaximumCharCount"] = 255,
        ["value"] = "change_me",
        ["form_display"] = true,
    },
    {
        ["uid"] = "rank_color1",
        ["type"] = "clr",
        ["name_tr"] = "form_rank_color1",
        ["value"] = Color(255,255,255),
    },
    {
        ["uid"] = "rank_color2",
        ["type"] = "clr",
        ["name_tr"] = "form_rank_color2",
        ["value"] = Color(255,255,255),
    },
    {
        ["uid"] = "rank_glow",
        ["type"] = "bool",
        ["name_tr"] = "form_rank_glow",
        ["value"] = false,
    },
    {
        ["uid"] = "rank_admin_cmds",
        ["type"] = "bool",
        ["name_tr"] = "form_rank_admin_cmds",
        ["value"] = false,
    },
})

--COLUMNS TAB
sv_tab = server_settings:AddTab("columns") --uid
sv_tab:SetNameTranslateKey("s_tab_columns") --key in language file
sv_tab:SetPosition(3) --postion

--COLUMN CUSTOMIZATION
local col_copy = table.Copy(columns)
table.insert(col_copy, "col_none") --add none column to all values
for col_num, default_value in ipairs(default_columns) do
    sv_tab:AddVar("col"..col_num, "choicelist")
        :SetName("№"..col_num)
        :SetDescTranslateKey("s_columns_desc")
        :SetValues(col_copy)
        :SetValue({default_value})
        :SetSelectableCount(1)
        :SetTranslateValues(true)
        :SetSearchEnabled(false)
        :SetShared(true)
        :SetPosition(col_num)
end

--end server settings and apply it
server_settings:End()