#!/bin/bash

# Verifies formatting of hand-written Dart sources.
#
# Excluded:
#   - *.*.dart                              (*.g.dart, *.freezed.dart, *.gen.dart, ...)
#   - lib/src/common/localization/generated  (intl_utils output, not formatter-clean)
#
# Pass CHECK_ONLY=0 to rewrite files in place instead of just checking.

set -euo pipefail

cd "$(dirname "$0")/.."

CHECK_ONLY="${CHECK_ONLY:-1}"

if [[ "$CHECK_ONLY" == "1" ]]; then
  FORMAT_ARGS=(--set-exit-if-changed -o none)
else
  FORMAT_ARGS=()
fi

targets=()
for d in lib test; do
  [[ -d "$d" ]] && targets+=("$d")
done

if ((${#targets[@]} == 0)); then
  echo "No lib/ or test/ directory to format."
  exit 0
fi

find "${targets[@]}" \
  -path 'lib/src/common/localization/generated' -prune -o \
  -name '*.dart' ! -name '*.*.dart' -print0 |
  xargs -0 dart format --line-length 100 "${FORMAT_ARGS[@]}"
