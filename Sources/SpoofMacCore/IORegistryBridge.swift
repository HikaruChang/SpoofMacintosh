// Powered by NyphexAI, Developed by Hikaru(i@rua.moe)
// Licensed under the PolyForm Noncommercial License 1.0.0

import Foundation
import IOKit

public struct HardwareIdentitySnapshot: Codable, Equatable {
    public let model: String
    public let modelNumber: String
    public let regionInfo: String
    public let regulatoryModelNumber: String
    public let targetType: String
    public let targetSubType: String
    public let countryOfOrigin: String
    public let platformName: String
    public let serialNumber: String
    public let rawSerialNumber: String
    public let hardwareUUID: String
    public let mlbSerialNumber: String
    public let manufacturer: String
    public let modelConfig: String
    public let configNumber: String
    public let deviceType: String
    public let secureRootPrefix: String
    public let nodeName: String
    public let compatible: [String]
    public let allAvailableKeys: [String]

    public init(
        model: String = "",
        modelNumber: String = "",
        regionInfo: String = "",
        regulatoryModelNumber: String = "",
        targetType: String = "",
        targetSubType: String = "",
        countryOfOrigin: String = "",
        platformName: String = "",
        serialNumber: String = "",
        rawSerialNumber: String = "",
        hardwareUUID: String = "",
        mlbSerialNumber: String = "",
        manufacturer: String = "",
        modelConfig: String = "",
        configNumber: String = "",
        deviceType: String = "",
        secureRootPrefix: String = "",
        nodeName: String = "",
        compatible: [String] = [],
        allAvailableKeys: [String] = []
    ) {
        self.model = model
        self.modelNumber = modelNumber
        self.regionInfo = regionInfo
        self.regulatoryModelNumber = regulatoryModelNumber
        self.targetType = targetType
        self.targetSubType = targetSubType
        self.countryOfOrigin = countryOfOrigin
        self.platformName = platformName
        self.serialNumber = serialNumber
        self.rawSerialNumber = rawSerialNumber
        self.hardwareUUID = hardwareUUID
        self.mlbSerialNumber = mlbSerialNumber
        self.manufacturer = manufacturer
        self.modelConfig = modelConfig
        self.configNumber = configNumber
        self.deviceType = deviceType
        self.secureRootPrefix = secureRootPrefix
        self.nodeName = nodeName
        self.compatible = compatible
        self.allAvailableKeys = allAvailableKeys
    }

    public var combinedPartNumber: String {
        "\(modelNumber)\(regionInfo)"
    }

    public static func masked(_ value: String, revealed: Bool) -> String {
        guard !revealed else { return value }
        guard !value.isEmpty else { return "" }
        if value.count <= 6 {
            return String(repeating: "•", count: value.count)
        }
        let edge = value.count >= 20 ? 4 : 3
        let prefix = value.prefix(edge)
        let suffix = value.suffix(edge)
        return "\(prefix)••••\(suffix)"
    }
}

public struct KextRuntimeStatus: Codable, Equatable {
    public let isKextServicePresent: Bool
    public let isSpoofActive: Bool
    public let bypassedByBootArg: Bool
    public let updateCompatible: Bool
    public let activeOverrides: [String: String]
    public let activeCustomProperties: [String: String]

    public init(
        isKextServicePresent: Bool = false,
        isSpoofActive: Bool = false,
        bypassedByBootArg: Bool = false,
        updateCompatible: Bool = true,
        activeOverrides: [String: String] = [:],
        activeCustomProperties: [String: String] = [:]
    ) {
        self.isKextServicePresent = isKextServicePresent
        self.isSpoofActive = isSpoofActive
        self.bypassedByBootArg = bypassedByBootArg
        self.updateCompatible = updateCompatible
        self.activeOverrides = activeOverrides
        self.activeCustomProperties = activeCustomProperties
    }
}

public enum IORegistryBridgeError: LocalizedError {
    case kextServiceNotLoaded
    case privilegeRequired
    case invalidArguments
    case ioKitFailure(code: kern_return_t)

    public var errorDescription: String? {
        localizedMessage(in: AppLanguage.current)
    }

