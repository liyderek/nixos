#!/usr/bin/env bash
set -euo pipefail

repo="$(dirname "$(readlink -f "${BASH_SOURCE[0]}")")"
command="${1:-help}"
if (( $# > 0 )); then
  shift
fi

case "$command" in
  rebuild|build|upgrade|work|update)
    host="$(hostname)"
    if (( $# > 0 )) && [[ "$1" != -* ]]; then
      host="${1:-$host}"
      shift
    fi
    ;;
esac

case "$command" in
  rebuild)
    exec nh os switch --hostname "$host" --no-specialisation "$repo" "$@"
    ;;
  build)
    exec nh os build --hostname "$host" --no-specialisation "$repo" "$@"
    ;;
  upgrade)
    exec nh os switch --hostname "$host" --no-specialisation --update "$repo" "$@"
    ;;
  work)
    exec nh os switch --hostname "$host" --specialisation work "$repo" "$@"
    ;;
  check)
    # nh does not implement flake checks.
    exec nix flake check --no-build --all-systems "$repo" "$@"
    ;;
  update)
    update_args=()
    while (( $# > 0 )) && [[ "$1" != -- ]]; do
      if [[ -n "$1" ]]; then
        update_args+=(--update-input "$1")
      fi
      shift
    done
    if [[ "${1:-}" == -- ]]; then
      shift
    fi
    if (( ${#update_args[@]} == 0 )); then
      update_args=(--update)
    fi
    exec nh os build --hostname "$host" --no-specialisation "$repo" "${update_args[@]}" "$@"
    ;;
  clean)
    exec nh clean all "$@"
    ;;
  edit)
    cd "$repo"
    exec codium "$repo" "$@"
    ;;
  run)
    # nh does not implement running arbitrary flake applications.
    exec nix run "$@"
    ;;
  help|-h|--help)
    printf 'Usage: %s {rebuild|build|upgrade|work} [hostname] [nh options ...]\n' "$0"
    printf '       %s update [hostname] [input ...] [-- nh options ...]\n' "$0"
    printf '       %s clean [nh options ...]\n' "$0"
    printf '       %s {check|edit|run} [arguments ...]\n' "$0"
    printf '\nupdate refreshes inputs and builds the host without activating it.\n'
    ;;
  *)
    printf 'Unknown command: %s\n' "$command" >&2
    exit 2
    ;;
esac
