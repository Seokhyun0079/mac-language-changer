import AppKit
import Carbon
import Foundation

class InputSourceManager: ObservableObject {
    static let shared = InputSourceManager()

    @Published var inputSources: [InputSource] = []

    private init() {
        refreshInputSources()
    }

    func refreshInputSources() {
        let inputSourceList = TISCreateInputSourceList(nil, false).takeRetainedValue()
        let currentSource = TISCopyCurrentKeyboardInputSource().takeRetainedValue()

        var sources: [InputSource] = []
        let count = CFArrayGetCount(inputSourceList)

        for index in 0 ..< count {
            let inputSource = Unmanaged<TISInputSource>.fromOpaque(
                CFArrayGetValueAtIndex(inputSourceList, index)
            ).takeUnretainedValue()

            guard let sourceIDPtr = TISGetInputSourceProperty(inputSource, kTISPropertyInputSourceID) else { continue }
            let sourceID = Unmanaged<CFString>.fromOpaque(sourceIDPtr).takeUnretainedValue() as String

            guard let localizedNamePtr = TISGetInputSourceProperty(inputSource, kTISPropertyLocalizedName)
            else { continue }
            let localizedName = Unmanaged<CFString>.fromOpaque(localizedNamePtr).takeUnretainedValue() as String

            let isSelected = CFEqual(inputSource, currentSource)

            sources.append(InputSource(
                id: sourceID,
                localizedName: localizedName,
                isSelected: isSelected
            ))
        }

        DispatchQueue.main.async {
            self.inputSources = sources
        }
    }

    func selectInputSource(_ source: InputSource) {
        let inputSourceList = TISCreateInputSourceList(nil, false).takeRetainedValue()
        let count = CFArrayGetCount(inputSourceList)

        for index in 0 ..< count {
            let inputSource = Unmanaged<TISInputSource>.fromOpaque(
                CFArrayGetValueAtIndex(inputSourceList, index)
            ).takeUnretainedValue()

            guard let sourceIDPtr = TISGetInputSourceProperty(inputSource, kTISPropertyInputSourceID) else { continue }
            let sourceID = Unmanaged<CFString>.fromOpaque(sourceIDPtr).takeUnretainedValue() as String

            if sourceID == source.id {
                let status = TISSelectInputSource(inputSource)
                if status == noErr {
                    refreshInputSources()
                }
                break
            }
        }
    }

