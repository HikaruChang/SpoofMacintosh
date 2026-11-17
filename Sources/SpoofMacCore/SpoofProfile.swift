// Powered by NyphexAI, Developed by Hikaru(i@rua.moe)
// Licensed under the PolyForm Noncommercial License 1.0.0

import Foundation

public enum SpoofMode: Codable, Equatable, Hashable {
    case keepNativeModel
    case presetModel(String)
    case custom

    private enum CodingKeys: String, CodingKey {
        case type
        case presetId
    }

    public init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        let type = try container.decode(String.self, forKey: .type)
        switch type {
        case "keepNativeModel":
            self = .keepNativeModel
        case "presetModel":
            let id = try container.decode(String.self, forKey: .presetId)
            self = .presetModel(id)
        default:
            self = .custom
        }
    }

    public func encode(to encoder: Encoder) throws {
        var container = encoder.container(keyedBy: CodingKeys.self)
        switch self {
        case .keepNativeModel:
            try container.encode("keepNativeModel", forKey: .type)
        case .presetModel(let id):
            try container.encode("presetModel", forKey: .type)
            try container.encode(id, forKey: .presetId)
        case .custom:
            try container.encode("custom", forKey: .type)
        }
    }
}

public enum CustomPropertyValueType: String, Codable, CaseIterable, Identifiable {
    case cstring = "cstring"
    case osstring = "osstring"
    case pad32 = "pad32"
    case pad64 = "pad64"
    case raw = "raw"
    case hex = "hex"

    public var id: String { rawValue }

    public var displayName: String {
        displayName(in: AppLanguage.system.resolved)
    }

    public func displayName(in lang: EffectiveLanguage) -> String {
        switch self {
        case .cstring: return L(lang, zhHant: "C 字串 (Data \\0)", zhHans: "C 字符串 (Data \\0)", en: "C String (Data \\0)", ja: "C文字列 (Data \\0)")
        case .osstring: return "OSString (String)"
        case .pad32: return L(lang, zhHant: "32-byte 補零 (Data)", zhHans: "32-byte 补零 (Data)", en: "32-byte Zero-Pad (Data)", ja: "32バイト零埋め (Data)")
        case .pad64: return L(lang, zhHant: "64-byte 補零 (Data)", zhHans: "64-byte 补零 (Data)", en: "64-byte Zero-Pad (Data)", ja: "64バイト零埋め (Data)")
        case .raw: return L(lang, zhHant: "純 ASCII (無 \\0)", zhHans: "纯 ASCII (无 \\0)", en: "Raw ASCII (No \\0)", ja: "生ASCII (\\0なし)")
        case .hex: return L(lang, zhHant: "十六進位 Bytes (Hex)", zhHans: "十六进制 Bytes (Hex)", en: "Hex Bytes", ja: "16進バイト列 (Hex)")
        }
    }
}

public struct CustomIORegProperty: Codable, Equatable, Identifiable, Hashable {
    public var id: UUID
    public var key: String
    public var type: CustomPropertyValueType
    public var value: String

    public init(
        id: UUID = UUID(),
        key: String,
        type: CustomPropertyValueType = .cstring,
        value: String
    ) {
        self.id = id
        self.key = key
        self.type = type
        self.value = value
    }
}

public struct SpoofProfile: Codable, Equatable {
    public static let defaultPreferencesPath = "/Library/Preferences/com.spoofmacintosh.plist"

