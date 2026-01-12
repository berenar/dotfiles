return {
  "folke/snacks.nvim",
  opts = {
    picker = {
      sources = {
        grep = {
          hidden = true,
          ignored = false,
          exclude = { "node_modules" },
        },
        grep_word = {
          hidden = true,
          ignored = false,
          exclude = { "node_modules" },
        },
        files = {
          hidden = true,
          ignored = false,
          exclude = { "node_modules" },
        },
      },
    },
  },
}
