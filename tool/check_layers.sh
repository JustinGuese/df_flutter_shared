#!/usr/bin/env bash
# Verifies that package dependencies conform to architecture layers defined in PLAN.md Batch 0:
#   L0: df_theme, df_analytics_core, df_error_reporting, df_api, leaf utils (df_core_utils, df_device_id, df_file_download, df_audio_capture)
#   L1: df_ui_widgets
#   L2: capability packages (df_ads, df_billing, df_courses, df_firebase_auth, etc.)
#   L3: df_funnel, df_settings, df_app_shell
#
# Rule: A package may only depend on lower layers (L2 lateral dependencies permitted).
# Upward dependencies (dep_layer > src_layer) and illegal L0/L3 cross-dependencies fail this check.
set -euo pipefail

cd "$(dirname "$0")/.." || exit 1

get_layer() {
  local pkg="$1"
  case "$pkg" in
    df_theme|df_analytics_core|df_error_reporting|df_api|df_core_utils|df_device_id|df_file_download|df_audio_capture)
      echo 0
      ;;
    df_ui_widgets)
      echo 1
      ;;
    df_funnel|df_settings|df_app_shell)
      echo 3
      ;;
    df_*)
      echo 2
      ;;
    *)
      echo -1
      ;;
  esac
}

if [ $# -gt 0 ]; then
  packages=("$@")
else
  packages=(df_*/)
fi

failed=()
checked=0

for pkg in "${packages[@]}"; do
  pkg="${pkg%/}"
  pubspec="$pkg/pubspec.yaml"
  [ -f "$pubspec" ] || continue

  src_layer=$(get_layer "$pkg")
  if [ "$src_layer" -lt 0 ]; then
    continue
  fi

  ((checked++)) || true

  # Extract df_* dependencies declared under dependencies or dev_dependencies
  deps=$(awk '
    /^[a-zA-Z0-9_]+:/ { in_deps = ($1 == "dependencies:" || $1 == "dev_dependencies:") }
    in_deps && /^  df_[a-zA-Z0-9_]+:/ { gsub(/[: ]/, "", $1); print $1 }
  ' "$pubspec" | sort -u)

  for dep in $deps; do
    dst_layer=$(get_layer "$dep")
    if [ "$dst_layer" -lt 0 ]; then
      continue
    fi

    if [ "$dst_layer" -gt "$src_layer" ]; then
      failed+=("$pkg (L$src_layer) depends upward on $dep (L$dst_layer)")
    elif [ "$src_layer" -eq 0 ] && [ "$dst_layer" -ge 0 ]; then
      failed+=("$pkg (L0) must not depend on other df_* packages, but depends on $dep (L$dst_layer)")
    elif [ "$src_layer" -eq 3 ] && [ "$dst_layer" -eq 3 ]; then
      failed+=("$pkg (L3) must not depend on peer L3 package $dep (L3)")
    fi
  done
done

echo "Layer check: $checked package(s) inspected."
if [ ${#failed[@]} -gt 0 ]; then
  printf '\033[1;31mLayer check FAILED (%d violation(s)):\033[0m\n' "${#failed[@]}"
  for v in "${failed[@]}"; do
    echo "  - $v"
  done
  exit 1
fi

echo "Layer check passed: all dependencies conform to layer hierarchy."
