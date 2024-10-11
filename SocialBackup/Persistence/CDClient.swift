//
//  CDClient.swift
//  ChitChat
//
//  Created by Alex Coundouriotis on 4/18/23.
//

import CoreData
import Foundation
import UIKit

class CDClient: Any {
    
    internal static let modelName: String = Constants.Additional.coreDataModelName
    
    private static let persistentContainer: NSPersistentContainer = {
        let container = NSPersistentContainer(name: modelName)
        container.loadPersistentStores(completionHandler: {description, error in
            if let error = error as? NSError {
                fatalError("Couldn't load persistent stores!\n\(error)\n\(error.userInfo)")
            }
        })
        return container
    }()
    
    public static let mainManagedObjectContext: NSManagedObjectContext = persistentContainer.viewContext
    
    
    
}
