---
name: gpui-components
description: Practical Rust GPUI Component guidance. Use when Codex needs to create, modify, review, or debug GPUI desktop interfaces using the gpui-component package family, including reusable widgets, buttons, inputs, forms, dialogs, sheets, popovers, notifications, menus, tabs, lists, tables, dock layouts, icons, themes, charts, text/markdown views, or avoiding hand-written raw GPUI components. Use with $gpui for low-level GPUI window, entity, render, layout, event, async, and custom-element work.
---

# GPUI Components

Use this skill to build GPUI UIs with the `gpui-component` component library instead of recreating standard controls by hand. This skill covers the crates.io package family:

- `gpui-component = "0.5.1"` as `gpui_component`
- `gpui-component-assets = "0.5.1"` as `gpui_component_assets`
- `gpui-component-macros = "0.5.1"`
- `gpui = "0.2.2"` as the compatible core framework

This is a portable skill for different users, repositories, and agents. Do not assume a fixed checkout path, username, registry mirror, or Cargo cache location. Prefer the target project's pinned dependency version, then use `$CARGO_HOME` or `$HOME/.cargo` to locate cached crates.

## Workflow

1. Identify whether the task is a new GPUI app, UI feature, component replacement, bug fix, or review.
2. Read `references/version.md` to confirm the crate family, versions, features, and naming.
3. Use `$gpui` as a companion skill when the task involves GPUI startup, `Application`, windows, `Render`, entities, raw styling, events, actions, async work, or compile errors outside the component library.
4. Prefer component APIs before raw `div()` controls:
   - Use `references/component-map.md` to choose the module.
   - Use `references/api-manual.md` for signatures and subsystem guidance.
   - Use `references/quickstart.md` for a new runnable app shell.
5. Load only the references needed for the task:
   - `references/quickstart.md` for dependency setup, `gpui_component::init`, assets, and `Root`.
   - `references/component-map.md` for choosing components by UI need.
   - `references/usage-patterns.md` for stateful components, inputs, dialogs, notifications, and styling.
   - `references/api-manual.md` for a practical API manual organized by subsystem.
   - `references/api-cheatsheet.md` for common constructors and builder methods.
   - `references/assets.md` for `gpui-component-assets`, `IconName`, and custom icons.
   - `references/source-fallback.md` when an API is missing or version-specific.
6. For new apps, set up `Application::new().with_assets(gpui_component_assets::Assets)`, call `gpui_component::init(cx)`, and wrap the first window view with `Root::new(view, window, cx)`.
7. For established projects, follow existing patterns first and replace hand-built controls incrementally.
8. Run `cargo check` or the repository's existing validation command after edits when feasible.
9. If a method or trait is not covered, inspect the local dependency source with the bundled scripts before writing final code.

## Component-First Rules

Use library components for ordinary desktop UI:

- Commands: `Button`, button variants, icons, tooltips, loading states.
- Form fields: `Input`, `InputState`, `NumberInput`, `OtpInput`, `Checkbox`, `Radio`, `Switch`, `Select`, `Slider`.
- Overlays: `Dialog`, `Sheet`, `Popover`, `Tooltip`, `Notification`.
- Collections: `List`, `Table`, `VirtualList`, `IndexPath`.
- Shells: `DockArea`, `DockItem`, `Panel`, `TabBar`, menus, sidebars, breadcrumbs.
- Presentation: `Alert`, `Badge`, `Avatar`, `Label`, `TextView`, `Icon`, `Progress`, `Spinner`, `Skeleton`.

Only hand-build raw GPUI widgets when the component library does not provide the required behavior or the UI is intentionally custom.

## Scripts

Find local registry sources:

```bash
bash /path/to/gpui-components/scripts/locate-gpui-components-cache.sh
```

Generate a source-derived public API index:

```bash
bash /path/to/gpui-components/scripts/list-public-api.sh 0.5.1
```

## Authoring Rules

Keep examples short and verified against the crate versions in `references/version.md` or the target project's resolved dependency. Do not add guessed method names or signatures to this skill.
