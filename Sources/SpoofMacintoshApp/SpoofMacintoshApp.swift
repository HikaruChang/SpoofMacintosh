// Powered by NyphexAI, Developed by Hikaru(i@rua.moe)
// Licensed under the PolyForm Noncommercial License 1.0.0

import AppKit
import SpoofMacCore
import SwiftUI

final class AppDelegate: NSObject, NSApplicationDelegate {
    static func loadAppIconImage() -> NSImage? {
        if let icnsURL = Bundle.main.url(forResource: "AppIcon", withExtension: "icns"),
           let image = NSImage(contentsOf: icnsURL) {
            return image
        }
        if let pngURL = Bundle.main.url(forResource: "icon", withExtension: "png"),
           let image = NSImage(contentsOf: pngURL) {
            return image
        }
        return nil
    }

    func applicationDidFinishLaunching(_ notification: Notification) {
        NSApplication.shared.setActivationPolicy(.regular)
        if let iconImage = Self.loadAppIconImage() {
            NSApplication.shared.applicationIconImage = iconImage
        }
        NSApplication.shared.activate(ignoringOtherApps: true)
    }

    func applicationShouldTerminateAfterLastWindowClosed(_ sender: NSApplication) -> Bool {
        true
    }
}

@main
struct SpoofMacintoshApp: App {
    @NSApplicationDelegateAdaptor(AppDelegate.self) var appDelegate
    @StateObject private var viewModel = AppViewModel()

    var body: some Scene {
        let lang = viewModel.lang
        let windowTitle = L(
            lang,
            zhHant: "SpoofMacintosh — Apple Silicon 機型與全欄位偽裝工具",
            zhHans: "SpoofMacintosh — Apple Silicon 机型与全字段伪装工具",
            en: "SpoofMacintosh — Apple Silicon Hardware & Region Spoofer",
            ja: "SpoofMacintosh — Apple Silicon モデル・地域偽装ツール"
        )
        let aboutLabel = L(
            lang,
            zhHant: "關於 \(SpoofMacMetadata.appName)",
            zhHans: "关于 \(SpoofMacMetadata.appName)",
            en: "About \(SpoofMacMetadata.appName)",
            ja: "\(SpoofMacMetadata.appName) について"
        )

        WindowGroup(windowTitle) {
            MainView(viewModel: viewModel)
                .frame(minWidth: 900, minHeight: 620)
        }
        .defaultSize(width: 1020, height: 700)
        .commands {
            CommandGroup(replacing: .appInfo) {
                Button(aboutLabel) {
                    let credits = NSAttributedString(
                        string: "\(SpoofMacMetadata.attribution)\n\(SpoofMacMetadata.licenseName) (Non-Commercial Only)",
                        attributes: [
                            .font: NSFont.systemFont(ofSize: 11),
                            .foregroundColor: NSColor.secondaryLabelColor,
                        ]
                    )
                    let appVersion = (Bundle.main.infoDictionary?["CFBundleShortVersionString"] as? String) ?? SpoofMacMetadata.version
                    var options: [NSApplication.AboutPanelOptionKey: Any] = [
                        .applicationName: SpoofMacMetadata.appName,
                        .applicationVersion: appVersion,
                        .credits: credits,
                    ]
                    if let icon = AppDelegate.loadAppIconImage() {
                        options[.applicationIcon] = icon
                    }
                    NSApplication.shared.orderFrontStandardAboutPanel(options: options)
                }
            }
        }
    }
}
