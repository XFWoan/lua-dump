local M = {}

local type = type
local table = table
local string = string
local tostring = tostring
local getmetatable = getmetatable

function M.dump(value, max_depth)
    local value_type = type(value)

    if value_type == "string" then
        return "\"" .. value .. "\""
    end

    if value_type == "table" then
        return M.dump_table(value, max_depth or 81)
    end

    return tostring(value)
end

function M.dump_table(tbl, max_depth)
    local tbl_dict = {}

    -- gen blank closure
    local function __gen_blank(n)
        -- gen blank
        local blank = {}
        for _ = 1, n do
            table.insert(blank, "    ")
        end
        return table.concat(blank)
    end

    -- dump table closure
    local function __dump_table(t, d)
        local result = { "{\n" }
        local blank = __gen_blank(d)

        -- metatable
        local mt = getmetatable(t)
        if mt then
            if tbl_dict[mt] or d >= max_depth then
                table.insert(result, string.format("%smetatable = %s,\n", blank, tostring(mt)))
            else
                table.insert(result, string.format("%smetatable = %s,\n", blank, __dump_table(mt, d + 1)))
            end
        end

        -- dump table
        if M.is_array(t) then
            -- array
            for i, v in ipairs(t) do
                -- dump value
                local value_str
                if type(v) == "table" and (tbl_dict[v] or d >= max_depth) then
                    value_str = tostring(v)
                elseif v == tbl then
                    value_str = "self"
                elseif type(v) == "table" then
                    tbl_dict[v] = true
                    value_str = __dump_table(v, d + 1)
                else
                    value_str = M.dump(v)
                end

                table.insert(result, string.format("%s[%d] = %s,\n", blank, i, value_str))
            end
        else
            -- map
            for k, v in pairs(t) do
                -- dump format string
                local tpl
                if type(k) == "number" then
                    tpl = "%s[%d] = %s,\n"
                else
                    tpl = "%s%s = %s,\n"
                end

                -- dump value
                local value_str
                if type(v) == "table" and (tbl_dict[v] or d >= max_depth) then
                    value_str = tostring(v)
                elseif v == tbl then
                    value_str = "self"
                elseif type(v) == "table" then
                    tbl_dict[v] = true
                    value_str = __dump_table(v, d + 1)
                else
                    value_str = M.dump(v)
                end

                table.insert(result, string.format(tpl, blank, tostring(k), value_str))
            end
        end

        table.insert(result, string.format("%s}", __gen_blank(d - 1)))
        return table.concat(result)
    end

    return __dump_table(tbl, 1)
end

function M.is_array(tbl)
    local n = 0
    for k in pairs(tbl) do
        if type(k) ~= "number" or k > #tbl or k <= 0 then
            return false
        end
        n = n + 1
    end
    return n == #tbl
end

return M.dump