//
//  GPTModels.swift
//  WriteSmith-SwiftUI
//
//  Created by Alex Coundouriotis on 7/31/24.
//

import Foundation

enum GPTModels: String, Codable {
    
    case gpt4oMini = "gpt-4o-mini"
    case gpt4o = "gpt-4o"
    
}

extension GPTModels {
    
    static func from(id: String) -> GPTModels {
        switch id {
        case GPTModels.gpt4o.rawValue:
            GPTModels.gpt4o
        default:
            GPTModels.gpt4oMini
        }
    }
    
    var name: String {
        switch self {
        case .gpt4oMini:
            "GPT-4o Mini"
        case .gpt4o:
            "GPT-4o + Vision"
        }
    }
    
    var isPremium: Bool {
        switch self {
        case .gpt4oMini:
            false
        case .gpt4o:
            true
        }
    }
    
}
