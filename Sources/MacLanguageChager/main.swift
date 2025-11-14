import AppKit
import SwiftUI

struct MacLanguageChagerApp: App {
    @NSApplicationDelegateAdaptor(AppDelegate.self) var appDelegate

    var body: some Scene {
        Settings {
            EmptyView()
        }
    }
}

class AppDelegate: NSObject, NSApplicationDelegate {
    var statusBarItem: NSStatusItem?
    var popover: NSPopover?
    private var statusMenu: NSMenu?

    func applicationDidFinishLaunching(_: Notification) {
        // 메뉴바 아이콘 생성
        statusBarItem = NSStatusBar.system.statusItem(withLength: NSStatusItem.variableLength)

        if let button = statusBarItem?.button {
            // 텍스트 레이블로 표시 (더 명확함)
            button.title = "🌐"
            button.toolTip = "MacLanguageChager"
            button.action = #selector(togglePopover)
            button.target = self
            button.sendAction(on: [.leftMouseUp, .rightMouseUp])

            // 또는 아이콘 사용 시
            // if let image = NSImage(systemSymbolName: "globe", accessibilityDescription: "Language Changer") {
            //     image.isTemplate = true
            //     button.image = image
            // }
        }

        // 우클릭 메뉴 생성
        setupMenu()

        // Popover 생성
        popover = NSPopover()
        popover?.contentSize = NSSize(width: 400, height: 500)
        popover?.behavior = .transient
        popover?.contentViewController = NSHostingController(rootView: MacLanguageChagerView())

        // 앱이 백그라운드에서도 실행되도록 설정
        NSApp.setActivationPolicy(.accessory)

        // 저장된 단축키 자동 등록
        if let savedShortcut = GlobalShortcutManager.shared.loadSavedShortcut() {
            GlobalShortcutManager.shared.registerShortcut(savedShortcut)
        }
    }

    func setupMenu() {
        let menu = NSMenu()
        statusMenu = menu

        menu.addItem(NSMenuItem(title: "Language Switch Settings", action: #selector(showPopoverFromMenu), keyEquivalent: ""))
        menu.items.last?.target = self

        menu.addItem(NSMenuItem.separator())

        menu.addItem(NSMenuItem(title: "Quit MacLanguageChager", action: #selector(quitApp), keyEquivalent: "q"))
        menu.items.last?.target = self
        menu.items.last?.keyEquivalentModifierMask = .command

        statusBarItem?.menu = menu
    }

    @objc func showPopoverFromMenu() {
        if let button = statusBarItem?.button {
            if let popover {
                if popover.isShown {
                    popover.performClose(nil)
                } else {
                    popover.show(relativeTo: button.bounds, of: button, preferredEdge: .minY)
                }
            }
        }
    }

    @objc func togglePopover() {
        let event = NSApp.currentEvent

        // 우클릭이나 Control+클릭이면 메뉴 표시
        if let event {
            let isRightClick = event.type == .rightMouseUp
            let isControlClick = event.type == .leftMouseUp && event.modifierFlags.contains(.control)
            if isRightClick || isControlClick {
                if let menu = statusMenu, let button = statusBarItem?.button {
                    menu.popUp(positioning: nil, at: NSPoint(x: 0, y: button.bounds.height), in: button)
                    button.highlight(false)
                }
                return
            }
        }

        if let button = statusBarItem?.button {
            if let popover {
                if popover.isShown {
                    popover.performClose(nil)
                } else {
                    popover.show(relativeTo: button.bounds, of: button, preferredEdge: .minY)
                }
            }
        }
    }

    @objc func quitApp() {
        // 전역 단축키 해제
        GlobalShortcutManager.shared.unregisterShortcut()

        // 앱 종료
        NSApplication.shared.terminate(nil)
    }
}

// 앱 진입점 (executable 타겟에서는 top-level code가 자동으로 main 함수가 됨)
let app = NSApplication.shared
let delegate = AppDelegate()
app.delegate = delegate

// SwiftUI App도 초기화
_ = MacLanguageChagerApp()

app.run()
