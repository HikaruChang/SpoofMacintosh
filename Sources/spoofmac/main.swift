// Powered by NyphexAI, Developed by Hikaru(i@rua.moe)
// Licensed under the PolyForm Noncommercial License 1.0.0

import Foundation
import SpoofMacCore

enum CLIError: LocalizedError {
    case usage(String)
    case rootRequired(String)
    case unknownPreset(String)
    case invalidChip(String)
    case runtimeFailure(String)

    var errorDescription: String? {
        switch self {
        case .usage(let msg): return msg
        case .rootRequired(let action): return "\(action)"
        case .unknownPreset(let id): return id
        case .invalidChip(let chip): return chip
        case .runtimeFailure(let msg): return msg
        }
    }

    func localizedMessage(in lang: EffectiveLanguage) -> String {
        switch self {
        case .usage(let msg):
            return msg
        case .rootRequired(let action):
            return L(lang,
                     zhHant: "\(action) 需要系統管理員權限，請改用 sudo spoofmac ...",
                     zhHans: "\(action) 需要系统管理员权限，请改用 sudo spoofmac ...",
                     en: "\(action) requires administrator privileges. Run with sudo spoofmac ...",
                     ja: "\(action) には管理者権限が必要です。sudo spoofmac ... を使用してください。")
        case .unknownPreset(let id):
            return L(lang,
                     zhHant: "找不到機型預設「\(id)」，請執行 spoofmac list-models 查看支援的識別碼。",
                     zhHans: "找不到机型预设「\(id)」，请执行 spoofmac list-models 查看支持的识别码。",
                     en: "Unknown Mac model preset '\(id)'. Run 'spoofmac list-models' to list supported identifiers.",
                     ja: "Macモデルプリセット「\(id)」が見つかりません。spoofmac list-models で一覧を確認してください。")
        case .invalidChip(let chip):
            return L(lang,
                     zhHant: "不支援的晶片世代「\(chip)」，可用值：M1, M2, M3, M4, M5, M6。",
                     zhHans: "不支持的芯片世代「\(chip)」，可用值：M1, M2, M3, M4, M5, M6。",
                     en: "Unsupported chip generation '\(chip)'. Allowed values: M1, M2, M3, M4, M5, M6.",
                     ja: "未対応のチップ世代「\(chip)」です。使用可能: M1, M2, M3, M4, M5, M6。")
        case .runtimeFailure(let msg):
            return msg
        }
    }
}

func extractLanguageAndCleanArgs(_ rawArgs: [String]) throws -> (EffectiveLanguage, [String]) {
    var lang = AppLanguage.system.resolved
    var cleaned: [String] = []
    var i = 0
    while i < rawArgs.count {
        let arg = rawArgs[i]
        if arg == "--lang" {
            guard i + 1 < rawArgs.count else {
                throw CLIError.usage("Missing value for --lang (expected: zh-hant | zh-hans | en | ja)")
            }
            let rawLang = rawArgs[i + 1]
            if rawLang.lowercased() == "system" {
                lang = AppLanguage.system.resolved
            } else if let parsed = AppLanguage.parseIdentifier(rawLang) {
                lang = parsed
            } else {
                throw CLIError.usage("Unsupported language '\(rawLang)' (expected: zh-hant | zh-hans | en | ja)")
            }
            i += 2
            continue
        } else if arg.hasPrefix("--lang=") {
            let rawLang = String(arg.dropFirst("--lang=".count))
            if rawLang.lowercased() == "system" {
                lang = AppLanguage.system.resolved
            } else if let parsed = AppLanguage.parseIdentifier(rawLang) {
                lang = parsed
            } else {
                throw CLIError.usage("Unsupported language '\(rawLang)' (expected: zh-hant | zh-hans | en | ja)")
            }
            i += 1
            continue
        }
        cleaned.append(arg)
        i += 1
    }
    return (lang, cleaned)
}

