//
//  QueuedTikTokDownloader.swift
//  SocialBackup
//
//  Created by Alex Coundouriotis on 10/19/24.
//

import CoreData
import Foundation

class QueuedTikTokDownloader: ObservableObject {
    
    @Published var recentlyDownloadedPosts: [Post] = []
    @Published var isProcessing: Bool = false
    
    private static let appGroupUserDefaults = UserDefaults(suiteName: Constants.Additional.appGroupName)
    private static let queueKey = "downloadQueue"
    
    // Accessing the queue from UserDefaults ensures it's shared and persistent
    private(set) static var queue: [String] {
        get {
            return appGroupUserDefaults?.stringArray(forKey: queueKey) ?? []
        }
        set {
            appGroupUserDefaults?.set(newValue, forKey: queueKey)
        }
    }
    
    // Adds a new URL to the queue
    static func enqueue(urlString: String) {
        var currentQueue = queue
        currentQueue.append(urlString)
        queue = currentQueue
    }
    
    // Adds a new URL to the queue
    func enqueue(urlString: String) {
        QueuedTikTokDownloader.enqueue(urlString: urlString)
    }
    
    // Starts processing the queue if not already processing
    func startProcessingQueue(authToken: String, postDownloaderAndSaverAndBackuper: PostDownloaderAndSaverAndBackuper, mediaICloudUploadUpdater: MediaICloudUploadUpdater, managedContext: NSManagedObjectContext) {
        guard !QueuedTikTokDownloader.queue.isEmpty else {
            return
        }
        
        guard !isProcessing else { return }
        DispatchQueue.main.async {
            self.isProcessing = true
        }
        processNext(authToken: authToken, postDownloaderAndSaverAndBackuper: postDownloaderAndSaverAndBackuper, mediaICloudUploadUpdater: mediaICloudUploadUpdater, managedContext: managedContext)
    }
    
    // Processes the next URL in the queue
    private func processNext(authToken: String, postDownloaderAndSaverAndBackuper: PostDownloaderAndSaverAndBackuper, mediaICloudUploadUpdater: MediaICloudUploadUpdater, managedContext: NSManagedObjectContext) {
        guard !QueuedTikTokDownloader.queue.isEmpty else {
            DispatchQueue.main.async {
                self.isProcessing = false
            }
            return
        }
        
        let urlString = QueuedTikTokDownloader.queue.removeFirst()
        
        Task {
            do {
                // Perform the download operation
                let post = try await postDownloaderAndSaverAndBackuper.createAndDownload(
                    urlString: urlString,
                    authToken: authToken,
                    mediaICloudUploadUpdater: mediaICloudUploadUpdater,
                    in: managedContext
                )
                
                // Append post to recentlyDownloadedPosts
                if let post = post {
                    await MainActor.run {
                        recentlyDownloadedPosts.append(post)
                    }
                }
            } catch {
                // TODO: Handle errors (e.g., retry logic or logging)
                print("Error downloading and saving post in QueuedTikTokDownloader... \(error)")
            }
            
//            // Remove the URL from the queue
//            var currentQueue = QueuedTikTokDownloader.queue
//            currentQueue.removeFirst()
//            QueuedTikTokDownloader.queue = currentQueue
            
            // Continue with the next URL
            processNext(authToken: authToken, postDownloaderAndSaverAndBackuper: postDownloaderAndSaverAndBackuper, mediaICloudUploadUpdater: mediaICloudUploadUpdater, managedContext: managedContext)
        }
    }
    
}

