//
//  MediaICloudUploadUpdater.swift
//  SocialBackup
//
//  Created by Alex Coundouriotis on 10/11/24.
//

import Foundation

class MediaICloudUploadUpdater: ObservableObject {
    
    @Published private(set) var uploadingFilenames: [String] = []
    
    func backupMediaToICloud(mediaData: Data, filepath: String) async throws {
        // Defer removing local URL from uploadingFilenames
        defer {
            DispatchQueue.main.async { [self] in
                uploadingFilenames.removeAll(where: { $0 == filepath })
            }
        }
        
        // Append localURL to uploadingFilenames
        await MainActor.run {
            uploadingFilenames.append(filepath)
        }
        
        // Ensure unwrap iCloudContainerURL, otherwise return
        guard let iCloudContainerURL = FileManager.default.url(forUbiquityContainerIdentifier: nil)?.appendingPathComponent("Documents/Posts") else {
            throw PostICloudUploadUpdaterError.iCloudError
        }
        
        // Ensure the iCloud Posts directory exists
        if !FileManager.default.fileExists(atPath: iCloudContainerURL.path) {
            try FileManager.default.createDirectory(at: iCloudContainerURL, withIntermediateDirectories: true, attributes: nil)
        }
        
        let destinationURL = iCloudContainerURL.appendingPathComponent(filepath)
        
        try await CloudDocumentsHandler().write(
            targetURL: destinationURL,
            data: mediaData)
    }
    
}
