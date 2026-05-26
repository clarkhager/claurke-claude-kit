# Section 9 addendum (will be merged into operating-manual.md)

This file is a temporary holder. The content below should be appended to operating-manual.md as section 9 in the next manual edit. Including separately to avoid re-pushing the full ~40KB manual file just for this addition.

---

## 9. Implementation gotchas (for kit maintainers)

When modifying the kit scripts (deploy.sh, new-project.sh, bootstrap.sh, install-humanizer.sh, etc.), watch for these patterns that have bitten the kit's own development before. Each entry: the pattern, why it fails, how to write it safely.

### Apostrophes inside `${VAR:-default}` bash expansions

Single quotes inside `${VAR:-default}` patterns open a string that bash never sees closed, even when the whole expression is wrapped in double quotes. The error surfaces much later in the script - usually as `syntax error near unexpected token "("` on a line that has nothing apparent wrong with it.

**Example that breaks:**

```bash
WHAT_THIS_IS="${WHAT_THIS_IS:-What's the core approach?}"
```

**Example that works** (rephrase without contractions):

```bash
WHAT_THIS_IS="${WHAT_THIS_IS:-What is the core approach?}"
```

**If you must include an apostrophe**, build the string in a separate line first:

```bash
DEFAULT_TEXT="What's the core approach?"
WHAT_THIS_IS="${WHAT_THIS_IS:-$DEFAULT_TEXT}"
```

The string is assigned in a fully-double-quoted context first, so the apostrophe is just a literal character. Then the `${VAR:-$DEFAULT_TEXT}` expansion uses the already-built variable.

**Caught:** May 2026, when the rewrite of new-project.sh shipped with `What's the core approach?` in the WHAT_THIS_IS default. Script crashed at line 207 (an `echo` with markdown link parens in `append_tracked_repos_section`) - 90+ lines after the actual offender. Took diagnosis via incremental `bash -n` to find that the real failure was line 120.

**Other characters to avoid inside `${VAR:-default}`:** backticks (command substitution), unescaped `$` (variable expansion), unbalanced parens, double quotes. Build the string in a separate variable first when you need any of these.

### Heredoc delimiter must be at column 0

When using `cat << EOF` heredocs, the closing `EOF` must be at column 0 (no leading whitespace) unless you use `<<- EOF` (which strips leading tabs only, not spaces). If the EOF is indented inside a function or conditional, bash keeps reading lines until end of file looking for a column-0 match. The error you see is usually `unexpected end of file` on the last line of the script, which is misleading.

**Example that breaks:**

```bash
my_function() {
  cat << EOF
some content
  EOF                # <- indented; bash doesn't recognize this as the terminator
}
```

**Example that works:**

```bash
my_function() {
  cat << EOF
some content
EOF                  # <- at column 0
}
```

IDEs that auto-indent shell scripts can sneak this bug in. Watch for it especially when copy-pasting heredocs into a function body.

### Unquoted vs quoted heredoc delimiter

`cat << EOF` (unquoted delimiter) expands variables (`$VAR`), command substitution (`` `cmd` `` or `$(cmd)`), and arithmetic (`$((expr))`) inside the heredoc content. To suppress all expansion and pass the content through literally, use `cat << 'EOF'` (single-quoted delimiter).

**Use unquoted when you WANT expansion:**

```bash
cat << EOF
Project is at $PROJECT_DIR.
Today is $(date).
EOF
```

**Use quoted when you DON'T want expansion** (e.g., embedded python code, raw markdown, anything with `$` that should be literal):

```bash
python3 << 'PYEOF'
import json, os
print(os.environ.get('HOME'))
PYEOF
```

The python heredocs in `deploy.sh` and `new-project.sh` use `'PYEOF'` for exactly this reason - python code references variables and shouldn't be subject to bash expansion.

### Test scripts with `bash -n` before pushing

For any non-trivial script change, run `bash -n script.sh` locally to catch syntax errors without executing. Doesn't catch runtime errors but catches the apostrophe/heredoc/quote bugs above before they ship.

For scripts that are too complex to syntax-check cleanly, write a smoke test that runs the script in a temp directory with default inputs and asserts on the output files. Worth the 15 minutes when the script is going to run on a half-dozen machines.

---

When this addendum gets merged into operating-manual.md as section 9, also update:
- The manual's intro line: `Eight sections` -> `Nine sections`
- The section list in the intro: add `implementation gotchas` at the end
- The "When in doubt" section at the very bottom (no change needed - it already says to check the manual first)
