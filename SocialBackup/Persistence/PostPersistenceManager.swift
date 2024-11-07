//
//  PostPersistenceManager.swift
//  SocialBackup
//
//  Created by Alex Coundouriotis on 10/11/24.
//

import AVFoundation
import CoreData
import SwiftUI

class PostPersistenceManager: ObservableObject {
    
//    private var postAudioTranscriber: MediaAudioTranscriber?
    
//    // Check if iCloud is available
//    var isICloudAvailable: Bool {
//        FileManager.default.ubiquityIdentityToken != nil
//    }
    
    // User Preferences
    @AppStorage("autoSyncEnabled") var autoSyncEnabled: Bool = false
    
    // Automatically creates Media entities with their externalURL to download. Download operations should be performed to each Media in another function
    func createMediaShells(for post: Post, in managedContext: NSManagedObjectContext) async throws {
        // Get getPostInfoResponse from Post, otherwise throw missingGetPostInfoResponse
        guard let getPostInfoResponseData = post.getPostInfoResponse else {
            print("Could not unwrap getPostInfoResponseData in PostPsersistenceManager!")
            throw PostPersistenceManagerError.missingGetPostInfoResponse
        }
        let getPostInfoResponse: GetPostInfoResponse
        do {
            getPostInfoResponse = try CodableDataAdapter.decode(GetPostInfoResponse.self, from: getPostInfoResponseData)
        } catch {
            print("Error decoding GetPostInfoResponse in PostPersistenceMangaer... \(error)")
            throw PostPersistenceManagerError.missingGetPostInfoResponse
        }
        
        // Create media for the post
        // Get highest quality video or TODO: Check if there are multiple videos or one video or something, I think the downloadResponse type will determine this
        let videos = getPostInfoResponse.body.downloadResponse.medias.filter({
            if let type = $0.type {
                return GetPostInfoResponseExpectedPostTypes(rawValue: type) == .video
            }
            return false
        })
        // TODO: Check if there are multiple videos rather than just one with multiple quality ranks
        let highestQualityVideo = videos.max(by: {
            let firstVideoQuality: GetPostInfoResponseExpectedMediaQualities
            let secondVideoQuality: GetPostInfoResponseExpectedMediaQualities
            
            if let firstVideoQualityString = $0.quality {
                firstVideoQuality = GetPostInfoResponseExpectedMediaQualities(rawValue: firstVideoQualityString) ?? .unknown
            } else {
                firstVideoQuality = .unknown
            }
            
            if let secondVideoQualityString = $1.quality {
                secondVideoQuality = GetPostInfoResponseExpectedMediaQualities(rawValue: secondVideoQualityString) ?? .unknown
            } else {
                secondVideoQuality = .unknown
            }
            
            return firstVideoQuality < secondVideoQuality
        })
        // Save images TODO: These are done separate because they should have indeces based on type, should this be looked at again and done better?
        let images = getPostInfoResponse.body.downloadResponse.medias.filter({
            if let type = $0.type {
                return GetPostInfoResponseExpectedPostTypes(rawValue: type) == .image
            }
            return false
        })
        
        // Get current existant Post Media URLs to filter out and prevent duplicates with the same URL
        let existantMediaURLs = try await MediaCDManager.getMedia(for: post, in: managedContext).compactMap(\.externalURL)
        
        // Save media
        if let videoURLString = highestQualityVideo?.url,
           let videoURL = URL(string: videoURLString) {
            // Create Media if not in existantMediaURLs
            if !existantMediaURLs.contains(videoURL) {
                try await MediaCDManager.saveMedia(
                    downloadURL: videoURL,
                    index: 0,
                    to: post,
                    in: managedContext)
            }
//            let media = try await MediaPersistenceManager.downloadSaveMedia(
//                url: videoURL,
//                index: 0,
//                postDocumentsSubdirectory: subdirectory,
//                to: post,
//                in: managedContext)
        }
        for i in 0..<images.count {
            if let imageURLString = images[i].url,
               let imageURL = URL(string: imageURLString) {
                // Create Media if not in existantMediaURLs
                if !existantMediaURLs.contains(imageURL) {
                    try await MediaCDManager.saveMedia(
                        downloadURL: imageURL,
                        index: Int64(i),
                        to: post,
                        in: managedContext)
                }
//                // Download and save the media
//                try await MediaPersistenceManager.downloadSaveMedia(
//                    url: imageURL,
//                    index: i,
//                    postDocumentsSubdirectory: subdirectory,
//                    to: post,
//                    in: managedContext)
            }
        }
    }
    
