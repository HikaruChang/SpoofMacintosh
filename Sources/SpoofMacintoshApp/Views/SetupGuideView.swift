// Powered by NyphexAI, Developed by Hikaru(i@rua.moe)
// Licensed under the PolyForm Noncommercial License 1.0.0

import SpoofMacCore
import SwiftUI

struct SetupGuideView: View {
    @ObservedObject var viewModel: AppViewModel

    var body: some View {
        let lang = viewModel.lang
        ScrollView {
            VStack(alignment: .leading, spacing: 18) {
                Text(L(lang, zhHant: "安裝管理與恢復模式 (1TR) 設定指南", zhHans: "安装管理与恢复模式 (1TR) 设置指南", en: "Installation & Recovery Mode (1TR) Guide", ja: "導入管理・リカバリモード (1TR) 設定ガイド"))
                    .font(.title2.bold())

                installControlCard(lang: lang)

                recoveryInstructionsCard(lang: lang)

                if !viewModel.lastCommandOutput.isEmpty {
                    VStack(alignment: .leading, spacing: 8) {
                        Text(L(lang, zhHant: "最近一次操作輸出", zhHans: "最近一次操作输出", en: "Last Command Output", ja: "直近のコマンド出力"))
                            .font(.headline)
                        Text(viewModel.lastCommandOutput)
                            .font(.caption.monospaced())
                            .textSelection(.enabled)
                            .padding(12)
                            .frame(maxWidth: .infinity, alignment: .leading)
                            .background(RoundedRectangle(cornerRadius: 8).fill(Color.black.opacity(0.06)))
                    }
                }
            }
            .padding(22)
        }
    }

    private func installControlCard(lang: EffectiveLanguage) -> some View {
        let sec = viewModel.report.security
        let yesLabel = L(lang, zhHant: "已安裝 ✓", zhHans: "已安装 ✓", en: "Installed ✓", ja: "導入済み ✓")
        let noLabel = L(lang, zhHant: "未安裝", zhHans: "未安装", en: "Not Installed", ja: "未導入")

        return VStack(alignment: .leading, spacing: 12) {
            Text(L(lang, zhHant: "系統元件安裝與維護", zhHans: "系统组件安装与维护", en: "System Components & Maintenance", ja: "システムコンポーネントの導入と管理"))
                .font(.headline)

            HStack(spacing: 18) {
                Label("Kext (/Library/Extensions): \(sec.kextInstalledToSystem ? yesLabel : noLabel)", systemImage: sec.kextInstalledToSystem ? "checkmark.circle.fill" : "circle")
                    .foregroundStyle(sec.kextInstalledToSystem ? .green : .secondary)
                Label("LaunchDaemon: \(sec.launchDaemonInstalled ? yesLabel : noLabel)", systemImage: sec.launchDaemonInstalled ? "checkmark.circle.fill" : "circle")
                    .foregroundStyle(sec.launchDaemonInstalled ? .green : .secondary)
            }
            .font(.callout)

            HStack(spacing: 12) {
                Button {
                    let label = L(lang, zhHant: "安裝／更新 SpoofMac.kext 與開機服務", zhHans: "安装/更新 SpoofMac.kext 与开机服务", en: "Install / Update Kext & Daemon", ja: "Kext と起動サービスの導入／更新")
                    viewModel.runInstallAction("install", label: label)
                } label: {
                    Label(L(lang, zhHant: "安裝 / 更新 Kext 與開機服務", zhHans: "安装 / 更新 Kext 与开机服务", en: "Install / Update Kext & Daemon", ja: "Kext と起動サービスを導入"), systemImage: "square.and.arrow.down.fill")
                }
                .buttonStyle(.borderedProminent)
                .disabled(viewModel.isBusy)

                Button {
                    let label = L(lang, zhHant: "完整卸載並恢復出廠硬體識別", zhHans: "完整卸载并恢复出厂硬件识别", en: "Full Uninstall & Factory Restore", ja: "完全アンインストール・出荷時復元")
                    viewModel.runInstallAction("uninstall", label: label)
                } label: {
                    Label(L(lang, zhHant: "完整卸載並還原原廠值", zhHans: "完整卸载并还原原厂值", en: "Uninstall & Restore", ja: "アンインストールして復元"), systemImage: "trash")
                }
                .buttonStyle(.bordered)
                .tint(.red)
                .disabled(viewModel.isBusy)

                Spacer()

                Button {
                    viewModel.copyDiagnoseReportToClipboard()
                } label: {
                    Label(L(lang, zhHant: "複製純文字診斷報告", zhHans: "复制纯文本诊断报告", en: "Copy Diagnostic Report", ja: "診断レポートをコピー"), systemImage: "doc.on.doc")
                }
                .buttonStyle(.bordered)
            }
        }
        .padding(16)
        .background(RoundedRectangle(cornerRadius: 12).fill(Color(nsColor: .controlBackgroundColor)))
        .overlay(RoundedRectangle(cornerRadius: 12).stroke(Color.primary.opacity(0.08)))
    }

