//
//  SyncStatus.swift
//  SocialBackup
//
//  Created by Alex Coundouriotis on 10/11/24.
//

import Foundation

enum SyncStatus: String, Codable {
    case notBackedUp       // Video is not backed up to iCloud.
    case pendingBackup     // Video is ready to be backed up.
    case backingUp         // Video is currently being backed up.
    case backedUp          // Video is backed up to iCloud.
    case backupFailed      // Backup process failed.
}
