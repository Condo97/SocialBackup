//
//  AuthHelper.swift
//  ChitChat
//
//  Created by Alex Coundouriotis on 3/30/23.
//

import Foundation
import SwiftUI

class AuthHelper {
    
//    static func get() -> String? {
//        return UserDefaults.standard.string(forKey: Constants.UserDefaults.authTokenKey)
//    }
    
    @AppStorage("authToken") private static var authToken: String?
    
    /***
     Ensure - Gets the authToken either from the server or locally
     
     throws
        - If the client cannot get the AuthToken from the server and there is no AuthToken available locally
     */
    static func ensure() async throws -> String {
        // If no authToken, register the user and update the authToken in UserDefaults
        if authToken == nil {
            let registerUserResponse = try await TikTokServerConnector().registerUser()
            
            authToken = registerUserResponse.body.authToken
        }
        
        return authToken!
    }
    
    /***
     Regenerate - Deletes current authToken and gets a new one from the server
     
     throws
        - If the client cannot get the AuthToken from the server and there is no AuthToken available locally
     */
    @discardableResult
    static func regenerate() async throws -> String {
        authToken = nil
        
        let registerUserResponse = try await TikTokServerConnector().registerUser()
        
        authToken = registerUserResponse.body.authToken
        
        return authToken!
    }
    
}
