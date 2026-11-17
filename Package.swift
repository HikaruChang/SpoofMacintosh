// swift-tools-version: 5.10
// Powered by NyphexAI, Developed by Hikaru(i@rua.moe)
// Licensed under the PolyForm Noncommercial License 1.0.0
import PackageDescription

let package = Package(
    name: "SpoofMacintosh",
    platforms: [
        .macOS(.v14)
    ],
    products: [
        .library(
            name: "SpoofMacCore",
            targets: ["SpoofMacCore"]
        ),
        .executable(
            name: "spoofmac",
            targets: ["spoofmac"]
        ),
        .executable(
            name: "SpoofMacintoshApp",
            targets: ["SpoofMacintoshApp"]
        )
    ],
    targets: [
        .target(
            name: "SpoofMacCore",
            linkerSettings: [
                .linkedFramework("IOKit")
            ]
        ),
        .executableTarget(
            name: "spoofmac",
            dependencies: ["SpoofMacCore"]
        ),
        .executableTarget(
            name: "SpoofMacintoshApp",
            dependencies: ["SpoofMacCore"],
            exclude: ["Info.plist"]
        ),
        .testTarget(
            name: "SpoofMacCoreTests",
            dependencies: ["SpoofMacCore"]
        )
    ]
)
