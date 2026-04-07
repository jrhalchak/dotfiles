# Norg Format Reference

Norg is the file format used by the Neovim plugin **neorg**. It is not org-mode and
not Markdown — do not apply conventions from either. This document covers the syntax
rules needed to generate or edit `.norg` files correctly.

## Document Metadata

Every norg file should begin with a `@document.meta` block. Fields are `key: value`
pairs, one per line. Multi-word values do not need quotes. List values use `[a b c]`.

```norg
@document.meta
title: My Document
description: A short description
authors: [jrh]
created: 2026-04-05
updated: 2026-04-05
categories: [reference work]
version: 0.1
@end
```

## Headings

Headings use one or more `*` characters followed by a space. Nesting is by number
of stars. Do not use `#` for headings — that is Markdown syntax and is invalid here.
Content under a heading is indented by 3 spaces per heading level.

```norg
* Top-level heading
  Paragraph text at level 1.

** Second level
   More content.

*** Third level
```

## Text Markup

Markup characters wrap the word or phrase with no spaces inside the delimiters.

| Syntax       | Result        |
|--------------|---------------|
| `*word*`     | Bold          |
| `/word/`     | Italic        |
| `_word_`     | Underline     |
| `-word-`     | Strikethrough |
| `` `word` `` | Inline code   |
| `\|word\|`   | Verbatim      |
| `^word^`     | Superscript   |
| `,word,`     | Subscript     |

## Lists

Unordered lists use `-`, ordered lists use `~`. Deeper nesting adds another
`-` or `~`. Each level is indented by a space.

```norg
- First item
- Second item
-- Nested under second
--- Deeper still

~ Step one
~ Step two
~~ Sub-step
```

## Links

| Syntax                    | Links to                        |
|---------------------------|---------------------------------|
| `{:path:}`                | Another norg file               |
| `{:path:* Heading}`       | A heading in another file       |
| `{* Heading}`             | A heading in the current file   |
| `{https://url}[label]`    | External URL with display text  |
| `{https://url}`           | External URL, no display text   |


The label `[label]` is optional on all link types.

## Code Blocks

Use `@code <lang> … @end`. Do not use fenced backticks — those are Markdown.
Use `norg` as the language tag for norg syntax examples.

```norg
@code lua
local x = 1
@end
```

## Tables

Wrap pipe-row tables in `@table … @end`. Bare pipe rows outside `@table` are
parsed as ordinary paragraph text, not tables.

```norg
@table
| Column A | Column B |
|----------|----------|
| Cell 1   | Cell 2   |
@end
```

Do not generate the native `: . :` table syntax. It is in the grammar but has
no exporter or tooling support and should not be used.

## Detached Modifier Extensions

Metadata attaches to any detached modifier (heading, list item, etc.) with
parentheses immediately after the modifier character, before the title text.

| Extension    | Meaning            |
|--------------|--------------------|
| `( )`        | Todo: undone       |
| `(x)`        | Todo: done         |
| `(-)`        | Todo: in progress  |
| `(!)`        | Todo: urgent       |
| `(?)`        | Todo: needs input  |
| `(=)`        | Todo: on hold      |
| `(_)`        | Todo: cancelled    |
| `(+)`        | Recurring          |
| `(# A)`      | Priority A         |
| `(< date)`   | Due date           |
| `(> date)`   | Start date         |

Dates use the format `Mon 7 Apr 2026`. Extensions chain with `|` inside the
same parentheses:

```norg
- (x) Completed item
- (-|# A|< Mon 7 Apr 2026) In progress, high priority, due Monday
* (# B) A heading with priority
```

## Carryover Tags

Carryover tags annotate the **next** element in the document. They go on their
own line immediately before the element.

- `#tag value` — strong: applies to the element and all its children
- `+tag value` — weak: applies to the element only, not its children

Neorg only acts on `#name` internally. All other tags are parsed by tree-sitter
but ignored by neorg — safe to use for custom metadata queryable by scripts.

```norg
#context work
#owner alice
** Planning Phase

+note one-off annotation
- ( ) A single task
```

## Common Mistakes to Avoid

- Do not use `#` for headings — use `*`
- Do not use fenced backticks for code blocks — use `@code lang … @end`
- Do not write bare pipe rows as tables — wrap in `@table … @end`
- Do not use Markdown link syntax `[label](url)` — use `{url}[label]`
- Do not use `**bold**` — use `*bold*`
- Do not omit `@end` to close any ranged tag (`@code`, `@table`, `@document.meta`)
