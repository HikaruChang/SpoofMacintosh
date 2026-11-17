// Powered by NyphexAI, Developed by Hikaru(i@rua.moe)
// Licensed under the PolyForm Noncommercial License 1.0.0

import SpoofMacCore
import SwiftUI

struct ModelSpoofEditorView: View {
    @ObservedObject var viewModel: AppViewModel
    @State private var showAdvancedDeviceTree = false

    var body: some View {
        let lang = viewModel.lang
        VStack(spacing: 0) {
            ScrollView {
                VStack(alignment: .leading, spacing: 18) {
                    modeSection(lang: lang)
                    if viewModel.editorMode == .presetModel {
                        presetSelectorSection(lang: lang)
                    }
                    regionSelectorSection(lang: lang)
                    coreFieldsSection(lang: lang)
                    serialIdentifiersSection(lang: lang)
                    advancedDeviceTreeSection(lang: lang)
                    customPropertiesSection(lang: lang)
                }
                .padding(22)
            }

            Divider()
            bottomApplyBar(lang: lang)
        }
    }

    // MARK: - 1. Mode Selection

    private func modeSection(lang: EffectiveLanguage) -> some View {
        VStack(alignment: .leading, spacing: 10) {
            Text(L(lang, zhHant: "偽裝模式選擇", zhHans: "伪装模式选择", en: "Spoofing Mode", ja: "偽装モード選択"))
                .font(.headline)

            HStack(spacing: 10) {
                ForEach(EditorMode.allCases) { mode in
                    let isSelected = viewModel.editorMode == mode
                    Button {
                        viewModel.switchEditorMode(mode)
                    } label: {
                        VStack(alignment: .leading, spacing: 3) {
                            Text(mode.title(in: lang))
                                .font(.subheadline.bold())
                                .foregroundStyle(isSelected ? Color.accentColor : Color.primary)
                                .lineLimit(1)
                            Text(mode.subtitle(in: lang))
                                .font(.caption2)
                                .foregroundStyle(.secondary)
                                .lineLimit(1)
                        }
                        .padding(.horizontal, 12)
                        .padding(.vertical, 9)
                        .frame(maxWidth: .infinity, alignment: .leading)
                        .background(
                            RoundedRectangle(cornerRadius: 8)
                                .fill(isSelected ? Color.accentColor.opacity(0.12) : Color(nsColor: .windowBackgroundColor))
                        )
                        .overlay(
                            RoundedRectangle(cornerRadius: 8)
                                .stroke(isSelected ? Color.accentColor : Color.primary.opacity(0.12), lineWidth: isSelected ? 1.5 : 1)
                        )
                    }
                    .buttonStyle(.plain)
                }
            }

            Text(L(lang,
                   zhHant: "提示：透過 IOKit 動態寫入已載入的 SpoofMac.kext，無須重編核心擴展或重開機即可即時套用與還原。",
                   zhHans: "提示：通过 IOKit 动态写入已加载的 SpoofMac.kext，无需重编内核扩展或重启即可实时套用与还原。",
                   en: "Tip: Updates are pushed dynamically via IOKit to SpoofMac.kext without rebuilding the kext or rebooting.",
                   ja: "ヒント：IOKit 経由でロード済み SpoofMac.kext へ動的に書き込むため、再コンパイルや再起動は不要です。"))
                .font(.caption)
                .foregroundStyle(.secondary)
        }
        .padding(16)
        .background(RoundedRectangle(cornerRadius: 12).fill(Color(nsColor: .controlBackgroundColor)))
        .overlay(RoundedRectangle(cornerRadius: 12).stroke(Color.primary.opacity(0.08)))
    }

    // MARK: - 2. Mac Model Presets (M1 - M6)

