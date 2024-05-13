return {
  {
    "nvim-treesitter/nvim-treesitter",
    ensure_installed = {
      "lua",
      "luadoc",
      "vim",
      "vimdoc",
      "git_rebase",
      "gitcommit",
      "gitignore",
      "bash",
      "html",
      "css",
      "scss",
      "json",
      "jsdoc",
      "javascript",
      "typescript",
      "make",
      "markdown",
      "markdown_inline",
      "mermaid",
      "python",
      "regex",
      "sql",
      "ssh_config",
      "terraform",
      "yaml",
    },
    build = ":TSUpdate",
    opts = {
      auto_install = true,
      highlight = {
        enable = true,
        additional_vim_regex_highlighting = false,
      },
    },
    config = function(_, opts)
      require("nvim-treesitter.configs").setup(opts)
    end,
  },
}
