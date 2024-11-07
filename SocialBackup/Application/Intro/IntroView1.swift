//
//  IntroView1.swift
//  SocialBackup
//
//  Created by Alex Coundouriotis on 11/4/24.
//

import SwiftUI

struct IntroView1: View {
    
    let onNext: () -> Void
    
    private let videoURL = Bundle.main.url(forResource: "Intro Animation", withExtension: "mp4")!
    
    var body: some View {
        VStack {
            VStack(spacing: 16.0) {
                Image(Images.logoText)
                    .resizable()
                    .aspectRatio(contentMode: .fit)
                    .foregroundStyle(Colors.accent)
                    .padding(.horizontal)
            
                Text("Social Media Archive")
                    .font(.custom(Constants.FontName.heavy, size: 28.0))
                    .foregroundStyle(Colors.text)
                    .padding(.horizontal)
                
                Text("Save any post from any app.")
                    .font(.custom(Constants.FontName.body, size: 20.0))
                    .foregroundStyle(Colors.text)
                    .padding(.horizontal)
            }
            
            Spacer()
            
            AutoResizingVideoPlayer(url: videoURL)
                .padding(.horizontal)
            
            Spacer()
            
            Button(action: onNext) {
                Text("Next")
                    .frame(maxWidth: .infinity)
                    .overlay(alignment: .trailing) {
                        Image(systemName: "chevron.right")
                    }
                    .appButtonStyle()
            }
            .padding(.horizontal)
        }
        .background(Colors.background)
    }
    
}

#Preview {
    
    IntroView1(onNext: {
        
    })
    
}
