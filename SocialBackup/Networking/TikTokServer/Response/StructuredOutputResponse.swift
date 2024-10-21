//
//  StructuredOutputResponse.swift
//  WriteSmith-SwiftUI
//
//  Created by Alex Coundouriotis on 8/18/24.
//

import Foundation

struct StructuredOutputResponse<StructuredOutput: Codable>: Codable {
    
    struct Body: Codable {
        
        var response: StructuredOutput
        
        enum CodingKeys: String, CodingKey {
            case response
        }
        
    }
    
    var body: Body
    var success: Int
    
    enum CodingKeys: String, CodingKey {
        case body = "Body"
        case success = "Success"
    }
    
}
