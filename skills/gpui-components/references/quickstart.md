# Quickstart

Use this when starting a GPUI app that should use ready-made GPUI Component widgets.

## Dependencies

```toml
[dependencies]
anyhow = "1"
gpui = "0.2.2"
gpui-component = "0.5.1"
gpui-component-assets = "0.5.1"
```

`gpui-component-assets` is optional if the project provides its own SVG assets, but recommended for the default `IconName` set.

## Minimal Window

```rust
use gpui::*;
use gpui_component::{button::*, *};
use gpui_component_assets::Assets;

pub struct AppView;

impl Render for AppView {
    fn render(&mut self, _window: &mut Window, _cx: &mut Context<Self>) -> impl IntoElement {
        v_flex()
            .size_full()
            .items_center()
            .justify_center()
            .gap_2()
            .child("Hello, GPUI Component")
            .child(
                Button::new("continue")
                    .primary()
                    .label("Continue")
                    .icon(IconName::ArrowRight)
                    .on_click(|_, _, _| println!("clicked")),
            )
    }
}

fn main() {
    let app = Application::new().with_assets(Assets);

    app.run(|cx| {
        gpui_component::init(cx);

        cx.spawn(async move |cx| {
            cx.open_window(WindowOptions::default(), |window, cx| {
                let view = cx.new(|_| AppView);
                cx.new(|cx| Root::new(view, window, cx))
            })?;

            Ok::<_, anyhow::Error>(())
        })
        .detach();
    });
}
```

## Required Setup Rules

- Call `Application::new().with_assets(gpui_component_assets::Assets)` when using default `IconName` SVGs.
- Call `gpui_component::init(cx)` inside `app.run` before rendering components.
- Make the first view opened in a window a `Root::new(view, window, cx)`. `Root` manages dialogs, sheets, notifications, input focus integration, and related overlays.
- Import component modules explicitly when useful, for example `use gpui_component::{button::*, input::*, *};`.

## Component-First Policy

Before writing raw GPUI controls with `div()`, check `component-map.md` and `api-manual.md`. Prefer:

- `Button`, `Checkbox`, `Radio`, `Switch`, `Input`, `NumberInput`, `OtpInput`, `Select`
- `Dialog`, `Sheet`, `Popover`, `Tooltip`, `Notification`
- `List`, `Table`, `DockArea`, `DockItem`, `Tabs`, `Menu`
- `Icon`, `Label`, `Text`, `Alert`, `Badge`, `Avatar`, `Progress`, `Spinner`, `Skeleton`

Use raw GPUI only for layout glue, highly custom visuals, or behavior missing from the component library.
