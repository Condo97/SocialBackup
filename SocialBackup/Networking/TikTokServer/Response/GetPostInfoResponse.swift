//
//  getPostInfoResponse.body.swift
//  SocialBackup
//
//  Created by Alex Coundouriotis on 10/10/24.
//

import Foundation

struct GetPostInfoResponse: Codable {
    
    struct Body: Codable {
        
        let downloadResponse: DownloaderResponse
        
        struct DownloaderResponse: Codable {
            let url: String?
            let source: String?
            let author: String?
            let title: String?
            let thumbnail: String?
            let type: String?
            let error: Bool?
            let duration: Double?
            let medias: [Media]
            
            struct Media: Codable {
                
                let url: String?
                let quality: String?
                let type: String?
                let ext: String? // 'extension' is a reserved keyword in Swift
                let id: String?
                let duration: Int64?
                
                enum CodingKeys: String, CodingKey {
                    case url
                    case quality
                    case type
                    case ext = "extension" // Map 'extension' from JSON to 'ext'
                    case id
                    case duration
                }
                
            }
            
            enum CodingKeys: String, CodingKey {
                case url
                case source
                case author
                case title
                case thumbnail
                case type
                case error
                case duration
                case medias
            }
            
        }
        
        enum CodingKeys: String, CodingKey {
            case downloadResponse
        }
        
    }
    
    let body: Body
    let success: Int
    
    enum CodingKeys: String, CodingKey {
        case body = "Body"
        case success = "Success"
    }
    
}

//extension getPostInfoResponse.body.DownloaderResponse {
//
//    var highestQualityVideo: Media? {
//        var highestQualityMedia: Media?
//        for media in medias {
//            if highestQualityMedia == nil {
//                highestQualityMedia = media
//                continue
//            }
//            
//            if let mediaQualityRaw = media.quality,
//               let mediaQuality = GetPostInfoResponseExpectedMediaQualities(rawValue: mediaQualityRaw) {
//                if let highestQualityMediaQualityRaw = highestQualityMedia!.quality,
//                   let highestQualityMediaQuality = GetPostInfoResponseExpectedMediaQualities(rawValue: highestQualityMediaQualityRaw) {
//                    if mediaQuality > highestQualityMediaQuality {
//                        highestQualityMedia = media
//                    }
//                }
//            }
//        }
//        
//        return highestQualityMedia
//    }
//    
//}
