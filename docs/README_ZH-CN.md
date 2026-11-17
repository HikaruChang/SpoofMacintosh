<p align="center">
  <img src="../Assets/icon.png" width="136" height="136" alt="SpoofMacintosh Icon" />
</p>

<h1 align="center">SpoofMacintosh</h1>
<p align="center"><strong>Apple Silicon 全系列 Mac 机型与地区动态伪装解锁工具</strong></p>
<p align="center">Powered by NyphexAI, Developed by Hikaru(<a href="mailto:i@rua.moe">i@rua.moe</a>)</p>

<p align="center">
  <img src="https://img.shields.io/badge/Platform-macOS%2014%2B%20%C2%B7%20Apple%20Silicon-007AFF?style=flat-square" alt="Platform" />
  <img src="https://img.shields.io/badge/Apple%20Silicon-M1%20%E2%80%93%20M6%20(59%20Presets)-34C759?style=flat-square" alt="Chipset" />
  <img src="https://img.shields.io/badge/License-PolyForm%20Noncommercial%201.0.0-orange?style=flat-square" alt="License" />
</p>

<p align="center">
  <a href="../README.md">繁體中文</a> |
  <strong>简体中文</strong> |
  <a href="README_EN.md">English</a> |
  <a href="README_JA.md">日本語</a>
</p>

---

**SpoofMacintosh** 是一套专为 **Apple Silicon Mac（M1 2020 至最新 M5 / M6 2026）** 独立设计与开发的原生 SwiftUI 图形界面工具、CLI 命令行与动态内核扩展系统。

通过极简的 `SpoofMac.kext` 在设备树（`IOPlatformExpertDevice`）源头运作，不仅能将 `region-info` 伪装为美版 `LL/A` 以解锁 Apple Intelligence 与各项受地区限制的功能，更支持**运行期免重编、免重启、动态修改整套 Mac 机型识别码、销售型号（Model Number）、监管型号（A-Number）、硬件板号、序列号／UUID／MLB 与任意自定义设备树属性**，并提供一键即时还原出厂设置的能力。

---

## 核心特色

1. **从 M1 到最新 Mac（M1–M6）全收录预设库**
   - 内置 **59 款** Apple Silicon 官方 Mac 机型预设（涵盖 M1 / M1 Pro / M1 Max / M1 Ultra、M2 系列、M3 系列、M4 系列、M5 / MacBook Neo 与最新 M6 世代，含对应 SoC `platform-name`）。
   - 提供 **13 大销售地区预设**（美国 `LL/A`、台湾 `TA/A`、香港 `ZP/A`、日本 `J/A`、新加坡 `ZA/A`、韩国 `KH/A`、加拿大 `C/A`、澳洲 `X/A`、英国 `B/A`、瑞士 `FD/A`、德国 `ZD/A`、法国 `FN/A`、中国大陆 `CH/A`）。
   - 下拉菜单选取后自动联动填入对应属性，亦可任意自定义 `model`、`model-number`、`region-info`、`regulatory-model-number`、`target-type`、`target-sub-type`、`country-of-origin`、`platform-name` 及 `compatible`。

2. **全字段动态修改与一键无损还原（含 SN / UUID / MLB / 任意自定义字段）**
   - `SpoofMac.kext` 会在首次修改任何属性前，自动将原厂值安全快照保存至 `spoofmac-originals`（并镜像 `orig-*` 供未提权读取），执行 `reset` 或卸载时 100% 还原至出厂状态。
   - 支持在运行期动态修改 **`IOPlatformSerialNumber`（自动同步 `serial-number`）、`IOPlatformUUID`、`mlb-serial-number`**（GUI 与 CLI 均提供合法格式一键随机生成），以及 `manufacturer`、`model-config`、`config-number`、`device_type`、`secure-root-prefix`、`name` 等全套设备树属性，更可通过 `--set <key:type=value>` 或 GUI 编辑器覆写 `IOPlatformExpertDevice` 上的**任意其他字段**。
   - 所有修改均通过 IOKit `IORegistryEntrySetCFProperties`（仅限 root 权限）即时写入内存中的设备树，**免重编 Kext、免重新点击允许、免重启**。

