import AppKit
import SwiftUI

struct LanguageChangerApp: App {
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
    
    func applicationDidFinishLaunching(_ notification: Notification) {
        // 메뉴바 아이콘 생성
        statusBarItem = NSStatusBar.system.statusItem(withLength: NSStatusItem.variableLength)
        
        if let button = statusBarItem?.button {
            // 텍스트 레이블로 표시 (더 명확함)
            button.title = "🌐"
            button.toolTip = "언어 전환 설정"
            button.action = #selector(togglePopover)
            button.target = self
            
            // 또는 아이콘 사용 시
            // if let image = NSImage(systemSymbolName: "globe", accessibilityDescription: "Language Changer") {
            //     image.isTemplate = true
            //     button.image = image
            // }
        }
        
        // Popover 생성
        popover = NSPopover()
        popover?.contentSize = NSSize(width: 400, height: 500)
        popover?.behavior = .transient
        popover?.contentViewController = NSHostingController(rootView: LanguageChangerView())
        
        // 앱이 백그라운드에서도 실행되도록 설정
        NSApp.setActivationPolicy(.accessory)
    }
    
    @objc func togglePopover() {
        if let button = statusBarItem?.button {
            if let popover = popover {
                if popover.isShown {
                    popover.performClose(nil)
                } else {
                    popover.show(relativeTo: button.bounds, of: button, preferredEdge: .minY)
                }
            }
        }
    }
}

// 앱 진입점 (executable 타겟에서는 top-level code가 자동으로 main 함수가 됨)
let app = NSApplication.shared
let delegate = AppDelegate()
app.delegate = delegate

// SwiftUI App도 초기화
let _ = LanguageChangerApp()

app.run()

