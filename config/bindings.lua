local wezterm = require('wezterm')
local platform = require('utils.platform')
local backdrops = require('utils.backdrops')
local act = wezterm.action

local mod = {}

if platform.is_mac then
   -- On macOS, SUPER maps to the Command key.
   mod.SUPER = 'SUPER'
   -- On macOS, SUPER_REV maps to Command+Control.
   mod.SUPER_REV = 'SUPER|CTRL'
elseif platform.is_win or platform.is_linux then
   -- On Windows/Linux, SUPER maps to Alt to avoid conflicts with OS Win-key shortcuts.
   mod.SUPER = 'ALT'
   -- On Windows/Linux, SUPER_REV maps to Alt+Control.
   mod.SUPER_REV = 'ALT|CTRL'
end

-- stylua: ignore
local keys = {
   -- misc/useful --
   -- ActivateCopyMode (Ctrl+Shift+X)
   { key = 'x',  mods = 'CTRL|SHIFT', action = act.ActivateCopyMode },
   -- ActivateCommandPalette (Ctrl+Shift+P)
   { key = 'p',  mods = 'CTRL|SHIFT', action = act.ActivateCommandPalette },
   -- ShowLauncher (Shift+F3)
   { key = 'F3', mods = 'SHIFT', action = act.ShowLauncher },
   -- ShowLauncherArgs tabs (Shift+F4)
   { key = 'F4', mods = 'SHIFT', action = act.ShowLauncherArgs({ flags = 'FUZZY|TABS' }) },
   -- ShowLauncherArgs workspaces (Shift+F5)
   {
      key = 'F5',
      mods = 'SHIFT',
      action = act.ShowLauncherArgs({ flags = 'FUZZY|WORKSPACES' }),
   },
   -- ToggleFullScreen (F11)
   { key = 'F11', mods = 'NONE',    action = act.ToggleFullScreen },
   -- ShowDebugOverlay (Ctrl+Shift+L)
   { key = 'l',  mods = 'CTRL|SHIFT', action = act.ShowDebugOverlay },
   -- Search (Alt+F)
   { key = 'f',   mods = mod.SUPER, action = act.Search({ CaseInSensitiveString = '' }) },
   -- QuickSelect open URL (Alt+Ctrl+U)
   {
      key = 'u',
      mods = mod.SUPER_REV,
      action = wezterm.action.QuickSelectArgs({
         label = 'open url',
         patterns = {
            '\\((https?://\\S+)\\)',
            '\\[(https?://\\S+)\\]',
            '\\{(https?://\\S+)\\}',
            '<(https?://\\S+)>',
            '\\bhttps?://\\S+[)/a-zA-Z0-9-]+'
         },
         action = wezterm.action_callback(function(window, pane)
            local url = window:get_selection_text_for_pane(pane)
            wezterm.log_info('opening: ' .. url)
            wezterm.open_with(url)
         end),
      }),
   },

   -- cursor movement --
   -- Send Home (Alt+LeftArrow)
   { key = 'LeftArrow',  mods = mod.SUPER,     action = act.SendString '\u{1b}OH' },
   -- Send End (Alt+RightArrow)
   { key = 'RightArrow', mods = mod.SUPER,     action = act.SendString '\u{1b}OF' },
   -- Delete line backward (Alt+Backspace)
   { key = 'Backspace',  mods = mod.SUPER,     action = act.SendString '\u{15}' },

   -- copy/paste --
   -- CopyTo clipboard (Ctrl+Shift+C)
   { key = 'c',          mods = 'CTRL|SHIFT',  action = act.CopyTo('Clipboard') },
   -- PasteFrom clipboard (Ctrl+Shift+V)
   { key = 'v',          mods = 'CTRL|SHIFT',  action = act.PasteFrom('Clipboard') },

   -- tabs --
   -- tabs: spawn+close
   -- SpawnTab default domain (Alt+T)
   { key = 't',          mods = mod.SUPER,     action = act.SpawnTab('DefaultDomain') },
   -- SpawnTab WSL Ubuntu Fish (Alt+Ctrl+T)
   { key = 't',          mods = mod.SUPER_REV, action = act.SpawnTab({ DomainName = 'wsl:ubuntu-fish' }) },
   -- CloseCurrentTab (Alt+Ctrl+W)
   { key = 'w',          mods = mod.SUPER_REV, action = act.CloseCurrentTab({ confirm = false }) },

   -- tabs: navigation
   -- ActivateTabRelative previous (Alt+[)
   { key = '[',          mods = mod.SUPER,     action = act.ActivateTabRelative(-1) },
   -- ActivateTabRelative next (Alt+])
   { key = ']',          mods = mod.SUPER,     action = act.ActivateTabRelative(1) },
   -- MoveTabRelative left (Alt+Ctrl+[)
   { key = '[',          mods = mod.SUPER_REV, action = act.MoveTabRelative(-1) },
   -- MoveTabRelative right (Alt+Ctrl+])
   { key = ']',          mods = mod.SUPER_REV, action = act.MoveTabRelative(1) },

   -- tab: title
   -- Manual tab title update (Alt+0)
   { key = '0',          mods = mod.SUPER,     action = act.EmitEvent('tabs.manual-update-tab-title') },
   -- Reset tab title (Alt+Ctrl+0)
   { key = '0',          mods = mod.SUPER_REV, action = act.EmitEvent('tabs.reset-tab-title') },

   -- tab: hide tab-bar
   -- Toggle tab bar (Alt+9)
   { key = '9',          mods = mod.SUPER,     action = act.EmitEvent('tabs.toggle-tab-bar'), },

   -- window --
   -- window: spawn windows
   -- SpawnWindow (Alt+N)
   { key = 'n',          mods = mod.SUPER,     action = act.SpawnWindow },

   -- window: zoom window
   -- Shrink window (Alt+-)
   {
      key = '-',
      mods = mod.SUPER,
      action = wezterm.action_callback(function(window, _pane)
         local dimensions = window:get_dimensions()
         if dimensions.is_full_screen then
            return
         end
         local new_width = dimensions.pixel_width - 50
         local new_height = dimensions.pixel_height - 50
         window:set_inner_size(new_width, new_height)
      end)
   },
   -- Grow window (Alt+=)
   {
      key = '=',
      mods = mod.SUPER,
      action = wezterm.action_callback(function(window, _pane)
         local dimensions = window:get_dimensions()
         if dimensions.is_full_screen then
            return
         end
         local new_width = dimensions.pixel_width + 50
         local new_height = dimensions.pixel_height + 50
         window:set_inner_size(new_width, new_height)
      end)
   },
   -- Maximize window (Alt+Ctrl+Enter)
   {
      key = 'Enter',
      mods = mod.SUPER_REV,
      action = wezterm.action_callback(function(window, _pane)
         window:maximize()
      end)
   },

   -- background controls --
   -- Random backdrop (Alt+/)
   {
      key = [[/]],
      mods = mod.SUPER,
      action = wezterm.action_callback(function(window, _pane)
         backdrops:random(window)
      end),
   },
   -- Cycle backdrop back (Alt+,)
   {
      key = [[,]],
      mods = mod.SUPER,
      action = wezterm.action_callback(function(window, _pane)
         backdrops:cycle_back(window)
      end),
   },
   -- Cycle backdrop forward (Alt+.)
   {
      key = [[.]],
      mods = mod.SUPER,
      action = wezterm.action_callback(function(window, _pane)
         backdrops:cycle_forward(window)
      end),
   },
   -- Select backdrop (Alt+Ctrl+/)
   {
      key = [[/]],
      mods = mod.SUPER_REV,
      action = act.InputSelector({
         title = 'InputSelector: Select Background',
         choices = backdrops:choices(),
         fuzzy = true,
         fuzzy_description = 'Select Background: ',
         action = wezterm.action_callback(function(window, _pane, idx)
            if not idx then
               return
            end
            ---@diagnostic disable-next-line: param-type-mismatch
            backdrops:set_img(window, tonumber(idx))
         end),
      }),
   },
   -- Toggle backdrop focus (Alt+B)
   {
      key = 'b',
      mods = mod.SUPER,
      action = wezterm.action_callback(function(window, _pane)
         backdrops:toggle_focus(window)
      end)
   },

   -- panes --
   -- panes: split panes
   -- SplitVertical current domain (Alt+\)
   {
      key = [[\]],
      mods = mod.SUPER,
      action = act.SplitVertical({ domain = 'CurrentPaneDomain' }),
   },
   -- SplitHorizontal current domain (Alt+Ctrl+\)
   {
      key = [[\]],
      mods = mod.SUPER_REV,
      action = act.SplitHorizontal({ domain = 'CurrentPaneDomain' }),
   },

   -- panes: zoom+close pane
   -- TogglePaneZoomState (Alt+Enter)
   { key = 'Enter', mods = mod.SUPER,     action = act.TogglePaneZoomState },
   -- CloseCurrentPane (Alt+W)
   { key = 'w',     mods = mod.SUPER,     action = act.CloseCurrentPane({ confirm = false }) },

   -- panes: navigation
   -- ActivatePaneDirection up (Alt+Ctrl+K)
   { key = 'k',     mods = mod.SUPER_REV, action = act.ActivatePaneDirection('Up') },
   -- ActivatePaneDirection down (Alt+Ctrl+J)
   { key = 'j',     mods = mod.SUPER_REV, action = act.ActivatePaneDirection('Down') },
   -- ActivatePaneDirection left (Alt+Ctrl+H)
   { key = 'h',     mods = mod.SUPER_REV, action = act.ActivatePaneDirection('Left') },
   -- ActivatePaneDirection right (Alt+Ctrl+L)
   { key = 'l',     mods = mod.SUPER_REV, action = act.ActivatePaneDirection('Right') },
   -- PaneSelect swap with active (Alt+Ctrl+P)
   {
      key = 'p',
      mods = mod.SUPER_REV,
      action = act.PaneSelect({ alphabet = '1234567890', mode = 'SwapWithActiveKeepFocus' }),
   },

   -- panes: scroll pane
   -- ScrollByLine up (Alt+PageUp)
   { key = 'PageUp',   mods = 'ALT',     action = act.ScrollByLine(-5) },
   -- ScrollByLine down (Alt+PageDown)
   { key = 'PageDown', mods = 'ALT',     action = act.ScrollByLine(5) },
   -- ScrollByPage up (Shift+PageUp)
   { key = 'PageUp',   mods = 'SHIFT',   action = act.ScrollByPage(-0.75) },
   -- ScrollByPage down (Shift+PageDown)
   { key = 'PageDown', mods = 'SHIFT',   action = act.ScrollByPage(0.75) },

   -- key-tables --
   -- resizes fonts
   -- Activate resize_font key table (Alt+Ctrl+Space, then F)
   {
      key = 'f',
      mods = 'LEADER',
      action = act.ActivateKeyTable({
         name = 'resize_font',
         one_shot = false,
         timeout_milliseconds = 1000,
      }),
   },
   -- resize panes
   -- Activate resize_pane key table (Alt+Ctrl+Space, then P)
   {
      key = 'p',
      mods = 'LEADER',
      action = act.ActivateKeyTable({
         name = 'resize_pane',
         one_shot = false,
         timeout_milliseconds = 1000,
      }),
   },
}

