#!/usr/bin/env bash
set -euo pipefail

usage() {
  printf 'Usage: %s <template-dir>\n' "$0"
}

if [[ "${1:-}" == "-h" || "${1:-}" == "--help" ]]; then
  usage
  exit 0
fi

if [[ $# -ne 1 ]]; then
  usage >&2
  exit 2
fi

template_dir="$1"
missing=0

if [[ ! -d "$template_dir" ]]; then
  printf 'Missing template directory: %s\n' "$template_dir" >&2
  exit 1
fi

for path in Cargo.toml src/main.rs; do
  if [[ ! -f "$template_dir/$path" ]]; then
    printf 'Missing required file: %s/%s\n' "$template_dir" "$path" >&2
    missing=1
  fi
done

if [[ "$missing" -ne 0 ]]; then
  exit 1
fi

printf 'Template structure looks complete: %s\n' "$template_dir"
