# API Manual

This is a practical API manual for `gpui-component = "0.5.1"` with `gpui = "0.2.2"`. It is not a replacement for source lookup when a target project pins another version.

## Table of Contents

- App setup and root
- Styling, size, themes, icons
- Buttons and basic controls
- Inputs
- Select
- Dialogs, sheets, popovers, tooltips, notifications
- Lists
- Tables
- Tabs, menus, and navigation
- Dock layouts and panels
- Text, markdown, alerts, badges, and presentation
- Optional features

## App Setup and Root

Add dependencies:

```toml
gpui = "0.2.2"
gpui-component = "0.5.1"
gpui-component-assets = "0.5.1"
```

Initialize components in `app.run`:

```rust
gpui_component::init(cx);
```

Use default icon assets:

```rust
let app = Application::new().with_assets(gpui_component_assets::Assets);
```

Wrap the first window view in `Root`:

```rust
cx.open_window(WindowOptions::default(), |window, cx| {
    let view = cx.new(|_| AppView);
    cx.new(|cx| Root::new(view, window, cx))
})?;
```

`Root` is required for `WindowExt` overlay helpers:

- `open_sheet`, `open_sheet_at`, `has_active_sheet`, `close_sheet`
- `open_dialog`, `has_active_dialog`, `close_dialog`, `close_all_dialogs`
- `push_notification`, `remove_notification`, `clear_notifications`, `notifications`
- `focused_input`, `has_focused_input`

## Styling, Size, Themes, Icons

Common re-exports:

- `h_flex()`, `v_flex()`: flex row/column helpers returning GPUI `Div`.
- `StyledExt`: extra style helpers such as focus rings, popover styles, shadows, and radius helpers.
- `Size`: `XSmall`, `Small`, `Medium`, `Large`, `Size(Pixels)`.
- `Sizable`: `.xsmall()`, `.small()`, `.large()`, `.with_size(...)`.
- `Selectable`: `.selected(bool)`.
- `Disableable`: `.disabled(bool)`.

Theme access:

```rust
let color = cx.theme().primary;
```

`ActiveTheme` is implemented for `App`. `Theme::change(mode, window, cx)` changes theme mode. `ThemeMode` includes light/dark/system-derived modes in the source; verify exact variants before matching exhaustively.

Icons:

```rust
Icon::new(IconName::Search)
IconName::Search.view(cx)
Button::new("search").icon(IconName::Search)
```

`IconName` variants in `0.5.1` include action, status, panel, file, user, theme, and window-control icons. Use `assets.md` or `src/icon.rs` for the full enum.

## Buttons and Basic Controls

### Button

Constructor:

```rust
Button::new(id)
```

Important builders:

- `.label(text)`
- `.icon(icon)`
- `.tooltip(text)`
- `.tooltip_with_action(text, action, context)`
- `.outline()`
- `.rounded(ButtonRounded | Pixels)`
- `.loading(bool)`
- `.loading_icon(icon)`
- `.compact()`
- `.dropdown_caret(bool)`
- `.tab_index(isize)`
- `.tab_stop(bool)`
- `.on_click(|&ClickEvent, &mut Window, &mut App| ...)`
- `.on_hover(|&bool, &mut Window, &mut App| ...)`

Variants from `ButtonVariants`:

- `.primary()`
- `.danger()`
- `.warning()`
- `.success()`
- `.info()`
- `.ghost()`
- `.link()`
- `.text()`
- `.custom(ButtonCustomVariant)`

`ButtonVariant::Secondary` is the default. There is no `.secondary()` helper in `0.5.1`; omit a variant for secondary style.

### Checkbox

```rust
Checkbox::new("accept")
    .label("Accept")
    .checked(self.accepted)
    .on_click(cx.listener(|this, checked, _window, cx| {
        this.accepted = *checked;
        cx.notify();
    }))
```

Builders: `.label(...)`, `.checked(bool)`, `.disabled(bool)`, `.tab_stop(bool)`, `.tab_index(isize)`, `.on_click(...)`, size helpers.

### Radio

`Radio` is a single radio control. Manage grouping in parent state.

