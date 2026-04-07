#!/usr/bin/env python3
"""
norg2md.py — Convert Neorg (.norg) files to Markdown (.md).

Usage:
    python3 norg2md.py [options] <vault_root>

Options:
    --dry-run       Print unified diffs; write nothing. (Default.)
    --apply         Write converted .md files to disk.
    --delete-norg   Remove .norg files after successful conversion.
                    Only valid with --apply.
    --log FILE      Write a conversion log to FILE (default: stderr summary only).
    --file FILE     Convert a single file instead of a whole vault.

Examples:
    python3 norg2md.py --dry-run ~/vault/notes
    python3 norg2md.py --apply ~/vault/work
    python3 norg2md.py --apply --delete-norg ~/vault/omni
    python3 norg2md.py --dry-run --file ~/vault/notes/index.norg

Notes:
  - Folder structure is preserved; .norg → .md extension.
  - Links are rewritten from {:path:}[text] → [[path]] wikilink syntax.
  - Root-relative links {:$/path:} are resolved relative to the vault root.
  - Heading anchor links ({** Heading} / {:path:** Heading}) lose the anchor
    (no standard cross-file anchor syntax in GFM/zk); flagged in the log.
  - @bdiagram and @data blocks are wrapped in fenced code blocks.
  - Definition lists ($ term / body) become **term** + paragraph.
  - Dry-run is the default; pass --apply to write files.
"""

import argparse
import difflib
import os
import re
import sys
from dataclasses import dataclass, field
from pathlib import Path
from typing import Optional


# ── todo state mapping ────────────────────────────────────────────────────────

NORG_TODO = {
    " ": " ",   # not started  → [ ]
    "x": "x",   # done         → [x]
    "_": "-",   # cancelled    → [-]
    "-": "-",   # on hold      → [-]   (closest match)
    "!": "!",   # urgent       → [!]
    "?": "/",   # uncertain    → [/]   (in_progress is closest)
    "=": "/",   # on hold (=)  → [/]
}


# ── block types ───────────────────────────────────────────────────────────────

class Block:
    NORMAL    = "normal"
    META      = "meta"       # @document.meta
    CODE      = "code"       # @code [lang]
    TABLE     = "table"      # @table
    BDIAGRAM  = "bdiagram"   # @bdiagram
    DATA      = "data"       # @data
    EXAMPLE   = "example"    # @example
    MARKDOWN  = "markdown"   # @markdown (passthrough)
    OTHER     = "other"      # unknown @ block


PASSTHROUGH_BLOCKS = {Block.CODE, Block.BDIAGRAM, Block.DATA, Block.EXAMPLE, Block.OTHER}


# ── per-file conversion state ─────────────────────────────────────────────────

@dataclass
class ConvertState:
    vault_root: Path
    current_file: Path
    warnings: list = field(default_factory=list)
    block: str = Block.NORMAL
    block_lang: str = ""           # language hint for @code blocks
    meta_lines: list = field(default_factory=list)
    in_table: bool = False         # inside a @table block
    fence_open: bool = False       # have we emitted the opening ``` yet


# ── helpers ───────────────────────────────────────────────────────────────────

def warn(state: ConvertState, lnum: int, msg: str):
    state.warnings.append(f"  line {lnum}: {msg}")


def heading_to_anchor(heading_text: str) -> str:
    """
    Slugify a heading string to a GFM/mkdnflow anchor fragment.
    Matches mkdnflow's formatLink logic (links/init.lua):
      1. Strip leading heading markers and whitespace (* ** etc.)
      2. Strip inline markup characters (* / _ ` ^ , -)
      3. Strip punctuation (everything except alphanumeric, space, hyphen, underscore)
      4. Replace spaces with hyphens
      5. Lowercase
      6. Prepend #
    """
    text = heading_text.strip()
    # Strip leading norg heading markers (* ** ***) if present
    text = re.sub(r"^\*+\s*", "", text)
    # Strip inline markup: norg bold (*), italic (/), underline (_), code (`), etc.
    text = re.sub(r"[*/`_^]", "", text)
    # Strip punctuation except hyphens, underscores, and spaces
    text = re.sub(r'[!"#$%&\'()*+,./:;<=>?@\[\]\\^`{|}~]', "", text)
    # Collapse and replace spaces with hyphens
    text = re.sub(r"\s+", "-", text.strip())
    # Collapse double hyphens
    text = re.sub(r"-{2,}", "-", text)
    return "#" + text.lower()


