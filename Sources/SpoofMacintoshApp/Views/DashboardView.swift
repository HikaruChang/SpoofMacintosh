// Powered by NyphexAI, Developed by Hikaru(i@rua.moe)
// Licensed under the PolyForm Noncommercial License 1.0.0

import AppKit
import SpoofMacCore
import SwiftUI

struct DashboardView: View {
    @ObservedObject var viewModel: AppViewModel

    var body: some View {
        let lang = viewModel.lang
        ScrollView {
            VStack(alignment: .leading, spacing: 18) {
                headerCard(lang: lang)

                HStack(alignment: .top, spacing: 16) {
                    IdentityCard(
                        title: L(lang,
                                 zhHant: "目前生效硬體識別 (Active IORegistry)",
                                 zhHans: "当前生效硬件识别 (Active IORegistry)",
                                 en: "Active Hardware Identity (IORegistry)",
                                 ja: "現在のハードウェア識別 (IORegistry)"),
                        subtitle: viewModel.report.kextStatus.isSpoofActive
                            ? L(lang, zhHant: "正套用 SpoofMac 動態偽裝", zhHans: "正套用 SpoofMac 动态伪装", en: "SpoofMac dynamic overrides active", ja: "SpoofMac 動的偽装が有効")
                            : L(lang, zhHant: "目前為出廠原生屬性", zhHans: "当前为出厂原生属性", en: "Using factory hardware properties", ja: "出荷時のプロパティを使用中"),
                        accentColor: viewModel.report.kextStatus.isSpoofActive ? .blue : .secondary,
                        identity: viewModel.report.currentIdentity,
                        showSensitive: viewModel.showSensitiveValues,
                        customOverrides: viewModel.report.kextStatus.activeCustomProperties,
                        lang: lang
                    )
                    .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .topLeading)

                    IdentityCard(
                        title: L(lang,
                                 zhHant: "出廠真實硬體識別 (Factory Hardware)",
                                 zhHans: "出厂真实硬件识别 (Factory Hardware)",
                                 en: "Factory Hardware Identity",
                                 ja: "出荷時オリジナル識別 (Factory Hardware)"),
                        subtitle: viewModel.report.kextStatus.isKextServicePresent
                            ? L(lang, zhHant: "由核心擴展唯讀快照保護", zhHans: "由内核扩展只读快照保护", en: "Protected by kext factory snapshot", ja: "Kext の読み取り専用スナップショットで保護")
                            : L(lang, zhHant: "直接讀自裝置樹", zhHans: "直接读自设备树", en: "Read directly from DeviceTree", ja: "DeviceTree から直接取得"),
                        accentColor: .secondary,
                        identity: viewModel.report.factoryIdentity,
                        showSensitive: viewModel.showSensitiveValues,
                        customOverrides: [:],
                        lang: lang
                    )
                    .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .topLeading)
                }
                .fixedSize(horizontal: false, vertical: true)

                quickActionsCard(lang: lang)

                securityNoticeCard(lang: lang)
            }
            .padding(22)
        }
    }

    private var headerIconImage: NSImage? {
        if let pngURL = Bundle.main.url(forResource: "icon", withExtension: "png"),
           let image = NSImage(contentsOf: pngURL) {
            return image
        }
        return NSApplication.shared.applicationIconImage
    }

    private func headerCard(lang: EffectiveLanguage) -> some View {
        let current = viewModel.report.currentIdentity
        let kext = viewModel.report.kextStatus
        let gmEligible = viewModel.report.eligibilityDomains.first { $0.id == "OS_ELIGIBILITY_DOMAIN_GREYMATTER" }?.isEligible ?? false

        return HStack(alignment: .center, spacing: 16) {
            if let nsImage = headerIconImage {
                Image(nsImage: nsImage)
                    .resizable()
                    .interpolation(.high)
                    .frame(width: 56, height: 56)
            }
            VStack(alignment: .leading, spacing: 5) {
                HStack(spacing: 8) {
                    Text(L(lang, zhHant: "SpoofMacintosh 狀態總覽", zhHans: "SpoofMacintosh 状态总览", en: "SpoofMacintosh Overview", ja: "SpoofMacintosh ステータス概要"))
                        .font(.title2.bold())
                    StatusPill(
                        text: kext.isKextServicePresent
                            ? (kext.isSpoofActive
                               ? L(lang, zhHant: "偽裝生效中", zhHans: "伪装生效中", en: "Spoof Active", ja: "偽装有効")
                               : L(lang, zhHant: "Kext 已就緒", zhHans: "Kext 已就绪", en: "Kext Ready", ja: "Kext 準備完了"))
                            : L(lang, zhHant: "Kext 未載入", zhHans: "Kext 未加载", en: "Kext Not Loaded", ja: "Kext 未ロード"),
                        color: kext.isKextServicePresent ? (kext.isSpoofActive ? .green : .blue) : .orange
                    )
                    if gmEligible {
                        StatusPill(
                            text: L(lang, zhHant: "Apple 智能已解鎖", zhHans: "Apple 智能已解锁", en: "Apple Intelligence Eligible", ja: "Apple Intelligence 対応"),
                            color: .purple
                        )
                    }
                }
                Text("\(L(lang, zhHant: "組合銷售型號", zhHans: "组合销售型号", en: "Part", ja: "型番"))：\(current.combinedPartNumber)  ·  \(L(lang, zhHant: "監管型號", zhHans: "监管型号", en: "Reg", ja: "認証"))：\(current.regulatoryModelNumber)  ·  \(L(lang, zhHant: "識別碼", zhHans: "识别码", en: "Model", ja: "機種"))：\(current.model)")
                    .font(.callout.monospaced())
                    .foregroundStyle(.secondary)
                    .lineLimit(1)
                    .truncationMode(.middle)
                Text(SpoofMacMetadata.attribution)
                    .font(.caption)
                    .foregroundStyle(.tertiary)
            }
            Spacer(minLength: 0)
        }
        .padding(16)
        .background(RoundedRectangle(cornerRadius: 12).fill(Color(nsColor: .controlBackgroundColor)))
        .overlay(RoundedRectangle(cornerRadius: 12).stroke(Color.primary.opacity(0.08)))
    }

    private func quickActionsCard(lang: EffectiveLanguage) -> some View {
        VStack(alignment: .leading, spacing: 12) {
            Text(L(lang, zhHant: "快捷一鍵操作", zhHans: "快捷一键操作", en: "Quick Actions", ja: "クイックアクション"))
                .font(.headline)

            HStack(alignment: .top, spacing: 12) {
                QuickActionTile(
                    title: L(lang, zhHant: "美版全功能解鎖 (僅改地區)", zhHans: "美版全功能解锁 (仅改地区)", en: "Unlock US Region (LL/A Only)", ja: "米国版リージョン解除 (地域のみ)"),
                    subtitle: L(lang, zhHant: "保留原機型號，將 region-info 改為 LL/A (USA)", zhHans: "保留原机型号，将 region-info 改为 LL/A (USA)", en: "Preserve native model; set region-info = LL/A (USA)", ja: "元の機種を維持し region-info を LL/A (USA) に変更"),
                    systemImage: "globe.americas.fill",
                    accent: .blue,
                    isPrimary: true,
                    disabled: viewModel.isBusy
                ) {
                    viewModel.applyQuickUnlockUSRegionOnly()
                }

                QuickActionTile(
                    title: L(lang, zhHant: "偽裝旗艦 MacBook Pro M5 Max", zhHans: "伪装旗舰 MacBook Pro M5 Max", en: "Spoof Flagship M5 Max (LL/A)", ja: "最上位 M5 Max (LL/A) に偽装"),
                    subtitle: L(lang, zhHant: "套用 Mac17,6 · MX4Z4LL/A · A3429 全套預設", zhHans: "套用 Mac17,6 · MX4Z4LL/A · A3429 全套预设", en: "Apply full Mac17,6 · MX4Z4LL/A · A3429 preset", ja: "Mac17,6 · MX4Z4LL/A · A3429 一式を適用"),
                    systemImage: "laptopcomputer",
                    accent: .indigo,
                    isPrimary: false,
                    disabled: viewModel.isBusy
                ) {
                    viewModel.applyQuickFlagshipUS()
                }

                QuickActionTile(
                    title: L(lang, zhHant: "即時還原出廠預設", zhHans: "即时还原出厂预设", en: "Restore Factory Defaults", ja: "出荷時設定に即時復元"),
                    subtitle: L(lang, zhHant: "恢復所有欄位（含 SN / UUID / 自訂屬性）", zhHans: "恢复所有字段（含 SN / UUID / 自定义属性）", en: "Restore all fields (incl. SN / UUID / custom keys)", ja: "SN・UUID・カスタム項目を含め全て復元"),
                    systemImage: "arrow.uturn.backward.circle",
                    accent: .orange,
                    isPrimary: false,
                    disabled: viewModel.isBusy
                ) {
                    viewModel.resetToFactory()
                }
            }
            .fixedSize(horizontal: false, vertical: true)
        }
        .padding(16)
        .background(RoundedRectangle(cornerRadius: 12).fill(Color(nsColor: .controlBackgroundColor)))
        .overlay(RoundedRectangle(cornerRadius: 12).stroke(Color.primary.opacity(0.08)))
    }

    private func securityNoticeCard(lang: EffectiveLanguage) -> some View {
        HStack(alignment: .center, spacing: 12) {
            Image(systemName: "info.circle.fill")
                .font(.title2)
                .foregroundStyle(.blue)
            VStack(alignment: .leading, spacing: 4) {
                Text(L(lang, zhHant: "全欄位動態偽裝與原廠安全快照", zhHans: "全字段动态伪装与原厂安全快照", en: "Full-Property Spoofing & Factory Snapshots", ja: "全フィールド動的偽装と出荷時スナップショット"))
                    .font(.subheadline.bold())
                Text(L(lang,
                       zhHant: "SpoofMac.kext 已支援修改機型、型號、地區、SN (IOPlatformSerialNumber)、UUID、MLB 及任意 IOPlatformExpertDevice 屬性，並在修改前自動備份原廠值以支援一鍵無損還原。提醒：修改 SN / UUID / MLB 可能影響 iCloud、FaceTime 與 PCC 憑證，若僅為了解鎖地區功能建議保留原廠序號。",
                       zhHans: "SpoofMac.kext 已支持修改机型、型号、地区、SN (IOPlatformSerialNumber)、UUID、MLB 及任意 IOPlatformExpertDevice 属性，并在修改前自动备份原厂值以支持一键无损还原。提醒：修改 SN / UUID / MLB 可能影响 iCloud、FaceTime 与 PCC 凭证，若仅为了解锁地区功能建议保留原厂序列号。",
                       en: "SpoofMac.kext supports modifying model, part number, region, SN (IOPlatformSerialNumber), UUID, MLB, and any IOPlatformExpertDevice property while snapshotting factory values for instant restoration. Note: altering SN/UUID/MLB may affect iCloud, FaceTime, and PCC attestation.",
                       ja: "SpoofMac.kext は機種・型番・地域・SN・UUID・MLB など IOPlatformExpertDevice の全項目を動的変更でき、変更前に出荷時値を自動保護してワンクリック復元に対応します。注意：SN/UUID/MLB を変更すると iCloud や PCC 認証に影響する場合があります。"))
                    .font(.caption)
                    .foregroundStyle(.secondary)
                    .fixedSize(horizontal: false, vertical: true)
            }
        }
        .padding(14)
        .frame(maxWidth: .infinity, alignment: .leading)
        .background(RoundedRectangle(cornerRadius: 12).fill(Color.blue.opacity(0.07)))
    }
}

