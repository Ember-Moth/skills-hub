# Component Map

Use this file to choose the correct module before hand-building UI.

## App Shell and Overlays

- `Root`, `WindowExt`: top-level window wrapper, dialogs, sheets, notifications, focused input tracking.
- `dialog`: modal dialogs with title, footer, confirm/alert variants, close/ok/cancel handlers.
- `sheet`: side sheets with title, footer, size, resizable/overlay behavior.
- `popover`: anchored floating content with trigger/content builders and controlled/uncontrolled open state.
- `tooltip`: text or element tooltips, optional action/keybinding display.
- `notification`: transient info/success/warning/error messages.

## Controls and Forms

- `button`: `Button`, button variants, button groups, dropdown buttons, toggles.
- `input`: `Input`, `InputState`, `NumberInput`, `OtpInput`, search/code/multiline state modes.
- `checkbox`, `radio`, `switch`, `slider`, `select`: common choice controls.
- `form`, `label`, `description_list`, `group_box`, `setting`: form layout and settings surfaces.
- `color_picker`, `date_picker`, `calendar`: specialized value pickers.
- `clipboard`, `kbd`, `link`: copy-to-clipboard, keyboard shortcut display, and link-style actions.

## Navigation and Layout

- `menu`: app menu bar, context menu, dropdown menu, menu items, popup menu.
- `tab`: tabs and tab bars.
- `breadcrumb`, `sidebar`, `accordion`, `collapsible`, `resizable`, `divider`, `scroll`.
- `title_bar`: custom title bar and window controls where supported.
- `dock`: dock area, side docks, panels, split/tabs/tiles, persisted dock state.

## Data and Large Lists

- `list`: delegate-backed virtualized/selectable/searchable lists.
- `table`: delegate-backed table with columns, sorting, selection, resizing, moving, fixed columns, scroll.
- Re-exports: `VirtualList`, `VirtualListScrollHandle`, `v_virtual_list`, `h_virtual_list`, `IndexPath`.

## Content Display

- `text`: styled text, text view, markdown/simple HTML support through text view internals.
- `highlighter`: tree-sitter highlighter/editor integration.
- `chart`, `plot`: charts and plotting primitives.
- `avatar`, `badge`, `alert`, `tag`, `kbd`, `link`, `progress`, `spinner`, `skeleton`.

## Docs-Only or Version-Sensitive Names

The local upstream docs checkout may mention components such as `AlertDialog`, `Combobox`, `HoverCard`, `Image`, `Pagination`, `Rating`, `StatusBar`, `Stepper`, or `FocusTrap`. These names were not exported as public modules in crates.io `gpui-component 0.5.1` during this skill's verification. Do not use them against `0.5.1` without inspecting the target project's resolved source.

## Theme, Icons, and Styling

- `theme`: `Theme`, `ThemeColor`, `ThemeMode`, `ActiveTheme`, color helpers.
- `icon`: `Icon`, `IconName`, `IconNamed`.
- `styled`: `h_flex`, `v_flex`, `StyledExt`, `Size`, `Sizable`, `Selectable`, `Disableable`.
- `window_border`, `title_bar`: window chrome helpers.

## Optional Modules

- `webview`: enabled by `gpui-component = { version = "0.5.1", features = ["webview"] }`. Verify limitations before relying on it.
- `tree-sitter-languages`: enable when using bundled languages for syntax highlighting.
