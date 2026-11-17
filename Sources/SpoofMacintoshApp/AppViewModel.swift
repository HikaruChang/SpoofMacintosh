// Powered by NyphexAI, Developed by Hikaru(i@rua.moe)
// Licensed under the PolyForm Noncommercial License 1.0.0

import AppKit
import Foundation
import SpoofMacCore

enum SidebarTab: String, CaseIterable, Identifiable {
    case dashboard
    case editor
    case eligibility
    case setup

    var id: String { rawValue }

    var symbolName: String {
        switch self {
        case .dashboard: return "desktopcomputer"
        case .editor: return "slider.horizontal.3"
        case .eligibility: return "checkmark.seal"
        case .setup: return "wrench.and.screwdriver"
        }
    }

    func title(in lang: EffectiveLanguage) -> String {
        switch self {
        case .dashboard:
            return L(lang, zhHant: "系統概覽", zhHans: "系统概览", en: "Overview", ja: "概要")
        case .editor:
            return L(lang, zhHant: "全欄位偽裝編輯", zhHans: "全字段伪装编辑", en: "Spoof Editor", ja: "プロパティ編集")
        case .eligibility:
            return L(lang, zhHant: "功能解鎖體檢", zhHans: "功能解锁体检", en: "Eligibility", ja: "機能利用資格")
        case .setup:
            return L(lang, zhHant: "安裝與恢復指南", zhHans: "安装与恢复指南", en: "Setup & 1TR", ja: "導入・リカバリ")
        }
    }
}

enum EditorMode: String, CaseIterable, Identifiable {
    case keepNativeModel
    case presetModel
    case custom

    var id: String { rawValue }

    func title(in lang: EffectiveLanguage) -> String {
        switch self {
        case .keepNativeModel:
            return L(lang, zhHant: "保留原機機型", zhHans: "保留原机机型", en: "Keep Native Model", ja: "元の機種を維持")
        case .presetModel:
            return L(lang, zhHant: "預設機型庫", zhHans: "预设机型库", en: "Model Presets", ja: "機種プリセット")
        case .custom:
            return L(lang, zhHant: "完全自訂", zhHans: "完全自定义", en: "Custom Fields", ja: "完全カスタム")
        }
    }

    func subtitle(in lang: EffectiveLanguage) -> String {
        switch self {
        case .keepNativeModel:
            return L(lang, zhHant: "僅改地區／指定欄位", zhHans: "仅改地区/指定字段", en: "Region / specific keys only", ja: "地域や指定項目のみ変更")
        case .presetModel:
            return L(lang, zhHant: "M1–M6 共 59 款預設", zhHans: "M1–M6 共 59 款预设", en: "59 presets (M1–M6)", ja: "M1–M6 全59機種")
        case .custom:
            return L(lang, zhHant: "任意編輯全部屬性", zhHans: "任意编辑全部属性", en: "Edit any IORegistry key", ja: "全プロパティを自由編集")
        }
    }
}

@MainActor
final class AppViewModel: ObservableObject {
    static let keepRegionTag = "__keep__"
    static let customRegionTag = "__custom__"
    static let allChipFilterTag = "__all__"

    @Published var selectedTab: SidebarTab = .dashboard
    @Published var report: SystemDiagnosticReport
    @Published var showSensitiveValues: Bool = false
    @Published var appLanguage: AppLanguage {
        didSet {
            UserDefaults.standard.set(appLanguage.rawValue, forKey: AppLanguage.defaultsKey)
        }
    }

    // Editor states
    @Published var editorMode: EditorMode = .keepNativeModel
    @Published var selectedChipFilter: MacChipGeneration? = nil
    @Published var selectedPresetID: String = MacModelCatalog.flagshipPreset.modelIdentifier
    @Published var selectedRegionOption: String = "LL/A"
    @Published var syncPlatformNameWithPreset: Bool = true

    // Core fields
    @Published var spoofModel: String = ""
    @Published var spoofModelNumber: String = ""
    @Published var spoofRegionInfo: String = "LL/A"
    @Published var spoofRegulatoryModel: String = ""
    @Published var spoofTargetType: String = ""
    @Published var spoofTargetSubType: String = ""
    @Published var spoofCountryOfOrigin: String = "USA"
    @Published var spoofPlatformName: String = ""

