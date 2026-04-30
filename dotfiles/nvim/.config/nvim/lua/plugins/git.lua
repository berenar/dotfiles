return {
	{ "tpope/vim-fugitive" },
	{
		"sindrets/diffview.nvim",
		cmd = { "DiffviewOpen", "DiffviewClose", "DiffviewToggleFiles", "DiffviewFocusFiles", "DiffviewFileHistory" },
		keys = {
			{ "<leader>gO", "<cmd>DiffviewOpen<cr>", desc = "Diffview Open" },
			{ "<leader>gH", "<cmd>DiffviewFileHistory %<cr>", desc = "Diffview File History" },
		},
	},
	{
		"lewis6991/gitsigns.nvim",
		config = function()
			require("gitsigns").setup()
			vim.keymap.set("n", "<leader>gd", ":Gitsigns preview_hunk<CR>", {})
			vim.keymap.set("n", "<leader>gb", ":Gitsigns blame_line<CR>", {})
			-- FIXME: They don't work as they would need to overwrite existing keymaps?
			vim.keymap.set("n", "[c", function()
				require("gitsigns").nav_hunk("prev")
			end, { desc = "Prev git hunk" })
			vim.keymap.set("n", "]c", function()
				require("gitsigns").nav_hunk("next")
			end, { desc = "Next git hunk" })
		end,
	},
}
