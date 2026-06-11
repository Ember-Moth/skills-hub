# Usage Patterns

Use this file for common composition patterns.

## Imports

```rust
use gpui::*;
use gpui_component::{button::*, input::*, *};
```

Use module imports for component-specific extension traits or variants. Keep `gpui_component::*` for shared items such as `Root`, `WindowExt`, `IconName`, `Size`, `Sizable`, `ActiveTheme`, `h_flex`, and `v_flex`.

## State-Holding Components

Many controls are stateless `RenderOnce` elements that receive their state each render:

```rust
Checkbox::new("enabled")
    .label("Enabled")
    .checked(self.enabled)
    .on_click(cx.listener(|this, checked, _, cx| {
        this.enabled = *checked;
        cx.notify();
    }))
```

Text inputs, lists, tables, selects, docks, and overlays often use `Entity<State>` values. Create them in the parent view constructor with `cx.new(...)`, store the entity, and render the component from the entity.

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

Read or mutate value through the entity:

```rust
let value = self.name.read(cx).value();
self.name.update(cx, |state, cx| state.set_value("Alice", window, cx));
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

## Avoid Manual Reimplementation

Do not manually build standard behavior already provided by the component library:

- Use `Button` instead of a clickable `div` for normal commands.
- Use `InputState` + `Input` instead of custom text editors for form fields.
- Use `Dialog`/`Sheet`/`Popover` instead of ad hoc absolute overlays.
- Use `List`/`Table` for large or selectable collections.
- Use `IconName` + `gpui-component-assets` for standard icons.