    private func presetSelectorSection(lang: EffectiveLanguage) -> some View {
        let chipItems: [NativePopUpItem] = [
            NativePopUpItem(
                id: AppViewModel.allChipFilterTag,
                title: L(lang, zhHant: "全部世代 (M1–M6 · 59 款)", zhHans: "全部世代 (M1–M6 · 59 款)", en: "All Generations (M1–M6 · 59)", ja: "全世代 (M1–M6 · 59機種)")
            ),
            .separator(0),
        ] + MacChipGeneration.allCases.map {
            NativePopUpItem(id: $0.rawValue, title: $0.displayName(in: lang))
        }

        let modelItems: [NativePopUpItem] = viewModel.filteredPresetModels.map {
            NativePopUpItem(id: $0.modelIdentifier, title: $0.displayLabel(in: lang))
        }

        return VStack(alignment: .leading, spacing: 12) {
            HStack {
                Text(L(lang,
                       zhHant: "Mac 機型預設庫（支援 M1 至最新 M5／M6 全系列）",
                       zhHans: "Mac 机型预设库（支持 M1 至最新 M5/M6 全系列）",
                       en: "Mac Model Presets (M1 through Latest M5 / M6)",
                       ja: "Mac モデルプリセット（M1〜最新 M5/M6 全対応）"))
                    .font(.headline)
                Spacer()
                Text(L(lang,
                       zhHant: "目前顯示 \(viewModel.filteredPresetModels.count) 款機型",
                       zhHans: "当前显示 \(viewModel.filteredPresetModels.count) 款机型",
                       en: "\(viewModel.filteredPresetModels.count) models",
                       ja: "\(viewModel.filteredPresetModels.count) 機種表示中"))
                    .font(.caption)
                    .foregroundStyle(.secondary)
            }

            HStack(alignment: .top, spacing: 14) {
                VStack(alignment: .leading, spacing: 5) {
                    Text(L(lang, zhHant: "晶片世代篩選", zhHans: "芯片世代筛选", en: "Chip Generation", ja: "チップ世代"))
                        .font(.caption)
                        .foregroundStyle(.secondary)
                    NativePopUpButton(
                        items: chipItems,
                        selection: Binding(
                            get: { viewModel.selectedChipFilter?.rawValue ?? AppViewModel.allChipFilterTag },
                            set: { viewModel.selectChipFilterTag($0) }
                        )
                    )
                }
                .frame(width: 235)

                VStack(alignment: .leading, spacing: 5) {
                    Text(L(lang, zhHant: "選擇 Mac 機型預設", zhHans: "选择 Mac 机型预设", en: "Mac Model Preset", ja: "Mac モデルを選択"))
                        .font(.caption)
                        .foregroundStyle(.secondary)
                    NativePopUpButton(
                        items: modelItems,
                        selection: Binding(
                            get: { viewModel.selectedPresetID },
                            set: { viewModel.applyPresetFields(modelID: $0) }
                        )
                    )
                }
                .frame(maxWidth: .infinity)
            }

            Toggle(
                L(lang,
                  zhHant: "套用預設機型時同步填入晶片平台代號 (platform-name)",
                  zhHans: "套用预设机型时同步填入芯片平台代号 (platform-name)",
                  en: "Sync SoC platform-name when selecting a preset",
                  ja: "プリセット選択時に platform-name (SoCコード) も同期入力"),
                isOn: $viewModel.syncPlatformNameWithPreset
            )
            .font(.caption)
            .onChange(of: viewModel.syncPlatformNameWithPreset) { _, sync in
                if sync, let preset = viewModel.selectedPresetModel {
                    viewModel.spoofPlatformName = preset.platformName
                }
            }
        }
        .padding(16)
        .background(RoundedRectangle(cornerRadius: 12).fill(Color(nsColor: .controlBackgroundColor)))
        .overlay(RoundedRectangle(cornerRadius: 12).stroke(Color.blue.opacity(0.25)))
    }

    // MARK: - 3. Region Selector

