return {
  {
    "nvim-mini/mini.ai",
    opts = function()
      local ai = require("mini.ai")
      return {
        n_lines = 500,
        mappings = {
          around_last = "",
          inside_last = "",
        },
        custom_textobjects = {
          o = ai.gen_spec.treesitter({ -- code block
            a = { "@block.outer", "@conditional.outer", "@loop.outer" },
            i = { "@block.inner", "@conditional.inner", "@loop.inner" },
          }),
          f = ai.gen_spec.treesitter({ a = "@function.outer", i = "@function.inner" }), -- function
          c = ai.gen_spec.treesitter({ a = "@class.outer", i = "@class.inner" }), -- class
          t = { "<([%p%w]-)%f[^<%w][^<>]->.-</%1>", "^<.->().*()</[^/]->$" }, -- tags
          d = { "%f[%d]%d+" }, -- digits
          e = { -- Word with case
            { "%u[%l%d]+%f[^%l%d]", "%f[%S][%l%d]+%f[^%l%d]", "%f[%P][%l%d]+%f[^%l%d]", "^[%l%d]+%f[^%l%d]" },
            "^().*()$",
          },
          i = LazyVim.mini.ai_indent, -- indent
          g = LazyVim.mini.ai_buffer, -- buffer
          u = ai.gen_spec.function_call(), -- u for "Usage"
          U = ai.gen_spec.function_call({ name_pattern = "[%w_]" }), -- without dot in function name
          l = function()
            local current_line = vim.fn.line(".")
            local first_char_col = vim.fn.getline("."):find("%S") or 1
            local end_char_col = vim.fn.getline("."):find("%S%s*$") or 1

            return {
              from = { line = current_line, col = first_char_col },
              to = { line = current_line, col = end_char_col },
            }
          end,
        },
      }
    end,
  },
  {
    "sontungexpt/buffer-closer",
    event = "VeryLazy",
    opts = {
      min_remaining_buffers = 7, -- can not be less than 1
      retirement_minutes = 7, -- can not be less than 1

      -- close the buffer when the given events are triggered (see :h autocmd-events)
      -- if the value is "default", the plugin will use the default events
      -- if the value is "disabled", the plugin will not use any events
      -- if the value is a table, the plugin will use the given events
      events = "default", -- (table, "default", "disabled"):

      timed_check = {
        enabled = false,
        interval_minutes = 1, -- can not be less than 1
      },

      excluded = {
        filetypes = { "lazy", "NvimTree", "mason" },
        buftypes = { "terminal", "nofile", "quickfix", "prompt", "help" },
        filenames = {},
      },

      -- it means that a buffer will not be closed if it is opened in a window
      ignore_working_windows = true,
    },
  },
  {
    "nvim-mini/mini.surround",
    keys = function(_, keys)
      -- Populate the keys based on the user's options
      local opts = LazyVim.opts("mini.surround")
      local mappings = {
        { opts.mappings.add, desc = "Add Surrounding", mode = { "n", "v" } },
        { opts.mappings.delete, desc = "Delete Surrounding" },
        { opts.mappings.find, desc = "Find Right Surrounding" },
        { opts.mappings.find_left, desc = "Find Left Surrounding" },
        { opts.mappings.highlight, desc = "Highlight Surrounding" },
        { opts.mappings.replace, desc = "Replace Surrounding" },
        { opts.mappings.update_n_lines, desc = "Update `MiniSurround.config.n_lines`" },
      }
      mappings = vim.tbl_filter(function(m)
        return m[1] and #m[1] > 0
      end, mappings)

      return vim.list_extend(mappings, keys)
    end,
    opts = {
      mappings = {
        add = "ys", -- Add surrounding in Normal and Visual Modes
        delete = "ds", -- Delete surrounding
        find = "gsf", -- Find surrounding (to the right)
        find_left = "gsF", -- Find surrounding (to the left)
        highlight = "gsh", -- Highlight surrounding
        replace = "cs", -- Replace surrounding
        update_n_lines = "gsn", -- Update `n_lines`
      },
    },
  },
  {
    "inkarkat/vim-ReplaceWithRegister",
    vscode = true,
    dependencies = {
      { "inkarkat/vim-ingo-library" },
    },
  },

  {
    "junegunn/vim-easy-align",
    vscode = true,
    config = function()
      vim.keymap.set("x", "ga", "<Plug>(EasyAlign)")
      vim.keymap.set("n", "gaip", "<Plug>(EasyAlign)ip")
      vim.keymap.set("n", "gaap", "<Plug>(EasyAlign)ip")
    end,
  },
  {
    "tommcdo/vim-exchange",
    vscode = true,
    config = function()
      vim.keymap.set("x", "X", "<Plug>(Exchange)")
    end,
  },
  {
    "esmuellert/codediff.nvim",
    cmd = "CodeDiff",
  },
  {
    "NeogitOrg/neogit",
    lazy = true,
    dependencies = {
      "esmuellert/codediff.nvim", -- optional

      "nvim-telescope/telescope.nvim", -- optional
    },
    cmd = "Neogit",
    keys = {
      { "<leader>gg", "<cmd>Neogit<cr>", desc = "Show Neogit UI" },
    },
  },
  {
    "allaman/emoji.nvim",
    version = "1.0.0", -- optionally pin to a tag
    ft = "markdown", -- adjust to your needs
    dependencies = {
      -- optional for nvim-cmp integration
      "hrsh7th/nvim-cmp",
      -- optional for telescope integration
      "nvim-telescope/telescope.nvim",
      -- optional for fzf-lua integration via vim.ui.select
      -- "ibhagwan/fzf-lua",
    },
    opts = {
      -- default is false, also needed for blink.cmp integration!
      enable_cmp_integration = false,
      -- optional if your plugin installation directory
      -- is not vim.fn.stdpath("data") .. "/lazy/
      -- plugin_path = vim.fn.expand("$HOME/plugins/"),
    },
    config = function(_, opts)
      require("emoji").setup(opts)
      -- optional for telescope integration
      local ts = require("telescope").load_extension("emoji")
      vim.keymap.set("n", "<leader>se", ts.emoji, { desc = "[S]earch [E]moji" })
    end,
  },
}
