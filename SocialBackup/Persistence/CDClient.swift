//
//  CDClient.swift
//  ChitChat
//
//  Created by Alex Coundouriotis on 4/18/23.
//
// https://medium.com/@pietromessineo/ios-share-coredata-with-extension-and-app-groups-69f135628736

import CoreData
import Foundation
import UIKit

class CDClient: Any {
    
    internal static let appGroupName: String = Constants.Additional.appGroupName
    internal static let modelName: String = Constants.Additional.coreDataModelName
    
//    lazy var persistentContainer: NSPersistentContainer = {
//            /*
//             The persistent container for the application. This implementation
//             creates and returns a container, having loaded the store for the
//             application to it. This property is optional since there are legitimate
//             error conditions that could cause the creation of the store to fail.
//             */
//            #warning("Replace - group.pietromessineo.sharedData - with your own App Group Name")
//            let storeURL = URL.storeURL(for: "group.pietromessineo.sharedData", databaseName: "DataModel")
//            let storeDescription = NSPersistentStoreDescription(url: storeURL)
//            let container = NSPersistentContainer(name: "DataModel")
//            container.persistentStoreDescriptions = [storeDescription]
//            container.loadPersistentStores(completionHandler: { (storeDescription, error) in
//                if let error = error as NSError? {
//                    // Replace this implementation with code to handle the error appropriately.
//                    // fatalError() causes the application to generate a crash log and terminate. You should not use this function in a shipping application, although it may be useful during development.
//                    
//                    /*
//                     Typical reasons for an error here include:
//                     * The parent directory does not exist, cannot be created, or disallows writing.
//                     * The persistent store is not accessible, due to permissions or data protection when the device is locked.
//                     * The device is out of space.
//                     * The store could not be migrated to the current model version.
//                     Check the error message to determine what the actual problem was.
//                     */
//                    fatalError("Unresolved error \(error), \(error.userInfo)")
//                }
//            })
//            return container
//        }()
    
    private static let persistentContainer: NSPersistentContainer = {
        let container = NSPersistentContainer(name: modelName)
        container.observeAppExtensionDataChanges() // So that CoreData updates if a change is made in the extension
        
//        // All this to make it update when changed in the extension as well
//        guard let persistentStoreDescriptions = container.persistentStoreDescriptions.first else {
//            fatalError("\(#function): Failed to retrieve a persistent store description.")
//        }
//        persistentStoreDescriptions.setOption(true as NSNumber, forKey: NSPersistentHistoryTrackingKey)
//        persistentStoreDescriptions.setOption(true as NSNumber, forKey: NSPersistentStoreRemoteChangeNotificationPostOptionKey)
        
        guard let storeURL = FileManager.default.containerURL(forSecurityApplicationGroupIdentifier: appGroupName)?.appendingPathComponent("\(modelName).sqlite", conformingTo: .fileURL) else {
            fatalError("fileContianer could not be unwrapped in CDClient. Shared file container could not be created!")
        }
        let storeDescription = NSPersistentStoreDescription(url: storeURL)
        
        storeDescription.setOption(true as NSNumber, forKey: NSPersistentHistoryTrackingKey) // This to make it update when changed in the extension as well
        storeDescription.setOption(true as NSNumber, forKey: NSPersistentStoreRemoteChangeNotificationPostOptionKey) // This to make it update when changed in the extension as well
        
        container.persistentStoreDescriptions = [storeDescription]
        container.loadPersistentStores(completionHandler: {description, error in
            if let error = error as? NSError {
                fatalError("Couldn't load persistent stores!\n\(error)\n\(error.userInfo)")
            }
        })
        
        container.viewContext.automaticallyMergesChangesFromParent = true // Also for making it update when changed in the extension
        container.viewContext.mergePolicy = NSMergeByPropertyStoreTrumpMergePolicy // Also for making it update when changed in the extension
        return container
    }()
    
    public static let mainManagedObjectContext: NSManagedObjectContext = persistentContainer.viewContext
    
//    private static let persistentContainer: NSPersistentContainer = {
//        let container = NSPersistentContainer(name: modelName)
//        container.loadPersistentStores(completionHandler: {description, error in
//            if let error = error as? NSError {
//                fatalError("Couldn't load persistent stores!\n\(error)\n\(error.userInfo)")
//            }
//        })
//        return container
//    }()
//    
//    public static let mainManagedObjectContext: NSManagedObjectContext = persistentContainer.viewContext
    
    
    
}
