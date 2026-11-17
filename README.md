<p align="center">
  <img src="Assets/icon.png" width="136" height="136" alt="SpoofMacintosh Icon" />
</p>

<h1 align="center">SpoofMacintosh</h1>
<p align="center"><strong>Apple Silicon 全系列 Mac 機型與地區動態偽裝解鎖工具</strong></p>
<p align="center">Powered by NyphexAI, Developed by Hikaru(<a href="mailto:i@rua.moe">i@rua.moe</a>)</p>

<p align="center">
  <img src="https://img.shields.io/badge/Platform-macOS%2014%2B%20%C2%B7%20Apple%20Silicon-007AFF?style=flat-square" alt="Platform" />
  <img src="https://img.shields.io/badge/Apple%20Silicon-M1%20%E2%80%93%20M6%20(59%20Presets)-34C759?style=flat-square" alt="Chipset" />
  <img src="https://img.shields.io/badge/License-PolyForm%20Noncommercial%201.0.0-orange?style=flat-square" alt="License" />
</p>

<p align="center">
  <strong>繁體中文</strong> |
  <a href="docs/README_ZH-CN.md">简体中文</a> |
  <a href="docs/README_EN.md">English</a> |
  <a href="docs/README_JA.md">日本語</a>
</p>

---

**SpoofMacintosh** 是一套專為 **Apple Silicon Mac（M1 2020 至最新 M5 / M6 2026）** 獨立設計與開發的原生 SwiftUI 圖形介面工具、CLI 命令列與動態核心擴展系統。

透過極簡的 `SpoofMac.kext` 在裝置樹（`IOPlatformExpertDevice`）源頭運作，不僅能將 `region-info` 偽裝為美版 `LL/A` 以解鎖 Apple Intelligence 與各項受地區限制之功能，更支援**執行期免重編、免重啟、動態修改整套 Mac 機型識別碼、銷售型號（Model Number）、監管型號（A-Number）、硬體板號、序號／UUID／MLB 與任意自訂裝置樹屬性**，並提供一鍵即時還原出廠設定的能力。

---

## 核心特色

1. **從 M1 到最新 Mac（M1–M6）全收錄預設庫**
   - 內建 **59 款** Apple Silicon 官方 Mac 機型預設（涵蓋 M1 / M1 Pro / M1 Max / M1 Ultra、M2 系列、M3 系列、M4 系列、M5 / MacBook Neo 與最新 M6 世代，含對應 SoC `platform-name`）。
   - 提供 **13 大銷售地區預設**（美國 `LL/A`、台灣 `TA/A`、香港 `ZP/A`、日本 `J/A`、新加坡 `ZA/A`、韓國 `KH/A`、加拿大 `C/A`、澳洲 `X/A`、英國 `B/A`、瑞士 `FD/A`、德國 `ZD/A`、法國 `FN/A`、中國大陸 `CH/A`）。
   - 下拉選單選取後自動連動填入對應屬性，亦可任意自訂 `model`、`model-number`、`region-info`、`regulatory-model-number`、`target-type`、`target-sub-type`、`country-of-origin`、`platform-name` 及 `compatible`。

2. **全欄位動態修改與一鍵無損還原（含 SN / UUID / MLB / 任意自訂欄位）**
   - `SpoofMac.kext` 會在首次修改任何屬性前，自動將原廠值安全快照保存至 `spoofmac-originals`（並鏡像 `orig-*` 供未提權讀取），執行 `reset` 或卸載時 100% 還原至出廠狀態。
   - 支援在運行期動態修改 **`IOPlatformSerialNumber`（自動同步 `serial-number`）、`IOPlatformUUID`、`mlb-serial-number`**（GUI 與 CLI 均提供合法格式一鍵隨機生成），以及 `manufacturer`、`model-config`、`config-number`、`device_type`、`secure-root-prefix`、`name` 等全套裝置樹屬性，更可透過 `--set <key:type=value>` 或 GUI 編輯器覆寫 `IOPlatformExpertDevice` 上的**任意其他欄位**。
   - 所有修改皆透過 IOKit `IORegistryEntrySetCFProperties`（僅限 root 權限）即時寫入記憶體中的裝置樹，**免重編 Kext、免重新點選允許、免重開機**。

3. **關於修改序號（SN / UUID / MLB）之安全提醒**
   - 若僅為了解鎖 Apple Intelligence、iPhone 鏡像輸出等地區功能，建議使用預設的「保留原機機型 / 僅改地區」模式而不變動原廠序號，以維持 Apple Silicon Secure Enclave（SEP）憑證與 iCloud、FaceTime、PCC 私密雲端運算之完整相容性；如需於測試／隔離環境修改 SN / UUID / MLB，隨時可於本工具一鍵即時還原。

