//
//  PostDownloaderAndSaverAndBackuper.swift
//  SocialBackup
//
//  Created by Alex Coundouriotis on 10/11/24.
//

import CoreData
import Foundation

// Steps to download and save post
// 1. Create post with original url
// 2. Get post info from Post (if not existant or corrupt)
// 3. Redownload post media
// 4. Backup to iCloud (if enabled)
// 5. Update missing transcriptions

// New CreateAndDownload flow:
// 1. GetPostInfoResponse is downloaded
// 2. Post is created with GetPostInfoResponse
//* 3. Media is created with all the URLs that are not duplicates (auto-checks for duplicates in PostPersistenceManager)
// 4. Download undownloaded media, skipping broken links
// 5. Backup to iCloud task start
// 6. Update missing transcriptions task start

// New Repair flow:
// 1. Ensure unwrap post info
//  1b. If the post info is nonexistant, start from step 2 above
// 2. Media is created with all the URLs that are not duplicates (auto-checks for duplicates in PostPersistenceManager) ... And it just continues the same way, because normally it always checks for duplicates

// Needs to check
// 1. If the post info is nonexistant, start from step 2
// 2. If the post is missing media or it is corrupt, start from step 3

// Entry points
// CreateAndDownload - Step 1, if the post is fresh
// Repair - Step 2 or 3 to be determined by if the post info is nonexistant of if the post is missing media or it is corrupt, if the post is existant
// Redownload - Step 2


class PostDownloaderAndSaverAndBackuper: ObservableObject {
    
    @Published var repairInProgress: [ObjectIdentifier] = []
    
    private let postPersistenceManager = PostPersistenceManager()
    
    // Steps 1-5
    func createAndDownload(
        urlString: String,
        authToken: String,
        mediaICloudUploadUpdater: MediaICloudUploadUpdater,
        in managedContext: NSManagedObjectContext
    ) async throws -> Post? {
        // Step 1
        guard let post = try await stepOne_CreatePostWithOriginalURL(urlString: urlString, in: managedContext) else {
            // TODO: Handle Errors
            print("Could not unwrap post after step one creating with original URL in PostDownloaderAndSaverAndBackuper!")
            return nil
        }
        
        do {
            // Shortcut steps 2-6 with repair
            try await
            repair(
                post: post,
                authToken: authToken,
                mediaICloudUploadUpdater: mediaICloudUploadUpdater,
                in: managedContext)
        } catch {
            // If there was an error repairing the post delete the post in CoreData and throw error
            try await managedContext.perform {
                managedContext.delete(post)
                
                try managedContext.save()
            }
            
            throw error
        }
//        // Step 2
//        try await stepTwo_GetUpdatePostInfoInPost(post, authToken: authToken, in: managedContext)
//        
//        // Step 3
//        try await stepThree_InsertMissingMediaShells(post, in: managedContext)
//        
//        // Step 4
//        try await stepFour_DownloadMissingMedia(post, authToken: authToken, in: managedContext)
//        
//        // Step 5
//        try await stepFive_BackupToICloudIfNonexistantInICloud(post, mediaICloudUploadUpdater: mediaICloudUploadUpdater, in: managedContext)
//        
//        // Step 6
//        try await stepSix_UpdateMissingTranscriptions(post, in: managedContext)
        
        // Return post
        return post
    }
    
