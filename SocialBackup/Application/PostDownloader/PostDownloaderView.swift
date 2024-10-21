//
//  PostDownloaderView.swift
//  SocialBackup
//
//  Created by Alex Coundouriotis on 10/9/24.
//

import GradientLoadingBar
import SwiftUI

struct PostDownloaderView: View {
    
    /**
     How should the database be structured?
     
     Well, there are
     - tiktok posts
     - collections (of posts)
     
     The tiktok post should somehow be stored in the user's drive so it syncs with iCloud.
     
     There should be a switch for "local" and "iCloud" in each post's settings, and also have the ability to remove locally and from iCloud with a long press
     
     */
    
    enum IsLoadingDownloadPostResultStates {
        case idle
        case downloading
        case animatingIn
    }
    
    @State private var testable: Bool = false
    
    @Environment(\.managedObjectContext) private var viewContext
    
    @EnvironmentObject private var mediaICloudUploadUpdater: MediaICloudUploadUpdater
    
//    @FetchRequest(sortDescriptors: [NSSortDescriptor(keyPath: \Post.lastModifyDate, ascending: false)])
//    private var recentPosts: FetchedResults<Post>
    
    @StateObject private var queuedTikTokDownloader: QueuedTikTokDownloader = QueuedTikTokDownloader()
    
//    @State private var recentlyDownloadedPosts: [Post] = [] // Recently downloaded posts in order from PostDownloadMiniContainer
    
    @State private var presentingPost: Post?
    
    @State private var isShowingUltraView: Bool = false
    
//    @State private var isLoadingDownloadPost: Bool = false
    
    @State private var animatingIsLoadingDownloadPostResultState: IsLoadingDownloadPostResultStates = .idle//isAnimatingIsLoadingDownloadPostResult: Bool = false
    
    var body: some View {
        NavigationStack {
            ScrollView {
                VStack(spacing: 0.0) {
                    // Input
                    PostDownloadMiniContainer(
                        isLoading: $queuedTikTokDownloader.isProcessing,
                        onSubmit: { urlString in
                            queuedTikTokDownloader.enqueue(urlString: urlString)
                            Task {
                                await startQueue()
                            }
                        
//                        // Add to recentlyDownloadedPosts
//                        withAnimation {
//                            recentlyDownloadedPosts.append(post)
//                        }
                    })
                    .padding(.top)
                    .padding(.horizontal)
                    .padding(.bottom)
                    .background(Colors.background)
                    .zIndex(1)
                    
                    Divider()
                        .zIndex(1)
                    
                    Group {
                        if animatingIsLoadingDownloadPostResultState == .downloading {
                            GradientLoadingBarView(gradientColors: [.purple, .yellow], progressDuration: 1.0)
                        } else if animatingIsLoadingDownloadPostResultState == .animatingIn {
                            GradientLoadingBarView(gradientColors: [.green, .yellow], progressDuration: 1.0)
                        }
                    }
                    .frame(height: 5.0)
                    .transition(.move(edge: .top))
                    
                    // Downloaded posts
                    QueuedPostDownloaderView(queuedTikTokDownloader: queuedTikTokDownloader)
                    
//                    // Most recent posts
//                    ZStack {
//                        if recentlyDownloadedPosts.isEmpty {
//                            VStack {
//                                Spacer(minLength: 50.0)
//                                VStack(spacing: 16.0) {
//                                    Text("How to Grab")
//                                        .font(.custom(Constants.FontName.heavy, size: 28.0))
//                                        .foregroundStyle(Colors.text)
//                                    
//                                    VStack(alignment: .leading, spacing: 16.0) {
//                                        Text("**\(Image(systemName: "link"))** Paste social media post link")
//                                        Text("**\(Image(systemName: "square.and.arrow.up"))** Share post to **APP_NAME**")
//                                    }
//                                    .font(.custom(Constants.FontName.body, size: 17.0))
//                                    .foregroundStyle(Colors.text)
//                                    
//                                    Text("")
//                                }
//                            }
//                        }
//                        
//                        ForEach(recentlyDownloadedPosts) { post in
//                            PostDownloaderRowButton(post: post, onSelect: { presentingPost = post })
//                                .background(RoundedRectangle(cornerRadius: 5.0)
//                                    .fill(Colors.background))
//                                .aspectRatio(contentMode: .fit)
//                                .frame(maxWidth: 350.0, maxHeight: 350.0)
//                                .padding()
//                        }
//                    }
                }
            }
            .overlay(alignment: .top) {
                // Color the top part
                Colors.background
                    .ignoresSafeArea()
                    .frame(maxHeight: 0.0)
            }
            .background(Colors.foreground)
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                LogoToolbarItem()
                
                UltraToolbarItem(isShowingUltraView: $isShowingUltraView)
            }
            .postContainer(post: $presentingPost)
        }
        .ultraViewPopover(isPresented: $isShowingUltraView)
        .onReceive(queuedTikTokDownloader.$isProcessing) { newValue in
            if newValue {
                withAnimation {
                    animatingIsLoadingDownloadPostResultState = .downloading
                }
            } else {
                if animatingIsLoadingDownloadPostResultState == .downloading {
                    withAnimation {
                        animatingIsLoadingDownloadPostResultState = .animatingIn
                    }
                    
                    DispatchQueue.main.asyncAfter(deadline: .now() + 1.0) {
                        withAnimation {
                            animatingIsLoadingDownloadPostResultState = .idle
                        }
                    }
                } else {
                    withAnimation {
                        animatingIsLoadingDownloadPostResultState = .idle
                    }
                }
            }
        }
    }
    
    func startQueue() async  {
        // Ensure quthToken
        let authToken: String
        do {
            authToken = try await AuthHelper.ensure()
        } catch {
            // TODO: Handle Errors
            print("Error ensuring authToken in PostDownloaderView... \(error)")
            return
        }
        
        queuedTikTokDownloader.startProcessingQueue(
            authToken: authToken,
            mediaICloudUploadUpdater: mediaICloudUploadUpdater,
            managedContext: viewContext)
    }
    
}

#Preview {
    
    let postCollection: PostCollection = {
        let postCollection = PostCollection(context: CDClient.mainManagedObjectContext)
        postCollection.title = "Test Collection"
        
        for i in 0..<5 {
            let post = Post(context: CDClient.mainManagedObjectContext)
            post.thumbnail = UIImage(named: "thumbnail1")?.jpegData(compressionQuality: 8)
            post.addToCollections(postCollection)
            post.lastModifyDate = Date()
        }
        
        try! CDClient.mainManagedObjectContext.save()
        
        return postCollection
    }()
    
    return NavigationStack {
        PostDownloaderView()
            .background(Colors.background)
            .environment(\.managedObjectContext, CDClient.mainManagedObjectContext)
    }
    
}
