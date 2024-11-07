//
//  PostSource.swift
//  SocialBackup
//
//  Created by Alex Coundouriotis on 10/14/24.
//

import Foundation

enum PostSource: Codable, CaseIterable {
    
    case tiktok
    case instagram
    case x
    case youtube
    
    public static func from(_ string: String) -> PostSource? {
        switch string.lowercased() { // TODO: Move to a class for decoding
        case "tiktok": .tiktok
        case "instagram": .instagram
        case "reels": .instagram
        case "x": .x
        case "twitter": .x
        case "youtube": .youtube
        default: nil
        }
    }
    
}

extension PostSource {
    
    var imageName: String {
        switch self { // TODO: Move to a class for decoding
        case .tiktok: Images.SocialIcons.tiktok
        case .instagram: Images.SocialIcons.instagram
        case .x: Images.SocialIcons.x
        case .youtube: Images.SocialIcons.youTube
        }
    }
    
    var name: String {
        switch self {
        case .tiktok: "TikTok"
        case .instagram: "Instagram"
        case .x: "X"
        case .youtube: "YouTube"
        }
    }
    
}
