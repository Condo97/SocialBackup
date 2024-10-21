//
//  SubscriptionIsActiveResponse.swift
//  SocialBackup
//
//  Created by Alex Coundouriotis on 10/13/24.
//

import Foundation

struct SubscriptionIsActiveResponse: Codable {
    
    struct Body: Codable {
        
        let isActive: Bool
        
        enum CodingKeys: String, CodingKey {
            case isActive
        }
        
    }
    
    let body: Body
    let success: Int
    
    enum CodingKeys: String, CodingKey {
        case body = "Body"
        case success = "Success"
    }
    
}
