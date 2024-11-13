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
    @StateObject var postDownloaderAndSaverAndBackuper: PostDownloaderAndSaverAndBackuper = PostDownloaderAndSaverAndBackuper()
    
    @State private var isShowingUltraView: Bool = false
    
    @AppStorage("shouldShowIntro") var shouldShowIntro: Bool = true
    
    init() {
        let coloredAppearance = UINavigationBarAppearance()
        coloredAppearance.backgroundColor = UIColor(Colors.background)
        coloredAppearance.titleTextAttributes = [.foregroundColor: UIColor(.white)]
        coloredAppearance.largeTitleTextAttributes = [.foregroundColor: UIColor(.white)]
        UINavigationBar.appearance().standardAppearance = coloredAppearance
        UINavigationBar.appearance().scrollEdgeAppearance = coloredAppearance
        
        UIView.appearance().tintColor = UIColor(Colors.text)
        
        UIView.appearance(whenContainedInInstancesOf: [UIAlertController.self]).tintColor = UIColor(Colors.foreground)
        
//        UITextField.appearance().tintColor = UIColor(Colors.text)
    }
    
    var body: some Scene {
        WindowGroup {
            Group {
                if shouldShowIntro {
                    IntroPresenterView(onFinish: {
                        isShowingUltraView = true
                        
                        DispatchQueue.main.asyncAfter(deadline: .now() + 1.0) {
                            self.shouldShowIntro = false                            
                        }
                    })
                } else {
                    MainView()
                }
            }
            .ultraViewPopover(isPresented: $isShowingUltraView)
            .environment(\.managedObjectContext, CDClient.mainManagedObjectContext)
            .environmentObject(postICloudUploadUpdater)
            .environmentObject(premiumUpdater)
            .environmentObject(productUpdater)
            .environmentObject(postDownloaderAndSaverAndBackuper)
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
                
                // Check all posts in background
                do {
                    let allPosts = try CDClient.mainManagedObjectContext.fetch(Post.fetchRequest())
                    for post in allPosts {
                        Task {
                            do {
                                try await postDownloaderAndSaverAndBackuper.repair(
                                    post: post,
                                    authToken: authToken,
                                    mediaICloudUploadUpdater: postICloudUploadUpdater,
                                    in: CDClient.mainManagedObjectContext)
                            } catch {
                                print("Error repairing posts in SocialBackupApp... \(error)")
                            }
                        }
                    }
                } catch {
                    // TODO: Handle Errors
                    print("Error getting all posts in SocialBackupApp... \(error)")
                }
//                    do {
//                        try postIntegrityChecker.checkAllPostsInBackground(authToken: authToken, mediaICloudUploadUpdater: postICloudUploadUpdater, in: CDClient.mainManagedObjectContext)
//                    } catch {
//                        // TODO: Handle Errors
//                        print("Error checking all posts in background in SocialBackupApp... \(error)")
//                    }
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
