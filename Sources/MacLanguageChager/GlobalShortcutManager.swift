import AppKit
import Carbon

class GlobalShortcutManager {
    static let shared = GlobalShortcutManager()

    private var eventHandler: EventHandlerRef?
    private var hotKeyRef: EventHotKeyRef?
    private var currentShortcut: KeyCombo?
    private var hotKeyID = EventHotKeyID(signature: FourCharCode(fromString: "MLCH"), id: 1)
    private var hotKeyIDCounter: UInt32 = 1
    private let shortcutDefaultsKey = "MacLanguageChagerShortcut"

    private init() {}

    func registerShortcut(_ combo: KeyCombo?) {
        unregisterShortcut()

        guard let combo else { return }

        currentShortcut = combo

        // 이벤트 핸들러 등록
        var eventSpec = EventTypeSpec(eventClass: OSType(kEventClassKeyboard), eventKind: OSType(kEventHotKeyPressed))

        var eventHandler: EventHandlerRef?
        let status = InstallEventHandler(GetApplicationEventTarget(), { _, theEvent, _ -> OSStatus in
            var hotKeyID = EventHotKeyID()
            let err = GetEventParameter(
                theEvent,
                EventParamName(kEventParamDirectObject),
                EventParamType(typeEventHotKeyID),
                nil,
                MemoryLayout<EventHotKeyID>.size,
                nil,
                &hotKeyID
            )

            if err == noErr {
                InputSourceManager.shared.switchToNextInputSource()
            }

            return noErr
        }, 1, &eventSpec, nil, &eventHandler)

        guard status == noErr, let handler = eventHandler else {
            print("⚠️ 이벤트 핸들러 등록 실패: \(status)")
            return
        }

        self.eventHandler = handler

        // Carbon 모디파이어 변환
        var carbonModifiers: UInt32 = 0
        if combo.modifiers.contains(.command) {
            carbonModifiers |= UInt32(cmdKey)
        }
        if combo.modifiers.contains(.shift) {
            carbonModifiers |= UInt32(shiftKey)
        }
        if combo.modifiers.contains(.option) {
            carbonModifiers |= UInt32(optionKey)
        }
        if combo.modifiers.contains(.control) {
            carbonModifiers |= UInt32(controlKey)
        }

        // 고유한 ID 생성 (충돌 방지)
        hotKeyID.id = hotKeyIDCounter
        hotKeyIDCounter += 1

        var hotKeyRef: EventHotKeyRef?
        let registerStatus = RegisterEventHotKey(
            UInt32(combo.keyCode),
            carbonModifiers,
            hotKeyID,
            GetApplicationEventTarget(),
            0,
            &hotKeyRef
        )

        if registerStatus == noErr {
            self.hotKeyRef = hotKeyRef
            print("✅ 단축키 등록 성공: \(combo.displayString)")
            saveShortcut(combo)
        } else {
            // 에러 코드별 메시지
            let errorMessage = getErrorMessage(for: registerStatus)
            print("❌ 단축키 등록 실패 (\(registerStatus)): \(errorMessage)")
            print("💡 해결 방법:")
            print("   1. 다른 키 조합을 시도해보세요")
            print("   2. 시스템 설정 > 개인정보 보호 및 보안 > 손쉬운 사용에서 앱 권한 확인")

            // 이벤트 핸들러도 정리
            RemoveEventHandler(handler)
            self.eventHandler = nil
        }
    }

    private func getErrorMessage(for errorCode: OSStatus) -> String {
        switch errorCode {
        case -9878: // eventHotKeyExistsErr
            "이 키 조합은 이미 사용 중입니다"
        case -9877: // eventHotKeyInvalidIDErr
            "잘못된 단축키 ID입니다"
        case -9876: // eventParameterNotFoundErr
            "파라미터를 찾을 수 없습니다"
        default:
            "알 수 없는 오류 (코드: \(errorCode))"
        }
    }

    func unregisterShortcut() {
        // HotKey 해제
        if let ref = hotKeyRef {
            UnregisterEventHotKey(ref)
            hotKeyRef = nil
        }

        // 이벤트 핸들러 제거
        if let handler = eventHandler {
            RemoveEventHandler(handler)
            eventHandler = nil
        }

        currentShortcut = nil
        clearSavedShortcut()
    }

    deinit {
        unregisterShortcut()
    }

    func loadSavedShortcut() -> KeyCombo? {
        guard let data = UserDefaults.standard.data(forKey: shortcutDefaultsKey) else {
            return nil
        }
        return try? JSONDecoder().decode(KeyCombo.self, from: data)
    }

    private func saveShortcut(_ combo: KeyCombo) {
        if let data = try? JSONEncoder().encode(combo) {
            UserDefaults.standard.set(data, forKey: shortcutDefaultsKey)
        }
    }

    private func clearSavedShortcut() {
        UserDefaults.standard.removeObject(forKey: shortcutDefaultsKey)
    }
}

extension FourCharCode {
    init(fromString string: String) {
        var result: FourCharCode = 0
        for (index, char) in string.utf8.prefix(4).enumerated() {
            result |= FourCharCode(char) << (8 * (3 - index))
        }
        self = result
    }
}
