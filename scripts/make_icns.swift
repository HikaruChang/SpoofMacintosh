#!/usr/bin/env swift
// Powered by NyphexAI, Developed by Hikaru(i@rua.moe)
// Licensed under the PolyForm Noncommercial License 1.0.0
// Renders a native macOS-style vector icon ("Mac + Shadow" silhouette) using SwiftUI
// and exports Assets/icon.png + Assets/AppIcon.icns.

import AppKit
import SwiftUI

struct MacSilhouetteShape: View {
    let bodyFill: AnyShapeStyle
    let screenFill: AnyShapeStyle
    let standFill: AnyShapeStyle
    let strokeColor: Color
    let strokeWidth: CGFloat
    let showReflection: Bool

    var body: some View {
        VStack(spacing: 0) {
            // Display bezel
            ZStack {
                RoundedRectangle(cornerRadius: 34, style: .continuous)
                    .fill(bodyFill)
                    .overlay(
                        RoundedRectangle(cornerRadius: 34, style: .continuous)
                            .stroke(strokeColor, lineWidth: strokeWidth)
                    )

                // Screen glass
                RoundedRectangle(cornerRadius: 20, style: .continuous)
                    .fill(screenFill)
                    .padding(18)
                    .overlay(
                        Group {
                            if showReflection {
                                GeometryReader { geo in
                                    Path { p in
                                        p.move(to: CGPoint(x: geo.size.width * 0.42, y: 0))
                                        p.addLine(to: CGPoint(x: geo.size.width, y: 0))
                                        p.addLine(to: CGPoint(x: geo.size.width, y: geo.size.height))
                                        p.addLine(to: CGPoint(x: geo.size.width * 0.14, y: geo.size.height))
                                        p.closeSubpath()
                                    }
                                    .fill(
                                        LinearGradient(
                                            colors: [Color.white.opacity(0.14), Color.white.opacity(0.02)],
                                            startPoint: .topTrailing,
                                            endPoint: .bottomLeading
                                        )
                                    )
                                }
                                .clipShape(RoundedRectangle(cornerRadius: 20, style: .continuous))
                                .padding(18)
                            }
                        }
                    )
            }
            .frame(width: 440, height: 300)

            // Stand neck
            Rectangle()
                .fill(standFill)
                .frame(width: 82, height: 42)
                .overlay(
                    Rectangle()
                        .fill(Color.black.opacity(0.12))
                        .frame(height: 10),
                    alignment: .top
                )

            // Stand foot
            RoundedRectangle(cornerRadius: 8, style: .continuous)
                .fill(standFill)
                .frame(width: 196, height: 18)
                .overlay(
                    RoundedRectangle(cornerRadius: 8, style: .continuous)
                        .stroke(strokeColor.opacity(0.6), lineWidth: strokeWidth * 0.7)
                )
        }
    }
}

struct MacIconCanvas: View {
    var body: some View {
        ZStack {
            // Standard Apple HIG 824x824 continuous squircle inside 1024x1024 canvas
            ZStack {
                // Background: native macOS system blue-to-indigo gradient
                RoundedRectangle(cornerRadius: 185, style: .continuous)
                    .fill(
                        LinearGradient(
                            colors: [
                                Color(red: 0.22, green: 0.61, blue: 1.00),
                                Color(red: 0.08, green: 0.43, blue: 0.96),
                                Color(red: 0.05, green: 0.22, blue: 0.60),
                            ],
                            startPoint: .top,
                            endPoint: .bottom
                        )
                    )

                // Soft top ambient light glow
                RadialGradient(
                    colors: [Color.white.opacity(0.28), Color.clear],
                    center: UnitPoint(x: 0.5, y: 0.12),
                    startRadius: 20,
                    endRadius: 520
                )
                .clipShape(RoundedRectangle(cornerRadius: 185, style: .continuous))

                // Back layer: Offset "Shadow / Spoofed" Mac silhouette
                MacSilhouetteShape(
                    bodyFill: AnyShapeStyle(Color.black.opacity(0.32)),
                    screenFill: AnyShapeStyle(Color.black.opacity(0.22)),
                    standFill: AnyShapeStyle(Color.black.opacity(0.30)),
                    strokeColor: Color.white.opacity(0.22),
                    strokeWidth: 3.5,
                    showReflection: false
                )
                .offset(x: 56, y: -42)
                .shadow(color: Color.black.opacity(0.18), radius: 14, x: 0, y: 10)

                // Front layer: Clean flat-layered Mac icon
                MacSilhouetteShape(
                    bodyFill: AnyShapeStyle(
                        LinearGradient(
                            colors: [Color.white, Color(red: 0.90, green: 0.94, blue: 1.0)],
                            startPoint: .top,
                            endPoint: .bottom
                        )
                    ),
                    screenFill: AnyShapeStyle(
                        LinearGradient(
                            colors: [Color(red: 0.04, green: 0.10, blue: 0.23), Color(red: 0.10, green: 0.22, blue: 0.46)],
                            startPoint: .topLeading,
                            endPoint: .bottomTrailing
                        )
                    ),
                    standFill: AnyShapeStyle(
                        LinearGradient(
                            colors: [Color(red: 0.85, green: 0.90, blue: 0.98), Color.white],
                            startPoint: .top,
                            endPoint: .bottom
                        )
                    ),
                    strokeColor: Color.white.opacity(0.85),
                    strokeWidth: 2.5,
                    showReflection: true
                )
                .offset(x: -36, y: 34)
                .shadow(color: Color.black.opacity(0.34), radius: 22, x: 8, y: 14)

                // Subtle top glass inner rim on squircle
                RoundedRectangle(cornerRadius: 185, style: .continuous)
                    .strokeBorder(
                        LinearGradient(
                            colors: [Color.white.opacity(0.42), Color.white.opacity(0.08)],
                            startPoint: .top,
                            endPoint: .bottom
                        ),
                        lineWidth: 4
                    )
            }
            .frame(width: 824, height: 824)
            .shadow(color: Color.black.opacity(0.30), radius: 26, x: 0, y: 16)
        }
        .frame(width: 1024, height: 1024)
        .background(Color.clear)
    }
}

