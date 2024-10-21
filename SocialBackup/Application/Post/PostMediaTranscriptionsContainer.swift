//
//  PostMediaTranscriptionsContainer.swift
//  SocialBackup
//
//  Created by Alex Coundouriotis on 10/20/24.
//

import Foundation
import SwiftUI

struct PostMediaTranscriptionsContainer: View {
    
    var post: Post
    
    var body: some View {
        PostMediaTranscriptionsView(medias: FetchRequest(
            sortDescriptors: [NSSortDescriptor(key: #keyPath(Media.index), ascending: true)],
            predicate: NSPredicate(format: "%K = %@", #keyPath(Media.post), post)))
    }
    
}
