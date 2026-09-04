import Foundation

struct Clip: Identifiable, Equatable {
    let id: UUID
    var type: ClipType
    var title: String
    var plainText: String
    var normalizedText: String
    var searchText: String
    var sourceAppName: String?
    var sourceBundleIdentifier: String?
    var url: String?
    var email: String?
    var colorValue: String?
    var createdAt: Date
    var updatedAt: Date
    var lastCopiedAt: Date
    var copyCount: Int
    var isPinned: Bool
    var isFavorite: Bool
    var isDeleted: Bool
    var tags: [String]
    var characterCount: Int
    var contentHash: String

    var previewText: String {
        plainText
            .replacingOccurrences(of: "\n", with: " ")
            .trimmingCharacters(in: .whitespacesAndNewlines)
    }

    static func make(from detectedClip: DetectedClip) -> Clip {
        let now = detectedClip.detectedAt
        let normalizedText = detectedClip.plainText
            .trimmingCharacters(in: .whitespacesAndNewlines)
            .lowercased()

        return Clip(
            id: UUID(),
            type: detectedClip.type,
            title: detectedClip.title,
            plainText: detectedClip.plainText,
            normalizedText: normalizedText,
            searchText: normalizedText,
            sourceAppName: nil,
            sourceBundleIdentifier: nil,
            url: detectedClip.type == .link ? detectedClip.plainText : nil,
            email: detectedClip.type == .email ? detectedClip.plainText : nil,
            colorValue: detectedClip.type == .color ? detectedClip.plainText : nil,
            createdAt: now,
            updatedAt: now,
            lastCopiedAt: now,
            copyCount: 1,
            isPinned: false,
            isFavorite: false,
            isDeleted: false,
            tags: [],
            characterCount: detectedClip.plainText.count,
            contentHash: detectedClip.contentHash
        )
    }
}
