# Mac Language Switch Customizer

MacLanguageChager lets you fully customize how you switch input sources on macOS.

## Features

- ✅ Display all available input sources
- ✅ Switch sources instantly by clicking the list
- ✅ Record a custom keyboard shortcut
- ✅ Register a global shortcut (Carbon hotkey)
- ✅ Menubar access with left-click popover and right-click menu
- ✅ Optional auto-launch at login via LaunchAgent
- ✅ Remembers shortcuts across launches

## Requirements

- macOS 13 (Ventura) or later
- Xcode Command Line Tools
- Swift 5.9+

Check/install the tools:

```bash
swift --version
xcode-select -p
xcode-select --install    # if missing
```

## Build & Run

### Swift Package Manager (recommended)

```bash
swift build          # debug
swift build -c release
swift run            # debug run
swift run -c release # release run
```

### Build script

```bash
./build.sh
swift run -c release
```

### Xcode (optional)

```bash
open Package.swift
```

Then Product > Run (⌘R).

## Usage

1. Launch the app to show the 🌐 status bar button.
2. Left-click to open the SwiftUI settings popover.
3. Click any input source in the list to switch immediately.
4. Press “Record”, hit your desired key combo (e.g. ⌘+Space), and it will be saved + registered globally.
5. Toggle “Launch at login” to create/remove a LaunchAgent at `~/Library/LaunchAgents`.
6. **Right-click or Control-click the status bar icon** to open the menu and choose “Quit MacLanguageChager”.

## Notes

- Global shortcuts may require Accessibility permission.
- Some key combos can conflict with system shortcuts.
- Quitting the app unregisters the hotkey (it is restored on next launch if saved).

## Development

```
Sources/MacLanguageChager/
├── main.swift
├── MacLanguageChagerView.swift
├── InputSourceManager.swift
├── KeyComboRecorder.swift
├── GlobalShortcutManager.swift
└── AutoStartManager.swift
```

Key tech: SwiftUI, AppKit, Carbon (TIS + hotkeys).

## Distribution

```bash
./create_app.sh  # builds MacLanguageChager.app
./create_dmg.sh  # creates MacLanguageChager.dmg
./create_pkg.sh  # creates MacLanguageChager.pkg
```

Copy the .app to `/Applications`, share the DMG, or ship the PKG installer.

## License

MIT License

---

# Mac 言語切替カスタマイズアプリ

MacLanguageChager は macOS の入力ソース切替を自由にカスタマイズできるアプリです。

## 機能

- ✅ すべての利用可能な入力ソースを一覧表示
- ✅ リストをクリックするだけで即座に切替
- ✅ カスタムキーボードショートカットの記録
- ✅ Carbon API を使ったグローバルショートカット
- ✅ メニューバーからの迅速なアクセス（左クリック: ポップオーバー, 右/Control クリック: メニュー）
- ✅ LaunchAgent によるログイン時自動起動
- ✅ 設定したショートカットは再起動後も保持

## 必要環境

- macOS 13 (Ventura) 以降
- Xcode Command Line Tools
- Swift 5.9 以上

確認/インストール:

```bash
swift --version
xcode-select -p
xcode-select --install
```

## ビルド & 実行

### Swift Package Manager

```bash
swift build
swift build -c release
swift run
swift run -c release
```

### ビルドスクリプト

```bash
./build.sh
swift run -c release
```

### Xcode

```bash
open Package.swift
```

その後 Product > Run (⌘R)。

## 使い方

1. アプリ起動でメニューバーに 🌐 アイコンが表示されます。
2. 左クリックで SwiftUI ポップオーバーを開きます。
3. 入力ソースをクリックすると即座に切替わります。
4. 「記録」ボタンを押し、希望のキーコンボを入力するとグローバルショートカットとして登録・保存されます。
5. 「ログイン時に自動起動」をオンにすると `~/Library/LaunchAgents` に LaunchAgent が作成されます。
6. **右クリックまたは Control+クリック** でメニューを開き、「MacLanguageChager を終了」を選択できます。

