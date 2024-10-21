//
//  Array+Safe.swift
//  WriteSmith-SwiftUI
//
//  Created by Alex Coundouriotis on 9/28/24.
//

import Foundation
import SwiftUI

// A helper extension to safely access array elements.
extension Array {
    subscript(safe index: Index) -> Element? {
        return indices.contains(index) ? self[index] : nil
    }
}

// A helper extension to safely access array elements.
extension FetchedResults {
    subscript(safe index: Index) -> Element? {
        return indices.contains(index) ? self[index] : nil
    }
}
