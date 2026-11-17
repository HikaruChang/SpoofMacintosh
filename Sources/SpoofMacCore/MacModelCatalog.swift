// Powered by NyphexAI, Developed by Hikaru(i@rua.moe)
// Licensed under the PolyForm Noncommercial License 1.0.0

import Foundation

public enum MacChipGeneration: String, CaseIterable, Codable, Identifiable {
    case m1 = "M1"
    case m2 = "M2"
    case m3 = "M3"
    case m4 = "M4"
    case m5 = "M5"
    case m6 = "M6"

    public var id: String { rawValue }

    public var displayName: String {
        displayName(in: AppLanguage.system.resolved)
    }

    public func displayName(in lang: EffectiveLanguage) -> String {
        L(lang, zhHant: "\(rawValue) 系列", zhHans: "\(rawValue) 系列", en: "\(rawValue) Series", ja: "\(rawValue) シリーズ")
    }
}

public enum MacProductLine: String, CaseIterable, Codable, Identifiable {
    case macBookAir = "MacBook Air"
    case macBookPro = "MacBook Pro"
    case macBookNeo = "MacBook Neo"
    case iMac = "iMac"
    case macMini = "Mac mini"
    case macStudio = "Mac Studio"
    case macPro = "Mac Pro"

    public var id: String { rawValue }
}

public struct MacModelPreset: Identifiable, Codable, Hashable {
    public let id: String
    public let chipGeneration: MacChipGeneration
    public let chipVariant: String
    public let productLine: MacProductLine
    public let marketingName: String
    public let releaseYear: Int
    public let modelIdentifier: String
    public let defaultModelNumber: String
    public let regulatoryModelNumber: String
    public let targetType: String
    public let targetSubType: String
    public let platformName: String

    public init(
        chipGeneration: MacChipGeneration,
        chipVariant: String,
        productLine: MacProductLine,
        marketingName: String,
        releaseYear: Int,
        modelIdentifier: String,
        defaultModelNumber: String,
        regulatoryModelNumber: String,
        targetType: String,
        targetSubType: String,
        platformName: String
    ) {
        self.id = modelIdentifier
        self.chipGeneration = chipGeneration
        self.chipVariant = chipVariant
        self.productLine = productLine
        self.marketingName = marketingName
        self.releaseYear = releaseYear
        self.modelIdentifier = modelIdentifier
        self.defaultModelNumber = defaultModelNumber
        self.regulatoryModelNumber = regulatoryModelNumber
        self.targetType = targetType
        self.targetSubType = targetSubType
        self.platformName = platformName
    }

    public var displayLabel: String {
        "\(marketingName) — \(modelIdentifier)"
    }

    public func localizedMarketingName(in lang: EffectiveLanguage) -> String {
        switch lang {
        case .zhHant:
            return marketingName
        case .zhHans:
            return marketingName
                .replacingOccurrences(of: "雙埠", with: "双端口")
                .replacingOccurrences(of: "四埠", with: "四端口")
        case .en:
            return marketingName
                .replacingOccurrences(of: " 雙埠", with: " 2-Port")
                .replacingOccurrences(of: " 四埠", with: " 4-Port")
                .replacingOccurrences(of: "14核", with: "14-Core")
                .replacingOccurrences(of: "16核", with: "16-Core")
        case .ja:
            return marketingName
                .replacingOccurrences(of: " 雙埠", with: " 2ポート")
                .replacingOccurrences(of: " 四埠", with: " 4ポート")
                .replacingOccurrences(of: "14核", with: "14コア")
                .replacingOccurrences(of: "16核", with: "16コア")
        }
    }

    public func displayLabel(in lang: EffectiveLanguage) -> String {
        "\(localizedMarketingName(in: lang)) — \(modelIdentifier)"
    }
}

public struct RegionPreset: Identifiable, Codable, Hashable {
    public let id: String
    public let regionCode: String
    public let countryCode3: String
    public let displayName: String
    public let flagEmoji: String
    public let unlocksAllFeatures: Bool
    public let notes: String

    public init(
        regionCode: String,
        countryCode3: String,
        displayName: String,
        flagEmoji: String,
        unlocksAllFeatures: Bool,
        notes: String
    ) {
        self.id = regionCode
        self.regionCode = regionCode
        self.countryCode3 = countryCode3
        self.displayName = displayName
        self.flagEmoji = flagEmoji
        self.unlocksAllFeatures = unlocksAllFeatures
        self.notes = notes
    }

    public var displayLabel: String {
        displayLabel(in: AppLanguage.system.resolved)
    }