    public var mode: SpoofMode
    // Core model & region properties
    public var spoofModel: String
    public var spoofModelNumber: String
    public var spoofRegionInfo: String
    public var spoofRegulatoryModel: String
    public var spoofTargetType: String
    public var spoofTargetSubType: String
    public var spoofCountryOfOrigin: String
    public var spoofPlatformName: String
    // Serial / UUID / MLB properties
    public var spoofSerialNumber: String
    public var spoofRawSerialData: String
    public var spoofUUID: String
    public var spoofMLB: String
    // Advanced DeviceTree / firmware properties
    public var updateCompatible: Bool
    public var spoofCompatible: String
    public var spoofManufacturer: String
    public var spoofModelConfig: String
    public var spoofConfigNumber: String
    public var spoofDeviceType: String
    public var spoofSecureRootPrefix: String
    public var spoofNodeName: String
    // Arbitrary additional IOPlatformExpertDevice properties
    public var customProperties: [CustomIORegProperty]

    public init(
        mode: SpoofMode = .keepNativeModel,
        spoofModel: String = "",
        spoofModelNumber: String = "",
        spoofRegionInfo: String = "LL/A",
        spoofRegulatoryModel: String = "",
        spoofTargetType: String = "",
        spoofTargetSubType: String = "",
        spoofCountryOfOrigin: String = "USA",
        spoofPlatformName: String = "",
        spoofSerialNumber: String = "",
        spoofRawSerialData: String = "",
        spoofUUID: String = "",
        spoofMLB: String = "",
        updateCompatible: Bool = true,
        spoofCompatible: String = "",
        spoofManufacturer: String = "",
        spoofModelConfig: String = "",
        spoofConfigNumber: String = "",
        spoofDeviceType: String = "",
        spoofSecureRootPrefix: String = "",
        spoofNodeName: String = "",
        customProperties: [CustomIORegProperty] = []
    ) {
        self.mode = mode
        self.spoofModel = spoofModel
        self.spoofModelNumber = spoofModelNumber
        self.spoofRegionInfo = spoofRegionInfo
        self.spoofRegulatoryModel = spoofRegulatoryModel
        self.spoofTargetType = spoofTargetType
        self.spoofTargetSubType = spoofTargetSubType
        self.spoofCountryOfOrigin = spoofCountryOfOrigin
        self.spoofPlatformName = spoofPlatformName
        self.spoofSerialNumber = spoofSerialNumber
        self.spoofRawSerialData = spoofRawSerialData
        self.spoofUUID = spoofUUID
        self.spoofMLB = spoofMLB
        self.updateCompatible = updateCompatible
        self.spoofCompatible = spoofCompatible
        self.spoofManufacturer = spoofManufacturer
        self.spoofModelConfig = spoofModelConfig
        self.spoofConfigNumber = spoofConfigNumber
        self.spoofDeviceType = spoofDeviceType
        self.spoofSecureRootPrefix = spoofSecureRootPrefix
        self.spoofNodeName = spoofNodeName
        self.customProperties = customProperties
    }

    private enum CodingKeys: String, CodingKey {
        case mode, spoofModel, spoofModelNumber, spoofRegionInfo, spoofRegulatoryModel
        case spoofTargetType, spoofTargetSubType, spoofCountryOfOrigin, spoofPlatformName
        case spoofSerialNumber, spoofRawSerialData, spoofUUID, spoofMLB
        case updateCompatible, spoofCompatible, spoofManufacturer, spoofModelConfig
        case spoofConfigNumber, spoofDeviceType, spoofSecureRootPrefix, spoofNodeName
        case customProperties
    }

