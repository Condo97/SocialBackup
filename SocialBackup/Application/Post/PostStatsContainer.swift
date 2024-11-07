//
//  PostStatsContainer.swift
//  SocialBackup
//
//  Created by Alex Coundouriotis on 10/11/24.
//

import SwiftUI

struct PostStatsContainer: View {
    
    var post: Post
    var onAddToCollection: () -> Void
    
    @Environment(\.managedObjectContext) private var viewContext
    
    @EnvironmentObject private var postDownloaderAndSaverAndBackuper: PostDownloaderAndSaverAndBackuper
    
    @StateObject private var summaryGenerator: SummaryGenerator = SummaryGenerator()
    
//    @State private var postInfo: GetPostInfoResponse?
//    @State private var postTranscriptions: [String] = []
    
    @State private var isLoading: Bool = false
    
    @State private var isLoadingSummary: Bool = false
    
    @State private var isShowingTranscriptions: Bool = false
    @State private var isShowingUltra: Bool = false
    
    private var isShowingSearchCategory: Binding<Bool> { Binding(get: { searchCategory != nil }, set: { if !$0 { searchCategory = nil }}) }
    @State private var searchCategory: String?
    private var isShowingSearchEmotion: Binding<Bool> { Binding(get: { searchEmotion != nil }, set: { if !$0 { searchEmotion = nil }}) }
    @State private var searchEmotion: String?
    private var isShowingSearchTag: Binding<Bool> { Binding(get: { searchTag != nil }, set: { if !$0 { searchTag = nil }}) }
    @State private var searchTag: String?
    private var isShowingSearchKeyword: Binding<Bool> { Binding(get: { searchKeyword != nil }, set: { if !$0 { searchKeyword = nil }}) }
    @State private var searchKeyword: String?
    
