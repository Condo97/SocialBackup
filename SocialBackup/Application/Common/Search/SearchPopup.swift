//
//  SearchPopup.swift
//  SocialBackup
//
//  Created by Alex Coundouriotis on 11/7/24.
//

import Foundation
import SwiftUI

struct SearchPopup: View {
    
    let title: String
    let posts: FetchRequest<Post>
    let onClose: () -> Void
    
    var body: some View {
        NavigationStack {
            PostCollectionView(posts: posts)
                .navigationTitle(title)
                .navigationBarTitleDisplayMode(.inline)
                .toolbar {
                    ToolbarItem(placement: .navigationBarTrailing) {
                        Button(action: onClose) {
                            Image(systemName: "xmark")
                        }
                    }
                }
        }
    }
    
}

extension View {
    
    func searchPopup(title: String, posts: FetchRequest<Post>, isPresented: Binding<Bool>) -> some View {
        self
            .fullScreenCover(isPresented: isPresented) {
                SearchPopup(
                    title: title,
                    posts: posts,
                    onClose: { isPresented.wrappedValue = false })
            }
    }
    
}
