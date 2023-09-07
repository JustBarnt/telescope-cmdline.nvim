local config = {}

config.defaults = {
  icons = {
    history = " ",
    command = "󰣿 ",
    number = "",
  },
  picker = {
    layout_config = {
      width = 80,
      height = 20,
    }
  },
  completions = {
    'command',
  },
  overseer = {
    enabled = true,
  }
}

config.values = {}

-- @param user_defaults table: user options
function config.set_defaults(user_defaults)
  user_defaults = vim.F.if_nil(user_defaults, {})
  config.values = vim.tbl_deep_extend("keep", user_defaults, config.defaults)
end

return config
