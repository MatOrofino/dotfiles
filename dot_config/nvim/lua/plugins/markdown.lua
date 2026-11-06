return {
  {
    "iamcco/markdown-preview.nvim",
    cmd = { "MarkdownPreviewToggle", "MarkdownPreview", "MarkdownPreviewStop" },
    ft = { "markdown" },
    config = function()
      vim.g.mkdp_preview_options = {
        disable_sync_scroll = 0,
      }
    end,
    build = ":call mkdp#util#install()",
  },
}
