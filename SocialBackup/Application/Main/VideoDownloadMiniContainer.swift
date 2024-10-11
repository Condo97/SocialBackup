//
//  VideoDownloadMiniContainer.swift
//  SocialBackup
//
//  Created by Alex Coundouriotis on 10/11/24.
//

import SwiftUI

struct VideoDownloadMiniContainer: View {
    
    @Binding var recentlyDownloadedVideo: Video?
    
    @Environment(\.managedObjectContext) private var viewContext
    
    @EnvironmentObject private var videoICloudUploadUpdater: VideoICloudUploadUpdater
    
    @State private var isLoading: Bool = false
    
    @State private var text: String = ""
    
    var body: some View {
        VideoDownloadMiniView(
            text: $text,
            isLoading: $isLoading,
            onSubmit: downloadAndSaveVideo)
    }
    
    func downloadAndSaveVideo() {
        Task {
            defer { DispatchQueue.main.async { isLoading = false } }
            await MainActor.run { isLoading = true }
            
            // Download and save
            do {
                recentlyDownloadedVideo = try await TikTokDownloader.downloadAndSave(
                    fromURLString: text,
                    videoICloudUploadUpdater: videoICloudUploadUpdater,
                    in: viewContext)
            } catch {
                // TODO: Handle Errors
                print("Error downloading and saving video in VideoDownloadMiniContainer... \(error)")
                return
            }
            
        }
    }
    
}

//#Preview {
//    
//    VideoDownloadMiniContainer()
//
//}
