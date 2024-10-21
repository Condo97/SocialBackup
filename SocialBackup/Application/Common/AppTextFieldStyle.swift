//
//  AppTextFieldStyle.swift
//  SocialBackup
//
//  Created by Alex Coundouriotis on 10/11/24.
//

import SwiftUI

struct AppTextFieldStyle: ViewModifier {
    
    func body(content: Content) -> some View {
        content
            .foregroundStyle(Colors.text)
            .font(.custom(Constants.FontName.medium, size: 17.0))
            .padding()
            .background(
                ZStack {
                    RoundedRectangle(cornerRadius: 14.0)
                        .fill(Colors.foreground)
                    RoundedRectangle(cornerRadius: 14.0)
                        .stroke(Colors.text.opacity(0.5), lineWidth: 1)
                })
    }
    
}

extension View {
    
    func appTextFieldStyle() -> some View {
        self
            .modifier(AppTextFieldStyle())
    }
    
}
