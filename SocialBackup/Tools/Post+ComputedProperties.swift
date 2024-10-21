//
//  Post+ComputedProperties.swift
//  SocialBackup
//
//  Created by Alex Coundouriotis on 10/19/24.
//

import CoreData
import Foundation

extension Post {
    
    func allSyncedToICloud(in managedContext: NSManagedObjectContext) throws -> Bool {
        let fetchRequest = Media.fetchRequest()
        fetchRequest.sortDescriptors = [NSSortDescriptor(key: #keyPath(Media.index), ascending: false)]
        fetchRequest.predicate = NSPredicate(format: "%K = %@", #keyPath(Media.post), self)
        
        return try managedContext.performAndWait {
            let results = try managedContext.fetch(fetchRequest)
            return results.allSatisfy({ !($0.iCloudFilename?.isEmpty ?? true) })
        }
    }
    
}
