//
//  CloudDocumentsHandler.swift
//  SocialBackup
//
//  Created by Alex Coundouriotis on 10/11/24.
//
// https://fatbobman.com/en/posts/in-depth-guide-to-icloud-documents/

import Foundation

actor CloudDocumentsHandler {
    
    let coordinator = NSFileCoordinator()

    func write(targetURL: URL, data: Data) throws {
        // Ensure the directory exists
        let directoryURL = targetURL.deletingLastPathComponent()
        if !FileManager.default.fileExists(atPath: directoryURL.path) {
            try FileManager.default.createDirectory(at: directoryURL, withIntermediateDirectories: true, attributes: nil)
        }
        
        var coordinationError: NSError?
        var writeError: Error?

        // Use the coordinationError variable to capture the error information of the coordinate method.
        // If an NSError pointer is not provided, errors occurring during the coordination process will not be caught and handled.
        coordinator.coordinate(writingItemAt: targetURL, options: [.forDeleting], error: &coordinationError) { url in
            do {
                try data.write(to: url, options: .atomic)
            } catch {
                writeError = error
            }
        }

        // Check outside the closure to see if an error occurred
        if let error = writeError {
            throw error
        }

        // Check if an error occurred during reconciliation
        if let coordinationError = coordinationError {
            throw coordinationError
        }
    }
    
    func read(url: URL) throws -> Data {
        var coordinationError: NSError?
        var readData: Data?
        var readError: Error?

        coordinator.coordinate(readingItemAt: url, options: [], error: &coordinationError) { url in
            do {
                readData = try Data(contentsOf: url)
            } catch {
                readError = error
            }
        }

        if let error = readError {
            throw error
        }

        if let coordinationError = coordinationError {
            throw coordinationError
        }

        // Make sure the data read is not empty
        guard let data = readData else {
            throw NSError(domain: "CloudDocumentsHandlerError", code: 0, userInfo: [NSLocalizedDescriptionKey: "No data was read from the file."])
        }

        return data
    }
    
}
