//
//  PremiumUpdater.swift
//  Barback
//
//  Created by Alex Coundouriotis on 10/7/23.
//

import Foundation
import SwiftUI

class PremiumUpdater: ObservableObject {
    
    @Published var isPremium: Bool = persistentIsPremium
    
#if DEBUG
    private static let testOverrideIsPremiumTrue = true
    #else
    private static let testOverrideIsPremiumTrue = false
#endif
    
    private static var persistentIsPremium: Bool {
        get {
            UserDefaults.standard.bool(forKey: Constants.UserDefaults.storedIsPremium) || testOverrideIsPremiumTrue
        }
        set {
            UserDefaults.standard.set(newValue, forKey: Constants.UserDefaults.storedIsPremium)
        }
    }
    
    static func get() -> Bool {
        UserDefaults.standard.bool(forKey: Constants.UserDefaults.storedIsPremium) || testOverrideIsPremiumTrue
    }
    
    func registerTransaction(authToken: String, transactionID: UInt64) async throws {
        // Get isPremiumResponse from server with authToken and transactionID
        let subscriptionIsActiveResponse = try await TikTokServerConnector().registerTransaction(
            request: RegisterTransactionRequest(
                authToken: authToken,
                transactionId: transactionID))
        
        // Update with isPremium value
        await update(isPremium: subscriptionIsActiveResponse.body.isActive)
    }
    
    func update(authToken: String) async throws {
        // Create authRequest
        let authRequest = AuthRequest(authToken: authToken)

        // Get isPremiumResponse from server
        let isPremiumResponse = try await TikTokServerConnector().getIsSubscriptionActive(request: authRequest)
        
        // Update with isPremium value
        await update(isPremium: isPremiumResponse.body.isActive)
    }
    
    private func update(isPremium: Bool) async {
        // Set persistentIsPremium to isPremium and self.isPremium to persistentIsPremium
        await MainActor.run {
            PremiumUpdater.persistentIsPremium = isPremium
            
            self.isPremium = PremiumUpdater.persistentIsPremium
        }
    }
    
}
