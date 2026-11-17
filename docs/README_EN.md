<p align="center">
  <img src="../Assets/icon.png" width="136" height="136" alt="SpoofMacintosh Icon" />
</p>

<h1 align="center">SpoofMacintosh</h1>
<p align="center"><strong>Dynamic Model, Region &amp; Full IORegistry Spoofing Suite for Apple Silicon Macs</strong></p>
<p align="center">Powered by NyphexAI, Developed by Hikaru(<a href="mailto:i@rua.moe">i@rua.moe</a>)</p>

<p align="center">
  <img src="https://img.shields.io/badge/Platform-macOS%2014%2B%20%C2%B7%20Apple%20Silicon-007AFF?style=flat-square" alt="Platform" />
  <img src="https://img.shields.io/badge/Apple%20Silicon-M1%20%E2%80%93%20M6%20(59%20Presets)-34C759?style=flat-square" alt="Chipset" />
  <img src="https://img.shields.io/badge/License-PolyForm%20Noncommercial%201.0.0-orange?style=flat-square" alt="License" />
</p>

<p align="center">
  <a href="../README.md">繁體中文</a> |
  <a href="README_ZH-CN.md">简体中文</a> |
  <strong>English</strong> |
  <a href="README_JA.md">日本語</a>
</p>

---

**SpoofMacintosh** is an independently engineered native SwiftUI GUI application, CLI tool (`spoofmac`), and minimal `arm64e` IOKit kernel extension (`SpoofMac.kext`) built for **Apple Silicon Macs (M1 2020 through latest M5 / M6 2026)**.

Operating directly at the root `IOPlatformExpertDevice` device-tree node, SpoofMacintosh can dynamically spoof `region-info` (e.g. `LL/A` / `USA`) to unlock Apple Intelligence and region-gated features, as well as hot-swap **Mac model identifiers, sales model numbers, regulatory A-numbers, board target types, SoC platform names, serial numbers / UUIDs / MLBs, and arbitrary custom `IOPlatformExpertDevice` keys at runtime** — with zero kext recompilation, zero reboot needed after loading, and instant live factory restoration.

---

## Key Features

1. **Full M1–M6 Catalog & 13 Global Region Presets**
   - Built-in catalog of **59 official Apple Silicon Mac presets** spanning M1 / M1 Pro / M1 Max / M1 Ultra, M2, M3, M4, M5 / MacBook Neo, and M6 generations (including SoC `platform-name`).
   - **13 global region presets** (`LL/A` US, `TA/A` Taiwan, `ZP/A` Hong Kong, `J/A` Japan, `ZA/A` Singapore, `KH/A` Korea, `C/A` Canada, `X/A` Australia, `B/A` UK, `FD/A` Switzerland, `ZD/A` Germany, `FN/A` France, `CH/A` Mainland China).
   - Fully customizable fields for `model`, `model-number`, `region-info`, `regulatory-model-number`, `target-type`, `target-sub-type`, `country-of-origin`, `platform-name`, and `compatible`.

2. **Full-Property Runtime Spoofing & Lossless Factory Restore**
   - Before mutating any property, `SpoofMac.kext` automatically captures factory values in `spoofmac-originals` (plus unprivileged `orig-*` mirrors) so `reset` or uninstall restores 100% of original properties immediately.
   - Supports dynamic updates to **`IOPlatformSerialNumber` (auto-syncing `serial-number`), `IOPlatformUUID`, `mlb-serial-number`** (with valid-format random generators in both GUI and CLI), `manufacturer`, `model-config`, `config-number`, `device_type`, `secure-root-prefix`, `name`, and **any arbitrary `IOPlatformExpertDevice` property** via `--set <key:type=value>` (`cstring`, `osstring`, `pad32`, `pad64`, `raw`, `hex`).
   - All live updates use root-only `IORegistryEntrySetCFProperties`.

3. **Safety Notice on Modifying SN / UUID / MLB**
   - If your sole goal is unlocking Apple Intelligence, iPhone Mirroring, or region-restricted features, keep your factory serial/UUID/MLB untouched via **Keep Native Model + US (`LL/A`) Region** mode so Secure Enclave (SEP), iCloud, FaceTime, and Private Cloud Compute (PCC) credentials remain intact.

4. **Multi-Domain `os_eligibility` Inspector & Refresh**
   - Checks and refreshes `GREYMATTER` (Apple Intelligence), `IRON` (iPhone Mirroring), `XCODE_LLM`, `SIRI_WITH_APP_INTENTS`, `FOUNDATION_MODELS`, `PERSONAL_QA`, and more, handling `eligibilityd`, `modelcatalogd` (`SIGKILL`), and `modelmanagerd` (`SIGTERM`) in the proper sequence.

5. **4-Language Native UI & CLI (`繁體中文` / `简体中文` / `English` / `日本語`)**
   - Instant in-app toolbar switcher and CLI `--lang <zh-hant|zh-hans|en|ja>` override (ideal when macOS system language is set to English for Apple Intelligence while operating the tool in Chinese or Japanese).

---

