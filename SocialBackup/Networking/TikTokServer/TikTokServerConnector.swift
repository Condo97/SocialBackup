//
//  TikTokServerConnector.swift
//  SocialBackup
//
//  Created by Alex Coundouriotis on 10/10/24.
//

import Foundation

class TikTokServerConnector {
    
    static func getVideoInfo(request: GetVideoInfoRequest) async throws -> GetVideoInfoResponse {
        let (data, response) = try await HTTPSClient.post(
            url: URL(string: "\(Constants.Networking.TikTokServer.baseURL)\(Constants.Networking.TikTokServer.Endpionts.getVideoInfo)")!,
            body: request,
            headers: nil)
        
        let checkIfChatRequestsImageRevisionResponse = try JSONDecoder().decode(GetVideoInfoResponse.self, from: data)
        
        return checkIfChatRequestsImageRevisionResponse
    }
    
}
