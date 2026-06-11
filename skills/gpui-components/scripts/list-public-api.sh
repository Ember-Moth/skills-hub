#!/usr/bin/env bash
set -euo pipefail

cargo_home="${CARGO_HOME:-$HOME/.cargo}"
arg="${1:-${GPUI_COMPONENT_VERSION:-0.5.1}}"
component_root=""

if [[ -d "$arg/src" ]]; then
  component_root="$arg"
  version="$(basename "$component_root" | sed -E 's/^gpui-component-//')"
else
  version="$arg"
  component_root="$(find "$cargo_home/registry/src" -maxdepth 3 -type d -name "gpui-component-$version" 2>/dev/null | sort | head -n 1)"
fi

if [[ -z "$component_root" || ! -d "$component_root/src" ]]; then
  printf 'Could not locate gpui-component source. Usage: %s [version|gpui-component-source-root]\n' "$0" >&2
  printf 'Looked under: %s/registry/src\n' "$cargo_home" >&2
  exit 1
fi

printf '# GPUI Component public API index\n\n'
printf 'Source: %s\n\n' "$component_root"

rg -n \
  '^(pub (use|mod|struct|enum|trait|type|const|fn)|    pub fn |    pub async fn )' \
  "$component_root/src" \
  | sed "s#^$component_root/##" \
  | sort -t: -k1,1 -k2,2n

for crate in gpui-component-assets gpui-component-macros; do
  root="$(find "$cargo_home/registry/src" -maxdepth 3 -type d -name "$crate-$version" 2>/dev/null | sort | head -n 1)"
  if [[ -n "$root" && -d "$root/src" ]]; then
    printf '\n# %s public API index\n\n' "$crate"
    printf 'Source: %s\n\n' "$root"
    rg -n \
      '^(pub (use|mod|struct|enum|trait|type|const|fn)|    pub fn |    pub async fn )' \
      "$root/src" \
      | sed "s#^$root/##" \
      | sort -t: -k1,1 -k2,2n
  fi
done
