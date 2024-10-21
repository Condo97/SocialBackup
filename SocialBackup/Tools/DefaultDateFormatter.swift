//
//  DefaultDateFormatter.swift
//  SocialBackup
//
//  Created by Alex Coundouriotis on 10/12/24.
//

import SwiftUI

class DefaultDateFormatter {
    
    static let defaultDateFormatter: DateFormatter = {
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "MMM d, h:mm a"
        return dateFormatter
    }()
    
}
