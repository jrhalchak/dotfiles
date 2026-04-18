# Notes system reference

This documents the notes/journal/agenda system in the nvmd Neovim config.
The system works from any working directory — vault paths are always resolved
from `mdagenda.config`, never from CWD.

`<leader>n?` reopens this file in a vertical split.

---

## Overview

zk-nvim was removed. It used a per-vault SQLite index (`.zk/`) and an LSP
server that crashed under Neovim 0.11 when working across multiple vaults.
Everything it provided is now implemented directly in Lua:

| Was | Now |
|-----|-----|
| `ZkNew { group = "journal" }` | `config/notes.lua` + `config/calendar.lua` |
| `ZkNotes`, `ZkTags` | Telescope `find_files` / `live_grep` scoped to vault |
| `ZkBacklinks` | `live_grep` for `[[vault/relative/path` |
| `ZkLinks` | parse `[[...]]` from buffer → `vim.ui.select` |
| `ZkInsertLink` | Telescope picker + relative link insertion |
| `ZkNewFromTitleSelection` | `notes.new_from_selection()` |
| `ZkIndex` | dropped — no index to maintain |

---

## Dependencies

### Plugins

| Plugin | Owns |
|--------|------|
| `jakewvincent/mkdnflow.nvim` | Link following (`<CR>`, `<BS>`, `<Del>`), checkbox toggle (`<C-Space>`), list items (`o`/`O`), YAML frontmatter parsing, fold text display |
| `OXY2DEV/markview.nvim` | Rendering and concealment (headings, bullets, checkboxes, code blocks, tables, YAML) |
| `nvim-telescope/telescope.nvim` | All note search / insert-link pickers |
| `mattn/calendar-vim` | Date picker for journal, due date, insert date |
| `mdagenda` (local) | Agenda panel (Today / Priority / Calendar views), async vault scanning |
| `dhruvasagar/vim-table-mode` | Table editing with formula support |
| `iamcco/markdown-preview.nvim` | Browser preview |

### External tools

| Tool | Required by | Notes |
|------|-------------|-------|
| `ripgrep` (`rg`) | mdagenda scanner | Must be on `$PATH` |
| Node.js / npm | markdown-preview.nvim | Build step (`cd app && npm install`) |

---

## Vault setup

Three vaults are configured in `lua/mdagenda/config.lua`:

| Name | Path |
|------|------|
| `notes` | `~/vault/notes` |
| `omni` | `~/vault/omni` |
| `work` | `~/vault/work` |

### Vault resolution order

Every notes operation resolves which vault to use via this chain:

1. Current buffer path — if the file lives inside a known vault, use that vault.
2. `$ZK_DEFAULT_VAULT` env var — set this per machine to skip the picker when
   opening Neovim outside a vault (e.g. `export ZK_DEFAULT_VAULT=omni`).
3. Interactive `vim.ui.select` vault picker — shown as a last resort.

### Vault structure

```
~/vault/<name>/
  index.md          top-level index (opened by <leader>nI)
  journal/
    YYYY-MM-DD.md   one file per day
  tasks/            task files created by <leader>nC
  ...               everything else is free-form
```

Journal files are created with this frontmatter template:

```markdown
---
created: YYYY-MM-DD
tags: []
---

# Month D, YYYY
```

---

## Keybindings

### Global (all buffers, normal mode)

#### Journal

| Key | Action |
|-----|--------|
| `<leader>njt` | Open / create today's journal entry |
| `<leader>njn` | Open / create tomorrow's journal entry |
| `<leader>njp` | Open / create yesterday's journal entry |
| `<leader>njc` | Open calendar picker → open that day's journal entry |
| `<leader>njl` | Telescope: list all journal entries |

#### Find / search

