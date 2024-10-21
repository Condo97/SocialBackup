//
//  PostDownloaderRowView.swift
//  SocialBackup
//
//  Created by Alex Coundouriotis on 10/19/24.
//

import SwiftUI

struct PostDownloaderRowView: View {
    
    let post: Post
    
    @Environment(\.managedObjectContext) private var viewContext
    
    @State private var offsetY: CGFloat = -500 // Initial offset (above the view)
    @State private var opacity: Double = 1    // Initial opacity

    var body: some View {
        VStack(spacing: 0.0) {
            PostPreviewContainer(post: post)
            
            HStack {
                // Saved
                Group {
                    if (try? post.allSyncedToICloud(in: viewContext)) ?? false {
                        Text(Image(systemName: "icloud.fill"))
                    }
                    Text(Image(systemName: "checkmark.circle.fill"))
                    Text("Saved")
                }
                .font(.custom(Constants.FontName.heavy, size: 12.0))
                .foregroundStyle(Colors.text)
                
                Spacer()
            }
            .padding(4)
        }
        .background(.black)
        .clipShape(RoundedRectangle(cornerRadius: 5.0))
        .padding()
        .offset(y: offsetY)
        .opacity(opacity)
        .onAppear {
            withAnimation(.easeOut(duration: 1.0)) {
                offsetY = 0      // Animate to default position
                opacity = 1      // Animate to fully visible
            }
        }
    }
    
}

#Preview {
    
    let post = try! CDClient.mainManagedObjectContext.fetch(Post.fetchRequest()).first!
    
    return ZStack {
        PostDownloaderRowView(post: post)
            .background(RoundedRectangle(cornerRadius: 5.0)
                .fill(Colors.background))
            .aspectRatio(contentMode: .fit)
            .frame(maxWidth: 350.0, maxHeight: 350.0)
            .padding()
    }
    .frame(maxWidth: .infinity, maxHeight: .infinity)

}
