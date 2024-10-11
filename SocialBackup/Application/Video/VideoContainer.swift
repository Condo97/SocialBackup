//
//  VideoContainer.swift
//  SocialBackup
//
//  Created by Alex Coundouriotis on 10/11/24.
//

import AVKit
import SwiftUI

// Custom PreferenceKey to track scroll offset
struct ScrollOffsetPreferenceKey: PreferenceKey {
    static var defaultValue: CGFloat = 0
    static func reduce(value: inout CGFloat, nextValue: () -> CGFloat) {
        value += nextValue()
    }
}

struct VideoContainer: View {
    
    var video: Video
    @Binding var isPresented: Bool

    @State private var translation: CGFloat = 0
//    @State private var isAtTop: Bool = true
    @State private var scrollOffset: CGFloat = 0
    @State private var initialDragGestureScrollOffset: CGFloat?
  
    @State private var player: AVPlayer?

    var body: some View {
        GeometryReader { geometry in
            ScrollView {
                VStack(spacing: 0.0) {
                    // Reference view to track scroll offset
                    Color.clear
                        .frame(height: 0)
                        .background(
                            GeometryReader { inner in
                                Color.clear.preference(key: ScrollOffsetPreferenceKey.self, value: inner.frame(in: .global).origin.y)
                            }
                        )
                    
                    VStack {
                        // Video player content
                        if let player = player {
                            VideoPlayer(player: player)
                                .frame(height: geometry.size.height)
                        } else {
                            // TODO: Handle loading error
                            Text("Loading...")
                            ProgressView()
                        }
                        VideoStatsContainer(video: video)
                        Spacer(minLength: 100.0)
                    }
                }
                .background(Colors.background)
            }
            .background(.black)
            .onPreferenceChange(ScrollOffsetPreferenceKey.self) { value in
                // Update isAtTop based on the scroll position
//                        let topLimit = geometry.safeAreaInsets.top
//                        self.isAtTop = value >= topLimit
                DispatchQueue.main.async {
                    self.scrollOffset = value
                }
            }
//                    .scrollTargetBehavior(.paging)
            .offset(y: self.translation)
            .simultaneousGesture(
                DragGesture()
                    .onChanged { value in
                        if initialDragGestureScrollOffset == nil {
                            initialDragGestureScrollOffset = scrollOffset
                        }
                        
                        let totalHeight = value.translation.height + (self.initialDragGestureScrollOffset ?? 0.0)
                        if totalHeight > 0 {
                            // Update translation only if dragging down and at top
                            self.translation = totalHeight
                        }
                    }
                    .onEnded { value in
                        initialDragGestureScrollOffset = nil
                        
                        if self.translation > 100 {
                            // Dismiss the view when dragged down sufficiently
                            withAnimation {
                                self.isPresented = false
                            }
                        } else {
                            // Animate back to original position
                            withAnimation {
                                self.translation = 0
                            }
                        }
                    }
            )
        }
        .ignoresSafeArea()
        .onAppear {
            if let localFilename = video.localFilename {
                self.player = AVPlayer(playerItem: AVPlayerItem(url: DocumentSaver.getFullDocumentsURL(from: localFilename)))
                self.player?.play()
            }
        }
        .onDisappear {
            self.player?.pause()
        }
    }
    
}

//#Preview {
//    
//    VideoContainer()
//
//}