    public func localizedDisplayName(in lang: EffectiveLanguage) -> String {
        switch (regionCode, lang) {
        case ("LL/A", .zhHant): return "美國版 (United States)"
        case ("LL/A", .zhHans): return "美国版 (United States)"
        case ("LL/A", .en): return "United States"
        case ("LL/A", .ja): return "アメリカ版 (United States)"
        case ("TA/A", .zhHant): return "台灣版 (Taiwan)"
        case ("TA/A", .zhHans): return "台湾版 (Taiwan)"
        case ("TA/A", .en): return "Taiwan"
        case ("TA/A", .ja): return "台湾版 (Taiwan)"
        case ("ZP/A", .zhHant): return "香港／澳門版 (Hong Kong / Macau)"
        case ("ZP/A", .zhHans): return "香港／澳门版 (Hong Kong / Macau)"
        case ("ZP/A", .en): return "Hong Kong / Macau"
        case ("ZP/A", .ja): return "香港／マカオ版 (HK / Macau)"
        case ("J/A", .zhHant): return "日本版 (Japan)"
        case ("J/A", .zhHans): return "日本版 (Japan)"
        case ("J/A", .en): return "Japan"
        case ("J/A", .ja): return "日本版 (Japan)"
        case ("ZA/A", .zhHant): return "新加坡版 (Singapore)"
        case ("ZA/A", .zhHans): return "新加坡版 (Singapore)"
        case ("ZA/A", .en): return "Singapore"
        case ("ZA/A", .ja): return "シンガポール版 (Singapore)"
        case ("KH/A", .zhHant): return "韓國版 (South Korea)"
        case ("KH/A", .zhHans): return "韩国版 (South Korea)"
        case ("KH/A", .en): return "South Korea"
        case ("KH/A", .ja): return "韓国版 (South Korea)"
        case ("C/A", .zhHant): return "加拿大版 (Canada)"
        case ("C/A", .zhHans): return "加拿大版 (Canada)"
        case ("C/A", .en): return "Canada"
        case ("C/A", .ja): return "カナダ版 (Canada)"
        case ("X/A", .zhHant): return "澳洲／紐西蘭版 (Australia / NZ)"
        case ("X/A", .zhHans): return "澳大利亚／新西兰版 (Australia / NZ)"
        case ("X/A", .en): return "Australia / New Zealand"
        case ("X/A", .ja): return "オーストラリア／NZ版"
        case ("B/A", .zhHant): return "英國版 (United Kingdom)"
        case ("B/A", .zhHans): return "英国版 (United Kingdom)"
        case ("B/A", .en): return "United Kingdom"
        case ("B/A", .ja): return "イギリス版 (UK)"
        case ("FD/A", .zhHant): return "瑞士版 (Switzerland)"
        case ("FD/A", .zhHans): return "瑞士版 (Switzerland)"
        case ("FD/A", .en): return "Switzerland"
        case ("FD/A", .ja): return "スイス版 (Switzerland)"
        case ("ZD/A", .zhHant): return "德國／歐盟版 (Germany / EU)"
        case ("ZD/A", .zhHans): return "德国／欧盟版 (Germany / EU)"
        case ("ZD/A", .en): return "Germany / EU"
        case ("ZD/A", .ja): return "ドイツ／EU版 (Germany / EU)"
        case ("FN/A", .zhHant): return "法國／歐盟版 (France / EU)"
        case ("FN/A", .zhHans): return "法国／欧盟版 (France / EU)"
        case ("FN/A", .en): return "France / EU"
        case ("FN/A", .ja): return "フランス／EU版 (France / EU)"
        case ("CH/A", .zhHant): return "中國大陸國行版 (Mainland China)"
        case ("CH/A", .zhHans): return "中国大陆国行版 (Mainland China)"
        case ("CH/A", .en): return "Mainland China"
        case ("CH/A", .ja): return "中国本土版 (Mainland China)"
        default: return displayName
        }
    }

    public func localizedNotes(in lang: EffectiveLanguage) -> String {
        switch (regionCode, lang) {
        case ("LL/A", .zhHant): return notes
        case ("LL/A", .zhHans): return "完整解锁 Apple Intelligence、iPhone 镜像、Xcode AI、新版 Siri 与 FaceTime 语音"
        case ("LL/A", .en): return "Unlocks Apple Intelligence, iPhone Mirroring, Xcode AI, new Siri & FaceTime Audio"
        case ("LL/A", .ja): return "Apple Intelligence・iPhoneミラーリング・Xcode AI・新Siriを完全解放"
        case ("TA/A", .zhHant): return notes
        case ("TA/A", .zhHans): return "具备完整 Apple Intelligence、iPhone 镜像与 Xcode AI 硬件区域资格"
        case ("TA/A", .en): return "Eligible for Apple Intelligence, iPhone Mirroring & Xcode AI"
        case ("TA/A", .ja): return "Apple Intelligence・iPhoneミラーリング・Xcode AIに対応"
        case ("ZP/A", .zhHant): return notes
        case ("ZP/A", .zhHans): return "具备 Apple Intelligence 硬件区域资格；不受国行 CH/A 限制"
        case ("ZP/A", .en): return "Eligible for Apple Intelligence; not subject to CH/A restrictions"
        case ("ZP/A", .ja): return "Apple Intelligence対応（CH/Aの地域制限なし）"
        case ("J/A", .zhHant): return notes
        case ("J/A", .zhHans): return "具备完整 Apple Intelligence 与 iPhone 镜像硬件区域资格"
        case ("J/A", .en): return "Eligible for Apple Intelligence & iPhone Mirroring"
        case ("J/A", .ja): return "Apple IntelligenceおよびiPhoneミラーリングに対応"
        case ("ZA/A", .zhHans), ("KH/A", .zhHans), ("C/A", .zhHans), ("X/A", .zhHans), ("B/A", .zhHans), ("FD/A", .zhHans):
            return "具备完整 Apple Intelligence 与区域功能资格"
        case ("ZA/A", .en), ("KH/A", .en), ("C/A", .en), ("X/A", .en), ("B/A", .en), ("FD/A", .en):
            return "Eligible for Apple Intelligence and regional system features"
        case ("ZA/A", .ja), ("KH/A", .ja), ("C/A", .ja), ("X/A", .ja), ("B/A", .ja), ("FD/A", .ja):
            return "Apple Intelligenceおよび各種地域機能に対応"
        case ("ZD/A", .zhHans), ("FN/A", .zhHans):
            return "受欧盟 DMA 法规影响，部分版本可能限制 iPhone 镜像 (IRON)"
        case ("ZD/A", .en), ("FN/A", .en):
            return "Subject to EU DMA regulations; iPhone Mirroring (IRON) may be restricted"
        case ("ZD/A", .ja), ("FN/A", .ja):
            return "EU DMA規制によりiPhoneミラーリング (IRON) が制限される場合があります"
        case ("CH/A", .zhHans):
            return "限制 Apple Intelligence (GREYMATTER) 与 FaceTime 语音通话等服务"
        case ("CH/A", .en):
            return "Restricts Apple Intelligence (GREYMATTER), FaceTime Audio, and related features"
        case ("CH/A", .ja):
            return "Apple Intelligence (GREYMATTER) やFaceTimeオーディオなどが制限されます"
        default:
            return notes
        }
    }

