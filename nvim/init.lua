-- Install packer
local install_path = vim.fn.stdpath('data') .. '/site/pack/packer/start/packer.nvim'
local packer_bootstrap = false

if vim.fn.empty(vim.fn.glob(install_path, nil, nil)) > 0 then
  packer_bootstrap = vim.fn.system({'git', 'clone', 'https://github.com/wbthomason/packer.nvim', install_path})
end

vim.cmd [[
  augroup Packer
    autocmd!
    autocmd BufWritePost init.lua PackerCompile
  augroup end
]]

local map = require'utils'.map

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

  use 'sheerun/vim-polyglot' --coloring and indenting for many programming languages

  use { -- "gc" to comment visual regions/lines
    'numToStr/Comment.nvim',
    config = function()
      require('Comment').setup {}
    end,
  }

  use { -- UI to select things (files, grep results, open buffers...)
    { 'nvim-telescope/telescope.nvim', requires = { 'nvim-lua/plenary.nvim' } },
    { 'nvim-telescope/telescope-fzf-native.nvim', run = 'make' },
  }

  use { -- Theming
    {
      'tanvirtin/monokai.nvim',
      -- Theme inspired by Atom
      'mjlbach/onedark.nvim',
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

  use 'nathom/filetype.nvim' -- fast filetype loading
  use 'vimwiki/vimwiki' -- Vimwiki management
  use 'lukas-reineke/indent-blankline.nvim' -- Add indentation guides even on blank lines

  use { -- Highlight, edit, and navigate code using a fast incremental parsing library
    'nvim-treesitter/nvim-treesitter',
    'nvim-treesitter/nvim-treesitter-textobjects', -- Additional textobjects for treesitter
  }

  use { -- LSP Installation & Config
    "gfanto/fzf-lsp.nvim",
    "folke/lua-dev.nvim",
    { "ray-x/navigator.lua", requires = { "ray-x/guihua.lua", run = "cd lua/fzy && make" } },
    "williamboman/nvim-lsp-installer", -- LspInstall command
    { -- Collection of configurations for built-in LSP client
      "neovim/nvim-lspconfig",
      config = function()
        require("nvim-lsp-installer").setup {
          ensure_installed = {
            "rust_analyzer", "sumneko_lua", "gopls", "tsserver", "prosemd_lsp",
            "spectral", "prismals", "pylsp", "sqlls", "taplo", "tflint","efm",
            "html", "graphql", "dockerls", "cssmodules_ls", "cmake", "bashls",
          },
          automatic_installation = true,
          ui = {
            icons = {
              server_installed = "✓",
              server_pending = "➜",
              server_uninstalled = "✗",
            }
          }
        }

        require'navigator'.setup {}

        local luadev = require'lua-dev'.setup {}
        local lspconfig = require("lspconfig")

        lspconfig.sumneko_lua.setup(luadev)
      end
    }
  }

  use { -- Autocompletion + Snippets
    'hrsh7th/nvim-cmp', -- Autocompletion plugin
    'L3MON4D3/LuaSnip', -- Snippets plugin
    'hrsh7th/cmp-nvim-lsp', -- cmp-lsp integration plugin
    'saadparwaiz1/cmp_luasnip', -- cmd-luasnip integration plugin
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
-- Set default indentation to 2 spaces
vim.o.expandtab = true
vim.o.tabstop = 2
vim.o.softtabstop = 2
vim.o.shiftwidth = 2
vim.g.did_load_filetypes = 1
-- set full color support
vim.o.termguicolors = true
-- set default theme
vim.cmd [[colorscheme monokai_pro]]

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
map{'<leader>e', '<cmd>lua vim.diagnostic.open_float()<CR>'}
map{'[d', '<cmd>lua vim.diagnostic.goto_prev()<CR>'}
map{']d', '<cmd>lua vim.diagnostic.goto_next()<CR>'}
map{'<leader>q', '<cmd>lua vim.diagnostic.setloclist()<CR>'}

-- Quickfix keymaps
map{']c', '<cmd>cnext<CR>'}
map{'[c', '<cmd>cprevious<CR>'}
map{'C', '<cmd>cclose<CR>'}

-- Setup functions
-- require('setup').telescope_setup()
-- require('setup').treesitter_setup()
-- require('setup').completion_setup()
-- require('setup').lsp_setup()

