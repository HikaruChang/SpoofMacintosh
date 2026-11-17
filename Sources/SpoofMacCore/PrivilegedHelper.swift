// Powered by NyphexAI, Developed by Hikaru(i@rua.moe)
// Licensed under the PolyForm Noncommercial License 1.0.0

import Foundation

public enum PrivilegedHelperError: LocalizedError {
    case binaryNotFound(String)
    case executionFailed(code: Int, message: String)
    case userCancelled

    public var errorDescription: String? {
        localizedMessage(in: AppLanguage.current)
    }

    public func localizedMessage(in lang: EffectiveLanguage) -> String {
        switch self {
        case .binaryNotFound(let name):
            return L(
                lang,
                zhHant: "找不到必要的執行檔案：\(name)。請確認建置或安裝完整。",
                zhHans: "找不到必要的可执行文件：\(name)。请确认构建或安装完整。",
                en: "Required executable '\(name)' was not found. Please ensure the build or installation is complete.",
                ja: "必要な実行ファイル「\(name)」が見つかりません。ビルドまたはインストールを確認してください。"
            )
        case .executionFailed(_, let message):
            if !message.isEmpty { return message }
            return L(
                lang,
                zhHant: "管理員權限操作失敗。",
                zhHans: "管理员权限操作失败。",
                en: "Privileged administrator operation failed.",
                ja: "管理者権限での操作に失敗しました。"
            )
        case .userCancelled:
            return L(
                lang,
                zhHant: "已取消管理員授權。",
                zhHans: "已取消管理员授权。",
                en: "Administrator authorization was cancelled.",
                ja: "管理者認証がキャンセルされました。"
            )
        }
    }
}

public enum PrivilegedHelper {
    public static func shellQuote(_ arg: String) -> String {
        "'" + arg.replacingOccurrences(of: "'", with: "'\\''") + "'"
    }

    public static func locateCLIExecutable() -> String? {
        var candidates: [String] = []
        if let resourceURL = Bundle.main.resourceURL {
            candidates.append(resourceURL.appendingPathComponent("spoofmac").path)
        }
        if let execDir = Bundle.main.executableURL?.deletingLastPathComponent() {
            candidates.append(execDir.appendingPathComponent("spoofmac").path)
        }
        candidates.append("/usr/local/bin/spoofmac")

        let fm = FileManager.default
        return candidates.first { fm.isExecutableFile(atPath: $0) }
    }

    public static func locateInstallScript() -> (scriptPath: String, workingDirectory: String)? {
        var candidates: [URL] = []
        if let resourceURL = Bundle.main.resourceURL {
            candidates.append(resourceURL.appendingPathComponent("install.sh"))
        }
        if let execDir = Bundle.main.executableURL?.deletingLastPathComponent() {
            candidates.append(execDir.appendingPathComponent("install.sh"))
            candidates.append(execDir.deletingLastPathComponent().appendingPathComponent("install.sh"))
            candidates.append(execDir.deletingLastPathComponent().deletingLastPathComponent().appendingPathComponent("install.sh"))
        }
        candidates.append(URL(fileURLWithPath: FileManager.default.currentDirectoryPath).appendingPathComponent("install.sh"))

        let fm = FileManager.default
        for url in candidates where fm.isExecutableFile(atPath: url.path) {
            return (url.path, url.deletingLastPathComponent().path)
        }
        return nil
    }

    public static func runPrivilegedShell(_ command: String) async throws -> String {
        try await withCheckedThrowingContinuation { continuation in
            DispatchQueue.global(qos: .userInitiated).async {
                if geteuid() == 0 {
                    let res = SystemDiagnostics.runCommand("/bin/bash", arguments: ["-c", command], timeoutSeconds: 120)
                    if res.exitCode == 0 {
                        continuation.resume(returning: res.stdout)
                    } else {
                        let msg = res.stderr.isEmpty ? res.stdout : res.stderr
                        continuation.resume(throwing: PrivilegedHelperError.executionFailed(code: Int(res.exitCode), message: msg))
                    }
                    return
                }

                let escapedForAppleScript = command
                    .replacingOccurrences(of: "\\", with: "\\\\")
                    .replacingOccurrences(of: "\"", with: "\\\"")
                let appleScriptSource = "do shell script \"\(escapedForAppleScript)\" with administrator privileges"

                var errorInfo: NSDictionary?
                guard let script = NSAppleScript(source: appleScriptSource) else {
                    continuation.resume(throwing: PrivilegedHelperError.executionFailed(code: -1, message: "無法建立 AppleScript 授權環境。"))
                    return
                }
                let result = script.executeAndReturnError(&errorInfo)
                if let errorInfo {
                    let code = (errorInfo[NSAppleScript.errorNumber] as? Int) ?? -1
                    if code == -128 {
                        continuation.resume(throwing: PrivilegedHelperError.userCancelled)
                    } else {
                        let message = (errorInfo[NSAppleScript.errorMessage] as? String) ?? "管理員命令執行失敗"
                        continuation.resume(throwing: PrivilegedHelperError.executionFailed(code: code, message: message))
                    }
                    return
                }
                continuation.resume(returning: result.stringValue ?? "")
            }
        }
    }

    public static func applyProfilePrivileged(_ profile: SpoofProfile, language: EffectiveLanguage = AppLanguage.current) async throws -> String {
        guard let cli = locateCLIExecutable() else {
            throw PrivilegedHelperError.binaryNotFound("spoofmac")
        }
        try profile.validate()

        let tempPath = NSTemporaryDirectory() + "spoofmac_apply_\(UUID().uuidString).plist"
        try profile.save(to: tempPath)
        try FileManager.default.setAttributes([.posixPermissions: 0o600], ofItemAtPath: tempPath)

        let cmd = "\(shellQuote(cli)) --lang \(shellQuote(language.rawValue)) apply --profile-file \(shellQuote(tempPath)) --delete-profile-file"
        do {
            let output = try await runPrivilegedShell(cmd)
            try? FileManager.default.removeItem(atPath: tempPath)
            return output
        } catch {
            try? FileManager.default.removeItem(atPath: tempPath)
            throw error
        }
    }

    public static func resetToFactoryPrivileged(language: EffectiveLanguage = AppLanguage.current) async throws -> String {
        guard let cli = locateCLIExecutable() else {
            throw PrivilegedHelperError.binaryNotFound("spoofmac")
        }
        let cmd = "\(shellQuote(cli)) --lang \(shellQuote(language.rawValue)) reset"
        return try await runPrivilegedShell(cmd)
    }

    public static func refreshEligibilityPrivileged(language: EffectiveLanguage = AppLanguage.current) async throws -> String {
        guard let cli = locateCLIExecutable() else {
            throw PrivilegedHelperError.binaryNotFound("spoofmac")
        }
        let cmd = "\(shellQuote(cli)) --lang \(shellQuote(language.rawValue)) refresh"
        return try await runPrivilegedShell(cmd)
    }

    public static func runInstallActionPrivileged(_ action: String) async throws -> String {
        guard let located = locateInstallScript() else {
            throw PrivilegedHelperError.binaryNotFound("install.sh")
        }
        let cmd = "cd \(shellQuote(located.workingDirectory)) && /bin/bash \(shellQuote(located.scriptPath)) \(shellQuote(action))"
        return try await runPrivilegedShell(cmd)
    }
}
