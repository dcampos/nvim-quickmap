--[[
Examples:

    quickmap['is']:add {
        ['<Tab>'] = function()
            ...
        end,
        ['<S-Tab>'] = function()
            ...
        end,
    }

    quickmap.add {
        { 'is', '<Tab>', function() ... end },
        { 'is', '<Tab>', function() ... end, { noremap = false } },
        ...
    }

    quickmap.add {
        ['n'] = {
            ['<Tab>'] = ...,
            ['<S-Tab>'] = ...,
        }
    }

    quickmap.add({ <specs> }, { <common opts> })

    quickmap.add(
        quickmap.with_opts({ noremap = false, expr = true }, {
            { 'is', '<Tab>', function() ... end), },
            { 'is', '<S-Tab>', function() ... end), },
        })
    )

    quickmap.setup({
        default_opts = { noremap = true, silent = true }
    })

    quickmap.nnoremap('K', vim.lsp.hover)
    quickmap.nmap('K', vim.lsp.hover)

    quickmap['nvo'] = {
        ['<Tab>'] = ...,
        ['<S-Tab>'] = ...,
    }

    quickmap['nvo'] = { { ... }, { noremap = false } }

    quickmap['nvo'] = { bufnr, { ... }, { noremap = false } }

]]

local Mapper = require 'quickmap.mapper'

local M = {}

---@private
local function _add(specs, opts, buffer)
    vim.validate({
        specs = { specs, 'table' },
        opts = { opts, 'table', true },
        buffer = { buffer, 'number', true },
    })
    opts = vim.tbl_extend('keep', opts or {}, Mapper._default_opts)
    if #specs > 0 then
        for _, spec in ipairs(specs) do
            spec[4] = vim.tbl_extend('keep', spec[4] or {}, opts)
            M.mapper:map(spec, buffer)
        end
    else
        -- Each index is a mode
        for mode, spec in pairs(specs) do
            local mapper = Mapper.new(mode, buffer)
            mapper:add(spec, opts)
        end
    end
end

M.mapper = Mapper.new()

setmetatable(M, {
    __index = function(_, key)
        if type(key) == 'string' then
            if key:match('^[cinsvx]+$') then
                return Mapper.new(key)
            elseif key:match('^.?noremap$') then
                local mode = #key == 8 and key:sub(1, 1) or ''

                return function(lhs, rhs, opts)
                    opts = vim.tbl_extend('force', opts or {}, { noremap = true })
                    M.mapper:map({ mode, lhs, rhs, opts })
                end
            elseif key:match('^.?map$') then
                local mode = #key == 4 and key:sub(1, 1) or ''

                return function(lhs, rhs, opts)
                    opts = vim.tbl_extend('force', opts or {}, { noremap = false })
                    M.mapper:map({ mode, lhs, rhs, opts })
                end
            end
        end
    end,

    __newindex = function(self, key, value)
        if type(key) == 'string' and key:match('^[cinsvx]+$') then
            if #value == 2 then
                _add({ [key] = value[1] }, value[2], value[3])
            elseif #value == 3 then
                _add({ [key] = value[2] }, value[3], value[1])
            else
                _add({ [key] = value })
            end
        else
            rawset(self, key, value)
        end
    end
})

function M.setup(config)
    error('not implemented')
end

--- Adds a set of mappings.
---
--- quickmap.add {
---     { 'is', '<Tab>', function() ... end },
---     { 'is', '<Tab>', function() ... end, { noremap = false } },
---     ...
--- }
---
--- quickmap.add {
---     ['n'] = {
---         ['<Tab>'] = ...,
---         ['<S-Tab>'] = ...,
---     }
--- }
---
--- quickmap.add({ <specs> }, { <common opts> })
---
---@param specs table Table with mapping specifications
---@param opts table Common options for these mappings
function M.add(specs, opts)
    vim.validate({
        specs = { specs, 'table' },
        opts = { opts, 'table', true },
    })
    _add(specs, opts)
end

--- Buffer equivalent of `add`.
---@param buffer number
---@param specs table
---@param opts table
function M.buf_add(buffer, specs, opts)
    vim.validate({
        buffer = { buffer, 'number' },
        specs = { specs, 'table' },
        opts = { opts, 'table', true },
    })
    _add(specs, opts, buffer)
end

function M.with_opts(opts, spec)
    error('not implemented')
end

-- function M.map(spec)
--     error('not implemented')
-- end

function M.buffer(number)
    error('not implemented')
end

return M
