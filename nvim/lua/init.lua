vim.g.mapleader = " "
vim.o.number = true
vim.o.relativenumber = true
vim.o.cursorline = true
vim.o.tabstop = 2
vim.o.shiftwidth = 2
vim.o.softtabstop = 2
vim.o.expandtab = true
vim.o.ignorecase = true
vim.o.incsearch = true
vim.o.hlsearch = true
vim.o.updatetime = 300
vim.o.incsearch = false
vim.wo.signcolumn = 'yes'
vim.opt.termguicolors = true
vim.cmd [[
set mouse=
set completeopt-=preview

sign define DiagnosticSignError text= linehl= texthl=DiagnosticSignError numhl=
sign define DiagnosticSignWarn text= linehl= texthl=DiagnosticSignWarn numhl=
sign define DiagnosticSignInfo text= linehl= texthl=DiagnosticSignInfo numhl=
sign define DiagnosticSignHint text=💡 linehl= texthl=DiagnosticSignHint numhl=
]]

vim.g.loaded_netrw = 1
vim.g.loaded_netrwPlugin = 1
require("nvim-tree").setup {
  open_on_setup = true,
  view = {
    adaptive_size = true,
  },
  update_focused_file = {
    enable = true
  },
  diagnostics = {
    enable = true
  }
}

local opts = { noremap = true, silent = true }
require 'fzf_lsp'.setup {
  override_ui_select = true
}

vim.keymap.set('n', '<leader>t', '<cmd>:Files<cr>', opts)
vim.keymap.set('n', '<leader>g', '<cmd>:Rg<cr>', opts)
vim.keymap.set('n', '<leader>b', '<cmd>:Buffers<cr>', opts)
vim.keymap.set('n', '<leader>h', '<cmd>:Helptags<cr>', opts)

vim.cmd [[
let g:fzf_action = {
      \ 'ctrl-t': 'tab split',
      \ 'ctrl-h': 'split',
      \ 'ctrl-v': 'vsplit'
  \ }
]]

require('kanagawa').setup({
  transparent = true
})
vim.cmd("colorscheme kanagawa")

require('lualine').setup({
  options = {
    disabled_filetypes = { "NvimTree" },
  },
  sections = {
    lualine_c = {
      'lsp_progress'
    }
  }
})

require('gitsigns').setup({
  current_line_blame = true
})

require 'nvim-treesitter.configs'.setup {
  highlight = {
    enable = true
  }
}

require("null-ls").setup({
  sources = {
    require("null-ls").builtins.formatting.prettierd,
    require("null-ls").builtins.diagnostics.markdownlint,
  }
})

require 'trouble'.setup()

local cmp = require 'cmp'
local luasnip = require 'luasnip'

cmp.setup({
  snippet = {
    -- REQUIRED - you must specify a snippet engine
    expand = function(args)
      -- vim.fn["vsnip#anonymous"](args.body) -- For `vsnip` users.
      require('luasnip').lsp_expand(args.body) -- For `luasnip` users.
      -- require('snippy').expand_snippet(args.body) -- For `snippy` users.
      -- vim.fn["UltiSnips#Anon"](args.body) -- For `ultisnips` users.
    end,
  },
  window = {
    -- completion = cmp.config.window.bordered(),
    -- documentation = cmp.config.window.bordered(),
  },
  mapping = cmp.mapping.preset.insert({
    ['<C-b>'] = cmp.mapping.scroll_docs(-4),
    ['<C-f>'] = cmp.mapping.scroll_docs(4),
    ['<C-Space>'] = cmp.mapping.complete(),
    ['<CR>'] = cmp.mapping.confirm {
      behavior = cmp.ConfirmBehavior.Replace,
      select = true
    },
    ['<Tab>'] = cmp.mapping(function(fallback)
      if cmp.visible() then
        cmp.select_next_item()
      elseif luasnip.expand_or_jumpable() then
        luasnip.expand_or_jump()
      else
        fallback()
      end
    end, { 'i', 's' }),

    ['<S-Tab>'] = cmp.mapping(function(fallback)
      if cmp.visible() then
        cmp.select_prev_item()
      elseif luasnip.jumpable(-1) then
        luasnip.jump(-1)
      else
        fallback()
      end
    end, { 'i', 's' })

  }),
  sources = cmp.config.sources({
    { name = 'nvim_lsp' },
    -- { name = 'vsnip' }, -- For vsnip users.
    { name = 'luasnip' }, -- For luasnip users.
    -- { name = 'ultisnips' }, -- For ultisnips users.
    -- { name = 'snippy' }, -- For snippy users.
  }, {
    { name = 'buffer' },
    { name = 'nvim_lsp_signature_help' }
  })
})

-- Set configuration for specific filetype.
cmp.setup.filetype('gitcommit', {
  sources = cmp.config.sources({
    { name = 'cmp_git' }, -- You can specify the `cmp_git` source if you were installed it.
  }, {
    { name = 'buffer' },
  })
})

-- Use buffer source for `/` and `?` (if you enabled `native_menu`, this won't work anymore).
cmp.setup.cmdline({ '/', '?' }, {
  mapping = cmp.mapping.preset.cmdline(),
  sources = {
    { name = 'buffer' }
  }
})

-- Use cmdline & path source for ':' (if you enabled `native_menu`, this won't work anymore).
cmp.setup.cmdline(':', {
  mapping = cmp.mapping.preset.cmdline(),
  sources = cmp.config.sources({
    { name = 'path' }
  }, {
    { name = 'cmdline' }
  })
})

-- Set up lspconfig.
local capabilities = require('cmp_nvim_lsp').default_capabilities()

vim.keymap.set('n', '<space>e', vim.diagnostic.open_float, opts)
vim.keymap.set('n', '[d', vim.diagnostic.goto_prev, opts)
vim.keymap.set('n', ']d', vim.diagnostic.goto_next, opts)
vim.keymap.set('n', '<space>q', vim.diagnostic.setloclist, opts)

vim.cmd [[
autocmd FileType java lua require'jdtls_setup'.setup()
]]

local servers = {
  'gopls',
  'tsserver',
  'sumneko_lua',
  'pyright',
  'astro',
  'ltex',
  'eslint',
  'cssls',
  'html',
  'jsonls',
  'rnix',
  'ccls'
}

local default_lspopts = {
  capabilities = capabilities,
  on_attach = require 'common'.on_attach
}

for _, lsp in ipairs(servers) do
  local lspopts = default_lspopts
  if lsp == 'sumneko_lua' then
    lspopts.settings = {
      Lua = {
        diagnostics = {
          globals = { 'vim' },
        },
        workspace = {
          -- Make the server aware of Neovim runtime files
          library = vim.api.nvim_get_runtime_file("", true),
          checkThirdParty = false
        },
      },
    }
  elseif lsp == 'ltex' then
    lspopts.settings = {
      ltex = {
        language = "en-GB"
      }
    }
  end
  require 'lspconfig'[lsp].setup(lspopts)
end
