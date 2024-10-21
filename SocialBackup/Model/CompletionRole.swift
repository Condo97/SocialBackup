//
//  CompletionRole.swift
//  WriteSmith-SwiftUI
//
//  Created by Alex Coundouriotis on 8/4/24.
//

import Foundation


enum CompletionRole: String, Codable {
    
    case assistant = "assistant"
    case system = "system"
    case user = "user"
    
}


extension CompletionRole {
    
    static func from(sender: Sender) -> CompletionRole {
        switch sender {
        case .ai:
                .assistant
        case .user:
                .user
        }
    }
    
}
