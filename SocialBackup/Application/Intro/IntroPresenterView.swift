//
//  IntroPresenterView.swift
//  SocialBackup
//
//  Created by Alex Coundouriotis on 11/4/24.
//

import SwiftUI

struct IntroPresenterView: View {
    
    let onFinish: () -> Void
    
    private let introVideo1URL = Bundle.main.url(forResource: "Intro 1 Clip-MPEG-4", withExtension: "mp4")!
    
    @State private var isShowingSecondView: Bool = false
    
    var body: some View {
        NavigationStack {
            IntroView1(onNext: {
                isShowingSecondView = true
            })
            .navigationBarBackButtonHidden(true)
            .navigationBarTitleDisplayMode(.inline)
            .navigationDestination(isPresented: $isShowingSecondView) {
                IntroVideoView(
                    headerTopText: "Keep favorite posts",
                    headerBottomText: "FOREVER",
                    iconSystemName: "lock",
                    videoURL: introVideo1URL,
                    onNext: onFinish)
                .navigationBarBackButtonHidden(true)
                .navigationBarTitleDisplayMode(.inline)
            }
        }
    }
    
}

#Preview {
    
    IntroPresenterView(onFinish: {})
    
}
