# Mac 언어 전환 커스터마이징 프로그램

Mac에서 언어(입력 소스) 전환을 커스터마이징할 수 있는 macOS 앱입니다.

## 기능

- ✅ 현재 사용 가능한 모든 입력 소스 목록 표시
- ✅ 클릭으로 입력 소스 전환
- ✅ 키보드 단축키 커스터마이징
- ✅ 전역 키보드 단축키로 입력 소스 전환
- ✅ 메뉴바에서 빠른 접근

## 요구사항

- macOS 13.0 (Ventura) 이상
- **Xcode Command Line Tools** (Xcode IDE는 필요 없음)
- Swift 5.9 이상

### Command Line Tools 설치 확인

```bash
swift --version
xcode-select -p
```

설치되어 있지 않다면:

```bash
xcode-select --install
```

## 빌드 및 실행

**Xcode IDE 없이도 빌드 가능합니다!** Xcode Command Line Tools만 있으면 됩니다.

### 방법 1: Swift Package Manager 직접 사용 (권장)

```bash
# 디버그 빌드
swift build

# 릴리즈 빌드
swift build -c release

# 실행
swift run
# 또는
swift run -c release
```

### 방법 2: 빌드 스크립트 사용

```bash
./build.sh
swift run -c release
```

### 방법 3: Xcode IDE 사용 (선택사항)

1. Xcode에서 프로젝트 열기:

```bash
open Package.swift
```

2. Product > Run (⌘R)로 실행

## 사용 방법

1. 앱을 실행하면 메뉴바에 키보드 아이콘이 표시됩니다.
2. 아이콘을 클릭하면 설정 창이 열립니다.
3. **입력 소스 전환**: 입력 소스 목록에서 원하는 언어를 클릭하여 즉시 전환할 수 있습니다.
4. **키보드 단축키 설정**:
   - "기록" 버튼을 클릭합니다.
   - 원하는 키 조합을 누릅니다 (예: ⌘ + Space).
   - 단축키가 자동으로 저장되고 활성화됩니다.
   - 설정한 단축키를 누르면 다음 입력 소스로 전환됩니다.

## 주의사항

- 전역 키보드 단축키를 사용하려면 시스템 접근성 권한이 필요할 수 있습니다.
- 일부 키 조합은 시스템 단축키와 충돌할 수 있습니다.
- 앱을 종료하면 설정한 단축키가 해제됩니다.

## 개발

이 프로젝트는 Swift Package Manager를 사용하여 빌드됩니다.

### 프로젝트 구조

```
Sources/mac-language-change/
├── main.swift                    # 앱 진입점 및 메뉴바 설정
├── LanguageChangerView.swift     # 메인 UI 뷰
├── InputSourceManager.swift      # 입력 소스 관리 로직
├── KeyComboRecorder.swift        # 키보드 단축키 기록 기능
└── GlobalShortcutManager.swift   # 전역 키보드 단축키 등록
```

### 주요 기술

- **SwiftUI**: 사용자 인터페이스
- **AppKit**: macOS 네이티브 기능
- **Carbon API**: 입력 소스 제어 및 전역 단축키 등록

## 문제 해결

### 빌드 오류가 발생하는 경우

1. Swift 버전 확인:

```bash
swift --version
```

2. Xcode Command Line Tools 설치 확인:

```bash
xcode-select --install
```

### 단축키가 작동하지 않는 경우

1. 시스템 설정 > 보안 및 개인정보 보호 > 접근성에서 앱에 권한이 있는지 확인
2. 다른 앱과 단축키 충돌 여부 확인
3. 앱을 재시작해보기

## 라이선스

MIT License
