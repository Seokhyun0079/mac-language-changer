import Foundation

class AutoStartManager {
    static let shared = AutoStartManager()

    private let label = "com.maclanguageschager.app"

    private var launchAgentURL: URL {
        let home = FileManager.default.homeDirectoryForCurrentUser
        return home.appendingPathComponent("Library/LaunchAgents/\(label).plist")
    }

    private init() {}

    func isEnabled() -> Bool {
        FileManager.default.fileExists(atPath: launchAgentURL.path)
    }

    func setEnabled(_ enabled: Bool) {
        enabled ? enableAutoLaunch() : disableAutoLaunch()
    }

    private func enableAutoLaunch() {
        do {
            try createLaunchAgent()
            print("✅ 로그인 시 자동 실행이 활성화되었습니다.")
        } catch {
            print("❌ 자동 실행 설정 실패: \(error.localizedDescription)")
        }
    }

    private func disableAutoLaunch() {
        do {
            if FileManager.default.fileExists(atPath: launchAgentURL.path) {
                try FileManager.default.removeItem(at: launchAgentURL)
            }
            print("ℹ️ 로그인 시 자동 실행이 비활성화되었습니다.")
        } catch {
            print("❌ 자동 실행 해제 실패: \(error.localizedDescription)")
        }
    }

    private func createLaunchAgent() throws {
        let directoryURL = launchAgentURL.deletingLastPathComponent()
        try FileManager.default.createDirectory(at: directoryURL, withIntermediateDirectories: true)

        let executablePath = currentExecutablePath()

        let plist: [String: Any] = [
            "Label": label,
            "ProgramArguments": [executablePath],
            "RunAtLoad": true,
            "KeepAlive": false,
        ]

        let data = try PropertyListSerialization.data(fromPropertyList: plist, format: .xml, options: 0)
        try data.write(to: launchAgentURL, options: .atomic)
    }

    private func currentExecutablePath() -> String {
        if let bundlePath = Bundle.main.executableURL?.path {
            return bundlePath
        }
        return CommandLine.arguments[0]
    }
}
