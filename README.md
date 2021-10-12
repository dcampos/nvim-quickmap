# Keymap

Neovim plugin for quickly mapping keys in Lua.

## Usage

```lua
    local quickmap = require('quickmap')

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
```

## Similar projects

Some other similar projects I took ideas/inspiration from:

* [tjdevries/astronauta.nvim](https://github.com/tjdevries/astronauta.nvim)
* [b0o/mapx.nvim](https://github.com/b0o/mapx.nvim)
* [LionC/nest.nvim](https://github.com/LionC/nest.nvim)

## Licence

MIT
