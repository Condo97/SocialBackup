//
//  OAIErrorResponse.swift
//  AICodingHelper
//
//  Created by Alex Coundouriotis on 7/30/24.
//

import Foundation


struct OAIErrorResponse: Codable {
    
    struct Error: Codable {
        
        enum ErrorCodes: String, Codable {
            case invalid_api_key = "invalid_api_key"
            case string_above_max_length = "string_above_max_length"
            case unknown // Add an unknown case without a raw value
            
            init(from decoder: Decoder) throws {
                let container = try decoder.singleValueContainer()
                let rawValue = try container.decode(String.self)
                
                if let errorCode = ErrorCodes(rawValue: rawValue) {
                    self = errorCode
                } else {
                    print("Unknown error code when decoding in OAIErrorResponse \(rawValue)")
                    self = .unknown // Fallback to unknown for unrecognized values
                }
            }
        }
        
        let message: String?
        let type: String?
        let param: String?
        let code: ErrorCodes?
        
        enum CodingKeys: String, CodingKey {
            case message
            case type
            case param
            case code
        }
        
    }
    
    let error: Error
    
    enum CodingKeys: String, CodingKey {
        case error
    }
    
}
