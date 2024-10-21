//
//  QueuedPostDownloaderView.swift
//  SocialBackup
//
//  Created by Alex Coundouriotis on 10/19/24.
//

import SwiftUI

struct QueuedPostDownloaderView: View {
    
    @ObservedObject var queuedTikTokDownloader: QueuedTikTokDownloader
    
    @Environment(\.managedObjectContext) private var viewContext
    
    private let recentPostWidth: CGFloat = 250.0
    private let recentPostMaxHeight: CGFloat = 450.0
    
    @FetchRequest(sortDescriptors: [NSSortDescriptor(key: #keyPath(Post.saveDate), ascending: false)])
    private var posts: FetchedResults<Post>
    
    @StateObject var mediaICloudUploadUpdater = MediaICloudUploadUpdater()
    
    @State private var presentingPost: Post?
    
    @State private var showAllPosts: Bool = false
    
    // TODO: Just show the recent ones starting from the front
    var body: some View {
        SingleAxisGeometryReader(axis: .horizontal) { width in
            ScrollViewReader { proxy in
                Group {
                    if #available(iOS 17.0, *) {
                        ScrollView(.horizontal) {
                            HStack {
//                                Spacer(minLength: (width - recentPostWidth) / 2)
                                ForEach(posts) { post in
                                    PostDownloaderRowButton(
                                        post: post,
                                        onSelect: { presentingPost = post } )
                                    .aspectRatio(contentMode: .fit)
                                    .frame(width: recentPostWidth)
                                }
//                                Spacer(minLength: (width - recentPostWidth) / 2)
                            }
                            .padding(.horizontal, (width - recentPostWidth) / 2)
                        }
//                        .scrollTargetBehavior(.paging)
                    } else {
                        ScrollView(.horizontal) {
                            HStack {
                                Spacer(minLength: (width - recentPostWidth) / 2)
                                ForEach(posts) { post in
                                    PostDownloaderRowButton(
                                        post: post,
                                        onSelect: { presentingPost = post } )
                                    .aspectRatio(contentMode: .fit)
                                    .frame(width: recentPostWidth)
                                }
                                Spacer(minLength: (width - recentPostWidth) / 2)
                            }
                        }
                    }
                }
                .scrollIndicators(.hidden)
            }
        }
        
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
                mediaICloudUploadUpdater: mediaICloudUploadUpdater,
                managedContext: viewContext)
        }
    }
    
}

//#Preview {
//    
//    QueuedPostDownloaderView()
//
//}
