//
//  URLUsernameExtractor.swift
//  SocialBackup
//
//  Created by Alex Coundouriotis on 10/27/24.
//

import Foundation

class URLUsernameExtractor {
    
    static func extractUsername(from urlString: String) -> String? {
        // Ensure the string is a valid URL
        guard let url = URL(string: urlString) else {
            return nil
        }
        // Break the path into components
        let pathComponents = url.pathComponents
        // Iterate over the components to find the username
        for component in pathComponents {
            if component.hasPrefix("@") {
                return component
            }
        }
        // If no username is found, return nil
        return nil
    }
    
}
