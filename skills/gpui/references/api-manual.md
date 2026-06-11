# API Manual

This manual is a practical guide to crates.io `gpui = "0.2.2"`. It is not a replacement for rustdoc, but it is intended to be enough for Codex to choose the right GPUI API without rereading the source for routine tasks.

Use `scripts/list-public-api.sh` when an exhaustive public declaration index is needed.

## Imports

Start most files with:

```rust
use gpui::{
    App, Application, Context, IntoElement, Render, Window, div, prelude::*,
};
```

Add focused imports as needed:

```rust
use gpui::{
    Bounds, Entity, FocusHandle, Focusable, KeyBinding, Menu, MenuItem, PromptLevel,
    SharedString, Timer, WindowBounds, WindowKind, WindowOptions, actions, px, rgb,
    size, uniform_list,
};
```

The prelude re-exports core traits: `AppContext`, `BorrowAppContext`, `Context`, `Element`, `InteractiveElement`, `IntoElement`, `ParentElement`, `Render`, `RenderOnce`, `StatefulInteractiveElement`, `Styled`, `StyledImage`, `VisualContext`, and `FluentBuilder`.

## Startup

`Application` is the pre-launch wrapper.

Common methods:

```rust
Application::new()
Application::headless()
Application::with_assets(asset_source)
Application::with_http_client(http_client)
Application::run(|cx: &mut App| { ... })
Application::on_open_urls(callback)
Application::on_reopen(callback)
```

Typical startup:

```rust
fn main() {
    Application::new().run(|cx: &mut App| {
        cx.open_window(WindowOptions::default(), |_, cx| cx.new(|_| RootView {}))
            .unwrap();
        cx.activate(true);
    });
}
```

Use `Application::headless()` for tests or non-window runtime code. Use `with_assets` before `run` when the app serves embedded assets.

## App

`App` is the root context. It owns entities, windows, globals, key bindings, menus, platform services, and task executors.

Common app lifecycle and window methods:

```rust
cx.open_window(options, |window, cx| cx.new(|cx| RootView {}))
cx.windows()
cx.window_stack()
cx.active_window()
cx.activate(true)
cx.hide()
cx.quit()
cx.restart()
cx.refresh_windows()
```

Entity methods are available through the `AppContext` trait:

```rust
let entity = cx.new(|cx| Model::new(cx));
cx.update_entity(&entity, |model, cx| { ... });
cx.read_entity(&entity, |model, app| { ... });
cx.reserve_entity::<T>();
cx.insert_entity(reservation, |cx| T { ... });
cx.background_spawn(async move { ... });
```

Globals:

```rust
cx.set_global(MyGlobal { ... });
cx.global::<MyGlobal>();
cx.try_global::<MyGlobal>();
cx.global_mut::<MyGlobal>();
cx.default_global::<MyGlobal>();
cx.observe_global::<MyGlobal>(|cx| { ... });
cx.remove_global::<MyGlobal>();
```

Platform services:

```rust
cx.write_to_clipboard(ClipboardItem::new_string(text));
cx.read_from_clipboard();
cx.open_url("https://example.com");
cx.prompt_for_paths(options);
cx.prompt_for_new_path(directory, suggested_name);
cx.reveal_path(path);
cx.open_with_system(path);
cx.displays();
cx.primary_display();
cx.window_appearance();
```

Keyboard and actions:

```rust
cx.bind_keys([KeyBinding::new("cmd-q", Quit, None)]);
cx.clear_key_bindings();
cx.on_action(|_: &Quit, cx| cx.quit());
cx.dispatch_action(&Quit);
cx.stop_propagation();
cx.propagate();
```

Menus:

```rust
cx.set_menus(vec![Menu { name, items }]);
cx.get_menus();
cx.set_dock_menu(items);
```

Async:

```rust
cx.spawn(async move |cx| { ... }).detach();
cx.to_async();
cx.defer(|cx| { ... });
```

## Context<T>

`Context<T>` is the entity-scoped context passed while constructing, updating, and rendering `T`. It dereferences into `App`, so most `App` methods are available through `cx`.

Identity:

