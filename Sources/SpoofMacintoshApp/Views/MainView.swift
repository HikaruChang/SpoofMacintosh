// Powered by NyphexAI, Developed by Hikaru(i@rua.moe)
// Licensed under the PolyForm Noncommercial License 1.0.0

import SpoofMacCore
import SwiftUI

struct MainView: View {
    @ObservedObject var viewModel: AppViewModel

    var body: some View {
        let lang = viewModel.lang
        NavigationSplitView {
            List(SidebarTab.allCases, selection: $viewModel.selectedTab) { tab in
                Label(tab.title(in: lang), systemImage: tab.symbolName)
                    .tag(tab)
            }
            .listStyle(.sidebar)
            .safeAreaInset(edge: .bottom) {
                sidebarFooter(lang: lang)
            }
            .navigationSplitViewColumnWidth(min: 205, ideal: 225, max: 255)
        } detail: {
            VStack(spacing: 0) {
                if let banner = viewModel.statusBannerMessage {
                    BannerBar(message: banner, isError: false) {
                        viewModel.statusBannerMessage = nil
                    }
                }
                if let err = viewModel.errorMessage {
                    BannerBar(message: err, isError: true) {
                        viewModel.errorMessage = nil
                    }
                }

                Group {
                    switch viewModel.selectedTab {
                    case .dashboard:
                        DashboardView(viewModel: viewModel)
                    case .editor:
                        ModelSpoofEditorView(viewModel: viewModel)
                    case .eligibility:
                        EligibilityView(viewModel: viewModel)
                    case .setup:
                        SetupGuideView(viewModel: viewModel)
                    }
                }
                .frame(maxWidth: .infinity, maxHeight: .infinity)

                if viewModel.isBusy {
                    Divider()
                    HStack(spacing: 10) {
                        ProgressView()
                            .controlSize(.small)
                        Text(L(lang,
                               zhHant: "正在執行系統核心／資格更新作業，請稍候…",
                               zhHans: "正在执行系统内核/资格更新操作，请稍候…",
                               en: "Executing kernel / eligibility operation, please wait…",
                               ja: "カーネル・利用資格の更新を実行中です…"))
                            .font(.caption)
                            .foregroundStyle(.secondary)
                        Spacer()
                    }
                    .padding(.horizontal, 16)
                    .padding(.vertical, 8)
                    .background(Color(nsColor: .controlBackgroundColor))
                }
            }
            .navigationTitle(viewModel.selectedTab.title(in: lang))
            .toolbar {
                ToolbarItemGroup(placement: .automatic) {
                    Menu {
                        ForEach(AppLanguage.allCases) { option in
                            Button {
                                viewModel.appLanguage = option
                            } label: {
                                HStack {
                                    Text(option.menuTitle(in: lang))
                                    if viewModel.appLanguage == option {
                                        Spacer()
                                        Image(systemName: "checkmark")
                                    }
                                }
                            }
                        }
                    } label: {
                        Label(viewModel.appLanguage.resolved.nativeName, systemImage: "globe")
                    }
                    .help(L(lang, zhHant: "切換介面語言", zhHans: "切换界面语言", en: "Switch Language", ja: "表示言語を切り替え"))

                    Button {
                        viewModel.showSensitiveValues.toggle()
                    } label: {
                        Label(
                            viewModel.showSensitiveValues
                                ? L(lang, zhHant: "隱藏序號", zhHans: "隐藏序列号", en: "Hide SN", ja: "SN非表示")
                                : L(lang, zhHant: "顯示序號", zhHans: "显示序列号", en: "Show SN", ja: "SN表示"),
                            systemImage: viewModel.showSensitiveValues ? "eye.slash" : "eye"
                        )
                    }
                    .help(L(lang, zhHant: "顯示或遮罩序號與 UUID", zhHans: "显示或遮罩序列号与 UUID", en: "Show or redact serial numbers & UUID", ja: "シリアル番号やUUIDの表示切替"))

                    Button {
                        viewModel.reloadStatus()
                    } label: {
                        Label(L(lang, zhHant: "重新整理", zhHans: "刷新", en: "Refresh", ja: "更新"), systemImage: "arrow.clockwise")
                    }
                    .disabled(viewModel.isBusy)
                }
            }
        }
    }

    private func sidebarFooter(lang: EffectiveLanguage) -> some View {
        VStack(alignment: .leading, spacing: 5) {
            Divider()
                .opacity(0.6)
                .padding(.bottom, 4)

            HStack(spacing: 8) {
                Circle()
                    .fill(viewModel.report.kextStatus.isKextServicePresent ? Color.green : Color.orange)
                    .frame(width: 8, height: 8)
                Text(viewModel.report.kextStatus.isKextServicePresent
                     ? L(lang, zhHant: "Kext 已載入核心", zhHans: "Kext 已加载内核", en: "Kext Loaded", ja: "Kext ロード済み")
                     : L(lang, zhHant: "Kext 尚未載入", zhHans: "Kext 尚未加载", en: "Kext Not Loaded", ja: "Kext 未ロード"))
                    .font(.caption)
                    .foregroundStyle(.secondary)
            }

            Text("\(L(lang, zhHant: "目前型號", zhHans: "当前型号", en: "Active", ja: "現在")): \(viewModel.report.currentIdentity.combinedPartNumber)")
                .font(.caption2.monospaced())
                .foregroundStyle(.secondary)
                .lineLimit(1)
                .truncationMode(.middle)

            Divider()
                .opacity(0.45)
                .padding(.vertical, 3)

            VStack(alignment: .leading, spacing: 2) {
                Text("Powered by \(SpoofMacMetadata.poweredBy)")
                    .font(.caption2.bold())
                    .foregroundStyle(.secondary)
                HStack(spacing: 0) {
                    Text("Developed by Hikaru(")
                        .font(.caption2)
                        .foregroundStyle(.secondary)
                    if let mailURL = URL(string: "mailto:\(SpoofMacMetadata.developerEmail)") {
                        Link(SpoofMacMetadata.developerEmail, destination: mailURL)
                            .font(.caption2)
                    } else {
                        Text(SpoofMacMetadata.developerEmail)
                            .font(.caption2)
                    }
                    Text(")")
                        .font(.caption2)
                        .foregroundStyle(.secondary)
                }
                Text(L(lang,
                       zhHant: "非商用授權 · PolyForm NC 1.0",
                       zhHans: "非商用授权 · PolyForm NC 1.0",
                       en: "Non-Commercial · PolyForm NC 1.0",
                       ja: "非商用限定 · PolyForm NC 1.0"))
                    .font(.system(size: 10))
                    .foregroundStyle(.tertiary)
            }
        }
        .frame(maxWidth: .infinity, alignment: .leading)
        .padding(.horizontal, 20)
        .padding(.top, 6)
        .padding(.bottom, 16)
    }
}

private struct BannerBar: View {
    let message: String
    let isError: Bool
    let onDismiss: () -> Void

    var body: some View {
        HStack(spacing: 10) {
            Image(systemName: isError ? "exclamationmark.triangle.fill" : "checkmark.circle.fill")
                .foregroundStyle(isError ? .red : .green)
            Text(message)
                .font(.callout)
                .textSelection(.enabled)
            Spacer()
            Button(action: onDismiss) {
                Image(systemName: "xmark")
                    .font(.caption)
            }
            .buttonStyle(.plain)
        }
        .padding(.horizontal, 16)
        .padding(.vertical, 10)
        .background(isError ? Color.red.opacity(0.12) : Color.green.opacity(0.12))
    }
}
