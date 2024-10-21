//
//  PostCollectionCDManager.swift
//  SocialBackup
//
//  Created by Alex Coundouriotis on 10/11/24.
//

import CoreData
import Foundation

class PostCollectionCDManager {
    
    static func savePostCollection(title: String, in managedContext: NSManagedObjectContext) async throws -> PostCollection {
        try await managedContext.perform {
            let postCollection = PostCollection(context: managedContext)
            postCollection.title = title
            postCollection.creationDate = Date()
            postCollection.lastModifyDate = Date()
            
            try managedContext.save()
            
            return postCollection
        }
    }
    
    static func addPost(_ post: Post, to postCollection: PostCollection, in managedContext: NSManagedObjectContext) async throws {
        try await managedContext.perform {
            // Ensure PostCollection does not contain Post and add to postCollection, otherwise throw duplicatePost
            guard !(postCollection.posts?.contains(post) ?? false) else {
                throw PostCollectionCDManagerError.duplicatePost
            }
            
            postCollection.addToPosts(post)
            
            try managedContext.save()
        }
    }
    
}