    func switchToNextInputSource() {
        // 활성화된 키보드 레이아웃만 필터링 (IME 제외)
        let inputSourceList = TISCreateInputSourceList(nil, false).takeRetainedValue()
        let currentSource = TISCopyCurrentKeyboardInputSource().takeRetainedValue()
        let count = CFArrayGetCount(inputSourceList)

        guard count > 0 else {
            print("⚠️ 사용 가능한 입력 소스가 없습니다")
            return
        }

        // 활성화된 입력 소스 수집 (가상 키보드 제외)
        var enabledSources: [TISInputSource] = []

        // 제외할 가상 키보드/팔레트 입력 소스 ID 목록
        let excludedSourceIDs: Set<String> = [
            "com.apple.CharacterPaletteIM", // Emoji & Symbols
            "com.apple.PressAndHold", // Press and Hold
            "com.apple.inputmethod.Kotoeri.Japanese.KanaPalette", // Japanese Kana Palette
        ]

        for index in 0 ..< count {
            let inputSource = Unmanaged<TISInputSource>.fromOpaque(
                CFArrayGetValueAtIndex(inputSourceList, index)
            ).takeUnretainedValue()

            // 입력 소스 ID 가져오기
            guard let sourceIDPtr = TISGetInputSourceProperty(inputSource, kTISPropertyInputSourceID) else { continue }
            let sourceID = Unmanaged<CFString>.fromOpaque(sourceIDPtr).takeUnretainedValue() as String

            // 가상 키보드/팔레트 입력 소스 제외
            if excludedSourceIDs.contains(sourceID) {
                continue
            }

            // 입력 소스 ID에 "Palette" 또는 "CharacterPalette"가 포함된 경우 제외
            if sourceID.contains("Palette") || sourceID.contains("CharacterPalette") {
                continue
            }

            // 활성화된 입력 소스인지 확인
            guard let enabledPtr = TISGetInputSourceProperty(inputSource, kTISPropertyInputSourceIsEnabled)
            else { continue }
            let enabled = Unmanaged<CFBoolean>.fromOpaque(enabledPtr).takeUnretainedValue()
            guard CFBooleanGetValue(enabled) else { continue }

            // 입력 소스 타입 확인 (팔레트 타입 제외)
            if let typePtr = TISGetInputSourceProperty(inputSource, kTISPropertyInputSourceType) {
                let type = Unmanaged<CFString>.fromOpaque(typePtr).takeUnretainedValue() as String
                // "TISTypePaletteInputMethod" 타입은 제외
                if type == "TISTypePaletteInputMethod" {
                    continue
                }
            }

            // 실제 키보드 입력이 가능한 입력 소스만 포함
            enabledSources.append(inputSource)
        }

        guard !enabledSources.isEmpty else {
            print("⚠️ 사용 가능한 입력 소스가 없습니다")
            return
        }

        // 현재 입력 소스 정보 가져오기
        guard let currentSourceIDPtr = TISGetInputSourceProperty(currentSource, kTISPropertyInputSourceID) else {
            print("⚠️ 현재 입력 소스 ID를 가져올 수 없습니다")
            return
        }
        let currentSourceID = Unmanaged<CFString>.fromOpaque(currentSourceIDPtr).takeUnretainedValue() as String

        // 현재 입력 소스 이름 가져오기 (디버깅용)
        if let currentSourceNamePtr = TISGetInputSourceProperty(currentSource, kTISPropertyLocalizedName) {
            let currentSourceName = Unmanaged<CFString>.fromOpaque(currentSourceNamePtr).takeUnretainedValue() as String
            print("현재 선택된 입력 소스: \(currentSourceName)")
        }

        // 현재 입력 소스의 인덱스 찾기 (ID로 비교)
        var currentIndex = -1
        for (index, source) in enabledSources.enumerated() {
            guard let sourceIDPtr = TISGetInputSourceProperty(source, kTISPropertyInputSourceID) else { continue }
            let sourceID = Unmanaged<CFString>.fromOpaque(sourceIDPtr).takeUnretainedValue() as String
            if sourceID == currentSourceID {
                currentIndex = index
                break
            }
        }

        // 현재 입력 소스가 필터링된 리스트에 없으면 첫 번째로 시작
        if currentIndex == -1 {
            print("⚠️ 현재 입력 소스가 필터링된 리스트에 없습니다. 첫 번째 입력 소스로 시작합니다.")
            currentIndex = 0
        }

        let nextIndex = (currentIndex + 1) % enabledSources.count
        let nextInputSource = enabledSources[nextIndex]

        // 입력 소스 전환 시도
        let status = TISSelectInputSource(nextInputSource)
        if status == noErr {
            // UI 업데이트를 위해 비동기로 새로고침
            DispatchQueue.main.async {
                self.refreshInputSources()
            }
        } else {
            // 실패했으면 다음 입력 소스로 시도 (최대 시도 횟수 제한)
            var attempts = 0
            var checkedIndices: Set<Int> = [nextIndex]
            while attempts < enabledSources.count - 1 {
                let tryIndex = (nextIndex + attempts + 1) % enabledSources.count
                if checkedIndices.contains(tryIndex) {
                    attempts += 1
                    continue
                }
                checkedIndices.insert(tryIndex)
                let tryInputSource = enabledSources[tryIndex]
                let tryStatus = TISSelectInputSource(tryInputSource)

                if tryStatus == noErr {
                    DispatchQueue.main.async {
                        self.refreshInputSources()
                    }
                    if let currentSourceNamePtr = TISGetInputSourceProperty(tryInputSource, kTISPropertyLocalizedName) {
                        let currentSourceName = Unmanaged<CFString>.fromOpaque(currentSourceNamePtr)
                            .takeUnretainedValue() as String
                        print("최종 선택된 입력 소스: \(currentSourceName)")
                    }
                    return
                }

                attempts += 1
            }
            // 모든 시도 실패 시 첫 번째 입력 소스로
            if !enabledSources.isEmpty {
                let firstInputSource = enabledSources[0]
                let firstStatus = TISSelectInputSource(firstInputSource)
                if firstStatus == noErr {
                    DispatchQueue.main.async {
                        self.refreshInputSources()
                    }
                }
            }
        }
    }
}

struct InputSource: Identifiable {
    let id: String
    let localizedName: String
    var isSelected: Bool
}
