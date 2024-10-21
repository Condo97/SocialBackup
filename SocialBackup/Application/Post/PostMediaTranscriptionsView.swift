//
//  PostMediaTranscriptionsView.swift
//  SocialBackup
//
//  Created by Alex Coundouriotis on 10/20/24.
//

import Foundation
import SwiftUI

struct PostMediaTranscriptionsView: View {
    
    @FetchRequest var medias: FetchedResults<Media>
    
    var body: some View {
        ScrollView {
            VStack(alignment: .leading) {
                ForEach(medias.indices, id: \.self) { mediaIndex in
                    if let transcription = medias[mediaIndex].transcription {
                        Text("Transcription \(mediaIndex)")
                            .font(.custom(Constants.FontName.heavy, size: 20.0))
                        Text(transcription)
                            .font(.custom(Constants.FontName.body, size: 12.0))
                        Divider()
                    }
                }
            }
        }
        .navigationTitle("Transcriptions")
    }
    
}

#Preview {
    
    PostMediaTranscriptionsView(medias: FetchRequest(sortDescriptors: [NSSortDescriptor(key: #keyPath(Media.index), ascending: true)]))
    
}