    private func regionSelectorSection(lang: EffectiveLanguage) -> some View {
        let regionItems: [NativePopUpItem] = MacModelCatalog.allRegions.map {
            NativePopUpItem(id: $0.regionCode, title: $0.displayLabel(in: lang))
        } + [
            .separator(1),
            NativePopUpItem(
                id: AppViewModel.keepRegionTag,
                title: L(lang, zhHant: "保留原機地區（不修改 region-info）", zhHans: "保留原机地区（不修改 region-info）", en: "Keep Native Region (Do not modify)", ja: "元の地域を維持（変更しない）")
            ),
            NativePopUpItem(
                id: AppViewModel.customRegionTag,
                title: L(lang, zhHant: "自訂地區碼與國別…", zhHans: "自定义地区码与国别…", en: "Custom Region & Country Code…", ja: "カスタム地域・国コード…")
            ),
        ]

        return VStack(alignment: .leading, spacing: 10) {
            Text(L(lang, zhHant: "銷售地區與國別預設 (Region / Country)", zhHans: "销售地区与国别预设 (Region / Country)", en: "Sales Region & Country Preset", ja: "販売地域・国コードプリセット"))
                .font(.headline)

            NativePopUpButton(
                items: regionItems,
                selection: Binding(
                    get: { viewModel.selectedRegionOption },
                    set: { viewModel.selectRegionOption($0) }
                )
            )
            .frame(maxWidth: .infinity)

            if let matched = MacModelCatalog.region(matching: viewModel.selectedRegionOption) {
                HStack(spacing: 8) {
                    StatusPill(
                        text: matched.unlocksAllFeatures
                            ? L(lang, zhHant: "完整功能資格 ✓", zhHans: "完整功能资格 ✓", en: "Full Eligibility ✓", ja: "全機能対象 ✓")
                            : L(lang, zhHant: "部分地區限制", zhHans: "部分地区限制", en: "Restricted Region", ja: "一部機能制限"),
                        color: matched.unlocksAllFeatures ? .green : .orange
                    )
                    Text(matched.localizedNotes(in: lang))
                        .font(.caption)
                        .foregroundStyle(.secondary)
                }
            }
        }
        .padding(16)
        .background(RoundedRectangle(cornerRadius: 12).fill(Color(nsColor: .controlBackgroundColor)))
        .overlay(RoundedRectangle(cornerRadius: 12).stroke(Color.primary.opacity(0.08)))
    }

    // MARK: - 4. Core Model & Region Fields (100% Aligned)

