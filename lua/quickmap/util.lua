local M = {}

M.valid_opts = {
    'noremap',
    'nowait',
    'silent',
    'script',
    'expr',
    'unique',
}

function M.validate_opts(opts)
    if type(opts) ~= 'table' then
        return false, "'opts' should be a table"
    end
    for key, value in pairs(opts) do
        if not vim.tbl_contains(M.valid_opts, key) then
            return false, 'invalid option: ' .. key
        end
        if type(value) ~= 'boolean' then
            return false, 'option value should be a boolean: ' .. key
        end
    end
    return true
end

function M.make_opts(value)
    local opts = {}
    local values = {}
    for key, v in pairs(value) do
        if vim.tbl_contains(M.valid_opts, key) then
            opts[key] = v
        else
            values[key] = v
        end
    end
    return values, opts
end

return M
