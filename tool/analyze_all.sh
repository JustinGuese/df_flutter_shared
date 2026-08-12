#!/usr/bin/env bash
# Resolve and analyze every df_* package. This is what CI runs; run it locally
# before pushing, because every consuming app tracks `main` directly.
#
#   ./tool/analyze_all.sh            # analyze all packages
#   ./tool/analyze_all.sh df_theme   # analyze just one
set -uo pipefail

cd "$(dirname "$0")/.." || exit 1

if [ $# -gt 0 ]; then
  packages=("$@")
else
  packages=(df_*/)
fi

failed=()
for pkg in "${packages[@]}"; do
  pkg="${pkg%/}"
  [ -f "$pkg/pubspec.yaml" ] || continue
  printf '\n\033[1m=== %s ===\033[0m\n' "$pkg"
  if ! (cd "$pkg" && flutter pub get >/dev/null 2>&1); then
    echo "  pub get FAILED"
    (cd "$pkg" && flutter pub get 2>&1 | tail -20)
    failed+=("$pkg (pub get)")
    continue
  fi
  if ! (cd "$pkg" && flutter analyze --fatal-infos); then
    failed+=("$pkg (analyze)")
  fi
done

echo
if [ ${#failed[@]} -eq 0 ]; then
  echo "All ${#packages[@]} package(s) clean."
else
  printf 'FAILED (%d):\n' "${#failed[@]}"
  printf '  - %s\n' "${failed[@]}"
  exit 1
fi
