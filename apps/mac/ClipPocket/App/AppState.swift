import Combine
import Foundation
import SwiftUI

@MainActor
final class AppState: ObservableObject {
    @Published private(set) var statusMessage = "Loading history"
    @Published var searchQuery = "" {
        didSet {
            refreshClips()
        }
    }
    @Published var selectedFilter: ClipFilter = .all
    @Published private(set) var lastDetectedClip: DetectedClip?
    @Published private(set) var detectedClipCount = 0
    @Published private(set) var clips: [Clip] = []
    @Published private(set) var totalClipCount = 0
    @Published private(set) var lastCopiedClipID: UUID?

    let appName = "Clip Pocket"

    private let settingsStore: SettingsStore
    private let clipStore: ClipStore?
    private let clipboardMonitor: ClipboardMonitor
    private let pasteboardWriter = PasteboardWriter()
    private var cancellables = Set<AnyCancellable>()

    var filteredClips: [Clip] {
        clips.filter { selectedFilter.matches($0) }
    }

    init(settingsStore: SettingsStore) {
        let clipStore: ClipStore?
        do {
            clipStore = try ClipStore()
        } catch {
            clipStore = nil
            print("[ClipPocket] Local store unavailable: \(error.localizedDescription)")
        }

        let clipboardMonitor = ClipboardMonitor()
        self.settingsStore = settingsStore
        self.clipStore = clipStore
        self.clipboardMonitor = clipboardMonitor
        applyClipboardSettings()
        observeSettings()

        refreshClips()

        clipboardMonitor.onClipDetected = { [weak self] clip in
            self?.handleDetectedClip(clip)
        }
        if !settingsStore.isClipboardMonitoringPaused {
            clipboardMonitor.start()
        }
    }

    func togglePinned(_ clip: Clip) {
        do {
            try clipStore?.setPinned(!clip.isPinned, for: clip)
            withAnimation(.easeOut(duration: 0.18)) {
                refreshClips()
            }
        } catch {
            handleStoreError(error)
        }
    }

    func toggleFavorite(_ clip: Clip) {
        do {
            try clipStore?.setFavorite(!clip.isFavorite, for: clip)
            withAnimation(.easeOut(duration: 0.18)) {
                refreshClips()
            }
        } catch {
            handleStoreError(error)
        }
    }

    func delete(_ clip: Clip) {
        do {
            try clipStore?.delete(clip)
            refreshClips()
        } catch {
            handleStoreError(error)
        }
    }

    func deleteClips(withIDs clipIDs: Set<UUID>) {
        do {
            try clipStore?.deleteClips(withIDs: clipIDs)
            refreshClips()
        } catch {
            handleStoreError(error)
        }
    }

    func copyToClipboard(_ clip: Clip) {
        pasteboardWriter.write(clip.plainText)
        withAnimation(.easeOut(duration: 0.16)) {
            lastCopiedClipID = clip.id
        }

        do {
            try clipStore?.recordCopyBack(for: clip)
            statusMessage = "Copied \(clip.type.displayName.lowercased()) clip"
        } catch {
            handleStoreError(error)
        }

        Task { [weak self, clipID = clip.id] in
            try? await Task.sleep(for: .seconds(1.4))
            await MainActor.run {
                guard self?.lastCopiedClipID == clipID else {
                    return
                }

                withAnimation(.easeOut(duration: 0.2)) {
                    self?.lastCopiedClipID = nil
                }
            }
        }
    }

    func clearHistory() {
        do {
            try clipStore?.clearHistory()
            searchQuery = ""
            refreshClips()
        } catch {
            handleStoreError(error)
        }
    }

    var isSearching: Bool {
        !searchQuery.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty
    }

    private func handleDetectedClip(_ clip: DetectedClip) {
        lastDetectedClip = clip
        detectedClipCount += 1

        guard let clipStore else {
            statusMessage = "Detected \(clip.type.displayName.lowercased()) clip"
            return
        }

        do {
            let savedClip = try clipStore.saveDetectedClip(
                clip,
                ignoringDuplicates: settingsStore.ignoreDuplicateClips
            )
            try clipStore.enforceHistoryLimit(settingsStore.maxHistorySize)
            refreshClips()

            if savedClip.copyCount > 1 {
                statusMessage = "Updated duplicate \(clip.type.displayName.lowercased()) clip"
            } else {
                statusMessage = "Saved \(clip.type.displayName.lowercased()) clip"
            }
        } catch {
            handleStoreError(error)
        }
    }

    private func refreshClips() {
        guard let clipStore else {
            statusMessage = "Local store unavailable"
            return
        }

        do {
            totalClipCount = try clipStore.countClips()
            if isSearching {
                clips = try clipStore.searchClips(matching: searchQuery)
            } else {
                clips = try clipStore.loadClips(limit: settingsStore.maxHistorySize)
            }
            statusMessage = settingsStore.isClipboardMonitoringPaused ? "Clipboard monitoring is paused" : "Watching clipboard"
        } catch {
            clips = []
            handleStoreError(error)
        }
    }

    private func observeSettings() {
        settingsStore.$isClipboardMonitoringPaused
            .dropFirst()
            .sink { [weak self] _ in
                self?.applyClipboardSettings()
                self?.refreshClips()
            }
            .store(in: &cancellables)

        settingsStore.$ignoreTransientClipboardContent
            .dropFirst()
            .sink { [weak self] _ in
                self?.applyClipboardSettings()
            }
            .store(in: &cancellables)

        settingsStore.$ignoreConcealedClipboardContent
            .dropFirst()
            .sink { [weak self] _ in
                self?.applyClipboardSettings()
            }
            .store(in: &cancellables)

        settingsStore.$maxHistorySize
            .dropFirst()
            .sink { [weak self] maximumClipCount in
                self?.enforceHistoryLimit(maximumClipCount)
                self?.refreshClips()
            }
            .store(in: &cancellables)
    }

    private func applyClipboardSettings() {
        clipboardMonitor.ignoresTransientClipboardContent = settingsStore.ignoreTransientClipboardContent
        clipboardMonitor.ignoresConcealedClipboardContent = settingsStore.ignoreConcealedClipboardContent

        if settingsStore.isClipboardMonitoringPaused {
            clipboardMonitor.stop()
        } else if !clipboardMonitor.isRunning {
            clipboardMonitor.start()
        }
    }

    private func enforceHistoryLimit(_ maximumClipCount: Int) {
        do {
            try clipStore?.enforceHistoryLimit(maximumClipCount)
        } catch {
            handleStoreError(error)
        }
    }

    private func handleStoreError(_ error: Error) {
        statusMessage = "Local store error"
        print("[ClipPocket] Store error: \(error.localizedDescription)")
    }
}