def norg_link_to_wikilink(state: ConvertState, lnum: int, path: str, text: Optional[str]) -> str:
    """
    Convert a norg {:path:} or {:$/path:} reference to a [[wikilink]].
    Heading anchors (** Heading inside the path) are stripped with a warning.
    """
    original_path = path

    # Root-relative: {:$/...} — strip the $/ prefix; link is relative to vault root
    # We keep the path as-is (relative to vault root) since zk resolves from vault root too.
    if path.startswith("$/"):
        path = path[2:]
    elif path.startswith("$"):
        path = path[1:]

    # Heading anchor inside path: {:path:** Heading}
    # The anchor separator is a colon followed by one or more asterisks then space.
    anchor_slug = None
    anchor_m = re.search(r":\*+\s+", path)
    if anchor_m:
        anchor_text = path[anchor_m.end():]
        path        = path[:anchor_m.start()]
        anchor_slug = heading_to_anchor(anchor_text)

    # Bare heading anchor with no file: {** Heading}
    if re.match(r"^\*+\s+", path):
        anchor_text = re.sub(r"^\*+\s+", "", path)
        slug = heading_to_anchor(anchor_text)
        display = text or anchor_text
        return f"[{display}]({slug})"

    # Strip trailing .norg extension if present (links rarely include it, but just in case)
    path = re.sub(r"\.norg$", "", path)

    # Strip trailing colon (sometimes present in bare {:path:} with no text)
    path = path.rstrip(":")

    if text:
        # If text matches the filename (slugified), bare link is cleaner
        basename = Path(path).name
        if text.strip().lower().replace(" ", "-") == basename.lower():
            return f"[[{path}{anchor_slug or ''}]]"
        return f"[[{path}{anchor_slug or ''}|{text}]]"
    else:
        return f"[[{path}{anchor_slug or ''}]]"


def convert_links(line: str, state: ConvertState, lnum: int) -> str:
    """
    Convert all norg link forms to Markdown/wikilink.

    Norg forms:
      {:path:}[text]     — internal link, text after
      [text]{:path:}     — internal link, text before
      {:path:}           — internal link, no text
      {# anchor}[text]   — in-file heading anchor
      {** Heading}       — bare in-file heading anchor (no text)
      [text]{url}        — external link, text before url
      {url}[text]        — external link, text after
      {url}              — bare external link
      {$ term}           — norg definition reference → plain term text

    IMPORTANT: link conversion must happen BEFORE convert_inline() so that
    path slashes and other special chars inside {...} are never seen by the
    italic/bold regexes.
    """

    # {:path:}[text]  (text after)
    def repl_internal_after(m):
        path = m.group(1)
        text = m.group(2) or None
        return norg_link_to_wikilink(state, lnum, path, text)

    # [text]{:path:}  (text before)
    def repl_internal_before(m):
        text = m.group(1) or None
        path = m.group(2)
        return norg_link_to_wikilink(state, lnum, path, text)

    # Bare {:path:} with no text
    def repl_internal_bare(m):
        path = m.group(1)
        return norg_link_to_wikilink(state, lnum, path, None)

    # {# in-file anchor}[text]
    def repl_anchor_after(m):
        anchor = m.group(1).strip()
        text   = m.group(2)
        slug   = heading_to_anchor(anchor)
        display = text or anchor
        return f"[{display}]({slug})"

    # Bare in-file heading anchor: {** Heading} or {* Heading} etc.
    def repl_bare_heading_anchor(m):
        anchor_text = m.group(1).strip()
        slug = heading_to_anchor(anchor_text)
        return f"[{anchor_text}]({slug})"

    # Norg definition reference: {$ term} → plain term
    def repl_def_ref(m):
        return m.group(1).strip()

    # [text]{url}  external
    def repl_ext_before(m):
        text = m.group(1)
        url  = m.group(2)
        return f"[{text}]({url})"

    # {url}[text]  external
    def repl_ext_after(m):
        url  = m.group(1)
        text = m.group(2)
        return f"[{text}]({url})"

    # {url}  bare external
    def repl_ext_bare(m):
        url = m.group(1)
        return f"<{url}>"

    # Apply in order — most-specific patterns first.

    # In-file heading anchor with text: {# ...}[text]
    line = re.sub(r"\{#([^}]+)\}\[([^\]]*)\]", repl_anchor_after, line)

    # Internal links with text after: {:path:}[text]  or  {:path:** Heading}[text]
    line = re.sub(r"\{:([^}]+?):?\}\[([^\]]*)\]", repl_internal_after, line)

    # Internal links with text before: [text]{:path:}  or  [text]{:path:** Heading}
    line = re.sub(r"\[([^\]]*)\]\{:([^}]+?):?\}", repl_internal_before, line)

    # Bare internal link: {:path:}  or  {:path:** Heading}
    line = re.sub(r"\{:([^}]+?):?\}", repl_internal_bare, line)

    # Bare in-file heading anchors: {** Heading}, {*** Heading}, etc.
    line = re.sub(r"\{\*+\s+([^}]+)\}", repl_bare_heading_anchor, line)

    # Norg definition reference: {$ term}
    line = re.sub(r"\{\$\s+([^}]+)\}", repl_def_ref, line)

    # External with text before: [text]{https?://...}
    line = re.sub(r"\[([^\]]+)\]\{(https?://[^}]+)\}", repl_ext_before, line)

    # External with text after: {https?://...}[text]
    line = re.sub(r"\{(https?://[^}]+)\}\[([^\]]+)\]", repl_ext_after, line)

    # Bare external: {https?://...}
    line = re.sub(r"\{(https?://[^}]+)\}", repl_ext_bare, line)

    return line


