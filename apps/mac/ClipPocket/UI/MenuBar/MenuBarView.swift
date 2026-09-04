import AppKit
import SwiftUI

struct MenuBarView: View {
    enum Presentation {
        case menuBar
        case window
    }

    var presentation: Presentation = .menuBar

    @EnvironmentObject private var appState: AppState
    @EnvironmentObject private var settingsStore: SettingsStore
    @Environment(\.colorScheme) private var colorScheme
    @Environment(\.accessibilityReduceMotion) private var reduceMotion
    @State private var hoveredClipID: UUID?
    @State private var isSelectionMode = false
    @State private var selectedClipIDs = Set<UUID>()
    @State private var isClearConfirmationVisible = false
    @State private var isDeleteSelectedConfirmationVisible = false

    var body: some View {
        VStack(alignment: .leading, spacing: 12) {
            header

            TextField("Search clips, links, emails, colors or code...", text: $appState.searchQuery)
                .textFieldStyle(.roundedBorder)

            filterPicker

            if appState.totalClipCount > 0 {
                historyActions
            }

            clipHistory

            Divider()

            HStack {
                Button {
                    SettingsWindowPresenter.shared.show(appState: appState, settingsStore: settingsStore)
                } label: {
                    Label("Settings", systemImage: "gearshape")
                }

                Spacer()

                Button {
                    NSApp.terminate(nil)
                } label: {
                    Label("Quit", systemImage: "power")
                }
            }
            .buttonStyle(.bordered)
            .controlSize(.small)
        }
        .padding(.top, 16)
        .padding(.horizontal, 16)
        .padding(.bottom, 14)
        .frame(
            minWidth: 392,
            idealWidth: 392,
            maxWidth: presentation == .window ? .infinity : 392,
            minHeight: presentation == .window ? 520 : nil,
            maxHeight: presentation == .window ? .infinity : nil,
            alignment: .topLeading
        )
        .onChange(of: appState.searchQuery) { _ in
            exitSelectionMode()
        }
        .onChange(of: appState.selectedFilter) { _ in
            exitSelectionMode()
        }
    }

    private var header: some View {
        HStack(spacing: 10) {
            Image("ClipPocketMenuBarIcon")
                .renderingMode(.template)
                .resizable()
                .scaledToFit()
                .foregroundStyle(.secondary)
                .frame(width: 16, height: 16)
                .frame(width: 28, height: 28)

            VStack(alignment: .leading, spacing: 2) {
                Text(appState.appName)
                    .font(.system(size: 17, weight: .semibold))

                if appState.statusMessage != "Watching clipboard" {
                    Text(appState.statusMessage)
                        .font(.system(size: 11))
                        .foregroundStyle(.secondary)
                        .lineLimit(1)
                }
            }

            Spacer()

            Text("\(appState.filteredClips.count)/\(appState.totalClipCount)")
                .font(.system(size: 12, weight: .semibold))
                .foregroundStyle(.secondary)
                .padding(.horizontal, 8)
                .padding(.vertical, 4)
                .background(Color(nsColor: .controlBackgroundColor))
                .clipShape(Capsule())
        }
    }

    private var filterPicker: some View {
        Picker("Filter", selection: $appState.selectedFilter) {
            ForEach(ClipFilter.allCases) { filter in
                Text(filter.displayName)
                    .tag(filter)
            }
        }
        .pickerStyle(.segmented)
        .labelsHidden()
        .controlSize(.small)
    }

