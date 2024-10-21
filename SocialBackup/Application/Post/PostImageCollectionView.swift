//
//  PostImageCollectionView.swift
//  SocialBackup
//
//  Created by Alex Coundouriotis on 10/12/24.
//

import SwiftUI

struct PostImageCollectionView: View {
    
    var subdirectory: String
    @FetchRequest var medias: FetchedResults<Media>
    
    var body: some View {
        GeometryReader { geometry in
            if #available(iOS 17.0, *) {
                ScrollView(.horizontal) {
                    HStack {
                        ForEach(medias) { media in
                            if let localFilename = media.localFilename {
                                let localFilepath = "\(subdirectory)/\(localFilename)"
                                if let imageData = try? DocumentSaver.getData(from: localFilepath),
                                   let uiImage = UIImage(data: imageData) {
                                    Image(uiImage: uiImage)
                                        .resizable()
                                        .aspectRatio(contentMode: .fit)
                                        .frame(width: geometry.size.width)
                                        .frame(maxHeight: .infinity)
                                }
                            }
                        }
                    }
                }
                .scrollTargetBehavior(.paging)
            } else {
                ScrollView(.horizontal) {
                    HStack {
                        ForEach(medias) { media in
                            if let localFilename = media.localFilename {
                                let localFilepath = "\(subdirectory)/\(localFilename)"
                                if let imageData = try? DocumentSaver.getData(from: localFilepath),
                                   let uiImage = UIImage(data: imageData) {
                                    Image(uiImage: uiImage)
                                        .resizable()
                                        .aspectRatio(contentMode: .fit)
                                        .frame(width: geometry.size.width)
                                        .frame(maxHeight: .infinity)
                                }
                            }
                        }
                    }
                }
            }
        }
    }
}

#Preview {
    
    GeometryReader { geometry in
        ScrollView {
            PostImageCollectionView(
                subdirectory: {
                    try! CDClient.mainManagedObjectContext.fetch(Post.fetchRequest()).first(where: { $0.subdirectory != nil })!.subdirectory!
                }(),
                medias: FetchRequest(sortDescriptors: [NSSortDescriptor(key: #keyPath(Media.index), ascending: true)]))
                .environment(\.managedObjectContext, CDClient.mainManagedObjectContext)
        }
    }
    
}