4. **全領域 `os_eligibility` 體檢與強制重算**
   - 支援檢視並重算 Apple Intelligence（`GREYMATTER`）、iPhone 鏡像輸出（`IRON`）、Xcode AI（`XCODE_LLM`）、新版 Siri（`SIRI_WITH_APP_INTENTS`）、`FOUNDATION_MODELS`、`PERSONAL_QA` 等多項系統資格，並正確處理 `modelcatalogd`（`SIGKILL`）與 `modelmanagerd`（`SIGTERM`）刷新順序。

5. **四國語言原生介面與 CLI 即時切換（繁體中文／简体中文／English／日本語）**
   - 支援自動偵測系統語言，亦可於 GUI 工具列語言選單或 CLI `--lang <zh-hant|zh-hans|en|ja>` 免重開機即時切換（適合為了啟用 Apple Intelligence 將系統語言設為英文、但仍想以中文或日文操作工具的使用者）。

---

## 前置條件（Apple Silicon 恢復模式 1TR 設定）

因為 macOS 預設封鎖未經 Apple 公證的第三方核心擴展（ad-hoc 簽章 Kext），首次使用必須在 **恢復模式 (1TR)** 開啟兩道安全閘門，**以下兩步驟順序不可顛倒**：

1. **關機** → **長按電源鍵**，直到出現「正在載入啟動選項 / Loading startup options」→ 選擇「選項 (Options)」進入恢復模式。
2. 頂部選單欄打開 **「實用工具 → 啟動安全性實用工具」**：
   - 選擇目前系統磁碟 → 點選 **「安全策略…」**
   - 選擇 **「降低安全性 (Reduced Security)」**，並勾選 **「允許使用者管理來自已識別開發者的核心擴展」** → 按「好」。
3. **【同一次恢復模式內，在執行第 2 步之後】** 打開頂部選單 **「實用工具 → 終端機」**，輸入：
   ```bash
   csrutil enable --without kext
   ```
   > 第 2 步調整安全策略會重設 SIP 狀態，因此本指令必須在「啟動安全性實用工具」設定完成之後執行。若該系統版本拒絕此參數，才改用 `csrutil disable`。
4. 輸入 `reboot` 重新開機。
5. 確保 `nvram boot-args` **不包含** `amfi_get_out_of_my_way=1`（安裝腳本會自動偵測並移除；該參數會破壞 PCC 私密雲端運算）。

> **已知系統限制提醒**：開啟第三方 Kext 並關閉 kext 簽章驗證後，本地開機安全性策略會進入 Permissive 模式，iPhone / iPad App（iOS Apps on Mac）在此狀態下將無法於 Mac 上開啟，此為 Apple Silicon 平台政策限制。

---

## 從 GitHub Releases 下載安裝

前往本專案的 **GitHub Releases** 頁面，依據使用方式選擇以下任一發行包（皆為 Apple Silicon `arm64` 原生建置並附 `SHA256SUMS.txt` 校驗檔）：

1. **`SpoofMacintosh-v<版本>-macOS-arm64.dmg`**（推薦一般使用者）
   - 打開 `.dmg` 後將 `SpoofMacintosh.app` 拖入 `/Applications`（App 內部已完整內嵌 `SpoofMac.kext`、`spoofmac` CLI 與安裝精靈）。
   - 由於釋出版採用 ad-hoc 簽章，首次從網路下載打開若遇到 Gatekeeper 提示「無法驗證開發者」或「已損毀」，請在終端機執行：
     ```bash
     xattr -cr /Applications/SpoofMacintosh.app
     ```
   - 啟動 `SpoofMacintosh.app` 後，切換至「安裝與恢復指南」分頁點擊 **「安裝 / 更新 Kext 與開機服務」**，並前往 **「系統設定 → 隱私與安全性」** 底部點擊 **「允許 / Allow」** 核准 `com.spoofmacintosh.SpoofMac`，隨後依指示重開機（首次重建 AuxKC 可能需要重開機兩次）。

2. **`SpoofMacintosh-v<版本>-Full-Suite-arm64.zip`**（推薦 CLI / 自動化部署）
   - 解壓後直接包含 `SpoofMacintosh.app`、`SpoofMac.kext`、`spoofmac`、`install.sh`、開機 LaunchDaemon 腳本及多語言說明文件：
     ```bash
     xattr -cr .
     sudo ./install.sh install
     ```

---