def convert_inline(line: str) -> str:
    """
    Convert norg inline markup to Markdown.
    Order matters: handle combined */.../* before separate * and /.

    Norg inline:
      *bold*           → **bold**
      /italic/         → *italic*
      */bold-italic/*  → ***bold-italic***
      _underline_      → <u>underline</u>
      `code`           → `code`  (unchanged)
      ^superscript^    → <sup>superscript</sup>

    Intentionally NOT converted (too ambiguous without AST):
      -strikethrough-  — "-" is too common in prose and file paths
      ,subscript,      — "," is too common in prose

    The italic regex is deliberately conservative: it requires the content
    between the slashes to contain no "/" character, preventing false matches
    on file paths and URLs that have already been converted to wikilinks.
    """
    # Protect inline code spans first so we don't mangle their contents.
    # Replace with placeholders, process, then restore.
    code_spans = []
    def save_code(m):
        code_spans.append(m.group(0))
        return f"\x00CODE{len(code_spans)-1}\x00"

    line = re.sub(r"`[^`]+`", save_code, line)

    # Bold+italic combined: */.../* or /*...*/ 
    line = re.sub(r"\*/([^/]+)/\*", r"***\1***", line)
    line = re.sub(r"/\*([^*]+)\*/", r"***\1***", line)

    # Bold: *text* — only when * is NOT at the very start of the stripped line
    # (start-of-line * is a heading or list marker, already handled).
    # Require non-space on both inner sides.
    # Use a negative lookbehind for whitespace/start and lookahead to avoid **
    line = re.sub(r"(?<!\*)\*(?!\s)([^*\n]+?)(?<!\s)\*(?!\*)", r"**\1**", line)

    # Italic: /text/ — require no "/" inside the span (avoids path false-positives).
    # Also require the span not to be immediately preceded by a word char or colon
    # (avoids matching inside URLs like https://foo).
    line = re.sub(r"(?<![:\w])/(?!\s)([^/\n]+?)(?<!\s)/(?!\w)", r"*\1*", line)

    # Underline: _text_ — only when surrounded by non-word chars.
    line = re.sub(r"(?<!\w)_(?!\s)([^_\n]+?)(?<!\s)_(?!\w)", r"<u>\1</u>", line)

    # Superscript: ^text^
    line = re.sub(r"\^([^\^\n]+)\^", r"<sup>\1</sup>", line)

    # Restore code spans.
    for i, span in enumerate(code_spans):
        line = line.replace(f"\x00CODE{i}\x00", span)

    return line


def meta_to_frontmatter(meta_lines: list[str]) -> list[str]:
    """
    Convert @document.meta block lines to YAML frontmatter.
    Norg meta format: key: value (no quotes needed; value may be empty)
    We pass through all keys as-is; just wrap in --- delimiters.
    """
    out = ["---"]
    for line in meta_lines:
        # Skip blank lines and version line (Neorg internal)
        stripped = line.strip()
        if not stripped or stripped.startswith("version:"):
            continue
        out.append(stripped)
    out.append("---")
    return out


