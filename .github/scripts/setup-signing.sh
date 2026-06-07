#!/usr/bin/env bash
set -euo pipefail

required_variables=(
  APPLE_ID
  APPLE_APP_SPECIFIC_PASSWORD
  DEVELOPER_ID_CERTIFICATE_BASE64
  DEVELOPER_ID_CERTIFICATE_PASSWORD
  NOTARY_PROFILE
  TEAM_ID
)

for variable_name in "${required_variables[@]}"; do
  if [[ -z "${!variable_name:-}" ]]; then
    echo "Required environment variable is missing: $variable_name" >&2
    exit 1
  fi
done

for command_name in base64 grep openssl security xcrun; do
  if ! command -v "$command_name" >/dev/null 2>&1; then
    echo "Required command not found: $command_name" >&2
    exit 1
  fi
done

CERTIFICATE_PATH="$RUNNER_TEMP/developer-id-application.p12"
KEYCHAIN_PATH="$RUNNER_TEMP/dropsweep-build.keychain-db"
KEYCHAIN_PASSWORD="$(openssl rand -base64 32)"

{
  echo "CERTIFICATE_PATH=$CERTIFICATE_PATH"
  echo "KEYCHAIN_PATH=$KEYCHAIN_PATH"
} >> "$GITHUB_ENV"

printf '%s' "$DEVELOPER_ID_CERTIFICATE_BASE64" | base64 --decode > "$CERTIFICATE_PATH"

security create-keychain -p "$KEYCHAIN_PASSWORD" "$KEYCHAIN_PATH"
security set-keychain-settings -lut 21600 "$KEYCHAIN_PATH"
security unlock-keychain -p "$KEYCHAIN_PASSWORD" "$KEYCHAIN_PATH"
security import "$CERTIFICATE_PATH" \
  -k "$KEYCHAIN_PATH" \
  -P "$DEVELOPER_ID_CERTIFICATE_PASSWORD" \
  -A \
  -t cert \
  -f pkcs12
security set-key-partition-list \
  -S apple-tool:,apple:,codesign: \
  -s \
  -k "$KEYCHAIN_PASSWORD" \
  "$KEYCHAIN_PATH"
security list-keychains -d user -s "$KEYCHAIN_PATH"
security default-keychain -d user -s "$KEYCHAIN_PATH"

xcrun notarytool store-credentials "$NOTARY_PROFILE" \
  --apple-id "$APPLE_ID" \
  --team-id "$TEAM_ID" \
  --password "$APPLE_APP_SPECIFIC_PASSWORD"

IDENTITIES="$(security find-identity -v -p codesigning "$KEYCHAIN_PATH")"
printf '%s\n' "$IDENTITIES"

if ! grep -q '"Developer ID Application:' <<< "$IDENTITIES"; then
  echo "No Developer ID Application identity was imported." >&2
  exit 1
fi
