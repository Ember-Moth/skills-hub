# API Cheatsheet

Use this for quick recall. Use `api-manual.md` for subsystem details.

## App Setup

```rust
use gpui::*;
use gpui_component::{button::*, *};
use gpui_component_assets::Assets;

let app = Application::new().with_assets(Assets);

app.run(|cx| {
    gpui_component::init(cx);
    cx.spawn(async move |cx| {
        cx.open_window(WindowOptions::default(), |window, cx| {
            let view = cx.new(|_| AppView);
            cx.new(|cx| Root::new(view, window, cx))
        })?;
        Ok::<_, anyhow::Error>(())
    }).detach();
});
```

## Shared Imports

```rust
use gpui::*;
use gpui_component::{button::*, input::*, *};
```

## Buttons

```rust
Button::new("id")
    .primary()
    .label("Save")
    .icon(IconName::Check)
    .tooltip("Save")
    .loading(false)
    .on_click(|event, window, cx| {});
```

Variants from `ButtonVariants`: `.primary()`, `.danger()`, `.warning()`, `.success()`, `.info()`, `.ghost()`, `.link()`, `.text()`, `.custom(...)`.

Shared size helpers from `Sizable`: `.xsmall()`, `.small()`, `.large()`, `.with_size(Size::Large)`.

## Inputs

```rust
let state = cx.new(|cx| {
    InputState::new(window, cx)
        .placeholder("Name")
        .default_value("")
});

Input::new(&state).cleanable(true)
```

Useful `InputState` builders: `.multi_line(bool)`, `.auto_grow(min, max)`, `.code_editor(language)`, `.searchable(bool)`, `.placeholder(...)`, `.line_number(bool)`, `.rows(...)`, `.masked(bool)`, `.clean_on_escape()`, `.soft_wrap(bool)`, `.pattern(regex)`, `.validate(...)`, `.default_value(...)`, `.mask_pattern(...)`.

Useful mutations: `set_value`, `insert`, `replace`, `set_placeholder`, `set_masked`, `set_loading`, `set_soft_wrap`, `set_cursor_position`, `focus`.

## Choice Controls

```rust
Checkbox::new("enabled")
    .label("Enabled")
    .checked(enabled)
    .on_click(|checked, window, cx| {});

Radio::new("mode-a")
    .label("Mode A")
    .checked(active)
    .on_click(|checked, window, cx| {});

Switch::new("online")
    .label("Online")
    .checked(online)
    .on_click(|checked, window, cx| {});
```

## Select

```rust
let state = cx.new(|cx| {
    SelectState::new(vec!["One", "Two"], None, window, cx)
        .searchable(true)
});

Select::new(&state)
    .placeholder("Choose")
    .search_placeholder("Search")
```

`String`, `SharedString`, and `&'static str` implement `SelectItem`.

## Dialogs and Notifications

```rust
window.open_dialog(cx, |dialog, _window, _cx| {
    dialog
        .confirm()
        .title("Continue?")
        .child("This action will update the project.")
        .on_ok(|_, window, cx| {
            window.push_notification(Notification::success("Updated"), cx);
            true
        })
});
```

`WindowExt` requires the window root to be `Root`.

## Lists

Implement `ListDelegate`, store `Entity<ListState<D>>`, render `List::new(&state)`.

Common state methods: `ListState::new(delegate, window, cx)`, `.searchable(bool)`, `.selectable(bool)`, `set_selected_index`, `selected_index`, `scroll_to_item`, `scroll_to_selected_item`, `delegate`, `delegate_mut`, `focus`.

## Tables

Implement `TableDelegate`, store `Entity<TableState<D>>`, render:

```rust
Table::new(&state)
    .stripe(true)
    .bordered(true)
    .scrollbar_visible(true, true)
```

Use `Column::new(key, name)` with `.sortable()`, `.ascending()`, `.descending()`, `.width(px(...))`, `.fixed_left()`, `.resizable(bool)`, `.movable(bool)`, `.selectable(bool)`.

## Icons and Assets

```rust
Icon::new(IconName::Search)
Button::new("search").icon(IconName::Search)
```

Use `Application::new().with_assets(gpui_component_assets::Assets)` for built-in icon SVGs.