private struct QuickActionTile: View {
    let title: String
    let subtitle: String
    let systemImage: String
    let accent: Color
    let isPrimary: Bool
    let disabled: Bool
    let action: () -> Void

    var body: some View {
        Button(action: action) {
            VStack(alignment: .leading, spacing: 6) {
                Label(title, systemImage: systemImage)
                    .font(.subheadline.bold())
                    .foregroundStyle(isPrimary ? Color.white : accent)
                    .lineLimit(1)
                Text(subtitle)
                    .font(.caption)
                    .foregroundStyle(isPrimary ? Color.white.opacity(0.88) : .secondary)
                    .fixedSize(horizontal: false, vertical: true)
            }
            .padding(12)
            .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .topLeading)
            .background(
                RoundedRectangle(cornerRadius: 10)
                    .fill(isPrimary ? accent : Color(nsColor: .windowBackgroundColor))
            )
            .overlay(
                RoundedRectangle(cornerRadius: 10)
                    .stroke(isPrimary ? Color.clear : accent.opacity(0.35), lineWidth: 1)
            )
            .contentShape(RoundedRectangle(cornerRadius: 10))
        }
        .buttonStyle(.plain)
        .disabled(disabled)
        .opacity(disabled ? 0.55 : 1.0)
    }
}

private struct IdentityCard: View {
    let title: String
    let subtitle: String
    let accentColor: Color
    let identity: HardwareIdentitySnapshot
    let showSensitive: Bool
    let customOverrides: [String: String]
    let lang: EffectiveLanguage

