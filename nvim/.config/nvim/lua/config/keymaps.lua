-- Keymaps are automatically loaded on the VeryLazy event
-- Default keymaps that are always set: https://github.com/LazyVim/LazyVim/blob/main/lua/lazyvim/config/keymaps.lua
-- Add any additional keymaps here
vim.keymap.set("n", "<leader>K", ":Telescope keymaps<CR>", { desc = "telescope Keymaps" })
vim.keymap.set("n", "<leader><tab>n", ":tabNext<CR>", { desc = "Next Tab" })

-- vim.keymap.del("n", "<leader>gg")

vim.keymap.set("n", "<leader>tt", ":vsplit<CR>:terminal<CR>i", { desc = "Vertical Split" })

vim.keymap.set("n", "<leader>jq", ":%!jq .<CR>", { desc = "JQ JSON format" })
