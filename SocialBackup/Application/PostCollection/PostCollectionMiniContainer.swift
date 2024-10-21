//
//  PostCollectionMiniContainer.swift
//  SocialBackup
//
//  Created by Alex Coundouriotis on 10/12/24.
//

import SwiftUI

struct PostCollectionMiniContainer: View {
    
    var postCollection: PostCollection
    
    var body: some View {
        PostCollectionMiniView(
            title: LocalizedStringKey(postCollection.title ?? "*Collection*"),
            posts: FetchRequest(
                sortDescriptors: [NSSortDescriptor(key: #keyPath(Post.lastModifyDate), ascending: false)],
                predicate: NSPredicate(format: "ANY %K = %@", #keyPath(Post.collections), postCollection)))
    }
    
}

//#Preview {
//    
//    PostCollectionMiniContainer()
//
//}
