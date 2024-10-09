//
//  SocialBackupApp.swift
//  SocialBackup
//
//  Created by Alex Coundouriotis on 10/9/24.
//

import SwiftUI

@main
struct SocialBackupApp: App {
    let persistenceController = PersistenceController.shared

    var body: some Scene {
        WindowGroup {
            ContentView()
                .environment(\.managedObjectContext, persistenceController.container.viewContext)
        }
    }
}
