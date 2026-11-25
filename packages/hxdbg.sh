#!/usr/bin/env bash
set -euo pipefail

# Build one C++ translation unit for Helix's lldb-dap binary launch template.
compiler=${1:?compiler required}
source=${2:?source file required}
case "$source" in
  *.cpp|*.cc|*.cxx|*.c++|*.C) ;;
  *) printf 'Not a C++ source file: %s\n' "$source" >&2; exit 2 ;;
esac
source=$(realpath -- "$source")
cache="${XDG_CACHE_HOME:-$HOME/.cache}/helix-debug"
mkdir -p -- "$cache"
key=$(printf '%s' "$source" | sha256sum | cut -c1-24)
program="$cache/$key"
log="$program.log"
tmp=$(mktemp "$cache/.build.XXXXXX")
trap 'rm -f -- "$tmp"' EXIT

if ! "$compiler" -std=c++20 -g -O0 -fno-omit-frame-pointer "$source" -o "$tmp" >"$log" 2>&1; then
  printf 'C++ build failed; diagnostics: %s\n' "$log" >&2
  cat "$log" >&2
  if [[ -n "${DISPLAY:-}${WAYLAND_DISPLAY:-}" ]]; then
    notify-send 'Helix C++ build failed' "$(head -n 5 "$log")"$'\n'"Full log: $log" || true
  fi
  exit 1
fi
chmod +x "$tmp"
mv -f -- "$tmp" "$program"
printf '%s\n' "$program"
