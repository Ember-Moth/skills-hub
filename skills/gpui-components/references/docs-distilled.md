# Distilled Upstream Docs

This reference distills the local upstream docs checkout found under `${CARGO_HOME:-$HOME/.cargo}/git/checkouts/gpui-component-*/8752104/docs`. That checkout declares `gpui-component = 0.5.2` and git-based GPUI dependencies, so treat this file as design and usage guidance. For crates.io `gpui-component = 0.5.1`, verify exact API names in `api-manual.md` or with `scripts/list-public-api.sh`.

## Table of Contents

- Provenance and version rules
- Core docs lessons
- Docs page coverage map
- Component selection notes
- Component families distilled
- Patterns worth reusing
- Docs-only names to verify first
- Extra API notes confirmed in 0.5.1

## Provenance and Version Rules

The upstream docs emphasize a component-first desktop UI library:

- 60+ desktop components on top of GPUI.
- Stateless `RenderOnce` elements for simple controls.
- `Entity<State>` + `Render` for stateful components such as inputs, lists, tables, selects, dates, trees, sliders, and color pickers.
- Built-in theme system and size scale.
- Virtualized list/table support for large data.
- Markdown/simple HTML text rendering, charts, code editor/highlighter, dock layouts, and CJK-friendly text.

Docs examples may use:

- `gpui_platform::application()` instead of crates.io `Application::new()`.
- git dependencies instead of crates.io versions.
- components or methods introduced after `0.5.1`.

For this skill, use crates.io setup unless the target project already pins git dependencies:

```rust
let app = Application::new().with_assets(gpui_component_assets::Assets);
```

This file distills the English docs tree (`docs/docs` and `docs/docs/components`). The `zh-CN` tree is a translation of the same conceptual material and should not be copied separately into the skill.

## Core Docs Lessons

Initialization:

- Call `gpui_component::init(cx)` before using component features.
- Use `Root::new(view, window, cx)` as the first-level window view.
- Use `Root::render_dialog_layer(window, cx)`, `Root::render_sheet_layer(window, cx)`, and `Root::render_notification_layer(window, cx)` when building a custom root surface that must explicitly place overlays.
- Use `WindowExt` for imperative overlays: dialogs, sheets, notifications, and focused input lookup.

Context conventions:

- `Window` handles window-level operations.
- `App` handles application-level operations and is passed to `RenderOnce`.
- `Context<Self>` handles entity-level state and notifications.
- `Entity<T>` stores stateful GPUI views/components.
- The conventional variable name is `cx` for both `&mut App` and `&mut Context<Self>`.

Element IDs:

- Keep `ElementId`s unique within the layout scope.
- For repeated children, use simple item IDs under a parent with its own stable ID.
- IDs are used by GPUI event binding and by component internals that call `window.use_keyed_state`.

Theme and sizing:

- Use `ActiveTheme` and `cx.theme()` for current theme colors.
- Prefer component size helpers: `.xsmall()`, `.small()`, default medium, `.large()`.
- In `0.5.1`, `Sizable` exposes `.xsmall()`, `.small()`, `.large()`, and `.with_size(...)`; do not assume a `.medium()` helper.

Assets:

- `gpui-component` intentionally does not embed icon assets.
- Use `gpui-component-assets` for default Lucide-based SVGs.
- Custom assets should implement `gpui::AssetSource` and provide paths matching `IconName`.

## Docs Page Coverage Map

General pages:

- `getting-started.md`: dependency setup, `Application::new().with_assets(...)`, `gpui_component::init(cx)`, `Root::new(...)`, stateless versus stateful components, theming, sizing, variants, icons.
- `root.md`: `Root` is the overlay host. If replacing `Root` with a custom root, explicitly render dialog, sheet, and notification layers.
- `element_id.md`: IDs are semantic component identity. Use stable, unique IDs; do not generate random IDs each render.
- `theme.md`: themes are registered during `gpui_component::init(cx)` and read through `cx.theme()`.
- `assets.md`: use `gpui-component-assets` for default icons; custom icon packs must expose matching asset paths.