```rust
Radio::new("mode-basic")
    .label("Basic")
    .checked(self.mode == Mode::Basic)
    .on_click(cx.listener(|this, checked, _window, cx| {
        if *checked {
            this.mode = Mode::Basic;
            cx.notify();
        }
    }))
```

Builders: `.label(...)`, `.checked(bool)`, `.disabled(bool)`, `.tab_index(isize)`, `.tab_stop(bool)`, `.on_click(...)`, size helpers.

### Switch

```rust
Switch::new("enabled")
    .label("Enabled")
    .checked(self.enabled)
    .tooltip("Toggle feature")
    .on_click(cx.listener(|this, checked, _window, cx| {
        this.enabled = *checked;
        cx.notify();
    }))
```

Builders: `.checked(bool)`, `.label(...)`, `.tooltip(...)`, `.disabled(bool)`, `.on_click(...)`, size helpers.

## Inputs

Use `InputState` for state and `Input` for rendering.

```rust
use gpui_component::input::*;

pub struct FormView {
    name: Entity<InputState>,
}

impl FormView {
    pub fn new(window: &mut Window, cx: &mut Context<Self>) -> Self {
        Self {
            name: cx.new(|cx| {
                InputState::new(window, cx)
                    .placeholder("Name")
                    .default_value("")
            }),
        }
    }
}
```

Render:

```rust
Input::new(&self.name)
    .cleanable(true)
    .prefix(IconName::User)
```

`Input` builders:

- `.prefix(element)`, `.suffix(element)`
- `.h_full()`, `.h(length)`
- `.appearance(bool)`
- `.bordered(bool)`
- `.focus_bordered(bool)`
- `.cleanable(bool)`
- `.mask_toggle()`
- `.disabled(bool)`
- `.tab_index(isize)`
- size helpers

`InputState` builders:

- `InputState::new(window, cx)`
- `.multi_line(bool)`
- `.auto_grow(min_rows, max_rows)`
- `.code_editor(language)`
- `.searchable(bool)`
- `.placeholder(text)`
- `.line_number(bool)`
- `.rows(usize)`
- `.masked(bool)`
- `.clean_on_escape()`
- `.soft_wrap(bool)`
- `.pattern(regex::Regex)`
- `.validate(|&str, &mut Context<Self>| bool)`
- `.default_value(text)`
- `.mask_pattern(pattern)`

`InputState` mutations/accessors:

- `set_placeholder`, `set_value`, `insert`, `replace`
- `set_line_number`, `set_highlighter`, `set_masked`, `set_loading`, `set_soft_wrap`, `set_pattern`, `set_mask_pattern`
- `value()`, `unmask_value()`, `text()`, `cursor_position()`, `set_cursor_position(...)`
- `focus(window, cx)`

`NumberInput::new(&input_state)` provides numeric step behavior and accepts `.placeholder(...)`, `.prefix(...)`, `.suffix(...)`, `.appearance(bool)`.

`OtpState::new(length, window, cx)` and `OtpInput::new(&state)` provide one-time-password input. `OtpInput` supports `.groups(n)`.

## Select

`String`, `SharedString`, and `&'static str` implement `SelectItem`, so a simple select can use a `Vec`.

```rust
let state = cx.new(|cx| {
    SelectState::new(vec!["Small", "Medium", "Large"], None, window, cx)
        .searchable(true)
});
```

Render:

```rust
Select::new(&self.size_select)
    .placeholder("Size")
    .search_placeholder("Search sizes")
    .cleanable(true)
```

`SelectItem` requirements:

- associated `Value: Clone`
- `title() -> SharedString`
- `value() -> &Self::Value`
- optional `display_title()`, `render(window, cx)`, `matches(query)`

`SelectDelegate` requirements:

- associated `Item: SelectItem`
- `items_count(section) -> usize`
- `item(IndexPath) -> Option<&Item>`
- `position(value) -> Option<IndexPath>`
- optional `sections_count`, `section`, `perform_search`

`SelectState` useful methods:

- `SelectState::new(delegate, selected, window, cx)`
- `.searchable(bool)`
- `set_selected_index`, `set_selected_value`, `set_items`
- `selected_index(cx)`, `selected_value()`, `focus(window, cx)`

`Select` builders:

