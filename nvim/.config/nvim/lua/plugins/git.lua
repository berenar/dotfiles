return {
	{ "tpope/vim-fugitive" },
	{
		"lewis6991/gitsigns.nvim",
		config = function()
			require("gitsigns").setup()
			vim.keymap.set("n", "<leader>gd", ":Gitsigns preview_hunk<CR>", {})
			vim.keymap.set("n", "<leader>gb", ":Gitsigns blame_line<CR>", {})
			-- FIXME: They don't work as they would need to overwrite existing keymaps?
			-- vim.keymap.set("n", "[c", ":Gitsigns nav_hunk('prev')<CR>", {})
			-- vim.keymap.set("n", "]c", ":Gitsigns nav_hunk('next')<CR>", {})
		end,
	},
}
