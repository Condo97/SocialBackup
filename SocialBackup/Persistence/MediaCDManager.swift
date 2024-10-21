//
//  MediaCDManager.swift
//  SocialBackup
//
//  Created by Alex Coundouriotis on 10/12/24.
//

import CoreData
import Foundation

class MediaCDManager {
    
    static func saveMedia(title: String, index: Int64, localFilename: String?, iCloudFilename: String?, to post: Post, in managedContext: NSManagedObjectContext) async throws -> Media {
        try await managedContext.perform {
            let media = Media(context: managedContext)
            media.title = title
            media.index = index
            media.localFilename = localFilename
            media.iCloudFilename = iCloudFilename
            media.post = post
            
            try managedContext.save()
            
            return media
        }
    }
    
    static func updateMedia(_ media: Media, iCloudFilepath: String?, in managedContext: NSManagedObjectContext) async throws {
        try await managedContext.perform {
            media.iCloudFilename = iCloudFilepath
            
            try managedContext.save()
        }
    }
    
    static func updateMedia(_ media: Media, transcription: String?, in managedContext: NSManagedObjectContext) async throws {
        try await managedContext.perform {
            media.transcription = transcription
            
            try managedContext.save()
        }
    }
    
}