    public func localizedMessage(in lang: EffectiveLanguage) -> String {
        switch self {
        case .kextServiceNotLoaded:
            return L(
                lang,
                zhHant: "SpoofMac.kext 尚未載入核心。請先執行安裝並於「系統設定 → 隱私與安全性」批准核心擴展。",
                zhHans: "SpoofMac.kext 尚未加载内核。请先执行安装并在「系统设置 → 隐私与安全性」批准内核扩展。",
                en: "SpoofMac.kext is not loaded in the kernel. Install it and approve the extension in System Settings -> Privacy & Security.",
                ja: "SpoofMac.kext がカーネルにロードされていません。インストール後「システム設定 → プライバシーとセキュリティ」で許可してください。"
            )
        case .privilegeRequired:
            return L(
                lang,
                zhHant: "需要系統管理員 (root) 權限才能動態寫入 IORegistry 核心擴展屬性。",
                zhHans: "需要系统管理员 (root) 权限才能动态写入 IORegistry 内核扩展属性。",
                en: "Administrator (root) privileges are required to modify kernel extension IORegistry properties.",
                ja: "IORegistry カーネル拡張プロパティを変更するには管理者 (root) 権限が必要です。"
            )
        case .invalidArguments:
            return L(
                lang,
                zhHant: "傳入的 IORegistry 屬性格式不正確。",
                zhHans: "传入的 IORegistry 属性格式不正确。",
                en: "Invalid IORegistry property arguments.",
                ja: "渡された IORegistry プロパティの形式が正しくありません。"
            )
        case .ioKitFailure(let code):
            let hex = String(format: "0x%08x", UInt32(bitPattern: code))
            return L(
                lang,
                zhHant: "IOKit 呼叫失敗 (kern_return_t = \(hex))。",
                zhHans: "IOKit 调用失败 (kern_return_t = \(hex))。",
                en: "IOKit call failed (kern_return_t = \(hex)).",
                ja: "IOKit 呼び出しに失敗しました (kern_return_t = \(hex))。"
            )
        }
    }
}

public enum IORegistryBridge {
    public static let platformExpertClass = "IOPlatformExpertDevice"
    public static let kextClassName = "com_spoofmacintosh_SpoofMac"
    public static let kextBundleIdentifier = "com.spoofmacintosh.SpoofMac"

    // MARK: - Binary Encoding / Decoding Helpers (Aligned with SpoofMac.cpp)

    public static func encodeZeroPadded32(_ value: String) -> Data {
        encodeZeroPadded(value, fixedLength: 32)
    }

    public static func encodeZeroPadded64(_ value: String) -> Data {
        encodeZeroPadded(value, fixedLength: 64)
    }

    private static func encodeZeroPadded(_ value: String, fixedLength: Int) -> Data {
        var buffer = Data(count: fixedLength)
        let bytes = Array(value.utf8.prefix(fixedLength - 1))
        for (index, byte) in bytes.enumerated() {
            buffer[index] = byte
        }
        return buffer
    }

    public static func encodeNullTerminated(_ value: String) -> Data {
        var data = Data(value.utf8)
        data.append(0)
        return data
    }

    public static func encodeRawASCII(_ value: String) -> Data {
        Data(value.utf8)
    }

    public static func encodeCompatibleArray(_ elements: [String]) -> Data {
        var data = Data()
        for item in elements where !item.isEmpty {
            data.append(contentsOf: item.utf8)
            data.append(0)
        }
        return data
    }

    public static func decodeHexBytes(_ hexString: String) -> Data? {
        let stripped = hexString
            .replacingOccurrences(of: "0x", with: "")
            .replacingOccurrences(of: "0X", with: "")
            .filter { !$0.isWhitespace && $0 != ":" && $0 != "-" }
        guard !stripped.isEmpty, stripped.count % 2 == 0, stripped.count <= 512 else {
            return nil
        }
        var data = Data(capacity: stripped.count / 2)
        var idx = stripped.startIndex
        while idx < stripped.endIndex {
            let nextIdx = stripped.index(idx, offsetBy: 2)
            guard let byte = UInt8(stripped[idx..<nextIdx], radix: 16) else {
                return nil
            }
            data.append(byte)
            idx = nextIdx
        }
        return data
    }

    public static func decodeIORegString(_ value: Any?) -> String {
        if let str = value as? String {
            return str.trimmingCharacters(in: CharacterSet(charactersIn: "\0"))
        }
        if let data = value as? Data {
            let prefix = data.prefix(while: { $0 != 0 })
            return String(decoding: prefix, as: UTF8.self)
        }
        return ""
    }

