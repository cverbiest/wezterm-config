# Notes for Claude

## SSH domains share a single connection

`config/domains.lua` drops the `SSHMUX:*` entries from
`wezterm.default_ssh_domains()` and keeps only the `SSH:*` ones. Those are
`multiplexing = "None"`: one direct ssh connection shared by every pane and
tab in that domain, which per WezTerm's docs "will close when the connection
is dropped".

Killing one session therefore takes out every pane on that host. That is the
configuration working as intended, not a bug.

## Don't build a "reconnect dead pane" feature

One was written and reverted without ever working. The `+` button in the tab
bar already starts a fresh session to the host, which is the entire feature.

Every route into the pane's own domain is a dead end once the connection has
dropped:

- `pane:split()` on a dead pane fails with `Closed(..)`
- `domain:detach()` panics with `Option::unwrap()` on a `None` value — a Rust
  panic, so `pcall` cannot catch it
- `SpawnCommandInNewTab` into that domain is a silent no-op — no pane, no error

There is also no way to tell whether an ssh pane is still alive:
`pane:get_foreground_process_info()` and `pane:get_foreground_process_name()`
are both documented as local-pane only, so anything keyed on liveness has to
resort to scanning the pane's text for WezTerm's exit notice.

## Unsolved: close confirmation on a disconnected ssh tab

Closing one still prompts "Really kill this tab and all contained panes?".
`skip_close_confirmation_for_processes_named` does not help — it matches on
process name, and WezTerm has none for a remote pane.

`CloseCurrentTab { confirm = false }` does work, and the <kbd>Alt+Ctrl+W</kbd>
binding in `config/bindings.lua` already uses it. The gap is the tab's `x`
button, which goes through WezTerm's built-in confirming path; whether that is
reachable from config has not been checked.