- `.menu_width(length)`
- `.placeholder(text)`
- `.icon(icon)`
- `.title_prefix(text)`
- `.cleanable(bool)`
- `.search_placeholder(text)`
- `.disabled(bool)`
- `.empty(element)`
- `.appearance(bool)`
- size helpers

Use `SelectGroup::new(title).item(...).items(...)` for grouped data.

## Dialogs, Sheets, Popovers, Tooltips, Notifications

These require `Root` at the window root and `WindowExt` in scope.

### Dialog

Open:

```rust
window.open_dialog(cx, |dialog, _window, _cx| {
    dialog
        .confirm()
        .title("Delete item?")
        .child("This cannot be undone.")
        .on_ok(|_, window, cx| {
            window.push_notification(Notification::success("Deleted"), cx);
            true
        })
})
```

`Dialog` builders:

- `.title(element)`
- `.footer(|window, cx| element)`
- `.confirm()`, `.alert()`
- `.button_props(DialogButtonProps::default().ok_text(...).cancel_text(...))`
- `.on_close`, `.on_ok`, `.on_cancel`
- `.close_button(bool)`
- `.margin_top(px)`, `.w(px)`, `.width(px)`, `.max_w(px)`
- `.overlay(bool)`, `.overlay_closable(bool)`, `.keyboard(bool)`

`DialogButtonProps` builders: `.ok_text(...)`, `.ok_variant(ButtonVariant)`, `.cancel_text(...)`, `.cancel_variant(ButtonVariant)`.

### Sheet

```rust
window.open_sheet(cx, |sheet, _window, _cx| {
    sheet
        .title("Settings")
        .size(px(420.))
        .resizable(true)
        .child(SettingsView)
})
```

`Sheet` builders: `.title(...)`, `.footer(...)`, `.size(...)`, `.margin_top(...)`, `.resizable(bool)`, `.overlay(bool)`, `.overlay_closable(bool)`, `.on_close(...)`.

### Popover

```rust
Popover::new("filters")
    .trigger(Button::new("filters-button").label("Filters"))
    .content(|window, cx| {
        v_flex().p_3().gap_2().child("Filter content")
    })
```

`Popover` builders: `.anchor(Corner)`, `.mouse_button(MouseButton)`, `.trigger(element)`, `.default_open(bool)`, `.open(bool)`, `.on_open_change(...)`, `.trigger_style(...)`, `.overlay_closable(bool)`, `.content(...)`, `.appearance(bool)`, `.track_focus(&FocusHandle)`.

`PopoverState::new(default_open, cx)` supports `is_open`, `dismiss`, and `show`.

### Tooltip

```rust
Button::new("refresh")
    .icon(IconName::Redo)
    .tooltip("Refresh")
```

For manual tooltips:

```rust
Tooltip::new("Refresh").build(window, cx)
```

`Tooltip` builders: `new(text)`, `element(builder)`, `.action(action, context)`, `.key_binding(kbd)`, `.build(window, cx)`.

### Notification

```rust
window.push_notification(Notification::success("Saved"), cx);
```

Constructors: `Notification::new()`, `info(message)`, `success(message)`, `warning(message)`, `error(message)`.

Builders: `.message(...)`, `.id::<T>()`, `.id1::<T>(key)`, `.title(...)`, `.icon(...)`, `.with_type(...)`, `.autohide(bool)`, `.on_click(...)`, `.action(...)`, `.content(...)`.

## Lists

Use `List` for virtualized, searchable, selectable lists. Implement `ListDelegate`.

Required trait pieces:

- `type Item: Selectable + IntoElement`
- `items_count(section, cx) -> usize`
- `render_item(IndexPath, window, cx) -> Option<Item>`
- `set_selected_index(Option<IndexPath>, window, cx)`

Optional pieces:

- `perform_search`, `sections_count`, `render_section_header`, `render_section_footer`
- `render_empty`, `render_initial`, `loading`, `render_loading`
- `confirm`, `cancel`, `is_eof`, `load_more_threshold`, `load_more`

State:

```rust
let list = cx.new(|cx| {
    ListState::new(delegate, window, cx)
        .searchable(true)
        .selectable(true)
});
```

Render:

```rust
List::new(&self.list)
    .scrollbar_visible(true)
    .search_placeholder("Search")
```

