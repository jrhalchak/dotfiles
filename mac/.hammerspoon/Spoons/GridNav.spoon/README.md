# GridNav

```

░░      ░░░       ░░░        ░░       ░░░   ░░░  ░░░      ░░░  ░░░░  ░
▒  ▒▒▒▒▒▒▒▒  ▒▒▒▒  ▒▒▒▒▒  ▒▒▒▒▒  ▒▒▒▒  ▒▒    ▒▒  ▒▒  ▒▒▒▒  ▒▒  ▒▒▒▒  ▒
▓  ▓▓▓   ▓▓       ▓▓▓▓▓▓  ▓▓▓▓▓  ▓▓▓▓  ▓▓  ▓  ▓  ▓▓  ▓▓▓▓  ▓▓▓  ▓▓  ▓▓
█  ████  ██  ███  ██████  █████  ████  ██  ██    ██        ████    ███
██      ███  ████  ██        ██       ███  ███   ██  ████  █████  ████

```

A keyboard-driven mouse grid navigation system for Hammerspoon.

![Demo GIF](link-to-demo.gif)

## Features
- Keyboard-driven mouse grid navigation system
- Divide screen into navigable quadrants with keyboard shortcuts
- Precisely control cursor position without touching the mouse
- Perform mouse actions (clicks, scrolling) entirely from keyboard

<details>
<summary><strong>Grid Navigation & Manipulation</strong></summary>

- Split the grid into smaller sections using directional keys (h/j/k/l)
- Move the grid around the screen (shift + h/j/k/l)
- Resize grid to match the current active window (t)
- Center grid around current cursor position (c)
- Adjust grid placement with pixel-level precision

</details>

<details>
<summary><strong>Mouse Actions</strong></summary>

- Warp cursor to grid center without clicking (w)
- Left-click at grid center (space or return)
- Right-click at grid center (shift+space or shift+return)
- Right-click while keeping grid active for menu selection

</details>

<details>
<summary><strong>Visual Customization</strong></summary>

- Customizable grid line color, thickness, and opacity
- Border styling options for grid appearance
- Midpoint indicator with configurable shape ("square" or "circle")
- Midpoint size and color options
- Background dimming with adjustable opacity

</details>

<details>
<summary><strong>Keyboard Configuration</strong></summary>

- Fully customizable key bindings for all actions
- Remap directional controls (WASD support, etc.)
- Custom shortcuts for special functions
- Alternative key bindings for common actions

</details>

<details>
<summary><strong>Additional Features</strong></summary>

- Scrolling in all directions at current cursor position
- Optional visual hints showing available commands
- Configure right-click exit behavior
- Easy installation as a Hammerspoon Spoon
- Minimal resource usage
- Comprehensive configuration options

</details>

## Installation
1. Download or clone this repository
2. Move GridNav.spoon to ~/.hammerspoon/Spoons/
3. Add to your init.lua: `hs.loadSpoon("GridNav")`

## Basic Usage
```lua
local gridNav = hs.loadSpoon("GridNav")
gridNav:start()  -- Use default configuration
```

### Focus-Follows-Mouse

If you want windows to focus automatically when warping the cursor, you have several options:

1. For Aerospace or other WM users: Set `focus_follows_mouse = true` or it's equivalent in you configuration.
2. For all users: Install a separate focus-follows-mouse utility like "Focusing" from the Mac App Store.
3. For advanced users: Create a script that enables focus-follows-mouse system-wide.

## Configuration
GridNav can be extensively customized. Below are all of the possible configuration values, and their default values.

