//
//  PostCollectionsView.swift
//  SocialBackup
//
//  Created by Alex Coundouriotis on 10/13/24.
//

import SwiftUI

struct PostCollectionsView: View {
    
    @FetchRequest(sortDescriptors: [NSSortDescriptor(keyPath: \PostCollection.lastModifyDate, ascending: false)])
    private var recentCollections: FetchedResults<PostCollection>
    
    @FetchRequest(
        sortDescriptors: [NSSortDescriptor(keyPath: \PostCollection.lastModifyDate, ascending: false)],
        predicate: NSPredicate(format: "%K = %d", #keyPath(PostCollection.isFavorite), true))
    private var favoriteCollections: FetchedResults<PostCollection>
    
    @State private var presentingPostCollection: PostCollection?
    @State private var isShowingRecentPostsFauxCollection: Bool = false
    @State private var isShowingUltraView: Bool = false
    
    private var isShowingPostCollection: Binding<Bool> { Binding(get: { presentingPostCollection != nil }, set: { if !$0 { presentingPostCollection = nil } }) }
    
    var body: some View {
        NavigationStack {
            ScrollView {
                VStack(alignment: .leading) {
                    // Favorite Collections
                    if !favoriteCollections.isEmpty {
                        Text("Favorite Collections")
                            .font(.custom(Constants.FontName.heavy, size: 20.0))
                            .padding(.horizontal)
                            .padding(.top)
                        ScrollView(.horizontal) {
                            HStack {
                                ForEach(favoriteCollections) { collection in
                                    Button(action: {
                                        withAnimation {
                                            presentingPostCollection = collection
                                        }
                                    }) {
                                        PostCollectionMiniContainer(postCollection: collection)
                                            .padding()
                                            .padding()
                                            .frame(height: 225.0)
                                            .foregroundStyle(Colors.text)
                                            .background(Colors.foreground)
                                            .clipShape(RoundedRectangle(cornerRadius: 14.0))
                                    }
                                }
                            }
                        }
                    }
                    
                    // All Collections
                    Text("All Collections")
                        .font(.custom(Constants.FontName.heavy, size: 20.0))
                        .foregroundStyle(Colors.text)
                        .padding(.horizontal)
                        .padding(.top)
                    LazyVGrid(columns: [GridItem(.flexible()), GridItem(.flexible())]) {
                        // Default recent posts collection
                        Button(action: {
                            isShowingRecentPostsFauxCollection = true
                        }) {
                            PostCollectionMiniView(
                                title: "*Recents*",
                                posts: FetchRequest(sortDescriptors: [NSSortDescriptor(key: #keyPath(Post.lastModifyDate), ascending: false)]))
                            .padding()
                            .frame(height: 225.0)
                            .frame(maxWidth: .infinity)
                            .foregroundStyle(Colors.text)
                            .background(Colors.foreground)
                            .clipShape(RoundedRectangle(cornerRadius: 14.0))
                        }
                        
                        if recentCollections.isEmpty {
                            // TODO: Plus button to add collection
                            
                        } else {
                            // Recent collections
                            ForEach(recentCollections) { collection in
                                Button(action: {
                                    withAnimation {
                                        presentingPostCollection = collection
                                    }
                                }) {
                                    PostCollectionMiniContainer(postCollection: collection)
                                        .padding()
                                        .frame(height: 225.0)
                                        .frame(maxWidth: .infinity)
                                        .foregroundStyle(Colors.text)
                                        .background(Colors.foreground)
                                        .clipShape(RoundedRectangle(cornerRadius: 14.0))
                                }
                            }
                        }
                    }
                    .padding(.horizontal)
                    Spacer(minLength: 150.0)
                }
            }
            .background(Colors.background)
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                LogoToolbarItem()
                
                UltraToolbarItem(isShowingUltraView: $isShowingUltraView)
            }
            .navigationDestination(isPresented: isShowingPostCollection) {
                if let presentingPostCollection = presentingPostCollection {
                    PostCollectionContainer(postCollection: presentingPostCollection)
                        .transition(.move(edge: .bottom))
                }
            }
            .navigationDestination(isPresented: $isShowingRecentPostsFauxCollection) {
                PostCollectionView(
                    title: "Recent Posts",
                    posts: FetchRequest(sortDescriptors: [NSSortDescriptor(key: #keyPath(Post.lastModifyDate), ascending: false)]))
            }
            .ultraViewPopover(isPresented: $isShowingUltraView)
        }
    }
    
}

//#Preview {
//    
//    PostCollectionsView()
//
//}
