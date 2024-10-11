//
//  DocumentsPersistenceManager.swift
//  WriteSmith-SwiftUI
//
//  Created by Alex Coundouriotis on 3/30/24.
//

import Foundation
import UIKit

class DocumentSaver {
    
    static func save(_ data: Data, to path: String) throws {
        let url = URL.documentsDirectory.appending(path: path)
        
        try data.write(to: url)
    }
    
    static func save(_ image: UIImage, to path: String) throws {
        let url = URL.documentsDirectory.appending(path: path)
        
        try image.pngData()?.write(to: url)
    }
    
    static func saveSecurityScopedFileToDocumentsDirectory(from url: URL) throws -> String {
        let accessing = url.startAccessingSecurityScopedResource()
        
        defer {
            if accessing {
                url.stopAccessingSecurityScopedResource()
            }
        }
        
        // Get fileData and fileName
        let fileData = try Data(contentsOf: url)
        let filename = url.lastPathComponent
        
        // Save to DocumentSaver
        try DocumentSaver.save(fileData, to: filename)
        
        // Return filename
        return filename
    }
    
    static func getData(from path: String) throws -> Data? {
        let url = URL.documentsDirectory.appending(path: path)
        
        return try Data(contentsOf: url)
    }
    
    static func getImage(from path: String) throws -> UIImage? {
        if let data = try getData(from: path) {
            return UIImage(data: data)
        }
        
        return nil
    }
    
    static func getFullDocumentsURL(from path: String) -> URL {
        URL.documentsDirectory.appending(path: path)
    }
    
    
}
