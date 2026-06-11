# Assets

Use this file when icons fail to render or when setting up a new app.

## Default Asset Bundle

The `gpui-component-assets` package provides a library named `gpui_component_assets` with an `Assets` type implementing `gpui::AssetSource`. It embeds default SVG files for the component library's `IconName` variants.

```rust
use gpui::*;
use gpui_component_assets::Assets;

let app = Application::new().with_assets(Assets);
```

If `IconName` icons do not appear, first check that the application was created with `.with_assets(Assets)`.

## Icon Usage

```rust
use gpui_component::{button::*, IconName};

Button::new("search")
    .icon(IconName::Search)
    .label("Search")
```

`IconName` converts into `Icon` and into an element. Common names in `0.5.1` include:

- Arrows and chevrons: `ArrowLeft`, `ArrowRight`, `ArrowUp`, `ArrowDown`, `ChevronDown`, `ChevronsUpDown`
- Actions: `Check`, `Close`, `Copy`, `Delete`, `Plus`, `Minus`, `Undo`, `Redo`, `Search`, `Replace`
- Status: `Info`, `CircleCheck`, `CircleX`, `TriangleAlert`, `Loader`, `LoaderCircle`
- UI/chrome: `Menu`, `Settings`, `PanelLeft`, `PanelRight`, `PanelBottom`, `WindowClose`, `WindowMaximize`, `WindowMinimize`
- Objects: `File`, `Folder`, `FolderOpen`, `Calendar`, `User`, `Globe`, `GitHub`

Run `scripts/list-public-api.sh` or inspect `src/icon.rs` in the resolved crate to confirm the full enum for a different version.

## Custom Icons

For custom icon sets, provide an asset source containing SVG paths that match an `IconNamed` implementation. `IconNamed::path(self) -> SharedString` returns the embedded asset path used by `Icon::build`.

Use `gpui-component-assets` unless the project has a deliberate custom icon bundle.
