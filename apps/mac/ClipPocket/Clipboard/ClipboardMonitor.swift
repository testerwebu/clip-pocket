import AppKit
import CryptoKit
import Foundation

@MainActor
final class ClipboardMonitor {
    var onClipDetected: ((DetectedClip) -> Void)?
    var ignoresTransientClipboardContent = true
    var ignoresConcealedClipboardContent = true

    private let pasteboard: NSPasteboard
    private let reader: PasteboardReader
    private let classifier: ClipClassifier
    private var timer: Timer?
    private var lastChangeCount: Int

    init(
        pasteboard: NSPasteboard = .general,
        reader: PasteboardReader = PasteboardReader(),
        classifier: ClipClassifier = ClipClassifier()
    ) {
        self.pasteboard = pasteboard
        self.reader = reader
        self.classifier = classifier
        self.lastChangeCount = pasteboard.changeCount
    }

    var isRunning: Bool {
        timer != nil
    }

    func start() {
        guard timer == nil else {
            return
        }

        lastChangeCount = pasteboard.changeCount

        let timer = Timer(timeInterval: 0.75, repeats: true) { [weak self] _ in
            Task { @MainActor in
                self?.pollPasteboard()
            }
        }
        timer.tolerance = 0.15

        RunLoop.main.add(timer, forMode: .common)
        self.timer = timer
    }

    func stop() {
        timer?.invalidate()
        timer = nil
    }

    private func pollPasteboard() {
        let currentChangeCount = pasteboard.changeCount

        guard currentChangeCount != lastChangeCount else {
            return
        }

        lastChangeCount = currentChangeCount

        guard let result = reader.readText(
            from: pasteboard,
            ignoringTransientTypes: ignoresTransientClipboardContent,
            ignoringConcealedTypes: ignoresConcealedClipboardContent
        ) else {
            return
        }

        let hash = contentHash(for: result.plainText)
        let clipType = classifier.classify(result.plainText)
        let detectedClip = DetectedClip(
            type: clipType,
            plainText: result.plainText,
            title: makeTitle(from: result.plainText),
            contentHash: hash,
            detectedAt: Date()
        )

        onClipDetected?(detectedClip)
    }

    private func contentHash(for text: String) -> String {
        let normalized = text.trimmingCharacters(in: .whitespacesAndNewlines)
        let digest = SHA256.hash(data: Data(normalized.utf8))

        return digest.map { byte in
            String(format: "%02x", byte)
        }
        .joined()
    }

    private func makeTitle(from text: String) -> String {
        let preview = text
            .replacingOccurrences(of: "\n", with: " ")
            .trimmingCharacters(in: .whitespacesAndNewlines)

        if preview.count <= 60 {
            return preview
        }

        return String(preview.prefix(57)) + "..."
    }
}
