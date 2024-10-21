//
//  MediaTypeFromExtension.swift
//  SocialBackup
//
//  Created by Alex Coundouriotis on 10/12/24.
//

import Foundation

class MediaTypeFromExtension {
    
    enum MediaType {
        case image
        case video
        case unknown
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
        let imageExtensions = ["jpg", "jpeg", "png", "gif", "tiff", "bmp", "heic", "webp", "svg", "ico"]
        let videoExtensions = ["mov", "mp4", "avi", "wmv", "flv", "mkv", "webm", "mpeg", "mpg", "m4v", "3gp"]
        
        let ext = `extension`.lowercased()
        
        if imageExtensions.contains(ext) {
            return .image
        } else if videoExtensions.contains(ext) {
            return .video
        } else {
            return .unknown
        }
    }
    
}