3. **关于修改序列号（SN / UUID / MLB）的安全提醒**
   - 若仅为解锁 Apple Intelligence、iPhone 镜像输出等地区功能，建议使用默认的「保留原机机型 / 仅改地区」模式而不变动原厂序列号，以维持 Apple Silicon Secure Enclave（SEP）凭证与 iCloud、FaceTime、PCC 私密云计算的完整兼容性；如需在测试／隔离环境修改 SN / UUID / MLB，随时可在本工具中一键即时还原。

4. **全领域 `os_eligibility` 体检与强制重算**
   - 支持查看并重算 Apple Intelligence（`GREYMATTER`）、iPhone 镜像输出（`IRON`）、Xcode AI（`XCODE_LLM`）、新版 Siri（`SIRI_WITH_APP_INTENTS`）、`FOUNDATION_MODELS`、`PERSONAL_QA` 等多项系统资格，并正确处理 `modelcatalogd`（`SIGKILL`）与 `modelmanagerd`（`SIGTERM`）刷新顺序。

5. **四国语言原生界面与 CLI 即时切换（繁體中文／简体中文／English／日本語）**
   - 支持自动检测系统语言，亦可在 GUI 工具栏语言菜单或 CLI `--lang <zh-hant|zh-hans|en|ja>` 免重启即时切换（适合为了启用 Apple Intelligence 将系统语言设为英文、但仍想以中文或日文操作工具的用户）。

---

## 前置条件（Apple Silicon 恢复模式 1TR 设置）

由于 macOS 默认封锁未经 Apple 公证的第三方内核扩展（ad-hoc 签名 Kext），首次使用必须在 **恢复模式 (1TR)** 开启两道安全闸门，**以下两步骤顺序不可颠倒**：

1. **关机** → **长按电源键**，直到出现「正在载入启动选项 / Loading startup options」→ 选择「选项 (Options)」进入恢复模式。
2. 顶部菜单栏打开 **「实用工具 → 启动安全性实用工具」**：
   - 选择当前系统磁盘 → 点击 **「安全策略…」**
   - 选择 **「降低安全性 (Reduced Security)」**，并勾选 **「允许用户管理来自已识别开发者的内核扩展」** → 按「好」。
3. **【同一次恢复模式内，在执行第 2 步之后】** 打开顶部菜单 **「实用工具 → 终端」**，输入：
   ```bash
   csrutil enable --without kext
   ```
   > 第 2 步调整安全策略会重置 SIP 状态，因此本命令必须在「启动安全性实用工具」设置完成之后执行。若该系统版本拒绝此参数，才改用 `csrutil disable`。
4. 输入 `reboot` 重新启动。
5. 确保 `nvram boot-args` **不包含** `amfi_get_out_of_my_way=1`（安装脚本会自动检测并移除；该参数会破坏 PCC 私密云计算）。

> **已知系统限制提醒**：开启第三方 Kext 并关闭 kext 签名验证后，本地开机安全性策略会进入 Permissive 模式，iPhone / iPad App（iOS Apps on Mac）在此状态下将无法在 Mac 上开启，此为 Apple Silicon 平台策略限制。

---

## 从 GitHub Releases 下载安装

前往本项目的 **GitHub Releases** 页面，根据使用方式选择以下任一发行包（均为 Apple Silicon `arm64` 原生构建并附 `SHA256SUMS.txt` 校验文件）：

