//
//  MediaTypeFromExtension.swift
//  SocialBackup
//
//  Created by Alex Coundouriotis on 10/12/24.
//

import Foundation

class MediaTypeFromExtension {
    
    enum MediaType: Comparable {
        case image
        case video
        case unknown
        
        var extensions: [String]? {
            switch self {
            case .image: return ["jpg", "jpeg", "png", "gif", "tiff", "bmp", "heic", "webp", "svg", "ico"]
            case .video: return ["mov", "mp4", "avi", "wmv", "flv", "mkv", "webm", "mpeg", "mpg", "m4v", "3gp"]
            default: return nil
            }
        }
        
        var name: String {
            switch self {
            case .image: return "Image"
            case .video: return "Video"
            case .unknown: return "Unknown"
            }
        }
        
    }
    
    static func getMediaType(fromLocalURL localURL: URL) -> MediaType {
        let ext = localURL.pathExtension
        return getMediaType(fromExtension: ext)
    }
    
    static func getMediaType(fromFilename filename: String) -> MediaType {
            let ext = (filename as NSString).pathExtension
            return getMediaType(fromExtension: ext)
        }
    
    static func getMediaType(fromExtension extension: String) -> MediaType {
//        let imageExtensions = ["jpg", "jpeg", "png", "gif", "tiff", "bmp", "heic", "webp", "svg", "ico"]
//        let videoExtensions = ["mov", "mp4", "avi", "wmv", "flv", "mkv", "webm", "mpeg", "mpg", "m4v", "3gp"]
        
        let ext = `extension`.lowercased()
        
        if let imageExtensions = MediaType.image.extensions,
           imageExtensions.contains(ext) {
            return .image
        } else if let videoExtensions = MediaType.video.extensions,
                  videoExtensions.contains(ext) {
            return .video
        } else {
            return .unknown
        }
    }
    
}
