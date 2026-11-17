// Powered by NyphexAI, Developed by Hikaru(i@rua.moe)
// Licensed under the PolyForm Noncommercial License 1.0.0

import XCTest
@testable import SpoofMacCore

final class SpoofMacCoreTests: XCTestCase {
    func testAllChipGenerationsHavePresetsAndUniqueIDs() {
        XCTAssertEqual(MacModelCatalog.allModels.count, 59)

        let ids = MacModelCatalog.allModels.map(\.modelIdentifier)
        XCTAssertEqual(Set(ids).count, MacModelCatalog.allModels.count, "Model identifiers must be unique")

        for gen in MacChipGeneration.allCases {
            let models = MacModelCatalog.models(for: gen)
            XCTAssertFalse(models.isEmpty, "Generation \(gen.rawValue) should contain at least one preset")
        }
    }

    func testM1ToLatestModelCoverageAndFieldFormats() {
        let m1Air = MacModelCatalog.model(matching: "MacBookAir10,1")
        XCTAssertNotNil(m1Air)
        XCTAssertEqual(m1Air?.chipGeneration, .m1)
        XCTAssertEqual(m1Air?.regulatoryModelNumber, "A2337")
        XCTAssertEqual(m1Air?.targetSubType, "J313AP")

        let m4Max = MacModelCatalog.model(matching: "Mac16,5")
        XCTAssertNotNil(m4Max)
        XCTAssertEqual(m4Max?.chipGeneration, .m4)
        XCTAssertEqual(m4Max?.defaultModelNumber, "MX303")
        XCTAssertEqual(m4Max?.regulatoryModelNumber, "A3186")

        let m5Max = MacModelCatalog.model(matching: "Mac17,6")
        XCTAssertNotNil(m5Max)
        XCTAssertEqual(m5Max?.chipGeneration, .m5)
        XCTAssertEqual(m5Max?.regulatoryModelNumber, "A3429")
        XCTAssertEqual(m5Max?.targetType, "J716c")
        XCTAssertEqual(m5Max?.targetSubType, "J716cAP")

        let m6Mini = MacModelCatalog.model(matching: "Mac18,5")
        XCTAssertNotNil(m6Mini)
        XCTAssertEqual(m6Mini?.chipGeneration, .m6)

        for model in MacModelCatalog.allModels {
            XCTAssertFalse(model.defaultModelNumber.isEmpty)
            XCTAssertTrue(model.regulatoryModelNumber.hasPrefix("A"), "Regulatory number should start with A: \(model.regulatoryModelNumber)")
            XCTAssertTrue(model.targetSubType.hasPrefix(model.targetType), "targetSubType should start with targetType for \(model.modelIdentifier)")
            XCTAssertTrue(model.targetSubType.hasSuffix("AP"))
        }
    }

    func testRegionCatalogCoverage() {
        XCTAssertEqual(MacModelCatalog.allRegions.count, 13)
        for code in ["LL/A", "TA/A", "ZP/A", "J/A", "CH/A"] {
            XCTAssertNotNil(MacModelCatalog.region(matching: code), "Missing region \(code)")
        }
        XCTAssertEqual(MacModelCatalog.usRegionPreset.countryCode3, "USA")
        XCTAssertTrue(MacModelCatalog.usRegionPreset.unlocksAllFeatures)
        XCTAssertFalse(MacModelCatalog.region(matching: "CH/A")!.unlocksAllFeatures)
    }

