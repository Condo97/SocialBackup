//
//  FeedView.swift
//  SocialBackup
//
//  Created by Alex Coundouriotis on 10/14/24.
//

import SwiftUI

struct FeedView: View {
    
    @FetchRequest var posts: FetchedResults<Post>
    var onSelectPost: (Post) -> Void
    
    var body: some View {
        LazyVGrid(columns: [GridItem(.flexible(), spacing: 0.0), GridItem(.flexible(), spacing: 0.0), GridItem(.flexible(), spacing: 0.0)], spacing: 0.0) {
            ForEach(0..<(Int(ceil(Double(posts.count) / 5.0))), id: \.self) { postIndex in
                if postIndex % 2 == 0 {
                    VStack(spacing: 0.0) {
                        FeedPostPreviewButton(
                            post: posts[safe: postIndex],
                            size: .short,
                            onSelect: { if let post = posts[safe: postIndex] { onSelectPost(post) } })
                        FeedPostPreviewButton(
                            post: posts[safe: postIndex + 1],
                            size: .short,
                            onSelect: { if let post = posts[safe: postIndex + 1] { onSelectPost(post) } })
                    }
                    VStack(spacing: 0.0) {
                        FeedPostPreviewButton(
                            post: posts[safe: postIndex + 2],
                            size: .short,
                            onSelect: { if let post = posts[safe: postIndex + 2] { onSelectPost(post) } })
                        FeedPostPreviewButton(
                            post: posts[safe: postIndex + 3],
                            size: .short,
                            onSelect: { if let post = posts[safe: postIndex + 3] { onSelectPost(post) } })
                    }
                    VStack {
                        FeedPostPreviewButton(
                            post: posts[safe: postIndex + 4],
                            size: .tall,
                            onSelect: { if let post = posts[safe: postIndex + 4] { onSelectPost(post) } })
                    }
                } else {
                    VStack {
                        FeedPostPreviewButton(
                            post: posts[postIndex],
                            size: .tall,
                            onSelect: { if let post = posts[safe: postIndex] { onSelectPost(post) } })
                    }
                    VStack(spacing: 0.0) {
                        FeedPostPreviewButton(
                            post: posts[safe: postIndex + 1],
                            size: .short,
                            onSelect: { if let post = posts[safe: postIndex + 1] { onSelectPost(post) } })
                        FeedPostPreviewButton(
                            post: posts[safe: postIndex + 2],
                            size: .short,
                            onSelect: { if let post = posts[safe: postIndex + 2] { onSelectPost(post) } })
                    }
                    VStack(spacing: 0.0) {
                        FeedPostPreviewButton(
                            post: posts[safe: postIndex + 3],
                            size: .short,
                            onSelect: { if let post = posts[safe: postIndex + 3] { onSelectPost(post) } })
                        FeedPostPreviewButton(
                            post: posts[safe: postIndex + 4],
                            size: .short,
                            onSelect: { if let post = posts[safe: postIndex + 4] { onSelectPost(post) } })
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