    public static func decodeCompatibleArray(_ value: Any?) -> [String] {
        if let strings = value as? [String] {
            return strings.filter { !$0.isEmpty }
        }
        if let data = value as? Data {
            return data
                .split(separator: 0, omittingEmptySubsequences: true)
                .map { String(decoding: $0, as: UTF8.self) }
                .filter { !$0.isEmpty }
        }
        return []
    }

    // MARK: - IOKit Reading

    private static func copyAllProperties(service: io_registry_entry_t) -> [String: Any] {
        var unmanagedDict: Unmanaged<CFMutableDictionary>?
        let kr = IORegistryEntryCreateCFProperties(service, &unmanagedDict, kCFAllocatorDefault, 0)
        guard kr == KERN_SUCCESS, let cfDict = unmanagedDict?.takeRetainedValue() else {
            return [:]
        }
        return (cfDict as? [String: Any]) ?? [:]
    }

    private static func findService(matchingClass className: String) -> io_service_t {
        guard let matching = IOServiceMatching(className) else {
            return 0
        }
        return IOServiceGetMatchingService(kIOMainPortDefault, matching)
    }

    public static func readCurrentHardwareIdentity() -> HardwareIdentitySnapshot {
        let service = findService(matchingClass: platformExpertClass)
        guard service != 0 else {
            return HardwareIdentitySnapshot()
        }
        defer { IOObjectRelease(service) }

        let props = copyAllProperties(service: service)
        let keys = props.keys.filter { $0 != "spoofmac-originals" }.sorted()

        return HardwareIdentitySnapshot(
            model: decodeIORegString(props["model"]),
            modelNumber: decodeIORegString(props["model-number"]),
            regionInfo: decodeIORegString(props["region-info"]),
            regulatoryModelNumber: decodeIORegString(props["regulatory-model-number"]),
            targetType: decodeIORegString(props["target-type"]),
            targetSubType: decodeIORegString(props["target-sub-type"]),
            countryOfOrigin: decodeIORegString(props["country-of-origin"]),
            platformName: decodeIORegString(props["platform-name"]),
            serialNumber: decodeIORegString(props["IOPlatformSerialNumber"]),
            rawSerialNumber: decodeIORegString(props["serial-number"]),
            hardwareUUID: decodeIORegString(props["IOPlatformUUID"]),
            mlbSerialNumber: decodeIORegString(props["mlb-serial-number"]),
            manufacturer: decodeIORegString(props["manufacturer"]),
            modelConfig: decodeIORegString(props["model-config"]),
            configNumber: decodeIORegString(props["config-number"]),
            deviceType: decodeIORegString(props["device_type"]),
            secureRootPrefix: decodeIORegString(props["secure-root-prefix"]),
            nodeName: decodeIORegString(props["name"]),
            compatible: decodeCompatibleArray(props["compatible"]),
            allAvailableKeys: keys
        )
    }

