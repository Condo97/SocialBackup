//
//  GetImportantConstantsResponse.swift
//  ChitChat
//
//  Created by Alex Coundouriotis on 3/30/23.
//

import Foundation

struct GetImportantConstantsResponse: Codable {
    
    struct Body: Codable {
        
        var sharedSecret: String?
        
        var weeklyProductID: String?
        var monthlyProductID: String?
        var annualProductID: String?
        
        var shareURL: String?
        
        enum CodingKeys: String, CodingKey {
            case sharedSecret
            case weeklyProductID
            case monthlyProductID
            case annualProductID
            case shareURL
        }
        
    }
    
    var body: Body
    var success: Int
    
    enum CodingKeys: String, CodingKey {
        case body = "Body"
        case success = "Success"
    }
    
}
