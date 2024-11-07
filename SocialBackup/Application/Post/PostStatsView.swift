//
//  PostStatsView.swift
//  SocialBackup
//
//  Created by Alex Coundouriotis on 10/11/24.
//

import SwiftUI

struct PostStatsView: View {
    
    var post: Post
//    var postInfo: GetPostInfoResponse
//    var summary: VideoSummarySO?
//    var transcriptions: [String]
    @FetchRequest var medias: FetchedResults<Media>
    @Binding var isLoadingSummary: Bool
    var onAddToCollection: () -> Void
    var onGenerateSummary: () -> Void
    var onOpenTranscriptionsView: () -> Void
    var onSelectCategory: (_ category: String) -> Void
    var onSelectEmotion: (_ emotion: String) -> Void
    var onSelectTag: (_ tag: String) -> Void
    var onSelectKeyword: (_ keyword: String) -> Void
    
    @Environment(\.openURL) private var openURL
    @Environment(\.managedObjectContext) private var viewContext
    
//    @FetchRequest(
//        sortDescriptors: [NSSortDescriptor(key: #keyPath(Media.index), ascending: true)],
//        predicate: NSPredicate(format: "%K = %@", #keyPath(Media.post), post))
//    private var medias: FetchedResults<Media>
    
//    @State private var isShowingTranscriptions: Bool = false
    
    private var postInfo: GetPostInfoResponse? {
        try? post.getGetPostInfoResponseObject()
    }
    
    private var postTranscriptions: [String] {
        medias.compactMap(\.transcription)
    }
    
