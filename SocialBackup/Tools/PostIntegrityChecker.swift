////
////  PostIntegrityChecker.swift
////  SocialBackup
////
////  Created by Your Name on 10/21/24.
////
//
//import CoreData
//import UIKit
//import AVFoundation
//
//// TODO: What will happen if the user opens the app, PostIntegrityCheckrer is called, and there is a link that leads to nothing? This could happen! In this case PostIntegrityChecker would try every time, deleting and attempting to redownload the media. Really the Post should, as soon as it gets the response, create Media entities with the download URLs which are then asynchronously queried and downloaded.
///*
// The new flow:
// 1. GetPostInfoResponse is downloaded
// 2. Post is created with it
// 3. Media is created with all the URLs
// 4. Download all media
// 5. Backup to iCloud task start
// 6. Update missing transcriptions task start
// */
//
//// TODO: We would not want it to always do a complete redownload as the original post could have been deleted. It should only delete the previous media if the new one is guaranteed.
//
//class PostIntegrityChecker {
//    
//    enum PostIntegrityStatus {
//        case fine
//        case missing
//    }
//    
//    // MARK: - Public Methods
//    
//    /// Checks all posts in the background to ensure their media files exist and are not corrupted.
//    /// If any issues are found, it calls `redownloadPost` to fix them.
//    func checkAllPostsInBackground(authToken: String, mediaICloudUploadUpdater: MediaICloudUploadUpdater, in managedContext: NSManagedObjectContext) {
//        Task {
//            await self.repairAllPosts(authToken: authToken, mediaICloudUploadUpdater: mediaICloudUploadUpdater, in: managedContext)
//        }
//    }
//    
//    func repairPost(post: Post, authToken: String, mediaICloudUploadUpdater: MediaICloudUploadUpdater, in managedContext: NSManagedObjectContext) async throws {
//        try await PostDownloaderAndSaverAndBackuper().repair(
//            post: post,
//            authToken: authToken,
//            mediaICloudUploadUpdater: mediaICloudUploadUpdater,
//            in: managedContext)
//    }
//    
//    // MARK: - Private Methods
//    
//    private func repairAllPosts(authToken: String, mediaICloudUploadUpdater: MediaICloudUploadUpdater, in managedContext: NSManagedObjectContext) async {
//        let fetchRequest = Post.fetchRequest()
//        
//        do {
//            let posts = try await managedContext.perform {
//                try managedContext.fetch(fetchRequest)
//            }
//            
//            for post in posts {
//                Task {
//                    do {
//                        try await repairPost(post: post, authToken: authToken, mediaICloudUploadUpdater: mediaICloudUploadUpdater, in: managedContext)
//                    } catch {
//                        // TODO: Handle Errors
//                        print("Error repairing post in PostIntegrityChecker... \(error)")
//                    }
//                }
//                
////                var needsRedownload = false
////                
////                // Get associated media for the post
////                let medias = try await PostCDManager.getMedia(for: post, in: managedContext)
////                
////                for media in medias {
////                    // Check if the local media file exists
////                    guard let localFilename = media.localFilename,
////                          let postSubdirectory = post.subdirectory else {
////                        print("Missing local filename or post subdirectory for media.")
////                        needsRedownload = true
////                        break
////                    }
////                    
////                    let filepath = "\(postSubdirectory)/\(localFilename)"
////                    
////                    if !DocumentSaver.fileExists(at: filepath) {
////                        print("File does not exist at path: \(filepath)")
////                        needsRedownload = true
////                        break
////                    }
////                    
////                    // Get the full file URL using DocumentSaver
////                    let fullFileURL = DocumentSaver.getFullContainerURL(from: filepath)
////                    
////                    // Check if the media file is not corrupted
////                    if PostIntegrityChecker.mediaIsCorrupted(localURL: fullFileURL) {
////                        print("Media is corrupted at path: \(filepath)")
////                        needsRedownload = true
////                        break
////                    }
////                }
////                
////                if needsRedownload {
////                    // Get getPostInfoResponse to redownload the post
////                    guard let getPostInfoResponseData = post.getPostInfoResponse else {
////                        print("Missing getPostInfoResponseData for post.")
////                        continue
////                    }
////                    
////                    guard let getPostInfoResponse = try? CodableDataAdapter.decode(GetPostInfoResponse.self, from: getPostInfoResponseData) else {
////                        print("Failed to decode getPostInfoResponseData.")
////                        continue
////                    }
////                    
////                    // Call redownloadPost to fix the post
////                    do {
////                        try await PostPersistenceManager().redownloadPostMedia(post, in: managedContext)
////                        print("Successfully redownloaded post: \(post.title ?? "Unknown Title")")
////                    } catch {
////                        print("Failed redownloading post: \(error)")
////                    }
////                }
//            }
//            
//        } catch {
//            print("Failed fetching posts: \(error)")
//        }
//    }
//    
////    func isPostFine(post: Post) -> Bool {
////        
////    }
////    
////    func isMediaFine(media: Media) -> Bool {
////        // Check if the local media file exists
////        guard let localFilename = media.localFilename,
////              let postSubdirectory = media.post?.subdirectory else {
////            print("Missing local filename or post subdirectory for media.")
////            return false
////        }
////        
////        let filepath = "\(postSubdirectory)/\(localFilename)"
////        
////        if !DocumentSaver.fileExists(at: filepath) {
////            print("File does not exist at path: \(filepath)")
////            needsRedownload = true
////            break
////        }
////        
////        // Get the full file URL using DocumentSaver
////        let fullFileURL = DocumentSaver.getFullContainerURL(from: filepath)
////        
////        // Check if the media file is not corrupted
////        if mediaIsCorrupted(media: media, url: fullFileURL) {
////            print("Media is corrupted at path: \(filepath)")
////            needsRedownload = true
////            break
////        }
////    }
//    
////    static func mediaIsCorrupted(localURL: URL) -> Bool { TODO: Removed because if the media is an incompatible filetype it will fail this and continue to try to download every launch
////        // Determine the file type based on the file extension
////        let fileExtension = localURL.pathExtension.lowercased()
////        
////        if ["jpg", "jpeg", "png", "gif"].contains(fileExtension) {
////            // Image file: Attempt to load the image data
////            do {
////                let data = try Data(contentsOf: localURL)
////                if UIImage(data: data) != nil {
////                    return false // Not corrupted
////                } else {
////                    return true // Corrupted
////                }
////            } catch {
////                print("Error loading image data: \(error)")
////                return true // Corrupted
////            }
////        } else if ["mp4", "mov", "avi", "m4v"].contains(fileExtension) {
////            // Video file: Attempt to load the AVAsset
////            let asset = AVAsset(url: localURL)
////            let playable = asset.isPlayable
////            let hasVideoTrack = !asset.tracks(withMediaType: .video).isEmpty
////            if playable && hasVideoTrack {
////                return false // Not corrupted
////            } else {
////                return true // Corrupted
////            }
////        } else {
////            // Unknown file type: Assume not corrupted
////            return false
////        }
////    }
//}