1. **`SpoofMacintosh-v<版本>-macOS-arm64.dmg`**（推荐一般用户）
   - 打开 `.dmg` 后将 `SpoofMacintosh.app` 拖入 `/Applications`（App 内部已完整内嵌 `SpoofMac.kext`、`spoofmac` CLI 与安装向导）。
   - 由于发布版采用 ad-hoc 签名，首次从网络下载打开若遇到 Gatekeeper 提示「无法验证开发者」或「已损坏」，请在终端执行：
     ```bash
     xattr -cr /Applications/SpoofMacintosh.app
     ```
   - 启动 `SpoofMacintosh.app` 后，切换至「安装与恢复指南」标签页点击 **「安装 / 更新 Kext 与开机服务」**，并前往 **「系统设置 → 隐私与安全性」** 底部点击 **「允许 / Allow」** 批准 `com.spoofmacintosh.SpoofMac`，随后按提示重启（首次重建 AuxKC 可能需要重启两次）。

2. **`SpoofMacintosh-v<版本>-Full-Suite-arm64.zip`**（推荐 CLI / 自动化部署）
   - 解压后包含 `SpoofMacintosh.app`、`SpoofMac.kext`、`spoofmac`、`install.sh`、开机 LaunchDaemon 脚本及多语言文档：
     ```bash
     xattr -cr .
     sudo ./install.sh install
     ```

---

## 从源码构建与安装（详见 [BUILD.md](../BUILD.md)）

```bash
./scripts/build.sh
sudo ./install.sh install
```

---

## CLI 命令行用法

```bash
# 查看版本与署名信息
spoofmac --version

# 查看原厂与当前生效的硬件识别、Kext 状态与全部 os_eligibility 资格
spoofmac status
spoofmac status --json

# 指定显示语言（zh-hant / zh-hans / en / ja）
spoofmac --lang zh-hans status

# 浏览 M1 至 M6 全部预设机型与地区预设库
spoofmac list-models
spoofmac list-models --chip M5
spoofmac list-regions

# 保留原机型号，仅切换为美版 (LL/A / USA) 解锁全部功能
sudo spoofmac apply --keep-model --region LL/A

# 动态切换整套机型预设为 MacBook Pro 16" (M5 Max, Mac17,6) 美版
sudo spoofmac apply --preset Mac17,6 --region LL/A

# 自定义序列号 (SN)、UUID、MLB（或使用随机生成）
sudo spoofmac apply --preset Mac17,6 --region LL/A --random-serial --random-uuid --random-mlb

# 任意覆写 IOPlatformExpertDevice 其他字段（支持 cstring/osstring/pad32/pad64/raw/hex）
sudo spoofmac apply --set "custom-prop:cstring=hello" --set "boot-flag:hex=01000000"

# 查看完整诊断报告（默认遮罩 SN/UUID/MLB；加上 --show-sensitive 显示明文）
spoofmac diagnose
spoofmac status --show-sensitive

# 立即还原为出厂原始硬件属性（免重启即时生效）
sudo spoofmac reset

# 强制重算 os_eligibility 与 AI 模型守护进程
sudo spoofmac refresh

# 完整卸载并恢复出厂硬件识别
sudo ./install.sh uninstall
```

---

## 紧急恢复参数 (`boot-args`)

若需要暂时关闭伪装但保留 Kext，可在恢复模式终端设置：

```bash
nvram boot-args="spoof_off=1"
```

---

## 开发团队与署名 (Credits)

**Powered by NyphexAI, Developed by Hikaru(i@rua.moe)**

## 授权条款 (License)

本项目采用 **[PolyForm Noncommercial License 1.0.0](../LICENSE)** 授权条款发布（严格要求署名且不得用于商业用途）：

* **强制保留署名**：任何复制、重制、修改或分发本软件及其衍生作品，均必须完整保留授权文件与以下声明：
  `Required Notice: Copyright (c) 2026 Hikaru (i@rua.moe). Powered by NyphexAI, Developed by Hikaru(i@rua.moe)`
* **禁止商业用途**：本软件仅授权予个人研究、实验、测试、教育、非营利机构与非商业用途使用；**严禁任何形式的商业贩售、付费代客安装／代改机型、商业打包分发或作为商业产品／服务的一部分**。
* 如有商业授权需求，请联系：`i@rua.moe`。
