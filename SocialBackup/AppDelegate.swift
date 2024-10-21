//
//  AppDelegate.swift
//  SocialBackup
//
//  Created by Alex Coundouriotis on 10/21/24.
//

import Foundation
import UIKit

class AppDelegate: UIResponder, UIApplicationDelegate {
    
    func applicationDidBecomeActive(_ application: UIApplication) {
        CDClient.mainManagedObjectContext.refreshAllObjects()
    }
    
}