    public init(from decoder: Decoder) throws {
        let c = try decoder.container(keyedBy: CodingKeys.self)
        mode = try c.decodeIfPresent(SpoofMode.self, forKey: .mode) ?? .keepNativeModel
        spoofModel = try c.decodeIfPresent(String.self, forKey: .spoofModel) ?? ""
        spoofModelNumber = try c.decodeIfPresent(String.self, forKey: .spoofModelNumber) ?? ""
        spoofRegionInfo = try c.decodeIfPresent(String.self, forKey: .spoofRegionInfo) ?? ""
        spoofRegulatoryModel = try c.decodeIfPresent(String.self, forKey: .spoofRegulatoryModel) ?? ""
        spoofTargetType = try c.decodeIfPresent(String.self, forKey: .spoofTargetType) ?? ""
        spoofTargetSubType = try c.decodeIfPresent(String.self, forKey: .spoofTargetSubType) ?? ""
        spoofCountryOfOrigin = try c.decodeIfPresent(String.self, forKey: .spoofCountryOfOrigin) ?? ""
        spoofPlatformName = try c.decodeIfPresent(String.self, forKey: .spoofPlatformName) ?? ""
        spoofSerialNumber = try c.decodeIfPresent(String.self, forKey: .spoofSerialNumber) ?? ""
        spoofRawSerialData = try c.decodeIfPresent(String.self, forKey: .spoofRawSerialData) ?? ""
        spoofUUID = try c.decodeIfPresent(String.self, forKey: .spoofUUID) ?? ""
        spoofMLB = try c.decodeIfPresent(String.self, forKey: .spoofMLB) ?? ""
        updateCompatible = try c.decodeIfPresent(Bool.self, forKey: .updateCompatible) ?? true
        spoofCompatible = try c.decodeIfPresent(String.self, forKey: .spoofCompatible) ?? ""
        spoofManufacturer = try c.decodeIfPresent(String.self, forKey: .spoofManufacturer) ?? ""
        spoofModelConfig = try c.decodeIfPresent(String.self, forKey: .spoofModelConfig) ?? ""
        spoofConfigNumber = try c.decodeIfPresent(String.self, forKey: .spoofConfigNumber) ?? ""
        spoofDeviceType = try c.decodeIfPresent(String.self, forKey: .spoofDeviceType) ?? ""
        spoofSecureRootPrefix = try c.decodeIfPresent(String.self, forKey: .spoofSecureRootPrefix) ?? ""
        spoofNodeName = try c.decodeIfPresent(String.self, forKey: .spoofNodeName) ?? ""
        customProperties = try c.decodeIfPresent([CustomIORegProperty].self, forKey: .customProperties) ?? []
    }

    public static func regionOnlyUS() -> SpoofProfile {
        SpoofProfile(
            mode: .keepNativeModel,
            spoofRegionInfo: "LL/A",
            spoofCountryOfOrigin: "USA",
            updateCompatible: true
        )
    }

    public static func fromPreset(
        _ preset: MacModelPreset,
        region: RegionPreset? = MacModelCatalog.usRegionPreset,
        includePlatformName: Bool = false
    ) -> SpoofProfile {
        SpoofProfile(
            mode: .presetModel(preset.modelIdentifier),
            spoofModel: preset.modelIdentifier,
            spoofModelNumber: preset.defaultModelNumber,
            spoofRegionInfo: region?.regionCode ?? "",
            spoofRegulatoryModel: preset.regulatoryModelNumber,
            spoofTargetType: preset.targetType,
            spoofTargetSubType: preset.targetSubType,
            spoofCountryOfOrigin: region?.countryCode3 ?? "",
            spoofPlatformName: includePlatformName ? preset.platformName : "",
            updateCompatible: true
        )
    }

    public func combinedPartNumber(fallbackModelNumber: String, fallbackRegion: String) -> String {
        let num = spoofModelNumber.isEmpty ? fallbackModelNumber : spoofModelNumber
        let reg = spoofRegionInfo.isEmpty ? fallbackRegion : spoofRegionInfo
        return "\(num)\(reg)"
    }

