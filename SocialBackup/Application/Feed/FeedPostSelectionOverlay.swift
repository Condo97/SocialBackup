//
//  FeedPostSelectionOverlay.swift
//  SocialBackup
//
//  Created by Alex Coundouriotis on 11/11/24.
//

import SwiftUI

struct FeedPostSelectionOverlay: ViewModifier {
    
    var post: Post?
    @Binding var isSelecting: Bool
    @Binding var selected: [Post]
    
    func body(content: Content) -> some View {
        content
            .overlay {
                if isSelecting,
                   let post = post {
                    Button(action: {
                        withAnimation {
                            if selected.contains(post) {
                                selected.removeAll(where: { $0 == post })
                            } else {
                                selected.append(post)
                            }
                        }
                    }) {
                        ZStack(alignment: .bottomTrailing) {
                            if selected.contains(post) {
                                Color.black.opacity(0.2)
                            } else {
                                Color.clear
                            }
                            Image(systemName: selected.contains(post) ? "checkmark.circle.fill" : "circle")
                                .font(.custom(Constants.FontName.body, size: 17.0))
                                .foregroundStyle(Colors.text)
                                .padding()
                        }
                    }
                }
            }
    }
    
}

extension View {
    
    func feedPostSelectionOverlay(post: Post?, isSelecting: Binding<Bool>, selected: Binding<[Post]>) -> some View {
        self
            .modifier(FeedPostSelectionOverlay(post: post, isSelecting: isSelecting, selected: selected))
    }
    
}
