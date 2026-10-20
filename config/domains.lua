local wezterm = require('wezterm')
local platform = require('utils.platform')

local ssh_domains = {}
local groups = {}
local group_order = {}
for _, dom in ipairs(wezterm.default_ssh_domains()) do
   if not dom.name:match('^SSHMUX:') then
      local group = dom.name:match('^([^-]+)-') or 'unclassified'
      if not groups[group] then
         groups[group] = {}
         table.insert(group_order, group)
      end
      table.insert(groups[group], dom)
   end
end
table.sort(group_order, function(a, b)
   if a == 'unclassified' then return false end
   if b == 'unclassified' then return true end
   return a < b
end)
for _, group in ipairs(group_order) do
   table.sort(groups[group], function(a, b) return a.name < b.name end)
   for _, dom in ipairs(groups[group]) do
      table.insert(ssh_domains, dom)
   end
end

local options = {
   -- ref: https://wezfurlong.org/wezterm/config/lua/SshDomain.html
   ssh_domains = ssh_domains,

   -- ref: https://wezfurlong.org/wezterm/multiplexing.html#unix-domains
   unix_domains = {},

   -- ref: https://wezfurlong.org/wezterm/config/lua/WslDomain.html
   wsl_domains = {},
}

if platform.is_win then
   local os_user = os.getenv('USER') or os.getenv('USERNAME')
   options.wsl_domains = {
      {
         name = 'wsl',
         distribution = 'Ubuntu',
         username = os_user,
         default_cwd = '/home/' .. os_user,
         default_prog = { 'bash', '-l' },
      },
   }
end
return options