`ListItem::new(id)` is a ready list row element. Useful builders: `.separator()`, `.check_icon(...)`, `.selected(bool)`, `.confirmed(bool)`, `.disabled(bool)`, `.suffix(...)`, `.on_click(...)`, `.on_mouse_enter(...)`.

Use `IndexPath` for section/row addressing.

## Tables

Use `Table` for large tabular datasets with virtualized rows/columns.

Implement `TableDelegate`:

- `columns_count(cx) -> usize`
- `rows_count(cx) -> usize`
- `column(col_ix, cx) -> &Column`
- `render_td(row_ix, col_ix, window, cx) -> impl IntoElement`

Optional trait pieces:

- `perform_sort`
- `render_header`, `render_th`, `render_tr`
- `context_menu`
- `move_column`
- `render_empty`, `loading`, `render_loading`
- `is_eof`, `load_more_threshold`, `load_more`
- `render_last_empty_col`
- `visible_rows_changed`, `visible_columns_changed`

Columns:

```rust
Column::new("name", "Name")
    .sortable()
    .width(px(180.))
    .resizable(true)
```

Column builders:

- `.sort(ColumnSort)`
- `.sortable()`, `.ascending()`, `.descending()`
- `.text_right()`, `.paddings(...)`, `.p_0()`
- `.width(px)`, `.fixed(...)`, `.fixed_left()`
- `.resizable(bool)`, `.movable(bool)`, `.selectable(bool)`

State:

```rust
let table = cx.new(|cx| {
    TableState::new(delegate, window, cx)
        .sortable(true)
        .row_selectable(true)
});
```

State builders and methods:

- `.loop_selection(bool)`, `.col_movable(bool)`, `.col_resizable(bool)`, `.sortable(bool)`, `.row_selectable(bool)`, `.col_selectable(bool)`
- `refresh`, `scroll_to_row`, `scroll_to_col`
- `selected_row`, `set_selected_row`, `selected_col`, `set_selected_col`, `clear_selection`
- `visible_range`, `delegate`, `delegate_mut`

Render:

```rust
Table::new(&self.table)
    .stripe(true)
    .bordered(true)
    .scrollbar_visible(true, true)
```

## Tabs, Menus, and Navigation

### Tabs

`Tab::new()` builders:

- `.label(...)`
- `.icon(...)`
- `.pill()`, `.outline()`, `.segmented()`, `.underline()`, `.with_variant(...)`
- `.prefix(...)`, `.suffix(...)`
- `.disabled(bool)`
- `.on_click(|&ClickEvent, &mut Window, &mut App| ...)`

`TabBar::new(id)` builders:

- `.pill()`, `.outline()`, `.segmented()`, `.underline()`, `.with_variant(...)`
- `.menu(bool)`, `.track_scroll(&ScrollHandle)`
- `.prefix(...)`, `.suffix(...)`
- `.child(tab)`, `.children(tabs)`
- `.selected_index(usize)`
- `.last_empty_space(element)`
- `.on_click(|usize, &mut Window, &mut App| ...)`

### Popup Menu

`PopupMenuItem` constructors/builders:

- `PopupMenuItem::new(label)`
- `element(builder)`, `submenu(label, menu)`, `separator()`, `label(label)`
- `.icon(...)`, `.action(Box<dyn Action>)`, `.disabled(bool)`, `.checked(bool)`, `.on_click(...)`
- `link(label, href)`

`PopupMenu` builders:

- `PopupMenu::build(window, cx, |menu, window, cx| menu...) -> Entity<PopupMenu>`
- `.action_context(handle)`, `.min_w(px)`, `.max_w(px)`, `.max_h(px)`, `.scrollable(bool)`, `.check_side(side)`, `.external_link_icon(bool)`
- `.menu(...)`, `.menu_with_enable(...)`, `.menu_with_disabled(...)`
- `.link(...)`, `.link_with_disabled(...)`, `.link_with_icon(...)`
- `.menu_with_icon(...)`, `.menu_with_check(...)`, `.menu_element(...)`
- `.separator()`, `.submenu(...)`, `.item(...)`, `.is_empty()`

For context menus, use `ContextMenuExt`/`ContextMenu` from `menu` and verify exact project pattern in source.

