-- Paste a clipboard image into a terminal program (e.g. Claude Code) as a file path.
-- Adapted from https://picton.uk/blog/claude-code-image-paste-wezterm/ for Windows and
-- SSH domains: the image is saved as PNG (PowerShell); in an SSH pane it is copied to
-- ~/.cache/wezterm-clip on that host (images there older than 7 days are removed) and
-- the remote path is pasted. Without an image on the clipboard it is a normal paste.
-- Uploading uses the system ssh/scp, so the host needs key authentication (no prompts).
local wezterm = require('wezterm')
local platform = require('utils.platform')
local act = wezterm.action

local M = {}

-- Saves the clipboard image to `path` as PNG; false when there is no image (or not Windows)
local function save_clipboard_image(path)
   if not platform.is_win then
      return false
   end
   local script = table.concat({
      'Add-Type -AssemblyName System.Windows.Forms, System.Drawing',
      '$img = [System.Windows.Forms.Clipboard]::GetImage()',
      "if ($img) { $img.Save('" .. path:gsub("'", "''") .. "', [System.Drawing.Imaging.ImageFormat]::Png); 'saved' }",
   }, '; ')
   local ok, stdout = wezterm.run_child_process({ 'powershell.exe', '-NoProfile', '-STA', '-Command', script })
   return ok and stdout:match('saved') ~= nil
end

-- Host alias of an SSH domain pane (SSH:host or SSHMUX:host), nil for local panes
local function ssh_host(pane)
   local domain = pane:get_domain_name()
   return domain:match('^SSH:(.+)') or domain:match('^SSHMUX:(.+)')
end

-- Copies `file` to ~/.cache/wezterm-clip/`name` on `host`; returns the remote path or nil
local function upload(host, file, name)
   local opts = { '-o', 'BatchMode=yes', '-o', 'ConnectTimeout=10' }
   local function cmd(prog, ...)
      local args = { prog }
      for _, a in ipairs(opts) do table.insert(args, a) end
      for _, a in ipairs({ ... }) do table.insert(args, a) end
      return args
   end
   local ok, stdout = wezterm.run_child_process(cmd('ssh', host,
      'd=~/.cache/wezterm-clip; mkdir -p -m 700 "$d" && find "$d" -name "clip_*" -mtime +7 -delete; cd "$d" && pwd'))
   -- The last line: the shell's startup files may print something first
   local dir = ok and stdout:match('([^\r\n]+)[\r\n]*$')
   if not dir then
      return nil
   end
   local remote = dir .. '/' .. name
   if not wezterm.run_child_process(cmd('scp', '-q', file, host .. ':' .. remote)) then
      return nil
   end
   return remote
end

function M.action()
   return wezterm.action_callback(function(window, pane)
      local name = 'clip_' .. os.date('%Y%m%d-%H%M%S') .. '.png'
      local sep = platform.is_win and '\\' or '/'
      local file = (os.getenv('TEMP') or os.getenv('TMPDIR') or '/tmp') .. sep .. name
      if not save_clipboard_image(file) then
         window:perform_action(act.PasteFrom('Clipboard'), pane)
         return
      end
      local path = file
      local host = ssh_host(pane)
      if host then
         path = upload(host, file, name)
         os.remove(file)
         if not path then
            window:toast_notification('wezterm', 'Image upload to ' .. host .. ' failed', nil, 4000)
            return
         end
      end
      pane:paste(path)
   end)
end

return M
