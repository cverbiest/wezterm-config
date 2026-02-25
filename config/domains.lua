local wezterm = require('wezterm')
local platform = require('utils.platform')

local ssh_domains = {}
for _, dom in ipairs(wezterm.default_ssh_domains()) do
   if not dom.name:match('^SSHMUX:') then
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
         name = 'wsl:ubuntu-fish',
         distribution = 'Ubuntu',
         username = os_user,
         default_cwd = '/home/' .. os_user,
         default_prog = { 'fish', '-l' },
      },
      {
         name = 'wsl:ubuntu-bash',
         distribution = 'Ubuntu',
         username = os_user,
         default_cwd = '/home/' .. os_user,
         default_prog = { 'bash', '-l' },
      },
   }
end
return options