| Key | Action |
|-----|--------|
| `<leader>nff` | Telescope: find files in vault |
| `<leader>nft` | Telescope: live grep pre-filled with `#` (tag search) |
| `<leader>nfg` | Telescope: live grep in vault |
| `<leader>nb`  | Telescope: live grep for `[[vault/relative/path` (backlinks) |
| `<leader>nl`  | `vim.ui.select` picker over `[[links]]` in current buffer |

#### Notes

| Key | Action |
|-----|--------|
| `<leader>nnn` | Prompt for title → create note in current buffer's directory |
| `<leader>ni`  | Telescope picker → insert `[[rel\|cword]]` at cursor |
| `<leader>nm`  | Insert YAML frontmatter at top of buffer |
| `<leader>nI`  | Open `index.md` for current vault (or pick vault) |
| `<leader>nv`  | Vault picker → open that vault's `index.md` |
| `<leader>n?`  | Open this file in a vertical split |

#### Agenda / tasks

| Key | Action |
|-----|--------|
| `<leader>na`  | Toggle agenda panel |
| `<leader>nD`  | Calendar picker → set `[due::YYYY-MM-DD]` on checkbox line |
| `<leader>nT`  | Calendar picker + time prompt → set `[due::YYYY-MM-DDThh:mm]` |
| `<leader>nP`  | Cycle `[priority::high\|medium\|low]` on checkbox line |
| `<leader>nC`  | Convert checkbox line to standalone task file + replace with wikilink |

#### Calendar / dates

| Key | Action |
|-----|--------|
| `<leader>nd`  | Calendar picker → insert `YYYY-MM-DD` at cursor |
| `<leader>nD`  | Calendar picker → set due date on checkbox line (see above) |
| `<leader>nT`  | Calendar picker + time → set due date+time on checkbox line |

---

### Markdown buffers only

These are set by `keymaps.setup_markdown()` on `FileType markdown`.

#### Navigation (normal mode)

| Key | Action |
|-----|--------|
| `<CR>` | Follow first `[[link]]` or `[text](url)` on the current line |
| `<BS>` | Go back (mkdnflow) |
| `<Del>` | Go forward (mkdnflow) |
| `<Tab>` | Jump to next link in buffer |
| `<S-Tab>` | Jump to previous link in buffer |
| `]]` | Next heading |
| `[[` | Previous heading |
| `<M-CR>` | Destroy link under cursor |

#### Editing (normal mode)

| Key | Action |
|-----|--------|
| `<C-Space>` | Toggle checkbox state (cycles through states) |
| `o` | New list item below, enter insert mode |
| `O` | New list item above, enter insert mode |
| `<leader>nL` | Telescope picker → insert `[[rel\|cword]]` (word under cursor as display text) |
| `<leader>p`  | Paste clipboard as markdown link (`[text](url)`) |

#### Editing (visual mode)

| Key | Action |
|-----|--------|
| `<C-Space>` | Toggle checkbox state on selected lines |
| `<leader>nL` | Telescope picker → insert `[[rel\|selection]]` (selection as display text) |
| `<leader>nc` | Prompt for slug → create note from selection title + replace with wikilink |

#### Insert mode

| Key | Action |
|-----|--------|
| `<CR>` | Continue list / follow link behaviour (mkdnflow) |

---

### Table mode (`<leader>T*`)

| Key | Action |
|-----|--------|
| `<leader>Tt` | Toggle table mode |
| `<leader>Tr` | Realign table |
| `<leader>Tf` | Evaluate formula line |
| `<leader>Ta` | Add formula |

---

## Note and task file format

### Frontmatter fields

| Field | Type | Used by |
|-------|------|---------|
| `title` | string | Display; new-note template |
| `created` | `YYYY-MM-DD` | Informational |
| `tags` | YAML list | Searchable via `<leader>nft` |
| `due` | `YYYY-MM-DD` | mdagenda file-level todo |
| `priority` | `high\|medium\|low` | mdagenda file-level todo |
| `status` | `not_started\|in_progress\|blocked\|cancelled\|complete` | mdagenda file-level todo |