    private var historyActions: some View {
        HStack(spacing: 8) {
            if isDeleteSelectedConfirmationVisible {
                Text("Delete \(selectedClipIDs.count) clips?")
                    .font(.system(size: 12, weight: .medium))
                    .foregroundStyle(.secondary)

                Spacer()

                Button {
                    isDeleteSelectedConfirmationVisible = false
                } label: {
                    Label("Cancel", systemImage: "xmark")
                }

                Button(role: .destructive) {
                    deleteSelectedClips()
                } label: {
                    Label("Delete", systemImage: "trash")
                }
            } else if isClearConfirmationVisible {
                Text("Clear all clips?")
                    .font(.system(size: 12, weight: .medium))
                    .foregroundStyle(.secondary)

                Spacer()

                Button {
                    isClearConfirmationVisible = false
                } label: {
                    Label("Cancel", systemImage: "xmark")
                }

                Button(role: .destructive) {
                    clearAllClips()
                } label: {
                    Label("Clear", systemImage: "trash")
                }
            } else if isSelectionMode {
                Button {
                    exitSelectionMode()
                } label: {
                    Label("Cancel", systemImage: "xmark")
                }

                Spacer()

                Text("\(selectedClipIDs.count) selected")
                    .font(.system(size: 12, weight: .medium))
                    .foregroundStyle(.secondary)

                Button(role: .destructive) {
                    isDeleteSelectedConfirmationVisible = true
                } label: {
                    Label("Delete", systemImage: "trash")
                }
                .disabled(selectedClipIDs.isEmpty)
            } else {
                Button {
                    withAnimation(reduceMotion ? nil : .easeOut(duration: 0.16)) {
                        isSelectionMode = true
                        selectedClipIDs.removeAll()
                    }
                } label: {
                    Label("Select", systemImage: "checkmark.circle")
                }

                Spacer()

                Button(role: .destructive) {
                    isClearConfirmationVisible = true
                } label: {
                    Label("Clear", systemImage: "trash")
                }
            }
        }
        .buttonStyle(.bordered)
        .controlSize(.small)
    }

    @ViewBuilder
    private var clipHistory: some View {
        if appState.totalClipCount == 0 {
            VStack(alignment: .leading, spacing: 6) {
                Label("Your pocket is empty", systemImage: "tray")
                    .font(.system(size: 15, weight: .semibold))

                Text("Copy something anywhere on your Mac and it will appear here.")
                    .font(.system(size: 13))
                    .foregroundStyle(.secondary)
            }
            .frame(maxWidth: .infinity, alignment: .leading)
            .padding(12)
            .background(Color(nsColor: .controlBackgroundColor))
            .clipShape(RoundedRectangle(cornerRadius: 10, style: .continuous))
        } else if appState.filteredClips.isEmpty && appState.isSearching {
            VStack(alignment: .leading, spacing: 6) {
                Label("No clips found", systemImage: "magnifyingglass")
                    .font(.system(size: 15, weight: .semibold))

                Text("Try another word, link, email or color.")
                    .font(.system(size: 13))
                    .foregroundStyle(.secondary)
            }
            .frame(maxWidth: .infinity, alignment: .leading)
            .padding(12)
            .background(Color(nsColor: .controlBackgroundColor))
            .clipShape(RoundedRectangle(cornerRadius: 10, style: .continuous))
        } else if appState.filteredClips.isEmpty {
            VStack(alignment: .leading, spacing: 6) {
                Label("No \(appState.selectedFilter.displayName.lowercased()) clips", systemImage: "line.3.horizontal.decrease.circle")
                    .font(.system(size: 15, weight: .semibold))

                Text("Switch filters or copy a matching item.")
                    .font(.system(size: 13))
                    .foregroundStyle(.secondary)
            }
            .frame(maxWidth: .infinity, alignment: .leading)
            .padding(12)
            .background(Color(nsColor: .controlBackgroundColor))
            .clipShape(RoundedRectangle(cornerRadius: 10, style: .continuous))
        } else {
            ScrollView {
                LazyVStack(spacing: 6) {
                    ForEach(appState.filteredClips) { clip in
                        clipRow(clip)
                    }
                }
                .padding(.vertical, 1)
            }
            .frame(
                minHeight: 260,
                maxHeight: presentation == .window ? .infinity : 430
            )
        }
    }

