-- https://github.com/neovim/neovim/issues/20784
local function rename_file()
  local source_file = vim.api.nvim_buf_get_name(0)

  vim.ui.input({
    prompt = "Source: ",
    completion = "file",
    default = source_file,
  }, function(source)
    if not source or source == "" then return end

    vim.ui.input({
      prompt = "Target: ",
      completion = "file",
      default = source,
    }, function(target)
      if not target or target == "" then return end

      vim.lsp.util.rename(source, target)
      vim.lsp.buf.execute_command({
        command = "_typescript.applyRenameFile",
        arguments = {{ sourceUri = source, targetUri = target }},
      })
      vim.cmd("edit " .. target)
    end)
  end)
end

vim.api.nvim_create_user_command("RenameFile", rename_file, {})

return {
  {
    "neovim/nvim-lspconfig",
    opts = {
      autoformat = false,
      inlay_hints = { enabled = false },
      servers = {

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
