#!/bin/bash
# Powered by NyphexAI, Developed by Hikaru(i@rua.moe)
# Licensed under the PolyForm Noncommercial License 1.0.0
# Unprivileged build script for SpoofMac.kext, spoofmac CLI, and SpoofMacintosh.app.
# Outputs everything to ./dist (and syncs SpoofMac.kext to repo root). Never invokes sudo.

set -euo pipefail

ROOT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
DIST_DIR="$ROOT_DIR/dist"
KEXT_SRC="$ROOT_DIR/kext/src"
KEXT_OUT="$DIST_DIR/SpoofMac.kext"
APP_OUT="$DIST_DIR/SpoofMacintosh.app"
BUILD_TMP="$DIST_DIR/.kext_tmp"

echo "==> 1/4 檢查建置工具與 macOS Kernel SDK..."
SDK="$(xcrun --sdk macosx --show-sdk-path)"
KH="$SDK/System/Library/Frameworks/Kernel.framework/Headers"
[ -d "$KH" ] || { echo "找不到 Kernel.framework Headers: $KH" >&2; exit 1; }

rm -rf "$KEXT_OUT" "$APP_OUT" "$BUILD_TMP"
mkdir -p "$KEXT_OUT/Contents/MacOS" "$BUILD_TMP"

echo "==> 2/4 編譯與連結 SpoofMac.kext (arm64e)..."
xcrun clang++ -arch arm64e -isysroot "$SDK" -I"$KH" \
  -DKERNEL -DKERNEL_PRIVATE -DDRIVER_PRIVATE -DAPPLE -DNeXT \
  -fno-builtin -fno-common -fapple-kext -mkernel \
  -std=c++17 -fno-rtti -fno-exceptions -fno-stack-protector -O2 \
  -c "$KEXT_SRC/SpoofMac.cpp" -o "$BUILD_TMP/SpoofMac.o"

xcrun clang -arch arm64e -isysroot "$SDK" -I"$KH" \
  -DKERNEL -DKERNEL_PRIVATE -DAPPLE \
  -fno-builtin -fno-common -mkernel -O2 \
  -c "$KEXT_SRC/kmod_info.c" -o "$BUILD_TMP/kmod_info.o"

xcrun clang++ -arch arm64e -isysroot "$SDK" -nostdlib -fapple-kext \
  -Xlinker -kext -lkmod -lkmodc++ -lcc_kext \
  -o "$KEXT_OUT/Contents/MacOS/SpoofMac" \
  "$BUILD_TMP/SpoofMac.o" "$BUILD_TMP/kmod_info.o"

cp "$KEXT_SRC/Info.plist" "$KEXT_OUT/Contents/Info.plist"
chmod 755 "$KEXT_OUT/Contents/MacOS/SpoofMac"
chmod 644 "$KEXT_OUT/Contents/Info.plist"

echo "==> 驗證 Kext Mach-O 架構與 KPI 相依性..."
if ! otool -hv "$KEXT_OUT/Contents/MacOS/SpoofMac" | grep -Eq 'ARM64[[:space:]]+E[[:space:]].*KEXTBUNDLE'; then
  echo "錯誤: Kext Mach-O 非 arm64e KEXTBUNDLE 架構" >&2
  otool -hv "$KEXT_OUT/Contents/MacOS/SpoofMac" >&2
  exit 1
fi

set +e
KPI_XML="$(kmutil libraries --arch arm64e --sdk "$SDK" -p "$KEXT_OUT" --xml 2>&1)"
KMUTIL_RC=$?
set -e

if [ "$KMUTIL_RC" -eq 0 ]; then
  if printf '%s\n' "$KPI_XML" | grep -q 'com.apple.kpi.private'; then
    echo "錯誤: Kext 不可相依於 com.apple.kpi.private" >&2
    printf '%s\n' "$KPI_XML" >&2
    exit 1
  fi
  echo "$KPI_XML" | grep -E 'com\.apple\.kpi\.' | sed 's/^/  KPI: /'