```rust
cx.entity_id()
cx.entity()
cx.weak_entity()
```

Notify and observe:

```rust
cx.notify();
cx.observe(&other_entity, |this, other, cx| { ... });
cx.observe_self(|this, cx| { ... });
cx.observe_release(&other_entity, |this, other, cx| { ... });
cx.observe_global::<MyGlobal>(|this, cx| { ... });
```

Events:

```rust
impl EventEmitter<MyEvent> for Model {}

cx.subscribe(&model, |this, model, event, cx| { ... });
cx.subscribe_self(|this, event, cx| { ... });
cx.emit(MyEvent { ... });
```

Callbacks for element APIs:

```rust
div().on_click(cx.listener(Self::on_click))

fn on_click(&mut self, event: &ClickEvent, window: &mut Window, cx: &mut Context<Self>) {
    cx.notify();
}
```

Use `cx.processor` when a GPUI API expects a closure that returns data:

```rust
uniform_list("rows", count, cx.processor(|this, range, window, cx| {
    range.map(|ix| div().child(ix.to_string())).collect::<Vec<_>>()
}))
```

Async and lifecycle:

```rust
cx.spawn(async move |weak, cx| { ... }).detach();
cx.on_release(|this, cx| { ... });
cx.on_drop(|this, cx| { ... });
cx.on_next_frame(window, |this, window, cx| { ... });
cx.defer_in(window, |this, window, cx| { ... });
```

Focus helpers:

```rust
cx.focus_view(&view, window);
cx.focus_self(window);
cx.on_focus(&focus_handle, window, |this, window, cx| { ... });
cx.on_blur(&focus_handle, window, |this, window, cx| { ... });
```

## Render And Elements

Implement `Render` for persistent views:

```rust
impl Render for RootView {
    fn render(&mut self, window: &mut Window, cx: &mut Context<Self>) -> impl IntoElement {
        div().child("Hello")
    }
}
```

Use `RenderOnce` for lightweight component structs that render by value:

```rust
struct Label {
    text: SharedString,
}

impl RenderOnce for Label {
    fn render(self, _window: &mut Window, _cx: &mut App) -> impl IntoElement {
        div().child(self.text)
    }
}
```

Common element traits:

- `IntoElement`: convert a type into a renderable element.
- `ParentElement`: `.child(...)` and `.children(...)`.
- `Styled`: layout, color, typography, spacing, border, visibility.
- `InteractiveElement`: ids, focus, key contexts, events, tooltips, drag/drop.
- `StatefulInteractiveElement`: stateful interaction methods after `.id(...)`.

Prefer `div()` for most UI. Reach for custom `Element` only for low-level drawing, custom layout, text input internals, or performance-sensitive rendering.

## Div And Children

Create a generic container:

```rust
div()
    .id("root")
    .flex()
    .flex_col()
    .child("Title")
    .children(rows)
```

Useful `div` family:

```rust
div()
stateful_element.id(...)
```

Other exported element constructors include:

- `anchored()` for anchored overlays.
- `uniform_list(...)` for many same-height rows.
- `list(...)` for measured lists.
- `img(source)` for images.
- `svg()` for SVG assets.
- `canvas(...)` for custom painting.
- `deferred(child)` for delayed/deferred rendering.
- `surface(source)` for platform surfaces.
- `image_cache(provider)` and `retain_all(id)` for image caching.

## Styling

The `Styled` trait exposes Tailwind-like methods.

Display and flex:

```rust
.block()
.flex()
.grid()
.hidden()
.flex_col()
.flex_row()
.flex_wrap()
.flex_1()
.flex_none()
.items_center()
.justify_center()
.content_center()
```

Spacing and sizing are commonly used through helpers from the style macros:

```rust
.p_4()
.px_2()
.gap_3()
.w_full()
.h_full()
.size_full()
.size(px(500.0))
```

Text:

```rust
.text_color(rgb(0xffffff))
.text_size(px(14.0))
.text_xs()
.text_sm()
.text_base()
.text_lg()
.text_xl()
.text_2xl()
.font_weight(...)
.font_family(...)
.line_height(px(20.0))
.truncate()
.whitespace_nowrap()
```

