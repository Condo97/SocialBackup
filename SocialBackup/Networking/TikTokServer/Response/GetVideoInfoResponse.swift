//
//  GetVideoInfoResponse.swift
//  SocialBackup
//
//  Created by Alex Coundouriotis on 10/10/24.
//

import Foundation

// MARK: - Root
struct GetVideoInfoResponse: Codable {
    
    struct DownloadResponse: Codable {
        
        struct VideoData: Codable {
            
            struct Author: Codable {
                let id: String
                let uniqueID: String
                let nickname: String
                let avatar: String

                enum CodingKeys: String, CodingKey {
                    case id
                    case uniqueID = "unique_id"
                    case nickname
                    case avatar
                }
            }
            
            struct CommerceInfo: Codable {
                let advPromotable: Bool
                let auctionAdInvited: Bool
                let brandedContentType: Int
                let withCommentFilterWords: Bool

                enum CodingKeys: String, CodingKey {
                    case advPromotable = "adv_promotable"
                    case auctionAdInvited = "auction_ad_invited"
                    case brandedContentType = "branded_content_type"
                    case withCommentFilterWords = "with_comment_filter_words"
                }
            }
            
            struct MusicInfo: Codable {
                let id: String
                let title: String
                let play: String
                let cover: String
                let author: String
                let original: Bool
                let duration: Int
                let album: String

                enum CodingKeys: String, CodingKey {
                    case id
                    case title
                    case play
                    case cover
                    case author
                    case original
                    case duration
                    case album
                }
            }
            
            let awemeID: String
            let id: String
            let region: String
            let title: String
            let cover: String
            let aiDynamicCover: String
            let originCover: String
            let duration: Int
            let play: String
            let wmplay: String
            let hdplay: String?
            let size: Int
            let wmSize: Int
            let hdSize: Int
            let music: String
            let musicInfo: MusicInfo
            let playCount: Int
            let diggCount: Int
            let commentCount: Int
            let shareCount: Int
            let downloadCount: Int
            let collectCount: Int
            let createTime: Int
            let anchors: String?
            let anchorsExtras: String
            let isAd: Bool
            let commerceInfo: CommerceInfo
            let commercialVideoInfo: String
            let itemCommentSettings: Int
            let mentionedUsers: String
            let author: Author

            enum CodingKeys: String, CodingKey {
                case awemeID = "aweme_id"
                case id
                case region
                case title
                case cover
                case aiDynamicCover = "ai_dynamic_cover"
                case originCover = "origin_cover"
                case duration
                case play
                case wmplay
                case hdplay
                case size
                case wmSize = "wm_size"
                case hdSize = "hd_size"
                case music
                case musicInfo = "music_info"
                case playCount = "play_count"
                case diggCount = "digg_count"
                case commentCount = "comment_count"
                case shareCount = "share_count"
                case downloadCount = "download_count"
                case collectCount = "collect_count"
                case createTime = "create_time"
                case anchors
                case anchorsExtras = "anchors_extras"
                case isAd = "is_ad"
                case commerceInfo = "commerce_info"
                case commercialVideoInfo = "commercial_video_info"
                case itemCommentSettings = "item_comment_settings"
                case mentionedUsers = "mentioned_users"
                case author
            }
        }
        
        let code: Int
        let msg: String
        let processedTime: Double
        let data: VideoData

        enum CodingKeys: String, CodingKey {
            case code
            case msg
            case processedTime = "processed_time"
            case data
        }
    }
    
    let downloadResponse: DownloadResponse

    enum CodingKeys: String, CodingKey {
        case downloadResponse
    }
}