enum MakeIcnsRunner {
    @MainActor
    static func run() throws {
        _ = NSApplication.shared
        let fm = FileManager.default
        let scriptURL = URL(fileURLWithPath: CommandLine.arguments[0]).standardizedFileURL
        let rootURL = scriptURL.deletingLastPathComponent().deletingLastPathComponent()
        let assetsURL = rootURL.appendingPathComponent("Assets", isDirectory: true)
        let iconPngURL = assetsURL.appendingPathComponent("icon.png")
        let iconsetURL = assetsURL.appendingPathComponent("AppIcon.iconset", isDirectory: true)
        let icnsURL = assetsURL.appendingPathComponent("AppIcon.icns")

        try fm.createDirectory(at: assetsURL, withIntermediateDirectories: true)

        let renderer = ImageRenderer(content: MacIconCanvas())
        renderer.scale = 1.0
        guard let masterCG = renderer.cgImage else {
            fputs("Error: ImageRenderer failed to produce master CGImage\n", stderr)
            exit(1)
        }

        func savePNG(_ cgImage: CGImage, to url: URL) throws {
            let rep = NSBitmapImageRep(cgImage: cgImage)
            rep.size = NSSize(width: cgImage.width, height: cgImage.height)
            guard let pngData = rep.representation(using: .png, properties: [:]) else {
                throw NSError(domain: "make_icns", code: 1, userInfo: [NSLocalizedDescriptionKey: "PNG encoding failed"])
            }
            try pngData.write(to: url, options: .atomic)
        }

        try savePNG(masterCG, to: iconPngURL)
        print("Generated \(iconPngURL.path)")

        if fm.fileExists(atPath: iconsetURL.path) {
            try fm.removeItem(at: iconsetURL)
        }
        try fm.createDirectory(at: iconsetURL, withIntermediateDirectories: true)

        let specs: [(String, Int)] = [
            ("icon_16x16.png", 16),
            ("icon_16x16@2x.png", 32),
            ("icon_32x32.png", 32),
            ("icon_32x32@2x.png", 64),
            ("icon_128x128.png", 128),
            ("icon_128x128@2x.png", 256),
            ("icon_256x256.png", 256),
            ("icon_256x256@2x.png", 512),
            ("icon_512x512.png", 512),
            ("icon_512x512@2x.png", 1024),
        ]

        let colorSpace = CGColorSpace(name: CGColorSpace.sRGB) ?? CGColorSpaceCreateDeviceRGB()
        for (filename, px) in specs {
            guard let ctx = CGContext(
                data: nil,
                width: px,
                height: px,
                bitsPerComponent: 8,
                bytesPerRow: 0,
                space: colorSpace,
                bitmapInfo: CGImageAlphaInfo.premultipliedLast.rawValue
            ) else {
                fputs("Error: Failed to allocate CGContext for \(filename)\n", stderr)
                exit(1)
            }
            ctx.interpolationQuality = .high
            ctx.draw(masterCG, in: CGRect(x: 0, y: 0, width: px, height: px))
            guard let resized = ctx.makeImage() else {
                fputs("Error: Failed to create resized image for \(filename)\n", stderr)
                exit(1)
            }
            try savePNG(resized, to: iconsetURL.appendingPathComponent(filename))
        }

        let proc = Process()
        proc.executableURL = URL(fileURLWithPath: "/usr/bin/iconutil")
        proc.arguments = ["-c", "icns", iconsetURL.path, "-o", icnsURL.path]
        try proc.run()
        proc.waitUntilExit()

        if proc.terminationStatus != 0 {
            fputs("Error: iconutil failed with exit code \(proc.terminationStatus)\n", stderr)
            exit(proc.terminationStatus)
        }

        try? fm.removeItem(at: iconsetURL)
        print("Generated \(icnsURL.path)")
    }
}

try MainActor.assumeIsolated {
    try MakeIcnsRunner.run()
}
