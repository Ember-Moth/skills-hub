# API Cheatsheet

Use this reference for common GPUI types, traits, imports, and signatures. Entries target crates.io `gpui = "0.2.2"`.

For a fuller subsystem-oriented API manual, read `references/api-manual.md`. Use this file when the task only needs quick signatures.

## Imports

```rust
use gpui::{
    App, Application, Bounds, Context, SharedString, Window, WindowBounds, WindowOptions, div,
    prelude::*, px, rgb, size,
};
```

Add imports as needed: `Entity`, `FocusHandle`, `Focusable`, `KeyBinding`, `Menu`, `MenuItem`, `PromptLevel`, `Timer`, `actions`, `uniform_list`.

## Startup

```rust
Application::new().run(|cx: &mut App| {
    // launch
});
```

## Open Window

```rust
cx.open_window(WindowOptions::default(), |window, cx| cx.new(|cx| MyView {}))?;
```

Real signature:

```rust
pub fn open_window<V: 'static + Render>(
    &mut self,
    options: WindowOptions,
    build_root_view: impl FnOnce(&mut Window, &mut App) -> Entity<V>,
) -> anyhow::Result<WindowHandle<V>>;
```

## Render

```rust
pub trait Render: 'static + Sized {
    fn render(&mut self, window: &mut Window, cx: &mut Context<Self>) -> impl IntoElement;
}
```

## Entity Creation

```rust
let entity = cx.new(|cx| MyView {});
```

## Notify After Mutation

```rust
self.value += 1;
cx.notify();
```

## Actions

```rust
actions!(module_name, [ActionName]);
cx.on_action(|_: &ActionName, cx| cx.quit());
cx.bind_keys([KeyBinding::new("cmd-q", ActionName, None)]);
```

## Focusable

```rust
impl Focusable for MyView {
    fn focus_handle(&self, _: &App) -> FocusHandle {
        self.focus_handle.clone()
    }
}
```

## Rule

Only include signatures verified against the source version recorded in `version.md`.
