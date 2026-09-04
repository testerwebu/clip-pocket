import Foundation
import SQLite3

enum ClipStoreError: LocalizedError {
    case saveFailed(String)
    case loadFailed(String)
    case updateFailed(String)

    var errorDescription: String? {
        switch self {
        case .saveFailed(let message):
            return "Could not save clip: \(message)"
        case .loadFailed(let message):
            return "Could not load clips: \(message)"
        case .updateFailed(let message):
            return "Could not update clip: \(message)"
        }
    }
}

@MainActor
final class ClipStore {
    private let database: SQLiteDatabase
    private let sqliteTransient = unsafeBitCast(-1, to: sqlite3_destructor_type.self)

    init(database: SQLiteDatabase? = nil) throws {
        self.database = try database ?? SQLiteDatabase(fileURL: SQLiteDatabase.defaultFileURL())
        try migrate()
    }

    func saveDetectedClip(_ detectedClip: DetectedClip, ignoringDuplicates: Bool = true) throws -> Clip {
        if let existingClip = try findClip(contentHash: detectedClip.contentHash) {
            if ignoringDuplicates && !existingClip.isDeleted {
                return existingClip
            }

            return try updateDuplicate(existingClip)
        }

        let clip = Clip.make(from: detectedClip)
        try insert(clip)
        return clip
    }

    func loadClips(limit: Int = 100) throws -> [Clip] {
        let sql = """
        SELECT id, type, title, plainText, normalizedText, searchText,
               sourceAppName, sourceBundleIdentifier, url, email, colorValue,
               createdAt, updatedAt, lastCopiedAt, copyCount,
               isPinned, isFavorite, isDeleted, tags, characterCount, contentHash
        FROM clips
        WHERE isDeleted = 0
        ORDER BY isPinned DESC, lastCopiedAt DESC
        LIMIT ?;
        """

        let statement = try database.prepare(sql)
        defer {
            sqlite3_finalize(statement)
        }

        sqlite3_bind_int(statement, 1, Int32(limit))

        var clips: [Clip] = []
        while sqlite3_step(statement) == SQLITE_ROW {
            clips.append(readClip(from: statement))
        }

        return clips
    }

    func searchClips(matching query: String, limit: Int = 100) throws -> [Clip] {
        guard let ftsQuery = makeFTSQuery(from: query) else {
            return try loadClips(limit: limit)
        }

        let sql = """
        SELECT clips.id, clips.type, clips.title, clips.plainText, clips.normalizedText, clips.searchText,
               clips.sourceAppName, clips.sourceBundleIdentifier, clips.url, clips.email, clips.colorValue,
               clips.createdAt, clips.updatedAt, clips.lastCopiedAt, clips.copyCount,
               clips.isPinned, clips.isFavorite, clips.isDeleted, clips.tags, clips.characterCount, clips.contentHash
        FROM clips
        JOIN clip_search ON clip_search.clipID = clips.id
        WHERE clips.isDeleted = 0
          AND clip_search MATCH ?
        ORDER BY clips.isPinned DESC, bm25(clip_search), clips.lastCopiedAt DESC
        LIMIT ?;
        """

        let statement = try database.prepare(sql)
        defer {
            sqlite3_finalize(statement)
        }

        bindText(ftsQuery, at: 1, in: statement)
        sqlite3_bind_int(statement, 2, Int32(limit))

        var clips: [Clip] = []
        while sqlite3_step(statement) == SQLITE_ROW {
            clips.append(readClip(from: statement))
        }

        return clips
    }

    func countClips() throws -> Int {
        let sql = """
        SELECT COUNT(*)
        FROM clips
        WHERE isDeleted = 0;
        """

        let statement = try database.prepare(sql)
        defer {
            sqlite3_finalize(statement)
        }

        guard sqlite3_step(statement) == SQLITE_ROW else {
            throw ClipStoreError.loadFailed(database.lastErrorMessage)
        }

        return Int(sqlite3_column_int(statement, 0))
    }

