// Powered by NyphexAI, Developed by Hikaru(i@rua.moe)
// Licensed under the PolyForm Noncommercial License 1.0.0

import Foundation

public enum EffectiveLanguage: String, CaseIterable, Codable, Identifiable {
    case zhHant = "zh-Hant"
    case zhHans = "zh-Hans"
    case en = "en"
    case ja = "ja"

    public var id: String { rawValue }

    public var nativeName: String {
        switch self {
        case .zhHant: return "繁體中文"
        case .zhHans: return "简体中文"
        case .en: return "English"
        case .ja: return "日本語"
        }
    }
}

public enum AppLanguage: String, CaseIterable, Codable, Identifiable {
    case system = "system"
    case zhHant = "zh-Hant"
    case zhHans = "zh-Hans"
    case en = "en"
    case ja = "ja"

    public static let defaultsKey = "SpoofMacintosh.AppLanguage"

    private static let overrideLock = NSLock()
    private static var _overrideLanguage: EffectiveLanguage?

    public static var overrideLanguage: EffectiveLanguage? {
        get {
            overrideLock.lock()
            defer { overrideLock.unlock() }
            return _overrideLanguage
        }
        set {
            overrideLock.lock()
            _overrideLanguage = newValue
            overrideLock.unlock()
        }
    }

    public static var current: EffectiveLanguage {
        if let forced = overrideLanguage {
            return forced
        }
        if let savedRaw = UserDefaults.standard.string(forKey: defaultsKey),
           let parsed = AppLanguage(rawValue: savedRaw) {
            return parsed.resolved
        }
        return detectSystemLanguage()
    }

    public var id: String { rawValue }

    public var resolved: EffectiveLanguage {
        switch self {
        case .zhHant: return .zhHant
        case .zhHans: return .zhHans
        case .en: return .en
        case .ja: return .ja
        case .system: return Self.detectSystemLanguage()
        }
    }

    public func menuTitle(in lang: EffectiveLanguage) -> String {
        switch self {
        case .system:
            return L(lang, zhHant: "跟隨系統", zhHans: "跟随系统", en: "Follow System", ja: "システム言語に従う")
        case .zhHant: return EffectiveLanguage.zhHant.nativeName
        case .zhHans: return EffectiveLanguage.zhHans.nativeName
        case .en: return EffectiveLanguage.en.nativeName
        case .ja: return EffectiveLanguage.ja.nativeName
        }
    }

    public static func parseIdentifier(_ raw: String) -> EffectiveLanguage? {
        let lower = raw.trimmingCharacters(in: .whitespacesAndNewlines)
            .lowercased()
            .replacingOccurrences(of: "_", with: "-")
        if lower.isEmpty { return nil }
        if lower == "zh-hans" || lower == "hans" || lower == "zh-cn" || lower == "cn" || lower.hasPrefix("zh-hans-") {
            return .zhHans
        }
        if lower == "zh-hant" || lower == "hant" || lower == "zh-tw" || lower == "tw" || lower == "zh-hk" || lower == "hk" || lower == "zh-mo" || lower.hasPrefix("zh-hant-") || lower == "zh" {
            return .zhHant
        }
        if lower == "ja" || lower == "jp" || lower.hasPrefix("ja-") {
            return .ja
        }
        if lower == "en" || lower.hasPrefix("en-") {
            return .en
        }
        return nil
    }

    public static func detectSystemLanguage() -> EffectiveLanguage {
        let env = ProcessInfo.processInfo.environment
        if let override = env["SPOOFMAC_LANG"], let parsed = parseIdentifier(override) {
            return parsed
        }
        for candidate in Locale.preferredLanguages {
            if let parsed = parseIdentifier(candidate) {
                return parsed
            }
        }
        for key in ["LC_ALL", "LANG"] {
            if let val = env[key], let parsed = parseIdentifier(val.components(separatedBy: ".").first ?? val) {
                return parsed
            }
        }
        return .en
    }
}

public func L(
    _ lang: EffectiveLanguage,
    zhHant: String,
    zhHans: String,
    en: String,
    ja: String
) -> String {
    switch lang {
    case .zhHant: return zhHant
    case .zhHans: return zhHans
    case .en: return en
    case .ja: return ja
    }
}
