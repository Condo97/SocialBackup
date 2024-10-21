//
//  StructuredOutputGenerator.swift
//  WriteSmith-SwiftUI
//
//  Created by Alex Coundouriotis on 8/11/24.
//

import Foundation

class StructuredOutputGenerator {
    
    static func generate<T: Codable>(authToken: String, model: GPTModels, messages: [OAIChatCompletionRequestMessage], endpoint: String) async throws -> T? {
        try await generate(
            structuredOutputRequest: StructuredOutputRequest(
                authToken: authToken,
                model: model,
                messages: messages),
            endpoint: endpoint)
    }
    
    static func generate<T: Codable>(structuredOutputRequest: StructuredOutputRequest, endpoint: String) async throws -> T? {
        // Get flash cards response
        let soResponse: StructuredOutputResponse<T> = try await TikTokServerConnector().structuredOutputRequest(
            endpoint: endpoint,
            request: structuredOutputRequest)
        
        return soResponse.body.response
    }
    
}
