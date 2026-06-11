#!/usr/bin/env bash
set -euo pipefail

cargo_home="${CARGO_HOME:-$HOME/.cargo}"
version="${1:-${GPUI_COMPONENT_VERSION:-0.5.1}}"

if [[ -d "$version/src" ]]; then
  component_root="$version"
  version="$(basename "$component_root" | sed -E 's/^gpui-component-//')"
else
  component_root="$(find "$cargo_home/registry/src" -maxdepth 3 -type d -name "gpui-component-$version" 2>/dev/null | sort | head -n 1)"
fi

assets_root="$(find "$cargo_home/registry/src" -maxdepth 3 -type d -name "gpui-component-assets-$version" 2>/dev/null | sort | head -n 1)"
macros_root="$(find "$cargo_home/registry/src" -maxdepth 3 -type d -name "gpui-component-macros-$version" 2>/dev/null | sort | head -n 1)"

if [[ -z "${component_root:-}" || ! -d "$component_root/src" ]]; then
  printf 'Could not locate gpui-component source for version %s.\n' "$version" >&2
  printf 'Looked under: %s/registry/src\n' "$cargo_home" >&2
  exit 1
fi

printf 'gpui-component=%s\n' "$component_root"

if [[ -n "$assets_root" ]]; then
  printf 'gpui-component-assets=%s\n' "$assets_root"
else
  printf 'gpui-component-assets=<not found for %s>\n' "$version"
fi

if [[ -n "$macros_root" ]]; then
  printf 'gpui-component-macros=%s\n' "$macros_root"
else
  printf 'gpui-component-macros=<not found for %s>\n' "$version"
fi