Component docs whose intent maps well to crates.io `0.5.1`:

- Controls: `button`, `checkbox`, `radio`, `switch`, `toggle`, `slider`, `select`, `input`, `number-input`, `otp-input`, `dropdown_button`.
- Overlays: `dialog`, `sheet`, `popover`, `tooltip`, `notification`.
- Layout/navigation: `accordion`, `breadcrumb`, `sidebar`, `tabs`, `menu`, `collapsible`, `resizable`, `scrollable`, `title-bar`, `dock`-style APIs from source.
- Data: `list`, `data-table` maps to `Table`/`TableState`/`TableDelegate`; `virtual-list` maps to `VirtualList`.
- Content: `alert`, `avatar`, `badge`, `clipboard`, `description-list`, `group-box`, `kbd`, `label`, `link`, `progress`, `skeleton`, `spinner`, `tag`, `chart`, `plot`, `editor`, `calendar`, `date-picker`, `color-picker`, `tree`.

Component docs that are useful design references but not direct `0.5.1` API references:

- `table.md` describes a simple stateless table API. In `0.5.1`, public `gpui_component::table` is delegate-backed; use `Table::new(&Entity<TableState<D>>)` rather than `Table::new().child(TableRow...)`.
- `data-table.md` uses the name `DataTable`. In `0.5.1`, the public type is `Table`, with `TableState`, `TableDelegate`, `Column`, `ColumnSort`, and `TableEvent`.
- `editor.md` is not a separate `Editor` component. Use `InputState::multi_line(true)`, `InputState::auto_grow(...)`, or `InputState::code_editor(language)` rendered by `Input::new(&state)`.
- Pages for `AlertDialog`, `Combobox`, `HoverCard`, `Image`, `Pagination`, `Rating`, `StatusBar`, `Stepper`, and `FocusTrap` should be treated as post-`0.5.1` or docs-only until the target source proves otherwise.

## Component Selection Notes

Use `Button` for commands, not clickable `div`s. Use variants for intent: primary, danger, warning, success, info, ghost, link, text. Secondary is the default in `0.5.1`.

Use `InputState` + `Input` for text fields. The docs patterns cover placeholders, default values, clear buttons, prefix/suffix icons, password masking, validation, regex patterns, context menus, and input events.

Use `NumberInput` when the value is numeric and should support stepping, formatting, min/max-style validation, or prefix/suffix display.

Use `OtpState` + `OtpInput` for verification codes, PIN entry, grouped OTP layout, masked entry, and auto-submit flows.

Use `Checkbox` for independent booleans, `Switch` for binary settings/toggles, `Radio`/`RadioGroup` for mutually exclusive choices, and `Toggle`/`ToggleGroup` for toolbar or segmented on/off choices.

Use `Select` for simple single-selection dropdowns. Docs mention `Combobox` for richer multi-select/custom-trigger UIs, but `Combobox` is not a public `0.5.1` module; verify source before using it.

Use `Popover` for contextual rich content anchored to a trigger. Docs stress that `.content(...)` is called during render, so avoid creating entities or doing heavy work inside it.

Use `Dialog`, `Sheet`, and `Notification` through `WindowExt` for imperative app overlays. If rendering your own first-level content inside `Root`, add the explicit Root overlay layers.

Use `Form`, `Field`, `SettingPage`, `SettingGroup`, `SettingItem`, and `SettingField` for settings and structured forms instead of ad hoc stacked labels and controls.

Use `List` for virtualized/searchable/sectioned lists and `Table` for delegate-backed high-performance tables. The docs also mention a simple stateless table API, but the crates.io `0.5.1` `table` module is delegate-backed; verify before using stateless table subcomponents.

Use `VirtualList` directly for large custom vertical/horizontal surfaces when `List` or `Table` is too opinionated.

Use `ResizablePanelGroup` and `ResizablePanel` for split panes when a full dock layout is unnecessary. Use `DockArea`/`DockItem`/`Panel` for IDE-style persistent layouts.