    // Serial / UUID / MLB fields
    @Published var spoofSerialNumber: String = ""
    @Published var spoofRawSerialData: String = ""
    @Published var spoofUUID: String = ""
    @Published var spoofMLB: String = ""

    // Advanced DeviceTree / Firmware fields
    @Published var updateCompatible: Bool = true
    @Published var spoofCompatible: String = ""
    @Published var spoofManufacturer: String = ""
    @Published var spoofModelConfig: String = ""
    @Published var spoofConfigNumber: String = ""
    @Published var spoofDeviceType: String = ""
    @Published var spoofSecureRootPrefix: String = ""
    @Published var spoofNodeName: String = ""

    // Arbitrary custom fields
    @Published var customProperties: [CustomIORegProperty] = []

    // Operation state
    @Published var isBusy = false
    @Published var statusBannerMessage: String?
    @Published var errorMessage: String?
    @Published var lastCommandOutput: String = ""

    init() {
        if let savedRaw = UserDefaults.standard.string(forKey: AppLanguage.defaultsKey),
           let parsed = AppLanguage(rawValue: savedRaw) {
            self.appLanguage = parsed
        } else {
            self.appLanguage = .system
        }
        let initialReport = SystemDiagnostics.collectFullReport()
        self.report = initialReport
        syncEditorFromProfileOrDefaults(initialReport.savedProfile)
    }

    var lang: EffectiveLanguage {
        appLanguage.resolved
    }

    var filteredPresetModels: [MacModelPreset] {
        MacModelCatalog.models(for: selectedChipFilter)
    }

    var selectedPresetModel: MacModelPreset? {
        MacModelCatalog.model(matching: selectedPresetID)
    }

    var previewModel: String {
        spoofModel.isEmpty ? report.factoryIdentity.model : spoofModel
    }

    var previewModelNumber: String {
        spoofModelNumber.isEmpty ? report.factoryIdentity.modelNumber : spoofModelNumber
    }

    var previewRegionInfo: String {
        spoofRegionInfo.isEmpty ? report.factoryIdentity.regionInfo : spoofRegionInfo
    }

    var previewRegulatoryModel: String {
        spoofRegulatoryModel.isEmpty ? report.factoryIdentity.regulatoryModelNumber : spoofRegulatoryModel
    }

    var previewTargetType: String {
        spoofTargetType.isEmpty ? report.factoryIdentity.targetType : spoofTargetType
    }

    var previewTargetSubType: String {
        spoofTargetSubType.isEmpty ? report.factoryIdentity.targetSubType : spoofTargetSubType
    }

    var previewCombinedPartNumber: String {
        "\(previewModelNumber)\(previewRegionInfo)"
    }

    var previewCompatibleDisplay: String {
        if !spoofCompatible.trimmingCharacters(in: .whitespaces).isEmpty {
            return spoofCompatible
        }
        if !updateCompatible || (spoofModel.isEmpty && spoofTargetSubType.isEmpty) {
            let suffix = L(lang, zhHant: " (保留原廠)", zhHans: " (保留原厂)", en: " (Factory)", ja: " (出荷時維持)")
            return report.factoryIdentity.compatible.joined(separator: ", ") + suffix
        }
        return "\(previewTargetSubType)\\0\(previewModel)\\0AppleARM\\0"
    }

