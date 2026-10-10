local wezterm = require('wezterm')
local custom = require('colors.custom')
local act = wezterm.action

-- The selected color scheme is stored here so it survives restarts
local STATE_FILE = wezterm.config_dir .. '/.colorscheme'
local DEFAULT = 'custom'
local DEFAULT_LABEL = 'Custom (catppuccin mocha)'

-- keep the custom ui colors, the tab-title/status events are styled for them
local UI_KEYS = { 'tab_bar', 'scrollbar_thumb', 'split', 'visual_bell', 'compose_cursor' }

local function read_selected()
   local file = io.open(STATE_FILE, 'r')
   if not file then
      return DEFAULT
   end
   local name = file:read('*l')
   file:close()
   return name or DEFAULT
end

local function write_selected(name)
   local file = io.open(STATE_FILE, 'w')
   if not file then
      wezterm.log_error('Could not write ' .. STATE_FILE)
      return false
   end
   file:write(name)
   file:close()
   return true
end

---Colors of the selected scheme, falls back to the custom scheme
---@return table
local function colors()
   local name = read_selected()
   if name == DEFAULT then
      return custom
   end

   local scheme = wezterm.color.get_builtin_schemes()[name]
   if not scheme then
      wezterm.log_warn('Unknown color scheme "' .. name .. '", using custom')
      return custom
   end

   for _, key in ipairs(UI_KEYS) do
      if scheme[key] == nil then
         scheme[key] = custom[key]
      end
   end
   return scheme
end

local function action()
   return wezterm.action_callback(function(window, pane)
      local selected = read_selected()
      local names = {}
      for name, _ in pairs(wezterm.color.get_builtin_schemes()) do
         table.insert(names, name)
      end
      table.sort(names, function(a, b)
         return a:lower() < b:lower()
      end)

      local selector_choices = {
         { id = DEFAULT, label = (selected == DEFAULT and '* ' or '  ') .. DEFAULT_LABEL },
      }
      for _, name in ipairs(names) do
         table.insert(selector_choices, {
            id = name,
            label = (name == selected and '* ' or '  ') .. name,
         })
      end

      window:perform_action(
         act.InputSelector({
            title = 'Color scheme (current: ' .. (selected == DEFAULT and DEFAULT_LABEL or selected) .. ')',
            choices = selector_choices,
            fuzzy = true,
            fuzzy_description = 'Color scheme: ',
            action = wezterm.action_callback(function(inner_window, _inner_pane, id)
               if not id or not write_selected(id) then
                  return
               end
               -- drop a background override so the overlay picks up the new background color
               local overrides = inner_window:get_config_overrides() or {}
               overrides.background = nil
               inner_window:set_config_overrides(overrides)
               wezterm.reload_configuration()
            end),
         }),
         pane
      )
   end)
end

return {
   colors = colors,
   action = action,
}
