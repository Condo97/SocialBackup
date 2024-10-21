//
//  SyncStatus.swift
//  SocialBackup
//
//  Created by Alex Coundouriotis on 10/11/24.
//

import Foundation

enum SyncStatus: String, Codable {
    case notBackedUp       // Post is not backed up to iCloud.
    case pendingBackup     // Post is ready to be backed up.
    case backingUp         // Post is currently being backed up.
    case backedUp          // Post is backed up to iCloud.
    case backupFailed      // Backup process failed.
}
