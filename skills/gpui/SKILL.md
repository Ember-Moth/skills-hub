---
name: gpui
description: Practical Rust GPUI app-building guidance. Use when Codex needs to create, modify, review, or debug Rust code that uses the gpui crate, including windows, views, Render implementations, elements, styling, layout, events, actions, focus, async tasks, app state, platform assumptions, or common GPUI compile errors. Prefer bundled tutorials, recipes, and templates before falling back to GPUI source lookup. For standard desktop widgets, forms, lists, tables, dialogs, menus, docks, and themed controls, use $gpui-components together with this skill instead of hand-building raw GPUI components.
---

# GPUI

Use this skill to write GPUI code from curated guidance, not by re-discovering the framework from scratch. The first version targets the crates.io `gpui = "0.2.2"` package. Treat source lookup as a fallback only when the bundled references do not cover the requested API or behavior.

This is a portable skill intended for different users, repositories, and agents. Do not assume a fixed checkout path, username, registry mirror, or Cargo cache location. Use the current project's dependency version first, and use `$CARGO_HOME` or `$HOME/.cargo` when locating cached crates.

## Workflow

1. Identify whether the task is a new app, feature work, bug fix, or review.
2. Read `references/version.md` to understand which GPUI source/version the guidance is meant to track.
3. Read `references/background.md` when the task involves GPUI capabilities, platform support, ecosystem status, or stale model assumptions.
4. If the task needs standard UI widgets, forms, overlays, lists, tables, menus, tabs, docks, icons, or themes, invoke `$gpui-components` and prefer its ready-made components before writing raw GPUI element trees.
5. Load only the reference files needed for the task:
   - `references/quickstart.md` for new app bootstrap and minimal runnable examples.
   - `references/background.md` for GPUI ecosystem status and platform support notes.
   - `references/mental-model.md` for App, Window, Entity, Context, Render, and element concepts.
   - `references/cookbook.md` for task-oriented recipes.
   - `references/styling.md` for layout, colors, typography, spacing, and state styling.
   - `references/events-actions.md` for clicks, keyboard input, actions, focus, menus, and subscriptions.
   - `references/async-state.md` for tasks, background work, state updates, and lifecycle.
   - `references/patterns.md` for component organization and idiomatic architecture.
   - `references/api-manual.md` for the API manual organized by subsystem.
   - `references/pitfalls.md` when compilation fails or GPUI behavior is surprising.
   - `references/api-cheatsheet.md` for common signatures and import hints.
6. Prefer existing project patterns over the templates when editing an established codebase.
7. For new projects, copy from `assets/templates/` only after selecting the closest template.
8. Run `cargo check` or the repository's existing validation command after edits when feasible.
9. If an API is not covered, inspect the local GPUI dependency or pinned source, then keep the final code aligned with the verified source.
10. When using crates.io `gpui`, prefer the cached registry package discovered by the bundled `scripts/locate-gpui-cache.sh` before browsing remote source.

## Templates

Use `assets/templates/minimal-app` for the smallest runnable GPUI application once the template is populated.
Use `assets/templates/panel-app` for apps with multiple panels or structured application state.
Use `assets/templates/async-list-app` for examples involving background loading and UI updates.

Validate populated templates with:

```bash
bash /path/to/gpui/scripts/verify-template.sh /path/to/gpui/assets/templates/minimal-app
```

Find the local crates.io registry copy with:

```bash
bash /path/to/gpui/scripts/locate-gpui-cache.sh
```

Generate a source-derived public API index with:

```bash
bash /path/to/gpui/scripts/list-public-api.sh
```

## Authoring Rules

Keep reference examples short, complete, and verified. Every API example added to this skill must come from one of:

- A local project that passed `cargo check`.
- GPUI or Zed source at the commit recorded in `references/version.md`.
- A small reproduction that was compiled before being copied into a reference.

Do not add guessed GPUI method names or signatures to the references.
