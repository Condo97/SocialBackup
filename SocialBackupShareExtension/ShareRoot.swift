//
//  ShareRoot.swift
//  SocialBackupShareExtension
//
//  Created by Alex Coundouriotis on 10/19/24.
//

import CoreData
import SwiftUI

struct ShareRoot: View {
    
    var onDismiss: () -> Void
    
    @StateObject private var postDownloaderAndSaverAndBackuper: PostDownloaderAndSaverAndBackuper = PostDownloaderAndSaverAndBackuper()
    
    @State private var managedContext: NSManagedObjectContext = CDClient.mainManagedObjectContext
    
    var body: some View {
        ShareView(onDismiss: onDismiss)
            .environment(\.managedObjectContext, managedContext)
            .environmentObject(postDownloaderAndSaverAndBackuper)
    }
    
}

#Preview {
    
    ShareRoot(onDismiss: {
        
    })
    
}
