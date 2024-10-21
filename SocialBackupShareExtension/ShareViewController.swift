//
//  ShareViewController.swift
//  SocialBackupShareExtension
//
//  Created by Alex Coundouriotis on 10/12/24.
//

import Social
import SwiftUI
import UIKit
import UniformTypeIdentifiers

class ShareViewController: UIViewController {

    override func viewDidLoad() {
        super.viewDidLoad()
        
        // Ensure access to extensionItem and itemProvider
        guard let extensionItem = extensionContext?.inputItems.first as? NSExtensionItem,
              let itemProviders = extensionItem.attachments else {
            close()
            return
        }
        
        for itemProvider in itemProviders {
            itemProvider.loadItem(forTypeIdentifier: UTType.url.identifier, options: nil) { result, error in
                // TODO: Handle Errors
                
                // Get URL
                guard let result = result as? URL else {
                    // TODO: Handle Errors
                    print("Could not unwrap result as URL in ShareViewController!")
                    return
                }
                
                // Add to process queue
                QueuedTikTokDownloader.enqueue(urlString: result.absoluteString)
            }
            
//            itemProvider.loadItem(forTypeIdentifier: UTType.video.identifier, options: nil) { result, error in
//                // TODO: Handle Errors
//                
//                // Get video data
//                
//                // Save as video post in CoreData
//            }
//            
//            itemProvider.loadItem(forTypeIdentifier: UTType.image.identifier, options: nil) { result, error in
//                // TODO: Handle Errors
//                
//                // Save to processing queue
//                
//                // Save as photo post in CoreData
//            }
        }
        
        // Show SwiftUI view
        DispatchQueue.main.async {
//            // Create the blur effect view
//            let blurEffect = UIBlurEffect(style: .extraLight)
//            let blurEffectView = UIVisualEffectView(effect: blurEffect)
//            blurEffectView.translatesAutoresizingMaskIntoConstraints = false
//            self.view.addSubview(blurEffectView)
//            
//            // Set constraints for the blur effect view to cover the entire screen
//            NSLayoutConstraint.activate([
//                blurEffectView.topAnchor.constraint(equalTo: self.view.topAnchor),
//                blurEffectView.leadingAnchor.constraint(equalTo: self.view.leadingAnchor),
//                blurEffectView.trailingAnchor.constraint(equalTo: self.view.trailingAnchor),
//                blurEffectView.bottomAnchor.constraint(equalTo: self.view.bottomAnchor)
//            ])
            
            // Initialize your SwiftUI view
            let shareViewHostingController = UIHostingController(rootView: ShareRoot(onDismiss: self.close))
            self.addChild(shareViewHostingController)
            self.view.addSubview(shareViewHostingController.view)
            shareViewHostingController.didMove(toParent: self)
            
            // Set shareViewHostingController view background to clear
            shareViewHostingController.view.backgroundColor = .clear
            
            // Set constraints for your SwiftUI view
            shareViewHostingController.view.translatesAutoresizingMaskIntoConstraints = false
            NSLayoutConstraint.activate([
                shareViewHostingController.view.centerXAnchor.constraint(equalTo: self.view.centerXAnchor),
                shareViewHostingController.view.centerYAnchor.constraint(equalTo: self.view.centerYAnchor)
            ])
        }
    }
    
    /// Close the Share Extension
    func close() {
        self.extensionContext?.completeRequest(returningItems: [], completionHandler: nil)
    }

}
