import AppKit
import SwiftUI

@MainActor
final class DockPanelPresenter: NSObject, NSWindowDelegate {
    static let shared = DockPanelPresenter()

    private var window: NSWindow?

    func show(appState: AppState, settingsStore: SettingsStore) {
        if let window {
            window.makeKeyAndOrderFront(nil)
            NSRunningApplication.current.activate(options: [.activateIgnoringOtherApps])
            return
        }

        let contentView = MenuBarView()
            .environmentObject(appState)
            .environmentObject(settingsStore)
            .preferredColorScheme(settingsStore.appearance.colorScheme)

        let hostingController = NSHostingController(rootView: contentView)
        let window = NSWindow(contentViewController: hostingController)
        window.title = "Clip Pocket"
        window.styleMask = [.titled, .closable, .miniaturizable]
        window.level = .normal
        window.collectionBehavior = [.moveToActiveSpace, .fullScreenAuxiliary]
        window.isReleasedWhenClosed = false
        window.isRestorable = false
        window.isMovableByWindowBackground = true
        window.delegate = self
        window.setContentSize(NSSize(width: 392, height: 640))
        position(window)

        self.window = window
        window.makeKeyAndOrderFront(nil)
        window.orderFrontRegardless()
        NSRunningApplication.current.activate(options: [.activateIgnoringOtherApps])
    }

    func windowWillClose(_ notification: Notification) {
        window = nil
    }

    private func position(_ window: NSWindow) {
        guard let screen = NSScreen.main ?? NSScreen.screens.first else {
            window.center()
            return
        }

        let visibleFrame = screen.visibleFrame
        let frame = window.frame
        let x = visibleFrame.midX - frame.width / 2
        let y = visibleFrame.midY - frame.height / 2
        window.setFrameOrigin(NSPoint(x: x, y: y))
    }
}
