return {
  {
    'brenoprata10/nvim-highlight-colors',
    config = function()
      require("nvim-highlight-colors").setup {
        -- @usage 'background'|'foreground'|'virtual'
        render = 'virtual',

        -- Set virtual symbol (requires render to be set to 'virtual')
        virtual_symbol = '',
        virtual_symbol_prefix = '',
        virtual_symbol_suffix = ' ',

        -- @usage 'inline'|'eol'|'eow'
        virtual_symbol_position = 'inline'
      }
    end
  }
}
