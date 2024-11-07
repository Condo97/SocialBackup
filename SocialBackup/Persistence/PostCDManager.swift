//
//  PostCDManager.swift
//  SocialBackup
//
//  Created by Alex Coundouriotis on 10/11/24.
//

import CoreData
import Foundation
import UIKit

class PostCDManager {
    
    static func deleteAllMedia(for post: Post, in managedContext: NSManagedObjectContext) async throws {
        let medias = try await getMedia(for: post, in: managedContext)
        try await managedContext.perform {
            for media in medias {
                managedContext.delete(media)
            }
            
            try managedContext.save()
        }
    }
    
    static func getMedia(for post: Post, in managedContext: NSManagedObjectContext) async throws -> [Media] {
        let fetchRequest = Media.fetchRequest()
        fetchRequest.sortDescriptors = [NSSortDescriptor(key: #keyPath(Media.index), ascending: true)]
        fetchRequest.predicate = NSPredicate(format: "%K = %@", #keyPath(Media.post), post)
        return try await managedContext.perform {
            try managedContext.fetch(fetchRequest)
        }
    }
    
    static func savePost(originalURL: String, extractedUsername: String?, title: String?, subdirectory: String?, thumbnailData: Data? = nil, getPostInfoResponse: GetPostInfoResponse?, in managedContext: NSManagedObjectContext) async throws -> Post {
        let getPostInfoResponseData = try CodableDataAdapter.encode(getPostInfoResponse)
        
        return try await managedContext.perform {
            let post = Post(context: managedContext)
            post.originalURL = originalURL
            post.extractedUsername = extractedUsername
            post.title = title
            post.subdirectory = subdirectory
            post.thumbnail = thumbnailData
            post.getPostInfoResponse = getPostInfoResponseData
            post.saveDate = Date()
            post.lastModifyDate = Date()
            
            if let source = getPostInfoResponse?.body.downloadResponse.source {
                post.cachedSource = source
            }
            
            try managedContext.save()
            
            return post
        }
        
//        return try await savePost(
//            originalURL: originalURL,
//            extractedUsername: extractedUsername,
//            title: title,
//            subdirectory: subdirectory,
//            thumbnailData: thumbnailData,
//            getPostInfoResponseData: getPostInfoResponseData,
//            in: managedContext)
    }
    
//    static func savePost(originalURL: String, extractedUsername: String?, title: String?, subdirectory: String?, thumbnailData: Data?, getPostInfoResponseData: Data, in managedContext: NSManagedObjectContext) async throws -> Post {
//        try await managedContext.perform {
//            let post = Post(context: managedContext)
//            post.originalURL = originalURL
//            post.extractedUsername = extractedUsername
//            post.title = title
//            post.subdirectory = subdirectory
//            post.thumbnail = thumbnailData
//            post.getPostInfoResponse = getPostInfoResponseData
//            post.saveDate = Date()
//            post.lastModifyDate = Date()
//            
//            try managedContext.save()
//            
//            return post
//        }
//    }
    
    static func updatePost(_ post: Post, getPostInfoResponse: GetPostInfoResponse, in managedContext: NSManagedObjectContext) async throws {
        let getPostInfoResponseData = try CodableDataAdapter.encode(getPostInfoResponse)
        try await managedContext.perform {
            post.getPostInfoResponse = getPostInfoResponseData
            
            // Update cachedSource as well
            if let source = getPostInfoResponse.body.downloadResponse.source {
                post.cachedSource = source
            }
            
            try managedContext.save()
        }
    }
    
    static func updatePost(_ post: Post, title: String, in managedContext: NSManagedObjectContext) async throws {
        try await managedContext.perform {
            post.title = title
            
            try managedContext.save()
        }
    }
    
    static func updatePost(_ post: Post, subdirectory: String, in managedContext: NSManagedObjectContext) async throws {
        try await managedContext.perform {
            post.subdirectory = subdirectory
            
            try managedContext.save()
        }
    }
    
    static func updatePost(_ post: Post, thumbnailData: Data, in managedContext: NSManagedObjectContext) async throws {
        try await managedContext.perform {
            post.thumbnail = thumbnailData
            
            try managedContext.save()
        }
    }
    
    static func updatePost(_ post: Post, videoSummarySO: VideoSummarySO, in managedContext: NSManagedObjectContext) async throws {
        try await managedContext.perform {
            post.generatedTitle = videoSummarySO.title
            post.generatedTopic = videoSummarySO.topic
            post.generatedShortSummary = videoSummarySO.shortSummary
            post.generatedMediumSummary = videoSummarySO.mediumSummary
            post.generatedEmotionsCSV = videoSummarySO.emotions.joined(separator: ",")
            post.generatedCategoriesCSV = videoSummarySO.categories.joined(separator: ",")
            post.generatedTagsCSV = videoSummarySO.tags.joined(separator: ",")
            post.generatedKeywordsCSV = videoSummarySO.keywords.joined(separator: ",")
            post.generatedKeyEntitiesCSV = videoSummarySO.keyEntities.joined(separator: ",")
            
            try managedContext.save()
        }
    }
    
}
