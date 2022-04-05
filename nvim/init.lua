-- Install packer
local install_path = vim.fn.stdpath('data') .. '/site/pack/packer/start/packer.nvim'
local packer_bootstrap = false

if vim.fn.empty(vim.fn.glob(install_path)) > 0 then
  packer_bootstrap = vim.fn.system({'git', 'clone', 'https://github.com/wbthomason/packer.nvim', install_path})
end

vim.cmd [[
  augroup Packer
    autocmd!
    autocmd BufWritePost init.lua PackerCompile
  augroup end
]]
-- function to create <leader> keymappings
local map_normal = function(keys, mapping)
  vim.api.nvim_set_keymap('n', keys, mapping, { noremap = true, silent = true })
end
local map_buf_normal = function(bufnr, keys, mapping)
  vim.api.nvim_buf_set_keymap(bufnr, 'n', keys, mapping, { noremap = true, silent = true })
end

require('packer').startup(function(use)
  use 'wbthomason/packer.nvim' -- Package manager

  use { -- Git commands & options
    'tpope/vim-fugitive',
    'tpope/vim-rhubarb', -- Fugitive-companion to interact with github
    {
      'lewis6991/gitsigns.nvim', -- Show git info in sign column & popups
      requires = { 'nvim-lua/plenary.nvim' },
      config = function ()
        vim.wo.signcolumn = 'yes'
        require('gitsigns').setup {
          signs = {
            add = { text = '+' },
            change = { text = '~' },
            delete = { text = '_' },
            topdelete = { text = '‾' },
            changedelete = { text = '~' },
          },
        }
      end,
    },
  }

  use { -- "gc" to comment visual regions/lines
    'numToStr/Comment.nvim',
    config = function() require('Comment').setup() end,
  }

  use 'ludovicchabant/vim-gutentags' -- Automatic tags management

  use { -- UI to select things (files, grep results, open buffers...)
    { 'nvim-telescope/telescope.nvim', requires = { 'nvim-lua/plenary.nvim' } },
    { 'nvim-telescope/telescope-fzf-native.nvim', run = 'make' },
    config = function()
      require('telescope').setup {
        defaults = {
          mappings = {
            i = {
              ['<C-u>'] = false,
              ['<C-d>'] = false,
            },
          },
        },
      }

      -- Enable telescope fzf native
      require('telescope').load_extension 'fzf'

      local map_telescope = function (key, map) map_normal(key, [[<cmd>lua require('telescope.builtin').]] .. map) end

      map_telescope('<leader><space>', 'buffers()<CR>')
      map_telescope('<leader>sf', 'find_files()<CR>')
      map_telescope('<leader>sh', 'help_tags()<CR>')
      map_telescope('<leader>st', 'tags()<CR>')
      map_telescope('<leader>sd', 'grep_string()<CR>')
      map_telescope('<leader>sp', 'live_grep()<CR>')
      map_telescope('<leader>?', 'oldfiles()<CR>')
      map_telescope('<leader>sb', 'current_buffer_fuzzy_find()<CR>')
      map_telescope('<leader>so', 'tags{ only_current_buffer = true }<CR>')
    end,
  }

  use { -- Theming
    { -- Theme inspired by Atom
      'mjlbach/onedark.nvim',
      config = function()
        vim.o.termguicolors = true
        vim.cmd [[colorscheme onedark]]
      end,
    },
    { -- Fancier statusline
      'nvim-lualine/lualine.nvim',
      config = function()
        require('lualine').setup {
          options = {
            icons_enabled = false,
            theme = 'onedark',
            component_separators = '|',
            section_separators = '',
          },
        }
      end,
    },
  }

  use 'lukas-reineke/indent-blankline.nvim' -- Add indentation guides even on blank lines

  use { -- Treesitter
    -- Highlight, edit, and navigate code using a fast incremental parsing library
    'nvim-treesitter/nvim-treesitter',
    'nvim-treesitter/nvim-treesitter-textobjects', -- Additional textobjects for treesitter
    config = function ()
      -- Parsers must be installed manually via :TSInstall
      -- Example -> :TSInstall all
      require('nvim-treesitter.configs').setup {
        highlight = {
          enable = true, -- false will disable the whole extension
        },
        incremental_selection = {
          enable = true,
          keymaps = {
            init_selection = 'gnn',
            node_incremental = 'grn',
            scope_incremental = 'grc',
            node_decremental = 'grm',
          },
        },
        indent = {
          enable = true,
        },
        textobjects = {
          select = {
            enable = true,
            lookahead = true, -- Automatically jump forward to textobj, similar to targets.vim
            keymaps = {
              -- You can use the capture groups defined in textobjects.scm
              ['af'] = '@function.outer',
              ['if'] = '@function.inner',
              ['ac'] = '@class.outer',
              ['ic'] = '@class.inner',
            },
          },
          move = {
            enable = true,
            set_jumps = true, -- whether to set jumps in the jumplist
            goto_next_start = {
              [']m'] = '@function.outer',
              [']]'] = '@class.outer',
            },
            goto_next_end = {
              [']M'] = '@function.outer',
              [']['] = '@class.outer',
            },
            goto_previous_start = {
              ['[m'] = '@function.outer',
              ['[['] = '@class.outer',
            },
            goto_previous_end = {
              ['[M'] = '@function.outer',
              ['[]'] = '@class.outer',
            },
          },
        },
      }
    end,
  }

  use { -- LSP Installation & Config
    'neovim/nvim-lspconfig', -- Collection of configurations for built-in LSP client
    'williamboman/nvim-lsp-installer', -- LspInstall command
    config = function()
      -- LSP must be installed manually via :LspInstall
      -- Example -> :LspInstall sumneko_lua bashls cssmodules_ls dockerls gopls tsserver remark_ls spectral pyright rust_analyzer taplo
      require('nvim-lsp-installer').on_server_ready(function (server)
        local opts = {
          on_attach = function(_, bufnr)
            map_buf_normal(bufnr, 'gD', '<cmd>lua vim.lsp.buf.declaration()<CR>')
            map_buf_normal(bufnr, 'gd', '<cmd>lua vim.lsp.buf.definition()<CR>')
            map_buf_normal(bufnr, 'K', '<cmd>lua vim.lsp.buf.hover()<CR>')
            map_buf_normal(bufnr, 'gi', '<cmd>lua vim.lsp.buf.implementation()<CR>')
            map_buf_normal(bufnr, '<C-k>', '<cmd>lua vim.lsp.buf.signature_help()<CR>')
            map_buf_normal(bufnr, '<leader>wa', '<cmd>lua vim.lsp.buf.add_workspace_folder()<CR>')
            map_buf_normal(bufnr, '<leader>wr', '<cmd>lua vim.lsp.buf.remove_workspace_folder()<CR>')
            map_buf_normal(bufnr, '<leader>wl', '<cmd>lua print(vim.inspect(vim.lsp.buf.list_workspace_folders()))<CR>')
            map_buf_normal(bufnr, '<leader>D', '<cmd>lua vim.lsp.buf.type_definition()<CR>')
            map_buf_normal(bufnr, '<leader>rn', '<cmd>lua vim.lsp.buf.rename()<CR>')
            map_buf_normal(bufnr, 'gr', '<cmd>lua vim.lsp.buf.references()<CR>')
            map_buf_normal(bufnr, '<leader>ca', '<cmd>lua vim.lsp.buf.code_action()<CR>')
            map_buf_normal(bufnr, '<leader>so', [[<cmd>lua require('telescope.builtin').lsp_document_symbols()<CR>]])
            vim.cmd [[ command! Format execute 'lua vim.lsp.buf.formatting()' ]]
          end,
        }

        if server.name == "sumneko_lua" or server.name == "lua" then
          opts.settings = { Lua = {
            runtime = { version = 'LuaJIT', },
            diagnostics = { globals = { 'vim' }, },
          } }
        end

        server:setup(opts)
      end)
    end
  }

  use { -- Autocompletion + Snippets
    'hrsh7th/nvim-cmp', -- Autocompletion plugin
    'L3MON4D3/LuaSnip', -- Snippets plugin
    'hrsh7th/cmp-nvim-lsp', -- cmp-lsp integration plugin
    'saadparwaiz1/cmp_luasnip', -- cmd-luasnip integration plugin
    config = function() -- nvim-cmp + luasnip setup
      -- nvim-cmp supports additional completion capabilities through LSP
      local capabilities = vim.lsp.protocol.make_client_capabilities()
      capabilities = require('cmp_nvim_lsp').update_capabilities(capabilities)

      local luasnip = require 'luasnip'
      local cmp = require 'cmp'
      cmp.setup {
        snippet = {
          expand = function(args)
            luasnip.lsp_expand(args.body)
          end,
        },
        mapping = {
          ['<C-p>'] = cmp.mapping.select_prev_item(),
          ['<C-n>'] = cmp.mapping.select_next_item(),
          ['<C-d>'] = cmp.mapping.scroll_docs(-4),
          ['<C-f>'] = cmp.mapping.scroll_docs(4),
          ['<C-Space>'] = cmp.mapping.complete(),
          ['<C-e>'] = cmp.mapping.close(),
          ['<CR>'] = cmp.mapping.confirm {
            behavior = cmp.ConfirmBehavior.Replace,
            select = true,
          },
          ['<Tab>'] = function(fallback)
            if cmp.visible() then
              cmp.select_next_item()
            elseif luasnip.expand_or_jumpable() then
              luasnip.expand_or_jump()
            else
              fallback()
            end
          end,
          ['<S-Tab>'] = function(fallback)
            if cmp.visible() then
              cmp.select_prev_item()
            elseif luasnip.jumpable(-1) then
              luasnip.jump(-1)
            else
              fallback()
            end
          end,
        },
        sources = {
          { name = 'nvim_lsp' },
          { name = 'luasnip' },
        },
      }
    end,
  }

  if packer_bootstrap then require('packer').sync() end
end)

