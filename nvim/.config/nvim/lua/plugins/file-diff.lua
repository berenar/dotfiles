return {
  "jemag/telescope-diff.nvim",
  dependencies = {
    { "nvim-telescope/telescope.nvim" },
  },
  config = function()
    vim.keymap.set("n", "<leader>sC", function()
      require("telescope").extensions.diff.diff_files({ hidden = true })
    end, { desc = "Compare 2 files" })
    vim.keymap.set("n", "<leader>sc", function()
      require("telescope").extensions.diff.diff_current({ hidden = true })
    end, { desc = "Compare file with current" })
  end,
}
