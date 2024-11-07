//
//  SummaryGenerator.swift
//  SocialBackup
//
//  Created by Alex Coundouriotis on 11/7/24.
//

import CoreData
import Foundation
import SwiftUI

class SummaryGenerator: ObservableObject {
    
    @Published var isLoading: Bool = false
    
    func generateSummary(for post: Post, in managedContext: NSManagedObjectContext) async throws {
        guard PremiumUpdater.get() else {
            // Throw subscriptionNotAuthorized
            throw SummaryGeneratorError.subscriptionNotAuthorized
        }
        
        defer { DispatchQueue.main.async { self.isLoading = false } }
        await MainActor.run { self.isLoading = true }
        
        await runSummaryGenerator(for: post, in: managedContext)
    }
    
    func generateSummaryForAll(in managedContext: NSManagedObjectContext) async throws {
        guard PremiumUpdater.get() else {
            // Throw subscriptionNotAuthorized
            throw SummaryGeneratorError.subscriptionNotAuthorized
        }
        
        defer { DispatchQueue.main.async { self.isLoading = false } }
        await MainActor.run { self.isLoading = true }
        
        let allPosts = try await managedContext.perform {
            let fetchRequest = Post.fetchRequest()
            return try managedContext.fetch(fetchRequest)
        }
        
        for post in allPosts {
            await runSummaryGenerator(for: post, in: managedContext)
        }
    }
    
    private func runSummaryGenerator(for post: Post, in managedContext: NSManagedObjectContext) async {
//            if PremiumUpdater.get() { TODO: Enable Premium Check
        // Ensure authToken
        let authToken: String
        do {
            authToken = try await AuthHelper.ensure()
        } catch {
            // TODO: Handle Errors
            print("Error ensuring authToken in PostDownloaderView... \(error)")
            return
        }
        
        // Update post videoSummary if any generated field is nil
    if post.generatedFieldIsNil {
            do {
                try await PostPersistenceManager.getAndSavePostSummary(
                    authToken: authToken,
                    to: post,
                    in: managedContext)
            } catch PostPersistenceManagerError.noTranscription {
                // Transcribe again TODO: Is this good enough, because what if one of the content's transcriptions is missing? There should be an automatic refresh or check
                print("No transcriptions received")
                do {
                    try await PostDownloaderAndSaverAndBackuper().updateMissingTranscriptions(for: post, in: managedContext) // TODO: Is it ok to create a new instance here? Or should it use a class' StateObject for this
                    
                    // TODO: Learn if necessary to call this safely recursively
                } catch {
                    // TODO: Handle Errors
                    print("Error updating missing transcriptions in PostStatsContainer... \(error)")
                }
            } catch {
                // TODO: Handle Errors
                print("Error getting and saving post summary in PostStatsContainer... \(error)")
            }
        }
    
//            // Set postSummary and postTranscriptions
//            do {
//                checkForAndUpdateTranscriptions()
//            } catch {
//                // TODO: Handle Errors
//                print("Error getting post summary object in PostStatsContainer... \(error)")
//            }
//            }
    }
    
}

enum SummaryGeneratorError: Error {
    
    case subscriptionNotAuthorized
    
}