    func syncEditorFromProfileOrDefaults(_ saved: SpoofProfile?) {
        let profile = saved ?? SpoofProfile.regionOnlyUS()
        switch profile.mode {
        case .keepNativeModel:
            editorMode = .keepNativeModel
        case .presetModel(let presetId):
            editorMode = .presetModel
            if MacModelCatalog.model(matching: presetId) != nil {
                selectedPresetID = presetId
            }
        case .custom:
            editorMode = .custom
        }

        spoofModel = profile.spoofModel
        spoofModelNumber = profile.spoofModelNumber
        spoofRegionInfo = profile.spoofRegionInfo
        spoofRegulatoryModel = profile.spoofRegulatoryModel
        spoofTargetType = profile.spoofTargetType
        spoofTargetSubType = profile.spoofTargetSubType
        spoofCountryOfOrigin = profile.spoofCountryOfOrigin
        spoofPlatformName = profile.spoofPlatformName

        spoofSerialNumber = profile.spoofSerialNumber
        spoofRawSerialData = profile.spoofRawSerialData
        spoofUUID = profile.spoofUUID
        spoofMLB = profile.spoofMLB

        updateCompatible = profile.updateCompatible
        spoofCompatible = profile.spoofCompatible
        spoofManufacturer = profile.spoofManufacturer
        spoofModelConfig = profile.spoofModelConfig
        spoofConfigNumber = profile.spoofConfigNumber
        spoofDeviceType = profile.spoofDeviceType
        spoofSecureRootPrefix = profile.spoofSecureRootPrefix
        spoofNodeName = profile.spoofNodeName

        customProperties = profile.customProperties

        if spoofRegionInfo.isEmpty && spoofCountryOfOrigin.isEmpty {
            selectedRegionOption = Self.keepRegionTag
        } else if let matched = MacModelCatalog.region(matching: spoofRegionInfo),
                  matched.countryCode3 == spoofCountryOfOrigin {
            selectedRegionOption = matched.regionCode
        } else {
            selectedRegionOption = Self.customRegionTag
        }
    }

    func switchEditorMode(_ newMode: EditorMode) {
        editorMode = newMode
        switch newMode {
        case .keepNativeModel:
            spoofModel = ""
            spoofModelNumber = ""
            spoofRegulatoryModel = ""
            spoofTargetType = ""
            spoofTargetSubType = ""
            spoofPlatformName = ""
        case .presetModel:
            applyPresetFields(modelID: selectedPresetID)
        case .custom:
            let f = report.factoryIdentity
            if spoofModel.isEmpty { spoofModel = f.model }
            if spoofModelNumber.isEmpty { spoofModelNumber = f.modelNumber }
            if spoofRegulatoryModel.isEmpty { spoofRegulatoryModel = f.regulatoryModelNumber }
            if spoofTargetType.isEmpty { spoofTargetType = f.targetType }
            if spoofTargetSubType.isEmpty { spoofTargetSubType = f.targetSubType }
            if spoofPlatformName.isEmpty { spoofPlatformName = f.platformName }
        }
    }

    func selectChipFilterTag(_ tag: String) {
        let gen = (tag == Self.allChipFilterTag) ? nil : MacChipGeneration(rawValue: tag)
        selectChipFilter(gen)
    }

    func selectChipFilter(_ generation: MacChipGeneration?) {
        selectedChipFilter = generation
        let models = MacModelCatalog.models(for: generation)
        if !models.contains(where: { $0.modelIdentifier == selectedPresetID }), let first = models.first {
            selectedPresetID = first.modelIdentifier
            if editorMode == .presetModel {
                applyPresetFields(modelID: first.modelIdentifier)
            }
        }
    }

    func applyPresetFields(modelID: String) {
        selectedPresetID = modelID
        guard let preset = MacModelCatalog.model(matching: modelID) else { return }
        spoofModel = preset.modelIdentifier
        spoofModelNumber = preset.defaultModelNumber
        spoofRegulatoryModel = preset.regulatoryModelNumber
        spoofTargetType = preset.targetType
        spoofTargetSubType = preset.targetSubType
        if syncPlatformNameWithPreset {
            spoofPlatformName = preset.platformName
        }
    }

    func selectRegionOption(_ option: String) {
        selectedRegionOption = option
        if option == Self.keepRegionTag {
            spoofRegionInfo = ""
            spoofCountryOfOrigin = ""
        } else if let matched = MacModelCatalog.region(matching: option) {
            spoofRegionInfo = matched.regionCode
            spoofCountryOfOrigin = matched.countryCode3
        }
    }