    func testIORegistryBinaryEncodingMatchesKernelSchema() {
        // model / target-type / target-sub-type: NUL-terminated C-string
        let modelBytes = IORegistryBridge.encodeNullTerminated("Mac17,6")
        XCTAssertEqual(modelBytes.count, 8)
        XCTAssertEqual(modelBytes.last, 0)
        XCTAssertEqual(IORegistryBridge.decodeIORegString(modelBytes), "Mac17,6")

        // region-info / model-number / regulatory-model-number: 32 bytes zero-padded
        let regionBytes = IORegistryBridge.encodeZeroPadded32("LL/A")
        XCTAssertEqual(regionBytes.count, 32)
        XCTAssertEqual(Array(regionBytes.prefix(4)), [0x4c, 0x4c, 0x2f, 0x41])
        XCTAssertTrue(regionBytes.dropFirst(4).allSatisfy { $0 == 0 })
        XCTAssertEqual(IORegistryBridge.decodeIORegString(regionBytes), "LL/A")

        let modelNumBytes = IORegistryBridge.encodeZeroPadded32("MX303")
        XCTAssertEqual(modelNumBytes.count, 32)
        XCTAssertEqual(IORegistryBridge.decodeIORegString(modelNumBytes), "MX303")

        // country-of-origin: raw 3 bytes without NUL terminator
        let countryBytes = IORegistryBridge.encodeRawASCII("USA")
        XCTAssertEqual(countryBytes.count, 3)
        XCTAssertEqual(Array(countryBytes), [0x55, 0x53, 0x41])
        XCTAssertEqual(IORegistryBridge.decodeIORegString(countryBytes), "USA")

        // compatible: <target-sub-type>\0<model>\0AppleARM\0
        let compatBytes = IORegistryBridge.encodeCompatibleArray(["J716cAP", "Mac17,6", "AppleARM"])
        XCTAssertEqual(compatBytes.count, 25)
        XCTAssertEqual(IORegistryBridge.decodeCompatibleArray(compatBytes), ["J716cAP", "Mac17,6", "AppleARM"])
    }

    func testSpoofProfileCombinedPartNumberAndSerialization() throws {
        let preset = MacModelCatalog.model(matching: "Mac16,5")!
        let profile = SpoofProfile.fromPreset(preset, region: MacModelCatalog.usRegionPreset)
        XCTAssertEqual(profile.combinedPartNumber(fallbackModelNumber: "Z1MY000U2", fallbackRegion: "ZP/A"), "MX303LL/A")

        let regionOnly = SpoofProfile.regionOnlyUS()
        XCTAssertEqual(regionOnly.combinedPartNumber(fallbackModelNumber: "Z1MY000U2", fallbackRegion: "CH/A"), "Z1MY000U2LL/A")

        let tempPath = NSTemporaryDirectory() + "spoofmac_test_\(UUID().uuidString).plist"
        defer { try? SpoofProfile.removeSaved(at: tempPath) }

        try profile.save(to: tempPath)
        let loaded = try SpoofProfile.load(from: tempPath)
        XCTAssertEqual(loaded, profile)

        let dict = profile.toKextPropertiesDictionary()
        XCTAssertEqual(dict["SpoofModel"] as? String, "Mac16,5")
        XCTAssertEqual(dict["SpoofRegionInfo"] as? String, "LL/A")
        XCTAssertEqual(dict["SpoofCountryOfOrigin"] as? String, "USA")
        XCTAssertEqual(dict["UpdateCompatible"] as? Bool, true)
    }

    func testSpoofProfileValidationRejectsInvalidInputs() {
        var invalid = SpoofProfile.regionOnlyUS()
        invalid.spoofRegionInfo = "中文"
        XCTAssertThrowsError(try invalid.validate())

        var tooLong = SpoofProfile.regionOnlyUS()
        tooLong.spoofModelNumber = String(repeating: "A", count: 32)
        XCTAssertThrowsError(try tooLong.validate())
    }

    func testMetadataAttributionAndLicense() {
        XCTAssertEqual(SpoofMacMetadata.attribution, "Powered by NyphexAI, Developed by Hikaru(i@rua.moe)")
        XCTAssertEqual(SpoofMacMetadata.licenseName, "PolyForm Noncommercial License 1.0.0")
        XCTAssertTrue(SpoofMacMetadata.requiredNotice.hasPrefix("Required Notice:"))
    }

