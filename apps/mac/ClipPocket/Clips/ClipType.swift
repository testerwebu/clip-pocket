import Foundation

enum ClipType: String, CaseIterable, Identifiable {
    case text
    case link
    case email
    case color
    case code

    var id: String { rawValue }

    var displayName: String {
        switch self {
        case .text:
            return "Text"
        case .link:
            return "Link"
        case .email:
            return "Email"
        case .color:
            return "Color"
        case .code:
            return "Code"
        }
    }

    var symbolName: String {
        switch self {
        case .text:
            return "doc.text"
        case .link:
            return "link"
        case .email:
            return "at"
        case .color:
            return "eyedropper"
        case .code:
            return "curlybraces"
        }
    }
}