    private func clipRow(_ clip: Clip) -> some View {
        let isCopied = appState.lastCopiedClipID == clip.id
        let isHovered = hoveredClipID == clip.id
        let isSelected = selectedClipIDs.contains(clip.id)

        return HStack(alignment: .center, spacing: 10) {
            Button {
                if isSelectionMode {
                    toggleSelection(for: clip)
                } else {
                    appState.copyToClipboard(clip)
                }
            } label: {
                HStack(alignment: .center, spacing: 10) {
                    Image(systemName: isSelectionMode ? (isSelected ? "checkmark.circle.fill" : "circle") : clip.type.symbolName)
                        .font(.system(size: 13, weight: .regular))
                        .foregroundStyle(isSelected ? Color.accentColor : (isCopied ? Color.accentColor : quietIconColor))
                        .frame(width: 22, height: 22)
                        .scaleEffect((isCopied || isSelected) && !reduceMotion ? 1.04 : 1)

                    VStack(alignment: .leading, spacing: 4) {
                        HStack(spacing: 6) {
                            Text(clip.type.displayName)
                                .font(.system(size: 11, weight: .semibold))
                                .foregroundStyle(.secondary)

                            if clip.isPinned {
                                Image(systemName: "pin.fill")
                                    .font(.system(size: 9, weight: .semibold))
                                    .foregroundStyle(activeIconColor)
                                    .transition(.opacity.combined(with: .scale(scale: 0.9)))
                            }

                            if clip.isFavorite {
                                Image(systemName: "star.fill")
                                    .font(.system(size: 9, weight: .semibold))
                                    .foregroundStyle(activeIconColor)
                                    .transition(.opacity.combined(with: .scale(scale: 0.9)))
                            }
                        }

                        Text(clip.title)
                            .font(clip.type == .code ? .system(size: 12, design: .monospaced) : .system(size: 13))
                            .foregroundStyle(.primary)
                            .lineLimit(2)
                    }
                    .frame(maxWidth: .infinity, alignment: .leading)
                }
                .contentShape(Rectangle())
            }
            .buttonStyle(.plain)

            if !isSelectionMode {
                Spacer(minLength: 8)

                HStack(spacing: 3) {
                    Button {
                        appState.copyToClipboard(clip)
                    } label: {
                        Image(systemName: isCopied ? "checkmark.circle.fill" : "square.on.square")
                            .id(isCopied)
                            .font(.system(size: 12, weight: isCopied ? .semibold : .regular))
                            .foregroundStyle(isCopied ? Color.accentColor : quietIconColor)
                            .scaleEffect(isCopied && !reduceMotion ? 1.04 : 1)
                            .transition(.opacity.combined(with: .scale(scale: 0.92)))
                    }
                    .help(isCopied ? "Copied" : "Copy")

                    Button {
                        appState.togglePinned(clip)
                    } label: {
                        Image(systemName: clip.isPinned ? "pin.fill" : "pin")
                            .font(.system(size: 12, weight: clip.isPinned ? .semibold : .regular))
                            .foregroundStyle(clip.isPinned ? activeIconColor : quietIconColor)
                            .scaleEffect(clip.isPinned && !reduceMotion ? 1.03 : 1)
                    }
                    .help(clip.isPinned ? "Unpin" : "Pin")

                    Button {
                        appState.toggleFavorite(clip)
                    } label: {
                        Image(systemName: clip.isFavorite ? "star.fill" : "star")
                            .font(.system(size: 12, weight: clip.isFavorite ? .semibold : .regular))
                            .foregroundStyle(clip.isFavorite ? activeIconColor : quietIconColor)
                            .scaleEffect(clip.isFavorite && !reduceMotion ? 1.03 : 1)
                    }
                    .help(clip.isFavorite ? "Unfavorite" : "Favorite")

                    Button(role: .destructive) {
                        appState.delete(clip)
                    } label: {
                        Image(systemName: "trash")
                            .font(.system(size: 12, weight: .regular))
                            .foregroundStyle(quietIconColor)
                    }
                    .help("Delete")
                }
                .buttonStyle(.borderless)
                .opacity(isHovered || isCopied ? 1 : 0.72)
            }
        }
        .padding(.horizontal, 10)
        .padding(.vertical, 8)
        .background {
            RoundedRectangle(cornerRadius: 8, style: .continuous)
                .fill(rowBackground(isCopied: isCopied, isHovered: isHovered, isSelected: isSelected))
        }
        .overlay {
            RoundedRectangle(cornerRadius: 8, style: .continuous)
                .stroke(rowBorder(isCopied: isCopied, isHovered: isHovered, isSelected: isSelected), lineWidth: 1)
        }
        .shadow(
            color: rowShadow(isCopied: isCopied, isHovered: isHovered, isSelected: isSelected),
            radius: isHovered || isCopied || isSelected ? 7 : 2,
            x: 0,
            y: isHovered || isCopied || isSelected ? 3 : 1
        )
        .clipShape(RoundedRectangle(cornerRadius: 8, style: .continuous))
        .onHover { isHovering in
            withAnimation(reduceMotion ? nil : .easeOut(duration: 0.14)) {
                hoveredClipID = isHovering ? clip.id : nil
            }
        }
        .animation(reduceMotion ? nil : .easeOut(duration: 0.16), value: isCopied)
        .animation(reduceMotion ? nil : .easeOut(duration: 0.14), value: isHovered)
        .animation(reduceMotion ? nil : .easeOut(duration: 0.16), value: clip.isPinned)
        .animation(reduceMotion ? nil : .easeOut(duration: 0.16), value: clip.isFavorite)
        .animation(reduceMotion ? nil : .easeOut(duration: 0.16), value: isSelected)
    }

