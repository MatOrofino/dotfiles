-- Autocmds are automatically loaded on the VeryLazy event
-- Default autocmds that are always set: https://github.com/LazyVim/LazyVim/blob/main/lua/lazyvim/config/autocmds.lua
-- Add any additional autocmds here

vim.cmd([[
autocmd FileType markdown set spelllang=pt_br,en_us | inoremap <C-l> <c-g>u<Esc>[s1z=`]a<c-g>u
autocmd FileType qml set shiftwidth=4|set tabstop=4
autocmd BufNewFile,BufRead,BufReadPost *.typ set filetype=typst
autocmd BufNewFile,BufRead,BufReadPost *.gazebo set filetype=xml
autocmd BufNewFile,BufRead,BufReadPost *.wbt set filetype=vrml
autocmd BufNewFile,BufRead,BufReadPost *.proto set filetype=vrml
autocmd BufNewFile,BufRead,BufReadPost *.launch set filetype=xml
autocmd BufNewFile,BufRead,BufReadPost *.urdf set filetype=xml
]])

vim.api.nvim_create_autocmd("ColorScheme", {
  pattern = "*",
  callback = function()
    -- Cores do Neo-tree
    vim.api.nvim_set_hl(0, "NeoTreeNormal", { link = "Normal" })
    vim.api.nvim_set_hl(0, "NeoTreeNormalNC", { link = "Normal" })
    vim.api.nvim_set_hl(0, "NeoTreeDirectoryName", { link = "Directory" })
    vim.api.nvim_set_hl(0, "NeoTreeDirectoryIcon", { link = "Directory" })
    vim.api.nvim_set_hl(0, "NeoTreeRootName", { link = "Title", bold = true })
    vim.api.nvim_set_hl(0, "NeoTreeFileName", { link = "Normal" })
    vim.api.nvim_set_hl(0, "NeoTreeFloatBorder", { link = "WinSeparator" })
    vim.api.nvim_set_hl(0, "NeoTreeEndOfBuffer", { link = "EndOfBuffer" })

    -- Cores do Which-Key
    vim.api.nvim_set_hl(0, "WhichKey", { link = "Function" }) -- As teclas de atalho
    vim.api.nvim_set_hl(0, "WhichKeyGroup", { link = "Keyword" }) -- Os grupos (ex: +windows)
    vim.api.nvim_set_hl(0, "WhichKeyDesc", { link = "String" }) -- A descrição do comando
    vim.api.nvim_set_hl(0, "WhichKeySeparator", { link = "Comment" }) -- O separador (->)
    vim.api.nvim_set_hl(0, "WhichKeyBorder", { link = "WinSeparator" })
    vim.api.nvim_set_hl(0, "WhichKeyNormal", { link = "NormalFloat" })
  end,
})
