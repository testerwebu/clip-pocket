import Foundation
import SQLite3

enum SQLiteDatabaseError: LocalizedError {
    case applicationSupportUnavailable
    case openFailed(String)
    case executeFailed(String)
    case prepareFailed(String)

    var errorDescription: String? {
        switch self {
        case .applicationSupportUnavailable:
            return "Application Support directory is unavailable."
        case .openFailed(let message):
            return "Could not open SQLite database: \(message)"
        case .executeFailed(let message):
            return "SQLite execution failed: \(message)"
        case .prepareFailed(let message):
            return "SQLite prepare failed: \(message)"
        }
    }
}

final class SQLiteDatabase {
    let fileURL: URL

    private var connection: OpaquePointer?

    init(fileURL: URL) throws {
        self.fileURL = fileURL

        if sqlite3_open(fileURL.path, &connection) != SQLITE_OK {
            let message = SQLiteDatabase.message(from: connection)
            sqlite3_close(connection)
            throw SQLiteDatabaseError.openFailed(message)
        }

        try execute("PRAGMA foreign_keys = ON;")
        try execute("PRAGMA journal_mode = WAL;")
    }

    deinit {
        sqlite3_close(connection)
    }

    static func defaultFileURL() throws -> URL {
        guard let applicationSupportURL = FileManager.default.urls(for: .applicationSupportDirectory, in: .userDomainMask).first else {
            throw SQLiteDatabaseError.applicationSupportUnavailable
        }

        let directoryURL = applicationSupportURL.appendingPathComponent("ClipPocket", isDirectory: true)
        try FileManager.default.createDirectory(at: directoryURL, withIntermediateDirectories: true)

        return directoryURL.appendingPathComponent("ClipPocket.sqlite")
    }

    func execute(_ sql: String) throws {
        guard sqlite3_exec(connection, sql, nil, nil, nil) == SQLITE_OK else {
            throw SQLiteDatabaseError.executeFailed(lastErrorMessage)
        }
    }

    func prepare(_ sql: String) throws -> OpaquePointer? {
        var statement: OpaquePointer?

        guard sqlite3_prepare_v2(connection, sql, -1, &statement, nil) == SQLITE_OK else {
            throw SQLiteDatabaseError.prepareFailed(lastErrorMessage)
        }

        return statement
    }

    var lastErrorMessage: String {
        SQLiteDatabase.message(from: connection)
    }

    private static func message(from connection: OpaquePointer?) -> String {
        guard let error = sqlite3_errmsg(connection) else {
            return "Unknown SQLite error."
        }

        return String(cString: error)
    }
}
