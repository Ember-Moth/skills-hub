# Source Fallback

Use this only when the bundled references do not cover a required API or when the target project pins a different version.

## Process

1. Identify the target project's actual versions from `Cargo.toml` and `Cargo.lock`.
2. Locate local sources with `scripts/locate-gpui-components-cache.sh`.
3. Search for the symbol definition before reading broad files.
4. Check an example, test, or real call site if behavior is unclear.
5. Use only verified method names/signatures in final code.

## Portable Cache Lookup

```bash
bash /path/to/gpui-components/scripts/locate-gpui-components-cache.sh
bash /path/to/gpui-components/scripts/locate-gpui-components-cache.sh 0.5.1
```

Do not hard-code registry hashes, mirrors, usernames, or absolute cache paths.

## Search Hints

```bash
rg "pub struct Button|trait ButtonVariants|pub fn new" <gpui-component-source-root>/src
rg "pub trait TableDelegate|pub struct TableState" <gpui-component-source-root>/src/table
rg "pub trait ListDelegate|pub struct ListState" <gpui-component-source-root>/src/list
rg "pub enum IconName|trait IconNamed" <gpui-component-source-root>/src/icon.rs
```

Generate a broad public API index:

```bash
bash /path/to/gpui-components/scripts/list-public-api.sh 0.5.1
```
