//
//  FeedContainer.swift
//  SocialBackup
//
//  Created by Alex Coundouriotis on 10/13/24.
//

import SwiftUI

struct FeedContainer: View {
    
    @Environment(\.managedObjectContext) private var viewContext
    
//    @FetchRequest(
//        sortDescriptors: [NSSortDescriptor(key: #keyPath(Post.lastModifyDate), ascending: false)])
//    private var posts: FetchedResults<Post>
    
//    private let searchMatchedGeometryEffectID = "searchMatchedGeometryEffectID"
    
    @FocusState private var searchFocused: Bool
    
//    @Namespace private var namespace
    
    @State private var searchText: String = ""
    @State private var selectedFilterWords: [String] = []
//    @State private var selectedFilterEmotions: [String] = []
//    @State private var selectedFilterTags: [String] = []
//    @State private var selectedFilterKeywords: [String] = []
    
    @State private var presentingPost: Post?
    
    @State private var isDisplayingAdvancedSearch: Bool = false
    
    private var postFilterPredicate: NSPredicate? {
        let finalizedSearchText = searchText + (selectedFilterWords.isEmpty ? "" : " " + selectedFilterWords.joined(separator: " ")).trimmingCharacters(in: .whitespacesAndNewlines)
        
        if finalizedSearchText.isEmpty {
            return nil
        }
        
        return NSPredicate(
            format: "%K CONTAINS[cd] %@ OR %K CONTAINS[cd] %@ OR %K CONTAINS[cd] %@ OR %K CONTAINS[cd] %@ OR %K CONTAINS[cd] %@ OR %K CONTAINS[cd] %@ OR %K CONTAINS[cd] %@",
            #keyPath(Post.title), finalizedSearchText,
            #keyPath(Post.generatedTitle), finalizedSearchText,
            #keyPath(Post.generatedTopic), finalizedSearchText,
            #keyPath(Post.generatedEmotionsCSV), finalizedSearchText,
            #keyPath(Post.generatedTagsCSV), finalizedSearchText,
            #keyPath(Post.generatedKeywordsCSV), finalizedSearchText,
            #keyPath(Post.generatedKeyEntitiesCSV), finalizedSearchText)
    }
    
    var body: some View {
        ZStack {
            ScrollView {
                Spacer(minLength: 130.0 + (selectedFilterWords.count == 0 ? 0 : 50.0))
                FeedView(
                    posts: FetchRequest(
                        sortDescriptors: [NSSortDescriptor(key: #keyPath(Post.lastModifyDate), ascending: false)],
                        predicate: postFilterPredicate),
                    onSelectPost: { post in
                        withAnimation {
                            presentingPost = post
                        }
                    }
                )
            }
        }
        .ignoresSafeArea()
        .background(Colors.background)
        .overlay(alignment: .top) {
            VStack {
                HStack {
                    // Back Button
                    if isDisplayingAdvancedSearch {
                        Button(action: {
                            searchText = ""
                            selectedFilterWords = []
                            withAnimation {
                                isDisplayingAdvancedSearch = false
                            }
                        }) {
                            Image(systemName: "chevron.left")
                                .foregroundStyle(Colors.text)
                                .padding(.horizontal)
                        }
                    }
                    
                    // Search Field
                    HStack {
                        VStack(spacing: 0.0) {
                            HStack {
                                Image(systemName: "magnifyingglass")
                                    .padding(.vertical)
                                TextField("", text: $searchText, prompt: Text("Search Posts").foregroundColor(Colors.text.opacity(0.6)))
                                    .focused($searchFocused)
                                    .padding(.vertical)
                            }
                            .padding(.horizontal)
                            
                            if !selectedFilterWords.isEmpty {
                                ScrollView(.horizontal) {
                                    HStack {
                                        ForEach(selectedFilterWords, id: \.self) { word in
                                            Button(action: { selectedFilterWords.removeAll(where: { $0 == word })}) {
                                                Text("\(word)\(Image(systemName: "xmark"))")
                                                    .font(.custom(Constants.FontName.body, size: 12.0))
                                                    .foregroundStyle(Colors.text)
                                                    .padding(.horizontal, 8)
                                                    .padding(.vertical, 4)
                                                    .background(Colors.background)
                                                    .clipShape(Capsule())
                                            }
                                        }
                                    }
                                    .padding(.horizontal)
                                    .padding(.bottom, 8)
                                }
                            }
                        }
                        
                        if !searchText.isEmpty || !selectedFilterWords.isEmpty {
                            Button(action: {
                                withAnimation {
                                    isDisplayingAdvancedSearch = false
                                }
                            }) {
                                Text("Go \(Image(systemName: "chevron.right"))")
                                    .font(.custom(Constants.FontName.body, size: 14.0))
                                    .padding(.horizontal)
                                    .padding(.vertical, 8)
                                    .foregroundStyle(Colors.foreground)
                                    .background(Colors.accent)
                                    .clipShape(RoundedRectangle(cornerRadius: 28.0))
                            }
                            .transition(.move(edge: .trailing))
                            .padding(.trailing)
                        }
                    }
                    .font(.custom(Constants.FontName.body, size: 17.0))
                    .foregroundStyle(Colors.text)
                    .background(Colors.foreground)
                    .clipShape(Capsule())
                    .padding(isDisplayingAdvancedSearch ? .trailing : .horizontal)
                }
                .zIndex(2)
                
                if isDisplayingAdvancedSearch {
                    FeedSearchFilterView(selectedFilterWords: $selectedFilterWords)
                    .frame(maxWidth: .infinity, maxHeight: .infinity)
                    .padding()
                    .background(Colors.background)
                    .transition(.move(edge: .top))
                    .ignoresSafeArea()
                    .zIndex(1)
//                        .animation(.easeInOut, value: searchFocused || !searchText.isEmpty)
                }
            }
        }
        .scrollDismissesKeyboard(.immediately)
        .postContainer(post: $presentingPost)
        .onChange(of: searchFocused) { newValue in
            if newValue {
                withAnimation {
                    isDisplayingAdvancedSearch = true
                }
            }
        }
        .onChange(of: isDisplayingAdvancedSearch) { newValue in
            if !newValue {
                searchFocused = false
            }
        }
    }
    
}

#Preview {
    
    FeedContainer()
        .environment(\.managedObjectContext, CDClient.mainManagedObjectContext)
        .environmentObject(MediaICloudUploadUpdater())
    
}
