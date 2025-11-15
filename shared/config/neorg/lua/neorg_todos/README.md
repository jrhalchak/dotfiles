# Neorg Todos

An agenda-like list view for incomplete Todos with management features for Neorg workspaces.

## Features

- **Rich UI with block-drawing characters** for a modern, visual interface
- **Status icons** with color-coding for different todo states
- **Smart grouping** by file, folder, or date (day/week/month)
- **Flexible sorting** by creation date, modification date, or none
- **Powerful filtering** by status, location (journal), or custom filters
- **Heading context** showing parent headings from your Neorg files
- **Keyboard navigation** for quick access to todos
- **Auto-refresh** when files are saved

## Installation

Add to your Neorg config:

```lua
require('neorg_todos').setup({
  -- Optional configuration
  sort_default = "none",          -- "none", "modified", "created"
  group_default = "file",         -- "file", "folder", "day", "week", "month"
  filter_default = "all",         -- "all", "journal", "important", "partial", "unknown", "hold"
  show_heading_context = false,   -- Show parent headings by default
  
  -- Customize status icons (nerdfont icons)
  icons = {
    pending = "",
    progress = "",
    important = "",
    unknown = "",
    hold = "",
  },
  
  -- Add custom filters
  custom_filters = {
    my_filter = function(todos)
      -- Return filtered todos
      return todos
    end
  }
})
```

## Usage

Open the todos panel:
```vim
:OpenTodos
```

Or use the Lua API:
```lua
require('neorg_todos').open()
```

## Keybindings

| Key | Action |
|-----|--------|
| `j` | Move cursor down to next todo |
| `k` | Move cursor up to previous todo |
| `h` | Jump to previous group header |
| `l` | Jump to next group header |
| `<CR>` | Open file and jump to todo location |
| `s` | Cycle sort mode (none → modified → created) |
| `g` | Cycle group mode (file → folder → day → week → month) |
| `f` | Cycle filter mode (all → journal → important → partial → unknown → hold) |
| `d` | Toggle heading context visibility |
| `r` | Refresh todos list |
| `q` | Close todos window |

## Todo Status Types

The plugin recognizes these Neorg todo statuses:

- `( )` - Pending (unchecked)
- `(-)` - In Progress (partial)
- `(!)` - Important (urgent)
- `(?)` - Unknown (needs clarification)
- `(=)` - On Hold (paused)

Completed `(x)` and cancelled `(_)` todos are excluded from the list.

## Sorting

- **None**: Display todos in the order they're found by grep
- **Modified**: Sort by file modification time (most recent first)
- **Created**: Sort by file creation time (newest first)

## Grouping

- **File**: Group todos by their source file (default)
- **Folder**: Group todos by their parent directory
- **Day**: Group by day (from file modification date)
- **Week**: Group by week number
- **Month**: Group by month and year

## Filtering

- **All**: Show all incomplete todos
- **Journal**: Only show todos from `journal/` folders
- **Important**: Only show `(!)` important todos
- **Partial**: Only show `(-)` in-progress todos
- **Unknown**: Only show `(?)` unknown todos
- **Hold**: Only show `(=)` on-hold todos

You can add custom filters via the setup configuration.

## Heading Context

When enabled (press `d` to toggle), the plugin shows the parent heading hierarchy for each todo, helping you understand the context. Generic headings like "TODO" or "Tasks" are automatically hidden to reduce clutter.

Example:
```
▌Project Planning → Sprint 1 → Backend
   Review API endpoints
   Write tests
```

## Technical Details

- Uses ripgrep for fast file searching
- Leverages Neorg's treesitter integration for heading extraction
- Automatically refreshes when `.norg` files are saved
- Virtual list management for efficient rendering

