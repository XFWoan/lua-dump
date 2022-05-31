local dump = require "dump"
local userdata = require "userdata"

local test_case = {
    { "nil", nil },
    { "true", true },
    { "false", false },
    { "number", 3.14 },
    { "string", "hello" },
    { "function", function()
    end },
    { "thread", coroutine.create(function()
    end) },
    { "userdata", userdata.gen_lightuserdata() },
}

for _, v in ipairs(test_case) do
    print(string.format("%-10s: %s \n", v[1], dump(v[2])))
end

local empty_tbl = {}
local nested_tbl = { test_case }
local dict_tbl = {
    number = 1,
    string = "hello",
}
table.insert(test_case, { "table", {
    ["empty table"]  = empty_tbl,
    ["nested table"] = nested_tbl,
    ["dict table"]   = dict_tbl,
} })

setmetatable(test_case, {
    __div = function()
    end,
    self  = test_case,
})

print(string.format("%-10s: \n%s", "table", dump(test_case)))


