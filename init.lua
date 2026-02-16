vim.g.mapleader = ','
vim.g.maplocalleader = ','

-- Set to true if you have a Nerd Font installed and selected in the terminal
vim.g.have_nerd_font = true

-- [[ Setting options ]]
-- See `:help vim.o`
-- NOTE: You can change these options as you wish!
--  For more options, you can see `:help option-list`

-- Make line numbers default
vim.o.relativenumber = false
vim.o.ruler = false
vim.o.syntax = 'enabled'
vim.o.mouse = ''
vim.o.termguicolors = true
vim.o.showmode = false
vim.o.breakindent = true
vim.o.undofile = true
vim.o.tabstop = 4
vim.o.ignorecase = true
vim.o.smartcase = true
vim.o.signcolumn = 'yes'
vim.o.updatetime = 250
vim.o.timeoutlen = 500
vim.o.termguicolors = true
vim.o.splitright = true
vim.o.splitbelow = true
vim.o.list = false
vim.opt.listchars = { tab = '» ', trail = '·', nbsp = '␣' }
vim.o.inccommand = ''
vim.o.cursorline = false
vim.o.scrolloff = 0
vim.o.confirm = true
vim.o.hlsearch = false
vim.o.background = 'light'
vim.o.laststatus = 0
vim.o.cmdheight = 0

-- Helper function to use minimal telescope theme
local function use_minimal(fn, overrides)
  local minimal_conf = {
    previewer = false,
    theme = 'dropdown',
    sorting_strategy = 'ascending',
    layout_config = {
      width = 0.7,
      height = 0.5,
      prompt_position = 'top',
    },
  }
  overrides = overrides or {}
  return function()
    fn(vim.tbl_extend('force', minimal_conf, overrides))
  end
end

-- [[ Basic Keymaps ]]
-- Open diagnostics quickfix list
vim.keymap.set('n', '<leader>q', vim.diagnostic.setloclist)
-- Toggle diagnostics in the gutter
vim.keymap.set('n', '<leader>td', function()
  vim.diagnostic.enable(not vim.diagnostic.is_enabled())
end)
-- Toggle git signs in the gutter
vim.keymap.set('n', '<leader>tg', ':Gitsigns toggle_signs<CR>', { silent = true })

-- [[ Basic Autocommands ]]
--  See `:help lua-guide-autocommands`

--    See `:help lazy.nvim.txt` or https://github.com/folke/lazy.nvim for more info
local lazypath = vim.fn.stdpath 'data' .. '/lazy/lazy.nvim'
if not (vim.uv or vim.loop).fs_stat(lazypath) then
  local lazyrepo = 'https://github.com/folke/lazy.nvim.git'
  local out = vim.fn.system { 'git', 'clone', '--filter=blob:none', '--branch=stable', lazyrepo, lazypath }
  if vim.v.shell_error ~= 0 then
    error('Error cloning lazy.nvim:\n' .. out)
  end
end

---@type vim.Option
local rtp = vim.opt.rtp
rtp:prepend(lazypath)