    func testExtendedFieldsCustomPropertiesAndRandomGenerators() throws {
        // 64-byte zero-padded encoding (config-number)
        let pad64 = IORegistryBridge.encodeZeroPadded64("CFG123")
        XCTAssertEqual(pad64.count, 64)
        XCTAssertEqual(IORegistryBridge.decodeIORegString(pad64), "CFG123")

        // Hex decoding
        let hexData = IORegistryBridge.decodeHexBytes("01 00 0a ff")
        XCTAssertEqual(hexData, Data([0x01, 0x00, 0x0a, 0xff]))
        XCTAssertNil(IORegistryBridge.decodeHexBytes("010")) // odd nibble length
        XCTAssertNil(IORegistryBridge.decodeHexBytes("ZZZZ"))

        // Random identity generators
        let sn = RandomIdentityGenerator.generateSerialNumber()
        XCTAssertEqual(sn.count, 10)
        XCTAssertFalse(sn.contains("I") || sn.contains("O"))
        let uuid = RandomIdentityGenerator.generateUUID()
        XCTAssertNotNil(UUID(uuidString: uuid))
        let mlb = RandomIdentityGenerator.generateMLB()
        XCTAssertEqual(mlb.count, 17)
        XCTAssertTrue(mlb.hasPrefix("C02"))

        // Custom properties serialization & validation
        var profile = SpoofProfile.fromPreset(MacModelCatalog.flagshipPreset, includePlatformName: true)
        profile.spoofSerialNumber = sn
        profile.spoofUUID = uuid
        profile.spoofMLB = mlb
        profile.customProperties = [
            CustomIORegProperty(key: "custom-flag", type: .hex, value: "01000000"),
            CustomIORegProperty(key: "custom-tag", type: .cstring, value: "hello"),
        ]
        try profile.validate()

        let kextDict = profile.toKextPropertiesDictionary()
        XCTAssertEqual(kextDict["SpoofPlatformName"] as? String, "t6050")
        XCTAssertEqual(kextDict["SpoofSerialNumber"] as? String, sn)
        XCTAssertEqual(kextDict["SpoofUUID"] as? String, uuid)
        XCTAssertEqual(kextDict["SpoofMLB"] as? String, mlb)
        let customMap = kextDict["CustomProperties"] as? [String: [String: String]]
        XCTAssertEqual(customMap?["custom-flag"]?["Type"], "hex")
        XCTAssertEqual(customMap?["custom-flag"]?["Value"], "01000000")

        // Reserved key rejection
        var badReserved = SpoofProfile.regionOnlyUS()
        badReserved.customProperties = [CustomIORegProperty(key: "spoofmac-originals", type: .cstring, value: "bad")]
        XCTAssertThrowsError(try badReserved.validate())

        // Masking helper
        XCTAssertEqual(HardwareIdentitySnapshot.masked("C02XY12345", revealed: false), "C02••••345")
        XCTAssertEqual(HardwareIdentitySnapshot.masked("C02XY12345", revealed: true), "C02XY12345")
    }

    func testMultiLanguageLocalizationSupport() {
        XCTAssertEqual(AppLanguage.parseIdentifier("zh-Hant"), .zhHant)
        XCTAssertEqual(AppLanguage.parseIdentifier("zh_TW"), .zhHant)
        XCTAssertEqual(AppLanguage.parseIdentifier("zh-Hans"), .zhHans)
        XCTAssertEqual(AppLanguage.parseIdentifier("zh_CN"), .zhHans)
        XCTAssertEqual(AppLanguage.parseIdentifier("en-US"), .en)
        XCTAssertEqual(AppLanguage.parseIdentifier("ja-JP"), .ja)

        let us = MacModelCatalog.usRegionPreset
        XCTAssertTrue(us.displayLabel(in: .zhHant).contains("美國版"))
        XCTAssertTrue(us.displayLabel(in: .zhHans).contains("美国版"))
        XCTAssertTrue(us.displayLabel(in: .en).contains("United States"))
        XCTAssertTrue(us.displayLabel(in: .ja).contains("アメリカ版"))

        let eligibleDomain = EligibilityDomainStatus(
            id: "OS_ELIGIBILITY_DOMAIN_GREYMATTER",
            displayName: "Apple Intelligence",
            description: "desc",
            answer: 4
        )
        XCTAssertEqual(eligibleDomain.statusLabel(in: .zhHant), "已解鎖 (4 ✓)")
        XCTAssertEqual(eligibleDomain.statusLabel(in: .zhHans), "已解锁 (4 ✓)")
        XCTAssertEqual(eligibleDomain.statusLabel(in: .en), "Eligible (4 ✓)")
        XCTAssertEqual(eligibleDomain.statusLabel(in: .ja), "利用可能 (4 ✓)")

        let report = SystemDiagnosticReport(
            timestamp: Date(),
            factoryIdentity: HardwareIdentitySnapshot(model: "Mac17,6"),
            currentIdentity: HardwareIdentitySnapshot(model: "Mac17,6"),
            kextStatus: KextRuntimeStatus(),
            savedProfile: nil,
            security: SecurityEnvironmentStatus(
                isAppleSilicon: true, architecture: "arm64", macOSVersion: "27.2", macOSBuild: "26B131",
                sipStatusRaw: "enabled", sipAllowsKext: false, sipFullyDisabled: false,
                thirdPartyKextsPolicy: "unknown", bootArgs: "", hasAmfiBypassBootArg: false,
                hasSpoofOffBootArg: false, amfiLaunchConstraints: "1", lockedEligibilityFiles: [],
                appleLanguages: "en-US", siriLanguage: "en-US", launchDaemonInstalled: false,
                kextInstalledToSystem: false, kextLoadedInKernel: false
            ),
            eligibilityDomains: [eligibleDomain],
            eligibilityReadable: true,
            eligibilityNote: ""
        )
        XCTAssertTrue(report.formatPlainText(language: .en).contains("Diagnostic Report"))
        XCTAssertTrue(report.formatPlainText(language: .zhHans).contains("诊断报告"))
        XCTAssertTrue(report.formatPlainText(language: .ja).contains("診断レポート"))
        XCTAssertTrue(report.formatPlainText(language: .zhHant).contains("診斷報告"))
    }