    private func recoveryInstructionsCard(lang: EffectiveLanguage) -> some View {
        VStack(alignment: .leading, spacing: 10) {
            Text(L(lang, zhHant: "Apple Silicon 前置步驟（首次安裝需於 1TR 恢復模式完成，順序不可顛倒）", zhHans: "Apple Silicon 前置步骤（首次安装需于 1TR 恢复模式完成，顺序不可颠倒）", en: "Apple Silicon Prerequisites (1TR Recovery Mode — Exact Order Required)", ja: "Apple Silicon 前提手順（1TR リカバリモードでの順序厳守）"))
                .font(.headline)
            Divider()
            StepRow(
                number: "1",
                title: L(lang, zhHant: "開啟「允許第三方核心擴展」啟動安全性原則", zhHans: "开启「允许第三方内核扩展」启动安全性策略", en: "Enable User Management of Kernel Extensions", ja: "サードパーティ製カーネル機能拡張の管理を許可"),
                detail: L(lang,
                          zhHant: "關機後長按電源鍵進入「選項 (Options)」→ 上方選單「實用工具 → 啟動安全性實用工具」→ 選擇目前系統磁碟 → 點選「安全策略… → 降低安全性」並勾選「允許使用者管理來自已識別開發者的核心擴展」。",
                          zhHans: "关机后长按电源键进入「选项 (Options)」→ 上方菜单「实用工具 → 启动安全性实用工具」→ 选择当前系统磁盘 → 点选「安全策略… → 降低安全性」并勾选「允许用户管理来自已识别开发者的内核扩展」。",
                          en: "Shut down, hold Power to enter Options -> Utilities -> Startup Security Utility -> Select boot disk -> Security Policy -> Reduced Security -> check 'Allow user management of kernel extensions from identified developers'.",
                          ja: "システム終了後、電源ボタン長押しで「オプション」→「ユーティリティ → 起動セキュリティユーティリティ」→「低セキュリティ」を選択し「確認済みの開発元から提供されたカーネル機能拡張のユーザ管理を許可」にチェックを入れます。")
            )
            StepRow(
                number: "2",
                title: L(lang, zhHant: "在同一輪恢復模式中豁免 Kext 簽章檢查（必須在步驟 1 之後）", zhHans: "在同一轮恢复模式中豁免 Kext 签名检查（必须在步骤 1 之后）", en: "Exempt Kext Signing in the Same Recovery Session (After Step 1)", ja: "同じリカバリセッション内で Kext 署名チェックを除外（手順 1 の直後）"),
                detail: L(lang,
                          zhHant: "切勿重開機，直接打開恢復模式的「實用工具 → 終端機」，執行：\n  csrutil enable --without kext\n（步驟 1 會重設 SIP 設定，因此務必先做步驟 1 再執行此指令；若系統不接受則改用 csrutil disable。）完成後執行 reboot。",
                          zhHans: "切勿重启，直接打开恢复模式的「实用工具 → 终端」，执行：\n  csrutil enable --without kext\n（步骤 1 会重置 SIP 设置，因此务必先做步骤 1 再执行此命令；若系统不接受则改用 csrutil disable。）完成后执行 reboot。",
                          en: "Do NOT reboot yet. Open Utilities -> Terminal in Recovery and run:\n  csrutil enable --without kext\n(Step 1 resets SIP, so this must run AFTER Step 1. Use 'csrutil disable' only if rejected.) Then run 'reboot'.",
                          ja: "再起動せず、そのまま「ユーティリティ → ターミナル」を開き次を実行します：\n  csrutil enable --without kext\n（手順 1 が SIP をリセットするため必ず手順 1 の後に実行してください。拒否される場合は csrutil disable を使用）完了後に reboot を実行します。")
            )
            StepRow(
                number: "3",
                title: L(lang, zhHant: "首次載入批准與重開機建立 AuxKC", zhHans: "首次加载批准与重启建立 AuxKC", en: "Approve Kext & Reboot to Build AuxKC", ja: "初回許可と AuxKC 再構築のための再起動"),
                detail: L(lang,
                          zhHant: "點選上方「安裝 / 更新 Kext 與開機服務」後，依提示前往「系統設定 → 隱私與安全性」底部批准 SpoofMac.kext 並重開機（首次重建 AuxKC 可能需要重開機兩次）。",
                          zhHans: "点击上方「安装 / 更新 Kext 与开机服务」后，按提示前往「系统设置 → 隐私与安全性」底部批准 SpoofMac.kext 并重启（首次重建 AuxKC 可能需要重启两次）。",
                          en: "Click 'Install / Update Kext & Daemon' above, approve SpoofMac.kext in System Settings -> Privacy & Security, and reboot (may require two reboots for AuxKC).",
                          ja: "上の「Kext と起動サービスを導入」を実行後、「システム設定 → プライバシーとセキュリティ」下部で SpoofMac.kext を許可し、再起動してください（初回は2回再起動が必要な場合があります）。")
            )
            StepRow(
                number: "4",
                title: L(lang, zhHant: "緊急復原參數 (boot-args)", zhHans: "紧急恢复参数 (boot-args)", en: "Emergency Bypass Boot-Arg", ja: "緊急バイパス引数 (boot-args)"),
                detail: L(lang,
                          zhHant: "若未來需要於不卸載 Kext 的狀況下暫時停用偽裝，可在恢復模式設定：nvram boot-args=\"spoof_off=1\"；請勿設定 amfi_get_out_of_my_way=1（會破壞 PCC 私密雲端運算）。",
                          zhHans: "若未来需要在不卸载 Kext 的情况下暂时停用伪装，可在恢复模式设置：nvram boot-args=\"spoof_off=1\"；请勿设置 amfi_get_out_of_my_way=1（会破坏 PCC 私密云计算）。",
                          en: "To temporarily disable spoofing without uninstalling the kext, set in Recovery: nvram boot-args=\"spoof_off=1\". Do NOT use amfi_get_out_of_my_way=1 (breaks PCC).",
                          ja: "Kext を削除せず一時的に偽装を無効化するにはリカバリで nvram boot-args=\"spoof_off=1\" を設定します。amfi_get_out_of_my_way=1 は使用しないでください（PCC が動作しなくなります）。")
            )
        }
        .padding(16)
        .background(RoundedRectangle(cornerRadius: 12).fill(Color(nsColor: .controlBackgroundColor)))
        .overlay(RoundedRectangle(cornerRadius: 12).stroke(Color.primary.opacity(0.08)))
    }
}

private struct StepRow: View {
    let number: String
    let title: String
    let detail: String

    var body: some View {
        HStack(alignment: .top, spacing: 12) {
            Text(number)
                .font(.caption.bold())
                .frame(width: 22, height: 22)
                .background(Circle().fill(Color.accentColor.opacity(0.2)))
                .foregroundStyle(Color.accentColor)
            VStack(alignment: .leading, spacing: 3) {
                Text(title)
                    .font(.subheadline.bold())
                Text(detail)
                    .font(.caption)
                    .foregroundStyle(.secondary)
                    .textSelection(.enabled)
                    .fixedSize(horizontal: false, vertical: true)
            }
        }
    }
}
