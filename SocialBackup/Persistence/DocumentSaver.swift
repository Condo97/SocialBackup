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
//        let url = URL.documentsDirectory.appending(path: path)
        let url = FileManager.default.containerURL(forSecurityApplicationGroupIdentifier: Constants.Additional.appGroupName)!.appendingPathComponent(path, conformingTo: .url)
        
        // Get the directory URL by removing the last path component (the file name)
        let directoryURL = url.deletingLastPathComponent()
        
        // Create the directory if it doesn't exist
        try FileManager.default.createDirectory(at: directoryURL, withIntermediateDirectories: true, attributes: nil)
        
        // Write the data to the file
        try data.write(to: url)
    }
    
    static func save(_ image: UIImage, to path: String) throws {
//        let url = URL.documentsDirectory.appending(path: path)
        let url = FileManager.default.containerURL(forSecurityApplicationGroupIdentifier: Constants.Additional.appGroupName)!.appendingPathComponent(path, conformingTo: .url)
        
        // Get the directory URL
        let directoryURL = url.deletingLastPathComponent()
        
        // Create the directory if it doesn't exist
        try FileManager.default.createDirectory(at: directoryURL, withIntermediateDirectories: true, attributes: nil)
        
        // Write the image data to the file
        if let imageData = image.pngData() {
            try imageData.write(to: url)
        } else {
            throw NSError(domain: "DocumentSaverError", code: -1, userInfo: [NSLocalizedDescriptionKey: "Unable to convert image to PNG data."])
        }
    }
    
//    static func saveSecurityScopedFile(from url: URL) throws -> String {
//        let accessing = url.startAccessingSecurityScopedResource()
//        
//        defer {
//            if accessing {
//                url.stopAccessingSecurityScopedResource()
//            }
//        }
//        
//        // Get fileData and fileName
//        let fileData = try Data(contentsOf: url)
//        let filename = url.lastPathComponent
//        
//        // Save to DocumentSaver
//        try DocumentSaver.save(fileData, to: filename)
//        
//        // Return filename
//        return filename
//    }
    
    static func getData(from path: String) throws -> Data? {
//        let url = URL.documentsDirectory.appending(path: path)
        let url = FileManager.default.containerURL(forSecurityApplicationGroupIdentifier: Constants.Additional.appGroupName)!.appendingPathComponent(path, conformingTo: .url)
        
        return try Data(contentsOf: url)
    }
    
    static func getImage(from path: String) throws -> UIImage? {
        if let data = try getData(from: path) {
            return UIImage(data: data)
        }
        
        return nil
    }
    
    static func getFullContainerURL(from path: String) -> URL {
//        URL.documentsDirectory.appending(path: path)
        FileManager.default.containerURL(forSecurityApplicationGroupIdentifier: Constants.Additional.appGroupName)!.appendingPathComponent(path, conformingTo: .url)
    }
    
    static func fileExists(at path: String) -> Bool {
        let url = getFullContainerURL(from: path)
        return FileManager.default.fileExists(atPath: url.path)
    }
    
}
