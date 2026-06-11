#!/usr/bin/env bash
set -euo pipefail

cargo_home="${CARGO_HOME:-$HOME/.cargo}"
version="${1:-${GPUI_VERSION:-}}"

if [[ -n "$version" ]]; then
  source_pattern="gpui-$version"
  archive_pattern="gpui-$version.crate"
else
  source_pattern="gpui-*"
  archive_pattern="gpui-*.crate"
fi

printf 'Source directories:\n'
find "$cargo_home/registry/src" -maxdepth 3 -type d -name "$source_pattern" 2>/dev/null | sort || true

printf '\nCrate archives:\n'
find "$cargo_home/registry/cache" -type f -name "$archive_pattern" 2>/dev/null | sort || true