func printUsage(lang: EffectiveLanguage) {
    let subtitle = L(
        lang,
        zhHant: "Apple Silicon 全欄位動態偽裝工具",
        zhHans: "Apple Silicon 全字段动态伪装工具",
        en: "Dynamic Apple Silicon Hardware & Region Spoofing Utility",
        ja: "Apple Silicon 全フィールド動的偽装ユーティリティ"
    )
    let text: String
    switch lang {
    case .en:
        text = """
        SpoofMacintosh CLI (spoofmac) v\(SpoofMacMetadata.version) — \(subtitle)
        \(SpoofMacMetadata.attribution)
        License: PolyForm Noncommercial 1.0.0 (Non-Commercial Only)

        USAGE:
          spoofmac [--lang zh-hant|zh-hans|en|ja] <command> [options]

        COMMANDS:
          status [--json] [--show-sensitive]    Show factory vs active IORegistry IDs, Kext & eligibility
          list-models [--chip M1..M6] [--json]  List all 59 supported Apple Silicon presets (M1–M6)
          list-regions [--json]                 List all 13 sales region & country presets
          apply [options]                       Apply model/region/SN/custom properties (requires sudo)
          reset [--no-refresh]                  Restore factory IOPlatformExpertDevice values (requires sudo)
          refresh                               Recalculate os_eligibility & reload AI daemons (requires sudo)
          boot-load                             LaunchDaemon boot loader + apply saved plist (requires sudo)
          diagnose [--show-sensitive]           Print full plain-text diagnostic report
          version                               Show version, attribution & license info

        APPLY OPTIONS:
          --preset <ModelID>        Apply full Mac preset (e.g. Mac17,6, Mac16,5, MacBookAir10,1)
          --keep-model              Keep native Mac model/board and only change region or specified keys
          --region <Code>           Set region-info (e.g. LL/A, TA/A, ZP/A, J/A) and country code
          --model <String>          Custom model identifier ("" restores factory value)
          --model-number <String>   Custom retail part number prefix (e.g. MX4Z4)
          --regulatory <String>     Custom regulatory model (e.g. A3429)
          --target-type <String>    Custom target-type (e.g. J716c)
          --target-sub-type <Str>   Custom target-sub-type (e.g. J716cAP)
          --country <3-Letter>      Custom country-of-origin (e.g. USA, TWN, HKG, JPN)
          --platform-name <String>  Custom platform-name (e.g. t6050, t6041, t8103)
          --serial <SN>             Custom IOPlatformSerialNumber (auto-syncs serial-number)
          --random-serial           Generate a random 10-char Apple Silicon serial number
          --raw-serial <SN>         Override 32-byte serial-number independently
          --uuid <UUID>             Custom IOPlatformUUID
          --random-uuid             Generate a random standard UUID
          --mlb <MLB>               Custom mlb-serial-number
          --random-mlb              Generate a random 17-char MLB serial
          --manufacturer / --model-config / --config-number / --device-type / --secure-root-prefix / --node-name
          --compatible <c1,c2,...>  Comma-separated compatible strings
          --no-compatible           Disable automatic compatible array updates
          --set <key:type=value>    Set arbitrary IOPlatformExpertDevice key (repeatable)
                                    type: cstring | osstring | pad32 | pad64 | raw | hex
          --clear-custom            Clear all saved --set custom properties
          --profile-file <Path>     Apply directly from a SpoofProfile plist file
          --save-only               Save preferences plist without pushing to kernel
          --no-refresh              Skip os_eligibility refresh after applying
        """
    case .ja:
        text = """
        SpoofMacintosh CLI (spoofmac) v\(SpoofMacMetadata.version) — \(subtitle)
        \(SpoofMacMetadata.attribution)
        License: PolyForm Noncommercial 1.0.0 (Non-Commercial Only)

        使い方:
          spoofmac [--lang zh-hant|zh-hans|en|ja] <コマンド> [オプション]

        コマンド:
          status [--json] [--show-sensitive]    出荷時 vs 現在の IORegistry 値・Kext・資格状態を表示
          list-models [--chip M1..M6] [--json]  対応 Apple Silicon Mac プリセット一覧 (M1–M6・59機種)
          list-regions [--json]                 販売地域・国コードプリセット一覧 (13地域)
          apply [オプション]                    機種・地域・SN・任意フィールドを動的適用 (要 sudo)
          reset [--no-refresh]                  IOPlatformExpertDevice を出荷時状態へ即時復元 (要 sudo)
          refresh                               os_eligibility と AI デーモンを強制再計算 (要 sudo)
          boot-load                             LaunchDaemon 起動用 Kext ロード＆設定適用 (要 sudo)
          diagnose [--show-sensitive]           テキスト形式の診断レポートを出力
          version                               バージョン・署名・ライセンス情報を表示

        主な apply オプション:
          --preset <ModelID>        指定した Mac 機種の全プリセットを適用 (例: Mac17,6, Mac16,5)
          --keep-model              元の機種・ボードを維持し、地域や指定項目のみ変更
          --region <Code>           region-info を設定 (例: LL/A, TA/A, ZP/A, J/A)
          --model / --model-number / --regulatory / --target-type / --target-sub-type / --country / --platform-name
          --serial <SN> / --random-serial / --raw-serial <SN>
          --uuid <UUID> / --random-uuid / --mlb <MLB> / --random-mlb
          --manufacturer / --model-config / --config-number / --device-type / --secure-root-prefix / --node-name
          --compatible <c1,c2,...>  カンマ区切りの compatible 配列を指定
          --no-compatible           compatible の自動更新を無効化
          --set <key:type=value>    任意の IORegistry キーを上書き (複数指定可)
                                    type: cstring | osstring | pad32 | pad64 | raw | hex
          --clear-custom / --profile-file <Path> / --save-only / --no-refresh
        """
    case .zhHans:
        text = """
        SpoofMacintosh CLI (spoofmac) v\(SpoofMacMetadata.version) — \(subtitle)
        \(SpoofMacMetadata.attribution)
        License: PolyForm Noncommercial 1.0.0 (Non-Commercial Only)

        用法:
          spoofmac [--lang zh-hant|zh-hans|en|ja] <子命令> [选项]

        子命令:
          status [--json] [--show-sensitive]    显示原厂/生效硬件识别（含 SN/UUID/MLB）、Kext 与资格状态
          list-models [--chip M1..M6] [--json]  列出支持的 Apple Silicon Mac 机型预设库 (M1–M6 共 59 款)
          list-regions [--json]                 列出支持的销售地区与国别预设库
          apply [选项]                          动态套用机型/地区/SN/任意字段（需 sudo；免重编 Kext）
          reset [--no-refresh]                  立即还原 IOPlatformExpertDevice 至出厂原始值（需 sudo）
          refresh                               强制重算 os_eligibility 与刷新 AI 守护进程（需 sudo）
          boot-load                             LaunchDaemon 开机加载 Kext 并套用持久化配置（需 sudo）
          diagnose [--show-sensitive]           输出完整纯文本诊断报告（默认遮罩 SN/UUID/MLB）
          version                               显示版本、署名与授权信息

        apply 常用选项:
          --preset <ModelID>        套用指定 Mac 机型全套预设（如 Mac17,6、Mac16,5、MacBookAir10,1）
          --keep-model              保留原机机型与板号，仅修改地区/销售型号或其他指定字段
          --region <Code>           设置 region-info（如 LL/A、TA/A、ZP/A、J/A），并自动带入国别码
          --model / --model-number / --regulatory / --target-type / --target-sub-type / --country / --platform-name
          --serial <SN> / --random-serial / --raw-serial <SN>
          --uuid <UUID> / --random-uuid / --mlb <MLB> / --random-mlb
          --manufacturer / --model-config / --config-number / --device-type / --secure-root-prefix / --node-name
          --compatible <c1,c2,...>  自定义逗号分隔 compatible 数组
          --no-compatible           停用自动更新 compatible
          --set <key:type=value>    任意覆盖 IOPlatformExpertDevice 其他字段（可重复多次）
                                    type 可选：cstring | osstring | pad32 | pad64 | raw | hex
          --clear-custom / --profile-file <Path> / --save-only / --no-refresh
        """
    case .zhHant:
        text = """
        SpoofMacintosh CLI (spoofmac) v\(SpoofMacMetadata.version) — \(subtitle)
        \(SpoofMacMetadata.attribution)
        License: PolyForm Noncommercial 1.0.0 (Non-Commercial Only)

        用法:
          spoofmac [--lang zh-hant|zh-hans|en|ja] <子命令> [選項]

        子命令:
          status [--json] [--show-sensitive]    顯示原廠/生效硬體識別（含 SN/UUID/MLB）、Kext 與資格狀態
          list-models [--chip M1..M6] [--json]  列出支援的 Apple Silicon Mac 機型預設庫 (M1–M6 共 59 款)
          list-regions [--json]                 列出支援的銷售地區與國別預設庫
          apply [選項]                          動態套用機型／地區／SN／任意欄位（需 sudo；免重編 Kext）
          reset [--no-refresh]                  立即還原 IOPlatformExpertDevice 至出廠原始值（需 sudo）
          refresh                               強制重算 os_eligibility 與重新整理 AI 守護程序（需 sudo）
          boot-load                             LaunchDaemon 開機載入 Kext 並套用持久化設定（需 sudo）
          diagnose [--show-sensitive]           輸出完整純文字診斷報告（預設遮罩 SN/UUID/MLB）
          version                               顯示版本、署名與授權資訊

        apply 常用選項:
          --preset <ModelID>        套用指定 Mac 機型全套預設（如 Mac17,6、Mac16,5、MacBookAir10,1）
          --keep-model              保留原機機型與板號，僅修改地區／銷售型號或其他指定欄位
          --region <Code>           設定 region-info（如 LL/A、TA/A、ZP/A、J/A），並自動帶入國別碼
          --model / --model-number / --regulatory / --target-type / --target-sub-type / --country / --platform-name
          --serial <SN> / --random-serial / --raw-serial <SN>
          --uuid <UUID> / --random-uuid / --mlb <MLB> / --random-mlb
          --manufacturer / --model-config / --config-number / --device-type / --secure-root-prefix / --node-name
          --compatible <c1,c2,...>  自訂逗號分隔 compatible 陣列
          --no-compatible           停用自動更新 compatible
          --set <key:type=value>    任意覆寫 IOPlatformExpertDevice 其他欄位（可重複多次）
                                    type 可選：cstring | osstring | pad32 | pad64 | raw | hex
          --clear-custom / --profile-file <Path> / --save-only / --no-refresh
        """
    }
    print(text)
}

