# Mental Model

Use this reference before making structural GPUI changes.

## Core Types

- `Application`: startup wrapper. Construct it in `main`, configure optional assets/http client, then call `run`.
- `App`: root context passed to the `Application::run` callback. Use it to create entities, open windows, register actions, set menus, and access global application services.
- `Window`: mutable window-scoped handle passed to `Render::render` and window callbacks. Use it for window operations, prompts, focus/input plumbing, layout requests, and window-specific state.
- `Entity<T>`: GPUI-owned handle to mutable state. Views are entities whose `T` implements `Render`.
- `Context<T>`: entity-scoped context. Use it to notify observers, create listeners, spawn tasks, observe other entities, and access `App` methods.
- `Render`: trait that turns a view entity into an element tree each frame.
- `IntoElement`: trait returned by render methods and reusable element builders.

## Render Boundary

For a view:

```rust
impl Render for MyView {
    fn render(&mut self, window: &mut Window, cx: &mut Context<Self>) -> impl IntoElement {
        div().child("content")
    }
}
```

Keep persistent state on the view struct. Build transient UI with `div()` and chained element/style/event methods.

## Update Flow

- Mutate state through `&mut self` in render-adjacent listeners or through entity update callbacks.
- Call `cx.notify()` after changing state that should cause observers or rendering to update.
- Use `cx.listener(Self::method)` when wiring an element event or action to a method on the current entity.
- Use `Entity<T>` when state must outlive a single render call or be shared by multiple views.

## Async Contexts

Use `cx.to_async()` or spawn helpers when a future must outlive a borrowed `&mut Context<T>`. Async contexts are fallible because the app, window, or entity may be gone by the time the future resumes.

## Source

This model is based on `gpui-0.2.2/docs/contexts.md`, `src/element.rs`, `src/app.rs`, and the official examples in the Cargo registry package.
