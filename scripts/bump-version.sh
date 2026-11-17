#!/bin/bash
# Powered by NyphexAI, Developed by Hikaru(i@rua.moe)
# Licensed under the PolyForm Noncommercial License 1.0.0
# Synchronizes release version across VERSION, SpoofMacMetadata.swift, and Info.plist manifests.

set -euo pipefail

if [ "$#" -ne 1 ]; then
  echo "Usage: $0 <version>" >&2
  echo "Example: $0 1.0.0  or  $0 v1.1.0-beta.1" >&2
  exit 1
fi

ROOT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
RAW_VERSION="$1"
VERSION="${RAW_VERSION#v}"

if ! printf '%s\n' "$VERSION" | grep -Eq '^[0-9]+\.[0-9]+\.[0-9]+(-[0-9A-Za-z.-]+)?$'; then
  echo "錯誤: 版本號格式無效 '$RAW_VERSION' (須為 X.Y.Z 或 X.Y.Z-prerelease)" >&2
  exit 1
fi

# Apple KEXT CFBundleVersion strictly requires numeric X.Y.Z (no prerelease suffix).
BASE_VERSION="${VERSION%%-*}"

printf '%s\n' "$VERSION" > "$ROOT_DIR/VERSION"

METADATA_SWIFT="$ROOT_DIR/Sources/SpoofMacCore/SpoofMacMetadata.swift"
python3 - "$METADATA_SWIFT" "$VERSION" <<'PY'
import re
import sys

path, version = sys.argv[1], sys.argv[2]
with open(path, "r", encoding="utf-8") as f:
    text = f.read()

new_text, count = re.subn(
    r'(public static let version\s*=\s*")[^"]*(")',
    lambda m: f"{m.group(1)}{version}{m.group(2)}",
    text,
    count=1,
)
if count != 1:
    sys.stderr.write(f"Failed to update SpoofMacMetadata.version in {path}\n")
    sys.exit(1)

with open(path, "w", encoding="utf-8") as f:
    f.write(new_text)
PY

APP_PLIST="$ROOT_DIR/Sources/SpoofMacintoshApp/Info.plist"
/usr/libexec/PlistBuddy -c "Set :CFBundleShortVersionString $VERSION" "$APP_PLIST"
/usr/libexec/PlistBuddy -c "Set :CFBundleVersion $BASE_VERSION" "$APP_PLIST"

KEXT_PLIST="$ROOT_DIR/kext/src/Info.plist"
/usr/libexec/PlistBuddy -c "Set :CFBundleShortVersionString $BASE_VERSION" "$KEXT_PLIST"
/usr/libexec/PlistBuddy -c "Set :CFBundleVersion $BASE_VERSION" "$KEXT_PLIST"

echo "✓ 版本號已同步更新為 v$VERSION (Kext/Build: $BASE_VERSION)："
echo "  • VERSION"
echo "  • Sources/SpoofMacCore/SpoofMacMetadata.swift"
echo "  • Sources/SpoofMacintoshApp/Info.plist"
echo "  • kext/src/Info.plist"