func requireRoot(for action: String) throws {
    if geteuid() != 0 {
        throw CLIError.rootRequired(action)
    }
}

func printJSON<T: Encodable>(_ value: T) throws {
    let encoder = JSONEncoder()
    encoder.outputFormatting = [.prettyPrinted, .sortedKeys]
    encoder.dateEncodingStrategy = .iso8601
    let data = try encoder.encode(value)
    if let json = String(data: data, encoding: .utf8) {
        print(json)
    }
}

func handleStatus(args: [String], lang: EffectiveLanguage) throws {
    let asJSON = args.contains("--json")
    let showSensitive = args.contains("--show-sensitive")
    let report = SystemDiagnostics.collectFullReport()
    if asJSON {
        try printJSON(report)
        return
    }

    func fmtSN(_ val: String) -> String {
        val.isEmpty ? "—" : HardwareIdentitySnapshot.masked(val, revealed: showSensitive)
    }

    let yes = L(lang, zhHant: "是", zhHans: "是", en: "Yes", ja: "はい")
    let no = L(lang, zhHant: "否", zhHans: "否", en: "No", ja: "いいえ")
    let installed = L(lang, zhHant: "已安裝", zhHans: "已安装", en: "Installed", ja: "導入済み")
    let notInstalled = L(lang, zhHant: "未安裝", zhHans: "未安装", en: "Not Installed", ja: "未導入")

    print("════════════════ SpoofMacintosh \(L(lang, zhHant: "狀態總覽", zhHans: "状态总览", en: "Status Overview", ja: "ステータス概要")) ════════════════")
    print(SpoofMacMetadata.attribution)
    print("\(L(lang, zhHant: "系統", zhHans: "系统", en: "System", ja: "システム")): macOS \(report.security.macOSVersion) (\(report.security.macOSBuild)) · \(report.security.architecture)")
    print("Kext: \(report.security.kextInstalledToSystem ? installed : notInstalled) | \(L(lang, zhHant: "核心載入", zhHans: "内核加载", en: "Loaded", ja: "ロード")): \(report.security.kextLoadedInKernel ? "\(yes) ✓" : no) | \(L(lang, zhHant: "偽裝啟用", zhHans: "伪装启用", en: "Spoof Active", ja: "偽装有効")): \(report.kextStatus.isSpoofActive ? "\(yes) ✓" : no)")
    print("SIP \(L(lang, zhHant: "允許 Kext", zhHans: "允许 Kext", en: "Allows Kext", ja: "Kext許可")): \(report.security.sipAllowsKext ? "\(yes) ✓" : "\(no) ✗") | bputil: \(report.security.thirdPartyKextsPolicy) | LaunchDaemon: \(report.security.launchDaemonInstalled ? installed : notInstalled)")
    print("")
    print("【\(L(lang, zhHant: "出廠硬體", zhHans: "原厂硬件", en: "Factory Hardware", ja: "出荷時ハードウェア"))】")
    print("  model: \(report.factoryIdentity.model) | \(L(lang, zhHant: "組合型號", zhHans: "组合型号", en: "Part", ja: "型番")): \(report.factoryIdentity.combinedPartNumber) | \(L(lang, zhHant: "監管", zhHans: "监管", en: "Reg", ja: "認証")): \(report.factoryIdentity.regulatoryModelNumber)")
    print("  target: \(report.factoryIdentity.targetType) / \(report.factoryIdentity.targetSubType) | platform: \(report.factoryIdentity.platformName) | \(L(lang, zhHant: "國別", zhHans: "国别", en: "Origin", ja: "製造国")): \(report.factoryIdentity.countryOfOrigin)")
    print("  SN: \(fmtSN(report.factoryIdentity.serialNumber)) | UUID: \(fmtSN(report.factoryIdentity.hardwareUUID)) | MLB: \(fmtSN(report.factoryIdentity.mlbSerialNumber))")
    print("【\(L(lang, zhHant: "目前生效", zhHans: "当前生效", en: "Active IORegistry", ja: "現在の IORegistry"))】")
    print("  model: \(report.currentIdentity.model) | \(L(lang, zhHant: "組合型號", zhHans: "组合型号", en: "Part", ja: "型番")): \(report.currentIdentity.combinedPartNumber) | \(L(lang, zhHant: "監管", zhHans: "监管", en: "Reg", ja: "認証")): \(report.currentIdentity.regulatoryModelNumber)")
    print("  target: \(report.currentIdentity.targetType) / \(report.currentIdentity.targetSubType) | platform: \(report.currentIdentity.platformName) | \(L(lang, zhHant: "國別", zhHans: "国别", en: "Origin", ja: "製造国")): \(report.currentIdentity.countryOfOrigin)")
    print("  SN: \(fmtSN(report.currentIdentity.serialNumber)) | UUID: \(fmtSN(report.currentIdentity.hardwareUUID)) | MLB: \(fmtSN(report.currentIdentity.mlbSerialNumber))")
    if !report.kextStatus.activeCustomProperties.isEmpty {
        print("  Custom: \(report.kextStatus.activeCustomProperties.map { "\($0.key)=\($0.value)" }.sorted().joined(separator: ", "))")
    }
    print("")
    print("【\(L(lang, zhHant: "功能解鎖資格 (os_eligibility)", zhHans: "功能解锁资格 (os_eligibility)", en: "Feature Eligibility (os_eligibility)", ja: "機能利用資格 (os_eligibility)"))】")
    if !report.eligibilityReadable {
        print("  \(report.eligibilityNote)")
    } else {
        for domain in report.eligibilityDomains where domain.answer != nil || ["OS_ELIGIBILITY_DOMAIN_GREYMATTER", "OS_ELIGIBILITY_DOMAIN_IRON", "OS_ELIGIBILITY_DOMAIN_XCODE_LLM", "OS_ELIGIBILITY_DOMAIN_SIRI_WITH_APP_INTENTS"].contains(domain.id) {
            print("  • \(domain.displayName(in: lang)): \(domain.statusLabel(in: lang))")
        }
    }
    print("════════════════════════════════════════════════════════")
}

