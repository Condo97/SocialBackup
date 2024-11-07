//
//  FileCorruptionChecker.swift
//  SocialBackup
//
//  Created by Alex Coundouriotis on 10/25/24.
//

import AVKit
import Foundation
import SwiftUI

class FileCorruptionChecker {
    
    static func mediaIsCorrupted(localURL: URL) throws -> Bool {
        // Determine the file type based on the file extension
        let fileExtension = localURL.pathExtension.lowercased()
        
        if ["jpg", "jpeg", "png", "gif"].contains(fileExtension) {
            // Image file: Attempt to load the image data
            do {
                let data = try Data(contentsOf: localURL)
                if UIImage(data: data) != nil {
                    return false // Not corrupted
                } else {
                    return true // Corrupted
                }
            } catch {
                print("Error loading image data: \(error)")
                return true // Corrupted
            }
        } else if ["mp4", "mov", "avi", "m4v"].contains(fileExtension) {
            // Video file: Attempt to load the AVAsset
            let asset = AVAsset(url: localURL)
            let playable = asset.isPlayable
            let hasVideoTrack = !asset.tracks(withMediaType: .video).isEmpty
            if playable && hasVideoTrack {
                return false // Not corrupted
            } else {
                return true // Corrupted
            }
        } else {
            // Unknown file type, throw FileCorruptionCheckerError unknownFileType
            throw FileCorruptionCheckerError.unknownFiletype
//            // Unknown file type: Assume not corrupted
//            return false
        }
    }
    
}

enum FileCorruptionCheckerError: Error {
    case unknownFiletype
}
