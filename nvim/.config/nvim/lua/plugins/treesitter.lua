return {
	"nvim-treesitter/nvim-treesitter",
	opts = {
		ensure_installed = {
			"bash",
			"javascript",
			"json",
			"lua",
			"markdown",
			"markdown_inline",
			"python",
			"query",
			"regex",
			"tsx",
			"html",
			"css",
			"typescript",
			"vim",
			"yaml",
		},
		highlight = { enable = true },
		indent = { enable = true },
		auto_install = true,
		incremental_selection = {
			enable = true,
			keymaps = {
				init_selection = "gnn", -- set to `false` to disable one of the mappings
				node_incremental = "grn",
				scope_incremental = "grc",
				node_decremental = "grm",
			},
		},
	},
}
