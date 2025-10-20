return {
	"folke/which-key.nvim",
	event = "VeryLazy",
	init = function()
		vim.o.timeout = true
		vim.o.timeoutlen = 2000 -- to make it painfully slow to use and hopefully use it less ;)
	end,
	opts = {},
}
