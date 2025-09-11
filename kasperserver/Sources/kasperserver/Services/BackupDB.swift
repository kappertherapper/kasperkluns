import Foundation
import Vapor

struct DatabaseBackup {
    static func backup(on app: Application) {
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "yyyy-MM-dd_HH-mm-ss"
        let dateString = dateFormatter.string(from: Date())
        
        let backupFolder = "/Users/kasperjonassen/Desktop/kasperkluns/backupsDB/"
        let backupPath = backupFolder + "db_backup_\(dateString).sql"

        let fileManager = FileManager.default

        // Create folder if it doesn't exist
        if !fileManager.fileExists(atPath: backupFolder) {
            try? fileManager.createDirectory(atPath: backupFolder, withIntermediateDirectories: true)
        }

        // Create empty file
        if !fileManager.fileExists(atPath: backupPath) {
            fileManager.createFile(atPath: backupPath, contents: nil, attributes: nil)
        }

        guard
            let dbName = Environment.get("DATABASE_NAME"),
            let username = Environment.get("DATABASE_USERNAME"),
            let password = Environment.get("DATABASE_PASSWORD")
        else {
            app.logger.error("Missing DATABASE environment variables")
            return
        }
        
        let host = Environment.get("DATABASE_HOST") ?? "localhost"
        let port = Environment.get("DATABASE_PORT") ?? "5432"

        let task = Process()
        task.executableURL = URL(fileURLWithPath: "/opt/homebrew/bin/pg_dump")
        task.arguments = ["-U", username, "-h", host, "-p", port, dbName]
        task.environment = ["PGPASSWORD": password]

        let outputFileHandle = try! FileHandle(forWritingTo: URL(fileURLWithPath: backupPath))
        task.standardOutput = outputFileHandle
        let pipe = Pipe()
        task.standardError = pipe

        do {
            try task.run()
            task.waitUntilExit()

            let errorData = pipe.fileHandleForReading.readDataToEndOfFile()
            if let errorString = String(data: errorData, encoding: .utf8), !errorString.isEmpty {
                app.logger.error("pg_dump error: \(errorString)")
            }

            app.logger.info("Backup completed at: \(backupPath)")
        } catch {
            app.logger.error("Backup failed: \(error.localizedDescription)")
        }
    }
}