def convert_list_line(line: str, state: ConvertState, lnum: int) -> str:
    """
    Convert norg list items to Markdown.

    Norg:
      - item           (unordered, depth 1)
      -- item          (unordered, depth 2)
      --- item         (depth 3)
      ~ item           (ordered, depth 1 — rare)
      ~~ item          (ordered, depth 2)

    Todos embedded in list items:
      - ( ) item
      - (x) item

    Norg indents with spaces but also uses -- for sub-items. We normalise
    to 2-space indent per level.
    """
    # Match list markers: leading whitespace + dashes + space
    m = re.match(r"^(\s*)(--*|~~*)\s+(.*)", line)
    if not m:
        return line

    indent_ws = m.group(1)
    marker    = m.group(2)
    rest      = m.group(3)

    # Depth from the marker character count
    depth = len(marker)
    # Norg also uses leading whitespace for sub-items under headings;
    # combine both sources of depth: marker depth takes priority.
    indent = "  " * (depth - 1)

    # Determine list type
    if marker.startswith("~"):
        bullet = "1."
    else:
        bullet = "-"

    # Check for todo state: ( ) (x) etc.
    todo_m = re.match(r"^\((.)\)\s+(.*)", rest)
    if todo_m:
        state_char = todo_m.group(1)
        text       = todo_m.group(2)
        md_state   = NORG_TODO.get(state_char, " ")
        rest = f"[{md_state}] {text}"

    return f"{indent}{bullet} {rest}"


def convert_heading(line: str) -> Optional[str]:
    """
    Convert a norg heading line (* H1, ** H2, etc.) to Markdown (# H1, ## H2).
    Returns None if the line is not a heading.
    Headings in norg are at column 0 (no leading whitespace).

    Also strips redundant inline bold/italic markers from the heading text —
    e.g. "* *Title*" → "# Title" (headings are already visually prominent).
    """
    m = re.match(r"^(\*+)\s+(.*)", line)
    if not m:
        return None
    depth   = len(m.group(1))
    content = m.group(2).strip()
    # Strip wrapping bold markers if the entire heading text is bolded.
    content = re.sub(r"^\*(.+)\*$", r"\1", content)
    # Strip wrapping italic markers if the entire heading text is italicised.
    content = re.sub(r"^/(.+)/$", r"\1", content)
    return "#" * depth + " " + content


def convert_definition(line: str) -> Optional[str]:
    """
    Convert a norg definition list term ($ Term) to **Term**.
    The body follows as normal indented text.
    Returns None if not a definition term.
    """
    m = re.match(r"^(\s*)\$\s+(.*)", line)
    if not m:
        return None
    indent  = m.group(1)
    term    = m.group(2).strip()
    return f"{indent}**{term}**"


def convert_hr(line: str) -> Optional[str]:
    """
    Norg horizontal rule: ___  (3+ underscores on their own line) → ---
    """
    if re.match(r"^\s*_{3,}\s*$", line):
        return "---"
    return None


# ── per-line dispatcher ───────────────────────────────────────────────────────

