//
//  PostDownloaderView.swift
//  SocialBackup
//
//  Created by Alex Coundouriotis on 10/9/24.
//

import GradientLoadingBar
import Photos
import SwiftUI

struct PostDownloaderView: View {
    
    @Binding var shouldBumpUpTabView: Bool
    
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
    
    enum DownloadStatus {
        case hidden
        case loading
        case success
        case error
    }
    
    @State private var testable: Bool = false
    
    @Environment(\.managedObjectContext) private var viewContext
    
    @EnvironmentObject private var mediaICloudUploadUpdater: MediaICloudUploadUpdater
    @EnvironmentObject private var postDownloaderAndSaverAndBackuper: PostDownloaderAndSaverAndBackuper
    
//    @FetchRequest(sortDescriptors: [NSSortDescriptor(keyPath: \Post.lastModifyDate, ascending: false)])
//    private var recentPosts: FetchedResults<Post>
    
    @StateObject private var queuedTikTokDownloader: QueuedTikTokDownloader = QueuedTikTokDownloader()
    
    @State private var isSelecting: Bool = false
    @State private var selected: [Post] = []
    @State private var downloadStatus: DownloadStatus = .hidden
    
//    @State private var recentlyDownloadedPosts: [Post] = [] // Recently downloaded posts in order from PostDownloadMiniContainer
    
    @State private var presentingPost: Post?
    
    @State private var isShowingUltraView: Bool = false
    
//    @State private var isLoadingDownloadPost: Bool = false
    
    @State private var animatingIsLoadingDownloadPostResultState: IsLoadingDownloadPostResultStates = .idle//isAnimatingIsLoadingDownloadPostResult: Bool = false
    
    private var isShowingDownloadStatus: Binding<Bool> {
        Binding(
            get: {
                downloadStatus != .hidden
            },
            set: { value in
                if !value {
                    downloadStatus = .hidden
                }
            })
    }
    