func handleListModels(args: [String], lang: EffectiveLanguage) throws {
    var chipFilter: MacChipGeneration?
    let asJSON = args.contains("--json")
    var idx = 0
    while idx < args.count {
        if args[idx] == "--chip", idx + 1 < args.count {
            let raw = args[idx + 1].uppercased()
            guard let gen = MacChipGeneration(rawValue: raw) else {
                throw CLIError.invalidChip(args[idx + 1])
            }
            chipFilter = gen
            idx += 2
            continue
        }
        idx += 1
    }

    let models = MacModelCatalog.models(for: chipFilter)
    if asJSON {
        try printJSON(models)
        return
    }

    print(L(lang,
            zhHant: "支援之 Apple Silicon Mac 機型預設庫（共 \(models.count) 款）:",
            zhHans: "支持的 Apple Silicon Mac 机型预设库（共 \(models.count) 款）:",
            en: "Supported Apple Silicon Mac Presets (\(models.count) models):",
            ja: "対応 Apple Silicon Mac プリセット一覧（全 \(models.count) 機種）:"))
    var currentGen: MacChipGeneration?
    for model in models {
        if model.chipGeneration != currentGen {
            currentGen = model.chipGeneration
            print("\n[\(model.chipGeneration.displayName(in: lang))]")
        }
        let idPad = model.modelIdentifier.padding(toLength: 15, withPad: " ", startingAt: 0)
        let partPad = model.defaultModelNumber.padding(toLength: 6, withPad: " ", startingAt: 0)
        let regPad = model.regulatoryModelNumber.padding(toLength: 6, withPad: " ", startingAt: 0)
        let platPad = model.platformName.padding(toLength: 6, withPad: " ", startingAt: 0)
        let targetPad = "\(model.targetType)/\(model.targetSubType)".padding(toLength: 16, withPad: " ", startingAt: 0)
        print("  \(idPad) | \(partPad) | \(regPad) | \(platPad) | \(targetPad) | \(model.localizedMarketingName(in: lang))")
    }
}

