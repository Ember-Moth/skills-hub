# Async State

Use this reference for background work, tasks, and UI updates.

## Spawn From App Or Context

`App`, `Context<T>`, and `Window` expose spawn helpers in `gpui-0.2.2`. Use them instead of holding borrowed contexts across `.await`.

```rust
cx.spawn(async move |_| {
    // async work
})
.detach();
```

Window-scoped work can be spawned from a window:

```rust
window
    .spawn(cx, async move |cx| {
        Timer::after(std::time::Duration::from_secs(3)).await;
        cx.update(|_, cx| {
            cx.activate(false);
        })
    })
    .detach();
```

Source: `examples/window.rs`.

## State Shape

Prefer explicit state enums when async UI has multiple states:

```rust
enum LoadState<T> {
    Idle,
    Loading,
    Loaded(T),
    Failed(String),
}
```

Call `cx.notify()` after storing completed data on an entity.

## Rule

Do not capture `&mut Context<T>`, `&mut App`, or `&mut Window` across `.await`. Convert to an async context or use the spawn closure's async context parameter.