## Dock Layouts and Panels

Use `dock` for IDE-style layouts, side docks, split panels, tabs, and tiles.

Core types:

- `DockArea`
- `DockItem`
- `Dock`
- `Panel`
- `PanelView`
- `PanelRegistry`
- `DockState`, `DockAreaState`, `PanelState`

`DockItem` constructors/builders:

- `.panel(Arc<dyn PanelView>)`
- `.tabs(...)`, `.tab(panel_entity, cx)`
- `.split(...)`, `.v_split(...)`, `.h_split(...)`, `.split_with_sizes(...)`
- `.tiles(...)`
- `.size(px)`, `.active_index(usize)`
- `add_panel`, `remove_panel`, `find_panel`, `set_collapsed`

`DockArea::new(id, version, window, cx)` creates the root dock surface:

```rust
let dock = cx.new(|cx| DockArea::new("main-dock", Some(1), window, cx));
```

Useful methods include `set_root`, `set_center`, `set_left_dock`, `set_bottom_dock`, `set_right_dock`, `toggle_dock`, `add_panel`, `remove_panel`, `load`, `dump`, `set_zoomed_in`, `set_zoomed_out`.

To create a dock panel, implement `Panel` on a `Render + Focusable + EventEmitter<PanelEvent>` view. Required:

```rust
fn panel_name(&self) -> &'static str;
```

Common optional methods: `tab_name`, `title`, `title_style`, `title_suffix`, `closable`, `zoomable`, `visible`, `set_active`, `set_zoomed`, `dropdown_menu`, `toolbar_buttons`, `dump`, `inner_padding`.

Register persisted panel construction with:

```rust
register_panel(cx, "panel-name", |dock_area, panel_state, panel_info, window, cx| {
    Box::new(cx.new(|cx| MyPanel::new(dock_area, panel_state, panel_info, window, cx)))
});
```

The closure returns `Box<dyn PanelView>`. `dock_area` is `WeakEntity<DockArea>`, `panel_state` is `&PanelState`, and `panel_info` is `&PanelInfo`.

## Text, Markdown, Alerts, Badges, and Presentation

### TextView

`Text` represents raw, markdown, or HTML content. Use `TextView` to render selectable/scrollable rich text.

Useful APIs:

- `Text::style(TextViewStyle)`
- `Text::as_str()`
- `TextView::markdown(id, markdown, window, cx)`
- `TextView::html(id, html, window, cx)`
- `TextView::text(raw)`
- `TextView::style(TextViewStyle)`
- `TextView::selectable(bool)`
- `TextView::scrollable(bool)`
- `TextView::code_block_actions(...)`

`TextViewStyle` builders: `.paragraph_gap(rems)`, `.heading_font_size(...)`, `.code_block(style)`.

### Label

```rust
Label::new("Account")
    .secondary("admin")
    .highlights("adm")
```

Builders: `.secondary(...)`, `.masked(bool)`, `.highlights(...)`.

### Alert

Constructors:

- `Alert::new(id, message)`
- `Alert::info(id, message)`
- `Alert::success(id, message)`
- `Alert::warning(id, message)`
- `Alert::error(id, message)`

Builders: `.with_variant(...)`, `.icon(...)`, `.title(...)`, `.banner()`, `.visible(bool)`, `.on_close(...)`, size helpers.

### Badge

```rust
Badge::new()
    .count(3)
    .child(Button::new("inbox").icon(IconName::Inbox))
```

Builders: `.dot()`, `.count(usize)`, `.icon(...)`, `.max(usize)`, `.color(hsla)`, size helpers.

### Other Presentation Components

Check `component-map.md` for `avatar`, `breadcrumb`, `description_list`, `group_box`, `kbd`, `link`, `progress`, `spinner`, `skeleton`, `tag`, `chart`, and `plot`. If the manual does not list a method, use `source-fallback.md`.

## Optional Features

`webview`: enables `gpui_component::webview` through Wry. The upstream README marks it early/experimental, so verify current limitations.

`tree-sitter-languages`: enables bundled grammars for syntax highlighting paths.

`inspector`: enables inspector integration in supported builds.

`decimal`: enables decimal support.
