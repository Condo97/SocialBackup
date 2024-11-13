//
//  QueuedPostDownloaderView.swift
//  SocialBackup
//
//  Created by Alex Coundouriotis on 10/19/24.
//

import SwiftUI

struct QueuedPostDownloaderView: View {
    
    @Binding var isSelecting: Bool
    @Binding var selected: [Post]
    @ObservedObject var queuedTikTokDownloader: QueuedTikTokDownloader
    
    @Environment(\.managedObjectContext) private var viewContext
    
    @EnvironmentObject private var postDownloaderAndSaverAndBackuper: PostDownloaderAndSaverAndBackuper
    
    private let introVideo1URL = Bundle.main.url(forResource: "Intro 1 Clip-MPEG-4", withExtension: "mp4")!
    
    private let recentPostWidth: CGFloat = 250.0
    private let recentPostMaxHeight: CGFloat = 450.0
    
    @FetchRequest(sortDescriptors: [NSSortDescriptor(key: #keyPath(Post.saveDate), ascending: false)])
    private var posts: FetchedResults<Post>
    
    @StateObject var mediaICloudUploadUpdater = MediaICloudUploadUpdater()
    
    @State private var presentingPost: Post?
    
    @State private var showAllPosts: Bool = false
    
    @State private var isShowingTikTokInstructions: Bool = false // TODO: Add Instagram and YouTube instructions
    
    @State private var currentScrollPositioniOS17: Int? = 0
    
    // TODO: Just show the recent ones starting from the front
    var body: some View {
        Group {
            if posts.isEmpty {
                VStack {
                    VStack(spacing: 8.0) {
                        Text("Keep Your Favorite Posts Forever")
                            .font(.custom(Constants.FontName.body, size: 17.0))
//                            .padding(.vertical)
                        Image(systemName: "lock")
                            .font(.custom(Constants.FontName.light, size: 28.0))
//                            .padding(.vertical)
                    }
                    .foregroundStyle(Colors.text)
                    .frame(maxWidth: .infinity)
                    .padding()
                    .background(Colors.background)
                    .clipShape(RoundedRectangle(cornerRadius: 14.0))
                    .padding(.vertical)
                    
                    Text("To start, paste link above or...")
                        .font(.custom(Constants.FontName.lightOblique, size: 14.0))
                        .foregroundStyle(Colors.text)
                        .padding(.top)
                        .padding(.top)
                    
                    HStack {
                        Image(systemName: "square.and.arrow.up")
                            .font(.custom(Constants.FontName.heavy, size: 28.0))
                            .foregroundStyle(Colors.text)
                            .offset(y: -4)
                        Text("Share to")
                            .font(.custom(Constants.FontName.heavy, size: 28.0))
                            .foregroundStyle(Colors.text)
                        Image(Images.logoText)
                            .resizable()
                            .aspectRatio(contentMode: .fit)
                            .frame(width: 60.0, height: 60.0)
                            .foregroundStyle(Colors.accent)
                            .background(RoundedRectangle(cornerRadius: 14.0)
                                .fill(Colors.background)) // Typically foreground but because this is on foreground it is background
                            .aspectRatio(contentMode: .fit)
                    }
                    
                    Text("from any app.")
                        .font(.custom(Constants.FontName.lightOblique, size: 14.0))
                        .foregroundStyle(Colors.text)
                    
                    Button(action: {
                        isShowingTikTokInstructions = true
                    }) {
                        HStack {
                            Image(systemName: "info.circle")
                            Text("Show Tutorial")
                        }
                        .font(.custom(Constants.FontName.medium, size: 20.0))
                        .foregroundStyle(Colors.elementBackgroundColor)
                    }
                    .padding(.top, 28.0)
                    
                    Spacer()
                }
                .padding(.horizontal)
            } else {
                FeedView(
                    isSelecting: $isSelecting,
                    selected: $selected,
                    posts: _posts,
                    onSelectPost: { presentingPost = $0 })
            }
        }
        .alert("Error GRABbing", isPresented: $queuedTikTokDownloader.alertShowingErrorDownloadingPost, actions: {
            Button("Done", role: .cancel) { }
        }) {
            Text("Could not download post. Please check the URL and try again.")
        }
//        SingleAxisGeometryReader(axis: .horizontal) { width in
//            ScrollViewReader { proxy in
//                Group {
//                    if #available(iOS 17.0, *) {
//                        ScrollView(.horizontal) {
//                            HStack {
////                                Spacer(minLength: (width - recentPostWidth) / 2)
//                                ForEach(posts.indices, id: \.self) { postIndex in
//                                    PostDownloaderRowButton(
//                                        post: posts[postIndex],
//                                        onSelect: { presentingPost = posts[postIndex] } )
//                                    .id(postIndex)
//                                    .aspectRatio(contentMode: .fit)
//                                    .frame(width: recentPostWidth)
//                                    .containerRelativeFrame(.horizontal)
//                                }
////                                Spacer(minLength: (width - recentPostWidth) / 2)
//                            }
//                            .scrollTargetLayout()
////                            .padding(.horizontal, (width - recentPostWidth) / 2)
//                        }
//                        .scrollTargetBehavior(.viewAligned)
//                        .scrollPosition(id: $currentScrollPositioniOS17)
//                        .overlay {
//                            HStack {
//                                if let currentScrollPositioniOS17 {
//                                    if currentScrollPositioniOS17 > 0 {
//                                        Button(action: {
//                                            withAnimation {
//                                                self.currentScrollPositioniOS17? -= 1
//                                            }
//                                        }) {
//                                            Text(Image(systemName: "chevron.left"))
//                                                .font(.custom(Constants.FontName.heavy, size: 17.0))
//                                                .opacity(0.4)
//                                                .padding()
//                                        }
//                                    }
//                                    
//                                    Spacer()
//                                    
//                                    if currentScrollPositioniOS17 < (posts.count - 1) {
//                                        Button(action: {
//                                            withAnimation {
//                                                self.currentScrollPositioniOS17? += 1
//                                            }
//                                        }) {
//                                            Text(Image(systemName: "chevron.right"))
//                                                .font(.custom(Constants.FontName.heavy, size: 17.0))
//                                                .opacity(0.4)
//                                                .padding()
//                                        }
//                                    }
//                                }
//                            }
//                        }
//                    } else {
//                        ScrollView(.horizontal) {
//                            HStack {
//                                Spacer(minLength: (width - recentPostWidth) / 2)
//                                ForEach(posts) { post in
//                                    PostDownloaderRowButton(
//                                        post: post,
//                                        onSelect: { presentingPost = post } )
//                                    .aspectRatio(contentMode: .fit)
//                                    .frame(width: recentPostWidth)
//                                }
//                                Spacer(minLength: (width - recentPostWidth) / 2)
//                            }
//                        }
//                    }
//                }
//                .scrollIndicators(.hidden)
//            }
//        }
        
//        ScrollViewReader { proxy in
//            if queuedTikTokDownloader.recentlyDownloadedPosts.count == 1,
//               let post = queuedTikTokDownloader.recentlyDownloadedPosts.first {
//                PostDownloaderRowButton(
//                    post: post,
//                    onSelect: {
//                        presentingPost = post
//                    })
//                    .background(RoundedRectangle(cornerRadius: 5.0)
//                        .fill(Colors.background))
//                    .aspectRatio(contentMode: .fit)
//                    .frame(maxWidth: 350.0, maxHeight: 350.0)
//                    .padding()
//                
//            } else if !showAllPosts {
//                ZStack {
//                    let topPost = queuedTikTokDownloader.recentlyDownloadedPosts[safe: queuedTikTokDownloader.recentlyDownloadedPosts.count - 1]
//                    let midPost = queuedTikTokDownloader.recentlyDownloadedPosts[safe: queuedTikTokDownloader.recentlyDownloadedPosts.count - 2]
//                    let underPost = queuedTikTokDownloader.recentlyDownloadedPosts[safe: queuedTikTokDownloader.recentlyDownloadedPosts.count - 3]
//                    
//                    if let underPost = underPost {
//                        PostDownloaderRowView(post: underPost)
//                            .background(RoundedRectangle(cornerRadius: 5.0)
//                                .fill(Colors.background))
//                            .aspectRatio(contentMode: .fit)
//                            .frame(maxWidth: 350.0, maxHeight: 350.0)
//                            .padding()
//                            .rotationEffect(.degrees(-11), anchor: .bottom)
//                    }
//                    
//                    if let midPost = midPost {
//                        PostDownloaderRowView(post: midPost)
//                            .background(RoundedRectangle(cornerRadius: 5.0)
//                                .fill(Colors.background))
//                            .aspectRatio(contentMode: .fit)
//                            .frame(maxWidth: 350.0, maxHeight: 350.0)
//                            .padding()
//                            .rotationEffect(.degrees(11), anchor: .bottom)
//                    }
//                    
//                    if let topPost = topPost {
//                        PostDownloaderRowView(post: topPost)
//                            .background(RoundedRectangle(cornerRadius: 5.0)
//                                .fill(Colors.background))
//                            .aspectRatio(contentMode: .fit)
//                            .frame(maxWidth: 350.0, maxHeight: 350.0)
//                            .padding()
//                    }
//                }
//                .onTapGesture {
//                    showAllPosts = true
//                }
//            } else {
//                ScrollView(.horizontal) {
//                    HStack {
//                        ForEach(queuedTikTokDownloader.recentlyDownloadedPosts) { post in
//                            PostDownloaderRowButton(
//                                post: post,
//                                onSelect: { presentingPost = post } )
//                        }
//                    }
//                }
//            }
//        }
        .fullScreenCover(isPresented: $isShowingTikTokInstructions) {
            IntroVideoView(
                headerTopText: "Keep favorite posts",
                headerBottomText: "FOREVER",
                iconSystemName: "lock",
                videoURL: introVideo1URL,
                onNext: {
                    isShowingTikTokInstructions = false
                })
        }
        .postContainer(post: $presentingPost)
        .task { // Begin processing queue
            // Ensure authToken
            let authToken: String
            do {
                authToken = try await AuthHelper.ensure()
            } catch {
                // TODO: Handle Errors
                print("Error ensuring authToken in ShareViewController... \(error)")
                return
            }

            queuedTikTokDownloader.startProcessingQueue(
                authToken: authToken,
                postDownloaderAndSaverAndBackuper: postDownloaderAndSaverAndBackuper,
                mediaICloudUploadUpdater: mediaICloudUploadUpdater,
                managedContext: viewContext)
        }
    }
    
}

#Preview {
    
    ZStack {
        Colors.foreground
        ScrollView {
            QueuedPostDownloaderView(
                isSelecting: .constant(false),
                selected: .constant([]),
                queuedTikTokDownloader: QueuedTikTokDownloader())
        }
    }
    .environmentObject(PostDownloaderAndSaverAndBackuper())

}