    public func toKextPropertiesDictionary() -> [String: Any] {
        var customMap: [String: [String: String]] = [:]
        for prop in customProperties {
            let trimmedKey = prop.key.trimmingCharacters(in: .whitespacesAndNewlines)
            guard !trimmedKey.isEmpty, trimmedKey != "spoofmac-originals" else { continue }
            customMap[trimmedKey] = [
                "Type": prop.type.rawValue,
                "Value": prop.value,
            ]
        }

        return [
            "SpoofModel": spoofModel,
            "SpoofModelNumber": spoofModelNumber,
            "SpoofRegionInfo": spoofRegionInfo,
            "SpoofRegulatoryModel": spoofRegulatoryModel,
            "SpoofTargetType": spoofTargetType,
            "SpoofTargetSubType": spoofTargetSubType,
            "SpoofCountryOfOrigin": spoofCountryOfOrigin,
            "SpoofPlatformName": spoofPlatformName,
            "SpoofSerialNumber": spoofSerialNumber,
            "SpoofRawSerialData": spoofRawSerialData,
            "SpoofUUID": spoofUUID,
            "SpoofMLB": spoofMLB,
            "SpoofManufacturer": spoofManufacturer,
            "SpoofModelConfig": spoofModelConfig,
            "SpoofConfigNumber": spoofConfigNumber,
            "SpoofDeviceType": spoofDeviceType,
            "SpoofSecureRootPrefix": spoofSecureRootPrefix,
            "SpoofNodeName": spoofNodeName,
            "SpoofCompatible": spoofCompatible,
            "UpdateCompatible": updateCompatible,
            "CustomProperties": customMap,
        ]
    }

    public var hasAnyOverride: Bool {
        let stdNonEmpty = [
            spoofModel, spoofModelNumber, spoofRegionInfo, spoofRegulatoryModel,
            spoofTargetType, spoofTargetSubType, spoofCountryOfOrigin, spoofPlatformName,
            spoofSerialNumber, spoofRawSerialData, spoofUUID, spoofMLB,
            spoofManufacturer, spoofModelConfig, spoofConfigNumber, spoofDeviceType,
            spoofSecureRootPrefix, spoofNodeName, spoofCompatible,
        ].contains { !$0.isEmpty }
        return stdNonEmpty || customProperties.contains { !$0.key.isEmpty && !$0.value.isEmpty }
    }

