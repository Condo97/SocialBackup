//
//  PostDownloaderAndSaverAndBackuper.swift
//  SocialBackup
//
//  Created by Alex Coundouriotis on 10/11/24.
//

import CoreData
import Foundation

class PostDownloaderAndSaverAndBackuper {
    
    private let postPersistenceManager = PostPersistenceManager()
    
    func downloadAndSave(fromURLString urlString: String, authToken: String, mediaICloudUploadUpdater: MediaICloudUploadUpdater, in viewContext: NSManagedObjectContext) async throws -> Post? {
        // Get post info
        let postInfo = try await TikTokServerConnector().getPostInfo(request: GetPostInfoRequest(authToken: authToken, postURL: urlString))
        
        // Save post
        let post = try await postPersistenceManager.downloadAndSavePost(
            getPostInfoResponse: postInfo,
            mediaICloudUploadUpdater: mediaICloudUploadUpdater,
            in: viewContext)
        
        // Backup
        Task {
            let fetchRequest = Media.fetchRequest()
            fetchRequest.predicate = NSPredicate(format: "%K = %@", #keyPath(Media.post), post)
            let medias = try await viewContext.perform { try viewContext.fetch(fetchRequest) }
            for media in medias {
                do {
                    try await MediaPersistenceManager.backupToICloud(
                        media: media,
                        mediaICloudUploadUpdater: mediaICloudUploadUpdater,
                        in: viewContext)
                } catch {
                    // TODO: Handle Errors
                    print("Error backing up media to iCloud in PostDownloaderAndSaverAndBackuper... \(error)")
                }
            }
        }
        
        // Get transcription for each media in a task
        Task {
            do {
                try await updateMissingTranscriptions(for: post, in: viewContext)
            } catch {
                // TODO: Handle Errors
                print("Error updating missing transcriptions in PostDownloaderAndSaverAndBackuper... \(error)")
            }
        }
        
        
        // Return post
        return post
    }
    
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
