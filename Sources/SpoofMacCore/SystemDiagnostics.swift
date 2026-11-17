// Powered by NyphexAI, Developed by Hikaru(i@rua.moe)
// Licensed under the PolyForm Noncommercial License 1.0.0

import Foundation

public struct EligibilityDomainDescriptor {
    public let key: String
    public let displayName: String
    public let description: String
    public let invertedRestriction: Bool

    public init(key: String, displayName: String, description: String, invertedRestriction: Bool = false) {
        self.key = key
        self.displayName = displayName
        self.description = description
        self.invertedRestriction = invertedRestriction
    }
}

public struct EligibilityDomainStatus: Identifiable, Codable, Equatable {
    public let id: String
    public let displayName: String
    public let description: String
    public let answer: Int?
    public let invertedRestriction: Bool
    public let inputsSummary: [String: Int]

    public init(
        id: String,
        displayName: String,
        description: String,
        answer: Int?,
        invertedRestriction: Bool = false,
        inputsSummary: [String: Int] = [:]
    ) {
        self.id = id
        self.displayName = displayName
        self.description = description
        self.answer = answer
        self.invertedRestriction = invertedRestriction
        self.inputsSummary = inputsSummary
    }

    public var isEligible: Bool {
        guard let answer else { return false }
        return invertedRestriction ? (answer == 2) : (answer == 4)
    }

    public func displayName(in lang: EffectiveLanguage) -> String {
        switch id {
        case "OS_ELIGIBILITY_DOMAIN_GREYMATTER":
            return "Apple Intelligence"
        case "OS_ELIGIBILITY_DOMAIN_IRON":
            return L(lang, zhHant: "iPhone 鏡像輸出", zhHans: "iPhone 镜像", en: "iPhone Mirroring", ja: "iPhone ミラーリング")
        case "OS_ELIGIBILITY_DOMAIN_XCODE_LLM":
            return L(lang, zhHant: "Xcode AI 輔助", zhHans: "Xcode AI 辅助", en: "Xcode Predictive AI", ja: "Xcode AI アシスト")
        case "OS_ELIGIBILITY_DOMAIN_SIRI_WITH_APP_INTENTS":
            return L(lang, zhHant: "新版 Siri 與 App Intents", zhHans: "新版 Siri 与 App Intents", en: "New Siri & App Intents", ja: "新SiriとApp Intents")
        case "OS_ELIGIBILITY_DOMAIN_FOUNDATION_MODELS":
            return L(lang, zhHant: "系統基礎模型 (Foundation Models)", zhHans: "系统基础模型 (Foundation Models)", en: "Foundation Models API", ja: "Foundation Models API")
        case "OS_ELIGIBILITY_DOMAIN_PERSONAL_QA":
            return L(lang, zhHant: "個人化語意問答 (Personal QA)", zhHans: "个性化语义问答 (Personal QA)", en: "Personal Context QA", ja: "パーソナルコンテキストQA")
        case "OS_ELIGIBILITY_DOMAIN_HYDROGEN":
            return L(lang, zhHant: "區域功能域 H (Hydrogen)", zhHans: "区域功能域 H (Hydrogen)", en: "Regional Domain H (Hydrogen)", ja: "地域機能ドメイン H (Hydrogen)")
        case "OS_ELIGIBILITY_DOMAIN_HELIUM":
            return L(lang, zhHant: "區域功能域 He (Helium)", zhHans: "区域功能域 He (Helium)", en: "Regional Domain He (Helium)", ja: "地域機能ドメイン He (Helium)")
        case "OS_ELIGIBILITY_DOMAIN_FORCED_SHUTTER_SOUND":
            return L(lang, zhHant: "強制相機快門音限制", zhHans: "强制相机快门音限制", en: "Forced Camera Shutter Sound", ja: "カメラシャッター音強制")
        default:
            return displayName
        }
    }