    private func coreFieldsSection(lang: EffectiveLanguage) -> some View {
        let f = viewModel.report.factoryIdentity
        let origLabel = L(lang, zhHant: "原廠", zhHans: "原厂", en: "Factory", ja: "出荷時")
        let keepHint = L(lang, zhHant: "留空保留原廠", zhHans: "留空保留原厂", en: "Empty keeps factory", ja: "空欄で出荷時維持")

        return VStack(alignment: .leading, spacing: 10) {
            HStack {
                Text(L(lang, zhHant: "機型與地區識別屬性（留空代表保留原廠該項數值）", zhHans: "机型与地区识别属性（留空代表保留原厂该项数值）", en: "Model & Region Properties (Empty = Keep Factory Value)", ja: "モデル・地域プロパティ（空欄の項目は出荷時を維持）"))
                    .font(.headline)
                Spacer()
                Button(L(lang, zhHant: "全部帶入原機原廠值", zhHans: "全部带入原机原厂值", en: "Fill All Factory Values", ja: "すべて出荷時値を入力")) {
                    viewModel.fillAllFactoryValues()
                }
                .buttonStyle(.link)
                .font(.caption)
            }

            VStack(spacing: 10) {
                AlignedFieldRow(title: L(lang, zhHant: "機型識別碼 (model)", zhHans: "机型识别码 (model)", en: "Model Identifier (model)", ja: "モデル識別子 (model)"), hint: "\(origLabel): \(f.model)") {
                    AlignedInputBox(placeholder: "\(keepHint)（Mac17,6）", text: $viewModel.spoofModel)
                }

                Divider().opacity(0.45)

                AlignedFieldRow(title: L(lang, zhHant: "銷售型號前綴 (model-number)", zhHans: "销售型号前缀 (model-number)", en: "Part Number Prefix (model-number)", ja: "販売型番プレフィックス (model-number)"), hint: "\(origLabel): \(f.modelNumber)") {
                    AlignedInputBox(placeholder: "\(keepHint)（MX4Z4 / Z1...）", text: $viewModel.spoofModelNumber) {
                        InlineActionChip(title: L(lang, zhHant: "原機前綴", zhHans: "原机前缀", en: "Native", ja: "元値")) {
                            viewModel.spoofModelNumber = f.modelNumber
                        }
                        if viewModel.editorMode == .presetModel {
                            InlineActionChip(title: L(lang, zhHant: "預設號", zhHans: "预设号", en: "Preset", ja: "既定")) {
                                if let preset = viewModel.selectedPresetModel {
                                    viewModel.spoofModelNumber = preset.defaultModelNumber
                                }
                            }
                        }
                    }
                }

                Divider().opacity(0.45)

                AlignedFieldRow(title: L(lang, zhHant: "銷售地區碼 (region-info)", zhHans: "销售地区码 (region-info)", en: "Region Code (region-info)", ja: "地域コード (region-info)"), hint: "\(origLabel): \(f.regionInfo)") {
                    AlignedInputBox(placeholder: "LL/A, TA/A, ZP/A, J/A", text: $viewModel.spoofRegionInfo)
                        .onChange(of: viewModel.spoofRegionInfo) { _, newValue in
                            if let matched = MacModelCatalog.region(matching: newValue),
                               matched.countryCode3 == viewModel.spoofCountryOfOrigin {
                                viewModel.selectedRegionOption = matched.regionCode
                            } else if newValue.isEmpty && viewModel.spoofCountryOfOrigin.isEmpty {
                                viewModel.selectedRegionOption = AppViewModel.keepRegionTag
                            } else {
                                viewModel.selectedRegionOption = AppViewModel.customRegionTag
                            }
                        }
                }

                Divider().opacity(0.45)

                AlignedFieldRow(title: L(lang, zhHant: "出廠國別碼 (country-of-origin)", zhHans: "出厂国别码 (country-of-origin)", en: "Country of Origin (country-of-origin)", ja: "製造国コード (country-of-origin)"), hint: "\(origLabel): \(f.countryOfOrigin)") {
                    AlignedInputBox(placeholder: "USA, TWN, HKG, JPN", text: $viewModel.spoofCountryOfOrigin)
                }

                Divider().opacity(0.45)

                AlignedFieldRow(title: L(lang, zhHant: "監管型號 (regulatory-model)", zhHans: "监管型号 (regulatory-model)", en: "Regulatory Model (A-Number)", ja: "認証モデル番号 (regulatory-model)"), hint: "\(origLabel): \(f.regulatoryModelNumber)") {
                    AlignedInputBox(placeholder: "\(keepHint)（A3429）", text: $viewModel.spoofRegulatoryModel)
                }

                Divider().opacity(0.45)

                AlignedFieldRow(title: L(lang, zhHant: "硬體板號 (target-type)", zhHans: "硬件板号 (target-type)", en: "Board Target (target-type)", ja: "ボード種別 (target-type)"), hint: "\(origLabel): \(f.targetType)") {
                    AlignedInputBox(placeholder: "\(keepHint)（J716c）", text: $viewModel.spoofTargetType)
                }

                Divider().opacity(0.45)

                AlignedFieldRow(title: L(lang, zhHant: "硬體子板號 (target-sub-type)", zhHans: "硬件子板号 (target-sub-type)", en: "Board Sub-Type (target-sub-type)", ja: "サブボード種別 (target-sub-type)"), hint: "\(origLabel): \(f.targetSubType)") {
                    AlignedInputBox(placeholder: "\(keepHint)（J716cAP）", text: $viewModel.spoofTargetSubType)
                }

                Divider().opacity(0.45)

                AlignedFieldRow(title: L(lang, zhHant: "晶片平台代號 (platform-name)", zhHans: "芯片平台代号 (platform-name)", en: "SoC Platform (platform-name)", ja: "SoC プラットフォーム (platform-name)"), hint: "\(origLabel): \(f.platformName)") {
                    AlignedInputBox(placeholder: "\(keepHint)（t6050 / t6041 / t8103）", text: $viewModel.spoofPlatformName)
                }
            }
        }
        .padding(16)
        .background(RoundedRectangle(cornerRadius: 12).fill(Color(nsColor: .controlBackgroundColor)))
        .overlay(RoundedRectangle(cornerRadius: 12).stroke(Color.primary.opacity(0.08)))
    }

    // MARK: - 5. Serial Number, UUID, MLB Identifiers

