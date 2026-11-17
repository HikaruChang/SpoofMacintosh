<p align="center">
  <img src="../Assets/icon.png" width="136" height="136" alt="SpoofMacintosh Icon" />
</p>

<h1 align="center">SpoofMacintosh</h1>
<p align="center"><strong>Apple Silicon 全モデル対応・動的機種／地域偽装アンロックツール</strong></p>
<p align="center">Powered by NyphexAI, Developed by Hikaru(<a href="mailto:i@rua.moe">i@rua.moe</a>)</p>

<p align="center">
  <img src="https://img.shields.io/badge/Platform-macOS%2014%2B%20%C2%B7%20Apple%20Silicon-007AFF?style=flat-square" alt="Platform" />
  <img src="https://img.shields.io/badge/Apple%20Silicon-M1%20%E2%80%93%20M6%20(59%20Presets)-34C759?style=flat-square" alt="Chipset" />
  <img src="https://img.shields.io/badge/License-PolyForm%20Noncommercial%201.0.0-orange?style=flat-square" alt="License" />
</p>

<p align="center">
  <a href="../README.md">繁體中文</a> |
  <a href="README_ZH-CN.md">简体中文</a> |
  <a href="README_EN.md">English</a> |
  <strong>日本語</strong>
</p>

---

**SpoofMacintosh** は、**Apple Silicon Mac（M1 2020 〜 最新 M5 / M6 2026）** 向けに独自設計・開発されたネイティブ SwiftUI GUI アプリ、CLI (`spoofmac`)、および動的 IOKit カーネル拡張 (`SpoofMac.kext`) スイートです。

ルートノード `IOPlatformExpertDevice` 上で動作し、`region-info` を米国版 `LL/A` に偽装して Apple Intelligence や地域制限機能を解放するだけでなく、**実行時に再コンパイルや再起動なしでモデル識別子、販売型番 (Model Number)、規制モデル番号 (A-Number)、ハードウェアターゲット、SoC プラットフォーム名、シリアル番号／UUID／MLB、任意のカスタム IORegistry プロパティを動的に変更し、ワンクリックで出荷時設定へ即座に復元**できます。

---

## 主な特徴

1. **M1〜M6 全世代 59機種のプリセット & 13地域コード収録**
   - **59種類**の公式 Apple Silicon Mac プリセット（M1 / M1 Pro / M1 Max / M1 Ultra、M2、M3、M4、M5 / MacBook Neo、M6 世代、`platform-name` 含む）を内蔵。
   - **13地域**の販売地域プリセット（米国 `LL/A`、台湾 `TA/A`、香港 `ZP/A`、日本 `J/A`、シンガポール `ZA/A`、韓国 `KH/A`、カナダ `C/A`、豪州 `X/A`、英国 `B/A`、スイス `FD/A`、ドイツ `ZD/A`、フランス `FN/A`、中国本土 `CH/A`）。

2. **全フィールドの動的偽装と無損失リセット（SN / UUID / MLB / 任意プロパティ対応）**
   - 初回変更前に出荷時データを `spoofmac-originals`（および非特権読み取り用の `orig-*`）へ自動バックアップ。`reset` またはアンインストール時に 100% 復元します。
   - **`IOPlatformSerialNumber`（`serial-number` 自動同期）、`IOPlatformUUID`、`mlb-serial-number`**（正規形式のランダム生成機能付き）、`manufacturer`、`model-config`、`config-number`、`device_type`、`secure-root-prefix`、`name` に加え、`--set <key:type=value>` または GUI で任意のカスタムプロパティを動的に変更可能。

3. **シリアル番号 (SN / UUID / MLB) 変更に関する注意**
   - Apple Intelligence や iPhone ミラーリングの有効化のみが目的の場合は、「元の機種を維持＋米国地域 (`LL/A`)」モードのまま純正シリアルを維持することを推奨します（Secure Enclave、iCloud、FaceTime、Private Cloud Compute の整合性を保つため）。

4. **全ドメイン `os_eligibility` 診断・強制再計算**
   - `GREYMATTER` (Apple Intelligence)、`IRON` (iPhone ミラーリング)、`XCODE_LLM`、`SIRI_WITH_APP_INTENTS`、`FOUNDATION_MODELS`、`PERSONAL_QA` 等の資格確認と、`eligibilityd` / `modelcatalogd` (`SIGKILL`) / `modelmanagerd` (`SIGTERM`) の再計算に対応。

5. **4言語ネイティブ対応（繁體中文／简体中文／English／日本語）**
   - ツールバーおよび CLI (`--lang <zh-hant|zh-hans|en|ja>`) から即時切り替え可能です。

---

## 前提条件（Apple Silicon リカバリ 1TR 設定）

ad-hoc 署名済み Kext を読み込むため、**macOS リカバリ (1TR)** にて以下の **2ステップをこの順番で** 実行してください：

