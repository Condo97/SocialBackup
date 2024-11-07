//
//  PostPreviewContainer.swift
//  SocialBackup
//
//  Created by Alex Coundouriotis on 10/12/24.
//

import SwiftUI

struct PostPreviewContainer: View {
    
    @ObservedObject var post: Post
    
    @Environment(\.managedObjectContext) private var viewContext
    
    @State private var isDisplayingRepair: Bool = false
    
    @State private var isShowingAddToCollection: Bool = false
    
    var body: some View {
        PostPreviewView(
            post: post,
            medias: FetchRequest(
                sortDescriptors: [NSSortDescriptor(key: #keyPath(Media.index), ascending: true)],
                predicate: NSPredicate(format: "%K = %@", #keyPath(Media.post), post)))
        .overlay(alignment: .bottomTrailing) {
            if let sourceString = try? post.getGetPostInfoResponseObject()?.body.downloadResponse.source,
               let source = PostSource.from(sourceString) {
                Image(source.imageName)
                    .resizable()
                    .aspectRatio(contentMode: .fit)
                    .frame(width: 20.0)
                    .padding(8)
            }
        }
        .contextMenu {
            Button("Add to Collection", systemImage: "plus") {
                isShowingAddToCollection = true
            }
            
            Divider()
            
            Button("Delete", systemImage: "trash", role: .destructive) {
                Task {
                    do {
                        try await viewContext.perform {
                            viewContext.delete(post)
                            
                            try viewContext.save()
                        }
                    } catch {
                        // TODO: Handle Errors
                        print("Error deleting post in PostPreviewContainer... \(error)")
                    }
                }
            }
        }
        .addPostToCollectionFullScreenCover(isPresented: $isShowingAddToCollection, post: post)
    }
    
    func hasMedia() async throws -> Bool {
        return try await !PostCDManager.getMedia(for: post, in: viewContext).isEmpty
    }
    
}

//#Preview {
//    
//    PostPreviewContainer()
//
//}