Use `Sidebar`, `SidebarMenu`, `SidebarMenuItem`, and `SidebarGroup` for app navigation. Docs patterns include nested menu items, active states, badges/suffixes, collapsible sidebars, headers, and footers.

Use `TextView` for markdown/simple HTML and selectable/scrollable rich text. Use `Label` for compact text, secondary text, highlights, and masked values.

Use `Alert` for inline status messages, `Notification` for transient toasts, `Badge` for counts/dots/icons, `Tag` for categorical/status labels, `Skeleton` for loading placeholders, `Progress` for percent bars, and `Spinner` for indeterminate loading.

Use `Calendar`, `DatePicker`, and `ColorPicker` for specialized date/color selection. Use disabled matchers and presets instead of hand-writing date filters.

Use `Chart` helpers (`LineChart`, `BarChart`, `AreaChart`, `PieChart`, `CandlestickChart`) for common charts. Use `plot` primitives for custom chart rendering.

Use `TitleBar` and `TitlebarOptions` for custom title bars. Docs note platform differences; verify titlebar behavior on the target OS.

## Component Families Distilled

Commands and toolbars:

- Use `Button` for one-shot commands. Use `ButtonGroup` when adjacent buttons share one selection surface or should be visually joined.
- Use `Toggle`/`ToggleGroup` for persistent toolbar state such as filters, formatting, or view modes. A `ToggleGroup` emits the whole checked vector, so map indices back to parent state.
- Use `DropdownButton` when a primary command has a menu of related actions. Use `PopupMenu` actions for command routing, not manually positioned popover lists.

Inputs and editors:

- Use one `Entity<InputState>` per logical text field and store it on the parent view. Do not create input entities inside `render`.
- Use `InputState::multi_line(true)` for textarea behavior, `.auto_grow(min, max)` for expanding comment boxes, and `.code_editor("rust")` for simple code editing or code display with line numbers and highlighting.
- Code editor mode is intentionally lightweight. For complex language server/editor behavior, inspect the target project and the `input::lsp` surface before promising features.
- Docs mention methods such as `show_whitespaces`, `scroll_beyond_last_line`, and `cursor_surrounding_lines`; these were not confirmed in crates.io `0.5.1`. For `0.5.1`, rely on confirmed builders such as `.code_editor`, `.line_number`, `.searchable`, `.rows`, `.soft_wrap`, and `.tab_size`.
- `NumberInput` emits `NumberInputEvent::Step`; the parent should subscribe and update/clamp the text value. The component supplies buttons and key bindings, not numeric parsing policy.
- `OtpInput` is for fixed-length verification codes. Use `.groups(n)` for visual grouping and `OtpState::value()` for reads.

Choice and filtering:

- Use `RadioGroup::vertical(id)` or `RadioGroup::horizontal(id)` for mutually exclusive options when the built-in group layout is enough. Use individual `Radio` controls only when custom layout makes the group element inconvenient.
- Use `Select` for single selection and search over a bounded dataset. Implement `SelectItem` for custom records and `SelectDelegate` only when sections, async search, or custom storage are needed.
- The docs' `Combobox` examples are a design guide for richer search/entry UIs. In `0.5.1`, compose `Input`, `Popover`, `List`, or `Select` instead.

Overlays:

- Use `Dialog` for blocking decisions and confirmations, `Sheet` for side panels or longer edit flows, `Popover` for contextual controls, and `Tooltip` for short hints.
- Use `WindowExt` overlay helpers from event handlers. They require the window root to be `Root` or to include Root overlay layers manually.
- Do not create stateful views inside a `Popover::content` callback. Create the entity in the parent constructor and render or clone it into the content.

Forms and settings:

- Use `Form` and `Field` for ordinary label/control/description alignment. This avoids hand-built spacing and required markers.
- Use `Settings`, `SettingPage`, `SettingGroup`, `SettingItem`, and `SettingField` for preference panes. It gives consistent pages, groups, sidebar behavior, reset/default affordances, and standard controls.
- Use `GroupBox` for visually grouped related controls and `DescriptionList` for read-only key/value data, metadata panels, profile details, and system info.