## 從原始碼建置與安裝（詳見 [BUILD.md](BUILD.md)）

```bash
./scripts/build.sh
```

建置結果產出於 `dist/`：
- `dist/SpoofMacintosh.app`
- `dist/spoofmac`
- `dist/SpoofMac.kext`

接著執行安裝：

```bash
sudo ./install.sh install
```

---

## CLI 命令列用法

安裝後可直接使用 `spoofmac`（未全域安裝時亦可使用 `./dist/spoofmac`）：

```bash
# 查看版本與署名資訊
spoofmac --version

# 查看原廠與目前生效的硬體識別、Kext 狀態與全部 os_eligibility 資格
spoofmac status
spoofmac status --json

# 指定顯示語言（繁體中文 / 简体中文 / English / 日本語）
spoofmac --lang en status

# 瀏覽 M1 至 M6 全部預設機型與地區預設庫
spoofmac list-models
spoofmac list-models --chip M5
spoofmac list-regions

# 保留原機型號，僅切換為美版 (LL/A / USA) 解鎖全部功能
sudo spoofmac apply --keep-model --region LL/A

# 動態切換整套機型預設為 MacBook Pro 16" (M5 Max, Mac17,6) 美版
sudo spoofmac apply --preset Mac17,6 --region LL/A

# 自訂序號 (SN)、UUID、MLB（或使用隨機生成）
sudo spoofmac apply --preset Mac17,6 --region LL/A --random-serial --random-uuid --random-mlb

# 任意覆寫 IOPlatformExpertDevice 其他欄位（支援 cstring/osstring/pad32/pad64/raw/hex）
sudo spoofmac apply --set "custom-prop:cstring=hello" --set "boot-flag:hex=01000000"

# 檢視完整診斷報告（預設遮罩 SN/UUID/MLB；加上 --show-sensitive 顯示明文）
spoofmac diagnose
spoofmac status --show-sensitive

# 立即還原為出廠原始硬體屬性（免重開機即時生效）
sudo spoofmac reset

# 強制重算 os_eligibility 與 AI 模型守護程序
sudo spoofmac refresh

# 完整卸載並恢復出廠硬體識別
sudo ./install.sh uninstall
```

---

## 專案結構

```text
SpoofMacintosh/
├── kext/src/                  # SpoofMac.kext (arm64e IOKit 動態偽裝核心擴展)
├── Sources/
│   ├── SpoofMacCore/          # 共用核心庫（IOKit 橋接、機型與地區預設、多語系、診斷與提權）
│   ├── spoofmac/              # 命令列工具 (spoofmac)
│   └── SpoofMacintoshApp/     # 原生 SwiftUI 圖形介面應用程式
├── Tests/SpoofMacCoreTests/   # XCTest 單元測試
├── scripts/                   # 建置 (build.sh)、圖示繪製、版本同步、Release 打包與開機載入腳本
├── docs/                      # 多語言 README（簡體中文 / English / 日本語）
├── .github/workflows/         # GitHub Actions 自動建置測試 (CI) 與自動發版 (Release)
├── install.sh                 # 一鍵安裝 / 管理 / 診斷 / 卸載腳本
└── BUILD.md                   # 完整建置與發版指南
```

---

## 緊急復原參數 (`boot-args`)

若需要暫時關閉偽裝但保留 Kext，可在恢復模式終端機設定：

```bash
nvram boot-args="spoof_off=1"
```

亦可透過 `boot-args` 在開機時預先覆寫特定屬性進行測試，例如：
`spoof_model`、`spoof_mnum`、`spoof_region`、`spoof_regnum`、`spoof_target`、`spoof_subtarget`、`spoof_country`。

---

## 開發團隊與署名 (Credits)

**Powered by NyphexAI, Developed by Hikaru(i@rua.moe)**

## 授權條款 (License)

本專案採用 **[PolyForm Noncommercial License 1.0.0](LICENSE)** 授權條款釋出（嚴格要求署名且不得用於商業用途）：

* **強制保留署名**：任何複製、重製、修改或分發本軟體及其衍生作品，皆必須完整保留授權檔案與以下聲明：
  `Required Notice: Copyright (c) 2026 Hikaru (i@rua.moe). Powered by NyphexAI, Developed by Hikaru(i@rua.moe)`
* **禁止商業用途**：本軟體僅授權予個人研究、實驗、測試、教育、非營利機構與非商業用途使用；**嚴禁任何形式的商業販售、付費代客安裝／代改機型、商業打包分發或作為商業產品／服務的一部分**。
* 若有商業授權需求，請聯繫：`i@rua.moe`。