    public func description(in lang: EffectiveLanguage) -> String {
        switch id {
        case "OS_ELIGIBILITY_DOMAIN_GREYMATTER":
            return L(lang,
                     zhHant: "寫作工具、影像樂園、Genmoji、通知摘要與 PCC 私密雲端運算",
                     zhHans: "写作工具、图像乐园、Genmoji、通知摘要与 PCC 私密云计算",
                     en: "Writing Tools, Image Playground, Genmoji, Summaries & Private Cloud Compute",
                     ja: "作文ツール、Image Playground、Genmoji、要約、Private Cloud Compute")
        case "OS_ELIGIBILITY_DOMAIN_IRON":
            return L(lang,
                     zhHant: "iPhone Mirroring 跨裝置鏡像控制（部分受限地區或歐盟政策會關閉）",
                     zhHans: "iPhone Mirroring 跨设备镜像控制（部分受限地区或欧盟政策会关闭）",
                     en: "Cross-device iPhone Mirroring control (restricted in EU/certain regions)",
                     ja: "デバイス間iPhoneミラーリング機能（EUや一部地域では制限）")
        case "OS_ELIGIBILITY_DOMAIN_XCODE_LLM":
            return L(lang,
                     zhHant: "Xcode 程式碼自動完成預測與智慧開發輔助",
                     zhHans: "Xcode 代码自动补全预测与智能开发辅助",
                     en: "Xcode predictive code completion & intelligent coding assistant",
                     ja: "Xcodeの予測コード補完およびAI開発支援")
        case "OS_ELIGIBILITY_DOMAIN_SIRI_WITH_APP_INTENTS":
            return L(lang,
                     zhHant: "新一代 Siri 螢幕感知與跨 App 動作執行",
                     zhHans: "新一代 Siri 屏幕感知与跨 App 动作执行",
                     en: "On-screen awareness and cross-app execution with new Siri",
                     ja: "次世代Siriの画面認識およびApp Intents連携")
        case "OS_ELIGIBILITY_DOMAIN_FOUNDATION_MODELS":
            return L(lang,
                     zhHant: "端側 Apple Foundation Models API 執行權限",
                     zhHans: "端侧 Apple Foundation Models API 执行权限",
                     en: "On-device Apple Foundation Models framework eligibility",
                     ja: "オンデバイスApple Foundation Models API利用資格")
        case "OS_ELIGIBILITY_DOMAIN_PERSONAL_QA":
            return L(lang,
                     zhHant: "個人上下文檢索與語意理解功能",
                     zhHans: "个人上下文检索与语义理解功能",
                     en: "Personal context retrieval and semantic understanding",
                     ja: "パーソナルコンテキスト検索・意味理解機能")
        case "OS_ELIGIBILITY_DOMAIN_HYDROGEN":
            return L(lang, zhHant: "系統區域性延伸服務開關", zhHans: "系统区域性扩展服务开关", en: "Regional extended service eligibility flag", ja: "地域拡張サービス利用資格フラグ")
        case "OS_ELIGIBILITY_DOMAIN_HELIUM":
            return L(lang, zhHant: "系統區域性相容功能開關", zhHans: "系统区域性兼容功能开关", en: "Regional compatibility feature flag", ja: "地域互換機能利用資格フラグ")
        case "OS_ELIGIBILITY_DOMAIN_FORCED_SHUTTER_SOUND":
            return L(lang,
                     zhHant: "部分地區機型限制（未強制表示正常）",
                     zhHans: "部分地区机型限制（未强制表示正常）",
                     en: "Regional hardware restriction (Not Enforced = Normal)",
                     ja: "特定地域モデルの強制制限（無効＝通常状態）")
        default:
            return description
        }
    }

    public var statusLabel: String {
        statusLabel(in: AppLanguage.system.resolved)
    }

    public func statusLabel(in lang: EffectiveLanguage) -> String {
        guard let answer else {
            return L(lang, zhHant: "尚未評估", zhHans: "尚未评估", en: "Not Evaluated", ja: "未評価")
        }
        if invertedRestriction {
            switch answer {
            case 2: return L(lang, zhHant: "未強制限制 (2 ✓)", zhHans: "未强制限制 (2 ✓)", en: "Not Enforced (2 ✓)", ja: "制限なし (2 ✓)")
            case 4: return L(lang, zhHant: "強制開啟限制 (4)", zhHans: "强制开启限制 (4)", en: "Enforced (4)", ja: "強制有効 (4)")
            default: return L(lang, zhHant: "狀態碼 \(answer)", zhHans: "状态码 \(answer)", en: "Code \(answer)", ja: "コード \(answer)")
            }
        }
        switch answer {
        case 4: return L(lang, zhHant: "已解鎖 (4 ✓)", zhHans: "已解锁 (4 ✓)", en: "Eligible (4 ✓)", ja: "利用可能 (4 ✓)")
        case 2: return L(lang, zhHant: "未解鎖 (2)", zhHans: "未解锁 (2)", en: "Ineligible (2)", ja: "利用不可 (2)")
        case 3: return L(lang, zhHant: "待確認 / 保留 (3)", zhHans: "待确认 / 保留 (3)", en: "Pending / Hold (3)", ja: "保留中 (3)")
        default: return L(lang, zhHant: "狀態碼 \(answer)", zhHans: "状态码 \(answer)", en: "Code \(answer)", ja: "コード \(answer)")
        }
    }
}