    private func serialIdentifiersSection(lang: EffectiveLanguage) -> some View {
        let f = viewModel.report.factoryIdentity
        let revealed = viewModel.showSensitiveValues
        let origLabel = L(lang, zhHant: "原廠", zhHans: "原厂", en: "Factory", ja: "出荷時")
        let randomLabel = L(lang, zhHant: "隨機生成", zhHans: "随机生成", en: "Random", ja: "ランダム")
        let factoryLabel = L(lang, zhHant: "原廠值", zhHans: "原厂值", en: "Factory", ja: "出荷時")

        return VStack(alignment: .leading, spacing: 10) {
            HStack {
                Text(L(lang, zhHant: "系統序號與硬體識別碼 (SN / UUID / MLB)", zhHans: "系统序列号与硬件识别码 (SN / UUID / MLB)", en: "Serial Numbers & Hardware UUID (SN / UUID / MLB)", ja: "シリアル番号とハードウェア識別子 (SN / UUID / MLB)"))
                    .font(.headline)
                Spacer()
                Button {
                    viewModel.showSensitiveValues.toggle()
                } label: {
                    Label(
                        revealed
                            ? L(lang, zhHant: "隱藏原廠明文", zhHans: "隐藏原厂明文", en: "Hide Factory IDs", ja: "元の番号を隠す")
                            : L(lang, zhHant: "顯示原廠明文", zhHans: "显示原厂明文", en: "Reveal Factory IDs", ja: "元の番号を表示"),
                        systemImage: revealed ? "eye.slash" : "eye"
                    )
                }
                .controlSize(.small)
            }

            Text(L(lang,
                   zhHant: "提醒：留空代表維持原廠識別碼；變更系統序號 / UUID / MLB 可能影響 iCloud、FaceTime 與 PCC 憑證。",
                   zhHans: "提醒：留空代表维持原厂识别码；变更系统序列号 / UUID / MLB 可能影响 iCloud、FaceTime 与 PCC 凭证。",
                   en: "Note: Leave blank to keep factory identifiers. Changing SN / UUID / MLB may affect iCloud, FaceTime, and PCC.",
                   ja: "注意：空欄の場合は出荷時の識別子を維持します。SN / UUID / MLB の変更は iCloud や PCC に影響する場合があります。"))
                .font(.caption)
                .foregroundStyle(.secondary)

            VStack(spacing: 10) {
                AlignedFieldRow(
                    title: L(lang, zhHant: "系統序號 (IOPlatformSerialNumber)", zhHans: "系统序列号 (IOPlatformSerialNumber)", en: "System Serial (IOPlatformSerialNumber)", ja: "シリアル番号 (IOPlatformSerialNumber)"),
                    hint: "\(origLabel): \(HardwareIdentitySnapshot.masked(f.serialNumber, revealed: revealed))"
                ) {
                    AlignedInputBox(
                        placeholder: L(lang, zhHant: "留空保留原廠（自動同步 serial-number）", zhHans: "留空保留原厂（自动同步 serial-number）", en: "Empty keeps factory (auto-syncs serial-number)", ja: "空欄で出荷時維持（serial-number へ自動同期）"),
                        text: $viewModel.spoofSerialNumber
                    ) {
                        InlineActionChip(title: randomLabel) { viewModel.generateRandomSerial() }
                        InlineActionChip(title: factoryLabel) { viewModel.spoofSerialNumber = f.serialNumber }
                    }
                }

                Divider().opacity(0.45)

                AlignedFieldRow(
                    title: L(lang, zhHant: "裝置樹序號 (serial-number)", zhHans: "设备树序列号 (serial-number)", en: "DeviceTree Serial (serial-number)", ja: "DeviceTree シリアル (serial-number)"),
                    hint: "\(origLabel): \(HardwareIdentitySnapshot.masked(f.rawSerialNumber, revealed: revealed))"
                ) {
                    AlignedInputBox(
                        placeholder: L(lang, zhHant: "留空自動同步上方 SN（或獨立覆寫 32-byte）", zhHans: "留空自动同步上方 SN（或独立覆盖 32-byte）", en: "Empty mirrors SN above (or override 32-byte Data)", ja: "空欄で上記 SN と同期（または個別に上書き）"),
                        text: $viewModel.spoofRawSerialData
                    )
                }

                Divider().opacity(0.45)

                AlignedFieldRow(
                    title: L(lang, zhHant: "硬體 UUID (IOPlatformUUID)", zhHans: "硬件 UUID (IOPlatformUUID)", en: "Hardware UUID (IOPlatformUUID)", ja: "ハードウェア UUID (IOPlatformUUID)"),
                    hint: "\(origLabel): \(HardwareIdentitySnapshot.masked(f.hardwareUUID, revealed: revealed))"
                ) {
                    AlignedInputBox(
                        placeholder: L(lang, zhHant: "留空保留原廠（36 字元標準 UUID）", zhHans: "留空保留原厂（36 字符标准 UUID）", en: "Empty keeps factory (36-char UUID)", ja: "空欄で出荷時維持（36文字 UUID）"),
                        text: $viewModel.spoofUUID
                    ) {
                        InlineActionChip(title: randomLabel) { viewModel.generateRandomUUID() }
                        InlineActionChip(title: factoryLabel) { viewModel.spoofUUID = f.hardwareUUID }
                    }
                }

                Divider().opacity(0.45)

                AlignedFieldRow(
                    title: L(lang, zhHant: "主機板序號 (mlb-serial-number)", zhHans: "主板序列号 (mlb-serial-number)", en: "MLB Serial (mlb-serial-number)", ja: "MLB シリアル (mlb-serial-number)"),
                    hint: "\(origLabel): \(HardwareIdentitySnapshot.masked(f.mlbSerialNumber, revealed: revealed))"
                ) {
                    AlignedInputBox(
                        placeholder: L(lang, zhHant: "留空保留原廠（17 碼 MLB）", zhHans: "留空保留原厂（17 位 MLB）", en: "Empty keeps factory (17-char MLB)", ja: "空欄で出荷時維持（17桁 MLB）"),
                        text: $viewModel.spoofMLB
                    ) {
                        InlineActionChip(title: randomLabel) { viewModel.generateRandomMLB() }
                        InlineActionChip(title: factoryLabel) { viewModel.spoofMLB = f.mlbSerialNumber }
                    }
                }
            }
        }
        .padding(16)
        .background(RoundedRectangle(cornerRadius: 12).fill(Color(nsColor: .controlBackgroundColor)))
        .overlay(RoundedRectangle(cornerRadius: 12).stroke(Color.orange.opacity(0.28)))
    }

