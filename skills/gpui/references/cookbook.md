# Cookbook

Use this reference for task-oriented GPUI recipes. These recipes target crates.io `gpui = "0.2.2"`.

## Create A Renderable View

Use this when the app needs a normal piece of persistent UI.

```rust
use gpui::{Context, IntoElement, Render, Window, div, prelude::*};

struct MyView;

impl Render for MyView {
    fn render(&mut self, _window: &mut Window, _cx: &mut Context<Self>) -> impl IntoElement {
        div().child("My view")
    }
}
```

Notes:
- Views are entities. Create them with `cx.new(|cx| MyView { ... })`.
- `Render::render` receives both `&mut Window` and `&mut Context<Self>`.

## Open The First Window

Use this in `main`.

```rust
Application::new().run(|cx: &mut App| {
    cx.open_window(WindowOptions::default(), |_, cx| cx.new(|_| MyView {}))
        .unwrap();
    cx.activate(true);
});
```

Prefer explicit `WindowOptions` when size, titlebar, resizability, or popup behavior matters.

## Create A Centered Window

Use this when a demo or tool should start at a stable size.

```rust
let bounds = Bounds::centered(None, size(px(500.0), px(500.0)), cx);
cx.open_window(
    WindowOptions {
        window_bounds: Some(WindowBounds::Windowed(bounds)),
        ..Default::default()
    },
    |_, cx| cx.new(|_| MyView {}),
)
.unwrap();
```

## Add A Clickable Button-Like Element

Use this for simple controls without introducing a custom element.

```rust
fn button(label: &str, on_click: impl Fn(&mut Window, &mut App) + 'static) -> impl IntoElement {
    div()
        .id(SharedString::from(label.to_string()))
        .px_2()
        .bg(rgb(0xf7f7f7))
        .active(|this| this.opacity(0.85))
        .border_1()
        .border_color(rgb(0xe0e0e0))
        .rounded_sm()
        .cursor_pointer()
        .child(label.to_string())
        .on_click(move |_, window, cx| on_click(window, cx))
}
```

Notes:
- Give interactive elements stable ids when needed.
- Keep the click closure small; delegate domain state changes to the relevant entity.

## Render A Uniform List

Use this for many similar rows.

```rust
div().size_full().child(
    uniform_list(
        "entries",
        50,
        cx.processor(|_this, range, _window, _cx| {
            range
                .map(|ix| {
                    let item = ix + 1;
                    div()
                        .id(ix)
                        .px_2()
                        .cursor_pointer()
                        .on_click(move |_event, _window, _cx| {
                            println!("clicked Item {item:?}");
                        })
                        .child(format!("Item {item}"))
                })
                .collect::<Vec<_>>()
        }),
    )
    .h_full(),
)
```

Source: `examples/uniform_list.rs`.

## Open A Secondary Window

Use this from a click handler or action.

```rust
cx.open_window(
    WindowOptions {
        window_bounds: Some(WindowBounds::Windowed(bounds)),
        ..Default::default()
    },
    |_, cx| cx.new(|_| SubWindow {}),
)
.unwrap();
```

For a popup, set `kind: WindowKind::PopUp`. For a custom titlebar, set `titlebar: None` and render your own top bar.

## Show A Prompt

Use `window.prompt` when a window-scoped confirmation is enough.

```rust
let answer = window.prompt(
    PromptLevel::Info,
    "Are you sure?",
    None,
    &["Ok", "Cancel"],
    cx,
);

cx.spawn(async move |_| {
    if answer.await.unwrap() == 0 {
        println!("accepted");
    }
})
.detach();
```

Source: `examples/window.rs`.

## Add An App Menu Action

Use this for app-level menu commands.

```rust
actions!(set_menus, [Quit]);

fn quit(_: &Quit, cx: &mut App) {
    cx.quit();
}

Application::new().run(|cx: &mut App| {
    cx.activate(true);
    cx.on_action(quit);
    cx.set_menus(vec![Menu {
        name: "set_menus".into(),
        items: vec![MenuItem::action("Quit", Quit)],
    }]);
    cx.open_window(WindowOptions::default(), |_, cx| cx.new(|_| MyView {}))
        .unwrap();
});
```

Source: `examples/set_menus.rs`.