-- [[ Configure and install plugins ]]
--
--  To check the current status of your plugins, run
--    :Lazy
require('lazy').setup {
  'NMAC427/guess-indent.nvim', -- Detect tabstop and shiftwidth automatically
  {
    'sderev/alabaster.vim',
    config = function()
      vim.cmd 'colorscheme alabaster'
    end,
  },

  -- Neo-tree is a Neovim plugin to browse the file system
  -- https://github.com/nvim-neo-tree/neo-tree.nvim
  {
    'preservim/nerdtree',
    lazy = false,
    keys = {
      { '\\', ':NERDTreeToggle<CR>', silent = true }, -- Toggle file tree
      { '|', ':NERDTreeFind<CR>', silent = true }, -- Reveal current file in tree
    },
    config = function()
      vim.g.NERDTreeWinPos = 'right'
      vim.g.NERDTreeMinimalUI = 1
      vim.g.NERDTreeWinSize = 40
      vim.g.NERDTreeQuitOnOpen = 3
    end,
  },

  -- See `:help gitsigns` to understand what the configuration keys do
  { -- Adds git related signs to the gutter, as well as utilities for managing changes
    'lewis6991/gitsigns.nvim',
    opts = {
      signs = {
        add = { text = '+' },
        change = { text = '~' },
        delete = { text = '_' },
        topdelete = { text = '‾' },
        changedelete = { text = '~' },
      },
      on_attach = function(bufnr)
        local gs = require 'gitsigns'
        vim.keymap.set('n', '<leader>hr', gs.reset_hunk)
        vim.keymap.set('n', ']h', gs.next_hunk)
        vim.keymap.set('n', '[h', gs.prev_hunk)
      end,
    },
  },

  { -- Fuzzy Finder (files, lsp, etc)
    'nvim-telescope/telescope.nvim',
    event = 'VimEnter',
    dependencies = {
      'nvim-lua/plenary.nvim',
      { -- If encountering errors, see telescope-fzf-native README for installation instructions
        'nvim-telescope/telescope-fzf-native.nvim',
        build = 'make',
        cond = function()
          return vim.fn.executable 'make' == 1
        end,
      },
      { 'nvim-telescope/telescope-ui-select.nvim' },
      { 'nvim-tree/nvim-web-devicons', enabled = vim.g.have_nerd_font },
    },
    config = function()
      require('telescope').setup {
        defaults = {
          path_display = { 'smart' },
        },
        extensions = {
          ['ui-select'] = {
            require('telescope.themes').get_dropdown(),
          },
        },
        pickers = {
          buffers = {
            sort_mru = true,
            sort_lastused = true,
            initial_mode = 'normal',
            mappings = {
              i = { ['<C-d>'] = 'delete_buffer' }, -- in insert mode
              n = { ['<C-d>'] = 'delete_buffer' }, -- in normal mode
            },
          },
        },
      }

      -- Enable Telescope extensions if they are installed
      pcall(require('telescope').load_extension, 'fzf')
      pcall(require('telescope').load_extension, 'ui-select')

      -- See `:help telescope.builtin`
      local builtin = require 'telescope.builtin'

      vim.keymap.set('n', '<leader>sr', builtin.resume)
      vim.keymap.set('n', '<leader>sf', use_minimal(builtin.find_files))
      vim.keymap.set('n', '<leader>sw', use_minimal(builtin.grep_string))
      vim.keymap.set('n', '<leader>sg', use_minimal(builtin.live_grep))
      vim.keymap.set('n', '<leader>s/', use_minimal(builtin.live_grep, { grep_open_files = true }))
      vim.keymap.set('n', '<leader>/', use_minimal(builtin.current_buffer_fuzzy_find))
      vim.keymap.set('n', '<leader><leader>', use_minimal(builtin.buffers, { show_all_buffers = true }))
      vim.keymap.set('n', '<leader>sp', function()
        local word = vim.fn.expand '<cword>'
        use_minimal(builtin.live_grep, { default_text = vim.fn.expand '<cword>' })()
      end)
    end,
  },

  {
    'folke/lazydev.nvim',
    ft = 'lua',
    dependencies = {
      { 'Bilal2453/luvit-meta', lazy = true }, -- Add this line
    },
    opts = {
      library = {
        { path = 'luvit-meta/library', words = { 'vim%.uv' } },
      },
    },
  },

  {
    -- Main LSP Configuration
    'neovim/nvim-lspconfig',
    dependencies = {
      { 'mason-org/mason.nvim', opts = {} },
      'mason-org/mason-lspconfig.nvim',
      'WhoIsSethDaniel/mason-tool-installer.nvim',
      {
        'j-hui/fidget.nvim',
        opts = {
          notification = {
            window = {
              normal_hl = 'Normal',
              winblend = 0,
              border = 'none',
            },
          },
        },
      },
      'saghen/blink.cmp',
    },
    config = function()
      vim.api.nvim_create_autocmd('LspAttach', {
        group = vim.api.nvim_create_augroup('kickstart-lsp-attach', { clear = true }),
        callback = function(event)
          local map = function(keys, func, _, mode)
            mode = mode or 'n'
            vim.keymap.set(mode, keys, func, { buffer = event.buf })
          end

          -- Rename symbol
          map('grn', vim.lsp.buf.rename)

          -- Find references
          map('grr', require('telescope.builtin').lsp_references)

          -- Go to implementation
          map('gri', require('telescope.builtin').lsp_implementations)

          -- Go to definition
          map('grd', require('telescope.builtin').lsp_definitions)

          -- Go to declaration
          map('grD', vim.lsp.buf.declaration)

          -- Open document symbols
          map(
            'gO',
            use_minimal(require('telescope.builtin').treesitter, {
              symbols = { 'function', 'method', 'class', 'struct', 'interface', 'type', 'module', 'namespace', 'constant', 'variable' },
            })
          )

          -- Open workspace symbols
          map('gW', require('telescope.builtin').lsp_dynamic_workspace_symbols)

          -- Go to type definition
          map('grt', require('telescope.builtin').lsp_type_definitions)

          -- This function resolves a difference between neovim nightly (version 0.11) and stable (version 0.10)
          ---@param client vim.lsp.Client
          ---@param method vim.lsp.protocol.Method
          ---@param bufnr? integer some lsp support methods only in specific files
          ---@return boolean
          local function client_supports_method(client, method, bufnr)
            if vim.fn.has 'nvim-0.11' == 1 then
              return client:supports_method(method, bufnr)
            else
              return client.supports_method(method, { bufnr = bufnr })
            end
          end
        end,
      })

      -- Diagnostic Config
      -- See :help vim.diagnostic.Opts
      vim.diagnostic.config {
        severity_sort = true,
        update_in_insert = false,
        float = false, -- { border = 'rounded', source = 'if_many' },
        underline = false, -- { severity = vim.diagnostic.severity.ERROR },
        signs = vim.g.have_nerd_font and {
          text = {
            [vim.diagnostic.severity.ERROR] = '󰅚 ',
            [vim.diagnostic.severity.WARN] = '󰀪 ',
            [vim.diagnostic.severity.INFO] = '󰋽 ',
            [vim.diagnostic.severity.HINT] = '󰌶 ',
          },
        } or {},
        virtual_text = false,
      }

      local capabilities = require('blink.cmp').get_lsp_capabilities()

      local servers = {
        clangd = {
          cmd = { 'clangd', '--background-index' },
          root_dir = require('lspconfig').util.root_pattern('compile_flags.txt', '.git'),
        },
        emmet_language_server = {
          filetypes = { 'html', 'typescriptreact', 'javascriptreact', 'css', 'sass', 'scss', 'less', 'svelte', 'vue' },
        },
        pyright = {},
        ts_ls = {},
        lua_ls = {
          -- cmd = { ... },
          -- filetypes = { ... },
          -- capabilities = {},
          settings = {
            Lua = {
              completion = {
                callSnippet = 'Replace',
              },
              -- You can toggle below to ignore Lua_LS's noisy `missing-fields` warnings
              -- diagnostics = { disable = { 'missing-fields' } },
            },
          },
        },
      }

      local ensure_installed = vim.tbl_keys(servers or {})
      vim.list_extend(ensure_installed, { 'stylua', 'emmet-language-server' })
      require('mason-tool-installer').setup { ensure_installed = ensure_installed }

      require('mason-lspconfig').setup {
        ensure_installed = { 'ts_ls' }, -- explicitly set to an empty table (Kickstart populates installs via mason-tool-installer)
        automatic_installation = false,
        handlers = {
          function(server_name)
            local server = servers[server_name] or {}
            server.capabilities = vim.tbl_deep_extend('force', {}, capabilities, server.capabilities or {})
            require('lspconfig')[server_name].setup(server)
          end,
        },
      }
    end,
  },

  { -- Autoformat (<leader>f to format buffer)
    'stevearc/conform.nvim',
    event = { 'BufWritePre' },
    cmd = { 'ConformInfo' },
    keys = {
      {
        '<leader>f',
        function()
          require('conform').format { async = true, lsp_format = 'fallback' }
        end,
        mode = '',
      },
    },
    opts = {
      notify_on_error = false,
      format_on_save = function(bufnr)
        -- Disable "format_on_save lsp_fallback" for languages that don't
        -- have a well standardized coding style. You can add additional
        -- languages here or re-enable it for the disabled ones.
        local disable_filetypes = { cpp = true }
        if disable_filetypes[vim.bo[bufnr].filetype] then
          return nil
        else
          return {
            timeout_ms = 500,
            lsp_format = 'fallback',
          }
        end
      end,
      formatters_by_ft = {
        lua = { 'stylua' },
        c = { 'clang-format' },
        python = function(bufnr)
          if require('conform').get_formatter_info('ruff_format', bufnr).available then
            return { 'ruff_format' }
          else
            return { 'isort', 'black' }
          end
        end,
        javascript = { 'prettierd' },
        typescript = { 'prettierd' },
        javascriptreact = { 'prettierd' },
        typescriptreact = { 'prettierd' },
        json = { 'prettierd' },
        html = { 'prettierd' },
        css = { 'prettierd' },
        scss = { 'prettierd' },
        less = { 'prettierd' },
        yaml = { 'prettierd' },
        markdown = { 'prettierd' },
        graphql = { 'prettierd' },
        go = { 'gofmt', 'goimports' },
      },
    },
  },

  { -- Autocompletion
    'saghen/blink.cmp',
    event = 'VimEnter',
    version = '1.*',
    dependencies = {
      'folke/lazydev.nvim',
    },
    --- @module 'blink.cmp'
    --- @type blink.cmp.Config
    opts = {
      keymap = {
        preset = 'super-tab',
        -- preset = 'default',
        ['<C-e>'] = { 'show', 'show_documentation', 'hide_documentation' },
      },

      appearance = {
        nerd_font_variant = 'mono',
      },

      completion = {
        -- Controls the visibility of the completion menu
        menu = { auto_show = true },

        -- Documentation settings
        documentation = { auto_show = false },

        -- Update trigger settings (optional, but consistent with manual mode)
        trigger = { show_on_keyword = true },

        list = {
          selection = {
            preselect = true,
            auto_insert = true,
          },
        },
      },

      sources = {
        default = function()
          return { 'lsp', 'path', 'lazydev' }
        end,
        providers = {
          lazydev = { module = 'lazydev.integrations.blink', score_offset = 100 },
        },
        transform_items = function(_, items)
          return vim.tbl_filter(function(item)
            return item.kind ~= require('blink.cmp.types').CompletionItemKind.Snippet
          end, items)
        end,
      },

      snippets = {},

      -- Blink.cmp includes an optional, recommended rust fuzzy matcher,
      -- which automatically downloads a prebuilt binary when enabled.
      --
      -- By default, we use the Lua implementation instead, but you may enable
      -- the rust implementation via `'prefer_rust_with_warning'`
      --
      -- See :h blink-cmp-config-fuzzy for more information
      fuzzy = { implementation = 'prefer_rust' },

      -- Shows a signature help window while you type arguments for a function
      signature = { enabled = false },
    },
  },
  { -- Highlight, edit, and navigate code
    'nvim-treesitter/nvim-treesitter',
    dependencies = {
      'nvim-treesitter/nvim-treesitter-textobjects',
    },
    build = ':TSUpdate',
    main = 'nvim-treesitter.configs', -- Sets main module to use for opts
    opts = {
      ensure_installed = { 'bash', 'go', 'diff', 'html', 'lua', 'luadoc', 'markdown', 'markdown_inline', 'query', 'vim', 'vimdoc', 'python', 'zig' },
      -- Autoinstall languages that are not installed
      auto_install = true,
      highlight = {
        enable = true,
      },
      textobjects = {
        select = {
          enable = true,
          lookahead = true, -- automatically jump forward to textobj
          keymaps = {
            ['af'] = '@function.outer',
            ['if'] = '@function.inner',
            ['ac'] = '@class.outer',
            ['ic'] = '@class.inner',
          },
        },
        move = {
          enable = true,
          set_jumps = true,
          goto_next_start = {
            [']f'] = '@function.outer',
            [']c'] = '@class.outer',
          },
          goto_previous_start = {
            ['[f'] = '@function.outer',
            ['[c'] = '@class.outer',
          },
        },
      },
      indent = { enable = true, disable = { 'ruby' } },
    },
  },
}

