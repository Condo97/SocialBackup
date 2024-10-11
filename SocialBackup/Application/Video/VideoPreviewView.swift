//
//  VideoPreviewView.swift
//  SocialBackup
//
//  Created by Alex Coundouriotis on 10/11/24.
//

import SwiftUI

struct VideoPreviewView: View {
    
    @ObservedObject var video: Video
    
    @Environment(\.managedObjectContext) private var viewContext
    
    @EnvironmentObject private var videoICloudUploadUpdater: VideoICloudUploadUpdater
    
    @State private var alertShowingErrorUploading: Bool = false
    
    var body: some View {
        ZStack {
            Color.black.opacity(0.1)//Colors.foreground
            
            if let imageData = video.thumbnail,
               let uiImage = UIImage(data: imageData) {
                Image(uiImage: uiImage)
                    .resizable()
                    .aspectRatio(contentMode: .fit)
            } else if let title = video.title {
                Text(title)
                    .lineLimit(1)
                    .minimumScaleFactor(0.5)
            } else {
                Text("?")
            }
        }
        .font(.custom(Constants.FontName.body, size: 17.0))
        .overlay(alignment: .bottomTrailing) {
            Button(action: {
                if video.iCloudFilename == nil {
                    // Upload
                    if let localFilename = video.localFilename {
                        Task {
                            do {
                                guard let videoData = try DocumentSaver.getData(from: localFilename) else {
                                    print("Could not unwrap videoData in VideoPreviewView!")
                                    return
                                }
                                
                                try await videoICloudUploadUpdater.backupVideoToICloud(videoData: videoData, filename: localFilename)
                                try await VideoCDManager.updateVideo(video, iCloudFilename: localFilename, in: viewContext)
                            } catch {
                                print("Error backing up video to iCloud in VideoPreviewView... \(error)")
                                alertShowingErrorUploading = true
                            }
                        }
                    } else {
                        // Show alert
                        alertShowingErrorUploading = true
                    }
                } else {
                    // Ask to delete TODO: Implement
                }
            }) {
                Image(systemName: (video.localFilename != nil && videoICloudUploadUpdater.uploadingFilenames.contains(video.localFilename!)) ? "icloud" : (video.iCloudFilename == nil ? "icloud.slash" : "icloud"))
                    .padding()
                    .overlay {
                        if video.localFilename != nil && videoICloudUploadUpdater.uploadingFilenames.contains(video.localFilename!) {
                            ProgressView()
                        }
                    }
                    .foregroundStyle(Colors.elementBackgroundColor)
            }
        }
        .clipShape(RoundedRectangle(cornerRadius: 5.0))
        .alert("Error Uploading", isPresented: $alertShowingErrorUploading, actions: {
            Button("Close", role: .cancel) {}
        }) {
            Text("There was an error saving your video to iCloud. Please try again.")
        }
    }
    
}

#Preview {
    
    let video: Video = {
        try! CDClient.mainManagedObjectContext.performAndWait {
            return try CDClient.mainManagedObjectContext.fetch(Video.fetchRequest()).first!
        }
    }()
    
    return VideoPreviewView(video: video)
    
}
