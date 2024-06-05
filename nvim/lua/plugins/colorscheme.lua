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
          hl['CocFloating'] = { bg = c.bg_highlight }
          hl['CocFloatingBorder'] = { fg = c.fg_dark, bg = c.bg }
          -- hl['DiffAdd'] = { fg = c.gitSigns.add }
          -- hl['DiffChange'] = { fg = c.gitSigns.change }
          -- hl['DiffDelete'] = { fg = c.gitSigns.delete }
          hl['DiffAdd'] = { fg = c.git.add }
          hl['DiffChange'] = { fg = c.git.change }
          hl['DiffDelete'] = { fg = c.git.delete }
        end,
      }
      vim.cmd('colorscheme tokyonight-night')
    end
  },
}