def process_line(raw: str, lnum: int, state: ConvertState) -> list[str]:
    """
    Given a raw norg line and current block state, return a list of output lines.
    (Usually one, but meta conversion emits multiple.)
    """
    line = raw.rstrip("\n")

    # ── block boundary detection ──────────────────────────────────────────────

    # Opening @ tags
    block_open = re.match(r"^\s*@(\w+)(.*)", line)
    if block_open and state.block == Block.NORMAL:
        tag  = block_open.group(1).lower()
        rest = block_open.group(2).strip()

        if tag == "document":
            # @document.meta
            state.block = Block.META
            state.meta_lines = []
            return []

        elif tag == "code":
            state.block     = Block.CODE
            state.block_lang = rest if rest else ""
            state.fence_open = True
            return [f"```{state.block_lang}"]

        elif tag == "table":
            state.block    = Block.TABLE
            state.in_table = True
            # @table wrapper is dropped; the pipe rows pass through as GFM
            return []

        elif tag == "bdiagram":
            state.block     = Block.BDIAGRAM
            state.fence_open = True
            return ["```"]

        elif tag == "data":
            state.block     = Block.DATA
            state.fence_open = True
            return ["```"]

        elif tag == "example":
            state.block     = Block.EXAMPLE
            state.fence_open = True
            return ["```"]

        elif tag == "markdown":
            state.block = Block.MARKDOWN
            return []

        else:
            state.block     = Block.OTHER
            state.fence_open = True
            return [f"```  <!-- @{tag} -->"]

    # @end closes any block
    if re.match(r"^\s*@end\s*$", line):
        prev_block = state.block
        state.block = Block.NORMAL

        if prev_block == Block.META:
            fm = meta_to_frontmatter(state.meta_lines)
            state.meta_lines = []
            return fm

        elif prev_block == Block.TABLE:
            state.in_table = False
            return []

        elif prev_block == Block.MARKDOWN:
            return []

        elif state.fence_open:
            state.fence_open = False
            return ["```"]

        return []

    # ── inside blocks ─────────────────────────────────────────────────────────

    if state.block == Block.META:
        state.meta_lines.append(line)
        return []

    if state.block in PASSTHROUGH_BLOCKS:
        # Pass content through verbatim; @end handled above.
        return [line]

    if state.block == Block.TABLE:
        # Pipe table rows pass through; @table/@end wrappers are dropped.
        return [line]

    if state.block == Block.MARKDOWN:
        return [line]

    # ── normal block ──────────────────────────────────────────────────────────

    # Horizontal rule
    hr = convert_hr(line)
    if hr is not None:
        return [hr]

    # Heading
    heading = convert_heading(line)
    if heading is not None:
        # Apply inline markup and links to heading text
        heading = convert_links(heading, state, lnum)
        heading = convert_inline(heading)
        return [heading]

    # Definition list term
    defn = convert_definition(line)
    if defn is not None:
        defn = convert_links(defn, state, lnum)
        defn = convert_inline(defn)
        return [defn]

    # List item (handles -- nesting and todos)
    # Check if it looks like a list line (may have leading whitespace)
    list_m = re.match(r"^(\s*)(--*|~~*)\s+", line)
    if list_m:
        converted = convert_list_line(line, state, lnum)
        converted = convert_links(converted, state, lnum)
        converted = convert_inline(converted)
        return [converted]

    # Plain paragraph line — apply inline transforms
    out = convert_links(line, state, lnum)
    out = convert_inline(out)
    return [out]


# ── file-level conversion ─────────────────────────────────────────────────────

def convert_file(norg_path: Path, vault_root: Path) -> tuple[list[str], list[str], list[str]]:
    """
    Convert a single .norg file.
    Returns (input_lines, output_lines, warnings).
    """
    state = ConvertState(vault_root=vault_root, current_file=norg_path)

    try:
        raw_lines = norg_path.read_text(encoding="utf-8").splitlines(keepends=True)
    except Exception as e:
        return [], [], [f"  could not read file: {e}"]

    output: list[str] = []

    for lnum, raw in enumerate(raw_lines, start=1):
        out_lines = process_line(raw, lnum, state)
        for ol in out_lines:
            output.append(ol + "\n")

    # If file ended mid-block, close any open fence
    if state.fence_open:
        output.append("```\n")
        state.warnings.append(f"  EOF: unclosed block '{state.block}' — fence auto-closed")

    input_lines = [l if l.endswith("\n") else l + "\n" for l in
                   [l.rstrip("\n") for l in raw_lines]]
    # (keep originals as-is for diff)
    input_lines = raw_lines

    return input_lines, output, state.warnings


# ── vault walking ─────────────────────────────────────────────────────────────

def find_norg_files(vault_root: Path) -> list[Path]:
    return sorted(vault_root.rglob("*.norg"))


def md_path(norg_path: Path) -> Path:
    return norg_path.with_suffix(".md")


# ── output / reporting ────────────────────────────────────────────────────────

def print_diff(norg_path: Path, input_lines: list[str], output_lines: list[str]):
    a_name = str(norg_path)
    b_name = str(md_path(norg_path))
    diff = difflib.unified_diff(
        input_lines,
        output_lines,
        fromfile=a_name,
        tofile=b_name,
    )
    try:
        sys.stdout.writelines(diff)
        sys.stdout.flush()
    except BrokenPipeError:
        # Pager exited early (e.g. user quit less/bat). Suppress the traceback;
        # devnull stderr so Python's own shutdown doesn't re-raise on flush.
        sys.stderr = open(os.devnull, "w")
        sys.exit(0)