## 注意事項

- グローバルショートカットにはアクセシビリティ許可が必要な場合があります。
- 一部のキーコンボはシステムショートカットと競合します。
- アプリ終了時にショートカット登録は解除されます（再起動時に保存内容から復元）。

## 開発

```
Sources/MacLanguageChager/
├── main.swift
├── MacLanguageChagerView.swift
├── InputSourceManager.swift
├── KeyComboRecorder.swift
├── GlobalShortcutManager.swift
└── AutoStartManager.swift
```

主要技術: SwiftUI / AppKit / Carbon (TIS API, グローバルホットキー)。

## 配布

```bash
./create_app.sh
./create_dmg.sh
./create_pkg.sh
```

.app を `/Applications` にコピーするか、DMG/PKG を配布してください。

## ライセンス

MIT License

---

# Mac 언어 전환 커스터마이징 프로그램

MacLanguageChager는 macOS에서 입력 소스 전환을 마음대로 커스터마이징할 수 있는 앱입니다.

## 기능

- ✅ 현재 사용 가능한 모든 입력 소스 목록 표시
- ✅ 클릭으로 입력 소스 전환
- ✅ 키보드 단축키 커스터마이징
- ✅ 전역 키보드 단축키로 입력 소스 전환 (Carbon)
- ✅ 메뉴바에서 빠른 접근 (좌클릭: 설정, 우클릭/Control+클릭: 메뉴)
- ✅ 로그인 시 자동 실행 옵션
- ✅ 앱 재시작 후에도 단축키 기억

## 요구사항

- macOS 13.0 (Ventura) 이상
- Xcode Command Line Tools
- Swift 5.9 이상

```bash
swift --version
xcode-select -p
xcode-select --install
```

## 빌드 및 실행

### Swift Package Manager (권장)

```bash
swift build
swift build -c release
swift run
swift run -c release
```

### 빌드 스크립트

```bash
./build.sh
swift run -c release
```

### Xcode IDE (선택)

```bash
open Package.swift
```

이후 Product > Run (⌘R).

## 사용 방법

1. 앱을 실행하면 메뉴바에 🌐 아이콘이 표시됩니다.
2. 좌클릭하면 SwiftUI 팝오버 설정 화면이 열립니다.
3. 입력 소스 목록에서 원하는 항목을 클릭하면 즉시 전환됩니다.
4. “기록” 버튼을 누른 뒤 원하는 키 조합(예: ⌘+Space)을 입력하면 전역 단축키로 등록되고 저장됩니다.
5. “로그인 시 자동 실행” 토글을 켜면 `~/Library/LaunchAgents`에 LaunchAgent가 생성되어 재부팅 후 자동으로 실행됩니다.
6. **우클릭 또는 Control+클릭**으로 메뉴를 열어 “종료 MacLanguageChager”를 선택할 수 있습니다.

## 주의사항

- 전역 단축키 사용 시 접근성 권한이 필요할 수 있습니다.
- 일부 키 조합은 시스템 단축키와 충돌할 수 있습니다.
- 앱 종료 시 단축키 등록이 해제되지만, 저장된 설정은 다음 실행 시 자동 복원됩니다.

## 개발

```
Sources/MacLanguageChager/
├── main.swift
├── MacLanguageChagerView.swift
├── InputSourceManager.swift
├── KeyComboRecorder.swift
├── GlobalShortcutManager.swift
└── AutoStartManager.swift
```

SwiftUI · AppKit · Carbon API로 구성되어 있습니다.

## 배포

```bash
./create_app.sh   # MacLanguageChager.app
./create_dmg.sh   # MacLanguageChager.dmg
./create_pkg.sh   # MacLanguageChager.pkg
```

.app은 /Applications로 복사하고, DMG/PKG는 배포용으로 사용하세요.

## 라이선스

MIT License
