# Quick Start Guide

## 1. Test the Plugin

Reload Neovim or restart, then:

```vim
:OpenTodos
```

This will open the todos sidebar showing all incomplete todos from your current Neorg workspace.

## 2. Basic Navigation

- Press `j` and `k` to move up/down
- Press `<Enter>` on a todo to jump to it in the file
- Press `q` to close the window

## 3. Try the Controls

- Press `s` to cycle through sort modes (none → modified → created)
- Press `g` to cycle through grouping (file → folder → day → week → month)
- Press `f` to cycle through filters (all → journal → important → partial → unknown → hold)
- Press `d` to toggle heading context display

## 4. Verify Features

Create a test file with todos to verify everything works:

```norg
* Test Heading
** Subheading

- ( ) This is a pending todo
- (-) This is in progress
- (!) This is important
- (?) This is unknown
- (=) This is on hold
- (x) This is complete (won't show)
```

Save the file and check the todos window - it should auto-refresh!

## 5. Customize (Optional)

Add to your Neovim config:

```lua
require('neorg_todos').setup({
  group_default = "folder",
  show_heading_context = true,
})
```

## Troubleshooting

### Todos not showing up
- Make sure you're in a Neorg workspace (`:Neorg workspace`)
- Check that ripgrep (`rg`) is installed
- Verify your todos match the pattern: `- ( )` or `- (-)`

### Error loading modules
- Ensure Neorg is properly installed
- Check that treesitter parser for norg is installed

### Navigation not working
- Make sure you're focused on the todos window
- Check that the window is still valid (try `:OpenTodos` again)

## File Structure

```
lua/neorg_todos/
├── init.lua              - Main entry point & config
├── todos.lua             - Command registration
├── ui.lua                - Rendering & display
├── state.lua             - State management
├── parser.lua            - Todo parsing & metadata
├── processing.lua        - Sort/group/filter logic
├── list_manager.lua      - Virtual list management
├── actions.lua           - Keybinding handlers
├── treesitter_utils.lua  - Heading extraction
└── utils.lua             - Helper functions
```

## Next Steps

- Try different grouping modes with your journal files
- Use filters to focus on specific types of todos
- Set up a keybinding to quickly open the todos window
- Experiment with custom filters for your workflow

Enjoy your enhanced Neorg todos experience!
