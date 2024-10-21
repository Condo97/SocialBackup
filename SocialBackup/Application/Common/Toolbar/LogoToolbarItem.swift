//
//  LogoToolbarItem.swift
//  SocialBackup
//
//  Created by Alex Coundouriotis on 10/20/24.
//

import SwiftUI

struct LogoToolbarItem: ToolbarContent {
    
    var body: some ToolbarContent {
        ToolbarItem(placement: .principal) {
            Image(Images.logoText)
                .resizable()
                .aspectRatio(contentMode: .fit)
                .frame(height: 40.0)
                .foregroundStyle(Colors.text)
        }
    }
    
}

#Preview {
    
    NavigationStack {
        ZStack {
            
        }
        .toolbar {
            LogoToolbarItem()
        }
    }
}
