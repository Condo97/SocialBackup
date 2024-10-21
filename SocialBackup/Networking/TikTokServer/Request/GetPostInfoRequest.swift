//
//  GetPostInfoRequest.swift
//  SocialBackup
//
//  Created by Alex Coundouriotis on 10/10/24.
//

import Foundation

struct GetPostInfoRequest: Codable {
    
    let authToken: String
    let postURL: String
    
}