elif [ "${GITHUB_ACTIONS:-}" = "true" ] && ! printf '%s\n' "$KPI_XML" | grep -qiE 'Undefined symbols|com\.apple\.kpi\.private'; then
  echo "  ! 注意 (GitHub Actions VM): 主機 Preboot BootKC 無法存取，改以 nm / Info.plist 驗證 KPI 相依性"
  if grep -q 'com.apple.kpi.private' "$KEXT_OUT/Contents/Info.plist"; then
    echo "錯誤: Info.plist OSBundleLibraries 不可包含 com.apple.kpi.private" >&2
    exit 1
  fi
  SYM_LIST="$(nm -u "$KEXT_OUT/Contents/MacOS/SpoofMac")"
  if [ -z "$SYM_LIST" ]; then
    echo "錯誤: 無法讀取 Kext 未解析 KPI 符號" >&2
    exit 1
  fi
  printf '%s\n' "$SYM_LIST" | wc -l | awk '{print "  KPI symbols linked cleanly (" $1 " external symbols)"}'
else
  echo "$KPI_XML" >&2
  echo "kmutil libraries 驗證失敗" >&2
  exit 1
fi

codesign -f -s - "$KEXT_OUT" >/dev/null
rm -rf "$BUILD_TMP"

echo "==> 3/4 建置 Swift Release 執行檔 (spoofmac & SpoofMacintoshApp)..."
swift build --package-path "$ROOT_DIR" -c release --arch arm64
BIN_DIR="$(swift build --package-path "$ROOT_DIR" -c release --arch arm64 --show-bin-path)"

cp "$BIN_DIR/spoofmac" "$DIST_DIR/spoofmac"
chmod 755 "$DIST_DIR/spoofmac"
codesign -f -s - "$DIST_DIR/spoofmac" >/dev/null

echo "==> 4/4 組裝獨立自包含 SpoofMacintosh.app..."
mkdir -p "$APP_OUT/Contents/MacOS" "$APP_OUT/Contents/Resources"
cp "$BIN_DIR/SpoofMacintoshApp" "$APP_OUT/Contents/MacOS/SpoofMacintoshApp"
chmod 755 "$APP_OUT/Contents/MacOS/SpoofMacintoshApp"
cp "$ROOT_DIR/Sources/SpoofMacintoshApp/Info.plist" "$APP_OUT/Contents/Info.plist"

# Embed self-contained runtime, icons, license, & installer payload inside Resources
cp "$ROOT_DIR/Assets/AppIcon.icns" "$APP_OUT/Contents/Resources/AppIcon.icns"
cp "$ROOT_DIR/Assets/icon.png" "$APP_OUT/Contents/Resources/icon.png"
cp "$ROOT_DIR/LICENSE" "$APP_OUT/Contents/Resources/LICENSE"
cp "$DIST_DIR/spoofmac" "$APP_OUT/Contents/Resources/spoofmac"
cp -R "$KEXT_OUT" "$APP_OUT/Contents/Resources/SpoofMac.kext"
cp "$ROOT_DIR/scripts/spoofmac-boot.sh" "$APP_OUT/Contents/Resources/spoofmac-boot.sh"
cp "$ROOT_DIR/scripts/com.spoofmacintosh.loader.plist" "$APP_OUT/Contents/Resources/com.spoofmacintosh.loader.plist"
cp "$ROOT_DIR/install.sh" "$APP_OUT/Contents/Resources/install.sh"
chmod 755 "$APP_OUT/Contents/Resources/spoofmac" \
          "$APP_OUT/Contents/Resources/spoofmac-boot.sh" \
          "$APP_OUT/Contents/Resources/install.sh"

codesign --force --deep -s - "$APP_OUT" >/dev/null

# Also mirror kext to repo root for convenience with sudo ./install.sh
rm -rf "$ROOT_DIR/SpoofMac.kext"
cp -R "$KEXT_OUT" "$ROOT_DIR/SpoofMac.kext"

echo "✓ 建置完成："
echo "  • $KEXT_OUT"
echo "  • $DIST_DIR/spoofmac"
echo "  • $APP_OUT"