    // MARK: - 6. Advanced DeviceTree & Firmware Fields

    private func advancedDeviceTreeSection(lang: EffectiveLanguage) -> some View {
        let f = viewModel.report.factoryIdentity
        let origLabel = L(lang, zhHant: "原廠", zhHans: "原厂", en: "Factory", ja: "出荷時")
        let keepHint = L(lang, zhHant: "留空保留原廠", zhHans: "留空保留原厂", en: "Empty keeps factory", ja: "空欄で出荷時維持")

        return DisclosureGroup(isExpanded: $showAdvancedDeviceTree) {
            VStack(alignment: .leading, spacing: 10) {
                Divider()
                    .padding(.vertical, 4)

                Toggle(isOn: $viewModel.updateCompatible) {
                    VStack(alignment: .leading, spacing: 2) {
                        Text(L(lang, zhHant: "自動同步更新裝置樹相容清單 (compatible)", zhHans: "自动同步更新设备树兼容列表 (compatible)", en: "Automatically update compatible DeviceTree array", ja: "compatible 配列を自動更新する"))
                            .font(.subheadline)
                        Text("\(L(lang, zhHant: "預計寫入", zhHans: "预计写入", en: "Output", ja: "書き込み値"))：\(viewModel.previewCompatibleDisplay)")
                            .font(.caption.monospaced())
                            .foregroundStyle(.secondary)
                    }
                }

                Divider().opacity(0.45)

                AlignedFieldRow(title: L(lang, zhHant: "自訂 compatible（逗號分隔）", zhHans: "自定义 compatible（逗号分隔）", en: "Custom compatible (comma-separated)", ja: "カスタム compatible（カンマ区切り）"), hint: "\(origLabel): \(f.compatible.joined(separator: ", "))") {
                    AlignedInputBox(placeholder: "J716cAP, Mac17,6, AppleARM", text: $viewModel.spoofCompatible)
                }

                Divider().opacity(0.45)

                AlignedFieldRow(title: L(lang, zhHant: "製造商 (manufacturer)", zhHans: "制造商 (manufacturer)", en: "Manufacturer (manufacturer)", ja: "製造元 (manufacturer)"), hint: "\(origLabel): \(f.manufacturer)") {
                    AlignedInputBox(placeholder: "\(keepHint)（Apple Inc.）", text: $viewModel.spoofManufacturer)
                }

                Divider().opacity(0.45)

                AlignedFieldRow(title: L(lang, zhHant: "機型組態 (model-config)", zhHans: "机型配置 (model-config)", en: "Model Config (model-config)", ja: "モデル構成 (model-config)"), hint: "\(origLabel): \(f.modelConfig)") {
                    AlignedInputBox(placeholder: "\(keepHint)（ICT;MoPED=...）", text: $viewModel.spoofModelConfig)
                }

                Divider().opacity(0.45)

                AlignedFieldRow(title: L(lang, zhHant: "設定編號 (config-number)", zhHans: "配置编号 (config-number)", en: "Config Number (config-number)", ja: "構成番号 (config-number)"), hint: "\(origLabel): \(f.configNumber.isEmpty ? "(空)" : f.configNumber)") {
                    AlignedInputBox(placeholder: "\(keepHint)（64-byte）", text: $viewModel.spoofConfigNumber)
                }

                Divider().opacity(0.45)

                AlignedFieldRow(title: L(lang, zhHant: "裝置類型 (device_type)", zhHans: "设备类型 (device_type)", en: "Device Type (device_type)", ja: "デバイス種別 (device_type)"), hint: "\(origLabel): \(f.deviceType)") {
                    AlignedInputBox(placeholder: "\(keepHint)（bootrom）", text: $viewModel.spoofDeviceType)
                }

                Divider().opacity(0.45)

                AlignedFieldRow(title: L(lang, zhHant: "安全根前綴 (secure-root-prefix)", zhHans: "安全根前缀 (secure-root-prefix)", en: "Secure Root Prefix", ja: "セキュアルート接頭辞"), hint: "\(origLabel): \(f.secureRootPrefix)") {
                    AlignedInputBox(placeholder: "\(keepHint)（md）", text: $viewModel.spoofSecureRootPrefix)
                }

                Divider().opacity(0.45)

                AlignedFieldRow(title: L(lang, zhHant: "裝置樹節點名 (name)", zhHans: "设备树节点名 (name)", en: "Node Name (name)", ja: "ノード名 (name)"), hint: "\(origLabel): \(f.nodeName)") {
                    AlignedInputBox(placeholder: "\(keepHint)（device-tree）", text: $viewModel.spoofNodeName)
                }
            }
            .padding(.top, 6)
        } label: {
            Text(L(lang, zhHant: "進階裝置樹與韌體屬性 (compatible / manufacturer / model-config 等)", zhHans: "高级设备树与固件属性 (compatible / manufacturer / model-config 等)", en: "Advanced DeviceTree & Firmware Properties", ja: "高度な DeviceTree・ファームウェアプロパティ"))
                .font(.headline)
        }
        .padding(16)
        .background(RoundedRectangle(cornerRadius: 12).fill(Color(nsColor: .controlBackgroundColor)))
        .overlay(RoundedRectangle(cornerRadius: 12).stroke(Color.primary.opacity(0.08)))
    }