-- Other settings

--Set highlight on search
vim.o.hlsearch = false
--Make line numbers default
vim.wo.number = true
--Enable mouse mode
vim.o.mouse = 'a'
--Enable break indent
vim.o.breakindent = true
--Save undo history
vim.opt.undofile = true
--Case insensitive searching UNLESS /C or capital in search
vim.o.ignorecase = true
vim.o.smartcase = true
--Decrease update time
vim.o.updatetime = 250
-- Set completeopt to have a better completion experience
vim.o.completeopt = 'menuone,noselect'

--Remap space as leader key
vim.api.nvim_set_keymap('', '<Space>', '<Nop>', { noremap = true, silent = true })
vim.g.mapleader = ' '
vim.g.maplocalleader = ' '

--Remap for dealing with word wrap
local opts = { noremap = true, expr = true, silent = true }
vim.api.nvim_set_keymap('n', 'k', "v:count == 0 ? 'gk' : 'k'", opts)
vim.api.nvim_set_keymap('n', 'j', "v:count == 0 ? 'gj' : 'j'", opts)

-- Highlight on yank
vim.cmd [[
  augroup YankHighlight
    autocmd!
    autocmd TextYankPost * silent! lua vim.highlight.on_yank()
  augroup end
]]

--Map blankline
vim.g.indent_blankline_char = '┊'
vim.g.indent_blankline_filetype_exclude = { 'help', 'packer' }
vim.g.indent_blankline_buftype_exclude = { 'terminal', 'nofile' }
vim.g.indent_blankline_show_trailing_blankline_indent = false

-- Diagnostic keymaps
map_normal('<leader>e', '<cmd>lua vim.diagnostic.open_float()<CR>')
map_normal('[d', '<cmd>lua vim.diagnostic.goto_prev()<CR>')
map_normal(']d', '<cmd>lua vim.diagnostic.goto_next()<CR>')
map_normal('<leader>q', '<cmd>lua vim.diagnostic.setloclist()<CR>')

-- Quickfix keymaps
map_normal(']c', '<cmd>cnext<CR>')
map_normal('[c', '<cmd>cprevious<CR>')
map_normal('C', '<cmd>cclose<CR>')
