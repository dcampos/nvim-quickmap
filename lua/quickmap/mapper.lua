local store = require 'quickmap.store'
local util = require 'quickmap.util'

local function t(value)
    return vim.api.nvim_replace_termcodes(value, true, true, true)
end

local Mapper = {}

Mapper._default_opts = { noremap = true, silent = true }

-- Store for functions
Mapper._store = store

function Mapper._run(mode, lhs, buffer)
    local fn = Mapper._store.get(mode, lhs, buffer)
    if fn then
        return fn()
    else
        error(string.format('No stored function for mode %s and lhs %s', mode, lhs))
    end
end

function Mapper._set(mode, spec, buffer)
    local fn = spec[3]
    local lhs = t(spec[2])
    buffer = buffer and vim.api.nvim_buf_get_number(buffer) or buffer
    Mapper._store.set(mode, lhs, buffer, fn)
    local expr
    if buffer then
        expr = string.format("require('quickmap.mapper')._run('%s', '%s', %d)", mode, lhs, buffer)
    else
        expr = string.format("require('quickmap.mapper')._run('%s', '%s')", mode, lhs)
    end
    if spec.opts.expr then
        return string.format('luaeval("%s")', expr)
    else
        return string.format('<cmd>lua %s<cr>', expr)
    end
end

---@private
function Mapper._map(mode, spec, buffer)
    local lhs, rhs, opts = spec[2], spec[3], spec.opts

    vim.validate({
        specs = { lhs, 'string' },
        opts = { opts, util.validate_opts, 'valid options' },
    })

    if type(rhs) == 'function' then
        rhs = Mapper._set(mode, spec, buffer)
    end

    if buffer then
        opts.buffer = nil
        vim.api.nvim_buf_set_keymap(buffer, mode, lhs, rhs, opts)
    else
        vim.api.nvim_set_keymap(mode, lhs, rhs, opts)
    end
end

Mapper.__index = Mapper

--- Creates a new mapper.
---@param mode string One or more letters representing the modes
---@param buffer number
---@return table
function Mapper.new(mode, buffer)
    local self = {
        buffer = buffer,
        mode = mode
    }

    setmetatable(self, Mapper)

    return self
end

--- Add a mapping by key/value pair.
---
--- Example:
---
--- mapper:add {
---     ['<Tab>'] = function()
---         ...
---     end,
---     ['<S-Tab>'] = function()
---         ...
---     end,
--- }
---
--- The value may also be a table with embedded options:
---
--- { function () ... end, expr = true }
---
---@param specs table Table with specs
---@param opts table Table with options to apply to all specs
function Mapper:add(specs, opts)
    vim.validate({
        specs = { specs, 'table' },
        opts = { opts, 'table', true },
    })
    if self.mode then
        for key, value in pairs(specs) do
            if type(value) == 'table' then
                local values, map_opts = util.make_opts(value)
                map_opts =  vim.tbl_extend('keep', map_opts, opts or {})
                self:map({ self.mode, key, values[1], map_opts }, self.buffer)
            else
                self:map({ self.mode, key, value, opts }, self.buffer)
            end
        end
    else
        error('No mode defined')
    end
end

--- Identical with `add`, but for buffer mapping.
---
--- Example:
---
--- mapper:buf_add(0, {
---     ['<Tab>'] = function()
---         ...
---     end,
---     ['<S-Tab>'] = function()
---         ...
---     end,
--- })
---
---@param buffer number Table with specs
---@param specs table Table with specs
---@param opts table Table with options to apply to all specs
function Mapper:buf_add(buffer, specs, opts)
    vim.validate({
        buffer = { buffer, 'number' },
        specs = { specs, 'table' },
        opts = { opts, 'table', true},
    })
    buffer = buffer == true and 0 or buffer
    if self.mode then
        for key, value in pairs(specs) do
            if type(value) == 'table' then
                local values, map_opts = util.make_opts(value)
                map_opts =  vim.tbl_extend('keep', map_opts, opts or {})
                self:map({ self.mode, key, values[1], map_opts }, buffer)
            else
                self:map({ self.mode, key, value, opts }, buffer)
            end
        end
    else
        error('No mode defined')
    end
end

--- Maps a spec
---
---@param spec table Table with { mode, lhs, rhs, opts? }
---@param buffer number
function Mapper:map(spec, buffer)
    vim.validate({
        specs = { spec, 'table' },
        buffer = { buffer, 'number', true },
    })
    spec.opts = vim.tbl_extend('keep', spec[4] or {}, Mapper._default_opts)
    local mode = spec[1]

    if mode == '' then
        Mapper._map(mode, spec, buffer)
    else
        for m in string.gmatch(mode, '.') do
            Mapper._map(m, spec, buffer)
        end
    end
end

return Mapper
