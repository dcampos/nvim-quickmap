--[[--
Module for storing functions.
]]

local M = {}

local mt
mt = {
    __index = function(self, key)
        self[key] = setmetatable({}, mt)
        return self[key]
    end
}

M._store = setmetatable({}, mt)
M._buf_store = setmetatable({}, mt)

--- Stores a function
---@param mode string
---@param lhs string
---@param buffer number
---@param fn function
function M.set(mode, lhs, buffer, fn)
    if buffer then
        M._buf_store[mode][buffer][lhs] = fn
    else
        M._store[mode][lhs] = fn
    end
end

--- Retrieves a stored function
-- @tparam string mode
-- @tparam string lhs
-- @tparam integer buffer
-- @treturn function
function M.get(mode, lhs, buffer)
    if buffer then
        return M._buf_store[mode][buffer][lhs]
    else
        return M._store[mode][lhs]
    end
end

return M
