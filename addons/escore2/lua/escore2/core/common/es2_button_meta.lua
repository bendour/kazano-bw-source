escore2.bottom_buttons = escore2.bottom_buttons or {}
escore2.actions = escore2.actions or {}


--Useful function
local function checktype(val, lua_type)
    if isfunction(lua_type) then
        if not lua_type(val) then 
            error("Customcheck failed. Maybe wrong lua type provided?")
        end
    elseif type(val) ~= lua_type then
        error("Wrong lua type or value is empty")
    end
end

local accessor_fn = function(tbl, key, name, default_val, lua_type)
    if lua_type and default_val ~= nil then 
        checktype(default_val, lua_type)
    end
    tbl[key] = default_val
    
    local set_name = string.format("Set%s", name)
    local get_name = string.format("Get%s", name)
    tbl[set_name] = function(self, val)
        if lua_type and val ~= nil then
            checktype(val, lua_type)
        end
        self[key] = val
        return self
    end
    tbl[get_name] = function(self, val)
        return self[key]
    end
end

local function color_check(val)
    if val == nil then return true end
    return IsColor(val) 
end


---------------------------
--# BOTTOM BUTTONS META #--
---------------------------
local BOTTOM_BUTTONS_META = {}
BOTTOM_BUTTONS_META.__index = BOTTOM_BUTTONS_META
local errorMat = Material("error")
local empty_fn = function() end --empty function

BOTTOM_BUTTONS_META.icon = errorMat
BOTTOM_BUTTONS_META.OnClick = empty_fn --to replace
BOTTOM_BUTTONS_META.position = 1000
BOTTOM_BUTTONS_META.color = Color(255,255,255)
BOTTOM_BUTTONS_META.hover_color = Color(255,255,255)

function BOTTOM_BUTTONS_META:SetIcon(material)
    self.icon = material
    return self
end

function BOTTOM_BUTTONS_META:SetIconURL(url)
    self.icon = errorMat

    escore2.addon:DownloadMaterial(url, -- AddonMeta:DownloadMaterial(url, on_succ, on_err, retry_count, additional_path)
        function(material)
            self.icon = material
        end,
        function(errMsg)
            --nothing todo
        end
    )

    return self
end

function BOTTOM_BUTTONS_META:SetIconColor(r,g,b,a)
    self.color = Color(r,g,b,a)
end

function BOTTOM_BUTTONS_META:SetIconHoverColor(r,g,b,a)
    self.hover_color = Color(r,g,b,a)
end


function BOTTOM_BUTTONS_META:SetName(name)
    self.name = name
    return self
end

function BOTTOM_BUTTONS_META:SetTranslatedName(translate_key)
    self:SetName(escore2.addon:Translate(translate_key))
    return self
end

function BOTTOM_BUTTONS_META:SetPosition(pos)
    self.position = pos
    return self
end


function escore2:NewBottomButton(name)
    local new_btn = {}

    setmetatable(new_btn, BOTTOM_BUTTONS_META)
    new_btn:SetName(name)
    self.bottom_buttons[name] = new_btn

    return new_btn
end

function escore2:GetBottomButtons()
    return self.bottom_buttons
end

function escore2:GetBottomButton(name)
    return self.bottom_buttons[name]
end


---------------------------
--# ACTION BUTTONS META #--
---------------------------
--category meta
local ACTION_CATEGORY_META = {}
ACTION_CATEGORY_META.__index = ACTION_CATEGORY_META
accessor_fn(ACTION_CATEGORY_META, "name", "Name")
accessor_fn(ACTION_CATEGORY_META, "name_tr", "NameTranslateKey")
accessor_fn(ACTION_CATEGORY_META, "check_func", "CheckFunc", empty_fn, "function")
accessor_fn(ACTION_CATEGORY_META, "color", "Color", Color(150,150,150), color_check)
accessor_fn(ACTION_CATEGORY_META, "position", "Position", 1, "number")

function ACTION_CATEGORY_META:GetButtons()
    return self.buttons
end

function ACTION_CATEGORY_META:GetButtonCount()
    return #self.buttons
end


--button meta
local ACTION_BUTTON_META = {}
ACTION_BUTTON_META.__index = ACTION_BUTTON_META
accessor_fn(ACTION_BUTTON_META, "name", "Name")
accessor_fn(ACTION_BUTTON_META, "name_tr", "NameTranslateKey")
accessor_fn(ACTION_BUTTON_META, "init_func", "InitFunc", empty_fn, "function")
accessor_fn(ACTION_BUTTON_META, "func", "Func", empty_fn, "function")
accessor_fn(ACTION_BUTTON_META, "check_func", "CheckFunc", empty_fn, "function")
accessor_fn(ACTION_BUTTON_META, "icon", "Icon", nil, "IMaterial")
accessor_fn(ACTION_BUTTON_META, "color", "Color", nil, color_check)
accessor_fn(ACTION_BUTTON_META, "position", "Position", 1, "number")


--Add button to category
function ACTION_CATEGORY_META:AddButton(uid)
    local btn = {}
    setmetatable(btn, ACTION_BUTTON_META)
    btn:SetName(uid)
    btn:SetNameTranslateKey(uid)
    btn:SetPosition(self:GetButtonCount()+1)

    table.insert(self.buttons, btn)
    return btn
end


--Add new action button category
function escore2:NewActionButtonCategory(uid)
    local new_category = {}
    new_category.buttons = {}

    setmetatable(new_category, ACTION_CATEGORY_META)
    new_category:SetName(uid)
    new_category:SetNameTranslateKey(uid)
    self.actions[uid] = new_category

    return new_category
end

function escore2:GetActionCategories()
    return escore2.actions
end

function escore2:GetActionCategory(uid)
    return escore2.actions[uid]
end



--Lua refresh
if IsValid(escore2.bg) then escore2:Build() end