    public static func readFactoryHardwareIdentity() -> HardwareIdentitySnapshot {
        let kextService = findService(matchingClass: kextClassName)
        guard kextService != 0 else {
            return readCurrentHardwareIdentity()
        }
        defer { IOObjectRelease(kextService) }

        let current = readCurrentHardwareIdentity()
        let kextProps = copyAllProperties(service: kextService)

        func factoryOrCurrent(_ origKey: String, fallback: String) -> String {
            if let prop = kextProps[origKey] {
                let decoded = decodeIORegString(prop)
                if !decoded.isEmpty {
                    return decoded
                }
            }
            return fallback
        }

        let origCompat: [String]
        if let prop = kextProps["orig-compatible"] {
            let parsed = decodeCompatibleArray(prop)
            origCompat = parsed.isEmpty ? current.compatible : parsed
        } else {
            origCompat = current.compatible
        }

        return HardwareIdentitySnapshot(
            model: factoryOrCurrent("orig-model", fallback: current.model),
            modelNumber: factoryOrCurrent("orig-model-number", fallback: current.modelNumber),
            regionInfo: factoryOrCurrent("orig-region-info", fallback: current.regionInfo),
            regulatoryModelNumber: factoryOrCurrent("orig-regulatory-model-number", fallback: current.regulatoryModelNumber),
            targetType: factoryOrCurrent("orig-target-type", fallback: current.targetType),
            targetSubType: factoryOrCurrent("orig-target-sub-type", fallback: current.targetSubType),
            countryOfOrigin: factoryOrCurrent("orig-country-of-origin", fallback: current.countryOfOrigin),
            platformName: factoryOrCurrent("orig-platform-name", fallback: current.platformName),
            serialNumber: factoryOrCurrent("orig-IOPlatformSerialNumber", fallback: current.serialNumber),
            rawSerialNumber: factoryOrCurrent("orig-serial-number", fallback: current.rawSerialNumber),
            hardwareUUID: factoryOrCurrent("orig-IOPlatformUUID", fallback: current.hardwareUUID),
            mlbSerialNumber: factoryOrCurrent("orig-mlb-serial-number", fallback: current.mlbSerialNumber),
            manufacturer: factoryOrCurrent("orig-manufacturer", fallback: current.manufacturer),
            modelConfig: factoryOrCurrent("orig-model-config", fallback: current.modelConfig),
            configNumber: factoryOrCurrent("orig-config-number", fallback: current.configNumber),
            deviceType: factoryOrCurrent("orig-device_type", fallback: current.deviceType),
            secureRootPrefix: factoryOrCurrent("orig-secure-root-prefix", fallback: current.secureRootPrefix),
            nodeName: factoryOrCurrent("orig-name", fallback: current.nodeName),
            compatible: origCompat,
            allAvailableKeys: current.allAvailableKeys
        )
    }

    public static func isKextServiceActive() -> Bool {
        let kextService = findService(matchingClass: kextClassName)
        guard kextService != 0 else { return false }
        IOObjectRelease(kextService)
        return true
    }

    public static func readKextStatus() -> KextRuntimeStatus {
        let kextService = findService(matchingClass: kextClassName)
        guard kextService != 0 else {
            return KextRuntimeStatus()
        }
        defer { IOObjectRelease(kextService) }

        let props = copyAllProperties(service: kextService)
        let spoofActive = (props["SpoofActive"] as? Bool) ?? false
        let bypassed = (props["SpoofBypassedByBootArg"] as? Bool) ?? false
        let updateCompat = (props["UpdateCompatible"] as? Bool) ?? true

        let activeKeys = [
            "active-model",
            "active-model-number",
            "active-region-info",
            "active-regulatory-model-number",
            "active-target-type",
            "active-target-sub-type",
            "active-country-of-origin",
            "active-platform-name",
            "active-IOPlatformSerialNumber",
            "active-serial-number",
            "active-IOPlatformUUID",
            "active-mlb-serial-number",
            "active-manufacturer",
            "active-model-config",
            "active-config-number",
            "active-device_type",
            "active-secure-root-prefix",
            "active-name",
        ]
        var overrides: [String: String] = [:]
        for key in activeKeys {
            if let str = props[key] as? String, !str.isEmpty {
                overrides[key] = str
            }
        }
        let customProps = (props["active-custom-properties"] as? [String: String]) ?? [:]

        return KextRuntimeStatus(
            isKextServicePresent: true,
            isSpoofActive: spoofActive,
            bypassedByBootArg: bypassed,
            updateCompatible: updateCompat,
            activeOverrides: overrides,
            activeCustomProperties: customProps
        )
    }

    // MARK: - Dynamic Runtime Updates (Requires Root)

    public static func pushProfileToKext(_ profile: SpoofProfile) throws {
        try profile.validate()
        let dict = profile.toKextPropertiesDictionary()
        try setKextProperties(dict)
    }

    public static func resetKextToFactory() throws {
        try setKextProperties(["ResetToFactory": true])
    }

    private static func setKextProperties(_ properties: [String: Any]) throws {
        let kextService = findService(matchingClass: kextClassName)
        guard kextService != 0 else {
            throw IORegistryBridgeError.kextServiceNotLoaded
        }
        defer { IOObjectRelease(kextService) }

        let kr = IORegistryEntrySetCFProperties(kextService, properties as CFDictionary)
        if kr == KERN_SUCCESS {
            return
        }
        if kr == kIOReturnNotPrivileged {
            throw IORegistryBridgeError.privilegeRequired
        }
        if kr == kIOReturnBadArgument {
            throw IORegistryBridgeError.invalidArguments
        }
        throw IORegistryBridgeError.ioKitFailure(code: kr)
    }
}
