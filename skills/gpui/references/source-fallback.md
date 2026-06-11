# Source Fallback

Use this reference only when the tutorial references do not cover a required GPUI API.

## Fallback Process

1. Identify the GPUI version used by the target project.
2. For crates.io `gpui = "0.2.2"`, start with `${CARGO_HOME:-$HOME/.cargo}/registry/src/*/gpui-0.2.2`.
3. Prefer the project's local path dependency or lockfile-resolved source when it differs from `0.2.2`.
4. Search for the symbol definition before reading broad files.
5. Find at least one real call site or test when behavior is unclear.
6. Use the verified API in the task, then consider adding the pattern to `cookbook.md` or `api-cheatsheet.md`.

## Search Hints

Prefer `rg` for source lookup:

```bash
rg "trait Render|struct App|fn new_window|impl .*Render" <gpui-source-root>
```

Find cached GPUI packages with:

```bash
bash /path/to/gpui/scripts/locate-gpui-cache.sh 0.2.2
```
