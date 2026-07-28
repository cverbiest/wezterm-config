# WezTerm Keybinding Selection (Comprehensive)

This table includes ALL bindings found in your `config/bindings.lua`.

- **Empty New Binding**: Keeps your "Current Binding".
- **Default Column**: Shows what WezTerm uses out-of-the-box.

## 1. Tabs & Windows

| Command            | Action / Event                       | Default                 | Current            | New Binding |
| :----------------- | :----------------------------------- | :---------------------- | :----------------- | :---------- |
| **New Tab**        | `act.SpawnTab('DefaultDomain')`      | `CTRL+SHIFT+T`          | `ALT + T`          |             |
| **New Tab (WSL)**  | `act.SpawnTab({ DomainName = ... })` | (None)                  | `ALT+CTRL + T`     |             |
| **Close Tab**      | `act.CloseCurrentTab`                | `CTRL+SHIFT+W`          | `ALT+CTRL + W`     |             |
| **Prev Tab**       | `act.ActivateTabRelative(-1)`        | `CTRL + PageUp`         | `ALT + [`          |             |
| **Next Tab**       | `act.ActivateTabRelative(1)`         | `CTRL + PageDown`       | `ALT + ]`          |             |
| **Move Tab Left**  | `act.MoveTabRelative(-1)`            | `SHIFT+CTRL + PageUp`   | `ALT+CTRL + [`     |             |
| **Move Tab Right** | `act.MoveTabRelative(1)`             | `SHIFT+CTRL + PageDown` | `ALT+CTRL + ]`     |             |
| **New Window**     | `act.SpawnWindow`                    | `CTRL+SHIFT+N`          | `ALT + N`          |             |
| **Maximize**       | `window:maximize()`                  | (None)                  | `ALT+CTRL + Enter` |             |
| **Toggle Tab Bar** | `tabs.toggle-tab-bar`                | (None)                  | `ALT + 9`          |             |
| **Custom Title**   | `tabs.manual-update-tab-title`       | (None)                  | `ALT + 0`          |             |
| **Reset Title**    | `tabs.reset-tab-title`               | (None)                  | `ALT+CTRL + 0`     |             |

## 2. Panes & Layout

| Command            | Action                               | Default            | Current        | New Binding |
| :----------------- | :----------------------------------- | :----------------- | :------------- | :---------- |
| **Split Vertical** | `act.SplitVertical`                  | `CTRL+SHIFT + "`   | `ALT + \`      |             |
| **Split Horiz**    | `act.SplitHorizontal`                | `CTRL+SHIFT + %`   | `ALT+CTRL + \` |             |
| **Close Pane**     | `act.CloseCurrentPane`               | `CTRL+SHIFT + W`   | `ALT + W`      |             |
| **Toggle Zoom**    | `act.TogglePaneZoomState`            | `SHIFT+CTRL + Z`   | `ALT + Enter`  |             |
| **Navigate Up**    | `act.ActivatePaneDirection('Up')`    | `SHIFT+CTRL+Arrow` | `ALT+CTRL + K` |             |
| **Navigate Down**  | `act.ActivatePaneDirection('Down')`  | `SHIFT+CTRL+Arrow` | `ALT+CTRL + J` |             |
| **Navigate Left**  | `act.ActivatePaneDirection('Left')`  | `SHIFT+CTRL+Arrow` | `ALT+CTRL + H` |             |
| **Navigate Right** | `act.ActivatePaneDirection('Right')` | `SHIFT+CTRL+Arrow` | `ALT+CTRL + L` |             |
| **Swap Panes**     | `act.PaneSelect`                     | (None)             | `ALT+CTRL + P` |             |

## 3. Backgrounds (Backdrops)

| Command           | Action                    | Default | Current        | New Binding |
| :---------------- | :------------------------ | :------ | :------------- | :---------- |
| **Random BG**     | `backdrops:random`        | (None)  | `ALT + /`      |             |
| **Select BG**     | `act.InputSelector`       | (None)  | `ALT+CTRL + /` |             |
| **Cycle Forward** | `backdrops:cycle_forward` | (None)  | `ALT + .`      |             |
| **Cycle Back**    | `backdrops:cycle_back`    | (None)  | `ALT + ,`      |             |
| **Toggle Focus**  | `backdrops:toggle_focus`  | (None)  | `ALT + B`      |             |

## 4. System & Tools

| Command             | Action                       | Default              | Current           | New Binding |
| :------------------ | :--------------------------- | :------------------- | :---------------- | :---------- |
| **Copy Mode**       | `act.ActivateCopyMode`       | `SHIFT+CTRL + X`     | `SHIFT + F1`      | default     |
| **Command Palette** | `act.ActivateCommandPalette` | `SHIFT+CTRL + P`     | `SHIFT + F2`      | default     |
| **Launcher**        | `act.ShowLauncher`           | `SHIFT+CTRL + L`     | `SHIFT + F3`      | default     |
| **Debug Overlay**   | `act.ShowDebugOverlay`       | `SHIFT+CTRL + L`     | `F12`             | default     |
| **Full Screen**     | `act.ToggleFullScreen`       | `ALT + Enter`        | `F11`             |             |
| **Search**          | `act.Search`                 | `SHIFT+CTRL + F`     | `ALT + F`         |             |
| **QuickSelect**     | `QuickSelectArgs` (Custom)   | `SHIFT+CTRL + Space` | `ALT+CTRL + U`    |             |
| **Home (Send)**     | `SendString '\u{1b}OH'`      | `Home`               | `ALT + Left`      |             |
| **End (Send)**      | `SendString '\u{1b}OF'`      | `End`                | `ALT + Right`     |             |
| **Delete Line**     | `SendString '\u{15}'`        | (None)               | `ALT + Backspace` |             |

## 5. Scrolling

| Command              | Action                    | Default            | Current    | New Binding |
| :------------------- | :------------------------ | :----------------- | :--------- | :---------- |
| **Scroll Up Line**   | `act.ScrollByLine(-5)`    | `ALT + PageUp`     | `ALT + U`  | default     |
| **Scroll Down Line** | `act.ScrollByLine(5)`     | `ALT + PageDown`   | `ALT + D`  | default     |
| **Scroll Up Page**   | `act.ScrollByPage(-0.75)` | `SHIFT + PageUp`   | `PageUp`   | default     |
| **Scroll Down Page** | `act.ScrollByPage(0.75)`  | `SHIFT + PageDown` | `PageDown` | default     |

## 6. Modal Key Tables (LEADER)

The **Leader Key** is currently set to `ALT+CTRL + Space`.

| Mode            | Trigger      | Action                       |
| :-------------- | :----------- | :--------------------------- |
| **Font Resize** | `Leader + F` | Activate `resize_font` table |
| **Pane Resize** | `Leader + P` | Activate `resize_pane` table |

---

## Instructions

1. Review the sections above. Total bindings: ~45.
2. Fill in the **New Binding** column for anything you'd like to change.
3. Save and tell me to "Apply these keybindings".
