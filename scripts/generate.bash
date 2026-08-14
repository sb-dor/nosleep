#!/bin/bash

# Generates every file that is git-ignored but required to compile:
#   - l10n      -> lib/src/common/localization/generated/ (intl_utils)
#   - assets    -> lib/src/common/constant/assets.gen.dart (flutter_gen_runner)
#   - *.g.dart / *.freezed.dart / *.drift.dart (build_runner)
#
# Must run before format/analyze/test, otherwise a fresh checkout has no
# generated sources and everything downstream fails to compile.

set -euo pipefail

cd "$(dirname "$0")/.."

printf '\n==> Resolving dependencies\n'
flutter pub get

printf '\n==> Generating localization (intl_utils)\n'
dart run intl_utils:generate

printf '\n==> Generating assets + code (build_runner)\n'
dart run build_runner build --delete-conflicting-outputs

printf '\n==> Generation complete\n'
