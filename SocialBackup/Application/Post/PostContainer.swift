//
//  PostContainer.swift
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

struct PostContainer: View {
    
    var post: Post
    @Binding var isPresented: Bool
    @FetchRequest var medias: FetchedResults<Media>

    @State private var translation: CGFloat = 0
//    @State private var isAtTop: Bool = true
    @State private var scrollOffset: CGFloat = 0
    @State private var initialDragGestureScrollOffset: CGFloat?
    
    @State private var isShowingAddToCollection: Bool = false
  
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
//                            let images = medias.filter({
//                                if let filename = $0.localFilename { // TODO: See if necessary to use iCloud filename
//                                    return MediaTypeFromExtension.getMediaType(fromFilename: filename) == .image
//                                }
//                                return false
//                            })
                            if let subdirectory = post.subdirectory {
                                PostImageCollectionView(
                                    subdirectory: subdirectory,
                                    medias: _medias)
                                .frame(height: geometry.size.height)
                            }
                            
//                            // TODO: Handle loading error
//                            Text("Loading...")
//                            ProgressView()
                        }
                        
                        VStack {
                            PostStatsContainer(
                                post: post,
                                onAddToCollection: {
                                    isShowingAddToCollection = true
                                })
                            Spacer(minLength: 100.0)
                        }
                        .background(Colors.background)
                    }
                }
            }
            .background(.black)
            .onPreferenceChange(ScrollOffsetPreferenceKey.self) { value in
                // Update isAtTop based on the scroll position
                DispatchQueue.main.async {
                    self.scrollOffset = value
                }
            }
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
//            var isDisplayingVideo = false
            
            // Check for video and display it
            if medias.contains(where: {
                if let filename = $0.localFilename,
                   let subdirectory = post.subdirectory { // TODO: See if necessary to use iCloud filename
                    let filepath = "\(subdirectory)/\(filename)"
                    return MediaTypeFromExtension.getMediaType(fromFilename: filepath) == .video
                }
                return false
            }) {
                // Get highest index video localFilename that exists
                if let subdirectory = post.subdirectory,
                   let highestIndexVideoLocalFilename = medias.sorted(by: { $0.index < $1.index }).first(where: { $0.localFilename != nil })?.localFilename {
                    let highestIndexVideoLocalFilepath = "\(subdirectory)/\(highestIndexVideoLocalFilename)"
                    self.player = AVPlayer(playerItem: AVPlayerItem(url: DocumentSaver.getFullContainerURL(from: highestIndexVideoLocalFilepath)))
                    self.player?.play()
//                    isDisplayingVideo = true
                }
            }
            
//            // Check for photo(s) if no video
//            if !isDisplayingVideo,
//               medias.filter(where: {
//                   if let filename = $0.localFilename { // TODO: See if necessary to use iCloud filename
//                       return MediaTypeFromExtension.getMediaType(fromFilename: filename) == .image
//                   }
//                   return false
//               }) {
//                
//            }
            
//            if let localFilename = post.localFilename {
//                self.player = AVPlayer(playerItem: AVPlayerItem(url: DocumentSaver.getFullDocumentsURL(from: localFilename)))
//                self.player?.play()
//            }
        }
        .onDisappear {
            self.player?.pause()
        }
        .addPostToCollectionFullScreenCover(isPresented: $isShowingAddToCollection, post: post)
    }
    
}

extension View {
    
    func postContainer(post: Binding<Post?>) -> some View {
        var isPresented: Binding<Bool> {
            Binding(
                get: {
                    post.wrappedValue != nil
                },
                set: { value in
                    if !value {
                        post.wrappedValue = nil
                    }
                })
        }
        
        return self
            .clearFullScreenCover(isPresented: isPresented, backgroundVisibleOpacity: 0.0) {
                if let post = post.wrappedValue {
                    PostContainer(
                        post: post,
                        isPresented: isPresented,
                        medias: FetchRequest(sortDescriptors: [NSSortDescriptor(key: #keyPath(Media.index), ascending: true)], predicate: NSPredicate(format: "%K = %@", #keyPath(Media.post), post)))
                    .transition(.move(edge: .bottom))
                }
            }
    }
    
}

//#Preview {
//    
//    PostContainer()
//
//}