### Visual Appearance
```lua
local gridNav = hs.loadSpoon("GridNav")

gridNav:configure({
  -- Grid appearance
  gridLineColor = {red = 0.9, green = 0.9, blue = 0.9, alpha = 0.7},
  gridBorderColor = {red = 0.9, green = 0.9, blue = 0.9, alpha = 0.7},
  gridLineWidth = 1,
  gridBorderWidth = 1,

  -- Midpoint configuration
  midpointSize = 10,
  midpointShape = "square",  -- "square" or "circle"
  midpointFillColor = {red = 1, green = 1, blue = 1, alpha = 0.2},
  midpointStrokeColor = {red = 0.9, green = 0.9, blue = 0.9, alpha = 0.7},
  midpointStrokeWidth = 0,
  showMidpoint = true,

  -- Background appearance
  dimBackground = true,
  dimColor = {red = 0, green = 0, blue = 0, alpha = 0.3},

  -- UI behavior
  showModalAlert = false,
  rightClickExitsGrid = false  -- When false, right-click keeps grid active
})

gridNav:start()
```

### Custom Keybindings
You can use the `gridNav:bindHotkeys()` method to set keybindings, or pass this object as the `keys = {}` property in the `gridNav:configure()` method.

```lua
local gridNav = hs.loadSpoon("GridNav")

gridNav:bindHotkeys({
  -- Main activation key
  activate = {{"cmd"}, ";"},

  -- Grid division keys
  halveLeft = "h",
  halveRight = "l",
  halveUp = "k",
  halveDown = "j",

  -- Grid movement
  moveLeft = {{"shift"}, "h"},
  moveRight = {{"shift"}, "l"},
  moveUp = {{"shift"}, "k"},
  moveDown = {{"shift"}, "j"},

  -- Mouse actions
  warpCursor = "w",
  leftClick = "space",
  leftClickAlt = "return",
  rightClick = {{"shift"}, "space"},
  rightClickAlt = {{"shift"}, "return"},

  -- Special functions
  resizeToWindow = "t",
  centerAroundCursor = "c",

  -- Scroll settings
  scrollEnabled = true,
  scrollDown = {{"cmd", "shift"}, "j"},
  scrollUp = {{"cmd", "shift"}, "k"},
  scrollLeft = {{"cmd", "shift"}, "h"},
  scrollRight = {{"cmd", "shift"}, "l"}
})

gridNav:start()
```

## API Reference

### Methods


| Method | Parameters | Description |
|--------|------------|-------------|
| `init([userConfig])` | `userConfig` - Optional table with configuration settings | Initialize GridNav's state and configuration |
| `configure(userConfig)` | `userConfig` - Table containing configuration options | Update GridNav settings after initialization |
| `getConfig()` | None | Returns a copy of the current configuration table |
| `bindHotkeys(mapping)` | `mapping` - Table with key mapping definitions | Customize keyboard shortcuts |
| `start()` | None | Start GridNav and activate hotkeys |
| `stop()` | None | Stop GridNav and deactivate hotkeys |

### Configuration Options


| Option | Type | Default | Description |
|--------|------|---------|-------------|
| `gridLineColor` | Table | `{red = 0.9, green = 0.9, blue = 0.9, alpha = 0.7}` | Color for grid lines |
| `gridBorderColor` | Table | `{red = 0.9, green = 0.9, blue = 0.9, alpha = 0.7}` | Color for grid border |
| `gridLineWidth` | Number | `1` | Width of grid lines in pixels |
| `gridBorderWidth` | Number | `1` | Width of grid border in pixels |
| `midpointSize` | Number | `10` | Size of midpoint indicator in pixels |
| `midpointShape` | String | `"square"` | Shape of midpoint ("square" or "circle") |
| `showMidpoint` | Boolean | `true` | Whether to show midpoint indicator |
| `dimBackground` | Boolean | `true` | Whether to dim background behind grid |
| `dimColor` | Table | `{red = 0, green = 0, blue = 0, alpha = 0.3}` | Color for background dim |
| `showModalAlert` | Boolean | `false` | Show alerts for keyboard commands |
| `rightClickExitsGrid` | Boolean | `false` | Exit grid after right-clicking |


## Todos
- [ ] Double-click
- [ ] U/D extra-scroll
- [ ] Click -> Drag -> Release workflow
- [ ] Test multi-monitor support

### Nice to Haves
- [ ] Macros?

## License & Copyright

&copy; 2025 Jonathan Halchak

MIT License


