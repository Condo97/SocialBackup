//
//  PostPreviewView.swift
//  SocialBackup
//
//  Created by Alex Coundouriotis on 10/11/24.
//

import SwiftUI

struct PostPreviewView: View {
    
    @ObservedObject var post: Post
    @FetchRequest var medias: FetchedResults<Media>
    
    @Environment(\.managedObjectContext) private var viewContext
    
//    @EnvironmentObject private var postICloudUploadUpdater: MediaICloudUploadUpdater
    
    @State private var alertShowingErrorUploading: Bool = false
    
    var body: some View {
        ZStack {
            Color.black.opacity(0.1)//Colors.foreground
            
            if let imageData = post.thumbnail,
               let uiImage = UIImage(data: imageData) {
                Image(uiImage: uiImage)
                    .resizable()
                    .aspectRatio(contentMode: .fill)
            } else if let title = post.title {
                Text(title)
                    .lineLimit(1)
                    .minimumScaleFactor(0.5)
            } else {
                Text("?")
            }
        }
        .font(.custom(Constants.FontName.body, size: 17.0))
//        .overlay(alignment: .bottomTrailing) {
//            Button(action: {
//                let notBackedUpMedias = medias.filter({ $0.iCloudFilename == nil })
//                
//                for notBackedUpMedia in notBackedUpMedias {
//                    // Upload
//                    if let localFilename = notBackedUpMedia.localFilename {
//                        Task {
//                            do {
//                                guard let mediaData = try DocumentSaver.getData(from: localFilename) else {
//                                    print("Could not unwrap mediaData in PostPreviewView!")
//                                    return
//                                }
//                                
//                                try await postICloudUploadUpdater.backupMediaToICloud(mediaData: mediaData, filepath: localFilename)
//                                try await MediaCDManager.updateMedia(notBackedUpMedia, iCloudFilepath: localFilename, in: viewContext)
//                            } catch {
//                                print("Error backing up post to iCloud in PostPreviewView... \(error)")
//                                alertShowingErrorUploading = true
//                            }
//                        }
//                    } else {
//                        // Show alert
//                        alertShowingErrorUploading = true
//                    }
//                }
//            }) {
//                let allAreUploading = medias.contains(where: { // Check if contains where iCloud filename is nil local file is not uploading
//                    if $0.iCloudFilename == nil,
//                       let localFilename = $0.localFilename {
//                        if !postICloudUploadUpdater.uploadingFilenames.contains(localFilename) {
//                            return false
//                        }
//                    }
//                    return true
//                })
//                Image(systemName: allAreUploading ? "icloud" : (medias.filter({ $0.iCloudFilename == nil }).isEmpty ? "icloud" : "icloud.slash"))// post.localFilename != nil && postICloudUploadUpdater.uploadingFilenames.contains(post.localFilename!)) ? "icloud" : (post.iCloudFilename == nil ? "icloud.slash" : "icloud"))
//                    .padding()
//                    .overlay {
//                        if !postICloudUploadUpdater.uploadingFilenames.isEmpty {
//                            ProgressView()
//                        }
//                    }
//                    .foregroundStyle(Colors.elementBackgroundColor)
//            }
//        }
//        .clipShape(RoundedRectangle(cornerRadius: 5.0))
        .alert("Error Uploading", isPresented: $alertShowingErrorUploading, actions: {
            Button("Close", role: .cancel) {}
        }) {
            Text("There was an error saving your post to iCloud. Please try again.")
        }
    }
    
}

#Preview {
    
    let post: Post = {
        try! CDClient.mainManagedObjectContext.performAndWait {
            return try CDClient.mainManagedObjectContext.fetch(Post.fetchRequest()).first!
        }
    }()
    
    return PostPreviewView(
        post: post,
        medias: FetchRequest(sortDescriptors: [NSSortDescriptor(key: #keyPath(Media.index), ascending: true)], predicate: NSPredicate(format: "%K = %@", #keyPath(Media.post), post)))
    
}
