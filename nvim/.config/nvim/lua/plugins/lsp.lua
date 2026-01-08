-- https://github.com/neovim/neovim/issues/20784
local function rename_file()
	local source_file, target_file

	vim.ui.input({
		prompt = "Source : ",
		completion = "file",
		default = vim.api.nvim_buf_get_name(0),
	}, function(input)
		source_file = input
	end)
	vim.ui.input({
		prompt = "Target : ",
		completion = "file",
		default = source_file,
	}, function(input)
		target_file = input
	end)

	local params = {
		command = "_typescript.applyRenameFile",
		arguments = {
			{
				sourceUri = source_file,
				targetUri = target_file,
			},
		},
		title = "",
	}

	vim.lsp.util.rename(source_file, target_file)
	vim.lsp.buf.execute_command(params)
	-- TODO: write changed buffer
end

return {
	{
		"neovim/nvim-lspconfig",
		opts = {
			autoformat = false,
			inlay_hints = { enabled = false },
			servers = {
				copilot = {},
			},
		},
		cmds = {
			RenameFile = {
				rename_file,
				description = "Rename File",
			},
		},
	},
	
	{
		"mason-org/mason-lspconfig.nvim",
		opts = {
			automatic_installation = true,
		},
	},
}
