# Events And Actions

Use this reference for user input and command handling.

## Click Handlers

```rust
div()
    .cursor_pointer()
    .on_click(move |_event, window, cx| {
        // window: &mut Window
        // cx: &mut App
    })
```

For handlers that mutate the current entity, prefer `cx.listener(Self::method)`:

```rust
impl MyView {
    fn on_click(&mut self, _event: &gpui::ClickEvent, _window: &mut Window, cx: &mut Context<Self>) {
        cx.notify();
    }
}

impl Render for MyView {
    fn render(&mut self, _window: &mut Window, cx: &mut Context<Self>) -> impl IntoElement {
        div().on_click(cx.listener(Self::on_click))
    }
}
```

## Actions

Define actions with `actions!`:

```rust
actions!(window, [Quit]);
```

Register app-level actions:

```rust
cx.on_action(|_: &Quit, cx| cx.quit());
cx.bind_keys([KeyBinding::new("cmd-q", Quit, None)]);
```

Bind element-level actions:

```rust
div()
    .key_context("menu")
    .on_action(cx.listener(Self::move_up))
```

## Key Contexts

Use `.key_context("name")` on the element subtree that should receive matching key bindings. Action names in keymaps use the fully qualified Rust type name.

## Focus

For focusable entities:

```rust
struct MyInput {
    focus_handle: FocusHandle,
}

impl Focusable for MyInput {
    fn focus_handle(&self, _: &App) -> FocusHandle {
        self.focus_handle.clone()
    }
}
```

In render, track focus with `.track_focus(&self.focus_handle(cx))`.

## Rule

Keep UI event handlers small. Move domain mutations into entity methods when the surrounding project already follows that pattern.
