//
//  SocialBackupApp.swift
//  SocialBackup
//
//  Created by Alex Coundouriotis on 10/9/24.
//

import SwiftUI

@main
struct SocialBackupApp: App {
    
//    @UIApplicationDelegateAdaptor(AppDelegate.self) var appDelegate
    
    @StateObject var postICloudUploadUpdater: MediaICloudUploadUpdater = MediaICloudUploadUpdater()
    @StateObject var premiumUpdater: PremiumUpdater = PremiumUpdater()
    @StateObject var productUpdater: ProductUpdater = ProductUpdater()
    
    init() {
        let coloredAppearance = UINavigationBarAppearance()
        coloredAppearance.backgroundColor = UIColor(Colors.background)
        coloredAppearance.titleTextAttributes = [.foregroundColor: UIColor(.white)]
        coloredAppearance.largeTitleTextAttributes = [.foregroundColor: UIColor(.white)]
        UINavigationBar.appearance().standardAppearance = coloredAppearance
        UINavigationBar.appearance().scrollEdgeAppearance = coloredAppearance
        
        UIView.appearance().tintColor = UIColor(Colors.text)
    }
    
    var body: some Scene {
        WindowGroup {
            MainView()
                .environment(\.managedObjectContext, CDClient.mainManagedObjectContext)
                .environmentObject(postICloudUploadUpdater)
                .environmentObject(premiumUpdater)
                .environmentObject(productUpdater)
                .task {
                    // Ensure AuthToken
                    let authToken: String
                    do {
                        authToken = try await AuthHelper.ensure()
                    } catch {
                        // TODO: Handle Errors
                        print("Error ensuring authToken in SocialBackupApp... \(error)")
                        return
                    }
                }
                .task {
                    // Update Constants
                    do {
                        try await ConstantsUpdater.update()
                    } catch {
                        // TODO: Handle Errors
                        print("Error updating constants in SocialBackupApp... \(error)")
                    }
                }
        }
    }
}
