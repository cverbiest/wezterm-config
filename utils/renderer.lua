local wezterm = require('wezterm')
local gpu_adapters = require('utils.gpu-adapter')
local act = wezterm.action

-- The selected renderer is stored here so it survives restarts
local STATE_FILE = wezterm.config_dir .. '/.renderer'
local DEFAULT = 'opengl'

---@class RendererChoice
---@field id string
---@field label string
---@field backend? WeztermGPUBackend
---@field device_type? WeztermGPUDeviceType

---@type RendererChoice[]
local ALL_CHOICES = {
   { id = 'opengl', label = 'OpenGL' },
   { id = 'software', label = 'Software (CPU)' },
   { id = 'webgpu-dx12-igpu', label = 'WebGpu Dx12', backend = 'Dx12', device_type = 'IntegratedGpu' },
   { id = 'webgpu-vulkan-igpu', label = 'WebGpu Vulkan', backend = 'Vulkan', device_type = 'IntegratedGpu' },
   { id = 'webgpu-dx12-dgpu', label = 'WebGpu Dx12', backend = 'Dx12', device_type = 'DiscreteGpu' },
   { id = 'webgpu-vulkan-dgpu', label = 'WebGpu Vulkan', backend = 'Vulkan', device_type = 'DiscreteGpu' },
}

---@param choice RendererChoice
---@return WeztermGPUAdapter|nil
local function adapter_for(choice)
   local by_backend = gpu_adapters[choice.device_type]
   return by_backend and by_backend[choice.backend]
end

-- only offer WebGpu choices whose adapter exists on this machine
local choices = {}
for _, choice in ipairs(ALL_CHOICES) do
   if not choice.backend then
      table.insert(choices, choice)
   else
      local adapter = adapter_for(choice)
      if adapter then
         table.insert(choices, {
            id = choice.id,
            label = choice.label .. ' - ' .. adapter.name,
            backend = choice.backend,
            device_type = choice.device_type,
         })
      end
   end
end

local function find(id)
   for _, choice in ipairs(choices) do
      if choice.id == id then
         return choice
      end
   end
end

local function read_selected()
   local file = io.open(STATE_FILE, 'r')
   if not file then
      return DEFAULT
   end
   local id = file:read('*l')
   file:close()
   if id and find(id) then
      return id
   end
   return DEFAULT
end

local function write_selected(id)
   local file = io.open(STATE_FILE, 'w')
   if not file then
      wezterm.log_error('Could not write ' .. STATE_FILE)
      return false
   end
   file:write(id)
   file:close()
   return true
end

---Config options for the selected renderer
---@return table
local function options()
   local choice = find(read_selected())

   if choice.id == 'opengl' then
      return { front_end = 'OpenGL' }
   elseif choice.id == 'software' then
      return { front_end = 'Software' }
   end

   return {
      front_end = 'WebGpu',
      webgpu_power_preference = choice.device_type == 'DiscreteGpu' and 'HighPerformance' or 'LowPower',
      webgpu_preferred_adapter = adapter_for(choice),
   }
end

local function action()
   return wezterm.action_callback(function(window, pane)
      local selected = read_selected()
      local selector_choices = {}
      for _, choice in ipairs(choices) do
         table.insert(selector_choices, {
            id = choice.id,
            label = (choice.id == selected and '* ' or '  ') .. choice.label,
         })
      end

      window:perform_action(
         act.InputSelector({
            title = 'Renderer (current: ' .. find(selected).label .. ')',
            choices = selector_choices,
            fuzzy = true,
            fuzzy_description = 'Renderer: ',
            action = wezterm.action_callback(function(inner_window, _inner_pane, id)
               if not id or not write_selected(id) then
                  return
               end
               wezterm.reload_configuration()
               inner_window:toast_notification(
                  'WezTerm',
                  'Renderer: ' .. find(id).label .. '. Open a new window (Alt+N) to test it.',
                  nil,
                  4000
               )
            end),
         }),
         pane
      )
   end)
end

return {
   options = options,
   action = action,
}
