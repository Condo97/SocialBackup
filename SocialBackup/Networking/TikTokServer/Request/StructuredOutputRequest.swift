//
//  StructuredOutputRequest.swift
//  WriteSmith-SwiftUI
//
//  Created by Alex Coundouriotis on 8/11/24.
//

import Foundation

struct StructuredOutputRequest: Codable {
    
    let authToken: String
    let model: GPTModels
    let messages: [OAIChatCompletionRequestMessage]
    
    enum CodingKeys: String, CodingKey {
        case authToken
        case model
        case messages
    }
    
}