### Checkbox states

| Marker | State | Rendered by markview |
|--------|-------|----------------------|
| `- [ ]` | not started | `○` |
| `- [/]` | in progress | `◎` |
| `- [!]` | blocked | `⊘` |
| `- [-]` | cancelled | `⊗` |
| `- [x]` | complete | `●` |

### Inline tags

Appended anywhere after the checkbox text. Multiple tags are space-separated.

```markdown
- [ ] Ship the feature [due::2026-05-01] [priority::high]
- [/] Write tests      [due::2026-04-15T14:00]
```

Tags are stripped from display text in the agenda panel.

---

## Agenda panel

Open/close with `<leader>na`. Three views, switched with number keys.

### Views

| Key | View | Groups |
|-----|------|--------|
| `1` | Today | Overdue / Today / This week / Later / No due date |
| `2` | Priority | High / Medium / Low / No priority |
| `3` | Calendar | Week grid (Mon–Sun) or month grid |

The **No due date** section in Today view is collapsed by default — press `<Tab>` to expand.

### Panel keymaps

| Key | Action |
|-----|--------|
| `<CR>` | Open file under cursor in previous window, jump to line |
| `<C-v>` | Open in vertical split |
| `<C-s>` | Open in horizontal split |
| `t` | Open in new tab |
| `v` | Cycle vault filter: all → notes → omni → work → all |
| `d` | Toggle display of completed items |
| `[` | Previous week / month |
| `]` | Next week / month |
| `w` | Toggle week / month sub-mode (Calendar view) |
| `f` | Toggle side panel / full window |
| `r` | Refresh (re-scan vaults) |
| `q` | Close panel |

Cancelled items are always excluded from the panel.

---

## Architecture

```
lua/
  config/
    notes.lua       vault resolution, journal, search, link insertion,
                    new-note creation — the main notes API
    calendar.lua    calendar-vim action dispatch (date insert, journal,
                    due date, due date+time)
    keymaps.lua     all <leader>n* bindings; setup_markdown() for
                    buffer-local markdown bindings
    autocmds.lua    wires setup_markdown() on FileType markdown

  mdagenda/         local plugin — agenda panel and in-buffer todo editing
    init.lua        public API: setup(), toggle(), open(), close(), refresh()
    config.lua      vault paths after setup(); vault_for_path(), default_vault()
    scanner.lua     async rg passes (checkbox lines + frontmatter due fields)
    parser.lua      raw rg lines → structured todo objects
    state.lua       singleton: panel win/buf, current view/filter, todo cache
    ui.lua          panel creation, render dispatch, panel keymaps
    edit.lua        set_due(), cycle_priority() — operate on cursor line
    convert.lua     todo_to_task() — checkbox line → standalone task file
    views/
      today.lua     Overdue / Today / This week / Later / No due date
      priority.lua  High / Medium / Low / Unset groups
      calendar.lua  week grid and month grid

  plugins/
    markdown.lua    lazy.nvim specs: mkdnflow, markview, calendar-vim,
                    mdagenda, markdown-preview, vim-table-mode
```

### Link format

Links use wiki-link style with relative paths and no `.md` extension:

```markdown
[[relative/path|display text]]
[[relative/path]]
```

Paths are relative to the **current file's directory** (mkdnflow
`path_resolution.primary = "current"`). `notes.lua` computes the correct
relative path using `relpath(from_dir, to_abs)` when inserting links.

---

## Known gaps / in progress

- `notes.new_note()` places files in the current buffer's directory, which
  is correct but offers no subdirectory picker.
- Checkbox state cycling order is defined independently in mkdnflow config
  and mdagenda — could be unified in a shared constant.
- mdagenda configuration does not yet expose the `tasks/` subdirectory name,
  checkbox state icons, or conceal characters.
- The system could be packaged as a proper plugin rather than a local module.