public struct SecurityEnvironmentStatus: Codable, Equatable {
    public let isAppleSilicon: Bool
    public let architecture: String
    public let macOSVersion: String
    public let macOSBuild: String
    public let sipStatusRaw: String
    public let sipAllowsKext: Bool
    public let sipFullyDisabled: Bool
    public let thirdPartyKextsPolicy: String
    public let bootArgs: String
    public let hasAmfiBypassBootArg: Bool
    public let hasSpoofOffBootArg: Bool
    public let amfiLaunchConstraints: String
    public let lockedEligibilityFiles: [String]
    public let appleLanguages: String
    public let siriLanguage: String
    public let launchDaemonInstalled: Bool
    public let kextInstalledToSystem: Bool
    public let kextLoadedInKernel: Bool

    public init(
        isAppleSilicon: Bool,
        architecture: String,
        macOSVersion: String,
        macOSBuild: String,
        sipStatusRaw: String,
        sipAllowsKext: Bool,
        sipFullyDisabled: Bool,
        thirdPartyKextsPolicy: String,
        bootArgs: String,
        hasAmfiBypassBootArg: Bool,
        hasSpoofOffBootArg: Bool,
        amfiLaunchConstraints: String,
        lockedEligibilityFiles: [String],
        appleLanguages: String,
        siriLanguage: String,
        launchDaemonInstalled: Bool,
        kextInstalledToSystem: Bool,
        kextLoadedInKernel: Bool
    ) {
        self.isAppleSilicon = isAppleSilicon
        self.architecture = architecture
        self.macOSVersion = macOSVersion
        self.macOSBuild = macOSBuild
        self.sipStatusRaw = sipStatusRaw
        self.sipAllowsKext = sipAllowsKext
        self.sipFullyDisabled = sipFullyDisabled
        self.thirdPartyKextsPolicy = thirdPartyKextsPolicy
        self.bootArgs = bootArgs
        self.hasAmfiBypassBootArg = hasAmfiBypassBootArg
        self.hasSpoofOffBootArg = hasSpoofOffBootArg
        self.amfiLaunchConstraints = amfiLaunchConstraints
        self.lockedEligibilityFiles = lockedEligibilityFiles
        self.appleLanguages = appleLanguages
        self.siriLanguage = siriLanguage
        self.launchDaemonInstalled = launchDaemonInstalled
        self.kextInstalledToSystem = kextInstalledToSystem
        self.kextLoadedInKernel = kextLoadedInKernel
    }
}

public struct SystemDiagnosticReport: Codable {
    public let timestamp: Date
    public let factoryIdentity: HardwareIdentitySnapshot
    public let currentIdentity: HardwareIdentitySnapshot
    public let kextStatus: KextRuntimeStatus
    public let savedProfile: SpoofProfile?
    public let security: SecurityEnvironmentStatus
    public let eligibilityDomains: [EligibilityDomainStatus]
    public let eligibilityReadable: Bool
    public let eligibilityNote: String