    // MARK: - 7. Arbitrary Custom IORegistry Properties

    private func customPropertiesSection(lang: EffectiveLanguage) -> some View {
        let availableKeys = viewModel.report.currentIdentity.allAvailableKeys
        let typeItems = CustomPropertyValueType.allCases.map {
            NativePopUpItem(id: $0.rawValue, title: $0.displayName(in: lang))
        }

        return VStack(alignment: .leading, spacing: 10) {
            HStack {
                VStack(alignment: .leading, spacing: 2) {
                    Text(L(lang, zhHant: "自訂其他任意 IORegistry 屬性 (IOPlatformExpertDevice)", zhHans: "自定义其他任意 IORegistry 属性 (IOPlatformExpertDevice)", en: "Custom Arbitrary IORegistry Properties", ja: "任意の追加 IORegistry プロパティ"))
                        .font(.headline)
                    Text(L(lang,
                           zhHant: "可新增或覆寫裝置樹上的任意其他鍵值；修改前核心自動快照原廠狀態，reset 時一併還原。",
                           zhHans: "可新增或覆盖设备树上的任意其他键值；修改前内核自动快照原厂状态，reset 时一并还原。",
                           en: "Add or override any key on IOPlatformExpertDevice; original values are snapshotted automatically for reset.",
                           ja: "IOPlatformExpertDevice 上の任意キーを追加・上書きできます。変更前の値は自動保存され reset 時に復元されます。"))
                        .font(.caption)
                        .foregroundStyle(.secondary)
                }
                Spacer()
                if !availableKeys.isEmpty {
                    Menu {
                        ForEach(availableKeys, id: \.self) { k in
                            Button(k) {
                                viewModel.addCustomProperty(key: k, type: .cstring, value: "")
                            }
                        }
                    } label: {
                        Label(L(lang, zhHant: "從現有鍵名插入", zhHans: "从现有键名插入", en: "Pick Existing Key", ja: "既存キーから挿入"), systemImage: "list.bullet")
                    }
                    .controlSize(.small)
                }
                Button {
                    viewModel.addCustomProperty()
                } label: {
                    Label(L(lang, zhHant: "新增欄位", zhHans: "新增字段", en: "Add Key", ja: "項目を追加"), systemImage: "plus")
                }
                .controlSize(.small)
            }

            if viewModel.customProperties.isEmpty {
                Text(L(lang,
                       zhHant: "目前未設定額外自訂屬性。點擊右上角「新增欄位」即可針對任何 IORegistry 屬性進行覆寫。",
                       zhHans: "当前未设置额外自定义属性。点击右上角「新增字段」即可针对任何 IORegistry 属性进行覆盖。",
                       en: "No custom properties configured. Click 'Add Key' above to override any IORegistry property.",
                       ja: "カスタムプロパティはまだありません。「項目を追加」から任意のプロパティを上書きできます。"))
                    .font(.caption)
                    .foregroundStyle(.tertiary)
                    .padding(.vertical, 6)
            } else {
                ForEach($viewModel.customProperties) { $prop in
                    HStack(alignment: .center, spacing: 10) {
                        AlignedInputBox(
                            placeholder: L(lang, zhHant: "屬性鍵名 (Key)", zhHans: "属性键名 (Key)", en: "Property Key", ja: "プロパティキー"),
                            text: $prop.key
                        )
                        .frame(width: 210)

                        NativePopUpButton(
                            items: typeItems,
                            selection: Binding(
                                get: { prop.type.rawValue },
                                set: { if let t = CustomPropertyValueType(rawValue: $0) { prop.type = t } }
                            )
                        )
                        .frame(width: 175)

                        AlignedInputBox(
                            placeholder: prop.type == .hex
                                ? "Hex (e.g. 01000000)"
                                : L(lang, zhHant: "屬性值（留空即還原此鍵）", zhHans: "属性值（留空即还原此键）", en: "Value (empty restores factory)", ja: "値（空欄でこのキーを復元）"),
                            text: $prop.value
                        )

                        Button(role: .destructive) {
                            viewModel.removeCustomProperty(id: prop.id)
                        } label: {
                            Image(systemName: "trash")
                                .foregroundStyle(.red)
                                .frame(width: 28, height: 28)
                        }
                        .buttonStyle(.borderless)
                        .help(L(lang, zhHant: "移除此自訂欄位", zhHans: "移除此自定义字段", en: "Remove custom property", ja: "この項目を削除"))
                    }
                }
            }
        }
        .padding(16)
        .background(RoundedRectangle(cornerRadius: 12).fill(Color(nsColor: .controlBackgroundColor)))
        .overlay(RoundedRectangle(cornerRadius: 12).stroke(Color.primary.opacity(0.08)))
    }