    private func rowBackground(isCopied: Bool, isHovered: Bool, isSelected: Bool) -> Color {
        if colorScheme == .dark {
            if isSelected {
                return Color.accentColor.opacity(0.16)
            }

            if isCopied {
                return Color.accentColor.opacity(0.13)
            }

            if isHovered {
                return Color.primary.opacity(0.08)
            }

            return Color.primary.opacity(0.045)
        }

        if isSelected {
            return Color(nsColor: NSColor(calibratedRed: 0.94, green: 0.965, blue: 1.0, alpha: 0.96))
        }

        if isCopied {
            return Color(nsColor: NSColor(calibratedRed: 0.955, green: 0.975, blue: 1.0, alpha: 0.96))
        }

        if isHovered {
            return Color(nsColor: NSColor(calibratedRed: 0.976, green: 0.982, blue: 0.992, alpha: 0.98))
        }

        return Color(nsColor: NSColor(calibratedRed: 0.985, green: 0.988, blue: 0.993, alpha: 0.94))
    }

    private func rowBorder(isCopied: Bool, isHovered: Bool, isSelected: Bool) -> Color {
        if isCopied || isSelected {
            return Color.accentColor.opacity(colorScheme == .dark ? 0.28 : 0.18)
        }

        if isHovered {
            return Color(nsColor: .separatorColor).opacity(colorScheme == .dark ? 0.26 : 0.18)
        }

        return Color(nsColor: .separatorColor).opacity(colorScheme == .dark ? 0.2 : 0.14)
    }

    private func rowShadow(isCopied: Bool, isHovered: Bool, isSelected: Bool) -> Color {
        guard colorScheme == .light else {
            return Color.clear
        }

        if isHovered || isCopied || isSelected {
            return Color.black.opacity(0.07)
        }

        return Color.black.opacity(0.035)
    }

    private var quietIconColor: Color {
        Color.secondary.opacity(0.76)
    }

    private var activeIconColor: Color {
        Color.accentColor
    }

    private func toggleSelection(for clip: Clip) {
        withAnimation(reduceMotion ? nil : .easeOut(duration: 0.14)) {
            if selectedClipIDs.contains(clip.id) {
                selectedClipIDs.remove(clip.id)
            } else {
                selectedClipIDs.insert(clip.id)
            }

            if selectedClipIDs.isEmpty {
                isDeleteSelectedConfirmationVisible = false
            }
        }
    }

    private func exitSelectionMode() {
        withAnimation(reduceMotion ? nil : .easeOut(duration: 0.16)) {
            isSelectionMode = false
            selectedClipIDs.removeAll()
            isDeleteSelectedConfirmationVisible = false
            isClearConfirmationVisible = false
        }
    }

    private func deleteSelectedClips() {
        appState.deleteClips(withIDs: selectedClipIDs)
        exitSelectionMode()
    }

    private func clearAllClips() {
        appState.clearHistory()
        exitSelectionMode()
    }
}

@MainActor
private final class SettingsWindowPresenter: NSObject, NSWindowDelegate {
    static let shared = SettingsWindowPresenter()

    private var window: NSWindow?

    func show(appState: AppState, settingsStore: SettingsStore) {
        if let window {
            window.makeKeyAndOrderFront(nil)
            NSApp.activate(ignoringOtherApps: true)
            return
        }

        let contentView = SettingsView()
            .environmentObject(appState)
            .environmentObject(settingsStore)

        let hostingController = NSHostingController(rootView: contentView)
        let window = NSWindow(contentViewController: hostingController)
        window.title = "Clip Pocket Settings"
        window.styleMask = [.titled, .closable, .miniaturizable]
        window.level = .floating
        window.collectionBehavior = [.moveToActiveSpace, .fullScreenAuxiliary]
        window.isReleasedWhenClosed = false
        window.isRestorable = false
        window.isMovableByWindowBackground = true
        window.delegate = self
        window.setContentSize(NSSize(width: 520, height: 680))
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
        let preferredY = visibleFrame.midY - frame.height / 2 - 64
        let y = max(visibleFrame.minY + 24, preferredY)

        window.setFrameOrigin(NSPoint(x: x, y: y))
    }
}