    public func formatPlainText(
        redactSensitive: Bool = true,
        language: EffectiveLanguage = AppLanguage.system.resolved
    ) -> String {
        let formatter = ISO8601DateFormatter()
        var lines: [String] = []
        let yes = L(language, zhHant: "是", zhHans: "是", en: "Yes", ja: "はい")
        let no = L(language, zhHant: "否", zhHans: "否", en: "No", ja: "いいえ")
        lines.append("════════════════ SpoofMacintosh \(L(language, zhHant: "診斷報告", zhHans: "诊断报告", en: "Diagnostic Report", ja: "診断レポート")) ════════════════")
        lines.append(SpoofMacMetadata.attribution)
        lines.append("\(L(language, zhHant: "授權條款", zhHans: "授权条款", en: "License", ja: "ライセンス")): \(SpoofMacMetadata.licenseName)")
        lines.append("\(L(language, zhHant: "產生時間", zhHans: "生成时间", en: "Generated", ja: "生成日時")): \(formatter.string(from: timestamp))")
        lines.append("")
        lines.append("## \(L(language, zhHant: "系統環境", zhHans: "系统环境", en: "System Environment", ja: "システム環境"))")
        lines.append("  macOS : \(security.macOSVersion) (\(security.macOSBuild))")
        lines.append("  Arch  : \(security.architecture) (Apple Silicon: \(security.isAppleSilicon ? yes : no))")
        lines.append("")
        lines.append("## \(L(language, zhHant: "安全性與 Kext 前置狀態", zhHans: "安全性与 Kext 前置状态", en: "Security & Kext Prerequisites", ja: "セキュリティと Kext 状態"))")
        lines.append("  SIP Allows Kext : \(security.sipAllowsKext ? "\(yes) ✓" : "\(no) ✗") (Fully Disabled: \(security.sipFullyDisabled ? yes : no))")
        for line in security.sipStatusRaw.split(separator: "\n") {
            lines.append("    \(line)")
        }
        lines.append("  3rd Party Kexts Policy (bputil) : \(security.thirdPartyKextsPolicy)")
        lines.append("  AMFI bypass (amfi_get_out_of_my_way) : \(security.hasAmfiBypassBootArg ? L(language, zhHant: "存在 !（會破壞 PCC）", zhHans: "存在 !（会破坏 PCC）", en: "Present ! (breaks PCC)", ja: "検出 ! (PCC に影響)") : L(language, zhHant: "未發現 ✓", zhHans: "未发现 ✓", en: "Not found ✓", ja: "未検出 ✓"))")
        lines.append("  spoof_off boot-arg : \(security.hasSpoofOffBootArg ? yes : no)")
        lines.append("  AMFI launch constraints : \(security.amfiLaunchConstraints)")
        lines.append("  boot-args : \(security.bootArgs.isEmpty ? "(empty)" : security.bootArgs)")
        lines.append("  Kext Installed (/Library/Extensions/SpoofMac.kext) : \(security.kextInstalledToSystem ? yes : no)")
        lines.append("  Kext Loaded (kmutil) : \(security.kextLoadedInKernel ? "\(yes) ✓" : no)")
        lines.append("  IORegistry Service : \(kextStatus.isKextServicePresent ? "Active ✓ (SpoofActive=\(kextStatus.isSpoofActive))" : "None")")
        lines.append("  LaunchDaemon : \(security.launchDaemonInstalled ? yes : no)")
        lines.append("")

        func appendIdentityBlock(_ title: String, _ id: HardwareIdentitySnapshot, showCompat: Bool) {
            let reveal = !redactSensitive
            lines.append("  [\(title)]")
            lines.append("    model                   : \(id.model)")
            lines.append("    model-number            : \(id.modelNumber)")
            lines.append("    region-info             : \(id.regionInfo)")
            lines.append("    combined-part-number    : \(id.combinedPartNumber)")
            lines.append("    regulatory-model-number : \(id.regulatoryModelNumber)")
            lines.append("    target-type / sub-type  : \(id.targetType) / \(id.targetSubType)")
            lines.append("    country-of-origin       : \(id.countryOfOrigin)")
            lines.append("    platform-name           : \(id.platformName)")
            lines.append("    IOPlatformSerialNumber  : \(HardwareIdentitySnapshot.masked(id.serialNumber, revealed: reveal))")
            lines.append("    serial-number           : \(HardwareIdentitySnapshot.masked(id.rawSerialNumber, revealed: reveal))")
            lines.append("    IOPlatformUUID          : \(HardwareIdentitySnapshot.masked(id.hardwareUUID, revealed: reveal))")
            lines.append("    mlb-serial-number       : \(HardwareIdentitySnapshot.masked(id.mlbSerialNumber, revealed: reveal))")
            lines.append("    manufacturer            : \(id.manufacturer)")
            lines.append("    model-config            : \(id.modelConfig)")
            lines.append("    config-number           : \(id.configNumber)")
            lines.append("    device_type / root      : \(id.deviceType) / \(id.secureRootPrefix)")
            lines.append("    name                    : \(id.nodeName)")
            if showCompat {
                lines.append("    compatible              : \(id.compatible.joined(separator: ", "))")
            }
        }

        lines.append("## \(L(language, zhHant: "硬體識別對照", zhHans: "硬件识别对照", en: "Hardware Identity Comparison", ja: "ハードウェア識別比較")) (\(redactSensitive ? L(language, zhHant: "敏感序號已遮罩，加 --show-sensitive 顯示明文", zhHans: "敏感序列号已遮罩，加 --show-sensitive 显示明文", en: "Sensitive IDs redacted; pass --show-sensitive to reveal", ja: "シリアル等はマスク済み (--show-sensitive で表示)") : L(language, zhHant: "明文模式", zhHans: "明文模式", en: "Unredacted", ja: "平文モード")))")
        appendIdentityBlock(L(language, zhHant: "原廠硬體", zhHans: "原厂硬件", en: "Factory Hardware", ja: "出荷時ハードウェア"), factoryIdentity, showCompat: false)
        appendIdentityBlock(L(language, zhHant: "目前生效 IORegistry", zhHans: "当前生效 IORegistry", en: "Active IORegistry", ja: "現在の IORegistry"), currentIdentity, showCompat: true)
        if !kextStatus.activeCustomProperties.isEmpty {
            lines.append("  [\(L(language, zhHant: "生效自訂屬性", zhHans: "生效自定义属性", en: "Active Custom Properties", ja: "有効なカスタムプロパティ"))]")
            for (k, v) in kextStatus.activeCustomProperties.sorted(by: { $0.key < $1.key }) {
                lines.append("    \(k) : \(v)")
            }
        }
        lines.append("")
        lines.append("## \(L(language, zhHant: "語言設定", zhHans: "语言设置", en: "Language Settings", ja: "言語設定"))")
        lines.append("  AppleLanguages : \(security.appleLanguages)")
        lines.append("  Siri Session Language : \(security.siriLanguage)")
        lines.append("")
        lines.append("## os_eligibility")
        if !security.lockedEligibilityFiles.isEmpty {
            lines.append("  ! Locked files (uchg/schg): \(security.lockedEligibilityFiles.joined(separator: ", "))")
        }
        if !eligibilityReadable {
            lines.append("  Error: \(eligibilityNote)")
        } else {
            for domain in eligibilityDomains {
                lines.append("  - \(domain.displayName(in: language)) (\(domain.id)): \(domain.statusLabel(in: language))")
            }
        }
        lines.append("════════════════════════════════════════════════════════════")
        return lines.joined(separator: "\n")
    }
}

