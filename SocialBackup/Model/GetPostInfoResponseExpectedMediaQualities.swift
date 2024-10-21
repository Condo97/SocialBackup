//
//  GetPostInfoResponseExpectedMediaQualities.swift
//  SocialBackup
//
//  Created by Alex Coundouriotis on 10/12/24.
//

import Foundation

enum GetPostInfoResponseExpectedMediaQualities: String, Codable, Comparable {
    
    static func < (lhs: GetPostInfoResponseExpectedMediaQualities, rhs: GetPostInfoResponseExpectedMediaQualities) -> Bool {
        lhs.rank < rhs.rank
    }
    
    case hdNoWatermark = "hd_no_watermark"
    case noWatermark = "no_watermark"
    case watermark
    case audio
    case unknown
    
    var isContent: Bool {
        switch self {
        case .audio, .unknown: false
        default: true
        }
    }
    
    var rank: Int {
        switch self {
        case .hdNoWatermark:
            3
        case .noWatermark:
            2
        case .watermark:
            1
        case .audio:
            -1
        case .unknown:
            -1
        }
    }
    
}
