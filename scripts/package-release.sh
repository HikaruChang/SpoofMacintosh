#!/bin/bash
# Powered by NyphexAI, Developed by Hikaru(i@rua.moe)
# Licensed under the PolyForm Noncommercial License 1.0.0
# Builds and packages distributable GitHub Release archives (.dmg, .zip, SHA256SUMS.txt, RELEASE_NOTES.md)
# into ./release without requiring root privileges (never calls sudo).

set -euo pipefail

ROOT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
VERSION_FILE="$ROOT_DIR/VERSION"

if [ "$#" -ge 1 ] && [ -n "$1" ]; then
  RAW_VERSION="$1"
elif [ -f "$VERSION_FILE" ]; then
  RAW_VERSION="$(tr -d '[:space:]' < "$VERSION_FILE")"
else
  echo "錯誤: 找不到 VERSION 檔案且未指定版本號" >&2
  exit 1
fi

VERSION="${RAW_VERSION#v}"
if ! printf '%s\n' "$VERSION" | grep -Eq '^[0-9]+\.[0-9]+\.[0-9]+(-[0-9A-Za-z.-]+)?$'; then
  echo "錯誤: 版本號格式無效 '$RAW_VERSION'" >&2
  exit 1
fi

echo "==> 建置 SpoofMacintosh v${VERSION} Release 產物..."
"$ROOT_DIR/scripts/build.sh"

RELEASE_DIR="$ROOT_DIR/release"
STAGE_DIR="$RELEASE_DIR/.staging"
DMG_NAME="SpoofMacintosh-v${VERSION}-macOS-arm64.dmg"
ZIP_NAME="SpoofMacintosh-v${VERSION}-Full-Suite-arm64.zip"
DMG_PATH="$RELEASE_DIR/$DMG_NAME"
ZIP_PATH="$RELEASE_DIR/$ZIP_NAME"

rm -rf "$RELEASE_DIR"
mkdir -p "$STAGE_DIR/dmg" "$STAGE_DIR/zip/SpoofMacintosh-v${VERSION}/scripts"

cleanup() {
  rm -rf "$STAGE_DIR"
}
trap cleanup EXIT

echo "==> 準備 DMG 磁碟映像暫存目錄..."
DMG_STAGE="$STAGE_DIR/dmg"
/usr/bin/ditto "$ROOT_DIR/dist/SpoofMacintosh.app" "$DMG_STAGE/SpoofMacintosh.app"
ln -s /Applications "$DMG_STAGE/Applications"
cp "$ROOT_DIR/README.md" "$DMG_STAGE/README.md"
cp "$ROOT_DIR/LICENSE" "$DMG_STAGE/LICENSE"
find "$DMG_STAGE" -name '.DS_Store' -delete

echo "==> 建立 ${DMG_NAME}..."
if ! /usr/bin/hdiutil create \
  -volname "SpoofMacintosh v${VERSION}" \
  -srcfolder "$DMG_STAGE" \
  -fs HFS+ \
  -ov \
  -format UDZO \
  "$DMG_PATH" >/dev/null; then
  echo "  ! HFS+ 指定失敗，改用預設檔案系統重新建立 DMG..."
  /usr/bin/hdiutil create \
    -volname "SpoofMacintosh v${VERSION}" \
    -srcfolder "$DMG_STAGE" \
    -ov \
    -format UDZO \
    "$DMG_PATH" >/dev/null
fi

echo "==> 準備 Full-Suite ZIP 暫存目錄..."
ZIP_ROOT="$STAGE_DIR/zip/SpoofMacintosh-v${VERSION}"
/usr/bin/ditto "$ROOT_DIR/dist/SpoofMacintosh.app" "$ZIP_ROOT/SpoofMacintosh.app"
/usr/bin/ditto "$ROOT_DIR/dist/SpoofMac.kext" "$ZIP_ROOT/SpoofMac.kext"
cp "$ROOT_DIR/dist/spoofmac" "$ZIP_ROOT/spoofmac"
cp "$ROOT_DIR/install.sh" "$ZIP_ROOT/install.sh"
cp "$ROOT_DIR/scripts/spoofmac-boot.sh" "$ZIP_ROOT/scripts/spoofmac-boot.sh"
cp "$ROOT_DIR/scripts/com.spoofmacintosh.loader.plist" "$ZIP_ROOT/scripts/com.spoofmacintosh.loader.plist"
chmod 755 "$ZIP_ROOT/spoofmac" "$ZIP_ROOT/install.sh" "$ZIP_ROOT/scripts/spoofmac-boot.sh"
cp "$ROOT_DIR/README.md" "$ZIP_ROOT/README.md"
cp "$ROOT_DIR/BUILD.md" "$ZIP_ROOT/BUILD.md"
cp "$ROOT_DIR/LICENSE" "$ZIP_ROOT/LICENSE"
if [ -d "$ROOT_DIR/docs" ]; then
  cp -R "$ROOT_DIR/docs" "$ZIP_ROOT/docs"
fi
find "$ZIP_ROOT" -name '.DS_Store' -delete

echo "==> 建立 ${ZIP_NAME}..."
/usr/bin/ditto -c -k --sequesterRsrc --keepParent "$ZIP_ROOT" "$ZIP_PATH"

echo "==> 產生 SHA256SUMS.txt 與 RELEASE_NOTES.md..."
(
  cd "$RELEASE_DIR"
  shasum -a 256 "$DMG_NAME" "$ZIP_NAME" > SHA256SUMS.txt
)

SHA_BLOCK="$(cat "$RELEASE_DIR/SHA256SUMS.txt")"

cat > "$RELEASE_DIR/RELEASE_NOTES.md" <<EOF
# SpoofMacintosh v${VERSION}

> Apple Silicon 全系列 Mac（M1–M6）動態機型、地區、序號與任意 \`IOPlatformExpertDevice\` 屬性偽裝解鎖工具  
> **Powered by NyphexAI, Developed by Hikaru(i@rua.moe)**

## 下載套件說明 / Release Packages

- **\`${DMG_NAME}\`**：原生 SwiftUI 圖形介面應用程式（內建 \`SpoofMac.kext\`、\`spoofmac\` CLI 與安裝精靈）。打開磁碟映像後將 \`SpoofMacintosh.app\` 拖入 \`Applications\` 即可。
- **\`${ZIP_NAME}\`**：完整套件壓縮包（含 \`SpoofMacintosh.app\`、獨立 \`SpoofMac.kext\`、\`spoofmac\` CLI、\`install.sh\`、開機 LaunchDaemon 腳本及多語言說明文件），適合進階使用者與終端機部署。

> **Gatekeeper / 隔離屬性說明**：本釋出版採用 ad-hoc 簽章（\`codesign -s -\`）。首次從瀏覽器下載打開若看到「無法驗證開發者」或「已損毀」，請執行以下指令移除系統下載隔離屬性：
> \`\`\`bash
> xattr -cr /Applications/SpoofMacintosh.app
> \`\`\`
> 完整恢復模式（1TR）前置設定與安裝步驟請參閱 \`README.md\`、\`docs/README_ZH-CN.md\`、\`docs/README_EN.md\` 與 \`docs/README_JA.md\`。

## SHA-256 Checksums

\`\`\`text
${SHA_BLOCK}
\`\`\`

---

* Required Notice: Copyright (c) 2026 Hikaru (i@rua.moe). Powered by NyphexAI, Developed by Hikaru(i@rua.moe)
* Licensed under the **PolyForm Noncommercial License 1.0.0** (attribution required; commercial use strictly prohibited).
EOF

echo "✓ Release 打包完成："
ls -lh "$RELEASE_DIR"
