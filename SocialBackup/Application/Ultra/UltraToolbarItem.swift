//
//  UltraToolbarItem.swift
//  SocialBackup
//
//  Created by Alex Coundouriotis on 10/20/24.
//

import Foundation
import SwiftUI

struct UltraToolbarItem: ToolbarContent {
    
    @Binding var isShowingUltraView: Bool
    
    var body: some ToolbarContent {
        ToolbarItem(placement: .topBarTrailing) {
            Button(action: { isShowingUltraView = true }) {
                HStack(spacing: 0.0) {
                    Image(systemName: "sparkles")
                        .font(.custom(Constants.FontName.heavy, size: 17.0))
                    Text("AI")
                        .font(.custom(Constants.FontName.heavy, size: 20.0))
                }
                .foregroundStyle(Colors.accent)
            }
        }
    }
    
}

#Preview {
    
    NavigationStack {
        ZStack {
            
        }
        .toolbar {
            UltraToolbarItem(isShowingUltraView: .constant(false))
        }
    }
    
}
