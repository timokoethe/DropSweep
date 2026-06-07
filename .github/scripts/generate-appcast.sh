#!/usr/bin/env bash
set -euo pipefail

required_variables=(
  GITHUB_REPOSITORY
  RELEASE_ASSET
  RELEASE_TAG
  RUNNER_TEMP
  SCHEME
  SPARKLE_PRIVATE_KEY
)

for variable_name in "${required_variables[@]}"; do
  if [[ -z "${!variable_name:-}" ]]; then
    echo "Required environment variable is missing: $variable_name" >&2
    exit 1
  fi
done

ROOT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")/../.." && pwd)"
APPCAST_DIR="$RUNNER_TEMP/sparkle-appcast"
SPARKLE_DERIVED_DATA="$RUNNER_TEMP/sparkle-derived-data"

cd "$ROOT_DIR"
rm -rf "$APPCAST_DIR" "$SPARKLE_DERIVED_DATA"
mkdir -p "$APPCAST_DIR"
cp "$RELEASE_ASSET" "$APPCAST_DIR/"

xcodebuild -resolvePackageDependencies \
  -project DropSweep.xcodeproj \
  -scheme "$SCHEME" \
  -derivedDataPath "$SPARKLE_DERIVED_DATA"

GENERATE_APPCAST="$SPARKLE_DERIVED_DATA/SourcePackages/artifacts/sparkle/Sparkle/bin/generate_appcast"

if [[ ! -x "$GENERATE_APPCAST" ]]; then
  echo "Sparkle generate_appcast tool not found: $GENERATE_APPCAST" >&2
  exit 1
fi

printf '%s' "$SPARKLE_PRIVATE_KEY" |
  "$GENERATE_APPCAST" \
    --ed-key-file - \
    --download-url-prefix "https://github.com/$GITHUB_REPOSITORY/releases/download/$RELEASE_TAG/" \
    --full-release-notes-url "https://github.com/$GITHUB_REPOSITORY/releases/tag/$RELEASE_TAG" \
    --link "https://github.com/$GITHUB_REPOSITORY" \
    --maximum-versions 1 \
    --maximum-deltas 0 \
    -o "$APPCAST_DIR/appcast.xml" \
    "$APPCAST_DIR"

cp "$APPCAST_DIR/appcast.xml" "$ROOT_DIR/appcast.xml"
