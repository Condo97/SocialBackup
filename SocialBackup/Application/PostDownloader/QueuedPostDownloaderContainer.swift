////
////  QueuedPostDownloaderContainer.swift
////  SocialBackup
////
////  Created by Alex Coundouriotis on 10/19/24.
////
//
//import SwiftUI
//
//struct QueuedPostDownloaderContainer: View {
//    
//    @ObservedObject var queuedTikTokDownloader: QueuedTikTokDownloader
//    
//    @Environment(\.managedObjectContext) private var viewContext
//    
//    @StateObject private var mediaICloudUploadUpdater = MediaICloudUploadUpdater()
//    
//    var body: some View {
//        QueuedPostDownloaderView(
////            queuedTikTokDownloader: queuedTikTokDownloader,
//            mediaICloudUploadUpdater: mediaICloudUploadUpdater)
//        .task { // Begin processing queue
//            // Ensure authToken
//            let authToken: String
//            do {
//                authToken = try await AuthHelper.ensure()
//            } catch {
//                // TODO: Handle Errors
//                print("Error ensuring authToken in ShareViewController... \(error)")
//                return
//            }
//            
//            queuedTikTokDownloader.startProcessingQueue(
//                authToken: authToken,
//                mediaICloudUploadUpdater: mediaICloudUploadUpdater,
//                managedContext: viewContext)
//        }
//    }
//    
//}
//
//#Preview {
//    
//    QueuedPostDownloaderContainer(queuedTikTokDownloader: QueuedTikTokDownloader())
//    
//}