    func setPinned(_ isPinned: Bool, for clip: Clip) throws {
        try updateBooleanColumn("isPinned", value: isPinned, clipID: clip.id)
    }

    func setFavorite(_ isFavorite: Bool, for clip: Clip) throws {
        try updateBooleanColumn("isFavorite", value: isFavorite, clipID: clip.id)
    }

    func delete(_ clip: Clip) throws {
        let sql = """
        UPDATE clips
        SET isDeleted = 1, updatedAt = ?
        WHERE id = ?;
        """

        let statement = try database.prepare(sql)
        defer {
            sqlite3_finalize(statement)
        }

        sqlite3_bind_double(statement, 1, Date().timeIntervalSince1970)
        bindText(clip.id.uuidString, at: 2, in: statement)

        guard sqlite3_step(statement) == SQLITE_DONE else {
            throw ClipStoreError.updateFailed(database.lastErrorMessage)
        }

        try removeFromSearchIndex(clipID: clip.id)
    }

    func deleteClips(withIDs clipIDs: Set<UUID>) throws {
        guard !clipIDs.isEmpty else {
            return
        }

        let now = Date().timeIntervalSince1970

        for clipID in clipIDs {
            let sql = """
            UPDATE clips
            SET isDeleted = 1, updatedAt = ?
            WHERE id = ?;
            """

            let statement = try database.prepare(sql)
            defer {
                sqlite3_finalize(statement)
            }

            sqlite3_bind_double(statement, 1, now)
            bindText(clipID.uuidString, at: 2, in: statement)

            guard sqlite3_step(statement) == SQLITE_DONE else {
                throw ClipStoreError.updateFailed(database.lastErrorMessage)
            }

            try removeFromSearchIndex(clipID: clipID)
        }
    }

    func recordCopyBack(for clip: Clip) throws {
        let now = Date()
        let sql = """
        UPDATE clips
        SET updatedAt = ?, copyCount = copyCount + 1
        WHERE id = ?;
        """

        let statement = try database.prepare(sql)
        defer {
            sqlite3_finalize(statement)
        }

        sqlite3_bind_double(statement, 1, now.timeIntervalSince1970)
        bindText(clip.id.uuidString, at: 2, in: statement)

        guard sqlite3_step(statement) == SQLITE_DONE else {
            throw ClipStoreError.updateFailed(database.lastErrorMessage)
        }
    }

    func clearHistory() throws {
        let sql = """
        UPDATE clips
        SET isDeleted = 1, updatedAt = ?
        WHERE isDeleted = 0;
        """

        let statement = try database.prepare(sql)
        defer {
            sqlite3_finalize(statement)
        }

        sqlite3_bind_double(statement, 1, Date().timeIntervalSince1970)

        guard sqlite3_step(statement) == SQLITE_DONE else {
            throw ClipStoreError.updateFailed(database.lastErrorMessage)
        }

        try database.execute("DELETE FROM clip_search;")
    }

    func enforceHistoryLimit(_ maximumClipCount: Int) throws {
        guard maximumClipCount > 0 else {
            return
        }

        let sql = """
        UPDATE clips
        SET isDeleted = 1, updatedAt = ?
        WHERE isDeleted = 0
          AND isPinned = 0
          AND id NOT IN (
              SELECT id
              FROM clips
              WHERE isDeleted = 0
              ORDER BY isPinned DESC, lastCopiedAt DESC
              LIMIT ?
          );
        """

        let statement = try database.prepare(sql)
        defer {
            sqlite3_finalize(statement)
        }

        sqlite3_bind_double(statement, 1, Date().timeIntervalSince1970)
        sqlite3_bind_int(statement, 2, Int32(maximumClipCount))

        guard sqlite3_step(statement) == SQLITE_DONE else {
            throw ClipStoreError.updateFailed(database.lastErrorMessage)
        }

        try rebuildSearchIndex()
    }

