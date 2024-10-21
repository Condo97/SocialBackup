//
//  GenerateSuggestionsSO.swift
//  WriteSmith-SwiftUI
//
//  Created by Alex Coundouriotis on 8/19/24.
//

import Foundation

struct GenerateSuggestionsSO: Codable {
    
    var suggestions: [String]
    
    enum CodingKeys: String, CodingKey {
        case suggestions
    }
    
}
