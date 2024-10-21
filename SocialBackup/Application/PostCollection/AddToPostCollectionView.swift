//
//  AddToPostCollectionView.swift
//  SocialBackup
//
//  Created by Alex Coundouriotis on 10/11/24.
//

import SwiftUI

struct AddToPostCollectionView: View {
    
    @Binding var isPresented: Bool
    var post: Post
    
    @Environment(\.managedObjectContext) private var viewContext
    
    @FetchRequest(sortDescriptors: [NSSortDescriptor(key: #keyPath(PostCollection.lastModifyDate), ascending: false)])
    private var postCollections: FetchedResults<PostCollection>
    
    @State private var isShowingCreateCollection: Bool = false
    
    @State private var alertShowingDuplicatePostInCollection: Bool = false
    
    var body: some View {
        ScrollView {
            VStack(alignment: .leading) {
                Text("Save post to a new or existing collection.")
                    .font(.custom(Constants.FontName.body, size: 17.0))
                Button(action: {
                    isShowingCreateCollection = true
                }) {
                    Text("New Collection")
                        .frame(maxWidth: .infinity)
                        .overlay {
                            HStack {
                                Spacer()
                                Image(systemName: "chevron.right")
                            }
                        }
                        .appButtonStyle()
                }
                
                Text("All Collections")
                    .font(.custom(Constants.FontName.heavy, size: 20.0))
                    .padding(.top)
                ForEach(postCollections) { postCollection in
                    Button(action: {
                        Task {
                            // Add post
                            do {
                                try await PostCollectionCDManager.addPost(post, to: postCollection, in: viewContext)
                            } catch PostCollectionCDManagerError.duplicatePost {
                                // Show duplicate post error
                                alertShowingDuplicatePostInCollection = true
                            } catch {
                                // TODO: Handle Errors
                                print("Error adding post to collection in AddToPostCollectionView... \(error)")
                            }
                        }
                    }) {
                        HStack {
                            VStack(alignment: .leading) {
                                HStack {
                                    Text(postCollection.title ?? "*No Title*")
                                        .font(.custom(Constants.FontName.heavy, size: 17.0))
                                    if postCollection.isFavorite {
                                        Text("\(Image(systemName: "heart.fill"))")
                                            .font(.custom(Constants.FontName.body, size: 17.0))
                                        
                                    }
                                }
                                HStack {
                                    if let modifyDate = postCollection.lastModifyDate {
                                        Text("\(Image(systemName: "calendar"))")
                                        Text(DefaultDateFormatter.defaultDateFormatter.string(from: modifyDate))
                                            .font(.custom(Constants.FontName.body, size: 14.0))
                                    }
                                    if let postCount = postCollection.posts?.count {
                                        HStack(spacing: 5.0) {
                                            Text("\(Image(systemName: "movieclapper"))")
                                                .font(.custom(Constants.FontName.light, size: 12.0))
                                            Text("\(postCount)")
                                                .font(.custom(Constants.FontName.body, size: 14.0))
                                        }
                                        .opacity(0.8)
                                    }
                                }
                            }
                            
                            Spacer()
                            
                            Image(systemName: "chevron.right")
                                .font(.custom(Constants.FontName.body, size: 17.0))
                        }
                        .appButtonStyle(foregroundColor: Colors.text, backgroundColor: Colors.foreground)
                    }
                }
            }
            .padding(.horizontal)
        }
        .navigationTitle("Add to Collection")
        .toolbar {
            ToolbarItem(placement: .topBarLeading) {
                Button("\(Image(systemName: "chevron.down")) Close", action: { isPresented = false })
                    .font(.custom(Constants.FontName.heavy, size: 17.0))
                    .foregroundStyle(Colors.elementBackgroundColor)
            }
        }
        .clearFullScreenCover(isPresented: $isShowingCreateCollection, style: .dark) {
            CreatePostCollectionView(
                isPresented: $isShowingCreateCollection,
                onSave: { collectionName in
                    Task {
                        // Create post collection
                        let postCollection: PostCollection
                        do {
                            postCollection = try await PostCollectionCDManager.savePostCollection(
                                title: collectionName,
                                in: viewContext)
                        } catch {
                            // TODO: Handle Errors
                            print("Error saving post collection in AddToPostCollectionView... \(error)")
                            return
                        }
                        
                        // Add post to it
                        do {
                            try await PostCollectionCDManager.addPost(post, to: postCollection, in: viewContext)
                        } catch {
                            // TODO: Handle Errors
                            print("Error adding post to collection in AddToPostCollectionView... \(error)")
                            return
                        }
                        
                        // Dismiss
                        isPresented = false
                    }
                })
            .padding()
            .background(Colors.background)
            .clipShape(RoundedRectangle(cornerRadius: 14.0))
            .padding()
        }
        .alert("Duplicate Post", isPresented: $alertShowingDuplicatePostInCollection, actions: {
            Button("Close") {}
        }) {
            Text("This collection already contains this post.")
        }
    }
}

extension View {
    
    func addPostToCollectionFullScreenCover(isPresented: Binding<Bool>, post: Post) -> some View {
        self
            .fullScreenCover(isPresented: isPresented) {
                NavigationStack {
                    AddToPostCollectionView(isPresented: isPresented, post: post)
                        .foregroundStyle(Colors.text)
                        .background(Colors.background)
                }
            }
    }
    
}

#Preview {
    
    let post = {
        let post = Post(context: CDClient.mainManagedObjectContext)
        post.thumbnail = UIImage(named: "thumbnail1")!.jpegData(compressionQuality: 0.8)
        return post
    }()
    
    return NavigationStack {
        AddToPostCollectionView(
            isPresented: .constant(true),
            post: post)
        .background(Colors.background)
    }
    .environment(\.managedObjectContext, CDClient.mainManagedObjectContext)
    
}