    // Steps 2- or 3-5
    func repair(
        post: Post,
        authToken: String,
        mediaICloudUploadUpdater: MediaICloudUploadUpdater,
        in managedContext: NSManagedObjectContext
    ) async throws {
        defer {
            DispatchQueue.main.async { [self] in
                repairInProgress.removeAll(where: {$0 == post.id})
            }
        }
        
        await MainActor.run {
            repairInProgress.append(post.id)
        }
        
        /* Diagnose */
        
        // Variables for diagnosing repair
        let hasPostInfo: Bool
        
        // Check post for post info
        do {
            let postInfo = try post.getGetPostInfoResponseObject()
            hasPostInfo = postInfo != nil
        } catch {
            print("Error getting getPostInfoResponse in PostDownloaderAndSaverAndBackuper, continuing... \(error)")
            hasPostInfo = false
        }
        
        /* Begin */
        
        // If does not have post info, get update post info in post which is step 2
        if !hasPostInfo {
            try await stepTwo_GetUpdatePostInfoInPost(post, authToken: authToken, in: managedContext)
        }
        
        // Insert media shells, step 3
        try await stepThree_InsertMissingMediaShells(post, in: managedContext)
        
        // Download missing media, step 4
        try await stepFour_DownloadMissingMedia(post, authToken: authToken, in: managedContext)
        
        // Backup to iCloud, step 5
        try await stepFive_BackupToICloudIfNonexistantInICloud(post, mediaICloudUploadUpdater: mediaICloudUploadUpdater, in: managedContext)
        
        // Update missing transactions, step 6
        try await stepSix_UpdateMissingTranscriptions(post, in: managedContext)
    }
    
    
    func stepOne_CreatePostWithOriginalURL(urlString: String, in managedContext: NSManagedObjectContext) async throws -> Post? {
        // Extract username from url
        let extractedUsername = URLUsernameExtractor.extractUsername(from: urlString)
        
        // Create post with originalURL
        let post = try await PostCDManager.savePost(
            originalURL: urlString,
            extractedUsername: extractedUsername,
            title: nil,
            subdirectory: nil,
            getPostInfoResponse: nil,
            in: managedContext)
        
        return post
    }
    
    func stepTwo_GetUpdatePostInfoInPost(_ post: Post, authToken: String, in managedContext: NSManagedObjectContext) async throws {
        guard let urlString = post.originalURL else {
            // TODO: Handle Errors
            print("Could not unwrap originalURL in PostDownloaderAndSaverAndBackuper!")
            throw PostDownloaderAndSaverAndBackuperError.missingOriginalURL
        }
        
        // Get post info
        let postInfo = try await TikTokServerConnector().getPostInfo(request: GetPostInfoRequest(authToken: authToken, postURL: urlString))
        
        // Update post info
        try await PostCDManager.updatePost(post, getPostInfoResponse: postInfo, in: managedContext)
    }
    
    func stepThree_InsertMissingMediaShells(_ post: Post, in managedContext: NSManagedObjectContext) async throws {
        try await postPersistenceManager.createMediaShells(for: post, in: managedContext)
    }
    
    func stepFour_DownloadMissingMedia(_ post: Post, authToken: String, in managedContext: NSManagedObjectContext) async throws {
        try await postPersistenceManager.downloadMissingMedia(post, in: managedContext)
    }
    