    var body: some View {
        VStack(alignment: .leading, spacing: 8) {
            VStack(alignment: .leading, spacing: 2) {
                Text(title)
                    .font(.headline)
                Text(subtitle)
                    .font(.caption)
                    .foregroundStyle(.secondary)
            }
            Divider()
            KeyValueRow(label: L(lang, zhHant: "機型識別碼 (model)", zhHans: "机型识别码 (model)", en: "Model ID (model)", ja: "モデルID (model)"), value: identity.model)
            KeyValueRow(label: L(lang, zhHant: "組合銷售型號", zhHans: "组合销售型号", en: "Combined Part Number", ja: "販売型番 (Combined)"), value: identity.combinedPartNumber)
            KeyValueRow(label: "model-number", value: identity.modelNumber)
            KeyValueRow(label: "region-info", value: identity.regionInfo)
            KeyValueRow(label: "regulatory-model-number", value: identity.regulatoryModelNumber)
            KeyValueRow(label: "target / sub-type", value: "\(identity.targetType) / \(identity.targetSubType)")
            KeyValueRow(label: "platform-name", value: identity.platformName)
            KeyValueRow(label: "country-of-origin", value: identity.countryOfOrigin)
            Divider()
            KeyValueRow(
                label: "IOPlatformSerialNumber",
                value: HardwareIdentitySnapshot.masked(identity.serialNumber, revealed: showSensitive)
            )
            KeyValueRow(
                label: "IOPlatformUUID",
                value: HardwareIdentitySnapshot.masked(identity.hardwareUUID, revealed: showSensitive)
            )
            KeyValueRow(
                label: "mlb-serial-number",
                value: HardwareIdentitySnapshot.masked(identity.mlbSerialNumber, revealed: showSensitive)
            )
            KeyValueRow(label: "manufacturer", value: identity.manufacturer)
            KeyValueRow(label: "compatible", value: identity.compatible.joined(separator: ", "))
            if !customOverrides.isEmpty {
                Divider()
                ForEach(customOverrides.keys.sorted(), id: \.self) { key in
                    KeyValueRow(label: "\(L(lang, zhHant: "自訂", zhHans: "自定义", en: "Custom", ja: "カスタム")): \(key)", value: customOverrides[key] ?? "")
                }
            }
            Spacer(minLength: 0)
        }
        .padding(16)
        .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .topLeading)
        .background(RoundedRectangle(cornerRadius: 12).fill(Color(nsColor: .controlBackgroundColor)))
        .overlay(RoundedRectangle(cornerRadius: 12).stroke(accentColor.opacity(0.25)))
    }
}

private struct KeyValueRow: View {
    let label: String
    let value: String

    var body: some View {
        HStack(alignment: .center, spacing: 8) {
            Text(label)
                .font(.caption)
                .foregroundStyle(.secondary)
                .lineLimit(1)
                .fixedSize(horizontal: true, vertical: false)
            Spacer(minLength: 8)
            Text(value.isEmpty ? "—" : value)
                .font(.caption.monospaced())
                .lineLimit(1)
                .truncationMode(.middle)
                .textSelection(.enabled)
                .help(value)
        }
    }
}
