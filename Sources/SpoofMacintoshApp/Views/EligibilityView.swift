// Powered by NyphexAI, Developed by Hikaru(i@rua.moe)
// Licensed under the PolyForm Noncommercial License 1.0.0

import SpoofMacCore
import SwiftUI

struct EligibilityView: View {
    @ObservedObject var viewModel: AppViewModel

    var body: some View {
        let lang = viewModel.lang
        ScrollView {
            VStack(alignment: .leading, spacing: 18) {
                HStack {
                    VStack(alignment: .leading, spacing: 4) {
                        Text(L(lang, zhHant: "功能解鎖與資格體檢 (os_eligibility)", zhHans: "功能解锁与资格体检 (os_eligibility)", en: "Feature Eligibility Check (os_eligibility)", ja: "機能利用資格チェック (os_eligibility)"))
                            .font(.title2.bold())
                        Text(L(lang,
                               zhHant: "即時讀取 /private/var/db/eligibilityd/eligibility.plist 各功能域狀態，協助確認系統是否完成解鎖。",
                               zhHans: "实时读取 /private/var/db/eligibilityd/eligibility.plist 各功能域状态，协助确认系统是否完成解锁。",
                               en: "Live status of /private/var/db/eligibilityd/eligibility.plist feature domains.",
                               ja: "/private/var/db/eligibilityd/eligibility.plist の各機能ドメイン状態をリアルタイム表示します。"))
                            .font(.callout)
                            .foregroundStyle(.secondary)
                    }
                    Spacer()
                    Button {
                        viewModel.refreshEligibility()
                    } label: {
                        Label(
                            L(lang, zhHant: "強制重算全部系統資格", zhHans: "强制重算全部系统资格", en: "Recalculate All Eligibility", ja: "全資格を強制再計算"),
                            systemImage: "arrow.triangle.2.circlepath"
                        )
                    }
                    .buttonStyle(.borderedProminent)
                    .disabled(viewModel.isBusy)
                }

                if !viewModel.report.security.lockedEligibilityFiles.isEmpty {
                    HStack(spacing: 10) {
                        Image(systemName: "exclamationmark.octagon.fill")
                            .foregroundStyle(.red)
                        Text(L(lang,
                               zhHant: "偵測到資格檔被鎖定（uchg/schg），eligibilityd 無法寫入新資格：",
                               zhHans: "检测到资格文件被锁定（uchg/schg），eligibilityd 无法写入新资格：",
                               en: "Locked eligibility files detected (uchg/schg); eligibilityd cannot write updates:",
                               ja: "ロックされた資格ファイル (uchg/schg) が検出されました：") + "\n\(viewModel.report.security.lockedEligibilityFiles.joined(separator: "\n"))")
                            .font(.caption)
                    }
                    .padding(12)
                    .frame(maxWidth: .infinity, alignment: .leading)
                    .background(RoundedRectangle(cornerRadius: 10).fill(Color.red.opacity(0.12)))
                }

                LazyVGrid(columns: [GridItem(.flexible(), spacing: 12), GridItem(.flexible(), spacing: 12)], spacing: 12) {
                    ForEach(viewModel.report.eligibilityDomains) { domain in
                        DomainCard(domain: domain, lang: lang)
                    }
                }

                environmentChecklistCard(lang: lang)
            }
            .padding(22)
        }
    }