    func fillAllFactoryValues() {
        let f = report.factoryIdentity
        editorMode = .custom
        spoofModel = f.model
        spoofModelNumber = f.modelNumber
        spoofRegionInfo = f.regionInfo
        spoofRegulatoryModel = f.regulatoryModelNumber
        spoofTargetType = f.targetType
        spoofTargetSubType = f.targetSubType
        spoofCountryOfOrigin = f.countryOfOrigin
        spoofPlatformName = f.platformName
        spoofSerialNumber = f.serialNumber
        spoofRawSerialData = f.rawSerialNumber
        spoofUUID = f.hardwareUUID
        spoofMLB = f.mlbSerialNumber
        spoofManufacturer = f.manufacturer
        spoofModelConfig = f.modelConfig
        spoofConfigNumber = f.configNumber
        spoofDeviceType = f.deviceType
        spoofSecureRootPrefix = f.secureRootPrefix
        spoofNodeName = f.nodeName
        spoofCompatible = f.compatible.joined(separator: ", ")
        selectedRegionOption = Self.customRegionTag
    }

    func generateRandomSerial() {
        spoofSerialNumber = RandomIdentityGenerator.generateSerialNumber()
    }

    func generateRandomUUID() {
        spoofUUID = RandomIdentityGenerator.generateUUID()
    }

    func generateRandomMLB() {
        spoofMLB = RandomIdentityGenerator.generateMLB()
    }

    func addCustomProperty(key: String = "", type: CustomPropertyValueType = .cstring, value: String = "") {
        customProperties.append(CustomIORegProperty(key: key, type: type, value: value))
    }

    func removeCustomProperty(id: UUID) {
        customProperties.removeAll { $0.id == id }
    }

    func buildProfileFromEditor() -> SpoofProfile {
        let mode: SpoofMode
        switch editorMode {
        case .keepNativeModel: mode = .keepNativeModel
        case .presetModel: mode = .presetModel(selectedPresetID)
        case .custom: mode = .custom
        }
        func clean(_ s: String) -> String {
            s.trimmingCharacters(in: .whitespacesAndNewlines)
        }
        return SpoofProfile(
            mode: mode,
            spoofModel: clean(spoofModel),
            spoofModelNumber: clean(spoofModelNumber),
            spoofRegionInfo: clean(spoofRegionInfo),
            spoofRegulatoryModel: clean(spoofRegulatoryModel),
            spoofTargetType: clean(spoofTargetType),
            spoofTargetSubType: clean(spoofTargetSubType),
            spoofCountryOfOrigin: clean(spoofCountryOfOrigin),
            spoofPlatformName: clean(spoofPlatformName),
            spoofSerialNumber: clean(spoofSerialNumber),
            spoofRawSerialData: clean(spoofRawSerialData),
            spoofUUID: clean(spoofUUID),
            spoofMLB: clean(spoofMLB),
            updateCompatible: updateCompatible,
            spoofCompatible: clean(spoofCompatible),
            spoofManufacturer: clean(spoofManufacturer),
            spoofModelConfig: clean(spoofModelConfig),
            spoofConfigNumber: clean(spoofConfigNumber),
            spoofDeviceType: clean(spoofDeviceType),
            spoofSecureRootPrefix: clean(spoofSecureRootPrefix),
            spoofNodeName: clean(spoofNodeName),
            customProperties: customProperties
        )
    }

    func reloadStatus() {
        report = SystemDiagnostics.collectFullReport()
    }

    func applyCurrentEditorProfile() {
        let profile = buildProfileFromEditor()
        let currentLang = self.lang
        let msg = L(lang,
                    zhHant: "已動態套用全欄位偽裝設定並完成系統資格重算。",
                    zhHans: "已动态套用全字段伪装设置并完成系统资格重算。",
                    en: "Applied all spoofing properties and recalculated system eligibility.",
                    ja: "全フィールドの偽装設定を適用し、システム資格を再計算しました。")
        runAsyncTask(successMessage: msg) {
            try profile.validate()
            return try await PrivilegedHelper.applyProfilePrivileged(profile, language: currentLang)
        }
    }