1. Mac を **システム終了** → 電源ボタンを **長押し** して「オプション」からリカバリを起動。
2. メニューバーの **「ユーティリティ → 起動セキュリティユーティリティ」** を開く：
   - 起動ディスクを選択 → **「セキュリティポリシー…」**
   - **「低セキュリティ (Reduced Security)」** を選択し、**「確認済みの開発元から提供されたカーネル機能拡張のユーザ管理を許可」** にチェック → **「OK」**。
3. **【同じリカバリセッション内で、ステップ2の後に実行】** **「ユーティリティ → ターミナル」** を開き、以下を実行：
   ```bash
   csrutil enable --without kext
   ```
   > ステップ2でセキュリティポリシーを変更すると SIP 設定がリセットされるため、必ずステップ2の後に実行してください（非対応 OS の場合のみ `csrutil disable` を使用）。
4. `reboot` を入力して再起動。
5. `nvram boot-args` に `amfi_get_out_of_my_way=1` が含まれていないことを確認してください（Private Cloud Compute が破損するため、`install.sh` が自動除去します）。

> **プラットフォーム上の制限**：低セキュリティ＋サードパーティ Kext を有効化すると、ローカル起動ポリシーが Permissive モードとなり、Apple Silicon 仕様上 iPhone / iPad アプリ（iOS Apps on Mac）は起動できなくなります。

---

## GitHub Releases からのダウンロードと導入

**GitHub Releases** から Apple Silicon (`arm64`) ビルドを選択してダウンロードしてください（`SHA256SUMS.txt` 付属）：

1. **`SpoofMacintosh-v<version>-macOS-arm64.dmg`**（GUI ユーザー向け推奨）
   - `SpoofMacintosh.app` を `/Applications` にドラッグ＆ドロップします。
   - ad-hoc 署名のため、初回起動前にダウンロード隔離属性を削除してください：
     ```bash
     xattr -cr /Applications/SpoofMacintosh.app
     ```
   - アプリを起動し、「導入・リカバリ」タブの **「Kext と起動サービスを導入／更新」** をクリックした後、**「システム設定 → プライバシーとセキュリティ」** 下部で `com.spoofmacintosh.SpoofMac` を **「許可」** して再起動してください（初回 AuxKC 構築時は 2 回の再起動が必要な場合があります）。

2. **`SpoofMacintosh-v<version>-Full-Suite-arm64.zip`**（CLI / 一括導入向け）
   ```bash
   xattr -cr .
   sudo ./install.sh install
   ```

---

## ソースからのビルド（詳細は [BUILD.md](../BUILD.md)）

```bash
./scripts/build.sh
sudo ./install.sh install
```

---

## CLI コマンド例

```bash
# バージョンと署名情報を表示
spoofmac --version

# 出荷時／現在のデバイス識別情報・Kext 状態・os_eligibility 一覧を表示
spoofmac status
spoofmac status --json

# 出力言語を即時指定
spoofmac --lang ja status

# M1〜M6 機種プリセットおよび地域一覧を表示
spoofmac list-models
spoofmac list-models --chip M5
spoofmac list-regions

# 元の機種を維持したまま米国版 (LL/A / USA) 地域のみ偽装
sudo spoofmac apply --keep-model --region LL/A

# 機種プリセットを MacBook Pro 16" (M5 Max, Mac17,6) 米国版に変更
sudo spoofmac apply --preset Mac17,6 --region LL/A

# SN / UUID / MLB を変更（またはランダム生成）
sudo spoofmac apply --preset Mac17,6 --region LL/A --random-serial --random-uuid --random-mlb

# 任意の IOPlatformExpertDevice プロパティを設定 (cstring/osstring/pad32/pad64/raw/hex)
sudo spoofmac apply --set "custom-prop:cstring=hello" --set "boot-flag:hex=01000000"

# 診断レポート出力（シリアル等は既定でマスク表示、--show-sensitive で平文表示）
spoofmac diagnose
spoofmac status --show-sensitive

# 即座に出荷時プロパティへ復元
sudo spoofmac reset

# os_eligibility および AI デーモンを強制再計算
sudo spoofmac refresh

# 完全アンインストールと出荷時設定への復元
sudo ./install.sh uninstall
```

---

## 緊急リカバリ (`boot-args`)

Kext をアンインストールせずに偽装機能のみを一時無効化する場合：

```bash
nvram boot-args="spoof_off=1"
```

---

## クレジット (Credits)

**Powered by NyphexAI, Developed by Hikaru(i@rua.moe)**

## ライセンス (License)

本プロジェクトは **[PolyForm Noncommercial License 1.0.0](../LICENSE)** の下で公開されています（クレジット表示必須・商用利用禁止）：

* **著作権およびクレジット表示義務**：複製・改変・再配布を行う場合は、ライセンス全文および以下の表記を必ず保持してください：
  `Required Notice: Copyright (c) 2026 Hikaru (i@rua.moe). Powered by NyphexAI, Developed by Hikaru(i@rua.moe)`
* **非商用限定**：個人の研究・実験・教育・非営利団体など非商用目的でのみ利用可能です。商用販売、有償での導入・改変代行、商用製品への組み込み等は禁止されています。
* 商用ライセンスのお問い合わせ：`i@rua.moe`
