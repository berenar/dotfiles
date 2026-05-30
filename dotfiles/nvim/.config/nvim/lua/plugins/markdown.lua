return {
	"iamcco/markdown-preview.nvim",
	cmd = {
		"MarkdownPreviewToggle",
		"MarkdownPreview",
		"MarkdownPreviewStop",
	},
	ft = { "markdown" },
	build = "cd app && sh ./install.sh",
	keys = {
		{ "<leader>mp", "<cmd>MarkdownPreviewToggle<cr>", desc = "Toggle Markdown Preview" },
	},
}