    public func validate() throws {
        let lang = AppLanguage.current
        let fields: [(String, String, Int)] = [
            ("\(L(lang, zhHant: "機型識別碼", zhHans: "机型识别码", en: "Model identifier", ja: "モデル識別子")) (model)", spoofModel, 128),
            ("\(L(lang, zhHant: "銷售型號前綴", zhHans: "销售型号前缀", en: "Model number prefix", ja: "販売型番プレフィックス")) (model-number)", spoofModelNumber, 31),
            ("\(L(lang, zhHant: "銷售地區碼", zhHans: "销售地区码", en: "Region info", ja: "販売地域コード")) (region-info)", spoofRegionInfo, 31),
            ("\(L(lang, zhHant: "監管型號", zhHans: "监管型号", en: "Regulatory model", ja: "規制モデル番号")) (regulatory-model-number)", spoofRegulatoryModel, 31),
            ("\(L(lang, zhHant: "硬體板號", zhHans: "硬件板号", en: "Target type", ja: "ターゲット種別")) (target-type)", spoofTargetType, 128),
            ("\(L(lang, zhHant: "硬體子板號", zhHans: "硬件子板号", en: "Target sub-type", ja: "サブターゲット")) (target-sub-type)", spoofTargetSubType, 128),
            ("\(L(lang, zhHant: "出廠國別碼", zhHans: "出厂国别码", en: "Country of origin", ja: "製造国コード")) (country-of-origin)", spoofCountryOfOrigin, 16),
            ("\(L(lang, zhHant: "晶片平台代號", zhHans: "芯片平台代号", en: "Platform name", ja: "プラットフォーム名")) (platform-name)", spoofPlatformName, 31),
            ("\(L(lang, zhHant: "系統序號", zhHans: "系统序列号", en: "Serial number", ja: "シリアル番号")) (IOPlatformSerialNumber)", spoofSerialNumber, 64),
            ("\(L(lang, zhHant: "裝置樹序號", zhHans: "设备树序列号", en: "DT serial data", ja: "DTシリアルデータ")) (serial-number)", spoofRawSerialData, 31),
            ("\(L(lang, zhHant: "硬體 UUID", zhHans: "硬件 UUID", en: "Hardware UUID", ja: "ハードウェアUUID")) (IOPlatformUUID)", spoofUUID, 64),
            ("\(L(lang, zhHant: "主機板序號", zhHans: "主板序列号", en: "MLB serial number", ja: "MLBシリアル番号")) (mlb-serial-number)", spoofMLB, 31),
            ("\(L(lang, zhHant: "製造商", zhHans: "制造商", en: "Manufacturer", ja: "製造元")) (manufacturer)", spoofManufacturer, 128),
            ("\(L(lang, zhHant: "機型組態", zhHans: "机型配置", en: "Model config", ja: "モデル構成")) (model-config)", spoofModelConfig, 255),
            ("\(L(lang, zhHant: "設定編號", zhHans: "设置编号", en: "Config number", ja: "設定番号")) (config-number)", spoofConfigNumber, 63),
            ("\(L(lang, zhHant: "裝置類型", zhHans: "设备类型", en: "Device type", ja: "デバイス種別")) (device_type)", spoofDeviceType, 64),
            ("\(L(lang, zhHant: "安全根前綴", zhHans: "安全根前缀", en: "Secure root prefix", ja: "セキュアルート接頭辞")) (secure-root-prefix)", spoofSecureRootPrefix, 32),
            ("\(L(lang, zhHant: "裝置樹節點名", zhHans: "设备树节点名", en: "DeviceTree node name", ja: "DeviceTreeノード名")) (name)", spoofNodeName, 64),
            ("\(L(lang, zhHant: "相容清單", zhHans: "兼容列表", en: "Compatible list", ja: "互換性リスト")) (compatible)", spoofCompatible, 400),
        ]
        for (name, value, maxLen) in fields where !value.isEmpty {
            guard value.allSatisfy({ $0.isASCII && !$0.isNewline }) else {
                throw SpoofProfileError.invalidCharacters(field: name)
            }
            guard value.utf8.count <= maxLen else {
                throw SpoofProfileError.exceedsMaxLength(field: name, maxLength: maxLen)
            }
        }

        var seenKeys = Set<String>()
        for prop in customProperties {
            let k = prop.key.trimmingCharacters(in: .whitespacesAndNewlines)
            if k.isEmpty { continue }
            guard k != "spoofmac-originals" else {
                throw SpoofProfileError.reservedKey(k)
            }
            guard k.allSatisfy({ $0.isASCII && !$0.isNewline }) else {
                let keyLabel = "\(L(lang, zhHant: "自訂鍵名", zhHans: "自定义键名", en: "Custom key", ja: "カスタムキー")) \(k)"
                throw SpoofProfileError.invalidCharacters(field: keyLabel)
            }
            guard seenKeys.insert(k).inserted else {
                throw SpoofProfileError.duplicateCustomKey(k)
            }
            guard prop.value.allSatisfy({ $0.isASCII && !$0.isNewline }) else {
                let propLabel = "\(L(lang, zhHant: "自訂欄位", zhHans: "自定义字段", en: "Custom property", ja: "カスタムプロパティ")) \(k)"
                throw SpoofProfileError.invalidCharacters(field: propLabel)
            }
            if !prop.value.isEmpty {
                switch prop.type {
                case .pad32:
                    guard prop.value.utf8.count <= 31 else {
                        throw SpoofProfileError.exceedsMaxLength(field: k, maxLength: 31)
                    }
                case .pad64:
                    guard prop.value.utf8.count <= 63 else {
                        throw SpoofProfileError.exceedsMaxLength(field: k, maxLength: 63)
                    }
                case .hex:
                    guard IORegistryBridge.decodeHexBytes(prop.value) != nil else {
                        throw SpoofProfileError.invalidHex(field: k)
                    }
                case .cstring, .osstring, .raw:
                    guard prop.value.utf8.count <= 254 else {
                        throw SpoofProfileError.exceedsMaxLength(field: k, maxLength: 254)
                    }
                }
            }
        }
    }