    func stepFive_BackupToICloudIfNonexistantInICloud(_ post: Post, mediaICloudUploadUpdater: MediaICloudUploadUpdater, in managedContext: NSManagedObjectContext) async throws {
        // Ensure unwrap subdirectory, otherwise throw missingSubdirectory
        guard let subdirectory = post.subdirectory else {
            throw PostDownloaderAndSaverAndBackuperError.missingSubdirectory
        }
        
        let fetchRequest = Media.fetchRequest()
        fetchRequest.predicate = NSPredicate(format: "%K = %@", #keyPath(Media.post), post)
        let medias = try await managedContext.perform { try managedContext.fetch(fetchRequest) }
        for media in medias {
            // Determine if shouldBackup
            var shouldBackup: Bool
            
            // If iCloudFilename is not nil and its file exists set shouldBakup to false, otherwise set to true
            if let iCloudFilename = media.iCloudFilename {
                guard let localFilename = media.localFilename else {
                    // TODO: Handle Errors
                    print("Could not unwrap localFilename in PostDownloaderAndSaverAndBackuper, continuing!")
                    continue
                }
                
                let filepath = "\(subdirectory)/\(localFilename)"
                guard let iCloudURL = await CloudDocumentsHandler().getFullICloudPostsContainerURL(filepath: filepath) else {
                    continue
                }
                
                if await CloudDocumentsHandler().fileExists(at: iCloudURL) {
                    // Filepath and file exist
                    shouldBackup = false
                } else {
                    // Filepath exists but file does not
                    shouldBackup = true
                }
            } else {
                // Filepath does not exist
                shouldBackup = true
            }
            
            if shouldBackup {
                do {
                    try await MediaPersistenceManager.backupToICloud(
                        media: media,
                        mediaICloudUploadUpdater: mediaICloudUploadUpdater,
                        in: managedContext)
                } catch {
                    // TODO: Handle Errors
                    print("Error backing up media to iCloud in PostDownloaderAndSaverAndBackuper... \(error)")
                }
            }
        }
    }
    
    func stepSix_UpdateMissingTranscriptions(_ post: Post, in managedContext: NSManagedObjectContext) async throws {
        try await updateMissingTranscriptions(for: post, in: managedContext)
    }
    
//    func downloadAndSave(fromURLString urlString: String, authToken: String, mediaICloudUploadUpdater: MediaICloudUploadUpdater, in managedContext: NSManagedObjectContext) async throws -> Post? {
//        // Create post with originalURL
//        let post = try await PostCDManager.savePost(
//            originalURL: urlString,
//            title: nil,
//            subdirectory: nil,
//            getPostInfoResponse: nil,
//            in: managedContext)
//        
//        // Get post info
//        let postInfo = try await TikTokServerConnector().getPostInfo(request: GetPostInfoRequest(authToken: authToken, postURL: urlString))
//        
//        // Update post info
//        try await PostCDManager.updatePost(post, getPostInfoResponse: postInfo, in: managedContext)
//        
//        // Save post
//        let post = try await postPersistenceManager.downloadAndSavePost(
//            getPostInfoResponse: postInfo,
//            mediaICloudUploadUpdater: mediaICloudUploadUpdater,
//            in: managedContext)
//        
//        // Backup
//        Task {
//            let fetchRequest = Media.fetchRequest()
//            fetchRequest.predicate = NSPredicate(format: "%K = %@", #keyPath(Media.post), post)
//            let medias = try await managedContext.perform { try managedContext.fetch(fetchRequest) }
//            for media in medias {
//                do {
//                    try await MediaPersistenceManager.backupToICloud(
//                        media: media,
//                        mediaICloudUploadUpdater: mediaICloudUploadUpdater,
//                        in: managedContext)
//                } catch {
//                    // TODO: Handle Errors
//                    print("Error backing up media to iCloud in PostDownloaderAndSaverAndBackuper... \(error)")
//                }
//            }
//        }
//        
//        // Get transcription for each media in a task
//        Task {
//            do {
//                try await updateMissingTranscriptions(for: post, in: managedContext)
//            } catch {
//                // TODO: Handle Errors
//                print("Error updating missing transcriptions in PostDownloaderAndSaverAndBackuper... \(error)")
//            }
//        }
//        
//        
//        // Return post
//        return post
//    }
    
    func updateMissingTranscriptions(for post: Post, in managedContext: NSManagedObjectContext) async throws {
        let fetchRequest = Media.fetchRequest()
        fetchRequest.predicate = NSPredicate(format: "%K = %@", #keyPath(Media.post), post)
        let medias = try await managedContext.perform { try managedContext.fetch(fetchRequest) }
        DispatchQueue.main.async {
            for media in medias {
                // Ensure media does not have transcription, otherwise continue
                guard media.transcription == nil else { continue }
                
                // Set postAudioTranscriber TODO: Make sure this doesn't need a stronger reference
                let mediaAudioTranscriber = MediaAudioTranscriber.shared//(media: media, managedContext: managedContext)
                
                // Start a task to update the media's transcription
                mediaAudioTranscriber.addTranscriptionRequest(media: media, managedContext: managedContext)
//                do {
//                } catch {
//                    // TODO: Handle Errors
//                    print("Error updating transaction in PostPersistenceManager... \(error)")
//                }
            }
        }
    }
    
}

enum PostDownloaderAndSaverAndBackuperError: Error {
    case missingOriginalURL
    case missingSubdirectory
}
