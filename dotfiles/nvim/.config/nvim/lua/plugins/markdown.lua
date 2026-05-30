return {
	"iamcco/markdown-preview.nvim",
	cmd = {
		"MarkdownPreviewToggle",
		"MarkdownPreview",
		"MarkdownPreviewStop",
	},
	ft = { "markdown" },
	build = "cd app && sh ./install.sh",
	config = function()
		local tile_script = vim.fn.stdpath("config") .. "/scripts/markdown-preview-tile.sh"

		vim.g.mkdp_browserfunc = "MkdpOpenTiled"

		vim.cmd(string.format(
			[[
			function! MkdpOpenTiled(url) abort
				call system(%s . ' ' . shellescape(a:url))
			endfunction
			]],
			vim.fn.shellescape(tile_script)
		))
	end,
	keys = {
		{ "<leader>mp", "<cmd>MarkdownPreviewToggle<cr>", desc = "Toggle Markdown Preview" },
	},
}