func handleListRegions(args: [String], lang: EffectiveLanguage) throws {
    let asJSON = args.contains("--json")
    if asJSON {
        try printJSON(MacModelCatalog.allRegions)
        return
    }

    print(L(lang,
            zhHant: "支援之銷售地區預設庫（共 \(MacModelCatalog.allRegions.count) 個地區）:",
            zhHans: "支持的销售地区预设库（共 \(MacModelCatalog.allRegions.count) 个地区）:",
            en: "Supported Sales Regions (\(MacModelCatalog.allRegions.count) regions):",
            ja: "対応販売地域プリセット一覧（全 \(MacModelCatalog.allRegions.count) 地域）:"))
    for region in MacModelCatalog.allRegions {
        let codePad = region.regionCode.padding(toLength: 6, withPad: " ", startingAt: 0)
        let countryPad = region.countryCode3.padding(toLength: 4, withPad: " ", startingAt: 0)
        let badge = region.unlocksAllFeatures
            ? L(lang, zhHant: "[解鎖]", zhHans: "[解锁]", en: "[Full]", ja: "[解放]")
            : L(lang, zhHant: "[受限]", zhHans: "[受限]", en: "[Limited]", ja: "[制限]")
        print("  \(region.flagEmoji) \(codePad) | \(countryPad) | \(badge) \(region.localizedDisplayName(in: lang)) — \(region.localizedNotes(in: lang))")
    }
}

struct ApplyParsedArgs {
    var profileFile: String?
    var deleteProfileFile = false
    var presetId: String?
    var keepModel = false
    var region: String?
    var model: String?
    var modelNumber: String?
    var regulatory: String?
    var targetType: String?
    var targetSubType: String?
    var country: String?
    var platformName: String?
    var serial: String?
    var rawSerial: String?
    var uuid: String?
    var mlb: String?
    var manufacturer: String?
    var modelConfig: String?
    var configNumber: String?
    var deviceType: String?
    var secureRootPrefix: String?
    var nodeName: String?
    var compatible: String?
    var customSets: [CustomIORegProperty] = []
    var clearCustom = false
    var noCompatible = false
    var saveOnly = false
    var noRefresh = false
}

