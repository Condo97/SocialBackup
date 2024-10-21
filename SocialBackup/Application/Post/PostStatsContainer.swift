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
    
//    @State private var postInfo: GetPostInfoResponse?
//    @State private var postTranscriptions: [String] = []
    
    @State private var isLoading: Bool = false
    
    @State private var isLoadingSummary: Bool = false
    
    @State private var isShowingTranscriptions: Bool = false
    @State private var isShowingUltra: Bool = false
    
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
                    onGenerateSummary: { Task { await generateSummary() }},
                    onOpenTranscriptionsView: { isShowingTranscriptions = true })
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
                try await PostDownloaderAndSaverAndBackuper().updateMissingTranscriptions(for: post, in: viewContext)
//                checkForAndUpdateTranscriptions()
            } catch {
                // TODO: Handle Errors
                print("Error updating missing transcriptions in PostStatsContainer... \(error)")
            }
        }
        .task {
            await generateSummary()
        }
    }
    
    func generateSummary() async {
        guard PremiumUpdater.get() else {
            // Show ultra view
            isShowingUltra = true
            return
        }
        
        defer { DispatchQueue.main.async { self.isLoadingSummary = false } }
        await MainActor.run { self.isLoadingSummary = true }
        
//            if PremiumUpdater.get() { TODO: Enable Premium Check
            // Ensure authToken
            let authToken: String
            do {
                authToken = try await AuthHelper.ensure()
            } catch {
                // TODO: Handle Errors
                print("Error ensuring authToken in PostDownloaderView... \(error)")
                return
            }
            
            // Update post videoSummary if any generated field is nil
        if post.generatedFieldIsNil {
                do {
                    try await PostPersistenceManager.getAndSavePostSummary(
                        authToken: authToken,
                        to: post,
                        in: viewContext)
                } catch PostPersistenceManagerError.noTranscription {
                    // Transcribe again TODO: Is this good enough, because what if one of the content's transcriptions is missing? There should be an automatic refresh or check
                    print("No transcriptions received")
                    do {
                        try await PostDownloaderAndSaverAndBackuper().updateMissingTranscriptions(for: post, in: viewContext)
                    } catch {
                        // TODO: Handle Errors
                        print("Error updating missing transcriptions in PostStatsContainer... \(error)")
                    }
                } catch {
                    // TODO: Handle Errors
                    print("Error getting and saving post summary in PostDownloaderAndSaverAndBackuper... \(error)")
                }
            }
        
//            // Set postSummary and postTranscriptions
//            do {
//                checkForAndUpdateTranscriptions()
//            } catch {
//                // TODO: Handle Errors
//                print("Error getting post summary object in PostStatsContainer... \(error)")
//            }
//            }
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
