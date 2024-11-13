//
//  FeedView.swift
//  SocialBackup
//
//  Created by Alex Coundouriotis on 10/14/24.
//

import SwiftUI

struct FeedView: View {
    
    @Binding var isSelecting: Bool
    @Binding var selected: [Post]
    @FetchRequest var posts: FetchedResults<Post>
    var onSelectPost: (Post) -> Void
    
    var body: some View {
        LazyVGrid(columns: [GridItem(.flexible(), spacing: 0.0), GridItem(.flexible(), spacing: 0.0), GridItem(.flexible(), spacing: 0.0)], spacing: 0.0) {
            let groupSize: Int = 5
            ForEach(0..<(Int(ceil(Double(posts.count) / Double(groupSize)))), id: \.self) { groupedPostIndex in
                let postIndex = groupedPostIndex * groupSize
                if postIndex % 2 == 0 {
                    VStack(spacing: 0.0) {
                        FeedPostPreviewButton(
                            post: posts[safe: postIndex],
                            size: .short,
                            onSelect: { if let post = posts[safe: postIndex] { onSelectPost(post) } })
                        .feedPostSelectionOverlay(post: posts[safe: postIndex], isSelecting: $isSelecting, selected: $selected)
                        FeedPostPreviewButton(
                            post: posts[safe: postIndex + 1],
                            size: .short,
                            onSelect: { if let post = posts[safe: postIndex + 1] { onSelectPost(post) } })
                        .feedPostSelectionOverlay(post: posts[safe: postIndex + 1], isSelecting: $isSelecting, selected: $selected)
                    }
                    VStack(spacing: 0.0) {
                        FeedPostPreviewButton(
                            post: posts[safe: postIndex + 2],
                            size: .short,
                            onSelect: { if let post = posts[safe: postIndex + 2] { onSelectPost(post) } })
                        .feedPostSelectionOverlay(post: posts[safe: postIndex + 2], isSelecting: $isSelecting, selected: $selected)
                        FeedPostPreviewButton(
                            post: posts[safe: postIndex + 3],
                            size: .short,
                            onSelect: { if let post = posts[safe: postIndex + 3] { onSelectPost(post) } })
                        .feedPostSelectionOverlay(post: posts[safe: postIndex + 3], isSelecting: $isSelecting, selected: $selected)
                    }
                    VStack {
                        FeedPostPreviewButton(
                            post: posts[safe: postIndex + 4],
                            size: .tall,
                            onSelect: { if let post = posts[safe: postIndex + 4] { onSelectPost(post) } })
                        .feedPostSelectionOverlay(post: posts[safe: postIndex + 4], isSelecting: $isSelecting, selected: $selected)
                    }
                } else {
                    VStack {
                        FeedPostPreviewButton(
                            post: posts[postIndex],
                            size: .tall,
                            onSelect: { if let post = posts[safe: postIndex] { onSelectPost(post) } })
                        .feedPostSelectionOverlay(post: posts[safe: postIndex], isSelecting: $isSelecting, selected: $selected)
                    }
                    VStack(spacing: 0.0) {
                        FeedPostPreviewButton(
                            post: posts[safe: postIndex + 1],
                            size: .short,
                            onSelect: { if let post = posts[safe: postIndex + 1] { onSelectPost(post) } })
                        .feedPostSelectionOverlay(post: posts[safe: postIndex + 1], isSelecting: $isSelecting, selected: $selected)
                        FeedPostPreviewButton(
                            post: posts[safe: postIndex + 2],
                            size: .short,
                            onSelect: { if let post = posts[safe: postIndex + 2] { onSelectPost(post) } })
                        .feedPostSelectionOverlay(post: posts[safe: postIndex + 2], isSelecting: $isSelecting, selected: $selected)
                    }
                    VStack(spacing: 0.0) {
                        FeedPostPreviewButton(
                            post: posts[safe: postIndex + 3],
                            size: .short,
                            onSelect: { if let post = posts[safe: postIndex + 3] { onSelectPost(post) } })
                        .feedPostSelectionOverlay(post: posts[safe: postIndex + 3], isSelecting: $isSelecting, selected: $selected)
                        FeedPostPreviewButton(
                            post: posts[safe: postIndex + 4],
                            size: .short,
                            onSelect: { if let post = posts[safe: postIndex + 4] { onSelectPost(post) } })
                        .feedPostSelectionOverlay(post: posts[safe: postIndex + 4], isSelecting: $isSelecting, selected: $selected)
                    }
                }
            }
        }
        
    }
}

//#Preview {
//    
//    FeedView()
//
//}
