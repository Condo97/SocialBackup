//
//  MediaCDManager.swift
//  SocialBackup
//
//  Created by Alex Coundouriotis on 10/12/24.
//

import CoreData
import Foundation

class MediaCDManager {
    
    static func getMedia(for post: Post, in managedContext: NSManagedObjectContext) async throws -> [Media] {
        try await managedContext.perform {
            let fetchRequest = Media.fetchRequest()
            fetchRequest.sortDescriptors = [NSSortDescriptor(key: #keyPath(Media.index), ascending: true)]
            fetchRequest.predicate = NSPredicate(format: "%K = %@", #keyPath(Media.post), post)
            return try managedContext.fetch(fetchRequest)
        }
    }
    
    static func saveMedia(downloadURL: URL, index: Int64, to post: Post, in managedContext: NSManagedObjectContext) async throws -> Media {
        try await managedContext.perform {
            let media = Media(context: managedContext)
            media.externalURL = downloadURL
            media.index = index
            media.post = post
            
            try managedContext.save()
            
            return media
        }
    }
    
    static func saveMedia(downloadURL: URL, title: String, index: Int64, localFilename: String?, iCloudFilename: String?, to post: Post, in managedContext: NSManagedObjectContext) async throws -> Media {
        try await managedContext.perform {
            let media = Media(context: managedContext)
            media.externalURL = downloadURL
            media.title = title
            media.index = index
            media.localFilename = localFilename
            media.iCloudFilename = iCloudFilename
            media.post = post
            
            try managedContext.save()
            
            return media
        }
    }
    
    static func updateMedia(_ media: Media, iCloudFilename: String?, in managedContext: NSManagedObjectContext) async throws {
        try await managedContext.perform {
            media.iCloudFilename = iCloudFilename
            
            try managedContext.save()
        }
    }
    
    static func updateMedia(_ media: Media, localFilename: String?, in managedContext: NSManagedObjectContext) async throws {
        try await managedContext.perform {
            media.localFilename = localFilename
            
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