    private var searchCategoryFetchRequest: FetchRequest<Post> {
        FetchRequest(
            sortDescriptors: [NSSortDescriptor(key: #keyPath(Post.lastModifyDate), ascending: false)],
            predicate: NSPredicate(format: "%K CONTAINS[cd] %@", #keyPath(Post.generatedCategoriesCSV), searchCategory ?? ""))
    }
    
    private var searchEmotionFetchRequest: FetchRequest<Post> {
        FetchRequest(
            sortDescriptors: [NSSortDescriptor(key: #keyPath(Post.lastModifyDate), ascending: false)],
            predicate: NSPredicate(format: "%K CONTAINS[cd] %@", #keyPath(Post.generatedEmotionsCSV), searchEmotion ?? ""))
    }
    
    private var searchTagFetchRequest: FetchRequest<Post> {
        FetchRequest(
            sortDescriptors: [NSSortDescriptor(key: #keyPath(Post.lastModifyDate), ascending: false)],
            predicate: NSPredicate(format: "%K CONTAINS[cd] %@", #keyPath(Post.generatedTagsCSV), searchTag ?? ""))
    }
    
    private var searchKeywordFetchRequest: FetchRequest<Post> {
        FetchRequest(
            sortDescriptors: [NSSortDescriptor(key: #keyPath(Post.lastModifyDate), ascending: false)],
            predicate: NSPredicate(format: "%K CONTAINS[cd] %@ OR %K CONTAINS[cd] %@",
                                   #keyPath(Post.generatedKeywordsCSV), searchKeyword ?? "",
                                   #keyPath(Post.generatedKeyEntitiesCSV), searchKeyword ?? ""))
    }
    
    var body: some View {
        Group {
            if (try? post.getGetPostInfoResponseObject()) != nil {
                PostStatsView(
                    post: post,
                    medias: FetchRequest(
                        sortDescriptors: [NSSortDescriptor(key: #keyPath(Media.index), ascending: true)],
                        predicate: NSPredicate(format: "%K = %@", #keyPath(Media.post), post)),
                    isLoadingSummary: $isLoadingSummary,
                    onAddToCollection: onAddToCollection,
                    onGenerateSummary: { Task { await generateSummary(showUltraOnFail: true) }},
                    onOpenTranscriptionsView: { isShowingTranscriptions = true },
                    onSelectCategory: { category in
                        searchCategory = category
                    },
                    onSelectEmotion: { emotion in
                        searchEmotion = emotion
                    },
                    onSelectTag: { tag in
                        searchTag = tag
                    },
                    onSelectKeyword: { keyword in
                        searchKeyword = keyword
                    })
            } else if isLoading {
                VStack {
                    Text("Loading...")
                    ProgressView()
                }
            } else {
                Text("No Post Info")
            }
        }
        .popover(isPresented: $isShowingTranscriptions) {
            VStack {
                HStack {
                    Spacer()
                    
                    Button(action: { isShowingTranscriptions = false }) {
                        Text("Close")
                    }
                }
                .background(Colors.background)
                PostMediaTranscriptionsContainer(post: post)
                    .padding()
                    .background(Colors.background)
            }
        }
        .searchPopup(
            title: searchCategory ?? "Searching Categories",
            posts: searchCategoryFetchRequest,
            isPresented: isShowingSearchCategory)
        .searchPopup(
            title: searchEmotion ?? "Searching Emotions",
            posts: searchEmotionFetchRequest,
            isPresented: isShowingSearchEmotion)
        .searchPopup(
            title: searchTag ?? "Searching Tags",
            posts: searchTagFetchRequest,
            isPresented: isShowingSearchTag)
        .searchPopup(
            title: searchKeyword ?? "Searching Keywords",
            posts: searchKeywordFetchRequest,
            isPresented: isShowingSearchKeyword)
        .ultraViewPopover(isPresented: $isShowingUltra)
//        .onAppear {
//            do {
//                postInfo = try post.getGetPostInfoResponseObject()
//            } catch {
//                // TODO: Handle Errors
//                print("Error decoding getPostInfoResponseData in PostStatsContainer... \(error)")
//                return
//            }
//        }
        .task {
            // Update missing transcriptions just so that in case there is one that is missing lol
            do {
                try await postDownloaderAndSaverAndBackuper.updateMissingTranscriptions(for: post, in: viewContext)
//                checkForAndUpdateTranscriptions()
            } catch {
                // TODO: Handle Errors
                print("Error updating missing transcriptions in PostStatsContainer... \(error)")
            }
        }
        .task {
            await generateSummary(showUltraOnFail: false)
        }
    }
    
    func generateSummary(showUltraOnFail: Bool) async {
        do {
            try await summaryGenerator.generateSummary(for: post, in: viewContext)
        } catch SummaryGeneratorError.subscriptionNotAuthorized {
            if showUltraOnFail {
                // Show ultra view
                await MainActor.run {
                    isShowingUltra = true
                }
            }
        } catch {
            // TODO: Handle Errors
            print("Error generating summary in PostStatsContainer... \(error)")
        }
    }
    
//    func checkForAndUpdateTranscriptions() {
//        DispatchQueue.main.asyncAfter(deadline: .now() + 2.0) { // TODO: Make this way better, make it wait for the task to finish with the delegate
//            Task {
//                do {
//                    postTranscriptions = try await PostCDManager.getMedia(
//                        for: post,
//                        in: viewContext).compactMap(\.transcription)
//                } catch {
//                    // TODO: Handle Errors
//                    print("Error getting media in PostStatsContainer... \(error)")
//                }
//            }
//        }
//        DispatchQueue.main.asyncAfter(deadline: .now() + 5.0) { // TODO: Make this way better, make it wait for the task to finish with the delegate
//            Task {
//                do {
//                    postTranscriptions = try await PostCDManager.getMedia(
//                        for: post,
//                        in: viewContext).compactMap(\.transcription)
//                } catch {
//                    // TODO: Handle Errors
//                    print("Error getting media in PostStatsContainer... \(error)")
//                }
//            }
//        }
//        DispatchQueue.main.asyncAfter(deadline: .now() + 10.0) { // TODO: Make this way better, make it wait for the task to finish with the delegate
//            Task {
//                do {
//                    postTranscriptions = try await PostCDManager.getMedia(
//                        for: post,
//                        in: viewContext).compactMap(\.transcription)
//                } catch {
//                    // TODO: Handle Errors
//                    print("Error getting media in PostStatsContainer... \(error)")
//                }
//            }
//        }
//    }
    
}

//#Preview {
//    
//    PostStatsContainer()
//
//}
