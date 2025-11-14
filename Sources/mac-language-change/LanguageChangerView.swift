import AppKit
import SwiftUI

struct LanguageChangerView: View {
    @StateObject private var inputSourceManager = InputSourceManager.shared
    @State private var selectedShortcut: KeyCombo?
    @State private var isRecording = false
    @State private var eventMonitor: Any?
    @State private var autoLaunchEnabled = false

    private let shortcutManager = GlobalShortcutManager.shared
    private let autoStartManager = AutoStartManager.shared

    var body: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: 20) {
                // 헤더
                Text("언어 전환 설정")
                    .font(.title2)
                    .fontWeight(.bold)
                    .padding(.bottom, 10)

                Divider()

                // 입력 소스 목록
                VStack(alignment: .leading, spacing: 10) {
                    Text("사용 가능한 입력 소스")
                        .font(.headline)

                    List {
                        ForEach(inputSourceManager.inputSources, id: \.id) { source in
                            HStack {
                                Text(source.localizedName)
                                Spacer()
                                if source.isSelected {
                                    Image(systemName: "checkmark.circle.fill")
                                        .foregroundColor(.blue)
                                }
                            }
                            .contentShape(Rectangle())
                            .onTapGesture {
                                inputSourceManager.selectInputSource(source)
                            }
                        }
                    }
                    .frame(height: 200)
                }

                Divider()

                // 키보드 단축키 설정
                VStack(alignment: .leading, spacing: 10) {
                    Text("키보드 단축키")
                        .font(.headline)

                    HStack {
                        Text("다음 입력 소스로 전환:")
                        Spacer()

                        if isRecording {
                            Button("녹음 중... (키를 누르세요)") {
                                stopRecording()
                            }
                            .buttonStyle(.bordered)
                            .controlSize(.small)
                        } else if let shortcut = selectedShortcut {
                            Button(shortcut.displayString) {
                                startRecording()
                            }
                            .buttonStyle(.bordered)
                            .controlSize(.small)
                        } else {
                            Button("기록") {
                                startRecording()
                            }
                            .buttonStyle(.bordered)
                            .controlSize(.small)
                        }
                    }

                    if let shortcut = selectedShortcut {
                        HStack {
                            Text("현재 단축키:")
                            Text(shortcut.displayString)
                                .foregroundColor(.secondary)
                            Spacer()
                            Button("제거") {
                                selectedShortcut = nil
                                shortcutManager.unregisterShortcut()
                            }
                        }
                    }
                }

                Spacer()

                Divider()

                Toggle("로그인 시 자동 실행", isOn: $autoLaunchEnabled)
                    .onChange(of: autoLaunchEnabled) { newValue in
                        autoStartManager.setEnabled(newValue)
                    }
                    .padding(.top, 8)

                // 하단 버튼
                HStack {
                    Spacer()
                    Button("닫기") {
                        NSApplication.shared.keyWindow?.close()
                    }
                    .keyboardShortcut(.defaultAction)
                }
            }
            .padding()
        }
        .frame(width: 400, height: 500)
        .onAppear {
            inputSourceManager.refreshInputSources()
            if selectedShortcut == nil, let savedShortcut = shortcutManager.loadSavedShortcut() {
                selectedShortcut = savedShortcut
            }
            autoLaunchEnabled = autoStartManager.isEnabled()
        }
        .onChange(of: selectedShortcut) { newValue in
            if newValue != nil {
                shortcutManager.registerShortcut(newValue)
            }
        }
    }

    private func startRecording() {
        // 기존 모니터 제거
        stopRecording()

        isRecording = true

        // 전역 이벤트 모니터 등록
        eventMonitor = NSEvent.addLocalMonitorForEvents(matching: [.keyDown, .flagsChanged]) { event in
            if event.type == .flagsChanged {
                // 모디파이어 키만 기록 (무시)
                return nil
            } else if event.type == .keyDown {
                let modifiers = event.modifierFlags.intersection([.command, .shift, .option, .control])
                let combo = KeyCombo(modifiers: modifiers, keyCode: event.keyCode)

                DispatchQueue.main.async {
                    selectedShortcut = combo
                    isRecording = false
                    shortcutManager.registerShortcut(combo)

                    // 이벤트 모니터 제거
                    if let monitor = eventMonitor {
                        NSEvent.removeMonitor(monitor)
                        eventMonitor = nil
                    }
                }

                return nil
            }
            return event
        }
    }

    private func stopRecording() {
        isRecording = false
        if let monitor = eventMonitor {
            NSEvent.removeMonitor(monitor)
            eventMonitor = nil
        }
    }
}
