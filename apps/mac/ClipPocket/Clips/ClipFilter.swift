import Foundation

enum ClipFilter: String, CaseIterable, Identifiable {
    case all
    case text
    case link
    case email
    case color
    case code
    case pinned

    var id: String { rawValue }

    var displayName: String {
        switch self {
        case .all:
            return "All"
        case .text:
            return "Text"
        case .link:
            return "Links"
        case .email:
            return "Emails"
        case .color:
            return "Colors"
        case .code:
            return "Code"
        case .pinned:
            return "Pinned"
        }
    }

    func matches(_ clip: Clip) -> Bool {
        switch self {
        case .all:
            return true
        case .text:
            return clip.type == .text
        case .link:
            return clip.type == .link
        case .email:
            return clip.type == .email
        case .color:
            return clip.type == .color
        case .code:
            return clip.type == .code
        case .pinned:
            return clip.isPinned
        }
    }
}