Color and paint:

```rust
.bg(rgb(0x202020))
.opacity(0.8)
.border_dashed()
```

Interaction state styling:

```rust
.hover(|style| style.bg(rgb(0xeeeeee)))
.active(|style| style.opacity(0.85))
.focus(|style| style.border_color(gpui::blue()))
.in_focus(|style| style.bg(rgb(0xf0f6ff)))
.group("row")
.group_hover("row", |style| style.bg(rgb(0xeeeeee)))
```

Use raw `rgb(...)`/`hsla(...)` for examples, but prefer project-local design tokens in real apps.

## Geometry And Color

Common constructors:

```rust
px(12.0)
rems(1.0)
size(px(500.0), px(300.0))
point(px(10.0), px(20.0))
bounds(point(px(0.0), px(0.0)), size(px(100.0), px(100.0)))
rgb(0xffffff)
rgba(0xff000080)
hsla(0.0, 1.0, 0.5, 1.0)
```

Common types:

- `Pixels`, `ScaledPixels`, `DevicePixels`, `Rems`.
- `Point<T>`, `Size<T>`, `Bounds<T>`, `Edges<T>`, `Corners<T>`.
- `Length`, `DefiniteLength`, `AbsoluteLength`, `Percentage`.
- `Rgba`, `Hsla`, `Background`, `LinearColorStop`.

Window placement:

```rust
let bounds = Bounds::centered(None, size(px(500.0), px(500.0)), cx);
WindowBounds::Windowed(bounds)
WindowBounds::Maximized(bounds)
WindowBounds::Fullscreen(bounds)
```

## Window

`Window` is the window-scoped API available during render, callbacks, and window update closures.

Root and lifecycle:

```rust
window.replace_root(cx, |window, cx| NewRoot { ... });
window.root::<RootView>();
window.window_handle();
window.refresh();
window.remove_window();
```

Focus:

```rust
window.focus(&focus_handle);
window.blur();
window.focused(cx);
window.focus_next();
window.focus_prev();
window.disable_focus();
```

Geometry and platform state:

```rust
window.bounds()
window.resize(size(px(800.0), px(600.0)));
window.viewport_size()
window.window_bounds()
window.inner_window_bounds()
window.is_fullscreen()
window.is_maximized()
window.is_window_active()
window.is_window_hovered()
window.scale_factor()
window.rem_size()
window.set_rem_size(px(16.0))
window.line_height()
```

Window controls:

```rust
window.set_window_title("Title");
window.set_app_id("app.id");
window.activate_window();
window.minimize_window();
window.toggle_fullscreen();
window.zoom_window();
window.start_window_move();
window.start_window_resize(edge);
window.show_window_menu(position);
window.request_decorations(WindowDecorations::Client);
```

Async and drawing:

```rust
window.defer(cx, |window, cx| { ... });
window.on_next_frame(|window, cx| { ... });
window.request_animation_frame();
window.spawn(cx, async move |cx| { ... }).detach();
window.to_async(cx);
```

Prompts:

```rust
let answer = window.prompt(
    PromptLevel::Info,
    "Are you sure?",
    None,
    &["Ok", "Cancel"],
    cx,
);
```

Input and dispatch:

```rust
window.mouse_position()
window.modifiers()
window.prevent_default()
window.default_prevented()
window.dispatch_action(Box::new(action), cx)
window.dispatch_keystroke(keystroke, cx)
window.has_pending_keystrokes()
```

Use low-level paint/layout APIs only inside custom elements:

```rust
window.request_layout(style, children, cx)
window.layout_bounds(layout_id)
window.paint_quad(quad)
window.paint_path(path, color)
window.insert_hitbox(bounds, behavior)
```

## Window Handles

`open_window` returns `WindowHandle<V>`.

```rust
let handle = cx.open_window(options, |_, cx| cx.new(|_| RootView {}))?;
handle.update(cx, |root, window, cx| { ... })?;
handle.read(cx)?;
handle.read_with(cx, |root, cx| { ... })?;
handle.entity(cx)?;
handle.is_active(cx);
```

