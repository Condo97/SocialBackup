//
//  AutoResizingVideoPlayer.swift
//  SocialBackup
//
//  Created by Alex Coundouriotis on 11/4/24.
//

import SwiftUI
import AVKit

struct AutoResizingVideoPlayer: View {
    
    let url: URL

    @State private var shouldPlay: Bool = true
    @State private var player: AVPlayer
    @State private var aspectRatio: CGFloat = 16/9
    @State private var showReplayButton = false

    init(url: URL) {
        self.url = url
//        self._shouldPlay = shouldPlay
        
        _player = State(initialValue: AVPlayer(url: url))
    }

    var body: some View {
        ZStack {
            // VideoPlayer that adjusts to the video's aspect ratio
            AutoResizingVideoPlayerViewRepresentable(player: player)
                .aspectRatio(aspectRatio, contentMode: .fit)
                .overlay {
                    // Overlay with replay button when the video ends
                    if showReplayButton {
                        Color.black.opacity(0.5)
                            .overlay(
                                Button(action: {
                                    replay()
                                }) {
                                    VStack {
                                        Image(systemName: "arrow.circlepath")
                                            .font(.largeTitle)
                                            .foregroundColor(.white)
                                        Text("Replay")
                                            .foregroundColor(.white)
                                    }
                                }
                            )
                    }
                }
                .onAppear {
                    calculateAspectRatio()
                    if shouldPlay {
                        player.play()
                    }
                }
                .onDisappear {
                    player.pause()
                }
                .onChange(of: shouldPlay) { play in
                    if play {
                        player.play()
                    } else {
                        player.pause()
                    }
                }
                .onReceive(NotificationCenter.default.publisher(for: .AVPlayerItemDidPlayToEndTime, object: player.currentItem)) { _ in
                    showReplayButton = true
                    shouldPlay = false
                }
                .onChange(of: url) { newUrl in
                    player.replaceCurrentItem(with: AVPlayerItem(url: newUrl))
                    calculateAspectRatio()
                    if shouldPlay {
                        player.play()
                    }
                }
        }
    }

    // Calculate the video's aspect ratio based on its natural size
    private func calculateAspectRatio() {
        guard let track = player.currentItem?.asset.tracks(withMediaType: .video).first else {
            return
        }
        let size = track.naturalSize.applying(track.preferredTransform)
        aspectRatio = abs(size.width / size.height)
    }

    // Replay the video from the beginning
    private func replay() {
        player.seek(to: .zero)
        player.play()
        showReplayButton = false
        shouldPlay = true
    }
    
}

struct AutoResizingVideoPlayerViewRepresentable: UIViewRepresentable {
    let player: AVPlayer

    func makeUIView(context: Context) -> PlayerUIView {
        let view = PlayerUIView()
        view.playerLayer.player = player
        return view
    }

    func updateUIView(_ uiView: PlayerUIView, context: Context) {
        uiView.playerLayer.player = player
    }
}

class PlayerUIView: UIView {
    override static var layerClass: AnyClass {
        AVPlayerLayer.self
    }

    var playerLayer: AVPlayerLayer {
        layer as! AVPlayerLayer
    }
}

#Preview {
    
    ZStack {
        Color.blue
        
        AutoResizingVideoPlayer(
            url: Bundle.main.url(forResource: "Intro 1 Clip-MPEG-4", withExtension: "mp4")!
//            shouldPlay: .constant(true)
        )
        .clipShape(RoundedRectangle(cornerRadius: 14.0))
        .padding()
    }
    
}
