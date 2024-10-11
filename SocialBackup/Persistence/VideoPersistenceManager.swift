//
//  VideoPersistenceManager.swift
//  SocialBackup
//
//  Created by Alex Coundouriotis on 10/11/24.
//

import SwiftUI
import CoreData

class VideoPersistenceManager: ObservableObject {
    
    // Check if iCloud is available
    static var isICloudAvailable: Bool {
        FileManager.default.ubiquityIdentityToken != nil
    }
    
    // User Preferences
    @AppStorage("autoSyncEnabled") static var autoSyncEnabled: Bool = false
    
    // Download and save video
    static func downloadAndSaveVideo(from url: URL, thumbnailData: Data?, getVideoInfoResponse: GetVideoInfoResponse, videoICloudUploadUpdater: VideoICloudUploadUpdater, in managedContext: NSManagedObjectContext) async throws -> Video {
        // Download the video data
        let (data, response) = try await URLSession.shared.data(from: url)
        
        // Get the suggested filename from the response
        let suggestedFilename = response.suggestedFilename ?? url.lastPathComponent
        let fileExtension = (suggestedFilename as NSString).pathExtension
        
        // Create a unique filename
        let uniqueID = UUID()
        let filename = "\(uniqueID).\(fileExtension)"
        
        // Save file to Documents
        try DocumentSaver.save(data, to: filename)
        
        // Create a new Video object in Core Data
        let video = try await VideoCDManager.saveVideo(
            title: suggestedFilename,
            thumbnailData: thumbnailData,
            getVideoInfoResponse: getVideoInfoResponse,
            localFilename: filename,
            iCloudFilename: nil,
            in: managedContext)
        
        // Handle iCloud backup if available and applicable
        if isICloudAvailable {
            if autoSyncEnabled {
                // Start auto-syncing
                try await videoICloudUploadUpdater.backupVideoToICloud(videoData: data, filename: filename)
                try await VideoCDManager.updateVideo(video, iCloudFilename: filename, in: managedContext)
            } else {
                // User has iCloud but auto-sync is off; still upload the video when downloaded
                try await videoICloudUploadUpdater.backupVideoToICloud(videoData: data, filename: filename)
                try await VideoCDManager.updateVideo(video, iCloudFilename: filename, in: managedContext)
            }
        }
        
        return video
    }
    
//    static func copyVideoFromICloudToLocal(iCloudURL: URL) async throws -> URL {
//        let data = try await CloudDocumentsHandler().read(url: iCloudURL)
//        
//        return try VideoPersistenceManager.saveVideoLocally(
//            data: data,
//            filename: iCloudURL.lastPathComponent)
//    }
    
//    // Save video locally
//    private static func saveVideoLocally(data: Data, filename: String) throws {
//        guard let documentsURL = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask).first else {
//            throw NSError(domain: "VideoManager", code: 1, userInfo: [NSLocalizedDescriptionKey: "Could not access documents directory"])
//        }
//        let videosDirectory = documentsURL.appendingPathComponent("Videos")
//        
//        // Create the Videos directory if it doesn't exist
//        if !FileManager.default.fileExists(atPath: videosDirectory.path) {
//            try FileManager.default.createDirectory(at: videosDirectory, withIntermediateDirectories: true, attributes: nil)
//        }
//        
//        let fileURL = videosDirectory.appendingPathComponent(filename)
//        try data.write(to: fileURL)
//        return fileURL
//    }
//    
//    // Get video locally
//    static func getLocalVideoData(for localURL: URL) throws -> Data {
//        let fileManager = FileManager.default
//        if fileManager.fileExists(atPath: localURL.path) {
//            return try Data(contentsOf: localURL)
//        } else {
//            throw NSError(domain: "VideoManager", code: 3, userInfo: [NSLocalizedDescriptionKey: "Video file not found at the local URL"])
//        }
//    }
    
}