`AnyWindowHandle` erases the root view type:

```rust
let any = handle.into();
any.downcast::<RootView>();
any.update(cx, |root, window, cx| { ... })?;
any.read::<RootView, _, _>(cx, |root, cx| { ... })?;
```

## Focus

Implement `Focusable` when a view participates in focus:

```rust
struct SearchBox {
    focus_handle: FocusHandle,
}

impl Focusable for SearchBox {
    fn focus_handle(&self, _: &App) -> FocusHandle {
        self.focus_handle.clone()
    }
}
```

Construct handles with `cx.focus_handle()` or through project patterns. In render:

```rust
div()
    .track_focus(&self.focus_handle(cx))
    .focusable()
    .tab_stop(true)
```

Useful focus methods:

```rust
focus_handle.focus(window);
focus_handle.is_focused(window);
focus_handle.contains_focused(window, cx);
focus_handle.within_focused(window, cx);
focus_handle.downgrade();
```

## Events And Interactivity

Mouse and click:

```rust
div()
    .on_click(cx.listener(Self::on_click))
    .on_mouse_down(MouseButton::Left, cx.listener(Self::on_mouse_down))
    .on_mouse_up(MouseButton::Left, cx.listener(Self::on_mouse_up))
    .on_mouse_move(cx.listener(Self::on_mouse_move))
    .on_scroll_wheel(cx.listener(Self::on_scroll))
```

Keyboard:

```rust
div()
    .key_context("editor")
    .on_key_down(cx.listener(Self::on_key_down))
    .on_key_up(cx.listener(Self::on_key_up))
    .on_action(cx.listener(Self::on_action))
```

Common event types:

- `ClickEvent`, `MouseDownEvent`, `MouseUpEvent`, `MouseMoveEvent`, `ScrollWheelEvent`, `MouseExitEvent`.
- `KeyDownEvent`, `KeyUpEvent`, `ModifiersChangedEvent`, `KeystrokeEvent`.
- `FileDropEvent`, `ExternalPaths`, `DragMoveEvent<T>`.
- `MouseButton`, `KeyboardButton`, `CursorStyle`, `ScrollDelta`.

Drag/drop and tooltips:

```rust
.on_drag(...)
.on_drag_move(...)
.drag_over(...)
.on_drop(...)
.can_drop(...)
.tooltip(|window, cx| tooltip_view.into())
.hoverable_tooltip(...)
```

## Actions And Key Bindings

Define unit actions:

```rust
actions!(editor, [Save, Cancel]);
```

Define structured actions:

```rust
#[derive(serde::Deserialize, gpui::Action)]
struct MoveSelection {
    direction: Direction,
}
```

Bind keys:

```rust
cx.bind_keys([
    KeyBinding::new("cmd-s", Save, Some("editor")),
    KeyBinding::new("escape", Cancel, None),
]);
```

Handle globally:

```rust
cx.on_action(|_: &Save, cx| { ... });
```

Handle inside an element tree:

```rust
div()
    .key_context("editor")
    .on_action(cx.listener(Self::save))
```

Use `cx.stop_propagation()` when an action is consumed and should not bubble.

## Lists And Scrolling

Use `uniform_list` when items have uniform row height or can be virtualized simply:

```rust
uniform_list("entries", item_count, cx.processor(|this, range, window, cx| {
    range.map(|ix| div().id(ix).child(ix.to_string())).collect::<Vec<_>>()
}))
```

Useful list/scroll types:

- `UniformList`, `UniformListScrollHandle`, `ScrollStrategy`.
- `list(...)`, `List`, `ListState`, `ListAlignment`, `ListSizingBehavior`.
- `ScrollHandle`, `ScrollAnchor`.

Scroll state:

```rust
let scroll = ScrollHandle::new();
div().overflow_y_scroll().track_scroll(&scroll)
scroll.offset()
scroll.set_offset(point(px(0.0), px(100.0)))
scroll.scroll_to_bottom()
```

## Text And Input

Simple text can be rendered with strings or `StyledText`:

```rust
div().child("plain text")
StyledText::new("styled text")
```

