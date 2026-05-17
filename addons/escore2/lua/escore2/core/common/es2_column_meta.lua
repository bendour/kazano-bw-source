escore2.columns = escore2.columns or {}
escore2.columns.list = escore2.columns.list or {}
escore2.columns.width = escore2.columns.width or 1

local COLUMN_META = {}
COLUMN_META.__index = COLUMN_META

function COLUMN_META:SetName(name)
    self.column_name = name
end

function COLUMN_META:SetInitTopbarFunc(fn)
    self.init_topbar = fn
    return self
end

function COLUMN_META:InitTopbar(...)
    self.init_topbar(...)
end

function COLUMN_META:SetInitPlayerbarFunc(fn)
    self.init_playerbar = fn
    return self
end

function COLUMN_META:SetSortFunc(fn)
    self.sort_func = fn
    return self
end

function COLUMN_META:SetCategoryNameFunc(fn)
    self.category_name_func = fn
    return self
end

function COLUMN_META:GetCategoryNameFunc()
    return self.category_name_func
end

function COLUMN_META:SetInitCategoryFunc(fn)
    self.init_category_func = fn
    return self
end

function COLUMN_META:GetInitCategoryFunc(fn)
    return self.init_category_func
end

function COLUMN_META:SetCustomCheckFunc(fn)
    self.custom_check = fn
    return self
end

function COLUMN_META:SetFixedWide(width)
    self.fixed_width = true
    self.width = width
end

function COLUMN_META:GetWide()
    if not self.width then error("Column sizes not calculated! Do it with escore2:CalculateColumnWidths() before calling this function.") end
    return self.width
end

--ONLY AFFECTS ICON!!! YOU MUST EDIT YOUR SORT FUNCTION
function COLUMN_META:SetInversedSort(bol)
    self.inversed_sort = bol
end

function COLUMN_META:SetIcon(icon_mat)
    self.icon = icon_mat
end


function escore2:NewColumn(name, parent_classname)
    local new_column = {}
    setmetatable(new_column, COLUMN_META)

    if self.columns.list[parent_classname] then
        --lets copy parent panel
        esclib:SafeMerge(new_column, self.columns.list[parent_classname], true)
    else
        new_column:SetName(name)
    end

    new_column.name = name
    self.columns.list[name] = new_column

    return new_column
end

function escore2:GetAllColumns()
    return self.columns.list
end

function escore2:GetColumn(name)
    return self.columns.list[name]
end

function escore2:GetAvailableColumns()
    local columns = {}
	for i = 1, escore2.column_count do
		local val = escore2.addon:GetVar("col"..i)
		if istable(val) and val[1] ~= "col_none" then
            val = val[1]
			local col_value = escore2:GetColumn(val)
			if not col_value then continue end

			if col_value.custom_check(col_value) ~= true then
				print("[escore2] Column "..val.." custom check returned False. Maybe column isn't compatible with your server!")
				continue 
			end

			table.insert(columns, val)
		end
	end
    table.insert(columns, "col_buttons") --by default
    return columns
end

function escore2:CalculateColumnWidths()

    local width = 1
    local count = 0
    local cols = escore2:GetAvailableColumns()
    for _,col_name in pairs(escore2:GetAvailableColumns()) do
        local col = escore2:GetColumn(col_name)
        if not col.fixed_width then
            count = count + 1
        else
            width = width - col.width
        end
    end
    if width <= 0 then
        esclib.print("[escore2][warning] The width of the columns is out of bounds.")
    end

    local single_width = width / count
    for _,col_name in pairs(escore2:GetAvailableColumns()) do
        local col = escore2:GetColumn(col_name)
        if not col.fixed_width then
            col.width = single_width
        end
    end

    escore2.columns.width = width
end

if IsValid(escore2.bg) then --lua refresh
    escore2:Build()
end