import Combine
import AppKit
import SwiftUI

@main
struct ClipPocketApp: App {
    @NSApplicationDelegateAdaptor(AppDelegate.self) private var appDelegate
    @StateObject private var appState: AppState
    @StateObject private var settingsStore: SettingsStore

    init() {
        let settingsStore = SettingsStore()
        let appState = AppState(settingsStore: settingsStore)
        _settingsStore = StateObject(wrappedValue: settingsStore)
        _appState = StateObject(wrappedValue: appState)
        appDelegate.configure(appState: appState, settingsStore: settingsStore)
    }

    var body: some Scene {
        Window("Clip Pocket", id: "main") {
            MenuBarView(presentation: .window)
                .environmentObject(appState)
                .environmentObject(settingsStore)
                .preferredColorScheme(settingsStore.appearance.colorScheme)
                .background(WindowRouterInstaller())
        }
        .defaultSize(width: 392, height: 640)

        MenuBarExtra {
            MenuBarView()
                .environmentObject(appState)
                .environmentObject(settingsStore)
                .preferredColorScheme(settingsStore.appearance.colorScheme)
        } label: {
            Image("ClipPocketMenuBarIcon")
                .renderingMode(.template)
                .resizable()
                .scaledToFit()
                .frame(width: 16, height: 16)
                .foregroundStyle(.primary)
                .accessibilityLabel("Clip Pocket")
        }
        .menuBarExtraStyle(.window)

        Settings {
            SettingsView()
                .environmentObject(appState)
                .environmentObject(settingsStore)
                .preferredColorScheme(settingsStore.appearance.colorScheme)
        }
    }
}

@MainActor
final class AppDelegate: NSObject, NSApplicationDelegate {
    private weak var appState: AppState?
    private weak var settingsStore: SettingsStore?
    private var cancellables = Set<AnyCancellable>()

    func configure(appState: AppState, settingsStore: SettingsStore) {
        self.appState = appState
        self.settingsStore = settingsStore
    }

    func applicationDidFinishLaunching(_ notification: Notification) {
        NSApp.setActivationPolicy(.regular)
        configureHotKey()
    }

    func applicationShouldHandleReopen(_ sender: NSApplication, hasVisibleWindows flag: Bool) -> Bool {
        showMainWindow()
        return true
    }

    func applicationSupportsSecureRestorableState(_ app: NSApplication) -> Bool {
        false
    }

    private func showMainWindow() {
        WindowRouter.shared.showMainWindow()
    }

    private func toggleMainWindow() {
        WindowRouter.shared.toggleMainWindow()
    }

    private func configureHotKey() {
        guard let settingsStore else {
            return
        }

        HotKeyManager.shared.configure(shortcut: settingsStore.openPanelShortcut) { [weak self] in
            self?.toggleMainWindow()
        }

        settingsStore.$openPanelShortcut
            .dropFirst()
            .sink { shortcut in
                HotKeyManager.shared.update(shortcut: shortcut)
            }
            .store(in: &cancellables)
    }
}

@MainActor
final class WindowRouter {
    static let shared = WindowRouter()

    var openMainWindow: (() -> Void)?
    weak var mainWindow: NSWindow?

    private init() {}

    func showMainWindow() {
        if let mainWindow {
            mainWindow.makeKeyAndOrderFront(nil)
            NSApp.activate(ignoringOtherApps: true)
            return
        }

        openMainWindow?()
        NSApp.activate(ignoringOtherApps: true)
    }

    func toggleMainWindow() {
        if let mainWindow, mainWindow.isVisible, NSApp.isActive {
            mainWindow.orderOut(nil)
            return
        }

        showMainWindow()
    }
}

private struct WindowRouterInstaller: View {
    @Environment(\.openWindow) private var openWindow

    var body: some View {
        WindowAccessor { window in
            WindowRouter.shared.mainWindow = window
        }
            .frame(width: 0, height: 0)
            .onAppear {
                WindowRouter.shared.openMainWindow = {
                    openWindow(id: "main")
                    NSApp.activate(ignoringOtherApps: true)
                }
            }
    }
}

private struct WindowAccessor: NSViewRepresentable {
    var onResolve: (NSWindow) -> Void

    func makeNSView(context: Context) -> NSView {
        let view = NSView(frame: .zero)
        resolveWindow(for: view)
        return view
    }

    func updateNSView(_ nsView: NSView, context: Context) {
        resolveWindow(for: nsView)
    }

    private func resolveWindow(for view: NSView) {
        DispatchQueue.main.async {
            if let window = view.window {
                onResolve(window)
            }
        }
    }
}