    public func displayLabel(in lang: EffectiveLanguage) -> String {
        let badge = unlocksAllFeatures
            ? L(lang, zhHant: " — 推薦：解鎖全部功能", zhHans: " — 推荐：解锁全部功能", en: " — Recommended: Unlocks All", ja: " — 推奨：全機能解放")
            : ""
        return "\(flagEmoji) \(localizedDisplayName(in: lang)) (\(regionCode))\(badge)"
    }
}

public enum RandomIdentityGenerator {
    private static let safeAlphaNum = Array("0123456789ABCDEFGHJKLMNPQRSTUVWXYZ")
    private static let safeLetters = Array("ABCDEFGHJKLMNPQRSTUVWXYZ")

    public static func generateSerialNumber() -> String {
        var result = String(safeLetters.randomElement()!)
        for _ in 0..<9 {
            result.append(safeAlphaNum.randomElement()!)
        }
        return result
    }

    public static func generateUUID() -> String {
        UUID().uuidString.uppercased()
    }

    public static func generateMLB() -> String {
        var result = "C02"
        for _ in 0..<14 {
            result.append(safeAlphaNum.randomElement()!)
        }
        return result
    }
}

public enum MacModelCatalog {
    public static let allModels: [MacModelPreset] = [
        // MARK: - M1 Generation (11 models)
        MacModelPreset(
            chipGeneration: .m1, chipVariant: "M1", productLine: .macBookAir,
            marketingName: "MacBook Air 13\" (M1, 2020)", releaseYear: 2020,
            modelIdentifier: "MacBookAir10,1", defaultModelNumber: "MGN63",
            regulatoryModelNumber: "A2337", targetType: "J313", targetSubType: "J313AP", platformName: "t8103"
        ),
        MacModelPreset(
            chipGeneration: .m1, chipVariant: "M1", productLine: .macBookPro,
            marketingName: "MacBook Pro 13\" (M1, 2020)", releaseYear: 2020,
            modelIdentifier: "MacBookPro17,1", defaultModelNumber: "MYD83",
            regulatoryModelNumber: "A2338", targetType: "J293", targetSubType: "J293AP", platformName: "t8103"
        ),
        MacModelPreset(
            chipGeneration: .m1, chipVariant: "M1", productLine: .macMini,
            marketingName: "Mac mini (M1, 2020)", releaseYear: 2020,
            modelIdentifier: "Macmini9,1", defaultModelNumber: "MGNR3",
            regulatoryModelNumber: "A2348", targetType: "J274", targetSubType: "J274AP", platformName: "t8103"
        ),
        MacModelPreset(
            chipGeneration: .m1, chipVariant: "M1", productLine: .iMac,
            marketingName: "iMac 24\" 雙埠 (M1, 2021)", releaseYear: 2021,
            modelIdentifier: "iMac21,2", defaultModelNumber: "MJV93",
            regulatoryModelNumber: "A2439", targetType: "J457", targetSubType: "J457AP", platformName: "t8103"
        ),
        MacModelPreset(
            chipGeneration: .m1, chipVariant: "M1", productLine: .iMac,
            marketingName: "iMac 24\" 四埠 (M1, 2021)", releaseYear: 2021,
            modelIdentifier: "iMac21,1", defaultModelNumber: "MGPK3",
            regulatoryModelNumber: "A2438", targetType: "J456", targetSubType: "J456AP", platformName: "t8103"
        ),
        MacModelPreset(
            chipGeneration: .m1, chipVariant: "M1 Pro", productLine: .macBookPro,
            marketingName: "MacBook Pro 14\" (M1 Pro, 2021)", releaseYear: 2021,
            modelIdentifier: "MacBookPro18,3", defaultModelNumber: "MKGP3",
            regulatoryModelNumber: "A2442", targetType: "J314s", targetSubType: "J314sAP", platformName: "t6000"
        ),
        MacModelPreset(
            chipGeneration: .m1, chipVariant: "M1 Max", productLine: .macBookPro,
            marketingName: "MacBook Pro 14\" (M1 Max, 2021)", releaseYear: 2021,
            modelIdentifier: "MacBookPro18,4", defaultModelNumber: "MKGT3",
            regulatoryModelNumber: "A2442", targetType: "J314c", targetSubType: "J314cAP", platformName: "t6001"
        ),
        MacModelPreset(
            chipGeneration: .m1, chipVariant: "M1 Pro", productLine: .macBookPro,
            marketingName: "MacBook Pro 16\" (M1 Pro, 2021)", releaseYear: 2021,
            modelIdentifier: "MacBookPro18,1", defaultModelNumber: "MK183",
            regulatoryModelNumber: "A2485", targetType: "J316s", targetSubType: "J316sAP", platformName: "t6000"
        ),
        MacModelPreset(
            chipGeneration: .m1, chipVariant: "M1 Max", productLine: .macBookPro,
            marketingName: "MacBook Pro 16\" (M1 Max, 2021)", releaseYear: 2021,
            modelIdentifier: "MacBookPro18,2", defaultModelNumber: "MK1A3",
            regulatoryModelNumber: "A2485", targetType: "J316c", targetSubType: "J316cAP", platformName: "t6001"
        ),
        MacModelPreset(
            chipGeneration: .m1, chipVariant: "M1 Max", productLine: .macStudio,
            marketingName: "Mac Studio (M1 Max, 2022)", releaseYear: 2022,
            modelIdentifier: "Mac13,1", defaultModelNumber: "MJMV3",
            regulatoryModelNumber: "A2615", targetType: "J375c", targetSubType: "J375cAP", platformName: "t6001"
        ),
        MacModelPreset(
            chipGeneration: .m1, chipVariant: "M1 Ultra", productLine: .macStudio,
            marketingName: "Mac Studio (M1 Ultra, 2022)", releaseYear: 2022,
            modelIdentifier: "Mac13,2", defaultModelNumber: "MJMW3",
            regulatoryModelNumber: "A2615", targetType: "J375d", targetSubType: "J375dAP", platformName: "t6002"
        ),

        // MARK: - M2 Generation (12 models)
        MacModelPreset(
            chipGeneration: .m2, chipVariant: "M2", productLine: .macBookAir,
            marketingName: "MacBook Air 13\" (M2, 2022)", releaseYear: 2022,
            modelIdentifier: "Mac14,2", defaultModelNumber: "MLXY3",
            regulatoryModelNumber: "A2681", targetType: "J413", targetSubType: "J413AP", platformName: "t8112"
        ),
        MacModelPreset(
            chipGeneration: .m2, chipVariant: "M2", productLine: .macBookPro,
            marketingName: "MacBook Pro 13\" (M2, 2022)", releaseYear: 2022,
            modelIdentifier: "Mac14,7", defaultModelNumber: "MNEH3",
            regulatoryModelNumber: "A2338", targetType: "J493", targetSubType: "J493AP", platformName: "t8112"
        ),
        MacModelPreset(
            chipGeneration: .m2, chipVariant: "M2", productLine: .macMini,
            marketingName: "Mac mini (M2, 2023)", releaseYear: 2023,
            modelIdentifier: "Mac14,3", defaultModelNumber: "MMFJ3",
            regulatoryModelNumber: "A2686", targetType: "J473", targetSubType: "J473AP", platformName: "t8112"
        ),
        MacModelPreset(
            chipGeneration: .m2, chipVariant: "M2 Pro", productLine: .macMini,
            marketingName: "Mac mini (M2 Pro, 2023)", releaseYear: 2023,
            modelIdentifier: "Mac14,12", defaultModelNumber: "MNH73",
            regulatoryModelNumber: "A2816", targetType: "J474s", targetSubType: "J474sAP", platformName: "t6020"
        ),
        MacModelPreset(
            chipGeneration: .m2, chipVariant: "M2 Pro", productLine: .macBookPro,
            marketingName: "MacBook Pro 14\" (M2 Pro, 2023)", releaseYear: 2023,
            modelIdentifier: "Mac14,9", defaultModelNumber: "MPHE3",
            regulatoryModelNumber: "A2779", targetType: "J414s", targetSubType: "J414sAP", platformName: "t6020"
        ),
        MacModelPreset(
            chipGeneration: .m2, chipVariant: "M2 Max", productLine: .macBookPro,
            marketingName: "MacBook Pro 14\" (M2 Max, 2023)", releaseYear: 2023,
            modelIdentifier: "Mac14,5", defaultModelNumber: "MPHH3",
            regulatoryModelNumber: "A2779", targetType: "J414c", targetSubType: "J414cAP", platformName: "t6021"
        ),
        MacModelPreset(
            chipGeneration: .m2, chipVariant: "M2 Pro", productLine: .macBookPro,
            marketingName: "MacBook Pro 16\" (M2 Pro, 2023)", releaseYear: 2023,
            modelIdentifier: "Mac14,10", defaultModelNumber: "MNW83",
            regulatoryModelNumber: "A2780", targetType: "J416s", targetSubType: "J416sAP", platformName: "t6020"
        ),
        MacModelPreset(
            chipGeneration: .m2, chipVariant: "M2 Max", productLine: .macBookPro,
            marketingName: "MacBook Pro 16\" (M2 Max, 2023)", releaseYear: 2023,
            modelIdentifier: "Mac14,6", defaultModelNumber: "MNWA3",
            regulatoryModelNumber: "A2780", targetType: "J416c", targetSubType: "J416cAP", platformName: "t6021"
        ),
        MacModelPreset(
            chipGeneration: .m2, chipVariant: "M2", productLine: .macBookAir,
            marketingName: "MacBook Air 15\" (M2, 2023)", releaseYear: 2023,
            modelIdentifier: "Mac14,15", defaultModelNumber: "MQKP3",
            regulatoryModelNumber: "A2941", targetType: "J415", targetSubType: "J415AP", platformName: "t8112"
        ),
        MacModelPreset(
            chipGeneration: .m2, chipVariant: "M2 Max", productLine: .macStudio,
            marketingName: "Mac Studio (M2 Max, 2023)", releaseYear: 2023,
            modelIdentifier: "Mac14,13", defaultModelNumber: "MQH73",
            regulatoryModelNumber: "A2901", targetType: "J475c", targetSubType: "J475cAP", platformName: "t6021"
        ),
        MacModelPreset(
            chipGeneration: .m2, chipVariant: "M2 Ultra", productLine: .macStudio,
            marketingName: "Mac Studio (M2 Ultra, 2023)", releaseYear: 2023,
            modelIdentifier: "Mac14,14", defaultModelNumber: "MQH63",
            regulatoryModelNumber: "A2901", targetType: "J475d", targetSubType: "J475dAP", platformName: "t6022"
        ),
        MacModelPreset(
            chipGeneration: .m2, chipVariant: "M2 Ultra", productLine: .macPro,
            marketingName: "Mac Pro (M2 Ultra, 2023)", releaseYear: 2023,
            modelIdentifier: "Mac14,8", defaultModelNumber: "M2H33",
            regulatoryModelNumber: "A2786", targetType: "J180d", targetSubType: "J180dAP", platformName: "t6022"
        ),

        // MARK: - M3 Generation (12 models)
        MacModelPreset(
            chipGeneration: .m3, chipVariant: "M3", productLine: .iMac,
            marketingName: "iMac 24\" 雙埠 (M3, 2023)", releaseYear: 2023,
            modelIdentifier: "Mac15,4", defaultModelNumber: "MQR93",
            regulatoryModelNumber: "A2874", targetType: "J433", targetSubType: "J433AP", platformName: "t8122"
        ),
        MacModelPreset(
            chipGeneration: .m3, chipVariant: "M3", productLine: .iMac,
            marketingName: "iMac 24\" 四埠 (M3, 2023)", releaseYear: 2023,
            modelIdentifier: "Mac15,5", defaultModelNumber: "MQRJ3",
            regulatoryModelNumber: "A2873", targetType: "J434", targetSubType: "J434AP", platformName: "t8122"
        ),
        MacModelPreset(
            chipGeneration: .m3, chipVariant: "M3", productLine: .macBookPro,
            marketingName: "MacBook Pro 14\" (M3, 2023)", releaseYear: 2023,
            modelIdentifier: "Mac15,3", defaultModelNumber: "MTL73",
            regulatoryModelNumber: "A2918", targetType: "J504", targetSubType: "J504AP", platformName: "t8122"
        ),
        MacModelPreset(
            chipGeneration: .m3, chipVariant: "M3 Pro", productLine: .macBookPro,
            marketingName: "MacBook Pro 14\" (M3 Pro, 2023)", releaseYear: 2023,
            modelIdentifier: "Mac15,6", defaultModelNumber: "MRX33",
            regulatoryModelNumber: "A2992", targetType: "J514s", targetSubType: "J514sAP", platformName: "t6030"
        ),
        MacModelPreset(
            chipGeneration: .m3, chipVariant: "M3 Max", productLine: .macBookPro,
            marketingName: "MacBook Pro 14\" 14核 (M3 Max, 2023)", releaseYear: 2023,
            modelIdentifier: "Mac15,10", defaultModelNumber: "MRX43",
            regulatoryModelNumber: "A2992", targetType: "J514m", targetSubType: "J514mAP", platformName: "t6031"
        ),
        MacModelPreset(
            chipGeneration: .m3, chipVariant: "M3 Max", productLine: .macBookPro,
            marketingName: "MacBook Pro 14\" 16核 (M3 Max, 2023)", releaseYear: 2023,
            modelIdentifier: "Mac15,8", defaultModelNumber: "MRX53",
            regulatoryModelNumber: "A2992", targetType: "J514c", targetSubType: "J514cAP", platformName: "t6031"
        ),
        MacModelPreset(
            chipGeneration: .m3, chipVariant: "M3 Pro", productLine: .macBookPro,
            marketingName: "MacBook Pro 16\" (M3 Pro, 2023)", releaseYear: 2023,
            modelIdentifier: "Mac15,7", defaultModelNumber: "MRW13",
            regulatoryModelNumber: "A2991", targetType: "J516s", targetSubType: "J516sAP", platformName: "t6030"
        ),
        MacModelPreset(
            chipGeneration: .m3, chipVariant: "M3 Max", productLine: .macBookPro,
            marketingName: "MacBook Pro 16\" 14核 (M3 Max, 2023)", releaseYear: 2023,
            modelIdentifier: "Mac15,11", defaultModelNumber: "MRW23",
            regulatoryModelNumber: "A2991", targetType: "J516m", targetSubType: "J516mAP", platformName: "t6031"
        ),
        MacModelPreset(
            chipGeneration: .m3, chipVariant: "M3 Max", productLine: .macBookPro,
            marketingName: "MacBook Pro 16\" 16核 (M3 Max, 2023)", releaseYear: 2023,
            modelIdentifier: "Mac15,9", defaultModelNumber: "MUW63",
            regulatoryModelNumber: "A2991", targetType: "J516c", targetSubType: "J516cAP", platformName: "t6031"
        ),
        MacModelPreset(
            chipGeneration: .m3, chipVariant: "M3", productLine: .macBookAir,
            marketingName: "MacBook Air 13\" (M3, 2024)", releaseYear: 2024,
            modelIdentifier: "Mac15,12", defaultModelNumber: "MRXN3",
            regulatoryModelNumber: "A3113", targetType: "J613", targetSubType: "J613AP", platformName: "t8122"
        ),
        MacModelPreset(
            chipGeneration: .m3, chipVariant: "M3", productLine: .macBookAir,
            marketingName: "MacBook Air 15\" (M3, 2024)", releaseYear: 2024,
            modelIdentifier: "Mac15,13", defaultModelNumber: "MRYM3",
            regulatoryModelNumber: "A3114", targetType: "J615", targetSubType: "J615AP", platformName: "t8122"
        ),
        MacModelPreset(
            chipGeneration: .m3, chipVariant: "M3 Ultra", productLine: .macStudio,
            marketingName: "Mac Studio (M3 Ultra, 2025)", releaseYear: 2025,
            modelIdentifier: "Mac15,14", defaultModelNumber: "MU973",
            regulatoryModelNumber: "A3389", targetType: "J575d", targetSubType: "J575dAP", platformName: "t6032"
        ),

        // MARK: - M4 Generation (12 models)
        MacModelPreset(
            chipGeneration: .m4, chipVariant: "M4", productLine: .iMac,
            marketingName: "iMac 24\" 雙埠 (M4, 2024)", releaseYear: 2024,
            modelIdentifier: "Mac16,2", defaultModelNumber: "MWUC3",
            regulatoryModelNumber: "A3247", targetType: "J623", targetSubType: "J623AP", platformName: "t8132"
        ),
        MacModelPreset(
            chipGeneration: .m4, chipVariant: "M4", productLine: .iMac,
            marketingName: "iMac 24\" 四埠 (M4, 2024)", releaseYear: 2024,
            modelIdentifier: "Mac16,3", defaultModelNumber: "MWUF3",
            regulatoryModelNumber: "A3139", targetType: "J624", targetSubType: "J624AP", platformName: "t8132"
        ),
        MacModelPreset(
            chipGeneration: .m4, chipVariant: "M4", productLine: .macMini,
            marketingName: "Mac mini (M4, 2024)", releaseYear: 2024,
            modelIdentifier: "Mac16,10", defaultModelNumber: "MU9D3",
            regulatoryModelNumber: "A3238", targetType: "J773g", targetSubType: "J773gAP", platformName: "t8132"
        ),
        MacModelPreset(
            chipGeneration: .m4, chipVariant: "M4 Pro", productLine: .macMini,
            marketingName: "Mac mini (M4 Pro, 2024)", releaseYear: 2024,
            modelIdentifier: "Mac16,11", defaultModelNumber: "MCX44",
            regulatoryModelNumber: "A3239", targetType: "J773s", targetSubType: "J773sAP", platformName: "t6040"
        ),
        MacModelPreset(
            chipGeneration: .m4, chipVariant: "M4", productLine: .macBookPro,
            marketingName: "MacBook Pro 14\" (M4, 2024)", releaseYear: 2024,
            modelIdentifier: "Mac16,1", defaultModelNumber: "MW2U3",
            regulatoryModelNumber: "A3112", targetType: "J604", targetSubType: "J604AP", platformName: "t8132"
        ),
        MacModelPreset(
            chipGeneration: .m4, chipVariant: "M4 Pro", productLine: .macBookPro,
            marketingName: "MacBook Pro 14\" (M4 Pro, 2024)", releaseYear: 2024,
            modelIdentifier: "Mac16,8", defaultModelNumber: "MX2H3",
            regulatoryModelNumber: "A3401", targetType: "J614s", targetSubType: "J614sAP", platformName: "t6040"
        ),
        MacModelPreset(
            chipGeneration: .m4, chipVariant: "M4 Max", productLine: .macBookPro,
            marketingName: "MacBook Pro 14\" (M4 Max, 2024)", releaseYear: 2024,
            modelIdentifier: "Mac16,6", defaultModelNumber: "MX2K3",
            regulatoryModelNumber: "A3185", targetType: "J614c", targetSubType: "J614cAP", platformName: "t6041"
        ),
        MacModelPreset(
            chipGeneration: .m4, chipVariant: "M4 Pro", productLine: .macBookPro,
            marketingName: "MacBook Pro 16\" (M4 Pro, 2024)", releaseYear: 2024,
            modelIdentifier: "Mac16,7", defaultModelNumber: "MX2X3",
            regulatoryModelNumber: "A3403", targetType: "J616s", targetSubType: "J616sAP", platformName: "t6040"
        ),
        MacModelPreset(
            chipGeneration: .m4, chipVariant: "M4 Max", productLine: .macBookPro,
            marketingName: "MacBook Pro 16\" (M4 Max, 2024)", releaseYear: 2024,
            modelIdentifier: "Mac16,5", defaultModelNumber: "MX303",
            regulatoryModelNumber: "A3186", targetType: "J616c", targetSubType: "J616cAP", platformName: "t6041"
        ),
        MacModelPreset(
            chipGeneration: .m4, chipVariant: "M4", productLine: .macBookAir,
            marketingName: "MacBook Air 13\" (M4, 2025)", releaseYear: 2025,
            modelIdentifier: "Mac16,12", defaultModelNumber: "MW123",
            regulatoryModelNumber: "A3240", targetType: "J713", targetSubType: "J713AP", platformName: "t8132"
        ),
        MacModelPreset(
            chipGeneration: .m4, chipVariant: "M4", productLine: .macBookAir,
            marketingName: "MacBook Air 15\" (M4, 2025)", releaseYear: 2025,
            modelIdentifier: "Mac16,13", defaultModelNumber: "MW1L3",
            regulatoryModelNumber: "A3241", targetType: "J715", targetSubType: "J715AP", platformName: "t8132"
        ),
        MacModelPreset(
            chipGeneration: .m4, chipVariant: "M4 Max", productLine: .macStudio,
            marketingName: "Mac Studio (M4 Max, 2025)", releaseYear: 2025,
            modelIdentifier: "Mac16,9", defaultModelNumber: "MU963",
            regulatoryModelNumber: "A3143", targetType: "J575c", targetSubType: "J575cAP", platformName: "t6041"
        ),

        // MARK: - M5 / M6 Generation (12 models)
        MacModelPreset(
            chipGeneration: .m5, chipVariant: "M5", productLine: .macBookPro,
            marketingName: "MacBook Pro 14\" (M5, 2025)", releaseYear: 2025,
            modelIdentifier: "Mac17,2", defaultModelNumber: "MX2E4",
            regulatoryModelNumber: "A3434", targetType: "J704", targetSubType: "J704AP", platformName: "t8142"
        ),
        MacModelPreset(
            chipGeneration: .m5, chipVariant: "M5", productLine: .macBookAir,
            marketingName: "MacBook Air 13\" (M5, 2026)", releaseYear: 2026,
            modelIdentifier: "Mac17,3", defaultModelNumber: "MW3A4",
            regulatoryModelNumber: "A3448", targetType: "J813", targetSubType: "J813AP", platformName: "t8142"
        ),
        MacModelPreset(
            chipGeneration: .m5, chipVariant: "M5", productLine: .macBookAir,
            marketingName: "MacBook Air 15\" (M5, 2026)", releaseYear: 2026,
            modelIdentifier: "Mac17,4", defaultModelNumber: "MW3M4",
            regulatoryModelNumber: "A3449", targetType: "J815", targetSubType: "J815AP", platformName: "t8142"
        ),
        MacModelPreset(
            chipGeneration: .m5, chipVariant: "M5", productLine: .macBookNeo,
            marketingName: "MacBook Neo (2026)", releaseYear: 2026,
            modelIdentifier: "Mac17,5", defaultModelNumber: "MW404",
            regulatoryModelNumber: "A3450", targetType: "J700", targetSubType: "J700AP", platformName: "t8142"
        ),
        MacModelPreset(
            chipGeneration: .m5, chipVariant: "M5 Pro", productLine: .macBookPro,
            marketingName: "MacBook Pro 14\" (M5 Pro, 2026)", releaseYear: 2026,
            modelIdentifier: "Mac17,9", defaultModelNumber: "MX4H4",
            regulatoryModelNumber: "A3427", targetType: "J714s", targetSubType: "J714sAP", platformName: "t6050"
        ),
        MacModelPreset(
            chipGeneration: .m5, chipVariant: "M5 Max", productLine: .macBookPro,
            marketingName: "MacBook Pro 14\" (M5 Max, 2026)", releaseYear: 2026,
            modelIdentifier: "Mac17,7", defaultModelNumber: "MX4K4",
            regulatoryModelNumber: "A3428", targetType: "J714c", targetSubType: "J714cAP", platformName: "t6050"
        ),
        MacModelPreset(
            chipGeneration: .m5, chipVariant: "M5 Pro", productLine: .macBookPro,
            marketingName: "MacBook Pro 16\" (M5 Pro, 2026)", releaseYear: 2026,
            modelIdentifier: "Mac17,8", defaultModelNumber: "MX4X4",
            regulatoryModelNumber: "A3430", targetType: "J716s", targetSubType: "J716sAP", platformName: "t6050"
        ),
        MacModelPreset(
            chipGeneration: .m5, chipVariant: "M5 Max", productLine: .macBookPro,
            marketingName: "MacBook Pro 16\" (M5 Max, 2026)", releaseYear: 2026,
            modelIdentifier: "Mac17,6", defaultModelNumber: "MX4Z4",
            regulatoryModelNumber: "A3429", targetType: "J716c", targetSubType: "J716cAP", platformName: "t6050"
        ),
        MacModelPreset(
            chipGeneration: .m5, chipVariant: "M5 Pro", productLine: .macMini,
            marketingName: "Mac mini (M5 Pro, 2026)", releaseYear: 2026,
            modelIdentifier: "Mac17,16", defaultModelNumber: "MCY44",
            regulatoryModelNumber: "A3456", targetType: "J873s", targetSubType: "J873sAP", platformName: "t6050"
        ),
        MacModelPreset(
            chipGeneration: .m5, chipVariant: "M5 Max", productLine: .macStudio,
            marketingName: "Mac Studio (M5 Max, 2026)", releaseYear: 2026,
            modelIdentifier: "Mac17,14", defaultModelNumber: "MU9A4",
            regulatoryModelNumber: "A3461", targetType: "J775c", targetSubType: "J775cAP", platformName: "t6050"
        ),
        MacModelPreset(
            chipGeneration: .m5, chipVariant: "M5 Ultra", productLine: .macStudio,
            marketingName: "Mac Studio (M5 Ultra, 2026)", releaseYear: 2026,
            modelIdentifier: "Mac17,15", defaultModelNumber: "MU9B4",
            regulatoryModelNumber: "A3462", targetType: "J775d", targetSubType: "J775dAP", platformName: "t6052"
        ),
        MacModelPreset(
            chipGeneration: .m6, chipVariant: "M6", productLine: .macMini,
            marketingName: "Mac mini (M6, 2026)", releaseYear: 2026,
            modelIdentifier: "Mac18,5", defaultModelNumber: "MU9E4",
            regulatoryModelNumber: "A3538", targetType: "J973g", targetSubType: "J973gAP", platformName: "t8152"
        ),
    ]

