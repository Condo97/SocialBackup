//
//  SocialBackupApp.swift
//  SocialBackup
//
//  Created by Alex Coundouriotis on 10/9/24.
//

import SwiftUI

@main
struct SocialBackupApp: App {
    
    @StateObject var videoICloudUploadUpdater: VideoICloudUploadUpdater = VideoICloudUploadUpdater()
    
    var body: some Scene {
        WindowGroup {
            MainView()
                .environment(\.managedObjectContext, CDClient.mainManagedObjectContext)
                .environmentObject(videoICloudUploadUpdater)
        }
    }
}
