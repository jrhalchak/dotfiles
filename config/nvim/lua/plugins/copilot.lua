return {
  {
    "CopilotC-Nvim/CopilotChat.nvim",
    dependencies = {
      { "zbirenbaum/copilot.lua" }, -- or github/copilot.vim
      { "nvim-lua/plenary.nvim", branch = "master" }, -- for curl, log and async functions
    },
    -- build = "make tiktoken", -- Only on MacOS or Linux
    -- opts = {
    --   -- See Configuration section for options
    -- },
    -- See Commands section for default commands if you want to lazy load on them
    config = function()
      require"copilot".setup{}

      local base_prompt = require('CopilotChat.config.prompts').COPILOT_BASE.system_prompt

      require"CopilotChat".setup({
        -- debug = true,
        -- Raw values for default settings
        -- model = "claude-sonnet-4",
        model = "gpt-4.1",
        context = { "files", "buffers" },
        system_prompt = [[# Professional Coding Assistant

          You are an elite software engineering assistant specializing in web development. Generate production-ready code following these strict guidelines:

          ## Core Principles
          - Deliver optimal, production-grade code with zero technical debt
          - Take complete ownership of all generated solutions
          - Implement precise solutions that exactly match requirements
          - Focus exclusively on current scope without future speculation
          - Rigorously apply DRY and KISS principles in all code
          - Create intuitive, maintainable code with minimal line count
          - Prioritize readability and developer experience

          ## Technical Standards
          - Never include comments in code that indicate someone else should complete the code
          - Eliminate all boilerplate and redundant code
          - Write self-documenting code with descriptive naming
          - Follow industry best practices and design patterns
          - Structure components for maximum reusability
          - Optimize for performance without sacrificing readability
          - Handle edge cases and errors elegantly

          ## Technical Expertise
          - Tailwind CSS (utility-first approach, component design, responsive layouts)
          - Node.js (RESTful APIs, authentication, file operations, asynchronous patterns)
          - JavaScript (ES6+, state management, DOM manipulation, data processing)
          - React (component architecture, hooks, context, performance optimization)
          - Lit Web Components (component architecture, reactive properties, state, DOM manipulation, render cycles, performance optimization)

          ## Response Format
          - Provide complete, executable code solutions
          - Present clean, minimalist implementations
          - Focus on essential logic without unnecessary abstractions
          - Structure code for maximum maintainability and extensibility
          - Eliminate any redundant or speculative elements]] .. base_prompt
      })
    end
  },
  -- {
  --   "zbirenbaum/copilot.lua",
  --   -- Remove once https://github.com/LazyVim/LazyVim/pull/5900 is released
  --   opts = function()
  --     require("copilot.api").status = require("copilot.status")
  --   end,
  -- },
{
		{
			"ravitemer/mcphub.nvim",
			dependencies = {
				"nvim-lua/plenary.nvim",
			},
			build = "npm install -g mcp-hub@latest",
			config = function()
				require("mcphub").setup({
					port = 5999,
					config = vim.fn.expand("~/.config/lvim/lvim-mcp-servers.json"),
				})
			end,
		},
	},
	-- {
	-- 	"yetone/avante.nvim",
	-- 	event = "VeryLazy",
	-- 	version = false, -- Never set this value to "*"! Never!
	-- 	opts = {
	-- 		-- for example
	-- 		provider = "copilot",
	-- 		copilot = {
	-- 			-- model = "claude-3.7-sonnet-thought", -- your desired model (or use gpt-4o, etc.)
	-- 			model = "claude-3.5-sonnet", -- your desired model (or use gpt-4o, etc.)
	-- 		},
	-- 		-- The system_prompt type supports both a string and a function that returns a string. Using a function here allows dynamically updating the prompt with mcphub
	-- 		system_prompt = function()
	-- 			local hub = require("mcphub").get_hub_instance()
	-- 			return hub:get_active_servers_prompt()
	-- 		end,
	-- 		-- The custom_tools type supports both a list and a function that returns a list. Using a function here prevents requiring mcphub before it's loaded
	-- 		custom_tools = function()
	-- 			return {
	-- 				require("mcphub.extensions.avante").mcp_tool(),
	-- 			}
	-- 		end,
	-- 	},
	-- 	-- if you want to build from source then do `make BUILD_FROM_SOURCE=true`
	-- 	build = "make",
	-- 	-- build = "powershell -ExecutionPolicy Bypass -File Build.ps1 -BuildFromSource false" -- for windows
	-- 	dependencies = {
	-- 		"nvim-treesitter/nvim-treesitter",
	-- 		"stevearc/dressing.nvim",
	-- 		"nvim-lua/plenary.nvim",
	-- 		"MunifTanjim/nui.nvim",
	-- 		"nvim-telescope/telescope.nvim", -- for file_selector provider telescope
	-- 		"hrsh7th/nvim-cmp", -- autocompletion for avante commands and mentions
	-- 		"nvim-tree/nvim-web-devicons", -- or echasnovski/mini.icons
	-- 		{
	-- 			"zbirenbaum/copilot.lua",
	-- 			config = function()
	-- 				require("copilot").setup({})
	-- 			end,
	-- 			build = ":Copilot auth",
	-- 		},
	-- 		{
	-- 			-- support for image pasting
	-- 			"HakonHarnes/img-clip.nvim",
	-- 			event = "VeryLazy",
	-- 			opts = {
	-- 				-- recommended settings
	-- 				default = {
	-- 					embed_image_as_base64 = false,
	-- 					prompt_for_file_name = false,
	-- 					drag_and_drop = {
	-- 						insert_mode = true,
	-- 					},
	-- 					-- required for Windows users
	-- 					use_absolute_path = true,
	-- 				},
	-- 			},
	-- 		},
	-- 		{
	-- 			-- Make sure to set this up properly if you have lazy=true
	-- 			"MeanderingProgrammer/render-markdown.nvim",
	-- 			opts = {
	-- 				file_types = { "markdown", "Avante" },
	-- 			},
	-- 			ft = { "markdown", "Avante" },
	-- 		},
	-- 	},
	-- },
	{
		"olimorris/codecompanion.nvim",
		dependencies = {
			{ "nvim-treesitter/nvim-treesitter", build = ":TSUpdate" },
			{ "nvim-lua/plenary.nvim" },
			-- Test with blink.cmp
			{
				"saghen/blink.cmp",
				lazy = false,
				version = "*",
				opts = {
					keymap = {
						preset = "enter",
						["<S-Tab>"] = { "select_prev", "fallback" },
						["<Tab>"] = { "select_next", "fallback" },
					},
					cmdline = { sources = { "cmdline" } },
					sources = {
						default = { "lsp", "path", "buffer", "codecompanion" },
					},
				},
			},
			-- Test with nvim-cmp
			-- { "hrsh7th/nvim-cmp" },
		},
		opts = {
			--Refer to: https://github.com/olimorris/codecompanion.nvim/blob/main/lua/codecompanion/config.lua
			strategies = {
				--NOTE: Change the adapter as required
				chat = {
					adapter = "copilot",
					tools = {
						["mcp"] = {
							callback = function()
								return require("mcphub.extensions.codecompanion")
							end,
							description = "Call tools and resources from the MCP Servers",
							opts = {
								requires_approval = true,
							},
						},
					},
				},
				inline = { adapter = "copilot" },
			},
			opts = {
				log_level = "DEBUG",
			},
		},
	},
}