Lists, trees, and tables:

- Use `List` when rows are selectable, searchable, sectioned, async-loaded, or virtualized. Rows should have stable heights because the delegate and virtualization assume predictable item sizing.
- Use `Tree` for hierarchical data such as file browsers or nested categories. Keep `TreeItem` IDs stable and update `TreeState` rather than rebuilding ad hoc rows in parent render code.
- Use `Table` for large or interactive tabular data. The docs' `DataTable` features map to `TableState` plus `TableDelegate`: sorting is implemented in `perform_sort`, context menus in `context_menu`, infinite loading in `load_more`, and selection through `TableState` plus `TableEvent`.
- Use `VirtualList` directly only for custom virtual surfaces that do not fit `List`, `Table`, or `Tree`.

Navigation and shell:

- Use `Sidebar` for application navigation, with `SidebarMenuItem` active state and suffix/badge support. Use a collapsed state in parent view state and pass it into both sidebar and toggle button.
- Use `TabBar`/`Tab` for local view switching. Use `DockArea`/`DockItem`/`Panel` for IDE-like multi-panel surfaces, persistence, side docks, tab panels, splits, and zooming.
- Use `ResizablePanelGroup` for simpler split panes when full dock persistence is unnecessary.
- Use `TitleBar` only when the app owns custom window chrome; validate platform behavior and existing project titlebar patterns first.

Content and feedback:

- Use `Alert` for inline warnings/errors/success states and `Notification` for transient feedback.
- Use `TextView` for markdown/simple HTML and code blocks. Use `Label` for compact inline text, secondary text, highlighted search matches, and masked values.
- Use `Badge` for counts and dot indicators, `Tag` for categorical/status labels, `Skeleton` for loading placeholders, `Spinner` for indeterminate activity, and `Progress` for percentage bars.
- Use `Chart` helpers for ordinary line/bar/area/pie/candlestick charts and `plot` primitives for custom axes, shapes, and tooltips.
- Use `Calendar`, `DatePicker`, and `ColorPicker` for date/color inputs; prefer disabled matchers, presets, and state APIs over custom pickers.

## Patterns Worth Reusing

Controlled state pattern:

```rust
Checkbox::new("remember")
    .label("Remember me")
    .checked(self.remember)
    .on_click(cx.listener(|this, checked, _window, cx| {
        this.remember = *checked;
        cx.notify();
    }))
```

Stateful component pattern:

```rust
let input = cx.new(|cx| {
    InputState::new(window, cx)
        .placeholder("Search")
        .clean_on_escape()
});

Input::new(&input).cleanable(true)
```

Select item pattern:

```rust
#[derive(Clone)]
struct Country {
    name: SharedString,
    code: SharedString,
}

impl SelectItem for Country {
    type Value = SharedString;

    fn title(&self) -> SharedString {
        self.name.clone()
    }

    fn value(&self) -> &Self::Value {
        &self.code
    }

    fn matches(&self, query: &str) -> bool {
        let query = query.to_lowercase();
        self.name.to_lowercase().contains(&query) || self.code.to_lowercase().contains(&query)
    }
}
```

Popover performance rule:

```rust
Popover::new("filters")
    .trigger(Button::new("filters-button").label("Filters"))
    .content(|_window, _cx| {
        v_flex().gap_2().child("Build cheap content here")
    })
```

For heavier content, create the entity in the parent view constructor and pass the existing entity into the popover.

Root overlay placement pattern:

```rust
div()
    .size_full()
    .child(app_content)
    .children(Root::render_dialog_layer(window, cx))
    .children(Root::render_sheet_layer(window, cx))
    .children(Root::render_notification_layer(window, cx))
```

Use this when your first-level view needs explicit overlay layering. If using `Root::new(view, window, cx)`, Root already owns the overlay state; check current render structure before duplicating layers.

## Docs-Only Names to Verify First

The local docs checkout contains pages for names that were not public modules in crates.io `gpui-component 0.5.1` during verification:

