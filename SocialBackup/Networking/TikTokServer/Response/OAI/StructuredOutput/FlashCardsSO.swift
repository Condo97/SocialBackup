//
//  FlashCardsSO.swift
//  WriteSmith-SwiftUI
//
//  Created by Alex Coundouriotis on 8/11/24.
//

import Foundation

struct FlashCardsSO: Codable {
    
    struct FlashCard: Codable {
        
        let front: String
        let back: String
        
        enum CodingKeys: String, CodingKey {
            case front
            case back
        }
        
    }
    
//    let title: String
    let flashCards: [FlashCard]
    
    enum CodingKeys: String, CodingKey {
//        case title
        case flashCards
    }
    
}
