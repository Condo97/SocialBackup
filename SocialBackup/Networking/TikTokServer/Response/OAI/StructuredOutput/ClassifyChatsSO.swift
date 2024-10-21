//
//  ClassifyChatsSO.swift
//  WriteSmith-SwiftUI
//
//  Created by Alex Coundouriotis on 8/11/24.
//

import Foundation

struct ClassifyChatsSO: Codable {
    
    let wantsFlashCards: Bool
    let wantsImageGeneration: Bool
    let wantsWebSearch: Bool
    
    enum CodingKeys: String, CodingKey {
        case wantsFlashCards
        case wantsImageGeneration
        case wantsWebSearch
    }
    
}