    public static func load(from path: String = defaultPreferencesPath) throws -> SpoofProfile? {
        let url = URL(fileURLWithPath: path)
        guard FileManager.default.fileExists(atPath: url.path) else {
            return nil
        }
        let data = try Data(contentsOf: url)
        return try PropertyListDecoder().decode(SpoofProfile.self, from: data)
    }

    public func save(to path: String = SpoofProfile.defaultPreferencesPath) throws {
        try validate()
        let url = URL(fileURLWithPath: path)
        let parent = url.deletingLastPathComponent()
        try FileManager.default.createDirectory(at: parent, withIntermediateDirectories: true)
        let encoder = PropertyListEncoder()
        encoder.outputFormat = .xml
        let data = try encoder.encode(self)
        try data.write(to: url, options: .atomic)
    }

    public static func removeSaved(at path: String = defaultPreferencesPath) throws {
        if FileManager.default.fileExists(atPath: path) {
            try FileManager.default.removeItem(atPath: path)
        }
    }
}

public enum SpoofProfileError: LocalizedError {
    case invalidCharacters(field: String)
    case exceedsMaxLength(field: String, maxLength: Int)
    case reservedKey(String)
    case duplicateCustomKey(String)
    case invalidHex(field: String)

    public var errorDescription: String? {
        localizedMessage(in: AppLanguage.current)
    }

    public func localizedMessage(in lang: EffectiveLanguage) -> String {
        switch self {
        case .invalidCharacters(let field):
            return L(
                lang,
                zhHant: "\(field) 僅允許輸入純 ASCII 字元且不可包含換行。",
                zhHans: "\(field) 仅允许输入纯 ASCII 字符且不可包含换行。",
                en: "\(field) must contain printable ASCII characters without newlines.",
                ja: "\(field) には改行を含まない ASCII 文字のみ指定できます。"
            )
        case .exceedsMaxLength(let field, let maxLength):
            return L(
                lang,
                zhHant: "\(field) 長度超出上限（最多 \(maxLength) 位元組）。",
                zhHans: "\(field) 长度超出上限（最多 \(maxLength) 字节）。",
                en: "\(field) exceeds the maximum length (\(maxLength) bytes).",
                ja: "\(field) の長さが上限（最大 \(maxLength) バイト）を超えています。"
            )
        case .reservedKey(let key):
            return L(
                lang,
                zhHant: "鍵名 \(key) 為核心保留快照欄位，不可覆寫。",
                zhHans: "键名 \(key) 为内核保留快照字段，不可覆盖。",
                en: "Key '\(key)' is reserved for kernel snapshot backup and cannot be overwritten.",
                ja: "キー「\(key)」はカーネルの元データ保持用のため上書きできません。"
            )
        case .duplicateCustomKey(let key):
            return L(
                lang,
                zhHant: "自訂屬性鍵名重複：\(key)。",
                zhHans: "自定义属性键名重复：\(key)。",
                en: "Duplicate custom property key: \(key).",
                ja: "カスタムプロパティのキーが重複しています: \(key)"
            )
        case .invalidHex(let field):
            return L(
                lang,
                zhHant: "自訂欄位 \(field) 的十六進位格式無效（須為偶數個 Hex 字元且非空，最多 256 bytes）。",
                zhHans: "自定义字段 \(field) 的十六进制格式无效（须为偶数个 Hex 字符且非空，最多 256 bytes）。",
                en: "Custom property '\(field)' has invalid hex bytes (must be even-length, non-empty, up to 256 bytes).",
                ja: "カスタムフィールド「\(field)」の16進バイト列が無効です（偶数文字・空不可・最大256バイト）。"
            )
        }
    }
}
