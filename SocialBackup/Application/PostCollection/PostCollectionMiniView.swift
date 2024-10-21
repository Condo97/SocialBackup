//
//  PostCollectionMiniView.swift
//  SocialBackup
//
//  Created by Alex Coundouriotis on 10/12/24.
//

import SwiftUI

struct PostCollectionMiniView: View {
    
//    var postCollection: PostCollection
    var title: LocalizedStringKey
    @FetchRequest var posts: FetchedResults<Post>
    var itemMinWidth: CGFloat = 50
    var itemMaxWidth: CGFloat = 100
    var itemMaxHeight: CGFloat = 150
    
    var body: some View {
        VStack {
            ZStack {
                if let post = posts[safe: 2],
                   let thumbnailData = post.thumbnail,
                   let thumbnailUIImage = UIImage(data: thumbnailData) {
                    Image(uiImage: thumbnailUIImage)
                        .resizable()
                        .aspectRatio(contentMode: .fit)
//                        .frame(minWidth: itemMinWidth, maxWidth: itemMaxWidth, maxHeight: itemMaxHeight)
                        .clipShape(RoundedRectangle(cornerRadius: 5.0))
                        .rotationEffect(.degrees(-11), anchor: .bottom)
                }
                
                if let post = posts[safe: 1],
                   let thumbnailData = post.thumbnail,
                   let thumbnailUIImage = UIImage(data: thumbnailData) {
                    Image(uiImage: thumbnailUIImage)
                        .resizable()
                        .aspectRatio(contentMode: .fit)
//                        .frame(minWidth: itemMinWidth, maxWidth: itemMaxWidth, maxHeight: itemMaxHeight)
                        .clipShape(RoundedRectangle(cornerRadius: 5.0))
                        .rotationEffect(.degrees(11), anchor: .bottom)
                }
                
                if let post = posts[safe: 0],
                   let thumbnailData = post.thumbnail,
                   let thumbnailUIImage = UIImage(data: thumbnailData) {
                    Image(uiImage: thumbnailUIImage)
                        .resizable()
                        .aspectRatio(contentMode: .fit)
                        .clipShape(RoundedRectangle(cornerRadius: 5.0))
//                        .frame(minWidth: itemMinWidth, maxWidth: itemMaxWidth, maxHeight: itemMaxHeight)
                }
            }
            
//            Text(postCollection.title ?? "*Collection*")
            Text(title)
                .font(.custom(Constants.FontName.medium, size: 17.0))
                .padding(.top)
        }
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

    return PostCollectionMiniView(
        title: LocalizedStringKey(postCollection.title ?? "*Collection*"),
        posts: FetchRequest(
            sortDescriptors: [NSSortDescriptor(key: #keyPath(Post.lastModifyDate), ascending: false)],
            predicate: NSPredicate(format: "ANY %K = %@", #keyPath(Post.collections), postCollection)))
    .environment(\.managedObjectContext, CDClient.mainManagedObjectContext)
    
}
