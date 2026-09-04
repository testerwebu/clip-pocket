import AppKit

struct PasteboardReadResult {
    let plainText: String
    let types: Set<NSPasteboard.PasteboardType>
}

struct PasteboardReader {
    func readText(
        from pasteboard: NSPasteboard,
        ignoringTransientTypes: Bool = true,
        ignoringConcealedTypes: Bool = true
    ) -> PasteboardReadResult? {
        let types = Set(pasteboard.types ?? [])

        guard !types.contains(PasteboardTypes.internalMarker) else {
            return nil
        }

        guard !ignoringTransientTypes || types.isDisjoint(with: PasteboardTypes.transientTypes) else {
            return nil
        }

        guard !ignoringConcealedTypes || types.isDisjoint(with: PasteboardTypes.concealedTypes) else {
            return nil
        }

        guard let text = pasteboard.string(forType: .string)?
            .trimmingCharacters(in: .whitespacesAndNewlines),
            !text.isEmpty
        else {
            return nil
        }

        return PasteboardReadResult(plainText: text, types: types)
    }
}

struct PasteboardWriter {
    func write(_ text: String, to pasteboard: NSPasteboard = .general) {
        pasteboard.clearContents()
        pasteboard.setString(text, forType: .string)
        pasteboard.setString("1", forType: PasteboardTypes.internalMarker)
    }
}
