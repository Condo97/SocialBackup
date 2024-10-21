//
//  FeedPostPreviewButton.swift
//  SocialBackup
//
//  Created by Alex Coundouriotis on 10/14/24.
//

import SwiftUI

struct FeedPostPreviewButton: View {
    
    var post: Post?
    var size: Size
    var onSelect: () -> Void
    
    enum Size {
        
        case short
        case tall
        
        var aspectRatio: CGFloat {
            switch self {
            case .short: 0.76
            case .tall: 0.38
            }
        }
        
    }
    
    var body: some View {
        Button(action: onSelect) {
            Group {
                if let post = post {
                    Color.clear
                        .background(PostPreviewContainer(post: post))
                } else {
                    Color.clear
                }
            }
            .aspectRatio(size.aspectRatio, contentMode: .fill)
            .clipped()
        }
        
    }
}

#Preview {
    
//    FeedPostPreviewButton()
    
}