    var body: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: 16) {
                // Author Info
                if let author = postInfo?.body.downloadResponse.author {
                    HStack(spacing: 12) {
                        // Since the avatar URL is not available, display a placeholder
                        Circle()
                            .fill(Color.gray)
                            .frame(width: 50.0, height: 50.0)
                            .overlay(
                                Text(author.prefix(1).uppercased())
                                    .font(.custom(Constants.FontName.heavy, size: 20.0))
                                    .foregroundColor(.white)
                            )
                            .overlay(alignment: .bottomTrailing) {
                                if let sourceString = postInfo?.body.downloadResponse.source,
                                   let source = PostSource.from(sourceString) {
                                    Image(source.imageName)
                                        .resizable()
                                        .aspectRatio(contentMode: .fit)
                                        .frame(width: 28.0, height: 28.0)
                                        .offset(x: 6, y: 6)
                                }
                                
                            }
                        
                        // Author Name and username
                        VStack(alignment: .leading) {
                            Text(author)
                                .font(.custom(Constants.FontName.heavy, size: 17.0))
                            if let extractedUsername = post.extractedUsername {
                                Text(extractedUsername)
                                    .font(.custom(Constants.FontName.body, size: 12.0))
                            }
                        }
                        
                        Spacer()
                        
                        Button(action: onAddToCollection) {
                            HStack {
                                Image(systemName: "plus")
                                    .font(.custom(Constants.FontName.body, size: 10.0))
                                Text("to Collection")
                            }
                            .miniButtonStyle()
                        }
                    }
                }

                // Post Title
                if let title = post.generatedTitle {
                    Text(title)
                        .font(.custom(Constants.FontName.heavy, size: 20.0))
                }
                
                // Original Title
                if let title = postInfo?.body.downloadResponse.title {
                    VStack(alignment: .leading, spacing: 0.0) {
                        if post.generatedTitle != nil {
                            Text("Original Title")
                                .font(.custom(Constants.FontName.heavy, size: 10.0))
                        }
                        
                        Text(title)
                            .font(.custom(Constants.FontName.body, size: 17.0))
                    }
                }
                
                // Post Topic
                if let topic = post.generatedTopic {
                    VStack(alignment: .leading, spacing: 0.0) {
                        Text("Topic:")
                            .font(.custom(Constants.FontName.heavy, size: 10.0))
                        Text(topic)
                            .font(.custom(Constants.FontName.body, size: 14.0))
                    }
                }
                
                // Post Short Summary
                if let shortSummary = post.generatedShortSummary {
                    VStack(alignment: .leading, spacing: 0.0) {
                        Text("Summary:")
                            .font(.custom(Constants.FontName.heavy, size: 10.0))
                        Text(shortSummary)
                            .font(.custom(Constants.FontName.body, size: 17.0))
                    }
                }
                
                // AI
                if post.generatedFieldIsNil && !isLoadingSummary { // TODO: Check if premium
                    if postTranscriptions.isEmpty {
                        Text("Awaiting Transcriptions...")
                            .frame(maxWidth: .infinity, alignment: .center)
                            .overlay(alignment: .trailing) {
                                ProgressView()
                                    .tint(Colors.foreground)
                            }
                            .appButtonStyle(foregroundColor: Colors.foreground, backgroundColor: Colors.accent)
                    } else {
                        Button(action: onGenerateSummary) {
                            Text("\(Image(systemName: "sparkles"))AI")
                                .frame(maxWidth: .infinity, alignment: .center)
                                .overlay(alignment: .trailing) {
                                    PremiumUpdater.get() ? Image(systemName: "chevron.right") : Image(systemName: "lock")
                                }
                                .appButtonStyle(foregroundColor: Colors.foreground, backgroundColor: Colors.accent)
                        }
                    }
                }
                if isLoadingSummary {
                    Text("Loading \(Image(systemName: "sparkles"))AI...")
                        .frame(maxWidth: .infinity, alignment: .center)
                        .overlay(alignment: .trailing) {
                            ProgressView()
                                .tint(Colors.foreground)
                        }
                        .appButtonStyle(foregroundColor: Colors.foreground, backgroundColor: Colors.accent)
                }
                
                // View transcriptions
                if !postTranscriptions.isEmpty {
                    Button(action: onOpenTranscriptionsView) {
                        Text("View Transcription")
                            .frame(maxWidth: .infinity, alignment: .center)
                            .overlay(alignment: .trailing) {
                                Image(systemName: "chevron.right")
                            }
                            .appButtonStyle()
                    }
                }
                
                // Post Duration
                if let duration = postInfo?.body.downloadResponse.duration {
                    if let sourceString = postInfo?.body.downloadResponse.source {
                        let source = PostSource.from(sourceString)
                        if source == .tiktok {
                            StatisticView(iconName: "clock.fill", value: formatDuration(duration / 1000)) // Divide by 1000 bc tiktok is in ms for some reason TODO: Better solution, for like if this changes so that the unit can be calculated before its display
                        } else {
                            StatisticView(iconName: "clock.fill", value: formatDuration(duration))
                        }
                    } else {
                        StatisticView(iconName: "clock.fill", value: formatDuration(duration))
                    }
                }
                
                // Source and Original URL
                if let sourceString = postInfo?.body.downloadResponse.source {
                    let source = PostSource.from(sourceString)
                    
                    HStack {
                        Group {
                            if let imageName = source?.imageName {
                                Image(imageName)
                                    .resizable()
                            } else {
                                Image(systemName: "questionmark")
                                    .resizable()
                            }
                        }
                        .aspectRatio(contentMode: .fit)
                        .frame(width: 28.0, height: 28.0)
                        
                        VStack(alignment: .leading) {
                            Text(source?.name ?? "*Unknown*")
                                .font(.custom(Constants.FontName.heavy, size: 14.0))
                            
                            if let urlString = postInfo?.body.downloadResponse.url {
                                Text(urlString)
                                    .font(.custom(Constants.FontName.body, size: 9.0))
                                    .lineLimit(1)
                            }
                        }
                            
                            
                        Spacer()
                        
                        if let urlString = postInfo?.body.downloadResponse.url,
                           let url = URL(string: urlString) {
                            Button(action: {
                                PasteboardHelper.copy(urlString)
                            }) {
                                Image(systemName: "doc.on.doc")
                                    .font(.custom(Constants.FontName.body, size: 12.0))
                                    .miniButtonStyle()
                            }
                            
                            Button(action: {
                                openURL(url)
                            }) {
                                HStack(spacing: 4.0) {
                                    Text("Open")
                                    Image(systemName: "chevron.right")
                                        .font(.custom(Constants.FontName.body, size: 10.0))
                                }
                                .miniButtonStyle()
                            }
                        }
                    }
                }
                
                // TODO: Post Categories
                if let categories = post.generatedCategoriesCSV?.split(separator: ",") {
                    VStack(alignment: .leading, spacing: 8.0) {
                        Text("Categories:")
                            .font(.custom(Constants.FontName.heavy, size: 10.0))
                        SingleAxisGeometryReader(axis: .horizontal) { geo in
                            HStack {
                                FlexibleView(
                                    availableWidth: geo.magnitude,
                                    data: categories,
                                    spacing: 8.0,
                                    alignment: .leading,
                                    content: { category in
                                        Button(action: { onSelectCategory(String(category)) }) {
                                            Text(category)
                                                .font(.custom(Constants.FontName.body, size: 14.0))
                                                .foregroundStyle(Colors.text)
                                                .padding(.horizontal)
                                                .padding(.vertical, 8)
                                                .background(Colors.foreground)
                                                .clipShape(RoundedRectangle(cornerRadius: 14.0))
                                        }
                                    })
                                Spacer()
                            }
                        }
                    }
                }
                
                // Post Emotions
                if let emotions = post.generatedEmotionsCSV?.split(separator: ",") {
                    VStack(alignment: .leading, spacing: 8.0) {
                        Text("Emotions:")
                            .font(.custom(Constants.FontName.heavy, size: 10.0))
                        SingleAxisGeometryReader(axis: .horizontal) { geo in
                            HStack {
                                FlexibleView(
                                    availableWidth: geo.magnitude,
                                    data: emotions,
                                    spacing: 8.0,
                                    alignment: .leading,
                                    content: { emotion in
                                        Button(action: { onSelectEmotion(String(emotion)) }) {
                                            Text(emotion)
                                                .font(.custom(Constants.FontName.body, size: 14.0))
                                                .foregroundStyle(Colors.text)
                                                .padding(.horizontal)
                                                .padding(.vertical, 8)
                                                .background(Colors.foreground)
                                                .clipShape(RoundedRectangle(cornerRadius: 14.0))
                                        }
                                    })
                                Spacer()
                            }
                        }
                    }
                }
                
                // Tags
                if let tags = post.generatedTagsCSV?.split(separator: ",") {
                    VStack(alignment: .leading, spacing: 8.0) {
                        Text("Tags:")
                            .font(.custom(Constants.FontName.heavy, size: 10.0))
                        SingleAxisGeometryReader(axis: .horizontal) { geo in
                            HStack {
                                FlexibleView(
                                    availableWidth: geo.magnitude,
                                    data: tags,
                                    spacing: 8.0,
                                    alignment: .leading,
                                    content: { tag in
                                        Button(action: { onSelectTag(String(tag)) }) {
                                            Text(tag)
                                                .font(.custom(Constants.FontName.body, size: 14.0))
                                                .foregroundStyle(Colors.text)
                                                .padding(.horizontal)
                                                .padding(.vertical, 8)
                                                .background(Colors.foreground)
                                                .clipShape(RoundedRectangle(cornerRadius: 14.0))
                                        }
                                    })
                                Spacer()
                            }
                        }
                    }
                }
                
                // Keywords
                if let keywords = post.generatedKeywordsCSV?.split(separator: ","),
                   let keyEntities = post.generatedKeyEntitiesCSV?.split(separator: ",") {
                    let keys = keywords + keyEntities
                    VStack(alignment: .leading, spacing: 8.0) {
                        Text("Keywords:")
                            .font(.custom(Constants.FontName.heavy, size: 10.0))
                        SingleAxisGeometryReader(axis: .horizontal) { geo in
                            HStack {
                                FlexibleView(
                                    availableWidth: geo.magnitude,
                                    data: keys,
                                    spacing: 8.0,
                                    alignment: .leading,
                                    content: { key in
                                        Button(action: { onSelectKeyword(String(key)) }) {
                                            Text(key)
                                                .font(.custom(Constants.FontName.body, size: 14.0))
                                                .foregroundStyle(Colors.text)
                                                .padding(.horizontal)
                                                .padding(.vertical, 8)
                                                .background(Colors.foreground)
                                                .clipShape(RoundedRectangle(cornerRadius: 14.0))
                                        }
                                    })
                                Spacer()
                            }
                        }
                    }
                }
            }
            .foregroundStyle(Colors.text)
            .padding()
        }
    }
    
    // Helper function to format duration from seconds to "Xm Ys"
    func formatDuration(_ duration: Double) -> String {
        let totalSeconds = Int(duration)
        let minutes = totalSeconds / 60
        let seconds = totalSeconds % 60
        return "\(minutes)m \(seconds)s"
    }
    
}

