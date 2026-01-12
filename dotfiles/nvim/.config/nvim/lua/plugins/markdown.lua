return {
	"iamcco/markdown-preview.nvim",
	cmd = {
		"MarkdownPreviewToggle",
		"MarkdownPreview",
		"MarkdownPreviewStop",
	},
	ft = { "markdown" },
	build = function()
		vim.fn["mkdp#util#install"]()
	end,
	keys = {
		{ "<leader>mp", "<cmd>MarkdownPreviewToggle<cr>", desc = "Toggle Markdown Preview" },
	},
}