func parseCustomSetArg(_ raw: String) throws -> CustomIORegProperty {
    guard let eqIdx = raw.firstIndex(of: "=") else {
        throw CLIError.usage("--set format must be key:type=value or key=value (got: \(raw))")
    }
    let lhs = String(raw[..<eqIdx])
    let val = String(raw[raw.index(after: eqIdx)...])

    let key: String
    let type: CustomPropertyValueType
    if let colonIdx = lhs.lastIndex(of: ":") {
        let kPart = String(lhs[..<colonIdx]).trimmingCharacters(in: .whitespaces)
        let tPart = String(lhs[lhs.index(after: colonIdx)...]).trimmingCharacters(in: .whitespaces).lowercased()
        guard let parsedType = CustomPropertyValueType(rawValue: tPart) else {
            throw CLIError.usage("Unsupported custom type '\(tPart)' (allowed: cstring, osstring, pad32, pad64, raw, hex)")
        }
        key = kPart
        type = parsedType
    } else {
        key = lhs.trimmingCharacters(in: .whitespaces)
        type = .cstring
    }
    guard !key.isEmpty else {
        throw CLIError.usage("--set key cannot be empty")
    }
    return CustomIORegProperty(key: key, type: type, value: val)
}

func parseApplyArgs(_ args: [String]) throws -> ApplyParsedArgs {
    var parsed = ApplyParsedArgs()
    var i = 0
    while i < args.count {
        let arg = args[i]
        func nextVal() throws -> String {
            guard i + 1 < args.count else {
                throw CLIError.usage("Missing value for \(arg)")
            }
            i += 2
            return args[i - 1]
        }
        switch arg {
        case "--profile-file": parsed.profileFile = try nextVal()
        case "--delete-profile-file": parsed.deleteProfileFile = true; i += 1
        case "--preset": parsed.presetId = try nextVal()
        case "--keep-model": parsed.keepModel = true; i += 1
        case "--region": parsed.region = try nextVal()
        case "--model": parsed.model = try nextVal()
        case "--model-number": parsed.modelNumber = try nextVal()
        case "--regulatory": parsed.regulatory = try nextVal()
        case "--target-type": parsed.targetType = try nextVal()
        case "--target-sub-type": parsed.targetSubType = try nextVal()
        case "--country": parsed.country = try nextVal()
        case "--platform-name": parsed.platformName = try nextVal()
        case "--serial": parsed.serial = try nextVal()
        case "--random-serial": parsed.serial = RandomIdentityGenerator.generateSerialNumber(); i += 1
        case "--raw-serial": parsed.rawSerial = try nextVal()
        case "--uuid": parsed.uuid = try nextVal()
        case "--random-uuid": parsed.uuid = RandomIdentityGenerator.generateUUID(); i += 1
        case "--mlb": parsed.mlb = try nextVal()
        case "--random-mlb": parsed.mlb = RandomIdentityGenerator.generateMLB(); i += 1
        case "--manufacturer": parsed.manufacturer = try nextVal()
        case "--model-config": parsed.modelConfig = try nextVal()
        case "--config-number": parsed.configNumber = try nextVal()
        case "--device-type": parsed.deviceType = try nextVal()
        case "--secure-root-prefix": parsed.secureRootPrefix = try nextVal()
        case "--node-name": parsed.nodeName = try nextVal()
        case "--compatible": parsed.compatible = try nextVal()
        case "--set": parsed.customSets.append(try parseCustomSetArg(try nextVal()))
        case "--clear-custom": parsed.clearCustom = true; i += 1
        case "--no-compatible": parsed.noCompatible = true; i += 1
        case "--save-only": parsed.saveOnly = true; i += 1
        case "--no-refresh": parsed.noRefresh = true; i += 1
        default: throw CLIError.usage("Unknown option: \(arg)")
        }
    }
    return parsed
}

