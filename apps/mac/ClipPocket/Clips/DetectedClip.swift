import Foundation

struct DetectedClip: Identifiable, Equatable {
    let id = UUID()
    let type: ClipType
    let plainText: String
    let title: String
    let contentHash: String
    let detectedAt: Date

    var previewText: String {
        plainText
            .replacingOccurrences(of: "\n", with: " ")
            .trimmingCharacters(in: .whitespacesAndNewlines)
    }
}
