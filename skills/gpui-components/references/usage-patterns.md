# Usage Patterns

Use this file for common composition patterns.

**Contents:** [Imports](#imports) · [Setup](#setup) · [Component Types](#component-types) · [Common Components](#common-components) · [Input Pattern](#input-pattern) · [Dialog and Notification Pattern](#dialog-and-notification-pattern) · [Theming](#theming) · [Layout Helpers](#layout-helpers) · [Overlay Layers](#overlay-layers-dialogs-sheets-notifications) · [Component Styling](#component-styling) · [Avoid Manual Reimplementation](#avoid-manual-reimplementation)

## Imports

```rust
use gpui::*;
use gpui_component::{button::*, input::*, *};
```

Use module imports for component-specific extension traits or variants. Keep `gpui_component::*` for shared items such as `Root`, `WindowExt`, `IconName`, `Size`, `Sizable`, `ActiveTheme`, `h_flex`, and `v_flex`.

## Setup

### Cargo.toml

```toml
[dependencies]
gpui = { git = "https://github.com/zed-industries/zed" }
gpui_platform = { git = "https://github.com/zed-industries/zed", features = ["font-kit"] }
gpui-component = { git = "https://github.com/longbridge/gpui-component" }
gpui-component-assets = { git = "https://github.com/longbridge/gpui-component" } # optional icons
```

### Initialization

```rust
fn main() {
    gpui_platform::application()
        .with_assets(gpui_component_assets::Assets)
        .run(move |cx| {
            gpui_component::init(cx); // MUST be first

            cx.spawn(async move |cx| {
                cx.open_window(WindowOptions::default(), |window, cx| {
                    let view = cx.new(|_| MyApp);
                    cx.new(|cx| Root::new(view, window, cx)) // Root wraps first view
                }).expect("Failed to open window");
            }).detach();
        });
}
```

**`Root` is required** as the first-level child of every window — it enables dialogs, sheets, and notifications.

## Component Types

### Stateless (most components)

Used directly in `render`, no stored state:

```rust
use gpui_component::button::Button;

impl Render for MyView {
    fn render(&mut self, _: &mut Window, _: &mut Context<Self>) -> impl IntoElement {
        Button::new("btn").primary().label("Submit")
            .on_click(|_, _, _| println!("clicked"))
    }
}
```

### Stateful (Input, Select, Combobox, etc.)

Many controls require an `Entity<State>` stored in your view. Create them in the parent view constructor with `cx.new(...)`, store the entity, and render the component from the entity.

```rust
use gpui_component::input::{Input, InputState};

struct MyView {
    name: Entity<InputState>,
}

impl MyView {
    fn new(window: &mut Window, cx: &mut Context<Self>) -> Self {
        Self {
            name: cx.new(|cx| InputState::new(window, cx).placeholder("Your name")),
        }
    }
}

impl Render for MyView {
    fn render(&mut self, _: &mut Window, cx: &mut Context<Self>) -> impl IntoElement {
        Input::new(&self.name)
    }
}
```

### Stateless controlled (Checkbox, Switch, Radio)

Some stateless controls are "controlled" — they receive their state each render:

```rust
Checkbox::new("enabled")
    .label("Enabled")
    .checked(self.enabled)
    .on_click(cx.listener(|this, checked, _, cx| {
        this.enabled = *checked;
        cx.notify();
    }))
```

Text inputs, lists, tables, selects, docks, and overlays often use `Entity<State>` values.

## Common Components

### Button

```rust
use gpui_component::button::{Button, ButtonGroup};

// Variants
Button::new("btn").label("Default")
Button::new("btn").primary().label("Primary")
Button::new("btn").danger().label("Delete")
Button::new("btn").warning().label("Warning")
Button::new("btn").success().label("Success")
Button::new("btn").ghost().label("Ghost")
Button::new("btn").link().label("Link")

// States
Button::new("btn").label("Text").disabled(true)
Button::new("btn").label("Text").loading(true)
Button::new("btn").label("Text").selected(true)

// With icon
Button::new("btn").icon(IconName::Plus).label("Add")

// Sizes
Button::new("btn").xsmall().label("XS")
Button::new("btn").small().label("S")
Button::new("btn").large().label("L")

// Group
ButtonGroup::new("group")
    .child(Button::new("a").label("A"))
    .child(Button::new("b").label("B"))
    .on_click(|indices, _, _| { /* selected indices */ })
```

### Select

```rust
use gpui_component::select::{Select, SelectState};

// Simple string list
let state = cx.new(|cx| {
    SelectState::new(vec!["Apple", "Orange", "Banana"], Some(IndexPath::default()), window, cx)
});

// Render
Select::new(&state)
Select::new(&state).placeholder("Pick one")

// Reading selection
let selected = state.read(cx).selected_item();
```

### Icon

```rust
use gpui_component::{Icon, IconName};

Icon::new(IconName::Check)
Icon::new(IconName::Search).small()
Icon::new(IconName::Plus).large().text_color(cx.theme().primary)
```

### Tabs

```rust
use gpui_component::tab::{Tab, TabBar};

TabBar::new("tabs")
    .child(Tab::new("tab1").child("Overview"))
    .child(Tab::new("tab2").child("Settings"))
    .child(Tab::new("tab3").child("Logs"))
```

### Tooltip

```rust
// On any element with .id(), add .tooltip():
div()
    .id("my-btn")
    .tooltip(|window, cx| Tooltip::new("Delete item").build(window, cx))
    .child("Delete")

// Or on a Button directly:
Button::new("btn").icon(IconName::Trash).tooltip("Delete")
```

### Form

```rust
use gpui_component::form::{v_form, h_form, field};

// Vertical form
v_form()
    .child(field().label("Name").child(Input::new(&self.name)))
    .child(field().label("Email").child(Input::new(&self.email)))
    .child(Button::new("submit").primary().label("Submit"))

// Horizontal label alignment
h_form()
    .child(field().label("Username").child(Input::new(&self.username)))
```

### List (searchable, virtualized)

```rust
use gpui_component::list::{List, ListState, ListDelegate, ListItem, ListEvent};

// Implement ListDelegate for your data type, then:
let list_state = cx.new(|cx| ListState::new(MyDelegate::new(), window, cx));

// Render
List::new(&list_state)
// Events
cx.subscribe(&list_state, |this, _, event, cx| {
    if let ListEvent::Select(index_path) = event {
        // handle selection
    }
});
```

## Input Pattern

```rust
use gpui_component::input::*;

pub struct FormView {
    name: Entity<InputState>,
}

impl FormView {
    pub fn new(window: &mut Window, cx: &mut Context<Self>) -> Self {
        Self {
            name: cx.new(|cx| {
                InputState::new(window, cx)
                    .placeholder("Name")
                    .default_value("")
            }),
        }
    }
}

impl Render for FormView {
    fn render(&mut self, _window: &mut Window, _cx: &mut Context<Self>) -> impl IntoElement {
        v_flex()
            .gap_2()
            .child(Label::new("Name"))
            .child(Input::new(&self.name).cleanable(true))
    }
}
```

### Render options

```rust
Input::new(&input)
Input::new(&input).cleanable(true)           // clear button
Input::new(&input).disabled(true)
Input::new(&input).prefix(Icon::new(IconName::Search).small())
Input::new(&input).suffix(Button::new("b").ghost().icon(IconName::X).xsmall())
Input::new(&input).mask_toggle()             // password reveal toggle
Input::new(&input).appearance(false)         // remove default border/bg
```

### Reading and mutating value

```rust
let value = self.name.read(cx).value();
self.name.update(cx, |state, cx| state.set_value("Alice", window, cx));
```

### Events

```rust
cx.subscribe_in(&input, window, |view, state, event, window, cx| {
    match event {
        InputEvent::Change => { let v = state.read(cx).value(); }
        InputEvent::PressEnter { .. } => { /* submit */ }
        InputEvent::Focus | InputEvent::Blur => {}
    }
});
```

## Dialog and Notification Pattern

`WindowExt` methods require the window root to be `Root`.

```rust
Button::new("delete")
    .danger()
    .label("Delete")
    .on_click(|_, window, cx| {
        window.open_dialog(cx, |dialog, _window, _cx| {
            dialog
                .confirm()
                .title("Delete item?")
                .child("This action cannot be undone.")
                .on_ok(|_, window, cx| {
                    window.push_notification(Notification::success("Deleted"), cx);
                    true
                })
        });
    })
```

### Modal variant

```rust
window.open_modal(cx, |modal, _, cx| {
    modal
        .title("Confirm")
        .child(div().child("Are you sure?"))
        .footer(|this, _, cx| {
            this.child(Button::new("cancel").label("Cancel"))
                .child(Button::new("ok").primary().label("OK")
                    .on_click(|_, window, cx| { window.close_modal(cx); }))
        })
});
```

### Notifications

```rust
// Simple string message
window.push_notification("Saved successfully!", cx);

// With type variant
window.push_notification(
    Notification::new("Upload complete").info().message("File uploaded"),
    cx,
);
```

## Theming

```rust
use gpui_component::ActiveTheme as _;

// Access colors
cx.theme().primary
cx.theme().background
cx.theme().foreground
cx.theme().border
cx.theme().surface
cx.theme().muted
cx.theme().destructive

// Use in styles
div()
    .bg(cx.theme().surface)
    .text_color(cx.theme().foreground)
    .border_color(cx.theme().border)
```

### Switch Theme

```rust
use gpui_component::Theme;

// Toggle light/dark
cx.update_global::<Theme, _>(|theme, cx| {
    theme.toggle_mode(cx);
});

// Load a named theme
Theme::global_mut(cx).apply_config(&theme_config);
```

## Layout Helpers

gpui-component extends GPUI with convenient layout methods:

```rust
h_flex()    // div().flex().flex_row().items_center()
v_flex()    // div().flex().flex_col()

// Common patterns
h_flex().gap_2().items_center()
    .child(Icon::new(IconName::User))
    .child(label("Username"))

v_flex().gap_4().p_4()
    .child(Input::new(&self.name))
    .child(Input::new(&self.email))
    .child(Button::new("submit").primary().label("Submit"))
```

## Overlay Layers (Dialogs, Sheets, Notifications)

To render overlays, add these to your first-level view's render:

```rust
impl Render for MyApp {
    fn render(&mut self, window: &mut Window, cx: &mut Context<Self>) -> impl IntoElement {
        div()
            .size_full()
            .child(self.main_content(window, cx))
            .children(Root::render_dialog_layer(cx))
            .children(Root::render_sheet_layer(cx))
            .children(Root::render_notification_layer(cx))
    }
}
```

## Component Styling

Components implement GPUI `Styled` where appropriate, so normal GPUI style methods and `StyledExt` helpers can be chained:

```rust
Button::new("save")
    .primary()
    .small()
    .label("Save")
    .w(px(120.))
```

For size-aware components, use `Sizable` helpers: `.xsmall()`, `.small()`, `.large()`, or `.with_size(Size::Large)`.

### Shared Traits

All components follow the builder pattern `Component::new("id").method().method()`:
- `Sizable`: `.xsmall()` / `.small()` / `.medium()` (default) / `.large()`
- `Disableable`: `.disabled(bool)`
- `Selectable`: `.selected(bool)`
- `Styled`: any GPUI style methods (`.w()`, `.bg()`, `.p_2()`, etc.)

For any component not covered here, fetch its doc from:
`https://longbridge.github.io/gpui-component/docs/components/{name}.md`

## Avoid Manual Reimplementation

Do not manually build standard behavior already provided by the component library:

- Use `Button` instead of a clickable `div` for normal commands.
- Use `InputState` + `Input` instead of custom text editors for form fields.
- Use `Dialog`/`Sheet`/`Popover` instead of ad hoc absolute overlays.
- Use `List`/`Table` for large or selectable collections.
- Use `IconName` + `gpui-component-assets` for standard icons.