public enum SystemDiagnosticsError: LocalizedError {
    case eligibilityFilesLocked([String])
    case commandFailed(String)
    case refreshTimedOut(String)

    public var errorDescription: String? {
        switch self {
        case .eligibilityFilesLocked(let files):
            return "資格資料庫檔案被 uchg/schg 旗標鎖定，請先解鎖：\n\(files.joined(separator: "\n"))"
        case .commandFailed(let message):
            return message
        case .refreshTimedOut(let message):
            return message
        }
    }
}

public enum SystemDiagnostics {
    public static let eligibilityPlistPath = "/private/var/db/eligibilityd/eligibility.plist"
    public static let installedKextPath = "/Library/Extensions/SpoofMac.kext"
    public static let launchDaemonPlistPath = "/Library/LaunchDaemons/com.spoofmacintosh.loader.plist"
    public static let bootLoaderScriptPath = "/usr/local/bin/spoofmac-boot.sh"

    private static let eligibilityFilesToCheck = [
        "/private/var/db/eligibilityd/eligibility.plist",
        "/private/var/db/eligibilityd/eligibility_inputs.plist",
        "/private/var/db/eligibilityd/datastore.data",
        "/private/var/db/eligibilityd/datastore.data-shm",
        "/private/var/db/eligibilityd/datastore.data-wal",
        "/private/var/db/os_eligibility/eligibility.plist",
    ]

    public static let trackedDomains: [EligibilityDomainDescriptor] = [
        EligibilityDomainDescriptor(
            key: "OS_ELIGIBILITY_DOMAIN_GREYMATTER",
            displayName: "Apple Intelligence",
            description: "寫作工具、影像樂園、Genmoji、通知摘要與 PCC 私密雲端運算"
        ),
        EligibilityDomainDescriptor(
            key: "OS_ELIGIBILITY_DOMAIN_IRON",
            displayName: "iPhone 鏡像輸出",
            description: "iPhone Mirroring 跨裝置鏡像控制（部分受限地區或歐盟政策會關閉）"
        ),
        EligibilityDomainDescriptor(
            key: "OS_ELIGIBILITY_DOMAIN_XCODE_LLM",
            displayName: "Xcode AI 輔助",
            description: "Xcode 程式碼自動完成預測與智慧開發輔助"
        ),
        EligibilityDomainDescriptor(
            key: "OS_ELIGIBILITY_DOMAIN_SIRI_WITH_APP_INTENTS",
            displayName: "新版 Siri 與 App Intents",
            description: "新一代 Siri 螢幕感知與跨 App 動作執行"
        ),
        EligibilityDomainDescriptor(
            key: "OS_ELIGIBILITY_DOMAIN_FOUNDATION_MODELS",
            displayName: "系統基礎模型 (Foundation Models)",
            description: "端側 Apple Foundation Models API 執行權限"
        ),
        EligibilityDomainDescriptor(
            key: "OS_ELIGIBILITY_DOMAIN_PERSONAL_QA",
            displayName: "個人化語意問答 (Personal QA)",
            description: "個人上下文檢索與語意理解功能"
        ),
        EligibilityDomainDescriptor(
            key: "OS_ELIGIBILITY_DOMAIN_HYDROGEN",
            displayName: "區域功能域 H (Hydrogen)",
            description: "系統區域性延伸服務開關"
        ),
        EligibilityDomainDescriptor(
            key: "OS_ELIGIBILITY_DOMAIN_HELIUM",
            displayName: "區域功能域 He (Helium)",
            description: "系統區域性相容功能開關"
        ),
        EligibilityDomainDescriptor(
            key: "OS_ELIGIBILITY_DOMAIN_FORCED_SHUTTER_SOUND",
            displayName: "強制相機快門音限制",
            description: "部分地區機型限制（未強制表示正常）",
            invertedRestriction: true
        ),
    ]

    // MARK: - Subprocess Helper

