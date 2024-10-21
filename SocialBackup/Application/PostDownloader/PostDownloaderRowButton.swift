//
//  PostDownloaderRowButton.swift
//  SocialBackup
//
//  Created by Alex Coundouriotis on 10/14/24.
//

import SwiftUI

struct PostDownloaderRowButton: View {
    
    let post: Post
    let onSelect: () -> Void

    var body: some View {
        Button(action: onSelect) {
            PostDownloaderRowView(post: post)
        }
    }
    
}

//#Preview {
//    
//    PostDownloaderRowButton()
//
//}
