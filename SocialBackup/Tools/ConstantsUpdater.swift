//
//  ConstantsUpdater.swift
//  WriteSmith-SwiftUI
//
//  Created by Alex Coundouriotis on 10/31/23.
//

import Combine
import Foundation

class ConstantsUpdater: ObservableObject {
    
    private static let priceVAR1Suffix = "VAR1"
    private static let priceVAR2Suffix = "VAR2"
    
}

extension ConstantsUpdater {
    
    static var shareURL: String {
        get {
            UserDefaults.standard.string(forKey: Constants.UserDefaults.shareURL) ?? Constants.Additional.defaultShareURL.absoluteString
        }
        set {
            UserDefaults.standard.set(newValue, forKey: Constants.UserDefaults.shareURL)
        }
    }
    
    static var sharedSecret: String {
        get {
            UserDefaults.standard.string(forKey: Constants.UserDefaults.sharedSecret) ?? Constants.Additional.fallbackSharedSecret
        }
        set {
            UserDefaults.standard.set(newValue, forKey: Constants.UserDefaults.sharedSecret)
        }
    }
    
    static var weeklyProductID: String {
        get {
            UserDefaults.standard.string(forKey: Constants.UserDefaults.weeklyProductID) ?? Constants.Additional.fallbackWeeklyProductID
        }
        set {
            UserDefaults.standard.set(newValue, forKey: Constants.UserDefaults.weeklyProductID)
        }
    }
    
    static var monthlyProductID: String {
        get {
            UserDefaults.standard.string(forKey: Constants.UserDefaults.monthlyProductID) ?? Constants.Additional.fallbackMonthlyProductID
        }
        set {
            UserDefaults.standard.set(newValue, forKey: Constants.UserDefaults.monthlyProductID)
        }
    }
    
    static var annualProductID: String {
        get {
            UserDefaults.standard.string(forKey: Constants.UserDefaults.annualProductID) ?? Constants.Additional.fallbackAnnualProductID
        }
        set {
            UserDefaults.standard.set(newValue, forKey: Constants.UserDefaults.annualProductID)
        }
    }
    
    
    static func update() async throws {
        let response = try await TikTokServerConnector().getImportantConstants()
//        if response.success != 1 {
//            // Update constants if nil, since the server returned an error
//            setIfNil(Constants.defaultShareURL, forKey: Constants.UserDefaults.userDefaultStoredShareURL)
//            setIfNil(Constants.defaultFreeEssayCap, forKey: Constants.UserDefaults.userDefaultStoredFreeEssayCap)
//            setIfNil(Constants.defaultWeeklyDisplayPrice, forKey: Constants.UserDefaults.userDefaultStoredWeeklyDisplayPrice)
//            setIfNil(Constants.defaultMonthlyDisplayPrice, forKey: Constants.UserDefaults.userDefaultStoredMonthlyDisplayPrice)
//        }
//
//        // Update constants
//        UserDefaults.standard.set(response.body.shareURL, forKey: Constants.UserDefaults.userDefaultStoredShareURL)
//        UserDefaults.standard.set(response.body.freeEssayCap, forKey: Constants.UserDefaults.userDefaultStoredFreeEssayCap)
//        UserDefaults.standard.set(response.body.weeklyDisplayPrice, forKey: Constants.UserDefaults.userDefaultStoredWeeklyDisplayPrice)
//        UserDefaults.standard.set(response.body.monthlyDisplayPrice, forKey: Constants.UserDefaults.userDefaultStoredMonthlyDisplayPrice)
        
        if let responseShareURL = response.body.shareURL {
            shareURL = responseShareURL
        }
        
        if let responseSharedSecret = response.body.sharedSecret {
            sharedSecret = responseSharedSecret
        }
        
        if let responseWeeklyProductID = response.body.weeklyProductID {
            weeklyProductID = responseWeeklyProductID
        }
        
        if let responseMonthlyProductID = response.body.monthlyProductID {
            monthlyProductID = responseMonthlyProductID
        }
        
        if let responseAnnualProductID = response.body.annualProductID {
            annualProductID = responseAnnualProductID
        }
        
    }
    
    private static func setIfNil(_ value: Any, forKey key: String) {
        if UserDefaults.standard.object(forKey: key) == nil {
            UserDefaults.standard.set(value, forKey: key)
        }
    }
    
}