    @discardableResult
    public static func runCommand(
        _ launchPath: String,
        arguments: [String] = [],
        timeoutSeconds: TimeInterval = 15
    ) -> (exitCode: Int32, stdout: String, stderr: String) {
        let process = Process()
        process.executableURL = URL(fileURLWithPath: launchPath)
        process.arguments = arguments
        process.standardInput = FileHandle.nullDevice

        let outPipe = Pipe()
        let errPipe = Pipe()
        process.standardOutput = outPipe
        process.standardError = errPipe

        do {
            try process.run()
        } catch {
            return (-1, "", error.localizedDescription)
        }

        let deadline = Date().addingTimeInterval(timeoutSeconds)
        while process.isRunning && Date() < deadline {
            Thread.sleep(forTimeInterval: 0.05)
        }
        if process.isRunning {
            process.terminate()
            Thread.sleep(forTimeInterval: 0.1)
            if process.isRunning {
                kill(process.processIdentifier, SIGKILL)
            }
        }
        process.waitUntilExit()

        let outData = outPipe.fileHandleForReading.readDataToEndOfFile()
        let errData = errPipe.fileHandleForReading.readDataToEndOfFile()
        let stdout = String(decoding: outData, as: UTF8.self).trimmingCharacters(in: .whitespacesAndNewlines)
        let stderr = String(decoding: errData, as: UTF8.self).trimmingCharacters(in: .whitespacesAndNewlines)
        return (process.terminationStatus, stdout, stderr)
    }

    // MARK: - Security & Environment Checks

    public static func currentBootVolumeGroupUUID() -> String? {
        let res = runCommand("/usr/sbin/diskutil", arguments: ["info", "-plist", "/"], timeoutSeconds: 10)
        guard res.exitCode == 0, let data = res.stdout.data(using: .utf8) else {
            return nil
        }
        guard let plist = try? PropertyListSerialization.propertyList(from: data, format: nil) as? [String: Any] else {
            return nil
        }
        return plist["APFSVolumeGroupID"] as? String
    }

    public static func queryThirdPartyKextPolicy() -> String {
        var args = ["-d"]
        if let vg = currentBootVolumeGroupUUID(), !vg.isEmpty {
            args.append(contentsOf: ["-v", vg])
        }
        let res = runCommand("/usr/bin/bputil", arguments: args, timeoutSeconds: 15)
        let combined = "\(res.stdout)\n\(res.stderr)"
        for line in combined.split(separator: "\n") where line.contains("3rd Party Kexts Status") {
            if line.localizedCaseInsensitiveContains("Enabled") {
                return "enabled"
            }
            if line.localizedCaseInsensitiveContains("Disabled") {
                return "disabled"
            }
        }
        return "unknown"
    }

    public static func detectLockedEligibilityFiles() -> [String] {
        var locked: [String] = []
        for path in eligibilityFilesToCheck where FileManager.default.fileExists(atPath: path) {
            let res = runCommand("/usr/bin/stat", arguments: ["-f", "%Sf", path], timeoutSeconds: 5)
            if res.exitCode == 0 && (res.stdout.contains("uchg") || res.stdout.contains("schg")) {
                locked.append("\(path) (\(res.stdout))")
            }
        }
        return locked
    }