    public static let allRegions: [RegionPreset] = [
        RegionPreset(
            regionCode: "LL/A", countryCode3: "USA", displayName: "美國版 (United States)",
            flagEmoji: "🇺🇸", unlocksAllFeatures: true,
            notes: "完整解鎖 Apple Intelligence、iPhone 鏡像輸出、Xcode AI、新版 Siri 與 FaceTime 語音"
        ),
        RegionPreset(
            regionCode: "TA/A", countryCode3: "TWN", displayName: "台灣版 (Taiwan)",
            flagEmoji: "🇹🇼", unlocksAllFeatures: true,
            notes: "具備完整 Apple Intelligence、iPhone 鏡像輸出與 Xcode AI 硬體區域資格"
        ),
        RegionPreset(
            regionCode: "ZP/A", countryCode3: "HKG", displayName: "香港／澳門版 (Hong Kong / Macau)",
            flagEmoji: "🇭🇰", unlocksAllFeatures: true,
            notes: "具備 Apple Intelligence 硬體區域資格；不受國行 CH/A 限制"
        ),
        RegionPreset(
            regionCode: "J/A", countryCode3: "JPN", displayName: "日本版 (Japan)",
            flagEmoji: "🇯🇵", unlocksAllFeatures: true,
            notes: "具備完整 Apple Intelligence 與 iPhone 鏡像輸出硬體區域資格"
        ),
        RegionPreset(
            regionCode: "ZA/A", countryCode3: "SGP", displayName: "新加坡版 (Singapore)",
            flagEmoji: "🇸🇬", unlocksAllFeatures: true,
            notes: "具備完整 Apple Intelligence 與 iPhone 鏡像輸出硬體區域資格"
        ),
        RegionPreset(
            regionCode: "KH/A", countryCode3: "KOR", displayName: "韓國版 (South Korea)",
            flagEmoji: "🇰🇷", unlocksAllFeatures: true,
            notes: "具備完整 Apple Intelligence 硬體區域資格"
        ),
        RegionPreset(
            regionCode: "C/A", countryCode3: "CAN", displayName: "加拿大版 (Canada)",
            flagEmoji: "🇨🇦", unlocksAllFeatures: true,
            notes: "具備完整北美 Apple Intelligence 與 iPhone 鏡像輸出資格"
        ),
        RegionPreset(
            regionCode: "X/A", countryCode3: "AUS", displayName: "澳洲／紐西蘭版 (Australia / NZ)",
            flagEmoji: "🇦🇺", unlocksAllFeatures: true,
            notes: "具備完整 Apple Intelligence 與 iPhone 鏡像輸出資格"
        ),
        RegionPreset(
            regionCode: "B/A", countryCode3: "GBR", displayName: "英國版 (United Kingdom)",
            flagEmoji: "🇬🇧", unlocksAllFeatures: true,
            notes: "非歐盟區域，具備完整 Apple Intelligence 與 iPhone 鏡像輸出資格"
        ),
        RegionPreset(
            regionCode: "FD/A", countryCode3: "CHE", displayName: "瑞士版 (Switzerland)",
            flagEmoji: "🇨🇭", unlocksAllFeatures: true,
            notes: "非歐盟單一市場地區，支援多數 Apple 功能"
        ),
        RegionPreset(
            regionCode: "ZD/A", countryCode3: "DEU", displayName: "德國／歐盟版 (Germany / EU)",
            flagEmoji: "🇩🇪", unlocksAllFeatures: false,
            notes: "受歐盟 DMA 法規影響，部分版本可能限制 iPhone 鏡像輸出 (IRON)"
        ),
        RegionPreset(
            regionCode: "FN/A", countryCode3: "FRA", displayName: "法國／歐盟版 (France / EU)",
            flagEmoji: "🇫🇷", unlocksAllFeatures: false,
            notes: "受歐盟 DMA 法規影響，部分版本可能限制 iPhone 鏡像輸出 (IRON)"
        ),
        RegionPreset(
            regionCode: "CH/A", countryCode3: "CHN", displayName: "中國大陸國行版 (Mainland China)",
            flagEmoji: "🇨🇳", unlocksAllFeatures: false,
            notes: "限制 Apple Intelligence (GREYMATTER) 與 FaceTime 語音通話等服務"
        ),
    ]

    public static func models(for generation: MacChipGeneration?) -> [MacModelPreset] {
        guard let generation else { return allModels }
        return allModels.filter { $0.chipGeneration == generation }
    }

    public static func model(matching identifier: String) -> MacModelPreset? {
        allModels.first { $0.modelIdentifier.caseInsensitiveCompare(identifier) == .orderedSame }
    }

    public static func region(matching code: String) -> RegionPreset? {
        allRegions.first { $0.regionCode.caseInsensitiveCompare(code) == .orderedSame }
    }

    public static var flagshipPreset: MacModelPreset {
        model(matching: "Mac17,6") ?? allModels.last!
    }

    public static var usRegionPreset: RegionPreset {
        region(matching: "LL/A") ?? allRegions.first!
    }
}
