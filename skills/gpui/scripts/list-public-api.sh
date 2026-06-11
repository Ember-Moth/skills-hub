#!/usr/bin/env bash
set -euo pipefail

cargo_home="${CARGO_HOME:-$HOME/.cargo}"
arg="${1:-}"
default_version="${GPUI_VERSION:-0.2.2}"
gpui_root=""

if [[ -n "$arg" && -d "$arg/src" ]]; then
  gpui_root="$arg"
else
  version="${arg:-$default_version}"
  gpui_root="$(find "$cargo_home/registry/src" -maxdepth 3 -type d -name "gpui-$version" 2>/dev/null | sort | head -n 1)"
fi

if [[ -z "$gpui_root" || ! -d "$gpui_root/src" ]]; then
  printf 'Could not locate gpui source. Usage: %s [gpui-version|gpui-source-root]\n' "$0" >&2
  printf 'Looked under: %s/registry/src\n' "$cargo_home" >&2
  exit 1
fi

printf '# GPUI public API index\n\n'
printf 'Source: %s\n\n' "$gpui_root"

rg -n \
  '^(pub (use|mod|struct|enum|trait|type|const|fn)|    pub fn |    pub async fn )' \
  "$gpui_root/src" \
  | sed "s#^$gpui_root/##" \
  | sort -t: -k1,1 -k2,2n
