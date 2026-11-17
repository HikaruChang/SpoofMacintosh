# 從原始碼建置與發佈 SpoofMacintosh

> Powered by NyphexAI, Developed by Hikaru(i@rua.moe)  
> Licensed under the [PolyForm Noncommercial License 1.0.0](LICENSE)

本文件說明如何在 Apple Silicon Mac 上從原始碼建置 `SpoofMac.kext`（`arm64e` 核心擴展）、`spoofmac`（CLI 命令列工具）、`SpoofMacintosh.app`（原生 SwiftUI 應用程式），以及打包與發佈 GitHub Release。

## 環境需求

- Apple Silicon Mac（`arm64`）
- 已安裝 Xcode 或 Command Line Tools（含 `Kernel.framework` 與 Swift 工具鏈）：
  ```bash
  xcode-select --install
  ```

## 一鍵建置與測試（無須 `sudo`）

在專案根目錄執行：

```bash
chmod +x scripts/*.sh install.sh
./scripts/build.sh
```

或使用 `Makefile`：

```bash
make build      # 編譯 Kext、CLI 與 App 至 dist/
make test       # 執行 SpoofMacCore XCTest 單元測試
make kext-check # 驗證 Mach-O 架構、KPI 相依性與簽章完整性
make release    # 建置並打包 .dmg、.zip、SHA256SUMS.txt 與 RELEASE_NOTES.md 至 release/
```

建置完成後，產物位於 `dist/` 與 `release/`：

- `dist/SpoofMac.kext`：arm64e 核心擴展（同步複製一份至專案根目錄 `SpoofMac.kext`）
- `dist/spoofmac`：arm64 CLI 命令列工具
- `dist/SpoofMacintosh.app`：獨立自包含 SwiftUI App（內嵌 `AppIcon.icns`、`icon.png`、`LICENSE`、`spoofmac`、`SpoofMac.kext`、`spoofmac-boot.sh`、`com.spoofmacintosh.loader.plist` 與 `install.sh`）
- `release/SpoofMacintosh-v<VERSION>-macOS-arm64.dmg`：拖曳安裝磁碟映像檔
- `release/SpoofMacintosh-v<VERSION>-Full-Suite-arm64.zip`：完整套件壓縮包（含 Kext、CLI、安裝腳本與多語系文件）
- `release/SHA256SUMS.txt` & `release/RELEASE_NOTES.md`：SHA-256 校驗碼與發版說明

## 版本號管理與自動發佈 GitHub Release

專案根目錄的 [`VERSION`](VERSION) 為單一版本號來源。

### 1. 本機同步更新版本號

```bash
./scripts/bump-version.sh 1.0.1
# 或使用 Makefile：
make bump-version V=1.0.1
```

此腳本會自動同步更新：
- `VERSION`
- `Sources/SpoofMacCore/SpoofMacMetadata.swift`
- `Sources/SpoofMacintoshApp/Info.plist`
- `kext/src/Info.plist`

### 2. 本地預打包驗證 Release 產物

```bash
./scripts/package-release.sh
```

### 3. 推送 Git Tag 自動觸發 GitHub Actions 發版

本儲存庫已在 `.github/workflows/release.yml` 設定自動化發版工作流程（使用 `macos-15` Apple Silicon Runner）：

```bash
# 更新版本並提交後，打上 v* 格式標籤並推送
git tag v1.0.0
git push origin main --tags
```

推送 `v*` Tag（或於 GitHub Actions 網頁手動執行 **Release → Run workflow** 並輸入 `tag_name`）後，GitHub Actions 將自動：
1. 同步版本號至 `SpoofMacMetadata.swift` 與所有 `Info.plist`；
2. 執行 Shell 語法檢查與 `swift test`；
3. 編譯 `SpoofMac.kext`、`spoofmac` 與 `SpoofMacintosh.app` 並驗證 `codesign` 與 KPI 相依性；
4. 打包 `.dmg`、Full-Suite `.zip` 與 `SHA256SUMS.txt`；
5. 自動建立並發佈 **GitHub Release**，附上產生之發行說明與可下載檔案。

## 重新產生 App 圖示（選用）

App 圖示由 SwiftUI 原生向量繪圖腳本（Mac + 影子效果）直接繪製生成。若調整了圖示樣式，可執行：

```bash
swift scripts/make_icns.swift
```

## 手動建置細節

### 1. 編譯 `SpoofMac.kext`

```bash
SDK="$(xcrun --sdk macosx --show-sdk-path)"
KH="$SDK/System/Library/Frameworks/Kernel.framework/Headers"
mkdir -p dist/SpoofMac.kext/Contents/MacOS dist/.tmp

xcrun clang++ -arch arm64e -isysroot "$SDK" -I"$KH" \
  -DKERNEL -DKERNEL_PRIVATE -DDRIVER_PRIVATE -DAPPLE -DNeXT \
  -fno-builtin -fno-common -fapple-kext -mkernel \
  -std=c++17 -fno-rtti -fno-exceptions -fno-stack-protector -O2 \
  -c kext/src/SpoofMac.cpp -o dist/.tmp/SpoofMac.o

xcrun clang -arch arm64e -isysroot "$SDK" -I"$KH" \
  -DKERNEL -DKERNEL_PRIVATE -DAPPLE \
  -fno-builtin -fno-common -mkernel -O2 \
  -c kext/src/kmod_info.c -o dist/.tmp/kmod_info.o

xcrun clang++ -arch arm64e -isysroot "$SDK" -nostdlib -fapple-kext \
  -Xlinker -kext -lkmod -lkmodc++ -lcc_kext \
  -o dist/SpoofMac.kext/Contents/MacOS/SpoofMac \
  dist/.tmp/SpoofMac.o dist/.tmp/kmod_info.o

cp kext/src/Info.plist dist/SpoofMac.kext/Contents/Info.plist
kmutil libraries --arch arm64e --sdk "$SDK" -p dist/SpoofMac.kext
codesign -f -s - dist/SpoofMac.kext
```

> **簽章說明**：預設使用 ad-hoc 簽章（`codesign -s -`），因此需在恢復模式關閉 kext 簽章檢查（`csrutil enable --without kext`）與啟用第三方核心擴展管理。若您擁有 Apple Developer ID（含 Kernel Extension 權限），可將 `-s -` 替換為您的簽章憑證並在 Reduced Security 下使用。

### 2. 編譯 Swift CLI 與 SwiftUI App

`Package.swift` 明確指定 `platforms: [.macOS(.v14)]` 與 Swift 5.10 工具鏈相容模式，避免新版本 macOS SDK 編譯出的執行檔無法在 macOS 14 / 15 / 26 上啟動（`-10825` 錯誤）：

```bash
swift build -c release --arch arm64
```

---

**Powered by NyphexAI, Developed by Hikaru(i@rua.moe)** · Licensed under [PolyForm Noncommercial License 1.0.0](LICENSE)
