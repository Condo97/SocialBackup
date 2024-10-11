//
//  VideoCDManager.swift
//  SocialBackup
//
//  Created by Alex Coundouriotis on 10/11/24.
//

import CoreData
import Foundation
import UIKit

class VideoCDManager {
    
    static func saveVideo(title: String, thumbnailData: Data?, getVideoInfoResponse: GetVideoInfoResponse, localFilename: String?, iCloudFilename: String?, in managedContext: NSManagedObjectContext) async throws -> Video {
        let getVideoInfoResponseData = try CodableDataAdapter.encode(getVideoInfoResponse)
        
        return try await saveVideo(
            title: title,
            thumbnailData: thumbnailData,
            getVideoInfoResponseData: getVideoInfoResponseData,
            localFilename: localFilename,
            iCloudFilename: iCloudFilename,
            in: managedContext)
    }
    
    static func saveVideo(title: String, thumbnailData: Data?, getVideoInfoResponseData: Data, localFilename: String?, iCloudFilename: String?, in managedContext: NSManagedObjectContext) async throws -> Video {
        try await managedContext.perform {
            let video = Video(context: managedContext)
            video.title = title
            video.thumbnail = thumbnailData
            video.getVideoInfoResponse = getVideoInfoResponseData
            video.localFilename = localFilename
            video.iCloudFilename = iCloudFilename
            video.saveDate = Date()
            video.lastModifyDate = Date()
            
            try managedContext.save()
            
            return video
        }
    }
    
    static func updateVideo(_ video: Video, iCloudFilename: String?, in managedContext: NSManagedObjectContext) async throws {
        try await managedContext.perform {
            video.iCloudFilename = iCloudFilename
            
            try managedContext.save()
        }
    }
    
}