- `AlertDialog`
- `Combobox`
- `HoverCard`
- `Image`
- `Pagination`
- `Rating`
- `StatusBar`
- `Stepper`
- `FocusTrap`

Do not use these names against `0.5.1` unless `scripts/list-public-api.sh` or the target project's source confirms them. When a docs-only component is missing:

- Use `Dialog` for `AlertDialog`.
- Use `Select`, `List`, or a custom `Popover` for `Combobox`.
- Use `Popover`/`Tooltip` for `HoverCard`.
- Use GPUI image/SVG primitives or project helpers for `Image`.
- Use `Button`/`ToggleGroup` and project state for `Pagination`, `Rating`, or `Stepper`.
- Use GPUI focus handles and `Root`/overlay behavior for focus trapping.
- Use `h_flex`/`v_flex`, `Divider`, `Button`, and text elements for a status bar.

Docs examples also mention methods not present in `0.5.1`, such as `Switch::color`, `Switch::label_side`, `ProgressCircle`, and `Button`/`Sizable` `.medium()`. Verify before using.

## Extra API Notes Confirmed in 0.5.1

Root:

- `Root::render_notification_layer(window, cx)`
- `Root::render_sheet_layer(window, cx)`
- `Root::render_dialog_layer(window, cx)`

Accordion:

- `Accordion::new(id)`, `.multiple(bool)`, `.bordered(bool)`, `.disabled(bool)`, `.item(...)`, `.on_toggle_click(...)`
- `AccordionItem::new()`, `.icon(...)`, `.title(...)`, `.bordered(bool)`, `.open(bool)`, `.disabled(bool)`

Avatar:

- `Avatar::new()`, `.src(...)`, `.name(...)`, `.placeholder(...)`, size helpers
- `AvatarGroup::new()`, `.child(...)`, `.children(...)`, `.limit(usize)`, `.ellipsis()`

Breadcrumb:

- `Breadcrumb::new()`, `.child(...)`, `.children(...)`
- `BreadcrumbItem::new(label)`, `.disabled(bool)`, `.on_click(...)`

Form:

- `v_form()`, `h_form()`, `field()`
- `Form::vertical()`, `Form::horizontal()`, `.layout(Axis)`, `.label_width(px)`, `.label_text_size(rems)`, `.child(field)`, `.children(fields)`, `.columns(usize)`
- `Field::new()`, `.label(...)`, `.label_indent(bool)`, `.label_fn(...)`, `.description(...)`, `.description_fn(...)`, `.visible(bool)`, `.required(bool)`, `.items_start()`, `.items_end()`, `.items_center()`, `.col_span(u16)`, `.col_start(i16)`, `.col_end(i16)`

Settings:

- `Settings::new(id)`, `.sidebar_width(px)`, `.page(...)`, `.pages(...)`, `.with_group_variant(...)`, `.sidebar_style(...)`
- `SettingPage::new(title)`, `.title(...)`, `.description(...)`, `.default_open(bool)`, `.resettable(bool)`, `.group(...)`, `.groups(...)`
- `SettingGroup::new()`, `.title(...)`, `.description(...)`, `.item(...)`, `.items(...)`
- `SettingItem::new(title, field)`, `.render(...)`, `.description(...)`, `.layout(Axis)`
- `SettingField::switch`, `checkbox`, `input`, `dropdown`, `element`, `render`, `number_input`, `.default_value(...)`

Sidebar:

- `Sidebar::left()`, `Sidebar::right()`, `Sidebar::new(side)`, `.collapsible(bool)`, `.collapsed(bool)`, `.header(...)`, `.footer(...)`, `.child(...)`, `.children(...)`
- `SidebarToggleButton::left()`, `.right()`, `.side(...)`, `.collapsed(bool)`, `.on_click(...)`
- `SidebarMenu::new()`, `.child(...)`, `.children(...)`
- `SidebarMenuItem::new(label)`, `.icon(...)`, `.active(bool)`, `.on_click(...)`, `.collapsed(bool)`, `.default_open(bool)`, `.click_to_open(bool)`, `.children(...)`, `.suffix(...)`, `.disable(bool)`
- `SidebarGroup::new(label)`, `.child(...)`, `.children(...)`

