# mdagenda

A Neovim plugin for tracking and managing todos across multiple Markdown vaults. Scans `.md` files with `ripgrep`, renders an agenda panel with three views (Today, Priority, Calendar), and provides in-buffer helpers for editing checkbox lines.

---

## Requirements

- Neovim 0.10+
- [`ripgrep`](https://github.com/BurntSushi/ripgrep) (`rg`) on `$PATH`
- [`mattn/calendar-vim`](https://github.com/mattn/calendar-vim) for due-date pickers (optional but expected in this config)

---

## Installation

mdagenda is a local plugin. It lives at `~/.config/nvmd/lua/mdagenda/` and is registered in lazy.nvim as a `dir =` spec:

```lua
{
  dir = vim.fn.stdpath("config") .. "/lua/mdagenda",
  name = "mdagenda",
  lazy = true,
  keys = {
    { "<leader>na", function() require("mdagenda").toggle() end, desc = "Agenda" },
  },
  config = function()
    require("mdagenda").setup()
  end,
}
```

---

## Configuration

Call `setup()` once during plugin initialisation. All keys are optional.

```lua
require("mdagenda").setup({
  vaults = {
    notes = vim.fn.expand("~/vault/notes"),
    omni  = vim.fn.expand("~/vault/omni"),
    work  = vim.fn.expand("~/vault/work"),
  },
  -- Fixed side-panel width in columns.
  -- nil = max(40, editor_width / 4)
  panel_width = nil,
})
```

### `vaults`

A table mapping vault names to absolute directory paths. Any number of vaults can be defined. Names are arbitrary but must be consistent — they appear in the panel as vault tags and are used by the vault filter cycle.

---

## Todo syntax

mdagenda reads two kinds of todos from `.md` files.

### Inline checkbox items

Standard GFM checkbox list items with an extended state set:

```markdown
- [ ] Not started
- [/] In progress
- [!] Blocked
- [-] Cancelled
- [x] Complete
```

#### Inline tags

Tags are appended anywhere after the checkbox text. They are stripped from the display text in the panel.

**Due date:**
```markdown
- [ ] Review Q1 goals [due::2026-04-10]
- [ ] Stand-up prep   [due::2026-04-10T09:00]
```

**Priority:**
```markdown
- [ ] Critical bug fix [priority::high]
- [ ] Documentation    [priority::medium]
- [ ] Nice to have     [priority::low]
```

Tags can be combined:
```markdown
- [/] Deploy to staging [due::2026-04-15] [priority::high]
```

### File-level todos (frontmatter)

A file with a `due:` field in its YAML frontmatter is treated as a synthetic todo representing the file as a whole. `priority:` and `status:` frontmatter fields are also read.

```yaml
---
title: Q2 planning
due: 2026-05-01
priority: high
status: not_started
---
```

The display text in the panel is derived from the filename (hyphens and underscores replaced with spaces), suffixed with `(file)`.

---

## The agenda panel

Open/close with `<leader>na` (or via `:lua require("mdagenda").toggle()`).

The panel opens as a side panel on the right (~25% of editor width). Press `f` to toggle between side panel and full-window mode.

Scanning is async (two concurrent `rg` passes). The panel refreshes automatically on `BufWritePost *.md`.

### Panel keymaps

#### View switching

| Key | Action |
|-----|--------|
| `1` | Today view |
| `2` | Priority view |
| `3` | Calendar view |

#### Navigation

| Key | Action |
|-----|--------|
| `<CR>` | Open file under cursor in the previous window |
| `<C-v>` | Open file in a vertical split |
| `<C-s>` | Open file in a horizontal split |
| `t` | Open file in a new tab |

Cursor jumps to the exact line of the todo item after opening.

#### Filtering

| Key | Action |
|-----|--------|
| `v` | Cycle vault filter: all → notes → omni → work → all |
| `d` | Toggle display of completed items (hidden by default) |

Cancelled items are always excluded.

#### Other

| Key | Action |
|-----|--------|
| `f` | Toggle side panel / full window |
| `r` | Refresh (re-run scan) |
| `q` | Close panel |

---

## Views

### Today view (`1`)

Todos grouped into five sections, in order:

| Section | Criteria |
|---------|----------|
| **Overdue** | `due_date` < today |
| **Today** | `due_date` == today |
| **This week** | `due_date` within the current ISO week (Mon–Sun) |
| **Later** | `due_date` beyond this week |
| **No due date** | No `[due::...]` tag |

Within each section, todos are sorted by priority (high → medium → low → unset), then by file path.

The **No due date** section is collapsed by default. Press `<Tab>` while in the Today view to expand or collapse it.

### Priority view (`2`)

All outstanding todos grouped into four sections:

- **High priority** — `[priority::high]`
- **Medium priority** — `[priority::medium]`
- **Low priority** — `[priority::low]`
- **No priority** — no priority tag

Within each group, todos are sorted by due date (ascending, nil last), then by file path.

### Calendar view (`3`)

Two sub-modes, toggled with `w`:

#### Week view (default)

A 7-column grid (Mon–Sun) showing todos with due dates in the current week. Each cell shows the checkbox state, optional time, and a truncated version of the todo text.

Today's column is highlighted. Weekend columns are dimmed.

#### Month view

A date grid for the current month. Days with at least one todo are marked with `+` and highlighted. Press `<CR>` on a day to zoom into the week view for that date.

#### Calendar navigation

| Key | Action |
|-----|--------|
| `[` | Previous week / previous month |
| `]` | Next week / next month |
| `w` | Toggle week / month sub-mode |

---

## In-buffer editing helpers

These operate on the **checkbox line under the cursor** in any buffer. If the cursor is not on a checkbox line (`- [ ]`, `- [/]`, etc.), a warning is shown and nothing is changed.

### Set due date — `<leader>nD`

Opens the calendar-vim date picker. On selection, writes or replaces the `[due::YYYY-MM-DD]` tag on the current line.

### Set due date + time — `<leader>nT`

Opens the calendar-vim date picker. After selecting a date, a `vim.ui.input` prompt asks for an optional time (`HH:MM`). Blank input or invalid format skips the time. Writes `[due::YYYY-MM-DDThh:mm]` or `[due::YYYY-MM-DD]` accordingly.

### Cycle priority — `<leader>nP`

Cycles the `[priority::...]` tag on the current line through:

```
none → [priority::high] → [priority::medium] → [priority::low] → none
```

If a tag is already present it is replaced in-place. Removing low wraps back to none (the tag is stripped from the line entirely).

### Convert todo to task file — `<leader>nC`

Converts a checkbox line into a standalone task file and replaces the line with a wikilink.

**Example — before:**
```markdown
- [ ] Review Q1 goals [due::2026-04-15] [priority::high]
```

**After:**
```markdown
- [ ] [[tasks/review-q1-goals]]
```

**Created file — `{vault}/tasks/review-q1-goals.md`:**
```markdown
---
title: Review Q1 goals
status: not_started
due: 2026-04-15
priority: high
---

```

Behaviour:
- The task file is created inside a `tasks/` subdirectory of the **same vault** as the source file. The directory is created if it does not exist.
- The filename is a slug derived from the todo text: lowercased, non-alphanumeric characters stripped, spaces collapsed to hyphens, truncated at 60 characters.
- Frontmatter includes `due:` and `priority:` only if those tags were present on the original line.
- If a file at the target path already exists, the operation is aborted with a warning and the source line is left unchanged.
- Indentation and checkbox state are preserved in the replacement wikilink line.

---

## Architecture

```
mdagenda/
  init.lua        public API: setup(), open(), close(), refresh(), toggle()
  config.lua      vault paths and resolved config after setup()
  state.lua       singleton: win, buf, view, filter, todos cache, line_map
  highlights.lua  MdAgenda* highlight group definitions + ColorScheme autocmd
  scanner.lua     async rg shell-outs (two concurrent passes)
  parser.lua      structured todo objects from raw rg lines
  ui.lua          panel creation, render dispatch, keymaps, full/side toggle
  edit.lua        in-buffer checkbox line editing (due date, priority)
  convert.lua     todo-to-task-file conversion
  views/
    today.lua     Overdue / Today / This week / Later / No due date
    priority.lua  High / Medium / Low / Unset groups
    calendar.lua  week grid and month grid with navigation
```

### Scanner

Two `rg` passes run concurrently via `vim.fn.jobstart`. A shared counter fires the parse callback only after both complete.

- Pass 1 — checkbox lines: `^\s*- \[[ /!x\-]\]` on `*.md`
- Pass 2 — frontmatter due fields: `^due:\s*\S` on `*.md`

### Todo object

```lua
{
  file         = "/home/jrh/vault/omni/1on1s/alice.md",
  vault        = "omni",
  lnum         = 42,
  state        = "not_started",  -- not_started|in_progress|blocked|complete|cancelled
  text         = "Review Q1 goals",
  due_date     = "2026-04-15",   -- nil if absent
  due_time     = "14:30",        -- nil if absent
  priority     = "high",         -- high|medium|low|nil
  is_file_todo = false,
}
```

### Highlights

All highlight groups are defined in `highlights.lua` and applied once at `setup()`, then re-applied on the `ColorScheme` autocmd. Groups link to standard Neovim groups where possible so your colorscheme is respected without extra configuration.

Groups defined (all prefixed `MdAgenda`):

- `Header`, `HeaderToday`, `HeaderOverdue`, `HeaderLater`
- `PriorityHigh`, `PriorityMedium`, `PriorityLow`, `PriorityUnset`
- `StateNotStarted`, `StateInProgress`, `StateBlocked`, `StateCancelled`, `StateDone`
- `DueOverdue`, `DueToday`, `DueSoon`, `DueLater`
- `VaultNotes`, `VaultOmni`, `VaultWork`
- `Dimmed`, `FilePath`
- `CalDay`, `CalToday`, `CalWeekend`, `CalHasTodo`

To override a group, define it in your colorscheme or `after/plugin/` before `setup()` is called, or redefine it after. The `attach_autocmd()` call in `setup()` re-applies defaults on every `ColorScheme` event, so overrides placed in an `after/` file will take precedence.

## Todo
- There's some repetition throughout the module files, like copying the todo state indicators across files instead of sharing them as a constant, perhaps at the config/setup level.
- This could be moved/packaged as an actual plugin instead of a local module.
- Configuration should include specifying folder name for holding tasks, folder name for zk style notes, conceal characters, and likely a lot more.