    private func migrate() throws {
        try database.execute("""
        CREATE TABLE IF NOT EXISTS clips (
            id TEXT PRIMARY KEY,
            type TEXT NOT NULL,
            title TEXT NOT NULL,
            plainText TEXT NOT NULL,
            normalizedText TEXT NOT NULL,
            searchText TEXT NOT NULL,
            sourceAppName TEXT,
            sourceBundleIdentifier TEXT,
            url TEXT,
            email TEXT,
            colorValue TEXT,
            createdAt REAL NOT NULL,
            updatedAt REAL NOT NULL,
            lastCopiedAt REAL NOT NULL,
            copyCount INTEGER NOT NULL,
            isPinned INTEGER NOT NULL,
            isFavorite INTEGER NOT NULL,
            isDeleted INTEGER NOT NULL,
            tags TEXT NOT NULL DEFAULT '',
            characterCount INTEGER NOT NULL,
            contentHash TEXT NOT NULL UNIQUE
        );
        """)

        try database.execute("CREATE UNIQUE INDEX IF NOT EXISTS idx_clips_content_hash ON clips(contentHash);")
        try database.execute("CREATE INDEX IF NOT EXISTS idx_clips_last_copied_at ON clips(lastCopiedAt);")
        try database.execute("CREATE INDEX IF NOT EXISTS idx_clips_pinned ON clips(isPinned);")

        try database.execute("""
        CREATE VIRTUAL TABLE IF NOT EXISTS clip_search USING fts5(
            clipID UNINDEXED,
            searchText,
            tokenize = 'unicode61'
        );
        """)

        try rebuildSearchIndex()
    }

    private func insert(_ clip: Clip) throws {
        let sql = """
        INSERT INTO clips (
            id, type, title, plainText, normalizedText, searchText,
            sourceAppName, sourceBundleIdentifier, url, email, colorValue,
            createdAt, updatedAt, lastCopiedAt, copyCount,
            isPinned, isFavorite, isDeleted, tags, characterCount, contentHash
        ) VALUES (?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?);
        """

        let statement = try database.prepare(sql)
        defer {
            sqlite3_finalize(statement)
        }

        bind(clip, to: statement)

        guard sqlite3_step(statement) == SQLITE_DONE else {
            throw ClipStoreError.saveFailed(database.lastErrorMessage)
        }

        try index(clip)
    }

    private func findClip(contentHash: String) throws -> Clip? {
        let sql = """
        SELECT id, type, title, plainText, normalizedText, searchText,
               sourceAppName, sourceBundleIdentifier, url, email, colorValue,
               createdAt, updatedAt, lastCopiedAt, copyCount,
               isPinned, isFavorite, isDeleted, tags, characterCount, contentHash
        FROM clips
        WHERE contentHash = ?
        LIMIT 1;
        """

        let statement = try database.prepare(sql)
        defer {
            sqlite3_finalize(statement)
        }

        bindText(contentHash, at: 1, in: statement)

        guard sqlite3_step(statement) == SQLITE_ROW else {
            return nil
        }

        return readClip(from: statement)
    }

    private func updateDuplicate(_ clip: Clip) throws -> Clip {
        let now = Date()
        let sql = """
        UPDATE clips
        SET updatedAt = ?, lastCopiedAt = ?, copyCount = copyCount + 1, isDeleted = 0
        WHERE contentHash = ?;
        """

        let statement = try database.prepare(sql)
        defer {
            sqlite3_finalize(statement)
        }

        sqlite3_bind_double(statement, 1, now.timeIntervalSince1970)
        sqlite3_bind_double(statement, 2, now.timeIntervalSince1970)
        bindText(clip.contentHash, at: 3, in: statement)

        guard sqlite3_step(statement) == SQLITE_DONE else {
            throw ClipStoreError.updateFailed(database.lastErrorMessage)
        }

        var updatedClip = clip
        updatedClip.updatedAt = now
        updatedClip.lastCopiedAt = now
        updatedClip.copyCount += 1
        updatedClip.isDeleted = false
        try removeFromSearchIndex(clipID: updatedClip.id)
        try index(updatedClip)
        return updatedClip
    }