// Helper view for displaying statistics
struct StatisticView: View {
    
    var iconName: String
    var value: String

    var body: some View {
        HStack(spacing: 4) {
            Image(systemName: iconName)
                .foregroundColor(.gray)
            Text(value)
                .font(.subheadline)
                .foregroundColor(.gray)
        }
    }
    
}

// Sample usage with preview
struct PostStatsView_Previews: PreviewProvider {
    static var previews: some View {
        // Sample data for preview purposes
        let media = GetPostInfoResponse.Body.DownloaderResponse.Media(
            url: "https://example.com/post.mp4",
            quality: "HD",
            type: "post",
            ext: "mp4",
            id: "12345",
            duration: 120
        )
        
        let downloaderResponse = GetPostInfoResponse.Body.DownloaderResponse(
            url: "https://example.com",
            source: "ExampleSource",
            author: "AuthorName",
            title: "Post Title",
            thumbnail: "https://example.com/thumbnail.jpg",
            type: "post",
            error: false,
            duration: 125.0,
            medias: [media]
        )
        
        let postInfo = GetPostInfoResponse(
            body: GetPostInfoResponse.Body(downloadResponse: downloaderResponse),
            success: 1)
        
        let postSummary = VideoSummarySO(
            title: "Title",
            topic: "Topic",
            shortSummary: "This is the short summary",
            mediumSummary: "This is the medium summary",
            emotions: ["Happy", "Sad", "Neutral", "Happy", "Sad", "Neutral", "Happy", "Sad", "Neutral"],
            categories: ["First category", "second category", "THIRD category"],
            tags: ["Dogs", "Cats"],
            keywords: ["one keyword", "another", "keyword"],
            keyEntities: ["Barb", "Crab", "Deer", "Eeee", "Frank"])
        
        let post = CDClient.mainManagedObjectContext.performAndWait {
            let newMedia = Media(context: CDClient.mainManagedObjectContext)
            newMedia.title = "Media Title"
            newMedia.transcription = "Media Transcription"
            
            let post = Post(context: CDClient.mainManagedObjectContext)
            post.title = "Title"
            post.getPostInfoResponse = try! CodableDataAdapter.encode(postInfo)
            post.generatedTitle = "Generated Title"
            post.generatedTopic = "Generated Topic"
            post.generatedShortSummary = "This is the short summary"
            post.generatedMediumSummary = "This is the medium summary"
            post.generatedEmotionsCSV = "Happy,Sad,Neutral,Happy,Sad,Neutral,Happy,Sad,Neutral"
            post.generatedTagsCSV = "Dogs,Cats"
            post.generatedKeywordsCSV = "one keyword,another,keyword"
            post.generatedKeyEntitiesCSV = "Barb,Crab,Deer,Eeee,Frank"
            post.addToMedias(newMedia)
            return post
        }
        
        PostStatsView(
            post: post,
//            postInfo: postInfo,
            medias: FetchRequest(sortDescriptors: [NSSortDescriptor(key: #keyPath(Media.index), ascending: true)], predicate: NSPredicate(format: "%K = %@", #keyPath(Media.post), post)),
            isLoadingSummary: .constant(false),
            onAddToCollection: {},
            onGenerateSummary: {},
            onOpenTranscriptionsView: {},
            onSelectCategory: { _ in },
            onSelectEmotion: { _ in },
            onSelectTag: { _ in },
            onSelectKeyword: { _ in })
            .background(Colors.background)
    }
}


//struct PostStatsView: View {
//    
//    var postInfo: GetPostInfoResponse
//    var onAddToCollection: () -> Void
//
//    var body: some View {
//        ScrollView {
//            VStack(alignment: .leading, spacing: 16) {
////                // Post Cover Image
////                if let coverURL = URL(string: postInfo.downloadResponse.data.cover) {
////                    AsyncImage(url: coverURL) { image in
////                        image
////                            .resizable()
////                            .aspectRatio(contentMode: .fit)
////                            .cornerRadius(10)
////                    } placeholder: {
////                        ProgressView()
////                    }
////                }
//
//                // Author Info
//                HStack(spacing: 12) {
//                    // Author Avatar
////                    if let avatarURL = URL(string: postInfo.downloadResponse.data.author.avatar) {
////                        AsyncImage(url: avatarURL) { image in
////                            image
////                                .resizable()
////                                .frame(width: 60, height: 60)
////                                .clipShape(Circle())
////                        } placeholder: {
////                            ProgressView()
////                        }
////                    }
//
//                    // Author Name and ID
//                    VStack(alignment: .leading) {
////                        Text(postInfo.downloadResponse.author)
////                            .font(.headline)
//                        Text("@\(postInfo.downloadResponse.author)")
//                            .font(.subheadline)
//                            .foregroundColor(.gray)
//                    }
//                    
//                    Spacer()
//                    
//                    Button(action: onAddToCollection) {
//                        Text(Image(systemName: "plus.circle"))
//                            .font(.custom(Constants.FontName.body, size: 17.0))
//                    }
//                }
//
//                // Post Statistics
//                LazyVGrid(
//                    columns: [GridItem(.flexible()), GridItem(.flexible())],
//                    spacing: 20
//                ) {
////                    StatisticView(iconName: "play.fill", value: postInfo.downloadResponse.data.playCount)
////                    StatisticView(iconName: "hand.thumbsup.fill", value: postInfo.downloadResponse.data.diggCount)
////                    StatisticView(iconName: "bubble.right.fill", value: postInfo.downloadResponse.data.commentCount)
////                    StatisticView(iconName: "arrowshape.turn.up.right.fill", value: postInfo.downloadResponse.data.shareCount)
//                }
//                .padding(.vertical)
//                
//                // Post Title
//                Text(postInfo.downloadResponse.title)
//                    .font(.custom(Constants.FontName.heavy, size: 17.0))
//
//                // Music Info
//                HStack(spacing: 12) {
//                    // Music Cover Image
//                    if let musicCoverURL = URL(string: postInfo.downloadResponse.posts.first(where: { $0.type == .tiktok}) .data.musicInfo.cover) {
//                        AsyncImage(url: musicCoverURL) { image in
//                            image
//                                .resizable()
//                                .frame(width: 60, height: 60)
//                                .cornerRadius(10)
//                        } placeholder: {
//                            ProgressView()
//                        }
//                    }
//
//                    // Music Title and Author
//                    VStack(alignment: .leading) {
//                        Text(postInfo.downloadResponse.data.musicInfo.title)
//                            .font(.headline)
//                        Text(postInfo.downloadResponse.data.musicInfo.author)
//                            .font(.subheadline)
//                            .foregroundColor(.gray)
//                    }
//                }
//
//                Spacer()
//            }
//            .padding()
//        }
//    }
//    
//}
//
//// Helper view for displaying statistics
//struct StatisticView: View {
//    
//    var iconName: String
//    var value: Int
//
//    var body: some View {
//        HStack(spacing: 4) {
//            Image(systemName: iconName)
//                .foregroundColor(.gray)
//            Text("\(value)")
//                .font(.subheadline)
//                .foregroundColor(.gray)
//        }
//    }
//    
//}

//#Preview {
//
//    PostStatsView()
//
//}