    /*
     Conditions for Redownload:
     1. Local filepath is nil or empty
     2. Local filepath points to a corrupt file
     What if the URL is corrupt? Skip? What about redownloading post info? If the URL is corrupt it should just skip. I guess this can be checked later or it is maybe a more rare problem or maybe there could be a "complete redownload" or "fix" button that creates a new Post and does the whole redownload process again
     So if there is a corrupt URL, skip it!
     */
    func downloadMissingMedia(_ post: Post, in managedContext: NSManagedObjectContext) async throws {// Get getPostInfoResponse from Post, otherwise throw missingGetPostInfoResponse
        guard let getPostInfoResponseData = post.getPostInfoResponse else {
            print("Could not unwrap getPostInfoResponseData in PostPsersistenceManager!")
            throw PostPersistenceManagerError.missingGetPostInfoResponse
        }
        let getPostInfoResponse: GetPostInfoResponse
        do {
            getPostInfoResponse = try CodableDataAdapter.decode(GetPostInfoResponse.self, from: getPostInfoResponseData)
        } catch {
            print("Error decoding GetPostInfoResponse in PostPersistenceMangaer... \(error)")
            throw PostPersistenceManagerError.missingGetPostInfoResponse
        }
        
        // Get post subdirectory or create if it doesn't exist or is empty
        let subdirectory: String
        if let postSubdirectory = post.subdirectory,
           !postSubdirectory.isEmpty {
            subdirectory = postSubdirectory
        } else {
            // Create a unique subdirectory
            let formatter = DateFormatter()
            formatter.dateFormat = "yyyyMMdd_HHmmss" // e.g., 20231006_153045
            let dateString = formatter.string(from: Date())
            let uuidString = UUID().uuidString.replacingOccurrences(of: "-", with: "").prefix(5)
            func sanitizeTitle(_ title: String) -> String {
                let allowedCharacters = CharacterSet.alphanumerics
                return String(title.unicodeScalars.filter { allowedCharacters.contains($0) })
            }
            let rawTitle = getPostInfoResponse.body.downloadResponse.title ?? dateString
            let trimmedTitle = String(rawTitle.prefix(15))
            let sanitizedTitle = sanitizeTitle(trimmedTitle)
            subdirectory = "\(sanitizedTitle)_\(uuidString)"
            
            // Update subdirectory
            try await PostCDManager.updatePost(post, subdirectory: subdirectory, in: managedContext)
        }
        
        // Update title if nonexistant
        if post.title == nil {
            try await PostCDManager.updatePost(post, title: getPostInfoResponse.body.downloadResponse.title == nil ? "*No Title*" : String(getPostInfoResponse.body.downloadResponse.title!.prefix(15)), in: managedContext)
        }
        
        // Update thumbnail if nonexistant
        if post.thumbnail == nil {
            // Get thumbnail data
            let thumbnailData: Data? = try await {
                if let thumbnail = getPostInfoResponse.body.downloadResponse.thumbnail,
                   let coverURL = URL(string: thumbnail) {
                    return try await URLSession.shared.data(from: coverURL).0
                }
                
                return nil
            }()
            
            // Update thumbnail
            if let thumbnailData = thumbnailData {
                try await PostCDManager.updatePost(post, thumbnailData: thumbnailData, in: managedContext)
            }
        }
        
        // Download and save or replace all undownloaded or corrupt Media
        let medias = try await PostCDManager.getMedia(for: post, in: managedContext)
        for media in medias {
            var shouldDownload: Bool = false
            if let localFilename = media.localFilename {
                let localFilepath = "\(subdirectory)/\(localFilename)"
                do {
                    let isMediaCorrupted = try FileCorruptionChecker.mediaIsCorrupted(localURL: DocumentSaver.getFullContainerURL(from: localFilepath))
                    
                    shouldDownload = !DocumentSaver.fileExists(at: localFilepath) || isMediaCorrupted
                } catch FileCorruptionCheckerError.unknownFiletype {
                    // If filetype is unknown, do not download
                    shouldDownload = false
                }
            } else {
                // Couldn't unwrap filename so redownload
                shouldDownload = true
            }
            
            // If shouldDownload download
            if shouldDownload {
                do {
                    try await MediaPersistenceManager.downloadFromExternalURL(
                        media: media,
                        postSubdirectory: subdirectory,
                        in: managedContext)
                } catch {
                    // TODO: Handle Errors
                    print("Error downloading media from external URL in PostPersistenceManager... \(error)")
                    continue
                }
            }
        }
        
        
//        // Delete media
//        try await PostCDManager.deleteAllMedia(for: post, in: managedContext)
//        
//        // TODO: THIS IS DONE IN PostDownloaderAndBackuper
//        // Save highest quality video or TODO: Check if there are multiple videos or one video or something, I think the downloadResponse type will determine this
//        let videos = getPostInfoResponse.body.downloadResponse.medias.filter({
//            if let type = $0.type {
//                return GetPostInfoResponseExpectedPostTypes(rawValue: type) == .video
//            }
//            return false
//        })
//        // TODO: Check if there are multiple videos rather than just one with multiple quality ranks
//        let highestQualityVideo = videos.max(by: {
//            let firstVideoQuality: GetPostInfoResponseExpectedMediaQualities
//            let secondVideoQuality: GetPostInfoResponseExpectedMediaQualities
//            
//            if let firstVideoQualityString = $0.quality {
//                firstVideoQuality = GetPostInfoResponseExpectedMediaQualities(rawValue: firstVideoQualityString) ?? .unknown
//            } else {
//                firstVideoQuality = .unknown
//            }
//            
//            if let secondVideoQualityString = $1.quality {
//                secondVideoQuality = GetPostInfoResponseExpectedMediaQualities(rawValue: secondVideoQualityString) ?? .unknown
//            } else {
//                secondVideoQuality = .unknown
//            }
//            
//            return firstVideoQuality < secondVideoQuality
//        })
//        if let videoURLString = highestQualityVideo?.url,
//           let videoURL = URL(string: videoURLString) {
//            let media = try await MediaPersistenceManager.downloadSaveMedia(
//                url: videoURL,
//                index: 0,
//                postDocumentsSubdirectory: subdirectory,
//                to: post,
//                in: managedContext)
//        }
//        
//        // Save images TODO: These are done separate because they should have indeces based on type, should this be looked at again and done better?
//        let images = getPostInfoResponse.body.downloadResponse.medias.filter({
//            if let type = $0.type {
//                return GetPostInfoResponseExpectedPostTypes(rawValue: type) == .image
//            }
//            return false
//        })
//        for i in 0..<images.count {
//            if let imageURLString = images[i].url,
//               let imageURL = URL(string: imageURLString) {
//                // Download and save the media
//                try await MediaPersistenceManager.downloadSaveMedia(
//                    url: imageURL,
//                    index: i,
//                    postDocumentsSubdirectory: subdirectory,
//                    to: post,
//                    in: managedContext)
//            }
//        }
    }
    
//    // Download and save post
//    func downloadAndSavePost(getPostInfoResponse: GetPostInfoResponse, mediaICloudUploadUpdater: MediaICloudUploadUpdater, in managedContext: NSManagedObjectContext) async throws -> Post {
////        // Create a unique subdirectory
////        let formatter = DateFormatter()
////        formatter.dateFormat = "yyyyMMdd_HHmmss" // e.g., 20231006_153045
////        let dateString = formatter.string(from: Date())
////        let uuidString = UUID().uuidString.replacingOccurrences(of: "-", with: "").prefix(5)
////        func sanitizeTitle(_ title: String) -> String {
////            let allowedCharacters = CharacterSet.alphanumerics
////            return String(title.unicodeScalars.filter { allowedCharacters.contains($0) })
////        }
////        let rawTitle = getPostInfoResponse.body.downloadResponse.title ?? dateString
////        let trimmedTitle = String(rawTitle.prefix(15))
////        let sanitizedTitle = sanitizeTitle(trimmedTitle)
////        let subdirectory = "\(sanitizedTitle)_\(uuidString)"
//        
//        // Get thumbnail data
//        let thumbnailData: Data? = try await {
//            if let thumbnail = getPostInfoResponse.body.downloadResponse.thumbnail,
//               let coverURL = URL(string: thumbnail) {
//                return try await URLSession.shared.data(from: coverURL).0
//            }
//            
//            return nil
//        }()
//        
//        // Save Post
//        let post = try await PostCDManager.savePost(
//            title: getPostInfoResponse.body.downloadResponse.title == nil ? "*No Title*" : String(getPostInfoResponse.body.downloadResponse.title!.prefix(15)),
//            subdirectory: nil,
//            thumbnailData: thumbnailData,
//            getPostInfoResponse: getPostInfoResponse,
//            in: managedContext)
//        
//        try await redownloadPost(post, getPostInfoResponse: getPostInfoResponse, in: managedContext)
//        
//        return post
//    }
    
