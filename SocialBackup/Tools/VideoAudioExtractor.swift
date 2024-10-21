//
//  VideoAudioExtractor.swift
//  SocialBackup
//
//  Created by Alex Coundouriotis on 10/18/24.
//

import AVFoundation
import Foundation

class VideoAudioExtractor {
    
    static func extractAudio(fromVideoAt videoURL: URL) async throws -> URL? {
        // Create an AVAsset from the video URL
        let asset = AVURLAsset(url: videoURL)
        
        // Check if the asset contains an audio track
        guard let assetAudioTrack = try await asset.loadTracks(withMediaType: .audio).first else {
            print("No audio track found in the video.")
            return nil
        }
        
        // Create a mutable composition for the audio
        let composition = AVMutableComposition()
        
        guard let compositionAudioTrack = composition.addMutableTrack(
            withMediaType: .audio,
            preferredTrackID: kCMPersistentTrackID_Invalid
        ) else {
            print("Unable to create composition track.")
            return nil
        }
        
        // Insert the audio track into the composition
        do {
            try await compositionAudioTrack.insertTimeRange(
//                CMTimeRange(start: .zero, duration: asset.duration),
                assetAudioTrack.load(.timeRange),
                of: assetAudioTrack,
                at: .zero
            )
        } catch {
            print("Error inserting audio track: \(error.localizedDescription)")
            return nil
        }
        
        // Prepare the output URL in the temporary directory
        let tempDirectory = URL(fileURLWithPath: NSTemporaryDirectory())
        let outputFileName = UUID().uuidString + ".m4a"
        let outputURL = tempDirectory.appendingPathComponent(outputFileName)
        
        // Remove existing file if necessary
        if FileManager.default.fileExists(atPath: outputURL.path) {
            do {
                try FileManager.default.removeItem(at: outputURL)
            } catch {
                print("Error removing existing file: \(error.localizedDescription)")
                return nil
            }
        }
        
        // Create an export session
        guard let exportSession = AVAssetExportSession(
            asset: composition,
            presetName: AVAssetExportPresetAppleM4A
        ) else {
            print("Failed to create export session.")
            return nil
        }
        
        // Configure the export session
        exportSession.outputFileType = .m4a
        exportSession.outputURL = outputURL
        exportSession.timeRange = CMTimeRange(
            start: .zero,
            duration: composition.duration
        )
        
        // Export the audio asynchronously
        await exportSession.export()
        
        print(composition.duration)
        
        
        return outputURL
//        return await withCheckedContinuation { continuation in
//            exportSession.exportAsynchronously {
//                switch exportSession.status {
//                case .completed:
//                    print("Audio extraction completed successfully.")
//                    continuation.resume(returning: outputURL)
//                case .failed:
//                    if let error = exportSession.error {
//                        print("Audio extraction failed: \(error.localizedDescription)")
//                    }
//                    continuation.resume(returning: nil)
//                case .cancelled:
//                    print("Audio extraction was cancelled.")
//                    continuation.resume(returning: nil)
//                default:
//                    print("Audio extraction status: \(exportSession.status.rawValue)")
//                    continuation.resume(returning: nil)
//                }
//            }
//        }
    }
    
}
