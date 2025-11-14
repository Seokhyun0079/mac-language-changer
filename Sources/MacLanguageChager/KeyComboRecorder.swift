import AppKit
import Carbon
import SwiftUI

struct KeyComboRecorder: NSViewRepresentable {
    @Binding var combo: KeyCombo?
    @Binding var isRecording: Bool

    func makeNSView(context _: Context) -> KeyComboRecorderView {
        let view = KeyComboRecorderView()
        view.comboBinding = $combo
        view.isRecordingBinding = $isRecording
        return view
    }

    func updateNSView(_ nsView: KeyComboRecorderView, context _: Context) {
        nsView.comboBinding = $combo
        nsView.isRecordingBinding = $isRecording
        nsView.updateButton()
    }
}

class KeyComboRecorderView: NSView {
    var comboBinding: Binding<KeyCombo?>? {
        didSet {
            updateButton()
        }
    }

    var isRecordingBinding: Binding<Bool>? {
        didSet {
            updateButton()
        }
    }

    private var eventMonitor: Any?
    private var recordedModifiers: NSEvent.ModifierFlags = []
    private var recordedKeyCode: UInt16?
    private var button: NSButton?

    override func viewDidMoveToWindow() {
        super.viewDidMoveToWindow()
        setupButton()
    }

    func setupButton() {
        if button == nil {
            let newButton = NSButton(title: "기록", target: self, action: #selector(startRecording))
            newButton.frame = bounds
            newButton.autoresizingMask = [.width, .height]
            newButton.bezelStyle = .rounded
            addSubview(newButton)
            button = newButton
        }
        updateButton()
    }

    func updateButton() {
        button?.title = isRecordingBinding?.wrappedValue == true ? "녹음 중..." : "기록"
        if let combo = comboBinding?.wrappedValue {
            button?.title = combo.displayString
        }
    }

    @objc func startRecording() {
        guard let isRecordingBinding else { return }

        if isRecordingBinding.wrappedValue {
            stopRecording()
        } else {
            isRecordingBinding.wrappedValue = true
            recordedModifiers = []
            recordedKeyCode = nil

            eventMonitor = NSEvent.addLocalMonitorForEvents(matching: [.keyDown, .flagsChanged]) { [weak self] event in
                guard let self else { return nil }

                if event.type == .flagsChanged {
                    recordedModifiers = event.modifierFlags.intersection([.command, .shift, .option, .control])
                    return nil
                } else if event.type == .keyDown {
                    recordedKeyCode = event.keyCode

                    if let keyCode = recordedKeyCode {
                        let combo = KeyCombo(
                            modifiers: recordedModifiers,
                            keyCode: keyCode
                        )
                        DispatchQueue.main.async {
                            self.comboBinding?.wrappedValue = combo
                            self.updateButton()
                        }
                    }

                    stopRecording()
                    return nil
                }

                return event
            }
        }
    }

    func stopRecording() {
        DispatchQueue.main.async {
            self.isRecordingBinding?.wrappedValue = false
            self.updateButton()
        }
        if let monitor = eventMonitor {
            NSEvent.removeMonitor(monitor)
            eventMonitor = nil
        }
    }
}

struct KeyCombo: Equatable, Codable {
    let modifiers: NSEvent.ModifierFlags
    let keyCode: UInt16

    var displayString: String {
        var parts: [String] = []

        if modifiers.contains(.control) {
            parts.append("⌃")
        }
        if modifiers.contains(.option) {
            parts.append("⌥")
        }
        if modifiers.contains(.shift) {
            parts.append("⇧")
        }
        if modifiers.contains(.command) {
            parts.append("⌘")
        }

        if let keyName = keyCodeToName(keyCode) {
            parts.append(keyName)
        }

        return parts.joined(separator: " ")
    }

    private func keyCodeToName(_ code: UInt16) -> String? {
        // 간단한 키 코드 매핑
        let mapping: [UInt16: String] = [
            0: "A", 1: "S", 2: "D", 3: "F", 4: "H", 5: "G",
            6: "Z", 7: "X", 8: "C", 9: "V", 11: "B", 12: "Q",
            13: "W", 14: "E", 15: "R", 16: "Y", 17: "T",
            31: "O", 32: "U", 34: "I", 35: "P", 37: "L",
            38: "J", 40: "K", 45: "N", 46: "M",
            36: "Return", 48: "Tab", 49: "Space", 51: "Delete",
            123: "←", 124: "→", 125: "↓", 126: "↑",
        ]
        return mapping[code]
    }

    enum CodingKeys: String, CodingKey {
        case modifiersRawValue
        case keyCode
    }

    init(modifiers: NSEvent.ModifierFlags, keyCode: UInt16) {
        self.modifiers = modifiers
        self.keyCode = keyCode
    }

    init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        let rawValue = try container.decode(UInt.self, forKey: .modifiersRawValue)
        modifiers = NSEvent.ModifierFlags(rawValue: rawValue)
        keyCode = try container.decode(UInt16.self, forKey: .keyCode)
    }

    func encode(to encoder: Encoder) throws {
        var container = encoder.container(keyedBy: CodingKeys.self)
        try container.encode(modifiers.rawValue, forKey: .modifiersRawValue)
        try container.encode(keyCode, forKey: .keyCode)
    }
}
