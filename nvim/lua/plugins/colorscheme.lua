return {
  {
    'folke/tokyonight.nvim',
    lazy = false,
    priority = 1000,
    opts = {},
    config = function()
      require('tokyonight').setup {
        -- use the night style
        style = 'night',
        transparent = true,
        -- Style to be applied to different syntax groups
        styles = {
          -- Value is any valid attr-list value for `:help nvim_set_hl`
          comments = { italic = true },
          keywords = { italic = true },
        },
        sidebars = { 'qf', 'vista_kind', 'terminal', 'packer' },
        -- Change the 'hint' color to the 'orange' color, and make the 'error' color bright red
        -- on_colors = function(colors)
        --   colors.hint = colors.orange
        --   colors.error = '#ff0000'
        -- end
        on_highlights = function(hl, c)
          -- hl['@some.treesitter.hlgroup'] = { undercurl = true, strikethrough = true, sp = '#ffffff', fg = c.fg_dark, bg = c.bg_dark }
          hl['netrwTreeBar'] = { fg = c.dark3 }
        end,
      }
      vim.cmd('colorscheme tokyonight-night')
    end
  },
}
