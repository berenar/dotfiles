return {
  -- {
  --   "luckasRanarison/tailwind-tools.nvim",
  --   dependencies = { "nvim-treesitter/nvim-treesitter" },
  --   opts = {
  --     {
  --       document_color = {
  --         enabled = false, -- can be toggled by commands
  --         kind = "inline", -- "inline" | "foreground" | "background"
  --         inline_symbol = "󰝤 ", -- only used in inline mode
  --         debounce = 200, -- in milliseconds, only applied in insert mode
  --       },
  --       conceal = {
  --         enabled = true, -- can be toggled by commands
  --         min_length = nil, -- only conceal classes exceeding the provided length
  --         symbol = "󱏿", -- only a single character is allowed
  --         highlight = { -- extmark highlight options, see :h 'highlight'
  --           fg = "#38BDF8",
  --         },
  --       },
  --       custom_filetypes = {}, -- see the extension section to learn how it works
  --     },
  --   },
  -- },
  {
    "norcalli/nvim-colorizer.lua",
    config = function()
      require("colorizer").setup({ "*" }, {
        mode = "background",
        RGB = true, -- #RGB hex codes
        RRGGBB = true, -- #RRGGBB hex codes
        names = true, -- "Name" codes like Blue
        RRGGBBAA = true, -- #RRGGBBAA hex codes
        rgb_fn = false, -- CSS rgb() and rgba() functions
        hsl_fn = false, -- CSS hsl() and hsla() functions
        css = false, -- Enable all CSS features: rgb_fn, hsl_fn, names, RGB, RRGGBB
        css_fn = false, -- Enable all CSS *functions*: rgb_fn, hsl_fn
      })
    end,
  },
}
