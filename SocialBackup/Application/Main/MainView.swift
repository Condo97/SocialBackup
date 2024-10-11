//
//  MainView.swift
//  SocialBackup
//
//  Created by Alex Coundouriotis on 10/9/24.
//

import SwiftUI

struct MainView: View {
    
    /**
     How should the database be structured?
     
     Well, there are
     - tiktok videos
     - collections (of videos)
     
     The tiktok video should somehow be stored in the user's drive so it syncs with iCloud.
     
     There should be a switch for "local" and "iCloud" in each video's settings, and also have the ability to remove locally and from iCloud with a long press
     
     */
    
    @Environment(\.managedObjectContext) private var viewContext
    
    @EnvironmentObject private var videoICloudUploadUpdater: VideoICloudUploadUpdater
    
    @FetchRequest(sortDescriptors: [NSSortDescriptor(keyPath: \Video.lastModifyDate, ascending: false)])
    private var videos: FetchedResults<Video>
    
    @State private var recentlyDownloadedVideo: Video? // Recently downloaded video from VideoDownloadMiniContainer. Not used in the implementation yet but it could like open to it or something or not
    
    @State private var presentingVideo: Video?
    
    var body: some View {
        ScrollView {
            VStack {
                // Input
                VideoDownloadMiniContainer(recentlyDownloadedVideo: $recentlyDownloadedVideo)
                    .padding(.horizontal)
                
                // Recents (side scroll)
                ScrollView(.horizontal) {
                    HStack {
                        ForEach(videos) { video in
                            Button(action: {
                                withAnimation {
                                    presentingVideo = video
                                }
                            }) {
                                VideoPreviewView(video: video)
                                    .frame(height: 250.0)
                                    .frame(minWidth: 50.0, maxWidth: 450.0)
                            }
                        }
                    }
                    .padding(.horizontal)
                }
                
                // Favorite Collections
                
                // All Collections
                
            }
        }
        .overlay {
            var isPresented: Binding<Bool> {
                Binding(
                    get: {
                        presentingVideo != nil
                    },
                    set: { value in
                        if !value {
                            presentingVideo = nil
                        }
                    })
            }
            
            if let presentingVideo = presentingVideo {
                VideoContainer(
                    video: presentingVideo,
                    isPresented: isPresented)
                .transition(.move(edge: .bottom))
            }
        }
    }
    
}

#Preview {
    
    MainView()
    
}
