local quickmap = require 'quickmap'

local function get_keymap(mode, lhs)
    local mappings = vim.api.nvim_get_keymap(mode)
    for _, mapping in ipairs(mappings) do
        if mapping.lhs == lhs then
            return mapping
        end
    end
end

--[[
{
    buffer = 0,
    expr = 0,
    lhs = "<Tab>",
    lnum = 0,
    mode = "x",
    noremap = 0,
    nowait = 0,
    rhs = "<Plug>(snippy-cut-text)",
    script = 0,
    sid = 102,
    silent = 1
  }
]]
describe("quickmap", function ()
    before_each(function ()
        -- Clear mappings
        for _, mode in ipairs { 'i', 'n', 'v', 'x' } do
            local mappings = vim.api.nvim_get_keymap(mode)
            for _, mapping in ipairs(mappings) do
                mapping.mode = mapping.mode == ' '  and '' or mapping.mode
                vim.api.nvim_del_keymap(mapping.mode, mapping.lhs)
            end
        end
    end)

    it("adds a mapping by spec", function ()
        local spec = { 'n', '-', ':split<CR>' }
        quickmap.add({spec})
        local mapping = get_keymap(spec[1], spec[2])
        assert.is_truthy(mapping)
        assert.are.same(spec[3], mapping.rhs)
    end)

    it("adds a mapping by spec with opts", function ()
        local spec = { 'n', '-', ':split<CR>', silent = false, nowait = true  }
        quickmap.add({spec})
        local mapping = get_keymap(spec[1], spec[2])
        assert.is_truthy(mapping)
        assert.are.same(0, mapping.silent)
        assert.are.same(1, mapping.nowait)

        vim.api.nvim_del_keymap(spec[1], spec[2])
    end)

    it("adds multiple mappings by mode", function ()
        local specs = {
            { 'n', '-', ':split<CR>' },
            { 'n', 'a', ':vsplit<CR>' },
            { 'n', '0', '^' },
        }
        local t = {}
        for _, spec in ipairs(specs) do
            t[spec[2]] = spec[3]
        end
        quickmap.add({ [specs[1][1]] = t })

        for _, spec in ipairs(specs) do
            local mapping = get_keymap(spec[1], spec[2])
            assert.is_truthy(mapping)
            assert.are.same(spec[3], mapping.rhs)
        end
    end)

    it("adds multiple mappings by mode with opts", function ()
        local opts = { silent = false, nowait = true }
        local specs = {
            { 'n', '-', ':split<CR>' },
            { 'n', 'a', ':vsplit<CR>' },
            { 'n', '0', '^' },
        }
        local t = {}
        for _, spec in ipairs(specs) do
            t[spec[2]] = spec[3]
        end
        quickmap.add({ [specs[1][1]] = t }, opts)

        for _, spec in ipairs(specs) do
            local mapping = get_keymap(spec[1], spec[2])
            assert.is_truthy(mapping)
            assert.are.same(spec[3], mapping.rhs)
            assert.are.same(0, mapping.silent)
            assert.are.same(1, mapping.nowait)
        end
    end)

    it("accepts overridden opts when mapping by mode", function ()
        local opts = { silent = false, nowait = true }
        local spec = { 'n', '0', '^' }
        quickmap.add({ n = { [spec[2]] = { spec[3], silent = true }}}, opts)
        local mapping = get_keymap(spec[1], spec[2])
        assert.is_truthy(mapping)
        assert.are.same(spec[3], mapping.rhs)
        assert.are.same(1, mapping.silent)
        assert.are.same(1, mapping.nowait)
    end)

    it("creates a mapper for mode", function ()
        local mapper = quickmap['is']
        assert.is_truthy(mapper)
        assert.are.equal(mapper.mode, 'is')
    end)

    it("maps with inoremap", function ()
        local inoremap = quickmap.inoremap
        local spec = { '0', '000', { silent = false } }
        inoremap(unpack(spec))
        local mapping = get_keymap('i', spec[1])
        assert.is_truthy(mapping)
        assert.are.same(spec[2], mapping.rhs)
        assert.are.same(0, mapping.silent)
        assert.are.same(1, mapping.noremap)
    end)

    it("maps with map", function ()
        local map = quickmap.map
        local spec = { '0', '000', { silent = true }}
        map(unpack(spec))
        local mapping = get_keymap('', spec[1])
        assert.is_truthy(mapping)
        assert.are.same(spec[2], mapping.rhs)
        assert.are.same(1, mapping.silent)
        assert.are.same(0, mapping.noremap)
    end)

    it("maps with __newindex", function ()
        local opts = { silent = false, nowait = true }
        local spec = { 'n', '0', '^' }
        quickmap['n'] = {{ [spec[2]] = { spec[3], spec[4], silent = true }}, opts}
        local mapping = get_keymap(spec[1], spec[2])
        assert.is_truthy(mapping)
        assert.are.same(spec[3], mapping.rhs)
        assert.are.same(1, mapping.silent)
        assert.are.same(1, mapping.nowait)
    end)
end)
