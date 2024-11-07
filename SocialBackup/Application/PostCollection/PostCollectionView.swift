//
//  PostCollectionView.swift
//  SocialBackup
//
//  Created by Alex Coundouriotis on 10/12/24.
//

import SwiftUI

struct PostCollectionView: View {
    
//    var postCollection: PostCollection
//    var title: LocalizedStringKey
    @FetchRequest var posts: FetchedResults<Post>
    
    @State private var presentingPost: Post?
    
    var body: some View {
        ScrollView {
            LazyVGrid(columns: [GridItem(.flexible()), GridItem(.flexible()), GridItem(.flexible())]) {
                ForEach(posts) { post in
                    Button(action: {
                        withAnimation {
                            presentingPost = post
                        }
                    }) {
                        PostPreviewContainer(post: post)
                            .aspectRatio(0.76, contentMode: .fill)
                            .clipped()
                    }
                }
            }
            .padding(.horizontal)
        }
//        .navigationTitle(title)
        .background(Colors.background)
        .postContainer(post: $presentingPost)
    }
    
}

#Preview {
    
    let postCollection = try! CDClient.mainManagedObjectContext.fetch(PostCollection.fetchRequest())[0]
    
    return PostCollectionView(
//        title: LocalizedStringKey(postCollection.title ?? "*Collection*"),
        posts: FetchRequest(
            sortDescriptors: [NSSortDescriptor(key: #keyPath(Post.lastModifyDate), ascending: false)],
            predicate: NSPredicate(format: "ANY %K = %@", #keyPath(Post.collections), postCollection)))
        .environment(\.managedObjectContext, CDClient.mainManagedObjectContext)
    
}
