-- TODO
-- Dynamically set locations based on env var? Different configs?
-- Solve this... maybe org-mode already does?

return {
  {
    'nvim-orgmode/orgmode',
    event = 'VeryLazy',
    ft = { 'org' },
    tag = "0.3.4", -- must be kept locked w/ org-roam
    config = function()
      -- Setup orgmode
      require('orgmode').setup({
        org_agenda_files = '~/orgfiles/**/*',
        org_default_notes_file = '~/orgfiles/refile.org',
      })
    end,
  },
  {
    "chipsenkbeil/org-roam.nvim",
    tag = "0.1.0",
    dependencies = {
      {
        "nvim-orgmode/orgmode",
        tag = "0.3.4", -- must be kept locked w/ org-roam
      },
    },
    config = function()
      require("org-roam").setup({
        directory = "~/org_roam_files",
        -- optional
        org_files = {
          "~/another_org_dir",
          "~/some/folder/*.org",
          "~/a/single/org_file.org",
        }
      })
    end
  },
  {
    "nvim-orgmode/telescope-orgmode.nvim",
    event = "VeryLazy",
    dependencies = {
      "nvim-orgmode/orgmode",
      "nvim-telescope/telescope.nvim",
    },
    config = function()
      require("telescope").load_extension("orgmode")
    end,
  },
}
