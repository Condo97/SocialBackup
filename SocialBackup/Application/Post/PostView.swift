////
////  PostView.swift
////  SocialBackup
////
////  Created by Alex Coundouriotis on 10/11/24.
////
//
//import AVKit
//import SwiftUI
//
//struct PostView: View {
//    
//    private let player: AVPlayer
//
//    init(url: URL) {
//        self.player = AVPlayer(playerItem: AVPlayerItem(url: url))
//    }
//
//    var body: some View {
//        PostPlayer(player: player)
//            .onDisappear {
//                // Pause the player when the view disappears
//                player.pause()
//            }
//    }
//    
//}
//
////#Preview {
////    
////    PostView()
////    
////}