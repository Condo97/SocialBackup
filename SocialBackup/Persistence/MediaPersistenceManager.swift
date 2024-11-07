//
//  MediaPersistenceManager.swift
//  SocialBackup
//
//  Created by Alex Coundouriotis on 10/20/24.
//

import CoreData
import Foundation

class MediaPersistenceManager {
    
    static func backupToICloud(media: Media, mediaICloudUploadUpdater: MediaICloudUploadUpdater, in managedContext: NSManagedObjectContext) async throws {
        guard let localFilename = media.localFilename,
              let localSubdirectory = media.post?.subdirectory else {
            print("Could not unwrap local filename or local subdirectory in PostPersistenceManager!")
            return
        }
        
        let localFilepath = "\(localSubdirectory)/\(localFilename)"
        
        guard let localFile = try DocumentSaver.getData(from: localFilepath) else {
            print("Could not unwrap local media file in PostPersistenceManager!")
            return
        }
        
        // Handle iCloud backup if available and applicable
        if FileManager.default.ubiquityIdentityToken != nil /* is icloud available? */ {
            // Start auto-syncing
            try await mediaICloudUploadUpdater.backupMediaToICloud(mediaData: localFile, filepath: localFilepath)
            try await MediaCDManager.updateMedia(media, iCloudFilename: localFilename, in: managedContext)
        }
    }
    
    static func downloadFromExternalURL(media: Media, postSubdirectory: String, in managedContext: NSManagedObjectContext) async throws {
        // Ensure unwrap externalURL, otherwise throw
        guard let externalURL = media.externalURL else {
            print("Could not unwrap externalURL in MediaPersistenceManager!")
            throw MediaPersistenceManagerError.missingExternalURL
        }
        
        // Download the post data
        let (data, response) = try await URLSession.shared.data(from: externalURL)
        
        // Get the suggested filename from the response
        let suggestedFilename = response.suggestedFilename ?? externalURL.lastPathComponent
        let fileExtension = (suggestedFilename as NSString).pathExtension
        
        // Set the filename and filepath
        let filename = suggestedFilename
        let filepath = "\(postSubdirectory)/\(filename)"
        
        // Save to container
        try DocumentSaver.save(data, to: filepath)
        
        // Update media
        try await MediaCDManager.updateMedia(media, localFilename: filename, in: managedContext)
    }
    
//    static func downloadSaveMedia(url: URL, index: Int, postDocumentsSubdirectory: String, to post: Post, in managedContext: NSManagedObjectContext) async throws -> Media {
//        // Download the post data
//        let (data, response) = try await URLSession.shared.data(from: url)
//        
//        // Get the suggested filename from the response
//        let suggestedFilename = response.suggestedFilename ?? url.lastPathComponent
//        let fileExtension = (suggestedFilename as NSString).pathExtension
//        
//        // Set the filepath
//        let filepath = "\(postDocumentsSubdirectory)/\(suggestedFilename)"
//        
//        // Save file to Documents
//        
//        try DocumentSaver.save(data, to: filepath)
//        
//        // Save media
//        let media = try await MediaCDManager.saveMedia(
//            title: suggestedFilename,
//            index: Int64(index),
//            localFilename: suggestedFilename,
//            iCloudFilename: nil,
//            to: post,
//            in: managedContext)
//        
//        return media
//    }
    
}

enum MediaPersistenceManagerError: Error {
    case missingExternalURL
}