-- stylua: ignore
local key_tables = {
   resize_font = {
      -- IncreaseFontSize (Leader, F, then K)
      { key = 'k',      action = act.IncreaseFontSize },
      -- DecreaseFontSize (Leader, F, then J)
      { key = 'j',      action = act.DecreaseFontSize },
      -- ResetFontSize (Leader, F, then R)
      { key = 'r',      action = act.ResetFontSize },
      -- PopKeyTable (Leader, F, then Escape)
      { key = 'Escape', action = 'PopKeyTable' },
      -- PopKeyTable (Leader, F, then Q)
      { key = 'q',      action = 'PopKeyTable' },
   },
   resize_pane = {
      -- AdjustPaneSize up (Leader, P, then K)
      { key = 'k',      action = act.AdjustPaneSize({ 'Up', 1 }) },
      -- AdjustPaneSize down (Leader, P, then J)
      { key = 'j',      action = act.AdjustPaneSize({ 'Down', 1 }) },
      -- AdjustPaneSize left (Leader, P, then H)
      { key = 'h',      action = act.AdjustPaneSize({ 'Left', 1 }) },
      -- AdjustPaneSize right (Leader, P, then L)
      { key = 'l',      action = act.AdjustPaneSize({ 'Right', 1 }) },
      -- PopKeyTable (Leader, P, then Escape)
      { key = 'Escape', action = 'PopKeyTable' },
      -- PopKeyTable (Leader, P, then Q)
      { key = 'q',      action = 'PopKeyTable' },
   },
}

local mouse_bindings = {
   -- Ctrl-click will open the link under the mouse cursor
   {
      event = { Up = { streak = 1, button = 'Left' } },
      mods = 'CTRL',
      action = act.OpenLinkAtMouseCursor,
   },
}

return {
   -- disable_default_key_bindings = true,
   -- disable_default_mouse_bindings = true,
   -- Leader key (Alt+Ctrl+Space)
   leader = { key = 'Space', mods = mod.SUPER_REV },
   keys = keys,
   key_tables = key_tables,
   mouse_bindings = mouse_bindings,
}
