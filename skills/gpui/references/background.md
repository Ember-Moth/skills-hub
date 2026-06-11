# GPUI Background

Use this file when a task depends on GPUI project status, ecosystem context, or platform assumptions. Keep final code aligned with the target project's actual dependency version.

## Baseline

This skill targets the crates.io `gpui = "0.2.2"` crate. `cargo info gpui --registry crates-io` reports:

- Description: `Zed's GPU-accelerated UI framework`
- Version: `0.2.2`
- License: `Apache-2.0`
- Homepage: `https://gpui.rs`
- Documentation: `https://docs.rs/gpui/0.2.2`
- Repository: `https://github.com/zed-industries/zed`

GPUI is pre-1.0 and evolves quickly. Prefer the current project's `Cargo.lock`, `Cargo.toml`, or path dependency over this skill's baseline when they differ.

## Stale Assumptions to Avoid

- Do not assume GPUI is only usable inside Zed. The `gpui` crate is published on crates.io.
- Do not assume GPUI lacks Windows support. In `gpui 0.2.2`, the crate metadata and source include Windows-specific dependencies and `src/platform/windows` code guarded by `target_os = "windows"`.
- Do not assume old examples from unreleased Zed main compile with crates.io `0.2.2`. Verify signatures against the local crate version.
- Do not assume public website/docs are complete. Treat docs.rs, crate examples, local source, and compiled reproductions as the reliable sources.

## Platform Notes

The `gpui 0.2.2` crate has platform-specific code paths for macOS, Linux/FreeBSD, and Windows. Some APIs are platform-conditioned and some behavior depends on OS windowing systems, so use `cfg(...)` only after checking the crate source or the target project's existing patterns.

On Linux, system packages for graphics/windowing/text stacks may still be required by transitive dependencies. A source tree containing Windows support does not guarantee every example or optional feature works identically on every OS.

## Ecosystem Boundary

Use this core `$gpui` skill for:

- application startup and window lifecycle
- `Render`, `Context`, `Entity`, and state management
- raw element composition and styling
- event handling, actions, focus, subscriptions, and async work
- low-level custom elements or project-specific widgets

Use `$gpui-components` for:

- standard controls such as buttons, inputs, checkboxes, radios, switches, select, tabs, menus, popovers, dialogs, sheets, notifications, tables, lists, dock layouts, icons, themes, and built-in text/code/markdown surfaces
- app UIs that should look cohesive without manually recreating widget behavior

When both skills apply, build the shell with GPUI concepts and fill standard UI with GPUI Component widgets.
