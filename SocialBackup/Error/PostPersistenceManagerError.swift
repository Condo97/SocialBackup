//
//  PostPersistenceManagerError.swift
//  SocialBackup
//
//  Created by Alex Coundouriotis on 10/20/24.
//

import Foundation

enum PostPersistenceManagerError: Error {
    
    case missingGetPostInfoResponse
    case nilVideoSummary
    case noTranscription
    
}