Resizable:

- `h_resizable(id)`, `v_resizable(id)`, `resizable_panel()`
- `ResizablePanelGroup::new(id)`, `.with_state(...)`, `.axis(Axis)`, `.child(...)`, `.children(...)`, `.size(px)`, `.on_resize(...)`
- `ResizablePanel::visible(bool)`, `.size(px)`, `.size_range(range)`
- `ResizableState::sizes()`

Scrolling:

- `ScrollableMask::new(axis, scroll_handle)`, `.debug()`
- `Scrollbar::new(handle)`, `.horizontal(handle)`, `.vertical(handle)`, `.id(...)`, `.scrollbar_show(...)`, `.scroll_size(...)`, `.axis(...)`
- `ScrollableElement` and `Scrollable<E>` wrap interactive elements with scrollbars.

Dates and color:

- `CalendarState::new(window, cx)`, `.disabled_matcher(...)`, `.set_disabled_matcher(...)`, `.set_date(...)`, `.date()`, `.set_number_of_months(...)`, `.year_range(...)`
- `Calendar::new(&state)`, `.number_of_months(usize)`
- `DatePickerState::new(window, cx)`, `DatePickerState::range(window, cx)`, `.date_format(...)`, `.number_of_months(...)`, `.date()`, `.set_date(...)`, `.disabled_matcher(...)`
- `DatePicker::new(&state)`, `.placeholder(...)`, `.cleanable(bool)`, `.presets(...)`, `.number_of_months(...)`, `.appearance(bool)`
- `DateRangePreset::single(label, date)`, `DateRangePreset::range(label, start, end)`
- `Matcher::interval(before, after)`, `Matcher::range(from, to)`, `Matcher::custom(...)`
- `ColorPickerState::new(window, cx)`, `.default_value(...)`, `.set_value(...)`, `.value()`
- `ColorPicker::new(&state)`, `.featured_colors(...)`, `.icon(...)`, `.label(...)`, `.anchor(...)`

Tree:

- `TreeItem::new(id, label)`, `.child(...)`, `.children(...)`, `.expanded(bool)`, `.disabled(bool)`
- `TreeState::new(cx)`, `.items(...)`, `.set_items(...)`, `.selected_index()`, `.set_selected_index(...)`, `.scroll_to_item(...)`, `.selected_entry()`
- `tree(&state, render_item)` or `Tree::new(&state, render_item)`

Presentation:

- `DescriptionList::vertical()`, `.horizontal()`, `.label_width(...)`, `.layout(Axis)`, `.bordered(bool)`, `.columns(usize)`, `.item(label, value)`, `.child(...)`, `.children(...)`, `.divider()`
- `DescriptionItem::new(label)`, `.value(...)`, `.span(usize)`
- `GroupBox::new()`, `.id(...)`, `.title(...)`, `.title_style(...)`, `.content_style(...)`; variants through `GroupBoxVariants`
- `Tag::new()`, `primary`, `secondary`, `danger`, `success`, `warning`, `info`, `custom`, `color`, `.with_variant(...)`, `.outline()`, `.rounded(...)`, `.rounded_full()`
- `Divider::vertical()`, `.horizontal()`, `.vertical_dashed()`, `.horizontal_dashed()`, `.label(...)`, `.color(...)`, `.dashed()`
- `Clipboard::new(id)`, `.value(...)`, `.value_fn(...)`, `.on_copied(...)`
- `Kbd::new(keystroke)`, `.appearance(bool)`, `binding_for_action`, `binding_for_action_in`, `format`
- `Link::new(id)`, `.href(...)`, `.on_click(...)`, `.disabled(bool)`
- `Skeleton::new()`, `.secondary()`
- `Progress::new()`, `.bg(color)`, `.value(0.0..=100.0)`
- `Spinner::new()`, `.icon(...)`, `.color(...)`, size helpers