    private func updateBooleanColumn(_ column: String, value: Bool, clipID: UUID) throws {
        let allowedColumns = ["isPinned", "isFavorite"]
        guard allowedColumns.contains(column) else {
            throw ClipStoreError.updateFailed("Unsupported column \(column).")
        }

        let sql = """
        UPDATE clips
        SET \(column) = ?, updatedAt = ?
        WHERE id = ?;
        """

        let statement = try database.prepare(sql)
        defer {
            sqlite3_finalize(statement)
        }

        sqlite3_bind_int(statement, 1, value ? 1 : 0)
        sqlite3_bind_double(statement, 2, Date().timeIntervalSince1970)
        bindText(clipID.uuidString, at: 3, in: statement)

        guard sqlite3_step(statement) == SQLITE_DONE else {
            throw ClipStoreError.updateFailed(database.lastErrorMessage)
        }
    }

    private func rebuildSearchIndex() throws {
        try database.execute("DELETE FROM clip_search;")
        try database.execute("""
        INSERT INTO clip_search (clipID, searchText)
        SELECT id,
               lower(
                   trim(
                       title || ' ' ||
                       plainText || ' ' ||
                       normalizedText || ' ' ||
                       searchText || ' ' ||
                       coalesce(sourceAppName, '') || ' ' ||
                       coalesce(sourceBundleIdentifier, '') || ' ' ||
                       coalesce(url, '') || ' ' ||
                       coalesce(email, '') || ' ' ||
                       coalesce(colorValue, '') || ' ' ||
                       tags
                   )
               )
        FROM clips
        WHERE isDeleted = 0;
        """)
    }

    private func index(_ clip: Clip) throws {
        let sql = """
        INSERT INTO clip_search (clipID, searchText)
        VALUES (?, ?);
        """

        let statement = try database.prepare(sql)
        defer {
            sqlite3_finalize(statement)
        }

        bindText(clip.id.uuidString, at: 1, in: statement)
        bindText(searchIndexText(for: clip), at: 2, in: statement)

        guard sqlite3_step(statement) == SQLITE_DONE else {
            throw ClipStoreError.saveFailed(database.lastErrorMessage)
        }
    }

    private func removeFromSearchIndex(clipID: UUID) throws {
        let sql = """
        DELETE FROM clip_search
        WHERE clipID = ?;
        """

        let statement = try database.prepare(sql)
        defer {
            sqlite3_finalize(statement)
        }

        bindText(clipID.uuidString, at: 1, in: statement)

        guard sqlite3_step(statement) == SQLITE_DONE else {
            throw ClipStoreError.updateFailed(database.lastErrorMessage)
        }
    }

    private func searchIndexText(for clip: Clip) -> String {
        [
            clip.title,
            clip.plainText,
            clip.normalizedText,
            clip.searchText,
            clip.sourceAppName,
            clip.sourceBundleIdentifier,
            clip.url,
            clip.email,
            clip.colorValue,
            clip.tags.joined(separator: " ")
        ]
        .compactMap { $0 }
        .joined(separator: " ")
        .lowercased()
    }

    private func makeFTSQuery(from query: String) -> String? {
        let tokens = query
            .lowercased()
            .split { character in
                character.unicodeScalars.allSatisfy { scalar in
                    !CharacterSet.alphanumerics.contains(scalar)
                }
            }
            .map(String.init)
            .filter { !$0.isEmpty }

        guard !tokens.isEmpty else {
            return nil
        }

        return tokens
            .map { "\($0)*" }
            .joined(separator: " AND ")
    }

