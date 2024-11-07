//
//  SearchView.swift
//  SocialBackup
//
//  Created by Alex Coundouriotis on 10/27/24.
//

import SwiftUI

struct SearchView: View {
    
    @Environment(\.managedObjectContext) private var viewContext
    
    @FetchRequest(sortDescriptors: [NSSortDescriptor(key: #keyPath(Post.lastModifyDate), ascending: false)])
    private var posts: FetchedResults<Post>
    
    @FocusState private var searchFocused: Bool
    
    @StateObject private var summaryGenerator: SummaryGenerator = SummaryGenerator()
    
//    @State private var selectedFilterWords: [String] = []
    @State private var searchText: String = ""
//    @State private var isDisplayingAdvancedSearch: Bool = false
    
    @State private var isShowingUltraView: Bool = false
    
    @State private var selectedApp: String?
    private var isDisplayingAppFauxCollection: Binding<Bool> { Binding(get: { selectedApp != nil }, set: { if !$0 { selectedApp = nil } }) }
    @State private var selectedType: MediaTypeFromExtension.MediaType?
    private var isdisplayingTypeFauxCollection: Binding<Bool> { Binding(get: { selectedType != nil }, set: { if !$0 { selectedType = nil } }) }
    @State private var selectedEmotion: String?
    private var isDisplayingEmotionFauxCollection: Binding<Bool> { Binding(get: { selectedEmotion != nil }, set: { if !$0 { selectedEmotion = nil } }) }
    @State private var selectedCategory: String?
    private var isDisplayingCategoryFauxCollection: Binding<Bool> { Binding(get: { selectedCategory != nil }, set: { if !$0 { selectedCategory = nil } }) }
    @State private var selectedTag: String?
    private var isdisplayingTagFauxCollection: Binding<Bool> { Binding(get: { selectedTag != nil }, set: { if !$0 { selectedTag = nil } }) }
    
    private var apps: [String] {
        Set(posts.compactMap { post in
            post.cachedSource
        }).sorted()
    }
    
    private var types: [MediaTypeFromExtension.MediaType] {
        Set(posts.flatMap { post in
            let fetchRequest = Media.fetchRequest()
            fetchRequest.predicate = NSPredicate(format: "%K = %@", #keyPath(Media.post), post)
            let medias: [Media]
            do {
                medias = try viewContext.performAndWait {
                    try viewContext.fetch(fetchRequest)
                }
            } catch {
                // TODO: Handle Errors
                print("Error fetching Media from Post in SearchView... \(error)")
                medias = []
            }
            return medias.compactMap({
                if let localFilename = $0.localFilename {
                    return MediaTypeFromExtension.getMediaType(fromFilename: localFilename)
                }
                return nil
            })
        }).sorted()
    }
    
    private var emotions: [String] {
        Set(posts.flatMap { post in
            post.generatedEmotionsCSV?
                .split(separator: ",")
                .map { String($0).trimmingCharacters(in: .whitespacesAndNewlines) } ?? []
        }).sorted()
    }

    private var categories: [String] {
        Set(posts.flatMap { post in
            post.generatedCategoriesCSV?
                .split(separator: ",")
                .map { String($0).trimmingCharacters(in: .whitespacesAndNewlines) } ?? []
        }).sorted()
    }

    private var tags: [String] {
        Set(posts.flatMap { post in
            post.generatedTagsCSV?
                .split(separator: ",")
                .map { String($0).trimmingCharacters(in: .whitespacesAndNewlines) } ?? []
        }).sorted()
    }
//    private var emotionGroupedPosts: [String: [Post]] {
//        // Write efficient logic for grouping
//        // let emotions = post.generatedEmotionsCSV?.split(separator: ",")
//    }
    
    private var postFilterPredicate: NSPredicate? {
        let finalizedSearchText = searchText/* + (selectedFilterWords.isEmpty ? "" : " " + selectedFilterWords.joined(separator: " "))*/.trimmingCharacters(in: .whitespacesAndNewlines)
        
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
        NavigationStack {
            ScrollView {
                VStack(alignment: .leading) {
                    searchBar
                    
                    if searchText.isEmpty {
                        filtersDisplay
                    } else {
                        searchDisplay
                    }
                    
                    Spacer(minLength: 150.0)
                }
            }
            .navigationTitle("Search")
            .toolbar {
                if !PremiumUpdater.get() {
                    UltraToolbarItem(isShowingUltraView: $isShowingUltraView)
                }
            }
            .background(Colors.background)
            .ultraViewPopover(isPresented: $isShowingUltraView)
            .navigationDestination(isPresented: isDisplayingAppFauxCollection) {
                if let selectedApp {
                    PostCollectionView(
//                        title: LocalizedStringKey(selectedApp.capitalized),
                        posts: FetchRequest(
                            sortDescriptors: [NSSortDescriptor(key: #keyPath(Post.lastModifyDate), ascending: false)],
                            predicate: NSPredicate(format: "%K = %@", #keyPath(Post.cachedSource), selectedApp)))
                    .navigationTitle(selectedApp.capitalized)
                }
            }
            .navigationDestination(isPresented: isdisplayingTypeFauxCollection) {
                if let selectedType,
                   let extensions = selectedType.extensions {
                    let predicates = extensions.map { fileExtension in
                        NSPredicate(format: "ANY %K ENDSWITH[cd] %@", #keyPath(Post.medias.localFilename), fileExtension)
                    }
                    let compoundPredicate = NSCompoundPredicate(orPredicateWithSubpredicates: predicates)
                    PostCollectionView(
//                        title: LocalizedStringKey(selectedType.name.capitalized),
                        posts: FetchRequest(
                            sortDescriptors: [NSSortDescriptor(key: #keyPath(Post.lastModifyDate), ascending: false)],
                            predicate: compoundPredicate))
                    .navigationTitle(selectedType.name.capitalized)
                }
            }
            .navigationDestination(isPresented: isDisplayingEmotionFauxCollection) {
                if let selectedEmotion {
                    PostCollectionView(
//                        title: LocalizedStringKey(selectedEmotion.capitalized),
                        posts: FetchRequest(
                            sortDescriptors: [NSSortDescriptor(key: #keyPath(Post.lastModifyDate), ascending: false)],
                            predicate: NSPredicate(format: "%K CONTAINS[c] %@", #keyPath(Post.generatedEmotionsCSV), selectedEmotion)))
                    .navigationTitle(selectedEmotion.capitalized)
                }
            }
            .navigationDestination(isPresented: isDisplayingCategoryFauxCollection) {
                if let selectedCategory {
                    PostCollectionView(
//                        title: LocalizedStringKey(selectedCategory.capitalized),
                        posts: FetchRequest(
                            sortDescriptors: [NSSortDescriptor(key: #keyPath(Post.lastModifyDate), ascending: false)],
                            predicate: NSPredicate(format: "%K CONTAINS[c] %@", #keyPath(Post.generatedCategoriesCSV), selectedCategory)))
                    .navigationTitle(selectedCategory.capitalized)
                }
            }
            .navigationDestination(isPresented: isdisplayingTagFauxCollection) {
                if let selectedTag {
                    PostCollectionView(
//                        title: LocalizedStringKey(selectedTag.capitalized),
                        posts: FetchRequest(
                            sortDescriptors: [NSSortDescriptor(key: #keyPath(Post.lastModifyDate), ascending: false)],
                            predicate: NSPredicate(format: "%K CONTAINS[c] %@", #keyPath(Post.generatedTagsCSV), selectedTag)))
                    .navigationTitle(selectedTag.capitalized)
                }
            }
        }
        .scrollDismissesKeyboard(.immediately) // TODO: Learn if this is the best placement
        .task {
            // Get all post summary
            do {
                try await summaryGenerator.generateSummaryForAll(in: viewContext)
            } catch SummaryGeneratorError.subscriptionNotAuthorized {
                // TODO: Handle Errors if Necessary
            } catch {
                // TODO: Handle Errors
                print("Error generating summary in SearchView... \(error)")
            }
        }
    }
    
    var searchBar: some View {
        HStack {
            VStack(spacing: 0.0) {
                HStack {
                    Image(systemName: "magnifyingglass")
                        .padding(.vertical)
                    TextField("", text: $searchText, prompt: Text("Search Posts").foregroundColor(Colors.text.opacity(0.6)))
                        .focused($searchFocused)
                        .padding(.vertical)
                    if !searchText.isEmpty {
                        Button(action: { searchText = "" }) {
                            Image(systemName: "xmark")
                                .imageScale(.small)
                                .foregroundStyle(Colors.text)
                                .opacity(0.6)
                        }
                    }
                }
                .padding(.horizontal)
                
//                if !selectedFilterWords.isEmpty { TODO: Reintegrate filter words if necessary and this is the little word in the search bar
//                    ScrollView(.horizontal) {
//                        HStack {
//                            ForEach(selectedFilterWords, id: \.self) { word in
//                                Button(action: { selectedFilterWords.removeAll(where: { $0 == word })}) {
//                                    Text("\(word) \(Image(systemName: "xmark"))")
//                                        .font(.custom(Constants.FontName.body, size: 12.0))
//                                        .foregroundStyle(Colors.text)
//                                        .padding(.horizontal, 8)
//                                        .padding(.vertical, 4)
//                                        .background(Colors.background)
//                                        .clipShape(Capsule())
//                                }
//                            }
//                        }
//                        .padding(.horizontal)
//                        .padding(.bottom, 8)
//                    }
//                }
            }
            
//            if !searchText.isEmpty || !selectedFilterWords.isEmpty {
//                Button(action: {
//                    withAnimation {
//                        isDisplayingAdvancedSearch = false
//                    }
//                }) {
//                    Text("Go \(Image(systemName: "chevron.right"))")
//                        .font(.custom(Constants.FontName.body, size: 14.0))
//                        .padding(.horizontal)
//                        .padding(.vertical, 8)
//                        .foregroundStyle(Colors.foreground)
//                        .background(Colors.accent)
//                        .clipShape(RoundedRectangle(cornerRadius: 28.0))
//                }
//                .transition(.move(edge: .trailing))
//                .padding(.trailing)
//            }
        }
        .font(.custom(Constants.FontName.body, size: 17.0))
        .foregroundStyle(Colors.text)
        .background(Colors.foreground)
        .clipShape(Capsule())
        .padding(.horizontal)
//        .padding(isDisplayingAdvancedSearch ? .trailing : .horizontal)
    }
    
    var filtersDisplay: some View {
        VStack(alignment: .leading) {
            Text("App")
                .font(.custom(Constants.FontName.heavy, size: 20.0))
                .foregroundStyle(Colors.text)
                .padding(.horizontal)
                .padding(.top)
            if apps.isEmpty {
                VStack {
                    Text("Posts grouped by app show here.")
                        .font(.custom(Constants.FontName.medium, size: 17.0))
                    Text("ex. TikTok, Instagram, YouTube, etc.")
                        .font(.custom(Constants.FontName.lightOblique, size: 14.0))
                }
                .opacity(0.6)
                .foregroundStyle(Colors.text)
                .padding()
                .frame(maxWidth: .infinity)
                .background(Colors.foreground)
                .clipShape(RoundedRectangle(cornerRadius: 14.0))
                .padding(.horizontal)
            } else {
                ScrollView(.horizontal) {
                    HStack {
                        ForEach(apps, id: \.self) { app in
                            Button(action: { selectedApp = app }) {
                                Group {
                                    if let source = PostSource.from(app) {
                                        Image(source.imageName)
                                            .resizable()
                                            .aspectRatio(contentMode: .fit)
                                    } else {
                                        Text(app)
                                    }
                                }
                                .frame(width: 60.0, height: 60.0)
                                .padding()
                                .background(Colors.foreground)
                                .clipShape(RoundedRectangle(cornerRadius: 14.0))
                            }
                        }
                    }
                }
                .padding(.horizontal)
            }
            
            Text("Type")
                .font(.custom(Constants.FontName.heavy, size: 20.0))
                .foregroundStyle(Colors.text)
                .padding(.horizontal)
                .padding(.top)
            if apps.isEmpty {
                VStack {
                    Text("Posts grouped by type show here.")
                        .font(.custom(Constants.FontName.medium, size: 17.0))
                    Text("ex. video, image")
                        .font(.custom(Constants.FontName.lightOblique, size: 14.0))
                }
                .opacity(0.6)
                .foregroundStyle(Colors.text)
                .padding()
                .frame(maxWidth: .infinity)
                .background(Colors.foreground)
                .clipShape(RoundedRectangle(cornerRadius: 14.0))
                .padding(.horizontal)
            } else {
                if types.isEmpty {
                    emptyFilterDisplay
                } else {
                    ScrollView(.horizontal) {
                        HStack {
                            ForEach(types, id: \.self) { type in
                                Button(action: { selectedType = type }) {
                                    if let extensions = type.extensions {
                                        let predicates = extensions.map { fileExtension in
                                            NSPredicate(format: "ANY %K ENDSWITH[cd] %@", #keyPath(Post.medias.localFilename), fileExtension)
                                        }
                                        let compoundPredicate = NSCompoundPredicate(orPredicateWithSubpredicates: predicates)
                                        
                                        PostCollectionMiniView(
                                            title: LocalizedStringKey(type.name),
                                            posts: FetchRequest(
                                                sortDescriptors: [NSSortDescriptor(key: #keyPath(Post.lastModifyDate), ascending: false)],
                                                predicate: compoundPredicate))
                                        .postCollectionMiniViewStyle()
                                        //                                    .padding()
                                        //                                    .padding()
                                        //                                    .frame(height: 225.0)
                                        //                                    .foregroundStyle(Colors.text)
                                        //                                    .background(Colors.foreground)
                                        //                                    .clipShape(RoundedRectangle(cornerRadius: 14.0))
                                    }
                                }
                            }
                        }
                        .padding(.horizontal)
                    }
                }
            }
            
            Text("Emotions")
                .font(.custom(Constants.FontName.heavy, size: 20.0))
                .foregroundStyle(Colors.text)
                .padding(.horizontal)
                .padding(.top)
            if PremiumUpdater.get() {
                if emotions.isEmpty {
                    emptyFilterDisplay
                } else {
                    ScrollView(.horizontal) {
                        HStack {
                            ForEach(emotions, id: \.self) { emotion in
                                Button(action: {
                                    selectedEmotion = emotion
                                }) {
                                    PostCollectionMiniView(
                                        title: LocalizedStringKey(emotion),
                                        posts: FetchRequest(
                                            sortDescriptors: [NSSortDescriptor(key: #keyPath(Post.lastModifyDate), ascending: false)],
                                            predicate: NSPredicate(format: "%K CONTAINS[c] %@", #keyPath(Post.generatedEmotionsCSV), emotion)))
                                    .postCollectionMiniViewStyle()
                                }
                            }
                        }
                        .padding(.horizontal)
                    }
                }
            } else {
                unlockAIOrganizationButton
            }
            
            Text("Categories")
                .font(.custom(Constants.FontName.heavy, size: 20.0))
                .foregroundStyle(Colors.text)
                .padding(.horizontal)
                .padding(.top)
            if PremiumUpdater.get() {
                if categories.isEmpty {
                    emptyFilterDisplay
                } else {
                    ScrollView(.horizontal) {
                        LazyHGrid(rows: [GridItem(.flexible()), GridItem(.flexible())]) {
                            ForEach(categories, id: \.self) { category in
                                Button(action: {
                                    selectedCategory = category
                                }) {
                                    PostCollectionMiniView(
                                        title: LocalizedStringKey(category),
                                        posts: FetchRequest(
                                            sortDescriptors: [NSSortDescriptor(key: #keyPath(Post.lastModifyDate), ascending: false)],
                                            predicate: NSPredicate(format: "%K CONTAINS[c] %@", #keyPath(Post.generatedCategoriesCSV), category)))
                                    .postCollectionMiniViewStyle()
                                }
                            }
                        }
                        .padding(.horizontal)
                    }
                }
            } else {
                unlockAIOrganizationButton
            }
            
            Text("Tags")
                .font(.custom(Constants.FontName.heavy, size: 20.0))
                .foregroundStyle(Colors.text)
                .padding(.horizontal)
                .padding(.top)
            if PremiumUpdater.get() {
                if tags.isEmpty {
                    emptyFilterDisplay
                } else {
                    ScrollView {
                        HStack {
                            SingleAxisGeometryReader(axis: .horizontal) { geo in
                                HStack {
                                    FlexibleView(
                                        availableWidth: geo.magnitude,
                                        data: tags,
                                        spacing: 8.0,
                                        alignment: .leading,
                                        content: { tag in
                                            Button(action: {
                                                selectedTag = tag
                                            }) {
                                                Text(tag.capitalized)
                                                    .font(.custom(Constants.FontName.body, size: 14.0))
//                                                    .foregroundStyle(selectedFilterWords.contains(where: {$0 == tag}) ? Colors.foreground : Colors.text) TODO: Reintegrate filter words if necessary and this is for coloring the tag
                                                    .foregroundStyle(Colors.text)
                                                    .padding(.horizontal)
                                                    .padding(.vertical, 8)
//                                                    .background(selectedFilterWords.contains(where: {$0 == tag}) ? Colors.text : Colors.foreground) TODO: Reintegrate filter words if necessary and this is for coloring the tag
                                                    .background(Colors.foreground)
                                                    .clipShape(RoundedRectangle(cornerRadius: 14.0))
                                            }
                                        })
                                    Spacer()
                                }
                            }
                        }
                        .padding(.horizontal)
                    }
                }
            } else {
                unlockAIOrganizationButton
            }
        }
    }
    
    var searchDisplay: some View {
        PostCollectionView(
//            title: "",
            posts: FetchRequest(
                sortDescriptors: [NSSortDescriptor(key: #keyPath(Post.lastModifyDate), ascending: false)],
                predicate: postFilterPredicate))
        .padding(.vertical)
    }
    
    var unlockAIOrganizationButton: some View {
        Button(action: { isShowingUltraView = true }) {
            VStack {
                Text("Unlock AI Organization")
                    .font(.custom(Constants.FontName.heavy, size: 17.0))
                Text("Try FREE Now")
                    .font(.custom(Constants.FontName.bodyOblique, size: 12.0))
            }
            .frame(maxWidth: .infinity)
            .overlay(alignment: .trailing) {
                Text("\(Image(systemName: "sparkles"))")
                    .font(.custom(Constants.FontName.medium, size: 17.0))
                    .foregroundStyle(Colors.accent)
            }
            .appButtonStyle()
            .padding(.horizontal)
        }
    }
    
    var emptyFilterDisplay: some View {
        Text("Grab some posts to get started.")
            .font(.custom(Constants.FontName.body, size: 14.0))
            .foregroundStyle(Colors.text)
            .frame(maxWidth: .infinity)
            .padding()
            .background(Colors.foreground)
            .clipShape(RoundedRectangle(cornerRadius: 14.0))
            .padding(.horizontal)
    }
    
}

extension PostCollectionMiniView {
    
    func postCollectionMiniViewStyle() -> some View {
        self
//            .padding()
            .padding()
            .frame(width: 150.0, height: 200.0)
            .foregroundStyle(Colors.text)
            .background(Colors.foreground)
            .clipShape(RoundedRectangle(cornerRadius: 14.0))
    }
    
}

#Preview {
    
    SearchView()
        .environment(\.managedObjectContext, CDClient.mainManagedObjectContext)
    
}
