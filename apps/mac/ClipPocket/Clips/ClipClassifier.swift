import Foundation

struct ClipClassifier {
    func classify(_ text: String) -> ClipType {
        let value = text.trimmingCharacters(in: .whitespacesAndNewlines)

        if isEmail(value) {
            return .email
        }

        if isURL(value) {
            return .link
        }

        if isColor(value) {
            return .color
        }

        if looksLikeCode(value) {
            return .code
        }

        return .text
    }

    private func isURL(_ value: String) -> Bool {
        guard value.contains(".") || value.contains("://") else {
            return false
        }

        if value.contains(" ") || value.contains("\n") {
            return false
        }

        if let url = URL(string: value),
           let scheme = url.scheme?.lowercased(),
           ["http", "https"].contains(scheme),
           url.host != nil {
            return true
        }

        let pattern = #"^(www\.)?[A-Za-z0-9](?:[A-Za-z0-9-]{0,61}[A-Za-z0-9])?(?:\.[A-Za-z0-9](?:[A-Za-z0-9-]{0,61}[A-Za-z0-9])?)+(?::\d{2,5})?(?:/[^\s]*)?(?:\?[^\s]*)?(?:#[^\s]*)?$"#
        return value.range(of: pattern, options: [.regularExpression, .caseInsensitive]) != nil
    }

    private func isEmail(_ value: String) -> Bool {
        let pattern = #"^[A-Z0-9._%+-]+@[A-Z0-9.-]+\.[A-Z]{2,}$"#
        return value.range(of: pattern, options: [.regularExpression, .caseInsensitive]) != nil
    }

    private func isColor(_ value: String) -> Bool {
        let patterns = [
            #"^#(?:[0-9A-Fa-f]{3}|[0-9A-Fa-f]{4}|[0-9A-Fa-f]{6}|[0-9A-Fa-f]{8})$"#,
            #"^rgba?\(\s*(?:\d{1,3}\s*,\s*){2}\d{1,3}(?:\s*,\s*(?:0|1|0?\.\d+))?\s*\)$"#,
            #"^hsla?\(\s*\d{1,3}(?:deg)?\s*,\s*\d{1,3}%\s*,\s*\d{1,3}%(?:\s*,\s*(?:0|1|0?\.\d+))?\s*\)$"#
        ]

        return patterns.contains { pattern in
            value.range(of: pattern, options: [.regularExpression, .caseInsensitive]) != nil
        }
    }

    private func looksLikeCode(_ value: String) -> Bool {
        let commonCodePatterns = [
            #"\b(import|func|let|var|class|struct|enum|return|if|else|for|while|switch|case|const|function|=>)\b"#,
            #"^\s*(def|class|interface|type|public|private|protected)\s+\w+"#,
            #"#include\s*[<"]"#,
            #"<[A-Za-z][^>]*>.*</[A-Za-z][^>]*>"#,
            #"\w+\s*=\s*["'\[{(0-9]"#,
            #"\w+\([^)]*\)\s*[;{]?$"#
        ]

        let hasLineBreak = value.contains("\n")
        let hasCodePattern = commonCodePatterns.contains { pattern in
            value.range(of: pattern, options: [.regularExpression, .caseInsensitive]) != nil
        }
        let hasCodePunctuation = value.range(of: #"[{};]"#, options: .regularExpression) != nil

        if hasLineBreak && (hasCodePattern || hasCodePunctuation) {
            return true
        }

        return value.count < 240 && hasCodePattern && hasCodePunctuation
    }
}
