# Styling

Use this reference for GPUI layout and visual styling.

## Common Builder Pattern

```rust
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
    .child("Content")
```

## Frequently Used Methods

- Layout: `.flex()`, `.flex_col()`, `.flex_wrap()`, `.justify_center()`, `.items_center()`, `.content_center()`.
- Size: `.size_full()`, `.w_full()`, `.h_full()`, `.size(px(...))`, `.h(px(...))`.
- Spacing: `.p_4()`, `.p_8()`, `.px_2()`, `.gap_2()`, `.gap_3()`.
- Color: `.bg(rgb(0xffffff))`, `.text_color(rgb(...))`, `gpui::white()`, `gpui::black()`, `gpui::blue()`.
- Border: `.border_1()`, `.border_color(...)`, `.border_dashed()`, `.rounded_sm()`, `.rounded_md()`.
- Interaction: `.cursor_pointer()`, `.active(|this| this.opacity(0.85))`.
- Text: `.text_xl()`, `.text_size(px(24.))`, `.line_height(px(30.))`.

## Rule

Prefer GPUI-native style builders and project-local design helpers over ad hoc helper layers. When editing an existing app, reuse its color/type/spacing constants before adding raw `rgb(...)` values.