## Prerequisites (Apple Silicon Recovery 1TR Setup)

Because macOS blocks ad-hoc signed third-party kernel extensions by default, you must enable two security gates in **macOS Recovery (1TR)** in the **exact order below**:

1. **Shut down** your Mac → **Press and hold the power button** until "Loading startup options" appears → select **Options**.
2. Open **Utilities → Startup Security Utility**:
   - Select your startup disk → **Security Policy…**
   - Choose **Reduced Security** and check **"Allow user management of kernel extensions from identified developers"** → click **OK**.
3. **[In the same Recovery session, AFTER step 2]** Open **Utilities → Terminal** and run:
   ```bash
   csrutil enable --without kext
   ```
   > Startup Security Utility resets SIP policy, so this command must run *after* step 2. Only fall back to `csrutil disable` if your macOS version rejects `--without kext`.
4. Run `reboot`.
5. Ensure `nvram boot-args` does **not** contain `amfi_get_out_of_my_way=1` (it breaks Private Cloud Compute; `install.sh` automatically cleans this up).

> **Platform Caveat**: Enabling Reduced Security + third-party kernel extensions places Local Boot Policy into Permissive mode, which prevents iPhone/iPad apps (iOS Apps on Mac) from launching on Apple Silicon due to Apple platform policy.

---

## Download & Install from GitHub Releases

Grab either prebuilt Apple Silicon (`arm64`) package from **GitHub Releases** (both verified via `SHA256SUMS.txt`):

1. **`SpoofMacintosh-v<version>-macOS-arm64.dmg`** (Recommended for GUI users)
   - Drag `SpoofMacintosh.app` into `/Applications` (it bundles `SpoofMac.kext`, `spoofmac` CLI, and `install.sh` inside its resources).
   - Because releases are ad-hoc signed, clear the macOS Gatekeeper quarantine attribute after downloading:
     ```bash
     xattr -cr /Applications/SpoofMacintosh.app
     ```
   - Open `SpoofMacintosh.app`, go to **Setup & 1TR**, and click **Install / Update Kext & Boot Service**. Approve `com.spoofmacintosh.SpoofMac` in **System Settings → Privacy & Security** and reboot as prompted (first AuxKC build may require two reboots).

2. **`SpoofMacintosh-v<version>-Full-Suite-arm64.zip`** (Recommended for CLI / Terminal setup)
   ```bash
   xattr -cr .
   sudo ./install.sh install
   ```

---

## Build from Source (see [BUILD.md](../BUILD.md))

```bash
./scripts/build.sh
sudo ./install.sh install
```

---

## CLI Usage

```bash
# Show version & attribution
spoofmac --version

# Inspect factory vs current hardware identity, Kext state, and all os_eligibility domains
spoofmac status
spoofmac status --json

# Switch output language dynamically
spoofmac --lang en status

# Browse M1-M6 model presets and region catalog
spoofmac list-models
spoofmac list-models --chip M5
spoofmac list-regions

# Keep native model and spoof region to US (LL/A)
sudo spoofmac apply --keep-model --region LL/A

# Spoof full model preset to MacBook Pro 16" (M5 Max, Mac17,6) US region
sudo spoofmac apply --preset Mac17,6 --region LL/A

# Customize SN / UUID / MLB (or generate valid-format random values)
sudo spoofmac apply --preset Mac17,6 --region LL/A --random-serial --random-uuid --random-mlb

# Set arbitrary IOPlatformExpertDevice properties (cstring/osstring/pad32/pad64/raw/hex)
sudo spoofmac apply --set "custom-prop:cstring=hello" --set "boot-flag:hex=01000000"

# Generate plain-text diagnostic report (redacted by default; pass --show-sensitive for full IDs)
spoofmac diagnose
spoofmac status --show-sensitive

# Instantly restore factory properties at runtime
sudo spoofmac reset

# Force os_eligibility & AI daemon recalculation
sudo spoofmac refresh

# Uninstall completely and restore factory identity
sudo ./install.sh uninstall
```

---

## Emergency Recovery (`boot-args`)

To temporarily disable spoofing at boot without uninstalling the kext, set in Recovery Terminal:

```bash
nvram boot-args="spoof_off=1"
```

Boot-time test overrides supported: `spoof_model`, `spoof_mnum`, `spoof_region`, `spoof_regnum`, `spoof_target`, `spoof_subtarget`, `spoof_country`.

---

## Credits

**Powered by NyphexAI, Developed by Hikaru(i@rua.moe)**

## License

Licensed under the **[PolyForm Noncommercial License 1.0.0](../LICENSE)** (attribution required; commercial use strictly prohibited):

* **Attribution Required**: Any copy, modification, or redistribution must preserve the license and notice:
  `Required Notice: Copyright (c) 2026 Hikaru (i@rua.moe). Powered by NyphexAI, Developed by Hikaru(i@rua.moe)`
* **Noncommercial Only**: Permitted for personal research, testing, education, and noncommercial organizations only. Commercial sale, paid installation/spoofing services, or bundling into commercial products is prohibited.
* Commercial licensing inquiries: `i@rua.moe`.