    private func environmentChecklistCard(lang: EffectiveLanguage) -> some View {
        let sec = viewModel.report.security
        return VStack(alignment: .leading, spacing: 10) {
            Text(L(lang, zhHant: "系統前提與環境檢查", zhHans: "系统前提与环境检查", en: "System Prerequisites Checklist", ja: "システム前提条件チェック"))
                .font(.headline)
            Divider()
            ChecklistRow(
                title: "Apple Silicon (arm64)",
                detail: "\(sec.architecture) · macOS \(sec.macOSVersion) (\(sec.macOSBuild))",
                passed: sec.isAppleSilicon
            )
            ChecklistRow(
                title: L(lang, zhHant: "SIP 允許第三方 Kext", zhHans: "SIP 允许第三方 Kext", en: "SIP Allows 3rd-Party Kext", ja: "SIP サードパーティ Kext 許可"),
                detail: sec.sipAllowsKext
                    ? (sec.sipFullyDisabled
                       ? L(lang, zhHant: "已完整關閉 SIP（可用）", zhHans: "已完整关闭 SIP（可用）", en: "SIP fully disabled (supported)", ja: "SIP 完全無効 (動作可能)")
                       : L(lang, zhHant: "已保留 SIP 並僅豁免 Kext 簽章 ✓", zhHans: "已保留 SIP 并仅豁免 Kext 签名 ✓", en: "SIP active, Kext signing disabled ✓", ja: "SIP 有効・Kext 署名のみ除外 ✓"))
                    : L(lang, zhHant: "Kext 簽章檢查仍開啟，無法載入 ad-hoc Kext", zhHans: "Kext 签名检查仍开启，无法加载 ad-hoc Kext", en: "Kext signing enforced; cannot load ad-hoc kext", ja: "Kext 署名チェックが有効なためロード不可"),
                passed: sec.sipAllowsKext
            )
            ChecklistRow(
                title: L(lang, zhHant: "本地啟動策略第三方 Kext (bputil)", zhHans: "本地启动策略第三方 Kext (bputil)", en: "Local Boot Policy 3rd-Party Kexts (bputil)", ja: "ローカル起動ポリシー (bputil)"),
                detail: "3rd Party Kexts Status: \(sec.thirdPartyKextsPolicy)",
                passed: sec.thirdPartyKextsPolicy == "enabled"
            )
            ChecklistRow(
                title: L(lang, zhHant: "AMFI 完整性 (PCC 私密雲端前提)", zhHans: "AMFI 完整性 (PCC 私密云端前提)", en: "AMFI Integrity (Required for PCC)", ja: "AMFI 整合性 (PCC クラウド要件)"),
                detail: sec.hasAmfiBypassBootArg
                    ? L(lang, zhHant: "發現 amfi_get_out_of_my_way，會破壞 PCC 憑證驗證！", zhHans: "发现 amfi_get_out_of_my_way，会破坏 PCC 凭证验证！", en: "amfi_get_out_of_my_way found — breaks PCC!", ja: "amfi_get_out_of_my_way 検出 — PCC が破損します！")
                    : L(lang, zhHant: "未發現顯式 AMFI 繞過參數 ✓", zhHans: "未发现显式 AMFI 绕过参数 ✓", en: "No explicit AMFI bypass boot-arg ✓", ja: "AMFI バイパス引数なし ✓"),
                passed: !sec.hasAmfiBypassBootArg
            )
            ChecklistRow(
                title: L(lang, zhHant: "系統與 Siri 語言設定", zhHans: "系统与 Siri 语言设置", en: "System & Siri Language", ja: "システム・Siri 言語設定"),
                detail: "AppleLanguages=\(sec.appleLanguages) | Siri=\(sec.siriLanguage)",
                passed: sec.siriLanguage.lowercased().hasPrefix("en") && sec.appleLanguages.lowercased().contains("en")
            )
        }
        .padding(16)
        .background(RoundedRectangle(cornerRadius: 12).fill(Color(nsColor: .controlBackgroundColor)))
        .overlay(RoundedRectangle(cornerRadius: 12).stroke(Color.primary.opacity(0.08)))
    }
}

private struct DomainCard: View {
    let domain: EligibilityDomainStatus
    let lang: EffectiveLanguage

    private var badgeColor: Color {
        if domain.answer == nil { return .secondary }
        return domain.isEligible ? .green : .orange
    }

    var body: some View {
        VStack(alignment: .leading, spacing: 8) {
            HStack(alignment: .center, spacing: 8) {
                Text(domain.displayName(in: lang))
                    .font(.headline)
                    .lineLimit(1)
                    .truncationMode(.tail)
                Spacer()
                StatusPill(text: domain.statusLabel(in: lang), color: badgeColor)
            }
            Text(domain.description(in: lang))
                .font(.caption)
                .foregroundStyle(.secondary)
                .fixedSize(horizontal: false, vertical: true)
            Spacer(minLength: 0)
            Text(domain.id)
                .font(.caption2.monospaced())
                .foregroundStyle(.tertiary)
                .lineLimit(1)
                .truncationMode(.middle)
        }
        .padding(14)
        .frame(maxWidth: .infinity, minHeight: 96, maxHeight: .infinity, alignment: .topLeading)
        .background(RoundedRectangle(cornerRadius: 12).fill(Color(nsColor: .controlBackgroundColor)))
        .overlay(RoundedRectangle(cornerRadius: 12).stroke(badgeColor.opacity(0.28)))
    }
}

private struct ChecklistRow: View {
    let title: String
    let detail: String
    let passed: Bool

    var body: some View {
        HStack(spacing: 10) {
            Image(systemName: passed ? "checkmark.circle.fill" : "exclamationmark.triangle.fill")
                .foregroundStyle(passed ? .green : .orange)
            VStack(alignment: .leading, spacing: 2) {
                Text(title)
                    .font(.subheadline.bold())
                Text(detail)
                    .font(.caption.monospaced())
                    .foregroundStyle(.secondary)
                    .lineLimit(1)
                    .truncationMode(.middle)
                    .help(detail)
            }
            Spacer()
        }
    }
}