def print_summary(results: list[dict], dry_run: bool, log_path: Optional[Path]):
    total   = len(results)
    warned  = sum(1 for r in results if r["warnings"])
    clean   = total - warned

    lines = [
        "",
        f"{'DRY RUN — ' if dry_run else ''}Conversion summary",
        f"  Files processed : {total}",
        f"  Clean           : {clean}",
        f"  With warnings   : {warned}",
        "",
    ]

    warning_lines = []
    for r in results:
        if r["warnings"]:
            warning_lines.append(f"{r['file']}:")
            warning_lines.extend(r["warnings"])
            warning_lines.append("")

    if warning_lines:
        lines.append("Files with warnings:")
        lines.extend(warning_lines)

    output = "\n".join(lines)
    print(output, file=sys.stderr)

    if log_path:
        try:
            log_path.write_text(output + "\n", encoding="utf-8")
            print(f"Log written to {log_path}", file=sys.stderr)
        except Exception as e:
            print(f"Could not write log: {e}", file=sys.stderr)


# ── main ──────────────────────────────────────────────────────────────────────

def main():
    parser = argparse.ArgumentParser(
        description="Convert Neorg (.norg) files to Markdown (.md).",
        formatter_class=argparse.RawDescriptionHelpFormatter,
        epilog=__doc__,
    )
    parser.add_argument("vault_root", nargs="?",
                        help="Root directory of the vault to convert.")
    parser.add_argument("--dry-run", action="store_true", default=True,
                        help="Print diffs only; write nothing. (Default.)")
    parser.add_argument("--apply", action="store_true",
                        help="Write converted .md files to disk.")
    parser.add_argument("--delete-norg", action="store_true",
                        help="Delete .norg files after successful conversion. Requires --apply.")
    parser.add_argument("--log", metavar="FILE",
                        help="Write warning log to FILE.")
    parser.add_argument("--file", metavar="FILE",
                        help="Convert a single .norg file instead of a whole vault.")
    parser.add_argument("--quiet", action="store_true",
                        help="Suppress per-file diffs in dry-run mode.")

    args = parser.parse_args()

    # Validation
    if args.apply:
        args.dry_run = False
    if args.delete_norg and not args.apply:
        parser.error("--delete-norg requires --apply")
    if not args.file and not args.vault_root:
        parser.error("provide either a vault_root or --file")

    log_path = Path(args.log) if args.log else None

    # Collect files to process
    if args.file:
        norg_path = Path(args.file).expanduser().resolve()
        if not norg_path.exists():
            print(f"Error: file not found: {norg_path}", file=sys.stderr)
            sys.exit(1)
        vault_root = norg_path.parent  # best-effort; links may not resolve
        files = [norg_path]
    else:
        vault_root = Path(args.vault_root).expanduser().resolve()
        if not vault_root.is_dir():
            print(f"Error: not a directory: {vault_root}", file=sys.stderr)
            sys.exit(1)
        files = find_norg_files(vault_root)
        if not files:
            print(f"No .norg files found in {vault_root}", file=sys.stderr)
            sys.exit(0)

    results = []

    for norg_path in files:
        input_lines, output_lines, warnings = convert_file(norg_path, vault_root)

        result = {
            "file"     : str(norg_path),
            "warnings" : warnings,
            "success"  : True,
        }

        if args.dry_run and not args.quiet:
            print_diff(norg_path, input_lines, output_lines)

        if args.apply:
            out_path = md_path(norg_path)
            try:
                out_path.write_text("".join(output_lines), encoding="utf-8")
                if warnings:
                    print(f"  [warn] {norg_path}", file=sys.stderr)
                else:
                    print(f"  [ok]   {norg_path}", file=sys.stderr)
            except Exception as e:
                print(f"  [err]  {norg_path}: {e}", file=sys.stderr)
                result["success"] = False

            if args.delete_norg and result["success"]:
                try:
                    norg_path.unlink()
                except Exception as e:
                    print(f"  [err]  could not delete {norg_path}: {e}", file=sys.stderr)

        results.append(result)

    print_summary(results, args.dry_run, log_path)


if __name__ == "__main__":
    main()