    public static func collectSecurityStatus() -> SecurityEnvironmentStatus {
        let arch = runCommand("/usr/bin/uname", arguments: ["-m"]).stdout
        let osVer = runCommand("/usr/bin/sw_vers", arguments: ["-productVersion"]).stdout
        let osBuild = runCommand("/usr/bin/sw_vers", arguments: ["-buildVersion"]).stdout

        let csrRes = runCommand("/usr/bin/csrutil", arguments: ["status"])
        let sipRaw = csrRes.stdout.isEmpty ? csrRes.stderr : csrRes.stdout
        let sipFullOff = sipRaw.localizedCaseInsensitiveContains("System Integrity Protection status: disabled")
        let sipKextOff = sipFullOff || sipRaw.range(
            of: #"Kext Signing:\s*disabled"#,
            options: [.regularExpression, .caseInsensitive]
        ) != nil

        let bpPolicy = queryThirdPartyKextPolicy()

        let nvramRes = runCommand("/usr/sbin/nvram", arguments: ["boot-args"])
        var bootArgs = nvramRes.stdout
        if bootArgs.hasPrefix("boot-args") {
            bootArgs = bootArgs.replacingOccurrences(
                of: #"^boot-args\s*"#,
                with: "",
                options: .regularExpression
            )
        }
        if nvramRes.exitCode != 0 {
            bootArgs = ""
        }

        let hasAmfiBypass = bootArgs.range(
            of: #"(^|\s)amfi_get_out_of_my_way(=[^\s]*)?(\s|$)"#,
            options: .regularExpression
        ) != nil
        let hasSpoofOff = bootArgs.range(
            of: #"(^|\s)spoof_off(=[^\s]*)?(\s|$)"#,
            options: .regularExpression
        ) != nil

        let amfiLC = runCommand(
            "/usr/sbin/sysctl",
            arguments: ["-n", "security.mac.amfi.launch_constraints_enforced"]
        ).stdout

        let langs = runCommand("/usr/bin/defaults", arguments: ["read", "-g", "AppleLanguages"]).stdout
            .replacingOccurrences(of: "\n", with: " ")
            .replacingOccurrences(of: #"\s+"#, with: " ", options: .regularExpression)
        let siriLang = runCommand(
            "/usr/bin/defaults",
            arguments: ["read", "com.apple.assistant.backedup", "Session Language"]
        ).stdout

        let kmLoaded = runCommand("/usr/bin/kmutil", arguments: ["showloaded", "--no-kernel-components"]).stdout
            .localizedCaseInsensitiveContains("com.spoofmacintosh.SpoofMac")

        return SecurityEnvironmentStatus(
            isAppleSilicon: arch == "arm64",
            architecture: arch.isEmpty ? "unknown" : arch,
            macOSVersion: osVer.isEmpty ? "unknown" : osVer,
            macOSBuild: osBuild.isEmpty ? "unknown" : osBuild,
            sipStatusRaw: sipRaw,
            sipAllowsKext: sipKextOff,
            sipFullyDisabled: sipFullOff,
            thirdPartyKextsPolicy: bpPolicy,
            bootArgs: bootArgs,
            hasAmfiBypassBootArg: hasAmfiBypass,
            hasSpoofOffBootArg: hasSpoofOff,
            amfiLaunchConstraints: amfiLC.isEmpty ? "?" : amfiLC,
            lockedEligibilityFiles: detectLockedEligibilityFiles(),
            appleLanguages: langs.isEmpty ? "?" : langs,
            siriLanguage: siriLang.isEmpty ? "未設定" : siriLang,
            launchDaemonInstalled: FileManager.default.fileExists(atPath: launchDaemonPlistPath),
            kextInstalledToSystem: FileManager.default.fileExists(atPath: installedKextPath),
            kextLoadedInKernel: kmLoaded || IORegistryBridge.isKextServiceActive()
        )
    }

    // MARK: - Eligibility Reading

    public static func readEligibilityDomains() -> (domains: [EligibilityDomainStatus], readable: Bool, note: String) {
        let url = URL(fileURLWithPath: eligibilityPlistPath)
        guard FileManager.default.fileExists(atPath: url.path) else {
            return (
                trackedDomains.map {
                    EligibilityDomainStatus(
                        id: $0.key,
                        displayName: $0.displayName,
                        description: $0.description,
                        answer: nil,
                        invertedRestriction: $0.invertedRestriction
                    )
                },
                false,
                "檔案尚未產生（eligibilityd 尚未執行計算）"
            )
        }

        do {
            let data = try Data(contentsOf: url)
            guard let plist = try PropertyListSerialization.propertyList(from: data, format: nil) as? [String: Any] else {
                return ([], false, "eligibility.plist 格式無法解析")
            }

            let results: [EligibilityDomainStatus] = trackedDomains.map { desc in
                guard let entry = plist[desc.key] as? [String: Any] else {
                    return EligibilityDomainStatus(
                        id: desc.key,
                        displayName: desc.displayName,
                        description: desc.description,
                        answer: nil,
                        invertedRestriction: desc.invertedRestriction
                    )
                }
                let answer = entry["os_eligibility_answer_t"] as? Int
                var inputs: [String: Int] = [:]
                if let statusDict = entry["status"] as? [String: Any] {
                    for (k, v) in statusDict where k != "OS_ELIGIBILITY_INPUT_COUNTRY_LOCATION" {
                        if let intVal = v as? Int {
                            inputs[k] = intVal
                        }
                    }
                }
                return EligibilityDomainStatus(
                    id: desc.key,
                    displayName: desc.displayName,
                    description: desc.description,
                    answer: answer,
                    invertedRestriction: desc.invertedRestriction,
                    inputsSummary: inputs
                )
            }
            return (results, true, "")
        } catch {
            return ([], false, error.localizedDescription)
        }
    }

    public static func collectFullReport() -> SystemDiagnosticReport {
        let factory = IORegistryBridge.readFactoryHardwareIdentity()
        let current = IORegistryBridge.readCurrentHardwareIdentity()
        let kextStatus = IORegistryBridge.readKextStatus()
        let saved = try? SpoofProfile.load()
        let security = collectSecurityStatus()
        let elig = readEligibilityDomains()

        return SystemDiagnosticReport(
            timestamp: Date(),
            factoryIdentity: factory,
            currentIdentity: current,
            kextStatus: kextStatus,
            savedProfile: saved,
            security: security,
            eligibilityDomains: elig.domains,
            eligibilityReadable: elig.readable,
            eligibilityNote: elig.note
        )
    }

    // MARK: - Daemon Refresh (Requires Root)

    private static func firstPID(processName: String) -> String? {
        let res = runCommand("/usr/bin/pgrep", arguments: ["-x", processName], timeoutSeconds: 5)
        guard res.exitCode == 0, let first = res.stdout.split(separator: "\n").first else {
            return nil
        }
        return String(first)
    }

    private static func fileStamp(path: String) -> String {
        runCommand("/usr/bin/stat", arguments: ["-f", "%i:%m:%c:%z", path], timeoutSeconds: 5).stdout
    }

    private static func greymatterAnswer() -> Int? {
        let res = runCommand(
            "/usr/libexec/PlistBuddy",
            arguments: ["-c", "Print :OS_ELIGIBILITY_DOMAIN_GREYMATTER:os_eligibility_answer_t", eligibilityPlistPath],
            timeoutSeconds: 5
        )
        return Int(res.stdout)
    }

    public static func refreshEligibilityDaemons(log: ((String) -> Void)? = nil) throws {
        let locked = detectLockedEligibilityFiles()
        if !locked.isEmpty {
            throw SystemDiagnosticsError.eligibilityFilesLocked(locked)
        }

        let beforeStamp = fileStamp(path: eligibilityPlistPath)
        let oldPID = firstPID(processName: "eligibilityd")

        if let oldPID {
            log?("正在終止舊的 eligibilityd (pid=\(oldPID))…")
            let termRes = runCommand("/usr/bin/killall", arguments: ["-TERM", "eligibilityd"])
            if termRes.exitCode != 0 && firstPID(processName: "eligibilityd") == oldPID {
                throw SystemDiagnosticsError.commandFailed("無法終止 eligibilityd：\(termRes.stderr)")
            }
            for _ in 0..<10 {
                if firstPID(processName: "eligibilityd") != oldPID {
                    break
                }
                Thread.sleep(forTimeInterval: 1.0)
            }
            if firstPID(processName: "eligibilityd") == oldPID {
                throw SystemDiagnosticsError.refreshTimedOut("eligibilityd 未能在 10 秒內退出。")
            }
        }

        let notifyRes = runCommand(
            "/usr/bin/notifyutil",
            arguments: ["-p", "AFLanguageCodeDidChangeDarwinNotification"]
        )
        if notifyRes.exitCode != 0 {
            throw SystemDiagnosticsError.commandFailed("喚醒 eligibilityd 失敗：\(notifyRes.stderr)")
        }

        var refreshed = false
        var newPID: String?
        var answer: Int?
        for _ in 0..<30 {
            newPID = firstPID(processName: "eligibilityd")
            let currentStamp = fileStamp(path: eligibilityPlistPath)
            answer = greymatterAnswer()
            if let pid = newPID, pid != oldPID, !currentStamp.isEmpty, currentStamp != beforeStamp, answer != nil {
                refreshed = true
                if answer == 4 {
                    break
                }
            }
            Thread.sleep(forTimeInterval: 1.0)
        }

        if !refreshed {
            throw SystemDiagnosticsError.refreshTimedOut(
                "30 秒內未觀察到新的 eligibilityd 更新資格檔 (pid=\(newPID ?? "none"), GREYMATTER=\(answer.map(String.init) ?? "unknown"))"
            )
        }
        log?("eligibilityd 已重新計算 (pid=\(newPID ?? "?"), GREYMATTER=\(answer ?? -1))")

        // modelcatalogd must NOT receive SIGTERM (it can hang on exit); use kickstart -k then SIGKILL.
        refreshModelDaemon(name: "modelcatalogd", label: "com.apple.modelcatalogd", fallbackSignal: "KILL", log: log)
        refreshModelDaemon(name: "modelmanagerd", label: "com.apple.modelmanagerd", fallbackSignal: "TERM", log: log)
    }

    private static func refreshModelDaemon(
        name: String,
        label: String,
        fallbackSignal: String,
        log: ((String) -> Void)?
    ) {
        guard let oldPID = firstPID(processName: name) else {
            log?("\(name): 目前未執行，將於下次呼叫時重新啟動")
            return
        }
        let kickstartRes = runCommand("/bin/launchctl", arguments: ["kickstart", "-k", "system/\(label)"])
        if kickstartRes.exitCode != 0 {
            let sigRes = runCommand("/usr/bin/killall", arguments: ["-\(fallbackSignal)", name])
            if sigRes.exitCode != 0 {
                log?("注意: 無法重啟 \(name) (\(sigRes.stderr))")
                return
            }
        }
        for _ in 0..<10 {
            if firstPID(processName: name) != oldPID {
                break
            }
            Thread.sleep(forTimeInterval: 0.5)
        }
        log?("\(name) 已刷新 (原 pid=\(oldPID))")
    }
}