    private func bind(_ clip: Clip, to statement: OpaquePointer?) {
        bindText(clip.id.uuidString, at: 1, in: statement)
        bindText(clip.type.rawValue, at: 2, in: statement)
        bindText(clip.title, at: 3, in: statement)
        bindText(clip.plainText, at: 4, in: statement)
        bindText(clip.normalizedText, at: 5, in: statement)
        bindText(clip.searchText, at: 6, in: statement)
        bindText(clip.sourceAppName, at: 7, in: statement)
        bindText(clip.sourceBundleIdentifier, at: 8, in: statement)
        bindText(clip.url, at: 9, in: statement)
        bindText(clip.email, at: 10, in: statement)
        bindText(clip.colorValue, at: 11, in: statement)
        sqlite3_bind_double(statement, 12, clip.createdAt.timeIntervalSince1970)
        sqlite3_bind_double(statement, 13, clip.updatedAt.timeIntervalSince1970)
        sqlite3_bind_double(statement, 14, clip.lastCopiedAt.timeIntervalSince1970)
        sqlite3_bind_int(statement, 15, Int32(clip.copyCount))
        sqlite3_bind_int(statement, 16, clip.isPinned ? 1 : 0)
        sqlite3_bind_int(statement, 17, clip.isFavorite ? 1 : 0)
        sqlite3_bind_int(statement, 18, clip.isDeleted ? 1 : 0)
        bindText(clip.tags.joined(separator: ","), at: 19, in: statement)
        sqlite3_bind_int(statement, 20, Int32(clip.characterCount))
        bindText(clip.contentHash, at: 21, in: statement)
    }

    private func bindText(_ value: String?, at index: Int32, in statement: OpaquePointer?) {
        guard let value else {
            sqlite3_bind_null(statement, index)
            return
        }

        sqlite3_bind_text(statement, index, value, -1, sqliteTransient)
    }

    private func readClip(from statement: OpaquePointer?) -> Clip {
        Clip(
            id: UUID(uuidString: readText(statement, column: 0)) ?? UUID(),
            type: ClipType(rawValue: readText(statement, column: 1)) ?? .text,
            title: readText(statement, column: 2),
            plainText: readText(statement, column: 3),
            normalizedText: readText(statement, column: 4),
            searchText: readText(statement, column: 5),
            sourceAppName: readOptionalText(statement, column: 6),
            sourceBundleIdentifier: readOptionalText(statement, column: 7),
            url: readOptionalText(statement, column: 8),
            email: readOptionalText(statement, column: 9),
            colorValue: readOptionalText(statement, column: 10),
            createdAt: readDate(statement, column: 11),
            updatedAt: readDate(statement, column: 12),
            lastCopiedAt: readDate(statement, column: 13),
            copyCount: Int(sqlite3_column_int(statement, 14)),
            isPinned: sqlite3_column_int(statement, 15) == 1,
            isFavorite: sqlite3_column_int(statement, 16) == 1,
            isDeleted: sqlite3_column_int(statement, 17) == 1,
            tags: readText(statement, column: 18).split(separator: ",").map(String.init),
            characterCount: Int(sqlite3_column_int(statement, 19)),
            contentHash: readText(statement, column: 20)
        )
    }

    private func readText(_ statement: OpaquePointer?, column: Int32) -> String {
        guard let text = sqlite3_column_text(statement, column) else {
            return ""
        }

        return String(cString: text)
    }

    private func readOptionalText(_ statement: OpaquePointer?, column: Int32) -> String? {
        guard sqlite3_column_type(statement, column) != SQLITE_NULL else {
            return nil
        }

        return readText(statement, column: column)
    }

    private func readDate(_ statement: OpaquePointer?, column: Int32) -> Date {
        Date(timeIntervalSince1970: sqlite3_column_double(statement, column))
    }
}