func buildProfile(from parsed: ApplyParsedArgs) throws -> SpoofProfile {
    if let profileFile = parsed.profileFile {
        guard let loaded = try SpoofProfile.load(from: profileFile) else {
            throw CLIError.runtimeFailure("Profile file not found: \(profileFile)")
        }
        try loaded.validate()
        return loaded
    }

    var profile: SpoofProfile
    if let presetId = parsed.presetId {
        guard let preset = MacModelCatalog.model(matching: presetId) else {
            throw CLIError.unknownPreset(presetId)
        }
        let regionPreset = parsed.region.flatMap { MacModelCatalog.region(matching: $0) }
        profile = SpoofProfile.fromPreset(preset, region: regionPreset ?? MacModelCatalog.usRegionPreset, includePlatformName: true)
    } else if parsed.keepModel {
        let existing = try? SpoofProfile.load()
        profile = existing ?? SpoofProfile.regionOnlyUS()
        profile.mode = .keepNativeModel
        profile.spoofModel = ""
        profile.spoofModelNumber = ""
        profile.spoofRegulatoryModel = ""
        profile.spoofTargetType = ""
        profile.spoofTargetSubType = ""
        profile.spoofPlatformName = ""
    } else if let existing = try SpoofProfile.load() {
        profile = existing
    } else {
        profile = SpoofProfile.regionOnlyUS()
    }

    if let reg = parsed.region {
        profile.spoofRegionInfo = reg
        if parsed.country == nil {
            if reg.isEmpty {
                profile.spoofCountryOfOrigin = ""
            } else if let matchedRegion = MacModelCatalog.region(matching: reg) {
                profile.spoofCountryOfOrigin = matchedRegion.countryCode3
            }
        }
    }

    if let model = parsed.model { profile.spoofModel = model }
    if let mnum = parsed.modelNumber { profile.spoofModelNumber = mnum }
    if let regulatory = parsed.regulatory { profile.spoofRegulatoryModel = regulatory }
    if let targetType = parsed.targetType { profile.spoofTargetType = targetType }
    if let targetSub = parsed.targetSubType { profile.spoofTargetSubType = targetSub }
    if let country = parsed.country { profile.spoofCountryOfOrigin = country }
    if let plat = parsed.platformName { profile.spoofPlatformName = plat }

    if let sn = parsed.serial { profile.spoofSerialNumber = sn }
    if let rawSn = parsed.rawSerial { profile.spoofRawSerialData = rawSn }
    if let uuid = parsed.uuid { profile.spoofUUID = uuid }
    if let mlb = parsed.mlb { profile.spoofMLB = mlb }

    if let mfr = parsed.manufacturer { profile.spoofManufacturer = mfr }
    if let mcfg = parsed.modelConfig { profile.spoofModelConfig = mcfg }
    if let cnum = parsed.configNumber { profile.spoofConfigNumber = cnum }
    if let dtype = parsed.deviceType { profile.spoofDeviceType = dtype }
    if let srp = parsed.secureRootPrefix { profile.spoofSecureRootPrefix = srp }
    if let nname = parsed.nodeName { profile.spoofNodeName = nname }
    if let compat = parsed.compatible { profile.spoofCompatible = compat }

    if parsed.clearCustom {
        profile.customProperties = []
    }
    for custom in parsed.customSets {
        profile.customProperties.removeAll { $0.key == custom.key }
        if !custom.value.isEmpty {
            profile.customProperties.append(custom)
        }
    }

    if parsed.presetId == nil && !parsed.keepModel &&
       (parsed.model != nil || parsed.modelNumber != nil || parsed.regulatory != nil ||
        parsed.targetType != nil || parsed.targetSubType != nil || parsed.serial != nil ||
        parsed.uuid != nil || parsed.mlb != nil || parsed.platformName != nil ||
        !parsed.customSets.isEmpty) {
        profile.mode = .custom
    }

    if parsed.noCompatible {
        profile.updateCompatible = false
    }

    try profile.validate()
    return profile
}

func handleApply(args: [String], lang: EffectiveLanguage) throws {
    try requireRoot(for: "apply")
    let parsed = try parseApplyArgs(args)
    let profile = try buildProfile(from: parsed)

    if parsed.deleteProfileFile, let tmpPath = parsed.profileFile {
        try? FileManager.default.removeItem(atPath: tmpPath)
    }

    try profile.save()
    print("✓ \(L(lang, zhHant: "已儲存設定檔至", zhHans: "已保存配置文件至", en: "Saved profile to", ja: "設定ファイルを保存しました:")) \(SpoofProfile.defaultPreferencesPath)")

    if !parsed.saveOnly {
        if !IORegistryBridge.isKextServiceActive(),
           FileManager.default.fileExists(atPath: SystemDiagnostics.installedKextPath) {
            let loadRes = SystemDiagnostics.runCommand(
                "/usr/bin/kmutil",
                arguments: ["load", "-p", SystemDiagnostics.installedKextPath],
                timeoutSeconds: 30
            )
            if loadRes.exitCode != 0 && !IORegistryBridge.isKextServiceActive() {
                throw CLIError.runtimeFailure("Kext load failed: \(loadRes.stderr.isEmpty ? loadRes.stdout : loadRes.stderr)")
            }
        }
        try IORegistryBridge.pushProfileToKext(profile)
        let active = IORegistryBridge.readCurrentHardwareIdentity()
        print("✓ \(L(lang, zhHant: "已動態套用至 IORegistry", zhHans: "已动态套用至 IORegistry", en: "Applied dynamically to IORegistry", ja: "IORegistry に動的適用しました"))：model=\(active.model) | \(active.combinedPartNumber) | \(active.regulatoryModelNumber)")

        if !parsed.noRefresh {
            try SystemDiagnostics.refreshEligibilityDaemons { msg in
                print("  \(msg)")
            }
        }
    }
}

