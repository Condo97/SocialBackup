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
    
    // Download and save post
    func downloadAndSavePost(getPostInfoResponse: GetPostInfoResponse, mediaICloudUploadUpdater: MediaICloudUploadUpdater, in managedContext: NSManagedObjectContext) async throws -> Post {
        // Get thumbnail data
        let thumbnailData: Data? = try await {
            if let thumbnail = getPostInfoResponse.body.downloadResponse.thumbnail,
               let coverURL = URL(string: thumbnail) {
                return try await URLSession.shared.data(from: coverURL).0
            }
            
            return nil
        }()
        
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
        let subdirectory = "\(sanitizedTitle)_\(uuidString)"
        
        // Save Post
        let post = try await PostCDManager.savePost(
            title: getPostInfoResponse.body.downloadResponse.title == nil ? "*No Title*" : String(getPostInfoResponse.body.downloadResponse.title!.prefix(15)),
            subdirectory: subdirectory,
            thumbnailData: thumbnailData,
            getPostInfoResponse: getPostInfoResponse,
            in: managedContext)
        
        // Save highest quality video or TODO: Check if there are multiple videos or one video or something, I think the downloadResponse type will determine this
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
        if let videoURLString = highestQualityVideo?.url,
           let videoURL = URL(string: videoURLString) {
            let media = try await MediaPersistenceManager.downloadSaveMedia(
                url: videoURL,
                index: 0,
                mediaICloudUploadUpdater: mediaICloudUploadUpdater,
                postDocumentsSubdirectory: subdirectory,
                to: post,
                in: managedContext)
        }
        
        // Save images TODO: These are done separate because they should have indeces based on type, should this be looked at again and done better?
        let images = getPostInfoResponse.body.downloadResponse.medias.filter({
            if let type = $0.type {
                return GetPostInfoResponseExpectedPostTypes(rawValue: type) == .image
            }
            return false
        })
        for i in 0..<images.count {
            if let imageURLString = images[i].url,
               let imageURL = URL(string: imageURLString) {
                // Download and save the media
                try await MediaPersistenceManager.downloadSaveMedia(
                    url: imageURL,
                    index: i,
                    mediaICloudUploadUpdater: mediaICloudUploadUpdater,
                    postDocumentsSubdirectory: subdirectory,
                    to: post,
                    in: managedContext)
            }
        }
        
        return post
    }
    
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
