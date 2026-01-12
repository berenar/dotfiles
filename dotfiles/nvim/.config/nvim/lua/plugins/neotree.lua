return {
  "nvim-neo-tree/neo-tree.nvim",
  opts = {
    close_if_last_window = true, -- Close Neo-tree if it is the last window left in the tab
    window = {
      position = "right",
      width = 30,
      auto_expand_width = true,
    },
    filesystem = {
      -- bind_to_cwd = true,
      filtered_items = {
        visible = true,
        show_hidden_count = true,
        hide_dotfiles = false,
        hide_gitignored = true,
        hide_by_name = {
          ".DS_Store",
        },
        never_show = {},
      },
      commands = {
        -- https://github.com/yetone/avante.nvim?tab=readme-ov-file#neotree-shortcut
        avante_add_files = function(state)
          local node = state.tree:get_node()
          local filepath = node:get_id()
          local relative_path = require("avante.utils").relative_path(filepath)
          local sidebar = require("avante").get()

          local open = sidebar:is_open()
          -- ensure avante sidebar is open
          if not open then
            require("avante.api").ask()
            sidebar = require("avante").get()
          end

          sidebar.file_selector:add_selected_file(relative_path)

          -- remove neo tree buffer
          if not open then
            sidebar.file_selector:remove_selected_file("neo-tree filesystem [1]")
          end
        end,
      },
      window = {
        mappings = {
          ["oa"] = "avante_add_files",
        },
      },
    },
    event_handlers = {
      {
        event = "file_opened",
        handler = function()
          require("neo-tree.command").execute({ action = "close" })
        end,
      },
    },
  },
}