func handleReset(args: [String], lang: EffectiveLanguage) throws {
    try requireRoot(for: "reset")
    let noRefresh = args.contains("--no-refresh")
    try SpoofProfile.removeSaved()
    if IORegistryBridge.isKextServiceActive() {
        try IORegistryBridge.resetKextToFactory()
        print("✓ \(L(lang, zhHant: "已還原 IOPlatformExpertDevice 至出廠原始硬體屬性", zhHans: "已还原 IOPlatformExpertDevice 至出厂原始硬件属性", en: "Restored IOPlatformExpertDevice to factory properties", ja: "IOPlatformExpertDevice を出荷時状態に復元しました"))")
    } else {
        print("! \(L(lang, zhHant: "SpoofMac.kext 未載入核心，已移除持久化設定檔", zhHans: "SpoofMac.kext 未加载内核，已移除持久化配置文件", en: "SpoofMac.kext is not loaded; removed saved profile", ja: "SpoofMac.kext は未ロードのため保存済み設定のみ削除しました"))")
    }

    if !noRefresh {
        try SystemDiagnostics.refreshEligibilityDaemons { msg in
            print("  \(msg)")
        }
    }
}

func handleRefresh() throws {
    try requireRoot(for: "refresh")
    try SystemDiagnostics.refreshEligibilityDaemons { msg in
        print("  \(msg)")
    }
}

func handleBootLoad(lang: EffectiveLanguage) throws {
    try requireRoot(for: "boot-load")
    let kextPath = SystemDiagnostics.installedKextPath
    guard FileManager.default.fileExists(atPath: kextPath) else {
        throw CLIError.runtimeFailure("Missing \(kextPath)")
    }

    let loadRes = SystemDiagnostics.runCommand("/usr/bin/kmutil", arguments: ["load", "-p", kextPath], timeoutSeconds: 30)
    if !loadRes.stdout.isEmpty { print(loadRes.stdout) }
    if !loadRes.stderr.isEmpty { print(loadRes.stderr) }

    for _ in 0..<10 {
        if IORegistryBridge.isKextServiceActive() {
            break
        }
        Thread.sleep(forTimeInterval: 1.0)
    }

    guard IORegistryBridge.isKextServiceActive() else {
        throw CLIError.runtimeFailure("SpoofMac.kext load failed or timed out (exit=\(loadRes.exitCode)).")
    }

    if let profile = try SpoofProfile.load() {
        try IORegistryBridge.pushProfileToKext(profile)
        print("✓ \(L(lang, zhHant: "已從設定檔套用開機偽裝設定", zhHans: "已从配置文件套用开机伪装设置", en: "Applied saved profile at boot", ja: "保存済みプロファイルを起動時に適用しました"))")
    } else {
        print("• \(L(lang, zhHant: "未找到自訂設定檔，維持 Kext 預設區域偽裝 (LL/A)", zhHans: "未找到自定义配置文件，维持 Kext 默认区域伪装 (LL/A)", en: "No saved profile; keeping Kext default LL/A region spoof", ja: "保存設定なし。Kext デフォルト (LL/A) を維持します"))")
    }

    try SystemDiagnostics.refreshEligibilityDaemons { msg in
        print("  \(msg)")
    }
}

func handleDiagnose(args: [String], lang: EffectiveLanguage) {
    let showSensitive = args.contains("--show-sensitive")
    let report = SystemDiagnostics.collectFullReport()
    print(report.formatPlainText(redactSensitive: !showSensitive, language: lang))
}

// MARK: - Main Entrypoint

var activeLang = AppLanguage.system.resolved
do {
    let rawArgs = Array(CommandLine.arguments.dropFirst())
    let (lang, args) = try extractLanguageAndCleanArgs(rawArgs)
    activeLang = lang
    AppLanguage.overrideLanguage = lang

    guard let cmd = args.first else {
        printUsage(lang: lang)
        exit(0)
    }
    let rest = Array(args.dropFirst())

    switch cmd {
    case "status":
        try handleStatus(args: rest, lang: lang)
    case "list-models":
        try handleListModels(args: rest, lang: lang)
    case "list-regions":
        try handleListRegions(args: rest, lang: lang)
    case "apply":
        try handleApply(args: rest, lang: lang)
    case "reset":
        try handleReset(args: rest, lang: lang)
    case "refresh":
        try handleRefresh()
    case "boot-load":
        try handleBootLoad(lang: lang)
    case "diagnose":
        handleDiagnose(args: rest, lang: lang)
    case "version", "--version", "-v":
        print("\(SpoofMacMetadata.appName) v\(SpoofMacMetadata.version) — \(SpoofMacMetadata.attribution) [PolyForm Noncommercial 1.0.0]")
    case "help", "--help", "-h":
        printUsage(lang: lang)
    default:
        printUsage(lang: lang)
        throw CLIError.usage("Unknown command: \(cmd)")
    }
} catch let cliErr as CLIError {
    fputs("\(L(activeLang, zhHant: "錯誤", zhHans: "错误", en: "Error", ja: "エラー")): \(cliErr.localizedMessage(in: activeLang))\n", stderr)
    exit(1)
} catch {
    fputs("\(L(activeLang, zhHant: "錯誤", zhHans: "错误", en: "Error", ja: "エラー")): \(error.localizedDescription)\n", stderr)
    exit(1)
}
