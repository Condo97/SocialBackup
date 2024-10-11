//
//  VideoICloudUploadUpdater.swift
//  SocialBackup
//
//  Created by Alex Coundouriotis on 10/11/24.
//

import Foundation

class VideoICloudUploadUpdater: ObservableObject {
    
    @Published private(set) var uploadingFilenames: [String] = []
    
//    // Backup video to iCloud
//    func backupVideoToICloud(localURL: URL) async throws -> URL? {
//        // Defer removing local URL from uploadingLocalVideoURLs
//        defer {
//            DispatchQueue.main.async { [self] in
//                uploadingLocalVideoURLs.removeAll(where: { $0 == localURL })
//            }
//        }
//        
//        // Append localURL to uploadingLocalVideoURLs
//        await MainActor.run {
//            uploadingLocalVideoURLs.append(localURL)
//        }
//        
//        let videoData = try VideoPersistenceManager.getLocalVideoData(for: localURL)
//        let filename = localURL.lastPathComponent
//        return try await backupVideoToICloud(
//            videoData: videoData,
//            filename: filename)
//    }
    
    func backupVideoToICloud(videoData: Data, filename: String) async throws {
        // Defer removing local URL from uploadingFilenames
        defer {
            DispatchQueue.main.async { [self] in
                uploadingFilenames.removeAll(where: { $0 == filename })
            }
        }
        
        // Append localURL to uploadingFilenames
        await MainActor.run {
            uploadingFilenames.append(filename)
        }
        
        // Ensure unwrap iCloudContainerURL, otherwise return
        guard let iCloudContainerURL = FileManager.default.url(forUbiquityContainerIdentifier: nil)?.appendingPathComponent("Documents/Videos") else {
            throw VideoICloudUploadUpdaterError.iCloudError
        }
        
        // Ensure the iCloud Videos directory exists
        if !FileManager.default.fileExists(atPath: iCloudContainerURL.path) {
            try FileManager.default.createDirectory(at: iCloudContainerURL, withIntermediateDirectories: true, attributes: nil)
        }
        
        let destinationURL = iCloudContainerURL.appendingPathComponent(filename)
        
        try await CloudDocumentsHandler().write(
            targetURL: destinationURL,
            data: videoData)
        
//        do {
//            // Remove existing file if it exists
//            if FileManager.default.fileExists(atPath: destinationURL.path) {
//                try FileManager.default.removeItem(at: destinationURL)
//            }
//            
//            // Copy the file to iCloud
//            return await MainActor.run {
//                do {
//                    try FileManager.default.setUbiquitous(true, itemAt: localURL, destinationURL: destinationURL)
//                    return destinationURL
//                } catch {
//                    print("Error copying file to iCloud... \(error)")
//                    return nil
//                }
//            }
//        } catch {
//            print("Error backing up video to iCloud... \(error)")
//            return nil
//        }
    }
    
}
