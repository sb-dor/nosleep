#!/bin/bash

# Runs the project's tests with coverage and a JSON report for the CI reporter.
#
# Package discovery deliberately prunes build/ and .dart_tool/ — a local build
# vendors third-party sources (e.g. build/ios/SourcePackages/*) that carry their
# own pubspec.yaml + test/, and those would otherwise be collected and run here.

set -euo pipefail

cd "$(dirname "$0")/.."

# Find directories with a pubspec.yaml and a test/ folder, ignoring build output.
find_test_dirs() {
  find . \
    \( -name build -o -name .dart_tool -o -name .git -o -name ephemeral \) -prune -o \
    -type f -name pubspec.yaml -print |
    while read -r pubspec; do
      dir="$(dirname "$pubspec")"
      # Emit the test/ dir, not the package root: `flutter test <pkg>` walks the
      # whole package and would descend into build/ again.
      if [ -d "$dir/test" ]; then
        echo "$dir/test"
      fi
    done
}

test_dirs=()
while IFS= read -r line; do
  [ -n "$line" ] && test_dirs+=("$line")
done < <(find_test_dirs)

if [ "${#test_dirs[@]}" -eq 0 ]; then
  echo "No directories with pubspec.yaml and test/ folder found."
  exit 0
fi

echo "Testing: ${test_dirs[*]}"

mkdir -p reports
flutter test "${test_dirs[@]}" --no-pub --coverage --file-reporter json:reports/tests.json
