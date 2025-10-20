local additional_rg_args = { "--hidden", "--glob", "!**/.git/*", "--glob", "!**/node_modules/*" }

return {
  "nvim-telescope/telescope.nvim",
  opts = {
    defaults = {},
    pickers = {
      find_files = {
        -- `hidden = true` will still show the inside of `.git/` as it's not `.gitignore`d.
        find_command = { "rg", "--files", "--hidden", "--glob", "!**/.git/*" },
      },
      live_grep = { additional_args = additional_rg_args },
      grep_string = { additional_args = additional_rg_args },
    },
  },
}
