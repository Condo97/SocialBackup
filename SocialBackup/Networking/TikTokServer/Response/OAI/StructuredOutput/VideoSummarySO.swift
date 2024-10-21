//
//  VideoSummarySO.swift
//  SocialBackup
//
//  Created by Alex Coundouriotis on 10/20/24.
//

import Foundation

struct VideoSummarySO: Codable {
    
    let title: String
    let topic: String
    let shortSummary: String
    let mediumSummary: String
    let emotions: [String]
    let tags: [String]
    let keywords: [String]
    let keyEntities: [String]
    
    enum CodingKeys: String, CodingKey {
        case title
        case topic
        case shortSummary
        case mediumSummary
        case emotions
        case tags
        case keywords
        case keyEntities
    }
    
}
