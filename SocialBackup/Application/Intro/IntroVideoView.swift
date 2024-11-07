//
//  IntroVideoView.swift
//  SocialBackup
//
//  Created by Alex Coundouriotis on 11/4/24.
//

import SwiftUI

struct IntroVideoView: View {
    
    let headerTopText: String
    let headerBottomText: String
    let iconSystemName: String?
    let videoURL: URL
    let onNext: () -> Void
    
    @State private var shouldPlay: Bool = false
    @State private var shouldAnimateIn1: Bool = false
    @State private var shouldAnimateIn2: Bool = false
    
    var body: some View {
        VStack {
            Spacer()
            
            ZStack {
                if let iconSystemName {
                    Image(systemName: iconSystemName)
                        .font(.custom(Constants.FontName.light, size: 170.0))
                        .foregroundStyle(Colors.foreground)
                        .opacity(shouldAnimateIn2 ? 0.2 : 0.0)
                        .padding(-16)
                }
                
                VStack {
                    Text(headerTopText)
                        .font(.custom(Constants.FontName.body, size: 24.0))
                        .foregroundStyle(Colors.text)
                        .padding(.top)
                    
                    Text(headerBottomText)
                        .font(.custom(Constants.FontName.black, size: 60.0))
                        .foregroundStyle(Colors.text)
                        .opacity(shouldAnimateIn1 ? 1.0 : 0.0)
                }
            }
            
            Spacer()
            
            AutoResizingVideoPlayer(url: videoURL)
                .clipShape(RoundedRectangle(cornerRadius: 14.0))
//                .padding(.horizontal)
                .padding()
            
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
        .onAppear {
            DispatchQueue.main.asyncAfter(deadline: .now() + 0.2) {
                withAnimation(.easeIn(duration: 1.0)) {
                    shouldAnimateIn1 = true
                }
                
                DispatchQueue.main.asyncAfter(deadline: .now() + 1) {
                    withAnimation(.easeIn(duration: 1.0)) {
                        shouldAnimateIn2 = true
                    }
                }
            }
        }
    }
    
}

#Preview {
    
    IntroVideoView(
        headerTopText: "Save your favorite posts",
        headerBottomText: "Forever",
        iconSystemName: "lock",
        videoURL: Bundle.main.url(forResource: "Intro 1 Clip-MPEG-4", withExtension: "mp4")!,
        onNext: {
            
        }
    )
}