    // MARK: - Bottom Bar

    private func bottomApplyBar(lang: EffectiveLanguage) -> some View {
        HStack(spacing: 14) {
            VStack(alignment: .leading, spacing: 3) {
                Text(L(lang, zhHant: "「系統資訊 / 關於本機」預期呈現結果", zhHans: "「系统信息 / 关于本机」预期呈现结果", en: "Preview in About This Mac / System Information", ja: "「この Mac について」での表示プレビュー"))
                    .font(.caption)
                    .foregroundStyle(.secondary)
                HStack(spacing: 8) {
                    Text(viewModel.previewCombinedPartNumber)
                        .font(.headline.monospaced())
                    if !viewModel.previewRegulatoryModel.isEmpty {
                        Text("(\(viewModel.previewRegulatoryModel))")
                            .font(.subheadline.monospaced())
                            .foregroundStyle(.secondary)
                    }
                    Text("· \(viewModel.previewModel)")
                        .font(.subheadline.monospaced())
                        .foregroundStyle(.blue)
                    if !viewModel.spoofSerialNumber.isEmpty {
                        Text("· SN: \(viewModel.spoofSerialNumber)")
                            .font(.caption.monospaced())
                            .foregroundStyle(.orange)
                    }
                }
            }

            Spacer()

            Button(L(lang, zhHant: "還原出廠值", zhHans: "还原出厂值", en: "Reset to Factory", ja: "出荷時に戻す")) {
                viewModel.resetToFactory()
            }
            .buttonStyle(.bordered)
            .tint(.orange)
            .disabled(viewModel.isBusy)

            Button {
                viewModel.applyCurrentEditorProfile()
            } label: {
                Label(
                    L(lang, zhHant: "套用並儲存設定", zhHans: "套用并保存设置", en: "Apply & Save", ja: "適用して保存"),
                    systemImage: "checkmark.circle.fill"
                )
            }
            .buttonStyle(.borderedProminent)
            .disabled(viewModel.isBusy)
        }
        .padding(.horizontal, 22)
        .padding(.vertical, 14)
        .background(Color(nsColor: .windowBackgroundColor))
    }
}
