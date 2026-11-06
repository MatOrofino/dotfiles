---@class ExtPluginLspOpts: PluginLspOpts
---@field ensure_installed string[]

local function get_ts_ensure_installed()
  local arch = vim.fn.system("uname -m"):gsub("\n", "")
  if arch == "x86_64" then
    return {
      "bash",
      "c",
      "diff",
      "html",
      "javascript",
      "jsdoc",
      "json",
      "lua",
      "luadoc",
      "luap",
      "markdown",
      "markdown_inline",
      "printf",
      "python",
      "query",
      "regex",
      "toml",
      "tsx",
      "typescript",
      "vim",
      "vimdoc",
      "xml",
      "yaml",
    }
  else
    return {}
  end
end

return {
  {
    "nvim-treesitter/nvim-treesitter",
    ---@param opts lazyvim.TSConfig
    config = function(_, opts)
      local TS = require("nvim-treesitter")

      setmetatable(require("nvim-treesitter.install"), {
        __newindex = function(_, k)
          if k == "compilers" then
            vim.schedule(function()
              LazyVim.error({
                "Setting custom compilers for `nvim-treesitter` is no longer supported.",
                "",
                "For more info, see:",
                "- [compilers](https://docs.rs/cc/latest/cc/#compile-time-requirements)",
              })
            end)
          end
        end,
      })

      -- some quick sanity checks
      if not TS.get_installed then
        return LazyVim.error("Please use `:Lazy` and update `nvim-treesitter`")
      elseif type(opts.ensure_installed) ~= "table" then
        return LazyVim.error("`nvim-treesitter` opts.ensure_installed must be a table")
      end

      -- setup treesitter
      TS.setup(opts)
      LazyVim.treesitter.get_installed(true) -- initialize the installed langs

      -- install missing parsers
      local install = vim.tbl_filter(function(lang)
        return not LazyVim.treesitter.have(lang)
      end, get_ts_ensure_installed() or {})
      if #install > 0 then
        LazyVim.treesitter.ensure_treesitter_cli(function()
          TS.install(install, { summary = true }):await(function()
            LazyVim.treesitter.get_installed(true) -- refresh the installed langs
          end)
        end)
      end

      vim.api.nvim_create_autocmd("FileType", {
        group = vim.api.nvim_create_augroup("lazyvim_treesitter", { clear = true }),
        callback = function(ev)
          local ft, lang = ev.match, vim.treesitter.language.get_lang(ev.match)
          if not LazyVim.treesitter.have(ft) then
            return
          end

          ---@param feat string
          ---@param query string
          local function enabled(feat, query)
            local f = opts[feat] or {} ---@type lazyvim.TSFeat
            return f.enable ~= false
              and not (type(f.disable) == "table" and vim.tbl_contains(f.disable, lang))
              and LazyVim.treesitter.have(ft, query)
          end

          -- highlighting
          if enabled("highlight", "highlights") then
            pcall(vim.treesitter.start)
          end

          -- indents
          if enabled("indent", "indents") then
            LazyVim.set_default("indentexpr", "v:lua.LazyVim.treesitter.indentexpr()")
          end

          -- folds
          if enabled("folds", "folds") then
            if LazyVim.set_default("foldmethod", "expr") then
              LazyVim.set_default("foldexpr", "v:lua.LazyVim.treesitter.foldexpr()")
            end
          end
        end,
      })
    end,
  },
  {
    "stevearc/conform.nvim",
    keys = {
      {
        "<leader>cF",
        false,
      },
      {
        "<leader>lF",
        function()
          require("conform").format({ formatters = { "injected" }, timeout_ms = 3000 })
        end,
        mode = { "n", "v" },
        desc = "Format Injected Langs",
      },
    },
    opts = {
      formatters_by_ft = {
        lua = { "stylua" },
        rust = { "rystfmt" },

        go = { "goimports", "gofmt" },
        toml = { "taplo" },

        yaml = { "prettier" },
        markdown = { "prettier" },
        ["markdown.mdx"] = { "prettier" },
        typescript = { "prettier" },
        typescriptreact = { "prettier" },
        javascriptreact = { "prettier" },

        sh = { "shfmt" },

        json = { "jq" },
        fish = { "fish_indent" },
        typst = { "typstfmt" },

        python = { "isort", "black" },

        html = { "prettier" },
        css = { "prettier" },
        javascript = { "prettier" },

        c = { "uncrustify", "clang-format", "prettier", stop_after_first = true },
        cpp = { "uncrustify", "clang-format", "prettier", stop_after_first = true },
        java = { "uncrustify", "prettier", stop_after_first = true },

        ["_"] = { "trim_whitespace", "trim_newlines" },
      },
      formatters = {
        uncrustify = {
          condition = function(ctx)
            return vim.fs.find({ "uncrustify.cfg", ".uncrustify.cfg" }, { path = ctx.dirname, upward = true })[1] ~= nil
          end,
        },
        ["clang-format"] = {
          condition = function(ctx)
            return vim.fs.find({ ".clang-format", "_clang-format" }, { path = ctx.dirname, upward = true })[1] ~= nil
          end,
        },
        prettier = {
          prepend_args = { "--trailing-comma", "none" },
        },
      },
    },
  },
  {
    "stevearc/overseer.nvim",
    init = function()
      local overseer = require("overseer")

      -- require("config.toggle.overseer").focus:map("<leader>oF")
      -- require("config.toggle.overseer").float:map("<leader>of")

      overseer.add_template_hook({ name = ".*run.*" }, function(task_defn, util)
        if not util.has_component(task_defn, "open_output") then
          util.add_component(task_defn, { "open_output", direction = "vertical", on_start = "always" })
        end
        util.remove_component(task_defn, "on_complete_notify")
      end)
      overseer.add_template_hook({ name = ".*build.*" }, function(task_defn, util)
        util.remove_component(task_defn, "on_complete_notify")
      end)

      vim.api.nvim_create_user_command("OverseerRestartLast", function()
        local tasks = overseer.list_tasks({ recent_first = true })
        if vim.tbl_isempty(tasks) then
          vim.cmd("OverseerRun")
        else
          if not tasks[1]:has_component("open_output") then
            tasks[1].add_component(tasks[1], { "open_output", direction = "vertical", on_start = "always" })
          end
          overseer.run_action(tasks[1], "restart")
        end
      end, {})
    end,
    opts = {
      templates = {
        "builtin",
        "cpp.build_standalone",
        "cpp.run_standalone",
        "c.build_standalone",
        "c.run_standalone",
        "python.run_standalone",
      },
      task_list = {
        bindings = {
          ["o"] = function()
            local overseer = require("overseer")
            local tasks = overseer.list_tasks({ recent_first = true })

            if not vim.tbl_isempty(tasks) then
              overseer.run_action(tasks[1], "open float")
            end
            vim.fn.feedkeys("G")
          end,
        },
      },
    },
    keys = {
      { "<leader>oO", "<cmd>OverseerRun<cr>", desc = "Run task" },
      { "<leader>oB", "<cmd>OverseerLoadBundle<cr>", desc = "Load Bundle" },
      { "<leader>oo", "<cmd>OverseerRestartLast<cr>", desc = "Run last task" },
      { "<leader>or", "<cmd>OverseerQuickAction restart<cr>", desc = "Restart last task" },
      {
        "<leader>ow",
        function()
          vim.cmd("OverseerToggle")

          for _, win in ipairs(vim.api.nvim_tabpage_list_wins(0)) do
            -- Obtém o buffer associado à janela
            local buffer = vim.api.nvim_win_get_buf(win)
            -- Verifica se o filetype do buffer corresponde ao filetype desejado
            if vim.api.nvim_get_option_value("filetype", { buf = buffer }) == "OverseerList" then
              vim.fn.feedkeys("p")
            end
          end
        end,
        desc = "Task list",
      },
    },
  },
  -- -- {
  -- --   "mason-org/mason-lspconfig.nvim",
  -- --   opts = {
  -- --     ensure_installed = {
  -- --       "clangd",
  -- --     },
  -- --   },
  -- -- },
  {
    "mason-org/mason.nvim",
    keys = {
      {
        "<leader>cm",
        false,
      },
      { "<leader>lm", "<cmd>Mason<cr>", desc = "Mason" },
    },
  },
  {
    "folke/trouble.nvim",
    dependencies = {
      "snacks.nvim",
    },
    keys = {
      { "<leader>cs", false },
      { "<leader>cS", false },
      { "<leader>ls", "<cmd>Trouble symbols toggle<cr>", desc = "Symbols (Trouble)" },
      { "<leader>lS", "<cmd>Trouble lsp toggle<cr>", desc = "LSP references/definitions/... (Trouble)" },
    },
  },
  {
    "nvimdev/lspsaga.nvim",
    opts = {
      lightbulb = {
        sign = false,
      },
      outline = {
        auto_preview = false,
      },
      finder = {
        toggle_or_open = "<CR>",
      },
      ui = {
        theme = "round",
        title = false,
        winblend = 10,
        colors = {
          normal_bg = "#1D202F",
        },
      },
    },
    dependencies = {
      "nvim-tree/nvim-web-devicons", -- optional
    },
  },
  {
    "neovim/nvim-lspconfig",
    opts = function()
      require("lazyvim.plugins.lsp.keymaps")._keys = {
        { "<leader>li", "<cmd>LspInfo<cr>", desc = "Lsp Info" },
        { "gh", "<cmd>Lspsaga finder<cr>", desc = "References" },
        { "<leader>lh", "<cmd>Lspsaga finder<cr>", desc = "References" },
        { "gd", "<cmd>Lspsaga goto_definition<cr>", desc = "Goto Definition", has = "definition" },
        { "gI", vim.lsp.buf.implementation, desc = "Goto Implementation" },
        { "gy", "<cmd>Lspsaga goto_type_definition<cr>", desc = "Goto T[y]pe Definition" },
        { "<leader>ly", "<cmd>Lspsaga goto_type_definition<cr>", desc = "Goto T[y]pe Definition" },
        { "gD", vim.lsp.buf.declaration, desc = "Goto Declaration" },
        { "K", vim.lsp.buf.hover, desc = "Hover" },
        {
          "gK",
          vim.lsp.buf.signature_help,
          desc = "Signature Help",
          has = "signatureHelp",
        },
        {
          "<c-k>",
          vim.lsp.buf.signature_help,
          mode = "i",
          desc = "Signature Help",
          has = "signatureHelp",
        },
        {
          "<leader>la",
          "<cmd>Lspsaga code_action<cr>",
          desc = "Code Action",
          mode = { "n", "v" },
          has = "codeAction",
        },
        {
          "<leader>ld",
          "<cmd>Lspsaga peek_definition<cr>",
          desc = "Peek Definition",
          mode = { "n" },
          has = "definition",
        },
        { "<leader>lc", vim.lsp.codelens.run, desc = "Run Codelens", mode = { "n", "v" }, has = "codeLens" },
        {
          "<leader>lC",
          vim.lsp.codelens.refresh,
          desc = "Refresh & Display Codelens",
          mode = { "n" },
          has = "codeLens",
        },
        {
          "<leader>lR",
          Snacks.rename.rename_file,
          desc = "Rename File",
          mode = { "n" },
          has = { "workspace/didRenameFiles", "workspace/willRenameFiles" },
        },
        { "<leader>lr", vim.lsp.buf.rename, desc = "Rename", has = "rename" },
        { "<leader>lA", LazyVim.lsp.action.source, desc = "Source Action", has = "codeAction" },
        {
          "]]",
          function()
            Snacks.words.jump(vim.v.count1)
          end,
          has = "documentHighlight",
          desc = "Next Reference",
          cond = function()
            return Snacks.words.is_enabled()
          end,
        },
        {
          "[[",
          function()
            Snacks.words.jump(-vim.v.count1)
          end,
          has = "documentHighlight",
          desc = "Prev Reference",
          cond = function()
            return Snacks.words.is_enabled()
          end,
        },
        {
          "<a-n>",
          function()
            Snacks.words.jump(vim.v.count1, true)
          end,
          has = "documentHighlight",
          desc = "Next Reference",
          cond = function()
            return Snacks.words.is_enabled()
          end,
        },
        {
          "<a-p>",
          function()
            Snacks.words.jump(-vim.v.count1, true)
          end,
          has = "documentHighlight",
          desc = "Prev Reference",
          cond = function()
            return Snacks.words.is_enabled()
          end,
        },
        { "gr", false },
      }

      local unmap = function(...)
        pcall(vim.keymap.del, ...)
      end
      unmap("n", "gri")
      unmap("n", "gra")
      unmap("n", "grn")
    end,
  },
}
