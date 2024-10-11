//
//  VideoStatsContainer.swift
//  SocialBackup
//
//  Created by Alex Coundouriotis on 10/11/24.
//

import SwiftUI

struct VideoStatsContainer: View {
    
    var video: Video
    
    @State private var videoInfo: GetVideoInfoResponse?
    
    @State private var isLoading: Bool = false
    
    var body: some View {
        Group {
            if let videoInfo = videoInfo {
                VideoStatsView(videoInfo: videoInfo)
            } else if isLoading {
                VStack {
                    Text("Loading...")
                    ProgressView()
                }
            } else {
                Text("No Video Info")
            }
        }
        .onAppear {
            defer {
                DispatchQueue.main.async {
                    self.isLoading = false
                }
            }
            
            DispatchQueue.main.async {
                self.isLoading = true
            }
            
            guard let getVideoInfoResponseData = video.getVideoInfoResponse else {
                // TODO: Handle Errors
                print("Could not get unwrap getVideoInfoResponse data in VideoStatsContainer!")
                return
            }
            
            do {
                videoInfo = try CodableDataAdapter.decode(GetVideoInfoResponse.self, from: getVideoInfoResponseData)
            } catch {
                // TODO: Handle Errors
                print("Error decoding getVideoInfoResponseData in VideoStatsContainer... \(error)")
                return
            }
        }
    }
    
}

//#Preview {
//    
//    VideoStatsContainer()
//
//}