For rich text/layout:

```rust
let text = StyledText::new("hello").with_runs(runs);
let interactive = InteractiveText::new("id", text)
    .on_click(|ranges, event, window, cx| { ... });
```

For editable text, implement `EntityInputHandler` and call `window.handle_input(...)` from a custom element. The official `examples/input.rs` is the reference pattern; do not invent a text input API.

Clipboard:

```rust
cx.write_to_clipboard(ClipboardItem::new_string(text));
let text = cx.read_from_clipboard().and_then(|item| item.text());
```

## Images, SVG, Assets

Asset source:

```rust
Application::new().with_assets(asset_source).run(...)
```

Images:

```rust
img(image_source)
image_cache(retain_all("images"))
RetainAllImageCache::new(cx)
```

SVG:

```rust
svg().path("icons/add.svg")
svg().with_transformation(Transformation::scale(size(2.0, 2.0)))
```

Core asset traits/types:

- `AssetSource`
- `Asset`
- `RenderImage`
- `ImageSource`
- `Image`, `ImageFormat`
- `ImageCache`, `ImageCacheProvider`, `RetainAllImageCache`

## Menus And Prompts

Menu setup:

```rust
actions!(app, [Quit]);

cx.on_action(|_: &Quit, cx| cx.quit());
cx.set_menus(vec![Menu {
    name: "App".into(),
    items: vec![MenuItem::action("Quit", Quit)],
}]);
```

Common menu types:

- `Menu`
- `MenuItem`
- `SystemMenuType`
- `OwnedMenu`

Prompt buttons:

```rust
PromptButton::ok("OK")
PromptButton::cancel("Cancel")
PromptButton::new("Custom")
```

Prompt levels include `PromptLevel`.

## Async And Tasks

Task type:

```rust
Task<T>
```

Spawn from app:

```rust
cx.spawn(async move |cx| {
    // cx is async app context
})
.detach();
```

Spawn from entity context:

```rust
cx.spawn(async move |weak, cx| {
    weak.update(cx, |this, cx| {
        this.loaded = true;
        cx.notify();
    })
    .ok();
})
.detach();
```

Spawn from window:

```rust
window.spawn(cx, async move |cx| {
    Timer::after(std::time::Duration::from_millis(250)).await;
    cx.update(|window, cx| { ... })
})
.detach();
```

Rules:

- Do not hold `&mut App`, `&mut Context<T>`, or `&mut Window` across `.await`.
- Hold or detach returned `Task`s.
- Prefer explicit UI state enums for loading/error/success.

## Custom Elements

Implement `Element` when `div` and helper components are insufficient.

Required associated types and methods:

```rust
impl Element for MyElement {
    type RequestLayoutState = ();
    type PrepaintState = ();

    fn id(&self) -> Option<ElementId> { ... }
    fn source_location(&self) -> Option<&'static core::panic::Location<'static>> { ... }
    fn request_layout(&mut self, id, inspector_id, window, cx) -> (LayoutId, Self::RequestLayoutState) { ... }
    fn prepaint(&mut self, id, inspector_id, bounds, request_layout, window, cx) -> Self::PrepaintState { ... }
    fn paint(&mut self, id, inspector_id, bounds, request_layout, prepaint, window, cx) { ... }
}
```

Use official examples for custom elements. `examples/input.rs` shows `IntoElement` + `Element` + custom painting + `window.handle_input`.

## Testing

Enable the `test-support` feature when writing GPUI tests.

Useful test exports:

- `#[gpui::test]`
- `TestAppContext`
- `run_test`
- `observe`
- `Observation<T>`

Prefer headless tests for state and action logic. Use visual/window tests only when the behavior depends on focus, key dispatch, or element rendering.

## Public API Index

For a source-derived index of public declarations:

```bash
bash /path/to/gpui/scripts/list-public-api.sh
```

Use the generated index when:

- A type or method is not covered by this manual.
- You need to distinguish core `gpui` APIs from `gpui-component` APIs.
- A compile error suggests a renamed or missing method.

If the project pins a different GPUI version, regenerate the index against that project's dependency source.
