# Version

This skill targets the crates.io GPUI Component package family.

## Current Provenance

- UI crate package: `gpui-component`
- UI crate library: `gpui_component`
- UI crate version: `0.5.1`
- Asset package: `gpui-component-assets = 0.5.1`
- Asset library: `gpui_component_assets`
- Macro package: `gpui-component-macros = 0.5.1`
- Core dependency: `gpui = 0.2.2`
- Registry cache pattern: `${CARGO_HOME:-$HOME/.cargo}/registry/src/*/gpui-component-0.5.1`
- Crate docs: `https://docs.rs/gpui-component`
- Homepage: `https://longbridge.github.io/gpui-component`
- Repository: `https://github.com/longbridge/gpui-component`
- License: `Apache-2.0`
- Updated: 2026-06-11
- Verified with: local Cargo registry cache inspection and `cargo info --registry crates-io`

The skill name is plural because it covers the package family. The actual dependency package names are singular: `gpui-component`, `gpui-component-assets`, and `gpui-component-macros`.

## Local Upstream Docs Checkout

Some environments may also have a Cargo git checkout of the upstream repository, for example:

```text
${CARGO_HOME:-$HOME/.cargo}/git/checkouts/gpui-component-*/<rev>/docs
```

The local checkout inspected for this skill was revision `87521042`, whose workspace declares `gpui-component = 0.5.2` and git-based GPUI dependencies. It is useful for design intent and examples, but this skill's executable API baseline remains crates.io `gpui-component = 0.5.1` with `gpui = 0.2.2`.

Use `references/docs-distilled.md` for distilled notes from that docs tree. Use `references/api-manual.md` and `scripts/list-public-api.sh` as the authority for `0.5.1` method names.

## Feature Flags

`gpui-component 0.5.1` exposes these notable features:

- `decimal`: enables `rust_decimal` support.
- `inspector`: enables GPUI/macros inspector integration and Wry devtools hooks.
- `tree-sitter-languages`: enables bundled tree-sitter grammars for the highlighter/editor paths.
- `webview`: enables the optional Wry-backed `webview` module. Treat it as early/experimental and verify project compatibility.

## Maintenance Rule

If a target project pins a different version, use that project's version for final code. Run `scripts/list-public-api.sh <version>` or inspect the project's path dependency before changing examples or signatures.
