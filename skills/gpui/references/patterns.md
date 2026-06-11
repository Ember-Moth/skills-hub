# Patterns

Use this reference for idiomatic GPUI architecture and code organization.

## Minimal App Structure

For small apps, keep the root view and `main` in one file until there is real complexity:

```text
src/
  main.rs
```

For larger apps:

```text
src/
  main.rs
  app.rs
  views/
    root.rs
    panel.rs
```

## View Structs

Use a view struct for state that directly affects rendering or input. Implement `Render` on it and create it with `cx.new`.

## Helper Components

Use functions returning `impl IntoElement` for simple reusable element patterns:

```rust
fn label(text: impl Into<String>) -> impl IntoElement {
    div().child(text.into())
}
```

Use `RenderOnce`/custom element types only when a plain helper becomes insufficient.

## Mutation

Keep state mutation close to the entity that owns the state. Use `cx.listener(Self::method)` to connect UI events to entity methods.

## Rule

Follow the host repository's established GPUI organization before applying a template from this skill.