    func applyQuickUnlockUSRegionOnly() {
        let profile = SpoofProfile.regionOnlyUS()
        let currentLang = self.lang
        syncEditorFromProfileOrDefaults(profile)
        let msg = L(lang,
                    zhHant: "已一鍵套用美版區域解鎖（保留原機型號 + LL/A）。",
                    zhHans: "已一键套用美版区域解锁（保留原机型号 + LL/A）。",
                    en: "Applied US (LL/A) region unlock while preserving native Mac model.",
                    ja: "元の機種を維持したまま米国版 (LL/A) リージョンを適用しました。")
        runAsyncTask(successMessage: msg) {
            try await PrivilegedHelper.applyProfilePrivileged(profile, language: currentLang)
        }
    }

    func applyQuickFlagshipUS() {
        let profile = SpoofProfile.fromPreset(
            MacModelCatalog.flagshipPreset,
            region: MacModelCatalog.usRegionPreset,
            includePlatformName: true
        )
        let currentLang = self.lang
        syncEditorFromProfileOrDefaults(profile)
        let msg = L(lang,
                    zhHant: "已一鍵偽裝為旗艦機型 \(MacModelCatalog.flagshipPreset.modelIdentifier) 美版 (LL/A)。",
                    zhHans: "已一键伪装为旗舰机型 \(MacModelCatalog.flagshipPreset.modelIdentifier) 美版 (LL/A)。",
                    en: "Spoofed to flagship \(MacModelCatalog.flagshipPreset.modelIdentifier) (LL/A).",
                    ja: "フラッグシップ機種 \(MacModelCatalog.flagshipPreset.modelIdentifier) (LL/A) に偽装しました。")
        runAsyncTask(successMessage: msg) {
            try await PrivilegedHelper.applyProfilePrivileged(profile, language: currentLang)
        }
    }

    func resetToFactory() {
        let currentLang = self.lang
        let msg = L(lang,
                    zhHant: "已將所有 IORegistry 屬性（含序號與自訂欄位）還原為出廠預設值。",
                    zhHans: "已将所有 IORegistry 属性（含序列号与自定义字段）还原为出厂默认值。",
                    en: "Restored all IORegistry properties (including serials & custom keys) to factory defaults.",
                    ja: "すべての IORegistry プロパティを出荷時の状態に復元しました。")
        runAsyncTask(successMessage: msg) {
            try await PrivilegedHelper.resetToFactoryPrivileged(language: currentLang)
        }
    }

    func refreshEligibility() {
        let currentLang = self.lang
        let msg = L(lang,
                    zhHant: "已完成全領域 os_eligibility 資格重算。",
                    zhHans: "已完成全领域 os_eligibility 资格重算。",
                    en: "Recalculated all os_eligibility feature domains.",
                    ja: "全 os_eligibility ドメインの再計算が完了しました。")
        runAsyncTask(successMessage: msg) {
            try await PrivilegedHelper.refreshEligibilityPrivileged(language: currentLang)
        }
    }

    func runInstallAction(_ action: String, label: String) {
        let suffix = L(lang, zhHant: "完成。", zhHans: "完成。", en: "completed.", ja: "が完了しました。")
        runAsyncTask(successMessage: "\(label) \(suffix)") {
            try await PrivilegedHelper.runInstallActionPrivileged(action)
        }
    }

    func copyDiagnoseReportToClipboard() {
        reloadStatus()
        let text = report.formatPlainText(redactSensitive: !showSensitiveValues, language: lang)
        NSPasteboard.general.clearContents()
        NSPasteboard.general.setString(text, forType: .string)
        statusBannerMessage = L(lang,
                                zhHant: "已複製純文字診斷報告到剪貼簿。",
                                zhHans: "已复制纯文本诊断报告到剪贴板。",
                                en: "Copied plain-text diagnostic report to clipboard.",
                                ja: "診断レポートをクリップボードにコピーしました。")
    }

    private func runAsyncTask(successMessage: String, operation: @escaping () async throws -> String) {
        isBusy = true
        errorMessage = nil
        statusBannerMessage = nil

        Task {
            do {
                let output = try await operation()
                self.lastCommandOutput = output
                self.reloadStatus()
                self.statusBannerMessage = successMessage
            } catch {
                self.errorMessage = error.localizedDescription
            }
            self.isBusy = false
        }
    }
}
