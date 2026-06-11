# Quickstart

Use this reference when creating a new GPUI project or adding the first GPUI window to an existing Rust project. These examples target crates.io `gpui = "0.2.2"`.

## Cargo.toml

```toml
[package]
name = "gpui-minimal-app"
version = "0.1.0"
edition = "2024"

[dependencies]
gpui = "0.2.2"
```

## Minimal App

```rust
use gpui::{
    App, Application, Bounds, Context, SharedString, Window, WindowBounds, WindowOptions, div,
    prelude::*, px, rgb, size,
};

struct HelloWorld {
    text: SharedString,
}

impl Render for HelloWorld {
    fn render(&mut self, _window: &mut Window, _cx: &mut Context<Self>) -> impl IntoElement {
        div()
            .flex()
            .flex_col()
            .gap_3()
            .size_full()
            .justify_center()
            .items_center()
            .bg(rgb(0x202020))
            .text_color(rgb(0xffffff))
            .text_xl()
            .child(format!("Hello, {}!", self.text))
    }
}

fn main() {
    Application::new().run(|cx: &mut App| {
        let bounds = Bounds::centered(None, size(px(500.0), px(500.0)), cx);
        cx.open_window(
            WindowOptions {
                window_bounds: Some(WindowBounds::Windowed(bounds)),
                ..Default::default()
            },
            |_, cx| {
                cx.new(|_| HelloWorld {
                    text: "World".into(),
                })
            },
        )
        .unwrap();
        cx.activate(true);
    });
}
```

## App Startup Pattern

- Create the application with `Application::new()`.
- Call `.run(|cx: &mut App| { ... })`.
- Open a window with `cx.open_window(WindowOptions { ... }, |window, cx| cx.new(...))`.
- Build the root view with `cx.new`.
- Call `cx.activate(true)` after opening the first visible window.

## Validation

Use the template in `assets/templates/minimal-app` for new projects:

```bash
bash /path/to/gpui/scripts/verify-template.sh /path/to/gpui/assets/templates/minimal-app
cargo check --manifest-path /path/to/gpui/assets/templates/minimal-app/Cargo.toml
```

## Source

This quickstart is adapted from the official `gpui-0.2.2/examples/hello_world.rs` file in the Cargo registry package.