    func testLocalizedErrorsAndVersionSync() throws {
        let profileErr = SpoofProfileError.reservedKey("spoofmac-originals")
        XCTAssertTrue(profileErr.localizedMessage(in: .zhHant).contains("保留快照"))
        XCTAssertTrue(profileErr.localizedMessage(in: .zhHans).contains("内核保留"))
        XCTAssertTrue(profileErr.localizedMessage(in: .en).contains("reserved for kernel"))
        XCTAssertTrue(profileErr.localizedMessage(in: .ja).contains("カーネル"))

        let bridgeErr = IORegistryBridgeError.kextServiceNotLoaded
        XCTAssertTrue(bridgeErr.localizedMessage(in: .zhHant).contains("尚未載入核心"))
        XCTAssertTrue(bridgeErr.localizedMessage(in: .zhHans).contains("尚未加载内核"))
        XCTAssertTrue(bridgeErr.localizedMessage(in: .en).contains("not loaded in the kernel"))
        XCTAssertTrue(bridgeErr.localizedMessage(in: .ja).contains("カーネルにロードされていません"))

        let helperErr = PrivilegedHelperError.userCancelled
        XCTAssertTrue(helperErr.localizedMessage(in: .zhHant).contains("已取消"))
        XCTAssertTrue(helperErr.localizedMessage(in: .zhHans).contains("已取消"))
        XCTAssertTrue(helperErr.localizedMessage(in: .en).contains("cancelled"))
        XCTAssertTrue(helperErr.localizedMessage(in: .ja).contains("キャンセル"))

        // Verify AppLanguage.overrideLanguage affects LocalizedError.localizedDescription
        let previous = AppLanguage.overrideLanguage
        defer { AppLanguage.overrideLanguage = previous }
        AppLanguage.overrideLanguage = .en
        XCTAssertEqual(helperErr.localizedDescription, helperErr.localizedMessage(in: .en))
        AppLanguage.overrideLanguage = .ja
        XCTAssertEqual(helperErr.localizedDescription, helperErr.localizedMessage(in: .ja))

        // Verify VERSION file matches SpoofMacMetadata.version
        let repoRoot = URL(fileURLWithPath: #filePath)
            .deletingLastPathComponent()
            .deletingLastPathComponent()
            .deletingLastPathComponent()
        let versionFile = repoRoot.appendingPathComponent("VERSION")
        let versionText = try String(contentsOf: versionFile, encoding: .utf8)
            .trimmingCharacters(in: .whitespacesAndNewlines)
        XCTAssertEqual(versionText, SpoofMacMetadata.version)
    }
}