-- Smart indentation rules by filetype
vim.api.nvim_create_autocmd('FileType', {
  pattern = { 'javascript', 'typescript', 'javascriptreact', 'typescriptreact', 'css', 'scss', 'html', 'json', 'yaml' },
  callback = function()
    vim.bo.expandtab = true -- use spaces instead of tabs
    vim.bo.tabstop = 2 -- show tabs as 2 spaces
    vim.bo.shiftwidth = 2 -- indentation size
    vim.bo.softtabstop = 2
  end,
})

vim.api.nvim_create_autocmd('FileType', {
  pattern = { 'python', 'htmldjango', 'c' },
  callback = function()
    vim.bo.expandtab = true
    vim.bo.tabstop = 4
    vim.bo.shiftwidth = 4
    vim.bo.softtabstop = 4
  end,
})

vim.api.nvim_create_autocmd('FileType', {
  pattern = { 'go' },
  callback = function()
    vim.bo.expandtab = false
    vim.bo.tabstop = 4
    vim.bo.shiftwidth = 4
    vim.bo.softtabstop = 0
  end,
})

-- Disable all background colors
vim.api.nvim_set_hl(0, 'Normal', { bg = 'none' })
vim.api.nvim_set_hl(0, 'NormalFloat', { bg = 'none' })
vim.api.nvim_set_hl(0, 'SignColumn', { bg = 'none' })
vim.api.nvim_set_hl(0, 'LineNr', { bg = 'none' })
vim.api.nvim_set_hl(0, 'EndOfBuffer', { bg = 'none' })

-- Set selection color for telescope
vim.api.nvim_set_hl(0, 'TelescopeSelection', { bg = '#e0e0e0', fg = '#000000' })

-- The line beneath this is called `modeline`. See `:help modeline`
-- vim: ts=2 sts=2 sw=2 et
