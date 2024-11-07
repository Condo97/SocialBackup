//
//  FeedSearchFilterView.swift
//  SocialBackup
//
//  Created by Alex Coundouriotis on 10/21/24.
//

import SwiftUI

struct FeedSearchFilterView: View {
    
//    var adding: (_ word: String) -> Void
//    var removing: (_ word: String) -> Void
    @Binding var filterText: String
    @Binding var selectedFilterWords: [String]
    
//    @State private var selectedFilterEmotions: [String] = []
//    @State private var selectedFilterTags: [String] = []
//    @State private var selectedFilterKeywords: [String] = []
    
    @FetchRequest(
        sortDescriptors: [NSSortDescriptor(key: #keyPath(Post.lastModifyDate), ascending: false)])
    private var posts: FetchedResults<Post>
    
    var body: some View {
        ScrollView {
            VStack {
                // Post Emotions
                let emotions = posts.compactMap { $0.generatedEmotionsCSV }.flatMap { $0.components(separatedBy: ",") }.filter({ filterText.isEmpty ? true : $0.lowercased().contains(filterText.lowercased()) }).sorted()
                if !emotions.isEmpty {
                    VStack(alignment: .leading, spacing: 8.0) {
                        Text("Emotions:")
                            .font(.custom(Constants.FontName.heavy, size: 14.0))
                            .foregroundStyle(Colors.text)
                        SingleAxisGeometryReader(axis: .horizontal) { geo in
                            HStack {
                                FlexibleView(
                                    availableWidth: geo.magnitude,
                                    data: emotions,
                                    spacing: 8.0,
                                    alignment: .leading,
                                    content: { emotion in
                                        Button(action: {
                                            withAnimation {
                                                if selectedFilterWords.contains(where: {$0 == emotion}) {
                                                    selectedFilterWords.removeAll(where: {$0 == emotion})
                                                } else {
                                                    selectedFilterWords.append(emotion)
                                                }
                                            }
                                        }) {
                                            Text(emotion.capitalized)
                                                .font(.custom(Constants.FontName.body, size: 14.0))
                                                .foregroundStyle(selectedFilterWords.contains(where: {$0 == emotion}) ? Colors.foreground : Colors.text)
                                                .padding(.horizontal)
                                                .padding(.vertical, 8)
                                                .background(selectedFilterWords.contains(where: {$0 == emotion}) ? Colors.text : Colors.foreground)
                                                .clipShape(RoundedRectangle(cornerRadius: 14.0))
                                        }
                                    })
                                Spacer()
                            }
                        }
                    }
                }
                
                // Tags
                let tags = posts.compactMap { $0.generatedTagsCSV }.flatMap { $0.components(separatedBy: ",") }.filter({ filterText.isEmpty ? true : $0.lowercased().contains(filterText.lowercased()) }).sorted()
                if !tags.isEmpty {
                    VStack(alignment: .leading, spacing: 8.0) {
                        Text("Tags:")
                            .font(.custom(Constants.FontName.heavy, size: 14.0))
                            .foregroundStyle(Colors.text)
                        SingleAxisGeometryReader(axis: .horizontal) { geo in
                            HStack {
                                FlexibleView(
                                    availableWidth: geo.magnitude,
                                    data: tags,
                                    spacing: 8.0,
                                    alignment: .leading,
                                    content: { tag in
                                        Button(action: {
                                            withAnimation {
                                                if selectedFilterWords.contains(where: {$0 == tag}) {
                                                    selectedFilterWords.removeAll(where: {$0 == tag})
                                                } else {
                                                    selectedFilterWords.append(tag)
                                                }
                                            }
                                        }) {
                                            Text(tag.capitalized)
                                                .font(.custom(Constants.FontName.body, size: 14.0))
                                                .foregroundStyle(selectedFilterWords.contains(where: {$0 == tag}) ? Colors.foreground : Colors.text)
                                                .padding(.horizontal)
                                                .padding(.vertical, 8)
                                                .background(selectedFilterWords.contains(where: {$0 == tag}) ? Colors.text : Colors.foreground)
                                                .clipShape(RoundedRectangle(cornerRadius: 14.0))
                                        }
                                    })
                                Spacer()
                            }
                        }
                    }
                }
                
                // Keywords
                let keywords = posts.compactMap { $0.generatedKeywordsCSV }.flatMap { $0.components(separatedBy: ",") }
                let keyEntities = posts.compactMap { $0.generatedKeyEntitiesCSV }.flatMap { $0.components(separatedBy: ",") }
                let keys = (keywords + keyEntities).filter({ filterText.isEmpty ? true : $0.lowercased().contains(filterText.lowercased()) }).sorted()
                if !keys.isEmpty {
                    VStack(alignment: .leading, spacing: 8.0) {
                        Text("Keywords:")
                            .font(.custom(Constants.FontName.heavy, size: 14.0))
                            .foregroundStyle(Colors.text)
                        SingleAxisGeometryReader(axis: .horizontal) { geo in
                            HStack {
                                FlexibleView(
                                    availableWidth: geo.magnitude,
                                    data: keys,
                                    spacing: 8.0,
                                    alignment: .leading,
                                    content: { key in
                                        Button(action: {
                                            withAnimation {
                                                if selectedFilterWords.contains(where: {$0 == key}) {
                                                    selectedFilterWords.removeAll(where: {$0 == key})
                                                } else {
                                                    selectedFilterWords.append(key)
                                                }
                                            }
                                        }) {
                                            Text(key.capitalized)
                                                .font(.custom(Constants.FontName.body, size: 14.0))
                                                .foregroundStyle(selectedFilterWords.contains(where: {$0 == key}) ? Colors.foreground : Colors.text)
                                                .padding(.horizontal)
                                                .padding(.vertical, 8)
                                                .background(selectedFilterWords.contains(where: {$0 == key}) ? Colors.text : Colors.foreground)
                                                .clipShape(RoundedRectangle(cornerRadius: 14.0))
                                        }
                                    })
                                Spacer()
                            }
                        }
                    }
                }
            }
        }
    }
    
}

#Preview {
    
    FeedSearchFilterView(filterText: .constant(""), selectedFilterWords: .constant(["word1", "word2", "word3"]))
        .padding()
        .background(Colors.background)
    
}
