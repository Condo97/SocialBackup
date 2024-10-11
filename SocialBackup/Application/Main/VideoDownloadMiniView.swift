//
//  VideoDownloadMiniView.swift
//  SocialBackup
//
//  Created by Alex Coundouriotis on 10/11/24.
//

import SwiftUI

struct VideoDownloadMiniView: View {
    
    @Binding var text: String
    @Binding var isLoading: Bool
    var onSubmit: () -> Void
    
    var body: some View {
        VStack {
            HStack {
                Image(systemName: "magnifyingglass")
                TextField("Enter Video URL...", text: $text)
                    .disabled(isLoading)
            }
            .foregroundStyle(Colors.text)
            .font(.custom(Constants.FontName.medium, size: 17.0))
            .padding()
            .background(RoundedRectangle(cornerRadius: 14.0)
                .stroke(Colors.text.opacity(0.1), lineWidth: 1))
                
            if !text.isEmpty {
                Button(action: onSubmit) {
                    HStack {
                        Spacer()
                        Text("Save")
                        Spacer()
                    }
                    .overlay {
                        HStack {
                            Spacer()
                            if isLoading {
                                ProgressView()
                            } else {
                                Image(systemName: "chevron.right")
                            }
                        }
                    }
                    .font(.custom(Constants.FontName.heavy, size: 17.0))
                    .foregroundStyle(Colors.elementTextColor)
                    .padding()
                    .background(Colors.elementBackgroundColor)
                    .clipShape(RoundedRectangle(cornerRadius: 14.0))
                }
                .disabled(isLoading)
            }
        }
    }
    
}

@available(iOS 17, *)
#Preview {
    
    @Previewable @State var text: String = ""
    @Previewable @State var isLoading: Bool = false
    
    return VideoDownloadMiniView(
        text: $text,
        isLoading: $isLoading,
        onSubmit: {
            
        })
    
}
