import Combine
import AppKit
import Foundation
import ServiceManagement
import SwiftUI

enum AppearancePreference: String, CaseIterable, Identifiable {
    case system
    case light
    case dark

    var id: String {
        rawValue
    }

    var displayName: String {
        switch self {
        case .system:
            "System"
        case .light:
            "Light"
        case .dark:
            "Dark"
        }
    }

    var colorScheme: ColorScheme? {
        switch self {
        case .system:
            nil
        case .light:
            .light
        case .dark:
            .dark
        }
    }

    var nsAppearance: NSAppearance? {
        switch self {
        case .system:
            nil
        case .light:
            NSAppearance(named: .aqua)
        case .dark:
            NSAppearance(named: .darkAqua)
        }
    }
}

@MainActor
final class SettingsStore: ObservableObject {
    @Published var launchAtLogin: Bool {
        didSet {
            defaults.set(launchAtLogin, forKey: Keys.launchAtLogin)
        }
    }

    @Published var showMenuBarIcon: Bool {
        didSet {
            defaults.set(showMenuBarIcon, forKey: Keys.showMenuBarIcon)
        }
    }

    @Published var isClipboardMonitoringPaused: Bool {
        didSet {
            defaults.set(isClipboardMonitoringPaused, forKey: Keys.isClipboardMonitoringPaused)
        }
    }

    @Published var maxHistorySize: Int {
        didSet {
            defaults.set(maxHistorySize, forKey: Keys.maxHistorySize)
        }
    }

    @Published var ignoreDuplicateClips: Bool {
        didSet {
            defaults.set(ignoreDuplicateClips, forKey: Keys.ignoreDuplicateClips)
        }
    }

    @Published var ignoreTransientClipboardContent: Bool {
        didSet {
            defaults.set(ignoreTransientClipboardContent, forKey: Keys.ignoreTransientClipboardContent)
        }
    }

    @Published var ignoreConcealedClipboardContent: Bool {
        didSet {
            defaults.set(ignoreConcealedClipboardContent, forKey: Keys.ignoreConcealedClipboardContent)
        }
    }

    @Published var appearance: AppearancePreference {
        didSet {
            defaults.set(appearance.rawValue, forKey: Keys.appearance)
            applyAppearance()
        }
    }

    @Published var openPanelShortcut: KeyboardShortcut {
        didSet {
            save(openPanelShortcut, forKey: Keys.openPanelShortcut)
        }
    }

    @Published private(set) var settingsErrorMessage: String?

    private let defaults: UserDefaults
    let historySizeOptions = [50, 100, 250, 500, 1_000]

    init(defaults: UserDefaults = .standard) {
        self.defaults = defaults
        self.launchAtLogin = SMAppService.mainApp.status == .enabled

        if defaults.object(forKey: Keys.showMenuBarIcon) == nil {
            self.showMenuBarIcon = true
        } else {
            self.showMenuBarIcon = defaults.bool(forKey: Keys.showMenuBarIcon)
        }

        self.isClipboardMonitoringPaused = defaults.bool(forKey: Keys.isClipboardMonitoringPaused)
        self.maxHistorySize = defaults.object(forKey: Keys.maxHistorySize) as? Int ?? 100

        if defaults.object(forKey: Keys.ignoreDuplicateClips) == nil {
            self.ignoreDuplicateClips = true
        } else {
            self.ignoreDuplicateClips = defaults.bool(forKey: Keys.ignoreDuplicateClips)
        }

        if defaults.object(forKey: Keys.ignoreTransientClipboardContent) == nil {
            self.ignoreTransientClipboardContent = true
        } else {
            self.ignoreTransientClipboardContent = defaults.bool(forKey: Keys.ignoreTransientClipboardContent)
        }

        if defaults.object(forKey: Keys.ignoreConcealedClipboardContent) == nil {
            self.ignoreConcealedClipboardContent = true
        } else {
            self.ignoreConcealedClipboardContent = defaults.bool(forKey: Keys.ignoreConcealedClipboardContent)
        }

        if let storedAppearance = defaults.string(forKey: Keys.appearance),
           let appearance = AppearancePreference(rawValue: storedAppearance) {
            self.appearance = appearance
        } else {
            self.appearance = .system
        }

        self.openPanelShortcut = Self.loadShortcut(
            from: defaults,
            key: Keys.openPanelShortcut,
            fallback: .defaultOpenPanel
        )

        Task { @MainActor in
            applyAppearance()
        }
    }

    func setLaunchAtLogin(_ enabled: Bool) {
        do {
            if enabled {
                try SMAppService.mainApp.register()
            } else {
                try SMAppService.mainApp.unregister()
            }

            launchAtLogin = enabled
            settingsErrorMessage = nil
        } catch {
            launchAtLogin = SMAppService.mainApp.status == .enabled
            settingsErrorMessage = error.localizedDescription
        }
    }

    private func applyAppearance() {
        NSApplication.shared.appearance = appearance.nsAppearance
    }

    private func save(_ shortcut: KeyboardShortcut, forKey key: String) {
        guard let data = try? JSONEncoder().encode(shortcut) else {
            return
        }

        defaults.set(data, forKey: key)
    }

    private static func loadShortcut(
        from defaults: UserDefaults,
        key: String,
        fallback: KeyboardShortcut
    ) -> KeyboardShortcut {
        guard let data = defaults.data(forKey: key),
              let shortcut = try? JSONDecoder().decode(KeyboardShortcut.self, from: data),
              shortcut.hasModifier else {
            return fallback
        }

        return shortcut
    }

    private enum Keys {
        static let launchAtLogin = "settings.launchAtLogin"
        static let showMenuBarIcon = "settings.showMenuBarIcon"
        static let isClipboardMonitoringPaused = "settings.isClipboardMonitoringPaused"
        static let maxHistorySize = "settings.maxHistorySize"
        static let ignoreDuplicateClips = "settings.ignoreDuplicateClips"
        static let ignoreTransientClipboardContent = "settings.ignoreTransientClipboardContent"
        static let ignoreConcealedClipboardContent = "settings.ignoreConcealedClipboardContent"
        static let appearance = "settings.appearance"
        static let openPanelShortcut = "settings.openPanelShortcut"
    }
}
