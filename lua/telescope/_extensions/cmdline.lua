local has_telescope, telescope = pcall(require, "telescope")

if not has_telescope then
  error("This plugins requires nvim-telescope/telescope.nvim")
end

local cmdline = require('cmdline')
local action = require('cmdline.actions')
local pickers = require("telescope.pickers")
local finders = require("telescope.finders")
local entry_display = require("telescope.pickers.entry_display")

local sorter = require('cmdline.sorter')

local get_config = function()
  local config = require('cmdline.config')
  if config.values == nil or config.values == {} then
    return config.defaults
  else
    return config.values
  end
end

local displayer = entry_display.create({
  separator = " ",
  items = {
    { width = 2 },
    { remaining = true },
  },
})

local make_display = function(entry)
  local config = assert(get_config(), "No config found")
  return displayer({
    { entry.icon, config.highlights.icon },
    { entry.cmd },
  })
end

local make_finder = function(config)
  return finders.new_dynamic({
    fn = cmdline.autocomplete,
    entry_maker = function(entry)
      entry.icon = config.icons[entry.type]
      entry.id = entry.index
      entry.value = entry.cmd
      entry.ordinal = entry.cmd
      entry.display = make_display
      return entry
    end,
  })
end

local make_picker = function(opts)
  local config = assert(get_config(), "No config found")
  return pickers.new(config.picker, {
    prompt_title = "Cmdline",
    prompt_prefix = " : ",
    finder = make_finder(config),
    sorter = sorter(opts),
    attach_mappings = function(_, map)
      map("i", config.mappings.complete, action.complete_input)     -- <Tab>
      map("i", config.mappings.run_input, action.run_input)         -- <CR>
      map("i", config.mappings.run_selection, action.run_selection) -- <C-CR>
      map("i", "<C-e>", action.edit)
      require("telescope.actions").close:enhance {
        post = function()
          cmdline.preview.clean(vim.api.nvim_win_get_buf(0))
        end,
      }
      return true
    end,
  })
end

local telescope_cmdline = function(opts)
  cmdline.preload()
  local picker = make_picker(opts)
  picker:find()
end

local cmdline_visual = function(opts)
  cmdline.preload()
  local picker = make_picker(opts)
  picker:find()
  picker:set_prompt("'<,'> ")
end

return telescope.register_extension({
  setup   = function(ext_config, config)
    require("cmdline.config").set_defaults(ext_config)
  end,
  exports = {
    cmdline = telescope_cmdline,
    visual  = cmdline_visual,
  }
})
