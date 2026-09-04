import Carbon.HIToolbox
import SwiftUI

struct SettingsView: View {
    @EnvironmentObject private var appState: AppState
    @EnvironmentObject private var settingsStore: SettingsStore
    @State private var isClearHistoryAlertPresented = false
    @State private var isRecordingShortcut = false
    @State private var keyDownMonitor: Any?

    var body: some View {
        VStack(alignment: .leading, spacing: 18) {
            HStack(spacing: 10) {
                Image(systemName: "gearshape")
                    .font(.system(size: 16, weight: .semibold))
                    .foregroundStyle(.secondary)
                    .frame(width: 30, height: 30)

                VStack(alignment: .leading, spacing: 2) {
                    Text("Clip Pocket Settings")
                        .font(.system(size: 17, weight: .semibold))

                    Text("Keep the app quiet and native.")
                        .font(.system(size: 12))
                        .foregroundStyle(.secondary)
                }
            }

            Form {
                Section {
                    Toggle("Launch at login", isOn: Binding(
                        get: { settingsStore.launchAtLogin },
                        set: { settingsStore.setLaunchAtLogin($0) }
                    ))
                } header: {
                    Text("General")
                } footer: {
                    if let settingsErrorMessage = settingsStore.settingsErrorMessage {
                        Text(settingsErrorMessage)
                    }
                }

                Section {
                    Toggle("Pause clipboard monitoring", isOn: $settingsStore.isClipboardMonitoringPaused)

                    Picker("Max history size", selection: $settingsStore.maxHistorySize) {
                        ForEach(settingsStore.historySizeOptions, id: \.self) { option in
                            Text("\(option) clips")
                                .tag(option)
                        }
                    }
                    .pickerStyle(.menu)
                } header: {
                    Text("Clipboard")
                } footer: {
                    if settingsStore.isClipboardMonitoringPaused {
                        Text("Clipboard monitoring is paused. New copied items will not be saved until you resume monitoring.")
                    }
                }

                Section {
                    Toggle("Ignore duplicate clips", isOn: $settingsStore.ignoreDuplicateClips)
                    Toggle("Ignore transient clipboard content", isOn: $settingsStore.ignoreTransientClipboardContent)
                    Toggle("Ignore concealed clipboard content", isOn: $settingsStore.ignoreConcealedClipboardContent)
                } header: {
                    Text("Privacy Filters")
                }

                Section {
                    Picker("Appearance", selection: $settingsStore.appearance) {
                        ForEach(AppearancePreference.allCases) { appearance in
                            Text(appearance.displayName)
                                .tag(appearance)
                        }
                    }
                    .pickerStyle(.segmented)
                } header: {
                    Text("Appearance")
                } footer: {
                    Text("Choose System to follow macOS, or force Clip Pocket to stay light or dark.")
                }

                Section {
                    LabeledContent("Open Clip Pocket") {
                        Text(settingsStore.openPanelShortcut.displayText)
                            .font(.system(.body, design: .monospaced))
                            .foregroundStyle(.secondary)
                    }

                    HStack {
                        Button {
                            toggleShortcutRecording()
                        } label: {
                            Label(
                                isRecordingShortcut ? "Press Shortcut..." : "Record Shortcut",
                                systemImage: isRecordingShortcut ? "keyboard.badge.ellipsis" : "keyboard"
                            )
                        }

                        Button("Reset") {
                            settingsStore.openPanelShortcut = .defaultOpenPanel
                            stopShortcutRecording()
                        }
                        .disabled(settingsStore.openPanelShortcut == .defaultOpenPanel)
                    }
                } header: {
                    Text("Keyboard Shortcut")
                } footer: {
                    Text("Use at least one modifier key. Default: Control Option Space.")
                }

                Section {
                    Text("Clip Pocket stores your clipboard history locally on your Mac.")
                    Text("No clips are uploaded.")
                    Text("No account is required.")
                } header: {
                    Text("Privacy")
                }

                Section {
                    Button("Clear History", role: .destructive) {
                        isClearHistoryAlertPresented = true
                    }
                } header: {
                    Text("Data")
                } footer: {
                    Text("This removes saved clips from Clip Pocket. It does not remove anything from other apps.")
                }

                Section {
                    LabeledContent("Version", value: versionText)
                    LabeledContent("Build", value: buildText)
                } header: {
                    Text("About")
                }
            }
            .formStyle(.grouped)
        }
        .padding(.top, 20)
        .padding(.horizontal, 22)
        .padding(.bottom, 18)
        .frame(width: 520, height: 680, alignment: .topLeading)
        .onDisappear {
            stopShortcutRecording()
        }
        .alert("Clear clipboard history?", isPresented: $isClearHistoryAlertPresented) {
            Button("Clear History", role: .destructive) {
                appState.clearHistory()
            }

            Button("Cancel", role: .cancel) {}
        } message: {
            Text("This removes saved clips from Clip Pocket. It does not remove anything from other apps.")
        }
    }

    private var versionText: String {
        Bundle.main.object(forInfoDictionaryKey: "CFBundleShortVersionString") as? String ?? "0.1.0"
    }

    private var buildText: String {
        Bundle.main.object(forInfoDictionaryKey: "CFBundleVersion") as? String ?? "1"
    }

    private func toggleShortcutRecording() {
        if isRecordingShortcut {
            stopShortcutRecording()
        } else {
            startShortcutRecording()
        }
    }

    private func startShortcutRecording() {
        stopShortcutRecording()
        isRecordingShortcut = true

        keyDownMonitor = NSEvent.addLocalMonitorForEvents(matching: .keyDown) { event in
            if Int(event.keyCode) == kVK_Escape {
                stopShortcutRecording()
                return nil
            }

            guard let shortcut = KeyboardShortcut.from(event: event) else {
                NSSound.beep()
                return nil
            }

            settingsStore.openPanelShortcut = shortcut
            stopShortcutRecording()
            return nil
        }
    }

    private func stopShortcutRecording() {
        if let keyDownMonitor {
            NSEvent.removeMonitor(keyDownMonitor)
        }

        keyDownMonitor = nil
        isRecordingShortcut = false
    }
}
