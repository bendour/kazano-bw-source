local convert_from_cfg = {
    ["sort_ascending"] = "ascending",
    ["sort_descending"] = "descending"
}

function escore2:SetSortFunc(fn)
    self.sort_fn = fn
    self:SortPanels()
end

function escore2:SortByCol(column_name)
    if not self.sorts[column_name] then
        column_name = "col_nickname"
    end

    if self.sort_column ~= column_name then
        self.sort_column = column_name
        self.sort_order = convert_from_cfg[self.addon:GetVar("default_sort_direction")[1]] or "ascending"
    else
        self.sort_order = (self.sort_order == "ascending") and "descending" or "ascending"
    end

    self:SetSortFunc(self.sorts[self.sort_column])
end

function escore2:SortPanels()
    local player_base_panel = self.player_base_panel
    if not IsValid(player_base_panel) then return end

    local inverse = (self.sort_order ~= "ascending")
    local succ, err = pcall(function() 
        table.sort(player_base_panel.ply_child, function(a, b)
            a = a:GetPlayer()
            b = b:GetPlayer()
            return self.sort_fn(a, b, inverse)
        end)
    end)
    if err then
        print("[escoreboard2] Warning: sort function was bad. Error: "..(err or ""))
    end
    self:Update()
end

function escore2:InitSorts()
    escore2.sorts = {}

    self.sorts["col_nickname"] = function(ply1, ply2, inverse)
        if escore2.search_text ~= "" then
            --levenshtein distance
            local d1 = esclib.text.distance(escore2.search_text, ply1:Nick())
            local d2 = esclib.text.distance(escore2.search_text, ply2:Nick())
    
            if d1 ~= d2 then
                return d1 > d2
            end
        end

        if inverse then
            return ply1:Nick() > ply2:Nick()
        else
            return ply1:Nick() < ply2:Nick()
        end
    end

    local columns = self:GetAvailableColumns()
    for _, column_name in ipairs(columns) do
        local column = self:GetColumn(column_name)
        if column and isfunction(column.sort_func) then
            self.sorts[column_name] = column.sort_func
        end
    end

    self.default_sort = self.addon:GetVar("default_sort")[1] or "col_nickname"
    self.sort_column = nil
    self.sort_order = convert_from_cfg[self.addon:GetVar("default_sort_direction")[1]] or "ascending"
    self.sort_fn = nil

    self:SortByCol(self.default_sort)
    -- self:SetSortFunc(self.sorts[self.sort_column])

    -- self:SortByCol(self.sort_column)
end

function escore2:GetSortColumn()
    return self.sort_column
end


if IsValid(escore2.bg) then --lua refresh
    escore2:Build()
end