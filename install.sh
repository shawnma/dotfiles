#!/usr/bin/env bash
# Usage: bash link-dotfiles.sh [dotfiles-folder]
# Defaults to this script's folder. Existing home files are left untouched.
set -euo pipefail

script_dir=$(cd -- "$(dirname -- "${BASH_SOURCE[0]}")" && pwd -P)
source_dir=$(cd -- "${1:-$script_dir}" && pwd -P)
script_path="$script_dir/$(basename -- "${BASH_SOURCE[0]}")"

if [[ "$source_dir" == "$(cd -- "$HOME" && pwd -P)" ]]; then
    echo "The source folder must be different from your home directory." >&2
    exit 1
fi

shopt -s nullglob dotglob
for source in "$source_dir"/*; do
    name=${source##*/}
    case "$name" in
        .git|.gitignore|.gitmodules|README*|LICENSE*) continue ;;
    esac
    [[ "$source" == "$script_path" ]] && continue
    # Ignore broken source links.
    [[ -e "$source" ]] || continue

    target="$HOME/.${name#.}"
    if [[ -L "$target" && "$(readlink -- "$target")" == "$source" ]]; then
        printf 'Already linked: %s\n' "$target"
    elif [[ -e "$target" || -L "$target" ]]; then
        printf 'Skipped (already exists): %s\n' "$target"
    else
        ln -s -- "$source" "$target"
        printf 'Linked: %s -> %s\n' "$target" "$source"
    fi
done
