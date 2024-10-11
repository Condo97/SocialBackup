//
//  TikTokDownloader.swift
//  SocialBackup
//
//  Created by Alex Coundouriotis on 10/11/24.
//

import CoreData
import Foundation

class TikTokDownloader {
    
    static func downloadAndSave(fromURLString urlString: String, videoICloudUploadUpdater: VideoICloudUploadUpdater, in viewContext: NSManagedObjectContext) async throws -> Video? {
        let videoInfo = try await TikTokServerConnector.getVideoInfo(request: GetVideoInfoRequest(videoURL: urlString))
        
        guard let videoURL = URL(string: videoInfo.downloadResponse.data.play) else {
            // TODO: Handle Errors
            print("Could not unwrap videoURL in TikTokDownloader!")
            return nil
        }
        
        let thumbnailData: Data? = try await {
            if let coverURL = URL(string: videoInfo.downloadResponse.data.cover) {
                return try await URLSession.shared.data(from: coverURL).0
            }
            
            return nil
        }()
        
        return try await VideoPersistenceManager.downloadAndSaveVideo(
            from: videoURL,
            thumbnailData: thumbnailData,
            getVideoInfoResponse: videoInfo,
            videoICloudUploadUpdater: videoICloudUploadUpdater,
            in: viewContext)
    }
    
}
