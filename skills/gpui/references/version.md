# Version

This skill targets the crates.io GPUI package, not Zed's unreleased main branch.

## Current Provenance

- Crate: `gpui`
- Version: `0.2.2`
- Registry cache source pattern: `${CARGO_HOME:-$HOME/.cargo}/registry/src/*/gpui-0.2.2`
- Registry crate archive pattern: `${CARGO_HOME:-$HOME/.cargo}/registry/cache/*/gpui-0.2.2.crate`
- Companion macro crate: `gpui-macros = 0.2.2`
- Upstream repository recorded by crate metadata: `https://github.com/zed-industries/zed`
- Crate homepage recorded by metadata: `https://gpui.rs`
- Updated: 2026-06-11
- Verified with: Cargo registry cache inspection and `cargo check --manifest-path /path/to/gpui/assets/templates/minimal-app/Cargo.toml`

## Adjacent Crates

Agents may also encounter these crates in user projects or Cargo caches:

- `gpui-component = 0.5.1`
- `gpui-component-assets = 0.5.1`
- `gpui-component-macros = 0.5.1`

Do not mix `gpui-component` patterns into this skill unless a task explicitly asks for that crate. This skill's references and templates should stay focused on the core `gpui` crate.

## Portable Cache Lookup

Use the bundled script from this skill's actual install directory:

```bash
bash /path/to/gpui/scripts/locate-gpui-cache.sh 0.2.2
```

The registry hash or mirror name is environment-specific and must not be hard-coded.

## Maintenance Rule

Update this file whenever examples, templates, or API signatures are refreshed from a different crates.io version. If a project pins another GPUI revision, prefer the project's revision for final code and treat these references as guidance only.