    static func getAndSavePostSummary(authToken: String, model: GPTModels = .gpt4oMini, to post: Post, in managedContext: NSManagedObjectContext) async throws {
        // Ensure unwrap getPostInfoResponseData, otherwise throw missingGetPostInfoResponse
        guard let getPostInfoResponseData = post.getPostInfoResponse else {
            throw PostPersistenceManagerError.missingGetPostInfoResponse
        }
        
        // Get post title
        let title = post.title
        
        // Get post platform
        let platform = try CodableDataAdapter.decode(GetPostInfoResponse.self, from: getPostInfoResponseData)
        
        // Get transcription for each media
        let transcriptions: [String] = try await {
            var transcriptions: [String] = []
            let fetchRequest = Media.fetchRequest()
            fetchRequest.predicate = NSPredicate(format: "%K = %@", #keyPath(Media.post), post)
            let medias = try await managedContext.perform { try managedContext.fetch(fetchRequest) }
            for media in medias {
                if let transcription = media.transcription {
                    transcriptions.append(transcription)
                }
            }
            return transcriptions
        }()
        
        // Ensure at least one transcription, otherwise throw noTranscription
        guard !transcriptions.isEmpty else {
            throw PostPersistenceManagerError.noTranscription
        }
        
        // Build message
        let message: String = {
            var message: String = ""
            if let title {
                message += "POST_TITLE:\n\(title)\n\n"
            }
            message += "POST_PLATFORM:\n\(platform)\n\n"
            for i in 0..<transcriptions.count {
                message += "POST_\(i) TRANSCRIPTION:\n(\(transcriptions[i]))\n\n"
            }
            return message
        }()
        
        // Get videoSummarySO output, otherwise throw nilVideoSummary
        guard let videoSummarySO: VideoSummarySO = try await StructuredOutputGenerator.generate(
            authToken: authToken,
            model: model,
            messages: [
                OAIChatCompletionRequestMessage(
                    role: .user,
                    content: [.text(OAIChatCompletionRequestMessageContentText(text: message))])
            ],
            endpoint: Constants.Networking.TikTokServer.Endpoints.StructuredOutput.videoSummary) else {
            throw PostPersistenceManagerError.nilVideoSummary
        }
        
        // Update Post with videoSummarySO values
        try await PostCDManager.updatePost(post, videoSummarySO: videoSummarySO, in: managedContext)
    }
    
    func getAudioDuration(from url: URL) -> TimeInterval? {
        // Create an asset from the URL
        let asset = AVURLAsset(url: url)
        
        // Get the duration of the asset
        let duration = asset.duration
        
        // Convert the duration to seconds
        let durationInSeconds = CMTimeGetSeconds(duration)
        
        // Check if the duration is a valid number
        if durationInSeconds.isFinite {
            return durationInSeconds
        } else {
            return nil
        }
    }
    
}