    private var selectedImagesLocalFilepaths: [String] {
        selected.flatMap({ post in
            // Get media from post
            let fetchRequest = Media.fetchRequest()
            fetchRequest.predicate = NSPredicate(format: "%K = %@", #keyPath(Media.post), post)
            let medias: [Media]
            do {
                medias = try viewContext.performAndWait { try viewContext.fetch(fetchRequest) }
            } catch {
                print("Error fetching media in PostDownloaderView, continuing... \(error)")
                medias = []
            }
            
            // Get all photos local filepaths if there are
            let allPhotosLocalFilepaths: [String] = medias.compactMap({ media in
                if let localFilename = media.localFilename,
                   let subdirectory = post.subdirectory {
                    let filepath = "\(subdirectory)/\(localFilename)"
                    if MediaTypeFromExtension.getMediaType(fromFilename: filepath) == .image {
                        return filepath
                    }
                }
                return nil
            })
            
            return allPhotosLocalFilepaths
        })
    }
    
    private var selectedVideosLocalFilepaths: [String] {
        selected.compactMap({ post in
            // Get media from post
            let fetchRequest = Media.fetchRequest()
            fetchRequest.predicate = NSPredicate(format: "%K = %@", #keyPath(Media.post), post)
            let medias: [Media]
            do {
                medias = try viewContext.performAndWait { try viewContext.fetch(fetchRequest) }
            } catch {
                print("Error fetching media in PostDownloaderView, continuing... \(error)")
                medias = []
            }
            
            // Get the highest quality video local filepath if it is there
            let highestQualityVideoLocalFilepath: String? = {
                if medias.contains(where: { // If contains a video, check for the highest quality video
                    if let filename = $0.localFilename,
                       let subdirectory = post.subdirectory {
                        let filepath = "\(subdirectory)/\(filename)"
                        return MediaTypeFromExtension.getMediaType(fromFilename: filepath) == .video
                    }
                    return false
                }) {
                    if let subdirectory = post.subdirectory,
                       let localFilename = medias.sorted(by: { $0.index < $1.index }).first(where: { $0.localFilename != nil })?.localFilename {
                        return "\(subdirectory)/\(localFilename)"
                    }
                }
                return nil
            }()
            
            return highestQualityVideoLocalFilepath
        })
    }
    
//    private var selectedMappedMediaForSave: [Data] {
//        selected.flatMap({ post in
//            // Get media from post
//            let fetchRequest = Media.fetchRequest()
//            fetchRequest.predicate = NSPredicate(format: "%K = %@", #keyPath(Media.post), post)
//            let medias: [Media]
//            do {
//                medias = try viewContext.performAndWait { try viewContext.fetch(fetchRequest) }
//            } catch {
//                print("Error fetching media in PostDownloaderView, continuing... \(error)")
//                medias = []
//            }
//            
//            // Get the highest quality video local filepath if it is there
//            let highestQualityVideoLocalFilepath: String? = {
//                if medias.contains(where: { // If contains a video, check for the highest quality video
//                    if let filename = $0.localFilename,
//                       let subdirectory = post.subdirectory {
//                        let filepath = "\(subdirectory)/\(filename)"
//                        return MediaTypeFromExtension.getMediaType(fromFilename: filepath) == .video
//                    }
//                    return false
//                }) {
//                    if let subdirectory = post.subdirectory,
//                       let localFilename = medias.sorted(by: { $0.index < $1.index }).first(where: { $0.localFilename != nil })?.localFilename {
//                        return "\(subdirectory)/\(localFilename)"
//                    }
//                }
//                return nil
//            }()
//            
//            // Get all photos local filepaths if there are
//            let allPhotosLocalFilepaths: [String] = medias.compactMap({ media in
//                if let localFilename = media.localFilename,
//                   let subdirectory = post.subdirectory {
//                    let filepath = "\(subdirectory)/\(localFilename)"
//                    if MediaTypeFromExtension.getMediaType(fromFilename: filepath) == .image {
//                        return filepath
//                    }
//                }
//                return nil
//            })
//            
//            // Get data from each
//            var shareData: [Data] = []
//            if let highestQualityVideoLocalFilepath {
//                do {
//                    if let data = try DocumentSaver.getData(from: highestQualityVideoLocalFilepath){
//                        shareData.append(data)
//                    }
//                } catch {
//                    // TODO: Handle Errors
//                    print("Error getting data from highestQualityVideoLocalFilepath... \(error)")
//                }
//            }
//            for photoLocalFilepath in allPhotosLocalFilepaths {
//                do {
//                    if let data = try DocumentSaver.getData(from: photoLocalFilepath) {
//                        shareData.append(data)
//                    }
//                } catch {
//                    // TODO: Handle Errors
//                    print("Error getting data from photoLocalFilepath... \(error)")
//                }
//            }
//            
//            // Return
//            return shareData
//        })
//    }
    
    var body: some View {
        NavigationStack {
            ScrollView {
                VStack(spacing: 0.0) {
                    // Input
                    PostDownloadMiniContainer(
                        isLoading: $queuedTikTokDownloader.isProcessing,
                        onSubmit: { urlString in
                            QueuedTikTokDownloader.enqueue(urlString: urlString)
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
                    QueuedPostDownloaderView(
                        isSelecting: $isSelecting,
                        selected: $selected,
                        queuedTikTokDownloader: queuedTikTokDownloader)
                    
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
                ToolbarItem(placement: .topBarLeading) {
                    Button(action: { withAnimation(.bouncy(duration: 0.5)) { isSelecting.toggle() } }) {
                        Text(isSelecting ? "Done" : "Select")
                            .font(.custom(isSelecting ? Constants.FontName.heavy : Constants.FontName.body, size: 17.0))
                            .foregroundStyle(Colors.text)
                    }
                }
                
                LogoToolbarItem()
                
                if !PremiumUpdater.get() {
                    UltraToolbarItem(isShowingUltraView: $isShowingUltraView)
                }
                
//                if isSelecting {
//                    // Share selection
//                    ToolbarItem(placement: .bottomBar) {
//                        HStack {
//                            Spacer()
//                            
//                            Button(action: {
//                                // TODO: Share items
//                            }) {
//                                Image(systemName: "square.and.arrow.up")
//                                    .foregroundStyle(Colors.text)
//                            }
//                        }
//                    }
//                }
            }
            .postContainer(post: $presentingPost)
        }
        .safeAreaInset(edge: .bottom, alignment: .trailing) {
            if isSelecting {
                HStack {
                    Spacer()
                    
                    // Download items
                    Button(action: {
                        DispatchQueue.main.async {
                            withAnimation {
                                self.downloadStatus = .loading
                            }
                        }
                        PHPhotoLibrary.shared().performChanges({
                            for imageLocalFilepath in selectedImagesLocalFilepaths {
                                PHAssetChangeRequest.creationRequestForAssetFromImage(atFileURL: DocumentSaver.getFullContainerURL(from: imageLocalFilepath))
                            }
                            for videoLocalFilepath in selectedVideosLocalFilepaths {
                                PHAssetChangeRequest.creationRequestForAssetFromVideo(atFileURL: DocumentSaver.getFullContainerURL(from: videoLocalFilepath))
                            }
                        }, completionHandler: { success, error in
                            DispatchQueue.main.async {
                                withAnimation {
                                    if success {
                                        self.downloadStatus = .success
                                    } else {
                                        self.downloadStatus = .error
                                    }
                                }
                                
                                DispatchQueue.main.asyncAfter(deadline: .now() + 1.0) {
                                    withAnimation {
                                        self.downloadStatus = .hidden
                                    }
                                }
                            }
                        })
                    }) {
                        Image(systemName: "square.and.arrow.down")
                            .font(.custom(Constants.FontName.body, size: 17.0))
                            .foregroundStyle(Colors.text)
                            .padding()
                    }
                    
//                    ShareLink(items: selectedMappedMediaForShare) {
//                        Image(systemName: "square.and.arrow.up")
//                            .font(.custom(Constants.FontName.body, size: 17.0))
//                            .foregroundStyle(Colors.text)
//                            .padding()
//                    }
//                    Button(action: {
//                        // TODO: Share items
//                    }) {
//                        Image(systemName: "square.and.arrow.up")
//                            .font(.custom(Constants.FontName.body, size: 17.0))
//                            .foregroundStyle(Colors.text)
//                            .padding()
//                    }
                }
                .background(Colors.background)
                .transition(.move(edge: .bottom))
            }
        }
        .clearFullScreenCover(isPresented: isShowingDownloadStatus, backgroundTapDismisses: false) {
            VStack {
                Text(downloadStatus == .loading ? "Saving..." : (downloadStatus == .success ? "Saved" : "Error"))
                    .font(.custom(Constants.FontName.body, size: 17.0))
                    .foregroundStyle(Colors.text)
                if downloadStatus == .loading {
                    ProgressView()
                        .tint(Colors.accent)
                } else if downloadStatus == .success {
                    Image(systemName: "checkmark")
                        .font(.custom(Constants.FontName.body, size: 20.0))
                        .foregroundStyle(Colors.accent)
                } else if downloadStatus == .error {
                    Image(systemName: "exclamationmark")
                        .font(.custom(Constants.FontName.body, size: 20.0))
                        .foregroundStyle(Color(.systemRed))
                }
            }
            .padding()
            .background(Colors.foreground)
            .clipShape(RoundedRectangle(cornerRadius: 14.0))
        }
        .ultraViewPopover(isPresented: $isShowingUltraView)
        .onChange(of: isSelecting) { newValue in
            withAnimation(.bouncy(duration: 0.5)) {
                shouldBumpUpTabView = newValue
            }
        }
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
            postDownloaderAndSaverAndBackuper: postDownloaderAndSaverAndBackuper,
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
        PostDownloaderView(shouldBumpUpTabView: .constant(false))
            .background(Colors.background)
            .environment(\.managedObjectContext, CDClient.mainManagedObjectContext)
    }
    
}
